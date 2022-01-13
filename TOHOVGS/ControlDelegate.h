//
//  ControlDelegate.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@class ViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol ControlDelegate <NSObject>
- (ViewController*)getViewController;
@end

NS_ASSUME_NONNULL_END
