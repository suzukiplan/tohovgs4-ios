//
//  TextTabView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/06/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TextTabView;

@protocol TextTabViewDelegate <NSObject>
- (void)textTabView:(TextTabView*)tabView didChangePosition:(NSInteger)position;
- (void)textTabViewDidMoveEnd:(TextTabView*)view;
@end

@interface TextTabView : UIView
@property (nonatomic) NSInteger position;
@property (nonatomic, readonly) CGFloat height;
- (instancetype)initWithTexts:(NSArray<NSString*>*)texts
                     delegate:(id<TextTabViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
