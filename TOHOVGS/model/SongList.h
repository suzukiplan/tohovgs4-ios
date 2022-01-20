/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import <Foundation/Foundation.h>
#import "Album.h"

NS_ASSUME_NONNULL_BEGIN

@interface SongList : NSObject
@property (nonatomic, readonly) NSString* version;
@property (nonatomic, readonly) NSArray<Album*>* albums;
@property (nonatomic, readonly) NSString* sha1;
@property (nonatomic, readonly) NSString* jsonString;
@property (nonatomic, readonly) NSInteger numberOfSongs;
@property (nonatomic, readonly) NSArray<Song*>* enumAllSongs;
@property (nonatomic, readonly) BOOL songRemoved;
+ (SongList* __nullable)fromFile:(NSString*)filePath;
+ (SongList* __nullable)fromJsonString:(NSString*)jsonString;
- (void)removeSong:(Song*)song;
@end

NS_ASSUME_NONNULL_END
