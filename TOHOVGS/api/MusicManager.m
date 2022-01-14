//
//  MusicManager.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import "MusicManager.h"
#import "../ControlDelegate.h"
#import "../vgs/vgsplay-ios.h"

extern void* vgsdec;

@interface MusicManager()
@property (nonatomic, readwrite) NSArray<Album*>* albums;
@property (nonatomic, readwrite) NSMutableArray<Song*>* allUnlockedSongs;
@property (nonatomic, weak) Song* playingSong;
@property (nonatomic) NSTimer* monitoringTimer;
@end

@implementation MusicManager

- (instancetype)init
{
    if (self = [super init]) {
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
        _allUnlockedSongs = [NSMutableArray array];
        for (Album* album in _albums) {
            NSLog(@"Exist album: %@", album.name);
            [_allUnlockedSongs addObjectsFromArray:album.songs]; // TODO: ロックされている曲を除外
        }
    }
    return self;
}

- (void)playSong:(Song*)song
{
    _playingSong = song;
    NSString* resourceName = [NSString stringWithFormat:@"assets/mml/%@", song.mml];
    NSString* mmlPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"mml"];
    vgsplay_start(mmlPath.UTF8String);
    [_delegate musicManager:self didStartPlayingSong:song];
    _monitoringTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                        target:self
                                                      selector:@selector(_monitor:)
                                                      userInfo:nil
                                                       repeats:YES];
    [_monitoringTimer fire];
}

- (void)_monitor:(NSTimer*)timer
{
    __weak MusicManager* weakSelf = self;
    NSInteger progress = vgsplay_getCurrentTime();
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.delegate musicManager:weakSelf didChangeProgress:progress];
    });
}

- (void)stopPlaying
{
    if (_playingSong) {
        vgsplay_stop();
        _playingSong.isPlaying = NO;
        [_delegate musicManager:self didStopPlayingSong:_playingSong];
        _playingSong = nil;
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

@end
