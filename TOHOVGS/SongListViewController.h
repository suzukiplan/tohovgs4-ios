/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "model/Song.h"

NS_ASSUME_NONNULL_BEGIN

@class SongListViewController;

@protocol SongListViewControllerDelegate <NSObject>
- (void)didDissmissSongListViewController:(SongListViewController*)viewController;
@end

@interface SongListViewController : UIViewController
@property (nonatomic, weak) id<SongListViewControllerDelegate> delegate;
@property (nonatomic) NSArray<Song*>* songs;
@end

NS_ASSUME_NONNULL_END
