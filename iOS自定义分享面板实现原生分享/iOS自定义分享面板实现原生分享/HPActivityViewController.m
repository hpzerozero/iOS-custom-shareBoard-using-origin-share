//
//  HPActivityViewController.m
//  baicai
//
//  Created by hp on 2017/5/22.
//  Copyright © 2017年 a. All rights reserved.
//

#import "HPActivityViewController.h"
#import "LFCollectionReusableView.h"
#import "MBProgressHUD.h"
#import "Header.h"
static NSString * const CellIdentifier = @"HPActivityCell";

@interface HPActivityViewController ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
/** */
//@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIToolbar *blurToolbar;

@property (strong, nonatomic) NSArray *applicationActivities;
/** title*/
@property (strong, nonatomic) UILabel *titleLabel;
/** tips*/
@property (strong, nonatomic) UIButton *tipsButton;

/** action*/
@property (strong, nonatomic) NSMutableArray * actionActivities;
/** share*/
@property (strong, nonatomic) NSMutableArray *shareActivities;
/** 背景图*/
@property (strong, nonatomic) UIView *bgView;
/** webview*/
@property (weak, nonatomic) UIView *webviewBgView;

/** 选中的平台*/
@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@implementation HPActivityViewController

- (void)setItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities
{
    self.activityItems = activityItems;
    self.applicationActivities = applicationActivities;
    self.actionActivities = [NSMutableArray array];
    self.shareActivities = [NSMutableArray array];
    for (HPActivity * activity in applicationActivities) {
        if (activity.activityCategory == UIActivityCategoryShare) {
            [self.shareActivities addObject:activity];
        }else if (activity.activityCategory == UIActivityCategoryAction) {
            [self.actionActivities addObject:activity];
        }
    }
    [self.collectionView reloadData];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 整体背景
        self.bgView = [[UIView alloc] initWithFrame:self.view.frame];
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.2;
        [self.view addSubview:self.bgView];
        
        self.contentView = [[UIView alloc] init];
        [self.view addSubview:self.contentView];
        
        [self addBlurBackground];
        [self setupTitleView];
        [self setUpCollectionViewForPhone];
        [self addCancelButton];
        
        [self setBounds];
        
        // 添加手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tap.delegate = self;
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tap];
    }
    return self;
}
- (instancetype)initWithItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities
{
    self = [super init];
    if (self) {
        self.activityItems = activityItems;
        self.applicationActivities = applicationActivities;
        self.actionActivities = [NSMutableArray array];
        self.shareActivities = [NSMutableArray array];
        for (HPActivity * activity in applicationActivities) {
            if (activity.activityCategory == UIActivityCategoryShare) {
                [self.shareActivities addObject:activity];
            }else if (activity.activityCategory == UIActivityCategoryAction) {
                [self.actionActivities addObject:activity];
            }
        }
        
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setBounds];
}
- (void)configureForPhone {
    
    CGFloat viewHeight = H(228);
    
    CGRect frame = CGRectMake(0,kScreenHeight - viewHeight,kScreenWidth,viewHeight);
    
    self.contentView.frame = frame;
    self.blurToolbar.frame = self.contentView.bounds;

    self.cancelButton.frame = CGRectMake(0, viewHeight-H(38), kScreenWidth, H(38));
    CGRect collectionFrame = self.contentView.bounds;
    collectionFrame.origin.y = H(85);
    collectionFrame.size.height = (viewHeight-H(38)-H(86));
    self.collectionView.frame = collectionFrame;
}
- (void)setBounds {
    
    [self configureForPhone];
}
#pragma mark - 
- (void)didTapCancelButton {
    [self removeView];
}
/** 移除视图*/
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    // 点击的位置
    CGPoint tapPoint = [gesture locationInView:self.view];
    // 点击范围
    if (!CGRectContainsPoint(self.contentView.frame, tapPoint)) {
        [self removeView];
    }
}
/** 移除视图*/
- (void)removeView
{
    // 动画
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        
        self.contentView.transform = CGAffineTransformMakeTranslation(1.0, H(296));
        self.bgView.alpha = 0.001;
    } completion:^(BOOL finished) {
        // 移除手势
        //        [self.view removeGestureRecognizer:gesture];
        // 移除视图
        [self.view removeFromSuperview];
        
    }];
}

// 手势代理
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
    // 点击范围
    if (CGRectContainsPoint(self.contentView.frame, tapPoint)) {
        return NO;
    }
    return YES;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.applicationActivities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HPActivityCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//    if (indexPath.section==0) {
//        
        cell.activity = self.applicationActivities[indexPath.row];
//    } else {
//        cell.activity = self.shareActivities[indexPath.row];
//    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    LFCollectionReusableView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LFCollectionReusableView" forIndexPath:indexPath];
    footerView.customView = [[UIView alloc] initWithFrame:CGRectMake(W(12), 0, footerView.frame.size.width-2*W(12), 1)];
    footerView.customView.backgroundColor = kRGB(204, 204, 204, 1);
    [footerView addSubview:footerView.customView];
    return footerView;
}
#pragma mark - UICollectionViewDelegate

- (void)alertSharePlatWithType:(HPActivity *)activity {
  UIImage *imageToShare = nil;
        NSString * textToShare = nil;
        NSURL * urlToShare = nil;
        for (id obj in self.activityItems) {
            if ([obj isKindOfClass:[NSString class]]) {
                textToShare = obj;
            }
            if ([obj isKindOfClass:[UIImage class]]) {
                imageToShare = obj;
            }
            if ([obj isKindOfClass:[NSURL class]]) {
                urlToShare = obj;
            }
        }
        
        
        if ([activity.activityType isEqualToString:HPActivityTypeQQ]) {
            if ([SLComposeViewController isAvailableForServiceType:@"com.tencent.mqq.ShareExtension"]) {
                
                SLComposeViewController * composeVC = [SLComposeViewController composeViewControllerForServiceType:@"com.tencent.mqq.ShareExtension"];
                
                composeVC.completionHandler = ^(SLComposeViewControllerResult result) {
                    NSLog(@"%s,line=%d",__FUNCTION__,__LINE__);
                };

                if (urlToShare) {
                    
                    [composeVC addURL:urlToShare];
                }
                [self.presentingVC presentViewController:composeVC animated:YES completion:nil];
            } else {
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.presentingVC.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"未安装QQ";
                [hud hide:YES afterDelay:1];
            }
        } else if ([activity.activityType isEqualToString:HPActivityTypeWeChat]) {
            if ([SLComposeViewController isAvailableForServiceType:@"com.tencent.xin.sharetimeline"]) {
                SLComposeViewController * composeVC = [SLComposeViewController composeViewControllerForServiceType:@"com.tencent.xin.sharetimeline"];
                composeVC.completionHandler = ^(SLComposeViewControllerResult result) {
                    NSLog(@"%s,line=%d",__FUNCTION__,__LINE__);
                };
                if (urlToShare) {
                    
                    [composeVC addURL:urlToShare];
                }
                [self.presentingVC presentViewController:composeVC animated:YES completion:nil];
                
            } else {
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.presentingVC.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"未安装微信";
                [hud hide:YES afterDelay:1];
            }
        }else if ([activity.activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
            
            NSString * str = [NSString stringWithFormat:@"【%@】点击链接，领取优惠券，进入👉手机淘宝👈即可看到，#LFopuoC#，%@",textToShare, urlToShare];
            [UIPasteboard generalPasteboard].string = str;
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.presentingVC.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"复制成功,赶快分享给好友吧";
            [hud hide:YES afterDelay:1];
        } else if ([activity.activityType isEqualToString:UIActivityTypePostToWeibo]) {
            if ([SLComposeViewController isAvailableForServiceType:@"com.apple.social.sinaweibo"]) {
                SLComposeViewController * composeVC = [SLComposeViewController composeViewControllerForServiceType:@"com.apple.social.sinaweibo"];
                
                composeVC.completionHandler = ^(SLComposeViewControllerResult result) {
                   NSLog(@"%s,line=%d",__FUNCTION__,__LINE__);
                };
                if(imageToShare) {
                    if(![composeVC addImage:imageToShare]){
                        NSLog(@"%s,line=%d,设置失败",__FUNCTION__,__LINE__);
                    };
                }
                if (textToShare) {
                    if(![composeVC setInitialText:textToShare]){
                        NSLog(@"%s,line=%d,设置失败",__FUNCTION__,__LINE__);
                    };
                }
                if (urlToShare) {
                    
                    if (![composeVC addURL:urlToShare]) {
                        NSLog(@"%s,line=%d,设置失败",__FUNCTION__,__LINE__);
                    }
                }
                [self.presentingVC presentViewController:composeVC animated:YES completion:nil];
            } else {
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.presentingVC.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"未安装微博";
                [hud hide:YES afterDelay:1];
            }
        }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.indexPath = indexPath;
    HPActivity *activity = self.applicationActivities[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectedItemsWithType:)]) {
        [self.delegate didSelectedItemsWithType:activity.activityType];
    }
//
    if (self.activityItems) {
        
        [self alertSharePlatWithType:activity];
        [self removeView];
    }
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


#pragma mark - Rendering methods

- (void)addBlurBackground {
    
    // content 背景
    self.blurToolbar = [[UIToolbar alloc] initWithFrame:self.contentView.bounds];
    self.blurToolbar.translucent = NO;
    [self.contentView insertSubview:self.blurToolbar atIndex:0];
}

- (void)setupTitleView {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, H(23), kScreenWidth, H(12))];
    self.titleLabel.textColor = kRGB(51, 51, 51, 1);
    self.titleLabel.text = @"— 分享有赏 —";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    
}

- (void)setUpCollectionViewForPhone {
    [self setUpCollectionView];
    self.collectionViewLayout.itemSize = CGSizeMake(W(50), H(65));
    self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(H(20), W(20), H(17), 0);
    self.collectionView.scrollEnabled = NO;
    self.collectionViewLayout.minimumInteritemSpacing = 5;
    self.collectionViewLayout.minimumLineSpacing = 5;
    self.collectionViewLayout.footerReferenceSize = CGSizeMake(kScreenWidth, 1);
}

- (void)setUpCollectionView {
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
    [self.collectionView registerClass:[HPActivityCell class] forCellWithReuseIdentifier:CellIdentifier];
    [self.collectionView registerClass:[LFCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LFCollectionReusableView"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.contentView addSubview: self.collectionView];
    
    self.collectionView.backgroundColor = UIColor.clearColor;
}

- (void)addCancelButton {
    //
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelButton.frame = CGRectMake(0, 0, self.view.frame.size.width, H(38));
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:kRGB(51, 51, 51, 1) forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = UIColor.clearColor;
    [self.cancelButton addTarget:self action:@selector(didTapCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelButton];
}


- (void)dealloc{
    NSLog(@"%s,line=%d, 销毁",__FUNCTION__,__LINE__);
}
@end
