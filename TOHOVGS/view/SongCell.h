//
//  SongCell.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <UIKit/UIKit.h>
#import "../model/Song.h"

NS_ASSUME_NONNULL_BEGIN

@class SongCell;

@protocol SongCellDelegate <NSObject>
- (void)songCell:(SongCell*)songCell didTapSong:(Song*)song;
@end

@interface SongCell : UITableViewCell
@property (nonatomic, weak) id<SongCellDelegate> delegate;
- (void)bindWithSong:(Song*)song;
@end

NS_ASSUME_NONNULL_END
