//
//  Song.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <Foundation/Foundation.h>
#import "Album.h"

NS_ASSUME_NONNULL_BEGIN

@class Album;

@interface Song : NSObject
@property (nonatomic, readonly) Album* parentAlbum;
@property (nonatomic, readonly) NSString* mml;
@property (nonatomic, readonly) NSInteger loop;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly, nullable) NSString* english;
@property (nonatomic, readonly, nullable) NSString* french;
@property (nonatomic) BOOL isPlaying;
+ (NSArray<Song*>*)parseJsonArray:(NSArray*)array album:(Album*)album;
@end

NS_ASSUME_NONNULL_END
