/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import <AVFoundation/AVFoundation.h>
#import "MusicManager.h"
#import "../ControlDelegate.h"
#import "../vgs/vgsplay-ios.h"

extern void* vgsdec;

@interface MusicManager()
@property (nonatomic, weak) NSUserDefaults* userDefaults;
@property (nonatomic, readwrite) NSArray<Album*>* albums;
@property (nonatomic, readwrite) NSMutableArray<Song*>* allUnlockedSongs;
@property (nonatomic, readwrite, weak) Song* playingSong;
@property (nonatomic) NSTimer* monitoringTimer;
@end

@implementation MusicManager

- (instancetype)init
{
    if (self = [super init]) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        NSError* error = nil;
        NSString* path = [[NSBundle mainBundle] pathForResource:@"assets/songlist" ofType:@"json"];
        NSLog(@"songlist: %@", path);
        NSString* jsonString = [[NSString alloc] initWithContentsOfFile:path
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUnicodeStringEncoding];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        _albums = [Album parseJsonArray:json[@"albums"]];
        _masterVolume = 100 - [_userDefaults integerForKey:@"master_volume"];
        vgsplay_changeMasterVolume((int)_masterVolume);
        [self _refreshAllUnlockedSongs];
    }
    return self;
}

- (void)_refreshAllUnlockedSongs
{
    if (!_allUnlockedSongs) {
        _allUnlockedSongs = [NSMutableArray array];
    } else {
        [_allUnlockedSongs removeAllObjects];
    }
    for (Album* album in _albums) {
        for (Song* song in album.songs) {
            if (![self isLockedSong:song]) {
                [_allUnlockedSongs addObject:song];
            }
        }
    }
}

- (NSString*)mmlPathOfSong:(Song*)song
{
    NSString* resourceName = [NSString stringWithFormat:@"assets/mml/%@", song.mml];
    return [[NSBundle mainBundle] pathForResource:resourceName ofType:@"mml"];
}

- (void)_active:(BOOL)active
{
    NSError* error;
    [[AVAudioSession sharedInstance] setActive:active error:&error];
    if (error) {
        NSLog(@"cannot %@ audio session: %@", active ? @"activate" : @"deactivate", error);
    }
}

- (void)playSong:(Song*)song
{
    _playingSong = song;
    NSString* mmlPath = [self mmlPathOfSong:song];
    vgsplay_start(mmlPath.UTF8String, (int)song.loop, _infinity ? 1 : 0, 0, 0, 16);
    [_delegate musicManager:self didStartPlayingSong:song];
    _monitoringTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                        target:self
                                                      selector:@selector(_monitor:)
                                                      userInfo:nil
                                                       repeats:YES];
    [_monitoringTimer fire];
    [self _active:YES];
}

- (void)_monitor:(NSTimer*)timer
{
    __weak MusicManager* weakSelf = self;
    NSInteger progress = vgsplay_getCurrentTime();
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.playingSong) {
            if (!vgsplay_isPlaying()) {
                NSLog(@"detect end: %@", weakSelf.playingSong.name);
                [weakSelf.delegate musicManager:weakSelf didEndPlayingSong:weakSelf.playingSong];
            } else {
                [weakSelf.delegate musicManager:weakSelf didChangeProgress:progress];
            }
        }
    });
}

- (void)stopPlaying
{
    if (_playingSong) {
        BOOL isPlaying = vgsplay_isPlaying() ? YES : NO;
        vgsplay_stop();
        _playingSong.isPlaying = NO;
        if (isPlaying) {
            [_delegate musicManager:self didStopPlayingSong:_playingSong];
        }
        _playingSong = nil;
        [self _active:NO];
    }
    if (_monitoringTimer) {
        [_monitoringTimer invalidate];
        _monitoringTimer = nil;
    }
}

- (void)seekTo:(NSInteger)progress
{
    NSLog(@"seekTo: %ld", progress);
    vgsplay_seek((unsigned int)progress);
}

- (void)setInfinity:(BOOL)infinity
{
    _infinity = infinity;
    vgsplay_changeInfinity(infinity ? 1 : 0);
}

- (NSString*)_keyForSong:(Song*)song
{
    return [NSString stringWithFormat:@"locked_%@", song.mml];
}

- (BOOL)isLockedSong:(Song*)song
{
    NSString* locked = [_userDefaults stringForKey:[self _keyForSong:song]];
    if (!locked) {
        return song.parentAlbum.defaultLocked;
    }
    return [locked isEqualToString:@"L"];
}

- (void)lock:(BOOL)lock song:(Song*)song
{
    NSString* locked = lock ? @"L" : @"U";
    [_userDefaults setObject:locked forKey:[self _keyForSong:song]];
    [self _refreshAllUnlockedSongs];
}

- (void)setMasterVolume:(NSInteger)masterVolume
{
    _masterVolume = masterVolume;
    [_userDefaults setInteger:(100 - masterVolume) forKey:@"master_volume"];
    vgsplay_changeMasterVolume((int)masterVolume);
}

@end
