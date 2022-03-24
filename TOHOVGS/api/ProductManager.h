//
//  ProductManager.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/03/24.
//

#import <Foundation/Foundation.h>
#import "PurchaseDelegate.h"

#define PRODUCT_ID_REWARD @"remove_reward_ads"
#define PRODUCT_ID_BANNER @"remove_banner_ads"

NS_ASSUME_NONNULL_BEGIN

@class ProductManager;

@protocol ProductManagerDelegate <NSObject>
- (void)productManagerDidRequestRemoveBannerAds:(ProductManager*)manager;
@end

@interface ProductManager : NSObject
@property (nonatomic, readonly) BOOL initialized;
@property (nonatomic, weak) id<ProductManagerDelegate> delegate;
- (NSString*)priceWithProductId:(NSString*)productId;
- (void)purchaseWithProductId:(NSString*)productId
             purchaseDelegate:(id<PurchaseDelegate>)purchaseDelegate;
- (void)restoreWithPurchaseDelegate:(id<PurchaseDelegate>)purchaseDelegate;
- (BOOL)isPurchasedWithProductId:(NSString*)productId;
@end

NS_ASSUME_NONNULL_END
