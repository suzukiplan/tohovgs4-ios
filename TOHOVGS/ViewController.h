//
//  ViewController.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <UIKit/UIKit.h>
#import "api/MusicManager.h"

@interface ViewController : UIViewController
@property (nonatomic, readonly) MusicManager* musicManager;
@end

