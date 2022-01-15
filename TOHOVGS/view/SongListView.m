//
//  SongListView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import "SongListView.h"
#import "SongCell.h"
#import "../api/MusicManager.h"

@interface SongListView() <UITableViewDataSource, UITableViewDelegate, SongCellDelegate>
@property (nonatomic, weak) id<ControlDelegate> controlDelegate;
@property (nonatomic, weak) MusicManager* musicManager;
@property (nonatomic) UITableView* table;
@property (nonatomic) UILabel* noContentMessage;
@property (nonatomic, weak) NSArray<Song*>* songs;
@property (nonatomic, nullable) NSMutableArray<Song*>* shuffleSongs;
@property (nonatomic, nullable) NSMutableArray<Album*>* splitAlbums;
@property (nonatomic, nullable) NSMutableDictionary<NSString*, NSMutableArray<Song*>*>* splitSongs;
@property (nonatomic) BOOL splitByAlbum;
@end

@implementation SongListView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                                  songs:(NSArray<Song*>*)songs
                           splitByAlbum:(BOOL)splitByAlbum
                                shuffle:(BOOL)shuffle;
{
    if (self = [super init]) {
        _songs = shuffle ? nil : songs;
        _splitByAlbum = splitByAlbum;
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
    }
    return self;
}

- (void)shuffleWithControlDelegate:(id<ControlDelegate>)controlDelegate
{
    if (_songs.count < 1) return;
    [controlDelegate startProgressWithMessage:NSLocalizedString(@"generating_shuffle_play_list", nil)];
    __weak SongListView* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        NSMutableArray<Song*>* sequential = [weakSelf.songs mutableCopy];
        weakSelf.shuffleSongs = [NSMutableArray arrayWithCapacity:weakSelf.songs.count];
        srand((unsigned int)time(NULL));
        while (0 < sequential.count) {
            NSInteger index = abs(rand()) % sequential.count;
            [weakSelf.shuffleSongs addObject:sequential[index]];
            [sequential removeObjectAtIndex:index];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [controlDelegate stopProgress:^{
                weakSelf.songs = weakSelf.shuffleSongs;
                [weakSelf.table reloadData];
            }];
        });
    });
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _table.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _noContentMessage.frame = _table.frame;
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
    if (song.isPlaying) {
        song.isPlaying = NO;
        [_musicManager stopPlaying];
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
    __weak SongListView* weakSelf = self;
    [_controlDelegate askLockWithSong:song locked:^{
        [weakSelf.table reloadData];
    }];
}

- (BOOL)songCell:(SongCell*)songCell didRequestCheckLockedSong:(Song*)song
{
    return [_musicManager isLockedSong:song];
}

- (void)stopSong
{
    for (Song* song in _songs) {
        if (song.isPlaying) {
            song.isPlaying = NO;
            [_table reloadData];
            [_musicManager stopPlaying];
            break;
        }
    }
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
        while ([_musicManager isLockedSong:_songs[next]]) {
            next++;
            next %= _songs.count;
            if (giveUp == next) {
                NSLog(@"All unlocked");
                return;
            }
        }
        NSLog(@"next: %@", _songs[next].name);
        [self _play:_songs[next]];
        [self _scrollToSong:_songs[next]];
    }
}

- (void)_scrollToSong:(Song*)song
{
    NSIndexPath* indexPath;
    NSInteger songIndex = [_songs indexOfObject:song];
    if (_splitByAlbum) {
        NSInteger s = [_splitAlbums indexOfObject:_songs[songIndex].parentAlbum];
        NSInteger r = [_splitSongs[_songs[songIndex].parentAlbum.albumId] indexOfObject:_songs[songIndex]];
        indexPath = [NSIndexPath indexPathForRow:r inSection:s];
    } else {
        indexPath = [NSIndexPath indexPathForRow:songIndex inSection:0];
    }
    [_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];

}

@end
