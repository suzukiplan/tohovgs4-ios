/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "api/MusicManager.h"
#import "api/ProductManager.h"

@interface ViewController : UIViewController
@property (nonatomic, readonly) MusicManager* musicManager;
@property (nonatomic, readonly) ProductManager* productManager;
@end

