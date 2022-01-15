/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "../model/Album.h"

NS_ASSUME_NONNULL_BEGIN

@class AlbumTabView;

@protocol AlbumTabViewDelegate <NSObject>
- (void)albumTabView:(AlbumTabView*)tabView didChangePosition:(NSInteger)position;
- (void)albumTabViewDidMoveEnd;
@end

@interface AlbumTabView : UIScrollView
@property (nonatomic) NSInteger position;
@property (nonatomic, readonly) CGFloat height;
- (instancetype)initWithAlbums:(NSArray<Album*>*)albums
               initialPosition:(NSInteger)initialPosition
                      delegate:(id<AlbumTabViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
