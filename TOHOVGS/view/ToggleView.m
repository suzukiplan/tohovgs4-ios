//
//  ToggleView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/12.
//

#import "ToggleView.h"
#import "PushableView.h"

#define BAR_HEIGHT 8
#define CIRCLE_SIZE 18

@interface ToggleView() <PushableViewDelegate>
@property (nonatomic, weak) id<ToggleViewDelegate> toggleDelegate;
@property (nonatomic) BOOL status;
@property (nonatomic) UIView* bar;
@property (nonatomic) UIView* circle;
@end

@implementation ToggleView

- (instancetype)initWithDelegate:(id<ToggleViewDelegate>)delegate status:(BOOL)status
{
    if (self = [super initWithDelegate:self]) {
        self.tapBoundAnimation = NO;
        _toggleDelegate = delegate;
        _status = status;
        _bar = [[UIView alloc] init];
        _bar.layer.cornerRadius = BAR_HEIGHT / 2;
        [self addSubview:_bar];
        _circle = [[UIView alloc] init];
        _circle.layer.cornerRadius = CIRCLE_SIZE / 2;
        [self addSubview:_circle];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    const CGFloat margin = 4;
    _bar.frame = CGRectMake(CIRCLE_SIZE / 2,
                            (frame.size.height - BAR_HEIGHT) / 2,
                            frame.size.width - CIRCLE_SIZE,
                            BAR_HEIGHT);
    _circle.frame = CGRectMake(_status ? frame.size.width - CIRCLE_SIZE - margin : margin,
                               (frame.size.height - CIRCLE_SIZE) / 2,
                               CIRCLE_SIZE,
                               CIRCLE_SIZE);
    if (_status) {
        _bar.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1];
        _circle.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:1];
    } else {
        _bar.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        _circle.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1];
    }
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    _status = !_status;
    [_toggleDelegate toggleView:self didChangeStatus:_status];
    __weak ToggleView* weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf setFrame:weakSelf.frame];
    }];
}

@end
