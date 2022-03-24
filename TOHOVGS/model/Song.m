/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "Song.h"

@interface Song()
@property (nonatomic, readwrite) Album* parentAlbum;
@property (nonatomic, readwrite, nullable) NSString* appleId;
@property (nonatomic, readwrite) NSString* mml;
@property (nonatomic, readwrite) NSInteger ver;
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
        song.appleId = data[@"appleId"] != [NSNull null] ? data[@"appleId"] : nil;
        song.mml = data[@"mml"];
        song.ver = data[@"ver"] != [NSNull null] ? [data[@"ver"] integerValue] : 0;
        song.loop = [data[@"loop"] integerValue];
        song.name = data[@"name"];
        song.english = data[@"english"] != [NSNull null] ? data[@"english"] : nil;
        song.primaryUseType = SongPrimaryUseTypePreset;
        [result addObject:song];
    }
    return result;
}

- (NSString*)appleMusicURL
{
    if (_parentAlbum.appleId) {
        if (_appleId) {
            return [NSString stringWithFormat:@"https://music.apple.com/jp/album/%@?i=%@", _parentAlbum.appleId, _appleId];
        }
    }
    return nil;
}

@end
