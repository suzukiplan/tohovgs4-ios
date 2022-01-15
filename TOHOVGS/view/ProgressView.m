/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "ProgressView.h"

@interface ProgressView()
@property (nonatomic) UIActivityIndicatorView* progress;
@property (nonatomic) UILabel* messageLabel;
@end

@implementation ProgressView

- (instancetype)initWithMessage:(NSString*)message
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
        _progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _progress.color = [UIColor whiteColor];
        [self addSubview:_progress];
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.text = message;
        _messageLabel.font = [UIFont boldSystemFontOfSize:12];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_messageLabel];
        [_progress startAnimating];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat y = (frame.size.height - (32 + 8 + _messageLabel.intrinsicContentSize.height)) / 2;
    _progress.frame = CGRectMake((frame.size.width - 32) / 2, y, 32, 32);
    [_progress sizeToFit];
    y += 32 + 8;
    _messageLabel.frame = CGRectMake(0, y, frame.size.width, _messageLabel.intrinsicContentSize.height);
}

@end
