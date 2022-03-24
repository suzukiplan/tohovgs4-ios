//
//  ProductManager.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/03/24.
//

#import "ProductManager.h"
@import StoreKit;

@interface ProductManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, readwrite) BOOL initialized;
@property (nonatomic, weak, nullable) id<PurchaseDelegate> purchaseDelegate;
@property (nonatomic) SKProductsRequest* request;
@property (nonatomic) SKReceiptRefreshRequest* refreshRequest;
@property (nonatomic) NSArray<SKProduct*>* products;
@end

@implementation ProductManager

- (instancetype)init
{
    if (self = [super init]) {
        NSSet<NSString*>* ids = [NSSet setWithArray:@[PRODUCT_ID_REWARD, PRODUCT_ID_BANNER]];
        _request = [[SKProductsRequest alloc] initWithProductIdentifiers:ids];
        _request.delegate = self;
        [_request start];
    }
    return self;
}

- (void)productsRequest:(SKProductsRequest*)request
     didReceiveResponse:(SKProductsResponse*)response
{
    _products = response.products;
    for (SKProduct* product in _products) {
        NSLog(@"%@ %@ %@ %@", product.productIdentifier, product.localizedTitle,  product.localizedDescription, [self localizedPriceWithProduct:product]);
    }
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    NSLog(@"ProductManager initialized");
    _initialized = YES;
}

- (void)requestDidFinish:(SKRequest*)request
{
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]) {
        NSLog(@"Refresh finished");
        [_purchaseDelegate purchaseDidRestored];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        return;
    }
}

- (void)request:(SKRequest*)request didFailWithError:(NSError*)error
{
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]) {
        NSLog(@"Refresh failed: %@", error);
        [_purchaseDelegate purchaseDidRestored];
        return;
    }
}

- (NSString*)localizedPriceWithProduct:(SKProduct*)product
{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = product.priceLocale;
    return [formatter stringFromNumber:product.price];
}

- (NSString*)priceWithProductId:(NSString*)productId
{
    for (SKProduct* product in _products) {
        if ([product.productIdentifier isEqualToString:productId]) {
            return [self localizedPriceWithProduct:product];
        }
    }
    return @"not initialized";
}

- (void)purchaseWithProductId:(NSString*)productId
             purchaseDelegate:(nonnull id<PurchaseDelegate>)purchaseDelegate
{
    _purchaseDelegate = purchaseDelegate;
    for (SKProduct* product in _products) {
        if ([product.productIdentifier isEqualToString:productId]) {
            SKPayment* payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            break;
        }
    }
}

- (void)restoreWithPurchaseDelegate:(id<PurchaseDelegate>)purchaseDelegate
{
    _purchaseDelegate = purchaseDelegate;
    _refreshRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
    _refreshRequest.delegate = self;
    [_refreshRequest start];
}

- (void)paymentQueue:(SKPaymentQueue*)queue
 updatedTransactions:(NSArray<SKPaymentTransaction*>*)transactions
{
    for (SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing... %@", transaction.payment.productIdentifier);
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"Defferred purchasing: %@", transaction.transactionIdentifier);
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Purchased: %@", transaction.payment.productIdentifier);
                [queue finishTransaction:transaction];
                [self _setPurchased:YES forKey:transaction.payment.productIdentifier];
                [_purchaseDelegate purchaseDidSucceed];
                _purchaseDelegate = nil;
                if ([transaction.payment.productIdentifier isEqualToString:PRODUCT_ID_BANNER]) {
                    __weak ProductManager* weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.delegate productManagerDidRequestRemoveBannerAds:weakSelf];
                    });
                }
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Failed purchasing: %@, error=%@", transaction.payment.productIdentifier, transaction.error);
                [queue finishTransaction:transaction];
                [_purchaseDelegate purchaseDidFailedWithError:transaction.error];
                _purchaseDelegate = nil;
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Restored purchasing: %@", transaction.payment.productIdentifier);
                [queue finishTransaction:transaction];
                [self _setPurchased:YES forKey:transaction.payment.productIdentifier];
                [_purchaseDelegate purchaseDidRestored];
                if ([transaction.payment.productIdentifier isEqualToString:PRODUCT_ID_BANNER]) {
                    __weak ProductManager* weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.delegate productManagerDidRequestRemoveBannerAds:weakSelf];
                    });
                }
                break;
        }
    }
}

- (void)_setPurchased:(BOOL)purchased forKey:(NSString*)productId
{
    [[NSUserDefaults standardUserDefaults] setBool:purchased forKey:productId];
}

- (BOOL)isPurchasedWithProductId:(NSString*)productId
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:productId];
}

@end
