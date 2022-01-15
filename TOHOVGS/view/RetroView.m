//
//  RetroView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import "RetroView.h"
#import "RetroLayer.h"
#import "vge.h"

extern int g_flingY;
extern int g_flingX;

struct MoveDir {
    NSTimeInterval time;
    int movedX;
    int movedY;
};

static struct MoveDir _moveDir[256];
static int _moveCur;

@interface RetroView ()
@property (nonatomic, weak) NSUserDefaults* userDefaults;
@property (nonatomic, weak) MusicManager* musicManager;
@property (nonatomic) NSMutableArray<Album*>* unlockedAlbums;
@property (nonatomic) CADisplayLink* displayLink;
@property (nonatomic) BOOL destroyed;
@property (nonatomic) NSTimeInterval timestampBegan;
@property (nonatomic) CGPoint pointBegan;
@property (nonatomic) CGPoint zoom;
@end

@implementation RetroView


+ (Class)layerClass
{
    return [RetroLayer class];
}

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
{
    if (self = [super init]) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _moveCur = 0;
        memset(&_moveDir, 0, sizeof(_moveDir));
        _musicManager = [controlDelegate getViewController].musicManager;
        _unlockedAlbums = [NSMutableArray arrayWithCapacity:_musicManager.albums.count];
        for (Song* song in _musicManager.allUnlockedSongs) {
            if (NSNotFound == [_unlockedAlbums indexOfObject:song.parentAlbum]) {
                [_unlockedAlbums addObject:song.parentAlbum];
            }
        }
        tohovgs_cleanUp();
        tohovgs_allocate((int)_unlockedAlbums.count, (int)_musicManager.allUnlockedSongs.count);
        int titleIndex = 0;
        int songIndex = 0;
        int albumId = 0x10;
        for (Album* album in _unlockedAlbums) {
            const char* albumTitle = [album.formalName cStringUsingEncoding:NSShiftJISStringEncoding];
            const char* albumCopyright = [album.copyright cStringUsingEncoding:NSShiftJISStringEncoding];
            int songNum = 0;
            int color = (int)album.compatColor;
            for (Song* song in album.songs) {
                if (![_musicManager isLockedSong:song]) {
                    const char* mmlPath = [_musicManager mmlPathOfSong:song].UTF8String;
                    const char* titleJ = [song.name cStringUsingEncoding:NSShiftJISStringEncoding];
                    const char* titleE = titleJ;
                    if (song.english) {
                        titleE = [song.english cStringUsingEncoding:NSShiftJISStringEncoding];
                    }
                    const char* cp = strstr(song.mml.UTF8String, "-");
                    int no = 0;
                    if (cp) {
                        cp++;
                        no = atoi(cp);
                    }
                    tohovgs_setSong(songIndex,
                                    albumId,
                                    no,
                                    (int)song.loop,
                                    color,
                                    (void*)mmlPath,
                                    strlen(mmlPath),
                                    (void*)titleJ,
                                    strlen(titleJ),
                                    (void*)titleE,
                                    strlen(titleE));
                    songNum++;
                    songIndex++;
                }
            }
            tohovgs_setTitle(titleIndex,
                             albumId,
                             songNum,
                             (void*)albumTitle,
                             strlen(albumTitle),
                             (void*)albumCopyright,
                             strlen(albumCopyright));
            titleIndex++;
            albumId += 0x10;
        }
        NSString* kanjiPath = [[NSBundle mainBundle] pathForResource:@"assets/compat/DSLOT255"
                                                              ofType:@"DAT"];
        NSData* kanji = [NSData dataWithContentsOfFile:kanjiPath];
        tohovgs_loadKanji(kanji.bytes, kanji.length);
        NSString* c0Path = [[NSBundle mainBundle] pathForResource:@"assets/compat/GSLOT000"
                                                         ofType:@"CHR"];
        NSData* c0 = [NSData dataWithContentsOfFile:c0Path];
        vge_gload(0, c0.bytes);
        NSString* c1Path = [[NSBundle mainBundle] pathForResource:@"assets/compat/GSLOT255"
                                                         ofType:@"CHR"];
        NSData* c1 = [NSData dataWithContentsOfFile:c1Path];
        vge_gload(1, c1.bytes);
        tohovgs_setPreference((int)[_userDefaults integerForKey:@"compat_current_title_id"],
                              (int)[_userDefaults integerForKey:@"compat_loop"],
                              (int)[_userDefaults integerForKey:@"compat_base"],
                              (int)[_userDefaults integerForKey:@"compat_infinity"],
                              (int)[_userDefaults integerForKey:@"compat_kobushi"],
                              (int)[_userDefaults integerForKey:@"compat_locale_id"],
                              (int)[_userDefaults integerForKey:@"compat_list_type"]);
        self.opaque = NO;
        self.clearsContextBeforeDrawing = NO;
        self.multipleTouchEnabled = NO;
        self.userInteractionEnabled = YES;
        ((RetroLayer*)self.layer).retroView = self;
        _displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(_detectVsync:)];
        _displayLink.preferredFramesPerSecond = 60;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _destroyed = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _zoom = CGPointMake(240.0 / frame.size.width, 320.0 / frame.size.height);
}

- (void)_detectVsync:(CADisplayLink*)sender;
{
    if (!_destroyed) {
        [(RetroLayer*)self.layer drawFrame];
    }
}

- (void)dealloc
{
    [self destroy];
}

- (void)destroy
{
    if (!_destroyed) {
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_displayLink invalidate];
        _displayLink = nil;
        _destroyed = YES;
        struct Preferences* prf = tohovgs_getPreference();
        [_userDefaults setInteger:prf->base forKey:@"compat_base"];
        [_userDefaults setInteger:prf->currentTitleId forKey:@"compat_current_title_id"];
        [_userDefaults setInteger:prf->infinity forKey:@"compat_infinity"];
        [_userDefaults setInteger:prf->kobushi forKey:@"compat_kobushi"];
        [_userDefaults setInteger:prf->listType forKey:@"compat_list_type"];
        [_userDefaults setInteger:prf->loop forKey:@"compat_loop"];
        [_userDefaults setInteger:prf->localeId forKey:@"compat_locale_id"];
        tohovgs_cleanUp();
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _timestampBegan = event.timestamp;
    _pointBegan = [touch locationInView:self];
    _moveCur = 0;
    memset(_moveDir, 0, sizeof(_moveDir));
    
    touches=[event allTouches];
    UITouch* aTouch=[touches anyObject];
    CGPoint point=[aTouch locationInView:self];
    _touch.s = 1;
    _touch.cx = (int)(point.x * _zoom.x);
    _touch.cy = (int)(point.y * _zoom.y);
    _touch.px = _touch.cx;
    _touch.py = _touch.cy;
    _touch.dx = 0;
    _touch.dy = 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    touches=[event allTouches];
    UITouch* aTouch=[touches anyObject];
    CGPoint point=[aTouch locationInView:self];
    _touch.s = 1;
    _touch.px = _touch.cx;
    _touch.py = _touch.cy;
    _touch.cx = (int)(point.x * _zoom.x);
    _touch.cy = (int)(point.y * _zoom.y);
    _moveDir[_moveCur].time = [[NSDate date] timeIntervalSince1970];
    _moveDir[_moveCur].movedX = _touch.cx-_touch.px;
    _moveDir[_moveCur].movedY = _touch.cy-_touch.py;
    _moveCur++;
    _moveCur &= 0xff;
    if(_touch.px) _touch.dx += _touch.cx-_touch.px;
    if(_touch.py) _touch.dy += _touch.cy-_touch.py;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    memset(&_touch, 0, sizeof(_touch));
    int sp = (_moveCur + 1) & 0xff;
    g_flingX = 0;
    g_flingY = 0;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    while (sp != _moveCur) {
        if (now - _moveDir[sp].time < 0.1) {
            g_flingX += _moveDir[sp].movedX;
            g_flingY += _moveDir[sp].movedY;
        }
        sp++;
        sp &= 0xff;
    }
    if (abs(g_flingY) < abs(g_flingX)) {
        g_flingY = 0;
    } else {
        g_flingX = 0;
    }
}

@end
