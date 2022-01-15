/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "../model/Song.h"
#import "../ControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SongListView : UIView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                                  songs:(NSArray<Song*>*)songs
                           splitByAlbum:(BOOL)splitByAlbum
                                shuffle:(BOOL)shuffle;
- (void)stopSong;
- (void)requireNextSong:(Song*)song
               infinity:(BOOL)infinity;
- (void)shuffleWithControlDelegate:(id<ControlDelegate>)controlDelegate;
- (void)reload;
- (void)scrollToCurrentSong;
@end

NS_ASSUME_NONNULL_END
