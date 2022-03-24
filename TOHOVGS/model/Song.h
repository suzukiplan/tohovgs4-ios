/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <Foundation/Foundation.h>
#import "Album.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SongPrimaryUseType) {
    SongPrimaryUseTypePreset,
    SongPrimaryUseTypeDownloaded,
};

@class Album;

@interface Song : NSObject
@property (nonatomic, readonly) Album* parentAlbum;
@property (nonatomic, readonly, nullable) NSString* appleId;
@property (nonatomic, readonly) NSString* mml;
@property (nonatomic, readonly) NSInteger ver;
@property (nonatomic, readonly) NSInteger loop;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly, nullable) NSString* english;
@property (nonatomic) SongPrimaryUseType primaryUseType;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, readonly, nullable) NSString* appleMusicURL;
+ (NSMutableArray<Song*>*)parseJsonArray:(NSArray*)array album:(Album*)album;
@end

NS_ASSUME_NONNULL_END
