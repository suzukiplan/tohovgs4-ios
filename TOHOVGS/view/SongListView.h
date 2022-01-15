//
//  SongListView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <UIKit/UIKit.h>
#import "../model/Song.h"
#import "../ControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SongListView : UIView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                                  songs:(NSArray<Song*>*)songs
                           splitByAlbum:(BOOL)splitByAlbum
                                shuffle:(BOOL)shuffle;
- (void)stopSong;
- (void)requireNextSong:(Song*)song
               infinity:(BOOL)infinity;
- (void)shuffleWithControlDelegate:(id<ControlDelegate>)controlDelegate;
- (void)reload;
@end

NS_ASSUME_NONNULL_END
