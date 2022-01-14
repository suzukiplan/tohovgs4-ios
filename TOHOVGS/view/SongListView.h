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
                           splitByAlbum:(BOOL)splitByAlbum;
- (void)stopSong;
- (void)requireNextSong:(Song*)song
               infinity:(BOOL)infinity;
@end

NS_ASSUME_NONNULL_END
