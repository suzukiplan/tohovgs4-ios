//
//  ControlDelegate.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "model/Song.h"

@class ViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol ControlDelegate <NSObject>
- (ViewController*)getViewController;
- (void)startProgressWithMessage:(NSString*)message;
- (void)stopProgress:(void(^)(void))done;
- (void)askLockWithSong:(Song*)song locked:(void(^)(void))locked;
- (void)askUnlockWithAlbum:(Album*)album unlocked:(void(^)(void))unlocked;
- (void)askUnlockAllWithCallback:(void(^)(void))unlocked;
@end

NS_ASSUME_NONNULL_END
