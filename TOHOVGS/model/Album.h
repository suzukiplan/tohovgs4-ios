/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <Foundation/Foundation.h>
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@class Song;

@interface Album : NSObject
@property (nonatomic, readonly) NSString* albumId;
@property (nonatomic, readonly, nullable) NSString* appleId;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* formalName;
@property (nonatomic, readonly) NSString* copyright;
@property (nonatomic, readonly) NSInteger compatColor;
@property (nonatomic, readonly) BOOL defaultLocked;
@property (nonatomic, readonly) NSMutableArray<Song*>* songs;
+ (NSArray<Album*>*)parseJsonArray:(NSArray*)array;
@end

NS_ASSUME_NONNULL_END
