/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "../ControlDelegate.h"
#import "../model/Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumPagerView : UIView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate;
- (void)refreshIsThereLockedSongWithAnimate:(BOOL)animate;
- (void)requireNextSong:(Song*)song
               infinity:(BOOL)infinity;
- (void)scrollToCurrentSong;
@end

NS_ASSUME_NONNULL_END
