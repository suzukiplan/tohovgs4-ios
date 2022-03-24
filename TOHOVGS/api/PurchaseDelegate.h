//
//  PurchaseDelegate.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/03/24.
//

#import <Foundation/Foundation.h>

@protocol PurchaseDelegate <NSObject>
- (void)purchaseDidSucceed;
- (void)purchaseDidFailedWithError:(NSError*)error;
- (void)purchaseDidRestored;
@end
