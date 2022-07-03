/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import <UIKit/UIKit.h>
#import "model/Song.h"
#import "api/MusicManager.h"

NS_ASSUME_NONNULL_BEGIN

@class EditFavoriteViewController;

@protocol EditFavoriteViewControllerDelegate <NSObject>
- (void)didDissmissEditFavoriteViewController:(EditFavoriteViewController*)viewController;
@end

@interface EditFavoriteViewController : UIViewController
@property (nonatomic, weak) id<EditFavoriteViewControllerDelegate> delegate;
@property (nonatomic, weak) MusicManager* musicManager;
@property (nonatomic) NSArray<Song*>* songs;
@end

NS_ASSUME_NONNULL_END
