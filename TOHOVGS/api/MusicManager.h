/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import <Foundation/Foundation.h>
#import "../model/SongList.h"

NS_ASSUME_NONNULL_BEGIN

@class MusicManager;

@protocol MusicManagerDelegate <NSObject>
- (void)musicManager:(MusicManager*)manager didStartPlayingSong:(Song*)song;
- (void)musicManager:(MusicManager*)manager didStopPlayingSong:(Song*)song;
- (void)musicManager:(MusicManager*)manager didEndPlayingSong:(Song*)song;
- (void)musicManager:(MusicManager*)manager didChangeProgress:(NSInteger)progress;
@end

@interface MusicManager : NSObject
@property (nonatomic, weak) id<MusicManagerDelegate> delegate;
@property (nonatomic, readonly) SongList* songList;
@property (nonatomic, readonly, weak) NSArray<Album*>* albums;
@property (nonatomic, readonly) NSArray<Song*>* allUnlockedSongs;
@property (nonatomic, readonly, weak) Song* playingSong;
@property (nonatomic) BOOL infinity;
@property (nonatomic) NSInteger masterVolume;
- (NSString*)mmlPathOfSong:(Song*)song;
- (void)playSong:(Song*)song;
- (void)stopPlaying;
- (BOOL)isPlayingSong:(Song*)song;
- (BOOL)isKeepingSong:(Song*)song;
- (void)stopPlayingWithKeep:(BOOL)keep;
- (void)purgeKeepInfo;
- (void)seekTo:(NSInteger)progress;
- (BOOL)isLockedSong:(Song*)song;
- (void)lock:(BOOL)lock song:(Song*)song;
- (void)checkUpdateWithCallback:(void(^)(BOOL updateExist))done;
- (void)updateSongListWithCallback:(void(^)(NSError* _Nullable error,
                                            BOOL updated,
                                            NSArray<Song*>* _Nullable downloaded))done;
@end

NS_ASSUME_NONNULL_END
