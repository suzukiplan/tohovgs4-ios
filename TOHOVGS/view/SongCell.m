/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "SongCell.h"
#import "PushableView.h"

@interface SongCell() <PushableViewDelegate, LongPressDelegate>
@property (nonatomic, weak) Song* song;
@property (nonatomic) PushableView* pushable;
@property (nonatomic) UILabel* titleLabel;
@property (nonatomic, nullable) UILabel* englishLabel;
@property (nonatomic) PushableView* lockedCover;
@property (nonatomic) UIImageView* lockedImage;
@end

@implementation SongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _pushable = [[PushableView alloc] initWithDelegate:self];
        _pushable.tapBoundAnimation = NO;
        _pushable.touchAlphaAnimation = YES;
        _pushable.longPressDelegate = self;
        [self.contentView addSubview:_pushable];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_pushable addSubview:_titleLabel];
        if (![[NSLocale currentLocale].languageCode isEqualToString:@"ja"]) {
            _englishLabel = [[UILabel alloc] init];
            _englishLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75];
            _englishLabel.textAlignment = NSTextAlignmentCenter;
            _englishLabel.font = [UIFont systemFontOfSize:11];
            [_pushable addSubview:_englishLabel];
        }
        _lockedCover = [[PushableView alloc] initWithDelegate:self];
        _lockedCover.tapBoundAnimation = NO;
        _lockedCover.touchAlphaAnimation = YES;
        _lockedCover.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [self.contentView addSubview:_lockedCover];
        _lockedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_lock_white_18pt"]];
        _lockedImage.alpha = 0.5;
        [_lockedCover addSubview:_lockedImage];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _pushable.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if (_englishLabel.text) {
        CGFloat y = (frame.size.height - (_titleLabel.intrinsicContentSize.height + _englishLabel.intrinsicContentSize.height)) / 2;
        _titleLabel.frame = CGRectMake(8, y, frame.size.width - 16, _titleLabel.intrinsicContentSize.height);
        y += _titleLabel.intrinsicContentSize.height;
        _englishLabel.frame = CGRectMake(8, y, frame.size.width - 16, _englishLabel.intrinsicContentSize.height);
    } else {
        _titleLabel.frame = CGRectMake(8, 0, frame.size.width - 16, frame.size.height);
    }
    if ([_delegate songCell:self didRequestCheckLockedSong:_song]) {
        _titleLabel.font = [UIFont systemFontOfSize:14.5];
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _lockedCover.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _lockedImage.frame = CGRectMake((frame.size.width - 18) / 2, (frame.size.height - 18) / 2, 18, 18);
        _lockedCover.hidden = NO;
        _lockedImage.hidden = NO;
    } else {
        _lockedCover.hidden = YES;
        _lockedImage.hidden = YES;
        if (_song.isPlaying) {
            _titleLabel.font = [UIFont boldSystemFontOfSize:14.5];
            self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        } else {
            _titleLabel.font = [UIFont systemFontOfSize:14.5];
            self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        }
    }
}

- (void)bindWithSong:(Song*)song
{
    _song = song;
    _titleLabel.text = song.name;
    _englishLabel.text = song.english;
    [self setFrame:self.frame];
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    if (pushableView == _pushable) {
        [_delegate songCell:self didTapSong:_song];
    } else if (pushableView == _lockedCover) {
        [_delegate songCell:self didRequestUnlockSong:_song];
    }
}

- (void)didLongPressOfPushableView:(PushableView*)pushableView
{
    if (pushableView == _pushable) {
        [_delegate songCell:self didLongPressSong:_song];
    }
}

@end
