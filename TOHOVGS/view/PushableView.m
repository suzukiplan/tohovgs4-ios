//
//  PushableView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/12.
//

#import "PushableView.h"

@interface PushableView ()
@property (nonatomic, readwrite) CGPoint position;
@property (nonatomic, readwrite) BOOL touching;
@property (nonatomic) UILongPressGestureRecognizer* longPress;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL isAnimating;
@end

@implementation PushableView

- (instancetype)initWithDelegate:(id<PushableViewDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
        _isEnabled = YES;
    }
    return self;
}

- (void)setLongPressDelegate:(id<LongPressDelegate>)longPressDelegate
{
    if (longPressDelegate) {
        _longPressDelegate = longPressDelegate;
        if (!_longPress) {
            _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(_detectLongPress:)];
            [self addGestureRecognizer:_longPress];
        }
    } else if (_longPress) {
        [self removeGestureRecognizer:_longPress];
        _longPress = nil;
    }
}

- (void)_detectLongPress:(UILongPressGestureRecognizer*)sender
{
    if (_longPressDelegate && sender.state == UIGestureRecognizerStateBegan) {
        [_longPressDelegate didLongPressOfPushableView:self];
    }
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    if (!_isEnabled) return;
    _touching = YES;
    __weak PushableView* weakSelf = self;
    if (_touchAlphaAnimation) {
        [UIView animateWithDuration:0.1
                         animations:^{
                             weakSelf.alpha = 0.5f;
                         }];
    } else {
        self.alpha = 1.0f;
    }
    for (UITouch* touch in touches) {
        _position = [touch locationInView:self];
        break;
    }
    if (_touchDetectDelegate) {
        [_touchDetectDelegate didStartTouchingOfPushableView:self];
    }
}

- (void)_endTouching
{
    _touching = NO;
    __weak PushableView* weakSelf = self;
    if (_touchAlphaAnimation) {
        [UIView animateWithDuration:0.1
                         animations:^{
                             weakSelf.alpha = 1.0f;
                         }];
    } else {
        self.alpha = 1.0f;
    }
}

- (void)touchesCancelled:(NSSet<UITouch*>*)touches
               withEvent:(UIEvent*)event
{
    if (!_touching) return;
    [self _endTouching];
    if (_touchDetectDelegate) {
        [_touchDetectDelegate didCancelTouchingOfPushableView:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    if (!_touching) return;
    for (UITouch* touch in touches) {
        CGPoint p = [touch locationInView:self];
        _position = p;
        if (_notCancelInOutside) break;
        if (p.x < 0 || p.y < 0 || self.frame.size.width < p.x ||
            self.frame.size.height < p.y) {
            [self _endTouching];
            if (_touchDetectDelegate) {
                [_touchDetectDelegate didCancelTouchingOfPushableView:self];
            }
            return;
        }
    }
    if (_touchDetectDelegate) {
        [_touchDetectDelegate didMoveTouchingOfPushableView:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    if (!_touching) return;
    [self _endTouching];
    if (event.type == UIControlEventTouchCancel) return;
    if (_isAnimating) return;
    _isAnimating = YES;
    __weak PushableView* weakSelf = self;
    if (_tapBoundAnimation) {
        [self _boundAnimationWithCallback:^() {
            [weakSelf.delegate didPushPushableView:weakSelf];
            weakSelf.isAnimating = NO;
            if (weakSelf.touchDetectDelegate) {
                [weakSelf.touchDetectDelegate didEndTouchingOfPushableView:self];
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate didPushPushableView:weakSelf];
            weakSelf.isAnimating = NO;
            if (weakSelf.touchDetectDelegate) {
                [weakSelf.touchDetectDelegate didEndTouchingOfPushableView:self];
            }
        });
    }
}

- (void)_boundAnimationWithCallback:(void (^)(void))callback
{
    [UIView animateWithDuration:0.06f
        delay:0.0f
        options:UIViewAnimationOptionCurveEaseIn
        animations:^{
            self.transform = CGAffineTransformMakeScale(0.3, 0.3);
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.12f
                delay:0.0f
                options:UIViewAnimationOptionCurveEaseIn
                animations:^{
                    self.transform = CGAffineTransformMakeScale(1.25, 1.25);
                }
                completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.08f
                        delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                        }
                        completion:^(BOOL finished) {
                            if (finished && callback) {
                                callback();
                            }
                        }];
                }];
        }];
}


- (void)setEnabled:(BOOL)enabled
{
    _isEnabled = enabled;
}

@end
