//
//  Album.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <Foundation/Foundation.h>
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@class Song;

@interface Album : NSObject
@property (nonatomic, readonly) NSString* albumId;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* formalName;
@property (nonatomic, readonly) NSString* copyright;
@property (nonatomic, readonly) NSInteger compatColor;
@property (nonatomic, readonly) BOOL defaultLocked;
@property (nonatomic, readonly) NSArray<Song*>* songs;
+ (NSArray<Album*>*)parseJsonArray:(NSArray*)array;
@end

NS_ASSUME_NONNULL_END
