/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import "EditFavoriteViewController.h"
#import "view/PushableView.h"

@protocol EditFavoriteSongCellDelegate
- (void)editFavoriteSongCellDidChangeLikeWithSong:(Song*)song like:(BOOL)like;
@end

@interface EditFavoriteSongCell : UITableViewCell <PushableViewDelegate>
@property (nonatomic, weak) id<EditFavoriteSongCellDelegate> delegate;
@property (nonatomic, weak) Song* song;
@property (nonatomic) BOOL like;
@property (nonatomic) UILabel* songName;
@property (nonatomic) UILabel* englishName;
@property (nonatomic) PushableView* favorite;
@property (nonatomic) UIImageView* favoriteImage;
@end

@implementation EditFavoriteSongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _songName = [[UILabel alloc] init];
        _songName.font = [UIFont systemFontOfSize:12];
        _songName.textColor = [UIColor whiteColor];
        _songName.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_songName];
        if (![[NSLocale currentLocale].languageCode isEqualToString:@"ja"]) {
            _englishName = [[UILabel alloc] init];
            _englishName.font = [UIFont systemFontOfSize:10];
            _englishName.textColor = [UIColor colorWithWhite:0.5 alpha:1];
            _englishName.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_englishName];
        }
        _favorite = [[PushableView alloc] initWithDelegate:self];
        _favorite.tapBoundAnimation = YES;
        [self.contentView addSubview:_favorite];
        _favoriteImage = [[UIImageView alloc] init];
        [_favorite addSubview:_favoriteImage];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat h = _songName.intrinsicContentSize.height + _englishName.intrinsicContentSize.height;
    CGFloat y = (64 - h) / 2;
    _songName.frame = CGRectMake(8, y, frame.size.width - 68, _songName.intrinsicContentSize.height);
    y += _songName.intrinsicContentSize.height;
    _englishName.frame = CGRectMake(8, y, frame.size.width - 68, _englishName.intrinsicContentSize.height);
    _favorite.frame = CGRectMake(frame.size.width - 52, 10, 44, 44);
    _favoriteImage.frame = CGRectMake(18.5, 18.5, 7, 7);
}

- (void)setSong:(Song*)song withLike:(BOOL)like
{
    _song = song;
    _like = like;
    _songName.text = _song.name;
    _englishName.text = _song.english;
    _favoriteImage.image = [UIImage imageNamed:(_like ? @"ic_like_on" : @"ic_like_off")];
    [self setFrame:self.frame];
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    _like = !_like;
    [_delegate editFavoriteSongCellDidChangeLikeWithSong:_song like:_like];
    _favoriteImage.image = [UIImage imageNamed:(_like ? @"ic_like_on" : @"ic_like_off")];
}

@end

@interface EditFavoriteViewController () <PushableViewDelegate, UITableViewDelegate, UITableViewDataSource, EditFavoriteSongCellDelegate>
@property (nonatomic) UIView* container;
@property (nonatomic) UILabel* titleLabel;
@property (nonatomic) UITableView* table;
@property (nonatomic) PushableView* close;
@property (nonatomic) UILabel* closeLabel;
@property (nonatomic, nullable) NSMutableArray<Album*>* splitAlbums;
@property (nonatomic, nullable) NSMutableDictionary<NSString*, NSMutableArray<Song*>*>* splitSongs;
@end

@implementation EditFavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _splitAlbums = [NSMutableArray array];
    _splitSongs = [NSMutableDictionary dictionary];
    for (Song* song in _songs) {
        if (!_splitSongs[song.parentAlbum.albumId]) {
            [_splitAlbums addObject:song.parentAlbum];
            _splitSongs[song.parentAlbum.albumId] = [NSMutableArray array];
        }
        [_splitSongs[song.parentAlbum.albumId] addObject:song];
    }
    _container = [[UIView alloc] init];
    _container.clipsToBounds = YES;
    _container.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    _container.layer.borderColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:1].CGColor;
    _container.layer.borderWidth = 1;
    _container.layer.cornerRadius = 4.0;
    [self.view addSubview:_container];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = NSLocalizedString(@"edit_favorite_songs", nil);
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

- (void)viewDidDisappear:(BOOL)animated
{
    [self.delegate didDissmissEditFavoriteViewController:self];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _splitAlbums.count;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return _splitAlbums[section].name;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _splitSongs[_splitAlbums[section].albumId].count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    label.text = _splitAlbums[section].name;
    label.textColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:0.9];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, 0, _table.frame.size.width, 20);
    return label;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EditFavoriteSongCell* cell = [tableView dequeueReusableCellWithIdentifier:@"EditFavoriteSongCell"];
    if (!cell) {
        cell = [[EditFavoriteSongCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"EditFavoriteSongCell"];
    }
    Song* song = _splitSongs[_splitAlbums[indexPath.section].albumId][indexPath.row];
    [cell setSong:song withLike:[_musicManager isFavoriteSong:song]];
    cell.delegate = self;
    return cell;
}

- (void)editFavoriteSongCellDidChangeLikeWithSong:(Song*)song like:(BOOL)like
{
    [_musicManager favorite:like song:song];
}

@end
