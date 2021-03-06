/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "model/Song.h"
#import "api/PurchaseDelegate.h"

@class ViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol ControlDelegate <NSObject>
- (ViewController*)getViewController;
- (void)startProgressWithMessage:(NSString*)message;
- (void)stopProgress;
- (void)showErrorMessage:(NSString*)message;
- (void)showInfoMessage:(NSString*)message;
- (void)showUpdateSongs:(NSArray<Song*>*)songs;
- (void)askLockWithSong:(Song*)song locked:(void(^)(void))locked;
- (void)askUnlockAllWithCallback:(void(^)(void))unlocked;
- (void)resetSeekBar;
- (NSString*)priceWithProductId:(NSString*)productId;
- (BOOL)isPurchasedWithProductId:(NSString*)productId;
- (void)purchaseWithProductId:(NSString*)productId purchaseDelegate:(id<PurchaseDelegate>)purchaseDelegate;
- (void)restorePurchaseWithPurchaseDelegate:(id<PurchaseDelegate>)purchaseDelegate;
- (void)presentViewController:(UIViewController*)viewController;
@end

NS_ASSUME_NONNULL_END
