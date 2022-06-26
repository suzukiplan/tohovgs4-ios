/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "SongCell.h"
#import "PushableView.h"
#import "../vgs/vgsplay-ios.h"

@interface SongCell() <PushableViewDelegate, LongPressDelegate>
@property (nonatomic, weak) Song* song;
@property (nonatomic) PushableView* pushable;
@property (nonatomic) UILabel* titleLabel;
@property (nonatomic, nullable) UILabel* englishLabel;
@property (nonatomic) UIImageView* pauseLabel;
@property (nonatomic) PushableView* lockedCover;
@property (nonatomic) UIImageView* lockedImage;
@property (nonatomic) PushableView* favorite;
@property (nonatomic) UIImageView* favoriteImage;
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
        _pauseLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"label_pause"]];
        [_pushable addSubview:_pauseLabel];
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
        _favorite = [[PushableView alloc] initWithDelegate:self];
        _favorite.tapBoundAnimation = YES;
        _favorite.touchAlphaAnimation = NO;
        [self.contentView addSubview:_favorite];
        _favoriteImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_like_off"]];
        _favoriteImage.frame = CGRectMake(18.5, 18.5, 7, 7);
        [_favorite addSubview:_favoriteImage];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    BOOL isLocking = [_delegate songCell:self didRequestCheckLockedSong:_song];
    BOOL isPlaying = _song.isPlaying;
    const CGFloat width = frame.size.width;
    const CGFloat height = frame.size.height;
    _pushable.frame = CGRectMake(0, 0, width, height);
    if (_englishLabel.text) {
        CGFloat y = (height - (_titleLabel.intrinsicContentSize.height + _englishLabel.intrinsicContentSize.height)) / 2;
        _titleLabel.frame = CGRectMake(8, y, width - 16, _titleLabel.intrinsicContentSize.height);
        y += _titleLabel.intrinsicContentSize.height;
        _englishLabel.frame = CGRectMake(8, y, width - 16, _englishLabel.intrinsicContentSize.height);
    } else {
        _titleLabel.frame = CGRectMake(8, 0, width - 16, height);
    }
    _pauseLabel.frame = CGRectMake(4, 4, 28, 8);
    if (isLocking) {
        _titleLabel.font = [UIFont systemFontOfSize:14.5];
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _lockedCover.frame = CGRectMake(0, 0, width, height);
        _lockedImage.frame = CGRectMake((width - 18) / 2, (height - 18) / 2, 18, 18);
        _lockedCover.hidden = NO;
        _lockedImage.hidden = NO;
        _pauseLabel.hidden = YES;
        _favorite.hidden = YES;
    } else {
        _lockedCover.hidden = YES;
        _lockedImage.hidden = YES;
        if (isPlaying) {
            _titleLabel.font = [UIFont boldSystemFontOfSize:14.5];
            _pauseLabel.hidden = vgsplay_isPlaying() ? YES : NO;
            if ([_delegate songCell:self didRequestCheckFavoriteSong:_song]) {
                _favoriteImage.image = [UIImage imageNamed:@"ic_like_on"];
            } else {
                _favoriteImage.image = [UIImage imageNamed:@"ic_like_off"];
            }
            _favorite.hidden = NO;
            _favorite.frame = CGRectMake(width - 44, (height - 44) / 2, 44, height);
            self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        } else {
            _titleLabel.font = [UIFont systemFontOfSize:14.5];
            _pauseLabel.hidden = YES;
            _favorite.hidden = YES;
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
    } else if (pushableView == _favorite) {
        BOOL favorite = ![_delegate songCell:self didRequestCheckFavoriteSong:_song];
        [_delegate songCell:self didRequestChangeFavorite:favorite forSong:_song];
        [self setFrame:self.frame];
    }
}

- (void)didLongPressOfPushableView:(PushableView*)pushableView
{
    if (pushableView == _pushable) {
        [_delegate songCell:self didLongPressSong:_song];
    }
}

@end
