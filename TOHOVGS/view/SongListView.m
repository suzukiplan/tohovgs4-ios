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
@property (nonatomic, weak) MusicManager* musicManager;
@property (nonatomic) UITableView* table;
@property (nonatomic, weak) NSArray<Song*>* songs;
@property (nonatomic, nullable) NSMutableArray<Album*>* splitAlbums;
@property (nonatomic, nullable) NSMutableDictionary<NSString*, NSMutableArray<Song*>*>* splitSongs;
@property (nonatomic) BOOL splitByAlbum;
@end

@implementation SongListView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                                  songs:(NSArray<Song*>*)songs
                           splitByAlbum:(BOOL)splitByAlbum;
{
    if (self = [super init]) {
        _songs = songs;
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
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _table.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
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
        NSLog(@"next: %@", _songs[next].name);
        [self _play:_songs[next]];
        NSIndexPath* nextIndex;
        if (_splitByAlbum) {
            NSInteger s = [_splitAlbums indexOfObject:_songs[next].parentAlbum];
            NSInteger r = [_splitSongs[_songs[next].parentAlbum.albumId] indexOfObject:_songs[next]];
            nextIndex = [NSIndexPath indexPathForRow:r inSection:s];
        } else {
            nextIndex = [NSIndexPath indexPathForRow:next inSection:0];
        }
        [_table scrollToRowAtIndexPath:nextIndex atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

@end
