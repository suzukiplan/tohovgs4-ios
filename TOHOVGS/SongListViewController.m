/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "SongListViewController.h"
#import "view/PushableView.h"

@interface SongListViewController () <PushableViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UIView* container;
@property (nonatomic) UILabel* titleLabel;
@property (nonatomic) UITableView* table;
@property (nonatomic) PushableView* close;
@property (nonatomic) UILabel* closeLabel;
@end

@interface AddSongCell : UITableViewCell
@property (nonatomic) UILabel* albumName;
@property (nonatomic) UILabel* songName;
@end

@implementation AddSongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _albumName = [[UILabel alloc] init];
        _albumName.font = [UIFont systemFontOfSize:12];
        _albumName.textColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:0.9];
        _albumName.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_albumName];
        _songName = [[UILabel alloc] init];
        _songName.font = [UIFont systemFontOfSize:16];
        _songName.textColor = [UIColor whiteColor];
        _songName.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_songName];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat h = _albumName.intrinsicContentSize.height + _songName.intrinsicContentSize.height + 4;
    CGFloat y = (frame.size.height - h) / 2;
    _albumName.frame = CGRectMake(8, y, frame.size.width - 16, _albumName.intrinsicContentSize.height);
    y += _albumName.intrinsicContentSize.height + 4;
    _songName.frame = CGRectMake(8, y, frame.size.width - 16, _songName.intrinsicContentSize.height);
}

@end

@implementation SongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _container = [[UIView alloc] init];
    _container.clipsToBounds = YES;
    _container.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    _container.layer.borderColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:1].CGColor;
    _container.layer.borderWidth = 1;
    _container.layer.cornerRadius = 4.0;
    [self.view addSubview:_container];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = NSLocalizedString(@"added_songs", nil);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_titleLabel];
    _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _table.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    _table.allowsSelection = NO;
    _table.separatorColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    _table.separatorInset = UIEdgeInsetsZero;
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_container addSubview:_table];
    _close = [[PushableView alloc] initWithDelegate:self];
    [_container addSubview:_close];
    _closeLabel = [[UILabel alloc] init];
    _closeLabel.text = NSLocalizedString(@"close", nil);
    _closeLabel.font = [UIFont boldSystemFontOfSize:12];
    _closeLabel.textColor = [UIColor whiteColor];
    _closeLabel.textAlignment = NSTextAlignmentCenter;
    _closeLabel.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.5];
    _closeLabel.layer.borderColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.25].CGColor;
    _closeLabel.layer.borderWidth = 2;
    _closeLabel.layer.cornerRadius = 4;
    _closeLabel.clipsToBounds = YES;
    [_close addSubview:_closeLabel];
    [self _resize];
}

- (void)_resize
{
    CGFloat width = self.view.frame.size.width * 0.8;
    CGFloat height = self.view.frame.size.height * 0.6;
    CGFloat x = (self.view.frame.size.width - width) / 2;
    CGFloat y = (self.view.frame.size.height - height) / 2;
    _container.frame = CGRectMake(x, y, width, height);
    _titleLabel.frame = CGRectMake(8, 8, width - 16, 44);
    _table.frame = CGRectMake(8, 60, width - 16, height - 120);
    _close.frame = CGRectMake(8, height - 52, width - 16, 44);
    _closeLabel.frame = CGRectMake(0, 0, width - 16, 44);
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songs.count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    AddSongCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AddSongCell"];
    if (!cell) {
        cell = [[AddSongCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"AddSongCell"];
    }
    cell.albumName.text = _songs[indexPath.row].parentAlbum.name;
    cell.songName.text = _songs[indexPath.row].name;
    return cell;
}

@end
