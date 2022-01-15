//
//  RetroLayer.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/15.
//

#import <QuartzCore/QuartzCore.h>
#import "RetroView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RetroLayer : CALayer
@property (nonatomic, weak) RetroView* retroView;
- (void)drawFrame;
@end

NS_ASSUME_NONNULL_END
