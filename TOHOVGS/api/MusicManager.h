//
//  MusicManager.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import <Foundation/Foundation.h>
#import "../model/Album.h"

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
@property (nonatomic, readonly) NSArray<Album*>* albums;
@property (nonatomic, readonly) NSArray<Song*>* allUnlockedSongs;
@property (nonatomic) BOOL infinity;
- (void)playSong:(Song*)song;
- (void)stopPlaying;
- (void)seekTo:(NSInteger)progress;
- (BOOL)isLockedSong:(Song*)song;
- (void)lock:(BOOL)lock song:(Song*)song;
@end

NS_ASSUME_NONNULL_END
