//
//  AlbumTabView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import <UIKit/UIKit.h>
#import "../model/Album.h"

NS_ASSUME_NONNULL_BEGIN

@class AlbumTabView;

@protocol AlbumTabViewDelegate <NSObject>
- (void)albumTabView:(AlbumTabView*)tabView didChangePosition:(NSInteger)position;
@end

@interface AlbumTabView : UIScrollView
@property (nonatomic) NSInteger position;
@property (nonatomic, readonly) CGFloat height;
- (instancetype)initWithAlbums:(NSArray<Album*>*)albums
                      delegate:(id<AlbumTabViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
