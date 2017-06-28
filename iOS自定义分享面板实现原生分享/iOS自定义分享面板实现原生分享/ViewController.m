//
//  ViewController.m
//  iOS自定义分享面板实现原生分享
//
//  Created by hp on 2017/6/28.
//  Copyright © 2017年 hpone. All rights reserved.
//

#import "ViewController.h"
#import "HPActivityViewController.h"
@interface ViewController ()<HPActivityViewControllerDelegate>
/** */
@property (strong, nonatomic) HPActivityViewController *shareVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareInfo:(id)sender {
    [self showBottomNormalView];
}

/** 原生分享*/
- (void)showBottomNormalView
{
    
    HPActivity * activityQQ = [[HPActivity alloc] initWithName:@"QQ" imageName:@"QQIcon" type:HPActivityTypeQQ category:UIActivityCategoryShare];
    HPActivity * activityWeChat = [[HPActivity alloc] initWithName:@"微信" imageName:@"微信" type:HPActivityTypeWeChat  category:UIActivityCategoryShare];
    HPActivity * activityCopy= [[HPActivity alloc] initWithName:@"复制链接" imageName:@"拷贝链接" type:UIActivityTypeCopyToPasteboard  category:UIActivityCategoryAction];
    HPActivity * activitySina= [[HPActivity alloc] initWithName:@"微博" imageName:@"新浪微博" type:UIActivityTypePostToWeibo  category:UIActivityCategoryShare];
    UIImage *imageToShare = [UIImage imageNamed:@"CYLoLi"];
    NSString *textToShare = @"";
    NSURL *urlToShare = [NSURL URLWithString:@"http://www.baidu.com"];
    NSArray *activityItems = @[imageToShare?imageToShare:@"",textToShare?textToShare:@"",urlToShare?urlToShare:@""];
    [self.shareVC setItems:activityItems applicationActivities:@[activityQQ,activityWeChat,activitySina,activityCopy]];
    self.shareVC.presentingVC = self;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        
        [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.shareVC.view];
    }];
    
}

- (void)didSelectedItemsWithType:(UIActivityType _Nullable )type{
    NSLog(@"%s,line=%d,%@",__FUNCTION__,__LINE__,type);
}

- (HPActivityViewController *)shareVC
{
    if (!_shareVC) {
        _shareVC = [[HPActivityViewController alloc] init];
        _shareVC.view.frame = [UIApplication sharedApplication].keyWindow.frame;
        _shareVC.delegate = self;
    }
    return _shareVC;
}
@end
