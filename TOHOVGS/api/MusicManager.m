//
//  MusicManager.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import "MusicManager.h"

@interface MusicManager()
@property (nonatomic, readwrite) NSArray<Album*>* albums;
@property (nonatomic, readwrite) NSMutableArray<Song*>* allUnlockedSongs;
@end

@implementation MusicManager

- (instancetype)init
{
    if (self = [super init]) {
        NSError* error = nil;
        NSString* path = [[NSBundle mainBundle] pathForResource:@"assets/songlist" ofType:@"json"];
        NSLog(@"songlist: %@", path);
        NSString* jsonString = [[NSString alloc] initWithContentsOfFile:path
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUnicodeStringEncoding];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        _albums = [Album parseJsonArray:json[@"albums"]];
        _allUnlockedSongs = [NSMutableArray array];
        for (Album* album in _albums) {
            NSLog(@"Exist album: %@", album.name);
            [_allUnlockedSongs addObjectsFromArray:album.songs]; // TODO: ロックされている曲を除外
        }
        
    }
    return self;
}

@end
