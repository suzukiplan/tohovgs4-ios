//
//  SongListView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import "SongListView.h"
#import "SongCell.h"

@interface SongListView() <UITableViewDataSource, UITableViewDelegate, SongCellDelegate>
@property (nonatomic, weak) id<ControlDelegate> controlDelegate;
@property (nonatomic) UITableView* table;
@property (nonatomic, weak) NSArray<Song*>* songs;
@end

@implementation SongListView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                                  songs:(NSArray<Song*>*)songs
{
    if (self = [super init]) {
        _controlDelegate = controlDelegate;
        _songs = songs;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _table = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
        _table.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _table.allowsSelection = NO;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songs.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SongCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell"];
    if (!cell) {
        cell = [[SongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SongCell"];
    }
    cell.delegate = self;
    [cell bindWithSong:_songs[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
}

- (void)songCell:(SongCell*)songCell didTapSong:(Song*)song
{
    if (song.isPlaying) {
        song.isPlaying = NO;
    } else {
        song.isPlaying = YES;
        for (Song* s in _songs) {
            if (s.isPlaying && s != song) {
                s.isPlaying = NO;
            }
        }
    }
    [_table reloadData];
}

- (void)songCell:(SongCell*)songCell didLongPressSong:(Song*)song
{
}

- (void)stopSong
{
    BOOL changed = NO;
    for (Song* song in _songs) {
        if (song.isPlaying) {
            song.isPlaying = NO;
            changed = YES;
        }
    }
    if (changed) {
        [_table reloadData];
    }
}

@end
