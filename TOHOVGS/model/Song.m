//
//  Song.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import "Song.h"

@interface Song()
@property (nonatomic, readwrite) Album* parentAlbum;
@property (nonatomic, readwrite) NSString* mml;
@property (nonatomic, readwrite) NSInteger loop;
@property (nonatomic, readwrite) NSString* name;
@property (nonatomic, readwrite, nullable) NSString* english;
@property (nonatomic, readwrite, nullable) NSString* french;
@end

@implementation Song

+ (NSArray<Song*>*)parseJsonArray:(NSArray*)array
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
        song.french = data[@"french"] != [NSNull null] ? data[@"french"] : nil;
        [result addObject:song];
    }
    return result;
}

@end
