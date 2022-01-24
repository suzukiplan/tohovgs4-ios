/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "model/Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface SongListViewController : UIViewController
@property (nonatomic) NSArray<Song*>* songs;
@end

NS_ASSUME_NONNULL_END
