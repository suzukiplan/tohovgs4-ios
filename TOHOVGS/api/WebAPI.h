/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import <Foundation/Foundation.h>
#import "../model/SongList.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebAPI : NSObject
- (void)checkUpdateWithCurrentSHA1:(NSString*)sha1
                              done:(void(^)(NSError* _Nullable error, BOOL updatable))done;
- (void)acquireSongList:(void(^)(NSError* _Nullable error, SongList* _Nullable songList))done;
- (void)acquireMmlWithSong:(Song*)song
                      done:(void(^)(NSError* _Nullable error, NSString* _Nullable mml))done;
@end

NS_ASSUME_NONNULL_END
