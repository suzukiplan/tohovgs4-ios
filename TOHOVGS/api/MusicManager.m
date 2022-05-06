/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import <AVFoundation/AVFoundation.h>
#import "MusicManager.h"
#import "../ControlDelegate.h"
#import "../vgs/vgsplay-ios.h"
#import "WebAPI.h"

extern void* vgsdec;

@interface MusicManager()
@property (nonatomic) WebAPI* api;
@property (nonatomic, weak) NSUserDefaults* userDefaults;
@property (nonatomic, readwrite) SongList* songList;
@property (nonatomic, readwrite, weak) NSArray<Album*>* albums;
@property (nonatomic, readwrite) NSMutableArray<Song*>* allUnlockedSongs;
@property (nonatomic, readwrite, weak) Song* playingSong;
@property (nonatomic, readwrite, weak) Song* keepSong;
@property (nonatomic) int keepDuration;
@property (nonatomic) NSTimer* monitoringTimer;
@property (nonatomic) NSError* mmlDownloadError;
@end

@implementation MusicManager

- (instancetype)init
{
    if (self = [super init]) {
        _api = [[WebAPI alloc] init];
        _userDefaults = [NSUserDefaults standardUserDefaults];
        // Choose a latest songlist.json from AppBundle or Downloaded
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* downloadPath = [paths[0] stringByAppendingPathComponent:@"songlist.json"];
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"assets/songlist" ofType:@"json"];
        SongList* downloadSongList = [SongList fromFile:downloadPath];
        SongList* bundleSongList = [SongList fromFile:bundlePath];
        if (!downloadSongList) {
            NSLog(@"Use AppBundle songlist.json (not downloaded)");
            _songList = bundleSongList;
        } else {
            NSArray<Song*>* downloadSongs = downloadSongList.enumAllSongs;
            NSArray<Song*>* bundleSongs = bundleSongList.enumAllSongs;
            for (Song* bundleSong in bundleSongs) {
                for (Song* downloadSong in downloadSongs) {
                    if ([bundleSong.mml isEqualToString:downloadSong.mml]) {
                        if (bundleSong.ver < downloadSong.ver) {
                            NSLog(@"%@.mml will be preferentially used downloaded data.", bundleSong.mml);
                            bundleSong.primaryUseType = SongPrimaryUseTypeDownloaded;
                            downloadSong.primaryUseType = SongPrimaryUseTypeDownloaded;
                        } else {
                            bundleSong.primaryUseType = SongPrimaryUseTypePreset;
                            downloadSong.primaryUseType = SongPrimaryUseTypePreset;
                        }
                    }
                }
            }
            if ([downloadSongList.version compare:bundleSongList.version] < 0) {
                // NOTE: May be rare case
                NSLog(@"Use AppBundle songlist.json (newer than downloaded)");
                _songList = bundleSongList;
            } else {
                NSLog(@"Use downloaded songlist.json");
                _songList = downloadSongList;
            }
        }

        // remove MML download failed songs if exist
        NSArray<Song*>* allSongs = _songList.enumAllSongs;
        for (Song* song in allSongs) {
            if (![self _getMmlPathWithSong:song]) {
                NSLog(@"remove song: %@ (MML file not found)", song.name);
                [_songList removeSong:song];
            }
        }
        _albums = _songList.albums;

        // reset master volume
        _masterVolume = 100 - [_userDefaults integerForKey:@"master_volume"];
        vgsplay_changeMasterVolume((int)_masterVolume);

        [self _refreshAllUnlockedSongs];
    }
    return self;
}

- (NSString*)_getMmlPathWithSong:(Song*)song
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (song.primaryUseType == SongPrimaryUseTypeDownloaded) {
        NSString* downloadMmlPath = [NSString stringWithFormat:@"%@.mml", song.mml];
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* downloadPath = [paths[0] stringByAppendingPathComponent:downloadMmlPath];
        if ([fileManager fileExistsAtPath:downloadPath isDirectory:nil]) {
            return downloadPath;
        }
        NSString* bunndleMmlName = [NSString stringWithFormat:@"assets/mml/%@", song.mml];
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:bunndleMmlName ofType:@"mml"];
        if ([fileManager fileExistsAtPath:bundlePath isDirectory:nil]) {
            return bundlePath;
        }
    } else {
        NSString* bunndleMmlName = [NSString stringWithFormat:@"assets/mml/%@", song.mml];
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:bunndleMmlName ofType:@"mml"];
        if ([fileManager fileExistsAtPath:bundlePath isDirectory:nil]) {
            return bundlePath;
        }
        NSString* downloadMmlPath = [NSString stringWithFormat:@"%@.mml", song.mml];
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* downloadPath = [paths[0] stringByAppendingPathComponent:downloadMmlPath];
        if ([fileManager fileExistsAtPath:downloadPath isDirectory:nil]) {
            return downloadPath;
        }
    }
    return nil;
}

- (NSArray<Song*>*)enumUndownloadedMmlSongs
{
    NSMutableArray<Song*>* result = [NSMutableArray arrayWithCapacity:_songList.numberOfSongs];
    for (Album* album in _songList.albums) {
        [result addObjectsFromArray:album.songs];
    }
    return result;
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
    return [self _getMmlPathWithSong:song];
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
    int seek = 0;
    if ([_keepSong.mml isEqualToString:song.mml]) {
        seek = _keepDuration;
    }
    _keepSong = nil;
    _playingSong = song;
    NSString* mmlPath = [self mmlPathOfSong:song];
    NSInteger kobushi = [[NSUserDefaults standardUserDefaults] integerForKey:@"compat_kobushi"];
    vgsplay_start(mmlPath.UTF8String, (int)song.loop, _infinity ? 1 : 0, kobushi ? 1 : 0, seek, 16);
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
    [self stopPlayingWithKeep:NO];
}

- (BOOL)isPlayingSong:(Song*)song
{
    return _playingSong && [song.mml isEqualToString:_playingSong.mml];
}

- (BOOL)isKeepingSong:(Song*)song
{
    return _keepSong && [song.mml isEqualToString:_keepSong.mml];
}

- (void)stopPlayingWithKeep:(BOOL)keep
{
    if (_playingSong) {
        BOOL isPlaying = vgsplay_isPlaying() ? YES : NO;
        if (isPlaying && keep) {
            _keepDuration = vgsplay_getCurrentTime();
            _keepSong = _playingSong;
        } else {
            _keepDuration = 0;
            _keepSong = nil;
        }
        vgsplay_stop();
        _playingSong.isPlaying = keep;
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

- (void)purgeKeepInfo
{
    _keepSong = nil;
    _keepDuration = 0;
    [self stopPlaying];
}

- (void)seekTo:(NSInteger)progress
{
    NSLog(@"seekTo: %ld", progress);
    if (vgsplay_isPlaying()) {
        vgsplay_seek((unsigned int)progress);
    } else if (_keepSong) {
        _keepDuration = (int)progress;
        [self playSong:_keepSong];
    }
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
    if (_masterVolume != masterVolume) {
        _masterVolume = masterVolume;
        [_userDefaults setInteger:(100 - masterVolume) forKey:@"master_volume"];
        vgsplay_changeMasterVolume((int)masterVolume);
    }
}

- (void)checkUpdateWithCallback:(void(^)(BOOL updateExist))done
{
    [_api checkUpdateWithCurrentVersion:_songList.version done:^(NSError* error, BOOL updatable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            done(updatable);
        });
    }];
}

- (void)updateSongListWithCallback:(void(^)(NSError* _Nullable error,
                                            BOOL updated,
                                            NSArray<Song*>* _Nullable downloaded))done
{
    NSLog(@"Updating songlist...");
    __weak MusicManager* weakSelf = self;
    _mmlDownloadError = nil;
    [_api checkUpdateWithCurrentVersion:_songList.version done:^(NSError* error, BOOL updatable) {
        usleep(1000000);
        if (updatable) {
            [weakSelf.api acquireSongList:^(NSError* error, SongList * _Nullable songList) {
                if (!songList) {
                    NSLog(@"failed download songlist.json: %@", error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        done(error, NO, nil);
                    });
                } else {
                    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSMutableArray<Song*>* downloaded = [NSMutableArray array];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (Song* song in songList.enumAllSongs) {
                            Song* currentSong = [weakSelf.songList searchSongOfMML:song.mml];
                            if (!currentSong || currentSong.ver < song.ver) {
                                if (currentSong) {
                                    song.primaryUseType = SongPrimaryUseTypeDownloaded;
                                }
                                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                                [weakSelf.api acquireMmlWithSong:song done:^(NSError* error, NSString * _Nonnull mml) {
                                    if (!mml) {
                                        NSLog(@"failed download %@: %@", song.name, error);
                                        weakSelf.mmlDownloadError = error;
                                    } else {
                                        NSString* path = [paths[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mml", song.mml]];
                                        [mml writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                        [downloaded addObject:song];
                                    }
                                    dispatch_semaphore_signal(semaphore);
                                }];
                                while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
                                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
                                }
                                if (weakSelf.mmlDownloadError) {
                                    break;
                                }
                            }
                        }
                        NSLog(@"Completed all MML file download tasks");
                        BOOL updated = NO;
                        if (!weakSelf.mmlDownloadError) {
                            weakSelf.songList = songList;
                            weakSelf.albums = songList.albums;
                            [weakSelf _refreshAllUnlockedSongs];
                            NSString* path = [paths[0] stringByAppendingPathComponent:@"songlist.json"];
                            [songList.jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            updated = YES;
                        }
                        done(weakSelf.mmlDownloadError, updated, downloaded);
                    });
                }
            }];
        } else {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    done(error, NO, nil);
                });
            } else {
                NSLog(@"songlist.json is already latest");
                dispatch_async(dispatch_get_main_queue(), ^{
                    done(nil, NO, @[]);
                });
            }
        }
    }];
}

@end
