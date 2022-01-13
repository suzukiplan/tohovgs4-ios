//
//  SliderView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import "SliderView.h"

#define BAR_HEIGHT 4
#define THUMB_SIZE 18

@interface SliderView() <PushableViewDelegate, TouchDetectDelegate>
@property (nonatomic, weak) id<SliderViewDelegate> sliderDelegate;
@property (nonatomic) UIView* thumb;
@property (nonatomic) UIView* left;
@property (nonatomic) UIView* right;
@end

@implementation SliderView

- (instancetype)initWithDelegate:(id<SliderViewDelegate>)delegate
{
    if (self = [super initWithDelegate:self]) {
        _sliderDelegate = delegate;
        self.tapBoundAnimation = NO;
        self.touchAlphaAnimation = NO;
        self.notCancelInOutside = YES;
        self.touchDetectDelegate = self;
        _left = [[UIView alloc] init];
        _left.layer.cornerRadius = BAR_HEIGHT / 2;
        _left.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1];
        [self addSubview:_left];
        _right = [[UIView alloc] init];
        _right.layer.cornerRadius = BAR_HEIGHT / 2;
        _right.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        [self addSubview:_right];
        _thumb = [[UIView alloc] init];
        _thumb.layer.cornerRadius = THUMB_SIZE / 2;
        _thumb.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:1];
        [self addSubview:_thumb];
        _max = 100;
        _progress = 0;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat tx = _progress;
    if (_max) tx /= _max;
    tx *= frame.size.width - THUMB_SIZE;
    _thumb.frame = CGRectMake(tx, (frame.size.height - THUMB_SIZE) / 2, THUMB_SIZE, THUMB_SIZE);
    CGFloat y = (frame.size.height - BAR_HEIGHT) / 2;
    CGFloat w = tx + THUMB_SIZE / 2;
    _left.frame = CGRectMake(0, y, w, BAR_HEIGHT);
    _right.frame = CGRectMake(w, y, frame.size.width - w, BAR_HEIGHT);
}

- (void)updateProgress
{
    _progress = _max * self.position.x / self.frame.size.width;
    if (_progress < 0) _progress = 0;
    else if (_max < _progress) _progress = _max;
    [self setFrame:self.frame];
}

- (void)didPushPushableView:(PushableView*)pushableView
{
}

- (void)didStartTouchingOfPushableView:(PushableView*)pushableView
{
    [self updateProgress];
    [self setFrame:self.frame];
}

- (void)didMoveTouchingOfPushableView:(PushableView*)pushableView
{
    [self updateProgress];
    [self setFrame:self.frame];
}

- (void)didEndTouchingOfPushableView:(PushableView*)pushableView
{
}

- (void)didCancelTouchingOfPushableView:(PushableView*)pushableView
{
}

@end
