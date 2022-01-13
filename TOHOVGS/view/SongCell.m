//
//  SongCell.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import "SongCell.h"
#import "PushableView.h"

@interface SongCell() <PushableViewDelegate, LongPressDelegate>
@property (nonatomic, weak) Song* song;
@property (nonatomic) PushableView* pushable;
@property (nonatomic) UILabel* titleLabel;
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
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _pushable.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _titleLabel.frame = CGRectMake(8, 0, frame.size.width - 16, frame.size.height);
    if (_song.isPlaying) {
        _titleLabel.font = [UIFont boldSystemFontOfSize:14.5];
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    } else {
        _titleLabel.font = [UIFont systemFontOfSize:14.5];
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    }
}

- (void)bindWithSong:(Song*)song
{
    _song = song;
    _titleLabel.text = song.name;
    [self setFrame:self.frame];
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    [_delegate songCell:self didTapSong:_song];
}

- (void)didLongPressOfPushableView:(PushableView*)pushableView
{
    [_delegate songCell:self didLongPressSong:_song];
}

@end
