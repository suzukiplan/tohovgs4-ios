/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "SongListViewController.h"
#import "view/PushableView.h"

@interface SongListViewController ()
@property (nonatomic) UIView* container;
@property (nonatomic) UILabel* titleLabel;
@property (nonatomic) UITableView* table;
@property (nonatomic) PushableView* close;
@property (nonatomic) UILabel* closeLabel;
@end

@implementation SongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _container = [[UIView alloc] init];
    _container.clipsToBounds = YES;
    _container.backgroundColor = [UIColor blackColor];
    _container.layer.borderColor = [UIColor whiteColor].CGColor;
    _container.layer.borderWidth = 4;
    _container.layer.cornerRadius = 8.0;
    [self.view addSubview:_container];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = NSLocalizedString(@"added_songs", nil);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_titleLabel];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
