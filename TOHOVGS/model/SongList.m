/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import "SongList.h"
#include <CommonCrypto/CommonDigest.h>

@interface SongList()
@property (nonatomic, readwrite) NSString* version;
@property (nonatomic, readwrite) NSArray<Album*>* albums;
@property (nonatomic, readwrite) NSString* jsonString;
@property (nonatomic, readwrite) NSInteger numberOfSongs;
@property (nonatomic, readwrite) BOOL songRemoved;
@end

@implementation SongList

+ (SongList*)fromFile:(NSString*)filePath
{
    NSLog(@"loading songlist.json from %@", filePath);
    NSError* error;
    NSString* jsonString = [[NSString alloc] initWithContentsOfFile:filePath
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
    if (error) {
        NSLog(@"cannot open %@: %@", filePath, error);
        return nil;
    }
    return [self fromJsonString:jsonString];
}

+ (SongList*)fromJsonString:(NSString*)jsonString
{
    NSError* error;
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    if (error) {
        NSLog(@"cannot parse json: %@", error);
        return nil;
    }
    SongList* result = [[SongList alloc] init];
    result.version = json[@"version"];
    result.jsonString = jsonString;
    result.albums = [Album parseJsonArray:json[@"albums"]];
    result.numberOfSongs = 0;
    for (Album* album in result.albums) {
        result.numberOfSongs += album.songs.count;
    }
    NSLog(@"read songlist.json: version=%@ songs=%ld", result.version, result.numberOfSongs);
    return result;
}

- (NSArray<Song*>*)enumAllSongs
{
    NSMutableArray<Song*>* result = [NSMutableArray arrayWithCapacity:_numberOfSongs];
    for (Album* album in _albums) {
        [result addObjectsFromArray:album.songs];
    }
    return result;
}

- (void)removeSong:(Song*)song
{
    for (Album* album in _albums) {
        if ([album.albumId isEqualToString:song.parentAlbum.albumId]) {
            [album.songs removeObject:song];
            _songRemoved = YES;
            return;
        }
    }
}

@end
