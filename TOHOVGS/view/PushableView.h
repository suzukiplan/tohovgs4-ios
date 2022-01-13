//
//  PushableView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PushableView;

@protocol PushableViewDelegate <NSObject>
- (void)didPushPushableView:(PushableView*)pushableView;
@end

@protocol LongPressDelegate <NSObject>
- (void)didLongPressOfPushableView:(PushableView*)pushableView;
@end

@protocol TouchDetectDelegate <NSObject>
- (void)didStartTouchingOfPushableView:(PushableView*)pushableView;
- (void)didMoveTouchingOfPushableView:(PushableView*)pushableView;
- (void)didEndTouchingOfPushableView:(PushableView*)pushableView;
- (void)didCancelTouchingOfPushableView:(PushableView*)pushableView;
@end

@interface PushableView : UIView
@property (nonatomic, weak) id<PushableViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<LongPressDelegate> longPressDelegate;
@property (nonatomic, weak, nullable) id<TouchDetectDelegate> touchDetectDelegate;
@property (nonatomic) BOOL touchAlphaAnimation;
@property (nonatomic) BOOL tapBoundAnimation;
@property (nonatomic) BOOL notCancelInOutside;
@property (nonatomic) BOOL enabled;
@property (nonatomic, readonly) BOOL touching;
@property (nonatomic, readonly) CGPoint position;
- (instancetype)initWithDelegate:(id<PushableViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
