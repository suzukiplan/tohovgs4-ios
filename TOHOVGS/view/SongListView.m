/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "SongListView.h"
#import "SongCell.h"
#import "PushableView.h"
#import "../api/MusicManager.h"
#import "../AdSettings.h"
#import "../vgs/vgsplay-ios.h"
#import "../EditFavoriteViewController.h"
@import GoogleMobileAds;

@interface SongListView() <UITableViewDataSource, UITableViewDelegate, SongCellDelegate, PushableViewDelegate, EditFavoriteViewControllerDelegate>
@property (nonatomic, weak) id<ControlDelegate> controlDelegate;
@property (nonatomic, weak) MusicManager* musicManager;
@property (nonatomic) UITableView* table;
@property (nonatomic) UILabel* noContentMessage;
@property (nonatomic, weak) NSArray<Song*>* songs;
@property (nonatomic, nullable) NSMutableArray<Song*>* shuffleSongs;
@property (nonatomic, nullable) NSMutableArray<Album*>* splitAlbums;
@property (nonatomic, nullable) NSMutableDictionary<NSString*, NSMutableArray<Song*>*>* splitSongs;
@property (nonatomic) BOOL splitByAlbum;
@property (nonatomic) BOOL favoriteOnly;
@property (nonatomic, nullable) PushableView* sortByDefault;
@property (nonatomic, nullable) UILabel* sortByDefaultLabel;
@property (nonatomic, nullable) PushableView* shuffle;
@property (nonatomic, nullable) UILabel* shuffleLabel;
@property (nonatomic, nullable) PushableView* addFavorite;
@property (nonatomic, nullable) UILabel* addFavoriteLabel;
@end

@implementation SongListView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                                  songs:(NSArray<Song*>*)songs
                           splitByAlbum:(BOOL)splitByAlbum
                                shuffle:(BOOL)shuffle
                           favoriteOnly:(BOOL)favoriteOnly
{
    if (self = [super init]) {
        _favoriteOnly = favoriteOnly;
        _splitByAlbum = splitByAlbum;
        if (!shuffle) {
            if (!favoriteOnly) {
                _songs = songs;
            } else {
                _songs = [controlDelegate getViewController].musicManager.favoriteSongs;
            }
        }
        if (splitByAlbum) {
            _splitAlbums = [NSMutableArray array];
            _splitSongs = [NSMutableDictionary dictionary];
            for (Song* song in songs) {
                if (!_splitSongs[song.parentAlbum.albumId]) {
                    [_splitAlbums addObject:song.parentAlbum];
                    _splitSongs[song.parentAlbum.albumId] = [NSMutableArray array];
                }
                [_splitSongs[song.parentAlbum.albumId] addObject:song];
            }
        }
        _controlDelegate = controlDelegate;
        _musicManager = [controlDelegate getViewController].musicManager;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _table = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
        _table.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _table.allowsSelection = NO;
        _table.separatorColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        _table.separatorInset = UIEdgeInsetsZero;
        if (@available(iOS 15.0, *)) {
            _table.sectionHeaderTopPadding = _splitByAlbum ? 16.0 : 0.0;
        }
        [_table setDataSource:self];
        [_table setDelegate:self];
        [self addSubview:_table];
        if (songs.count < 1) {
            _noContentMessage = [[UILabel alloc] init];
            _noContentMessage.text = NSLocalizedString(@"all_songs_are_locked", nil);
            _noContentMessage.textColor = [UIColor whiteColor];
            _noContentMessage.font = [UIFont systemFontOfSize:12];
            _noContentMessage.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_noContentMessage];
        }
        if (shuffle) {
            _songs = songs;
            [self shuffleWithControlDelegate:controlDelegate];
        }
        if (favoriteOnly) {
            _sortByDefault = [[PushableView alloc] initWithDelegate:self];
            _sortByDefault.tapBoundAnimation = NO;
            _sortByDefault.touchAlphaAnimation = YES;
            _sortByDefaultLabel = [self _makeButton:NSLocalizedString(@"sort_by_default", nil)];
            [_sortByDefault addSubview:_sortByDefaultLabel];
            [self addSubview:_sortByDefault];
            _shuffle = [[PushableView alloc] initWithDelegate:self];
            _shuffle.tapBoundAnimation = NO;
            _shuffle.touchAlphaAnimation = YES;
            _shuffleLabel = [self _makeButton:NSLocalizedString(@"shuffle_favorites", nil)];
            [_shuffle addSubview:_shuffleLabel];
            [self addSubview:_shuffle];
            _addFavorite = [[PushableView alloc] initWithDelegate:self];
            _addFavorite.tapBoundAnimation = YES;
            _addFavorite.touchAlphaAnimation = NO;
            _addFavoriteLabel = [self _makeButton:@"+"];
            [_addFavorite addSubview:_addFavoriteLabel];
            [self addSubview:_addFavorite];
        }
    }
    return self;
}

- (void)shuffleWithControlDelegate:(id<ControlDelegate>)controlDelegate
{
    if (_songs.count < 1) return;
    if ([controlDelegate isPurchasedWithProductId:PRODUCT_ID_BANNER]) {
        [self _doShuffleWithControlDelegate:controlDelegate];
        return;
    }
    GADRequest *request = [GADRequest request];
    [GADInterstitialAd loadWithAdUnitID:ADS_ID_INTERSTITIAL
                                request:request
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Succeed to load interstitial ad");
            [ad presentFromRootViewController:[controlDelegate getViewController]];
        }
    }];
    [controlDelegate startProgressWithMessage:NSLocalizedString(@"generating_shuffle_play_list", nil)];
    __weak SongListView* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        [weakSelf _doShuffleWithControlDelegate:controlDelegate];
    });
}

- (void)_doShuffleWithControlDelegate:(id<ControlDelegate>)controlDelegate
{
    NSMutableArray<Song*>* sequential = [_songs mutableCopy];
    _shuffleSongs = [NSMutableArray arrayWithCapacity:_songs.count];
    srand((unsigned int)time(NULL));
    while (0 < sequential.count) {
        NSInteger index = abs(rand()) % sequential.count;
        [_shuffleSongs addObject:sequential[index]];
        [sequential removeObjectAtIndex:index];
    }
    __weak SongListView* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.songs = weakSelf.shuffleSongs;
        [weakSelf.table reloadData];
        [controlDelegate stopProgress];
    });
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _table.frame = CGRectMake(0, 0, frame.size.width, frame.size.height - (_favoriteOnly ? 52 : 0));
    _noContentMessage.frame = _table.frame;
    if (_favoriteOnly) {
        CGFloat x = 4;
        CGFloat y = frame.size.height - 48;
        CGFloat w = (frame.size.width - 56) / 2;
        _sortByDefault.frame = CGRectMake(x, y, w, 44);
        _sortByDefaultLabel.frame = CGRectMake(0, 0, w, 44);
        x += w + 4;
        _shuffle.frame = CGRectMake(x, y, w, 44);
        _shuffleLabel.frame = CGRectMake(0, 0, w, 44);
        x += w + 4;
        _addFavorite.frame = CGRectMake(x, y, 44, 44);
        _addFavoriteLabel.frame = CGRectMake(0, 0, 44, 44);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_splitByAlbum) {
        return _splitAlbums.count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_splitByAlbum) {
        return _splitSongs[_splitAlbums[section].albumId].count;
    } else {
        return _songs.count;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SongCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell"];
    if (!cell) {
        cell = [[SongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SongCell"];
    }
    cell.delegate = self;
    if (_splitByAlbum) {
        [cell bindWithSong:_splitSongs[_splitAlbums[indexPath.section].albumId][indexPath.row]];
    } else {
        [cell bindWithSong:_songs[indexPath.row]];
    }
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_splitByAlbum) {
        UILabel* label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        label.text = _splitByAlbum ? _splitAlbums[section].formalName : _songs[0].parentAlbum.formalName;
        label.textColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:0.9];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake(0, 0, _table.frame.size.width, 20);
        return label;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return _splitByAlbum ? 28.0f : CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
}

- (void)songCell:(SongCell*)songCell didTapSong:(Song*)song
{
    if (![_musicManager isPlayingSong:song]) {
        [self _play:song];
    } else if (vgsplay_isPlaying()) {
        [_musicManager stopPlayingWithKeep:YES];
        [_table reloadData];
    } else {
        [self _play:song];
    }
    [self _scrollToSong:song];
}

- (void)_play:(Song*)song
{
    song.isPlaying = YES;
    for (Song* s in _songs) {
        if (s.isPlaying && s != song) {
            s.isPlaying = NO;
        }
    }
    [_musicManager playSong:song];
    [_table reloadData];
}

- (void)songCell:(SongCell*)songCell didLongPressSong:(Song*)song
{
    if ([_musicManager isPlayingSong:song] || [_musicManager isKeepingSong:song]) {
        [self stopSong];
        [_musicManager purgeKeepInfo];
        [_table reloadData];
        [_controlDelegate resetSeekBar];
        return;
    }
    [self stopSong];
    [_musicManager purgeKeepInfo];
    __weak SongListView* weakSelf = self;
    [_controlDelegate askLockWithSong:song locked:^{
        [weakSelf.table reloadData];
    }];
}

- (BOOL)songCell:(SongCell*)songCell didRequestCheckLockedSong:(Song*)song
{
    return [_musicManager isLockedSong:song];
}

- (void)songCell:(SongCell*)songCell didRequestUnlockSong:(Song*)song
{
    [self stopSong];
    __weak SongListView* weakSelf = self;
    [_controlDelegate askUnlockAllWithCallback:^{
        [weakSelf.table reloadData];
    }];
}


- (BOOL)songCell:(SongCell*)songCell didRequestCheckFavoriteSong:(Song*)song
{
    return [_musicManager isFavoriteSong:song];
}

- (void)songCell:(SongCell *)songCell didRequestChangeFavorite:(BOOL)favorite forSong:(Song*)song
{
    [_musicManager favorite:favorite song:song];
    if (_favoriteOnly) {
        [self reload];
        [_musicManager purgeKeepInfo];
    }
}

- (void)stopSong
{
    for (Song* song in _songs) {
        song.isPlaying = NO;
    }
    [_table reloadData];
    [_musicManager stopPlaying];
}

- (void)requireNextSong:(Song*)song
               infinity:(BOOL)infinity
{
    NSInteger current = [_songs indexOfObject:song];
    if (current == NSNotFound) {
        NSLog(@"NSNotFound!");
    } else {
        NSInteger next = infinity ? current : (current + 1) % _songs.count;
        NSInteger giveUp = next;
        if (_favoriteOnly) {
            while ([_musicManager isLockedSong:_songs[next]] && ![_musicManager isFavoriteSong:_songs[next]]) {
                next++;
                next %= _songs.count;
                if (giveUp == next) {
                    NSLog(@"All unlocked or Favroite not exist");
                    return;
                }
            }
        } else {
            while ([_musicManager isLockedSong:_songs[next]]) {
                next++;
                next %= _songs.count;
                if (giveUp == next) {
                    NSLog(@"All unlocked");
                    return;
                }
            }
        }
        NSLog(@"next: %@", _songs[next].name);
        [self _play:_songs[next]];
        [self _scrollToSong:_songs[next]];
    }
}

- (void)_scrollToSong:(Song*)song
{
    __weak SongListView* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath* indexPath;
        NSInteger songIndex = [weakSelf.songs indexOfObject:song];
        if (songIndex == NSNotFound) return;
        if (weakSelf.splitByAlbum) {
            NSInteger s = [weakSelf.splitAlbums indexOfObject:weakSelf.songs[songIndex].parentAlbum];
            NSInteger r = [weakSelf.splitSongs[weakSelf.songs[songIndex].parentAlbum.albumId] indexOfObject:weakSelf.songs[songIndex]];
            indexPath = [NSIndexPath indexPathForRow:r inSection:s];
        } else {
            indexPath = [NSIndexPath indexPathForRow:songIndex inSection:0];
        }
        [weakSelf.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    });
}

- (void)reload
{
    [_table reloadData];
}

- (void)scrollToCurrentSong
{
    Song* target = _musicManager.playingSong;
    if (target) {
        [self _scrollToSong:target];
    }
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    if (pushableView == _sortByDefault) {
        [_musicManager sortFavorites];
        _songs = _musicManager.favoriteSongs;
        [self reload];
    } else if (pushableView == _shuffle) {
        [_musicManager shuffleFavorites];
        _songs = _musicManager.favoriteSongs;
        [self reload];
    } else if (pushableView == _addFavorite) {
        EditFavoriteViewController* vc = [[EditFavoriteViewController alloc] init];
        vc.songs = _musicManager.allUnlockedSongs;
        vc.musicManager = _musicManager;
        vc.modalPresentationStyle = UIModalPresentationPopover;
        vc.delegate = self;
        [[_controlDelegate getViewController] presentViewController:vc animated:YES completion:^{
            ;
        }];
    }
}

- (void)didDissmissEditFavoriteViewController:(EditFavoriteViewController *)viewController
{
    _songs = _musicManager.favoriteSongs;
    [_table reloadData];
}

- (UILabel*)_makeButton:(NSString*)text
{
    UILabel* label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.5];
    label.layer.borderColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.25].CGColor;
    label.layer.borderWidth = 2;
    label.layer.cornerRadius = 4.0;
    label.clipsToBounds = YES;
    return label;
}

@end
