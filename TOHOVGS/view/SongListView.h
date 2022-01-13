//
//  SongListView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <UIKit/UIKit.h>
#import "../ControlDelegate.h"
#import "../model/Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface SongListView : UIView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                                  songs:(NSArray<Song*>*)songs;
@end

NS_ASSUME_NONNULL_END
