/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "Song.h"

@interface Song()
@property (nonatomic, readwrite) Album* parentAlbum;
@property (nonatomic, readwrite) NSString* mml;
@property (nonatomic, readwrite) NSInteger loop;
@property (nonatomic, readwrite) NSString* name;
@property (nonatomic, readwrite, nullable) NSString* english;
@end

@implementation Song

+ (NSMutableArray<Song*>*)parseJsonArray:(NSArray*)array
                                   album:(Album*)album
{
    NSMutableArray<Song*>* result = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary* data in array) {
        Song* song = [[Song alloc] init];
        song.parentAlbum = album;
        song.mml = data[@"mml"];
        song.loop = [data[@"loop"] integerValue];
        song.name = data[@"name"];
        song.english = data[@"english"] != [NSNull null] ? data[@"english"] : nil;
        [result addObject:song];
    }
    return result;
}

@end
