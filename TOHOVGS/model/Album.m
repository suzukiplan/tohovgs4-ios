/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "Album.h"

@interface Album()
@property (nonatomic, readwrite) NSString* albumId;
@property (nonatomic, readwrite) NSString* name;
@property (nonatomic, readwrite) NSString* formalName;
@property (nonatomic, readwrite) NSString* copyright;
@property (nonatomic, readwrite) NSInteger compatColor;
@property (nonatomic, readwrite) BOOL defaultLocked;
@property (nonatomic, readwrite) NSArray<Song*>* songs;
@end

@implementation Album

+ (NSArray<Album*>*)parseJsonArray:(NSArray*)array
{
    NSMutableArray<Album*>* result = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary* data in array) {
        Album* album = [[Album alloc] init];
        album.albumId = data[@"albumId"];
        album.name = data[@"name"];
        album.formalName = data[@"formalName"];
        album.copyright = data[@"copyright"];
        album.compatColor = [data[@"compatColor"] integerValue];
        album.defaultLocked = [data[@"defaultLocked"] boolValue];
        album.songs = [Song parseJsonArray:data[@"songs"] album:album];
        [result addObject:album];
    }
    return result;
}

@end
