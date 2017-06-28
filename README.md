# iOS-custom-shareBoard-using-origin-share
##iOS自定义分享面板实现原生分享

什么都不多说，先看效果图
<i class="icon ion-ios-eye"/>  
![1234.gif](https://github.com/hpzerozero/iOS-custom-shareBoard-using-origin-share/blob/master/1234.gif)   

此处与iOS原生分享不同的地方是，这个弹出的分享面板是可以自定义的，想要什么样子什么样子，而且还可以指定分享的平台，如果需要别的平台可以留言给我；

以下是原生的分享面板，调起的原生分享

![IMG_4186.PNG](https://github.com/hpzerozero/iOS-custom-shareBoard-using-origin-share/blob/master/IMG_4186.PNG)
![IMG_4187.PNG](https://github.com/hpzerozero/iOS-custom-shareBoard-using-origin-share/blob/master/IMG_4187.PNG)

以下是实现的基本思路：
自定义一个`viewController`,然后使用`collectionView`进行平台的布局  

```
#import <UIKit/UIKit.h>
#import "HPActivityCell.h"
#import <Social/Social.h>
typedef void (^UIActivityViewControllerCompletionWithItemsHandler)(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError);
typedef void (^UIActivityViewControllerCompletionHandler)(UIActivityType __nullable activityType, BOOL completed);

@protocol HPActivityViewControllerDelegate <NSObject>

- (void)didSelectedItemsWithType:(UIActivityType _Nullable )type;

@end

@interface HPActivityViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

- (instancetype _Nullable )initWithItems:(NSArray *_Nonnull)activityItems applicationActivities:(nullable NSArray *)applicationActivities;
- (void)setItems:(NSArray *_Nullable)activityItems applicationActivities:(NSArray *_Nonnull)applicationActivities;
@property(nullable, nonatomic, copy) UIActivityViewControllerCompletionHandler completionWithHandler; // set to nil after call
@property(nullable, nonatomic, copy) NSArray<UIActivityType> *excludedActivityTypes; // default is nil. activity types listed will not be displayed
- (void)reShare;
/** The actual content of the action sheet */
@property (strong, nonatomic) UIView * _Nonnull contentView;
/** presentingViewController*/
@property (weak, nonatomic) UIViewController * _Nullable presentingVC;
@property (strong, nonatomic) NSArray * _Nullable activityItems;

@property (weak, nonatomic ,nullable) id<HPActivityViewControllerDelegate> delegate;
@end

```  

```
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
```
其中自定义面板的部分都不是很难，毕竟这也算基本功了，但是最主要是面板定义好了如何才能点击平台调用相关的平台进行分享呢？

<i class="fa fa-flag"/>**上面的代码比较乱，可以按照自己的思路写，核心代码却是下面的部分**

```
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.indexPath = indexPath;
    HPActivity *activity = self.applicationActivities[indexPath.row];
    if (self.activityItems) {
        
        [self alertSharePlatWithType:activity];
        [self removeView];
    }
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}
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
```

总结：iOS里的原生分享面板是使用`UIActivityViewController`这个类来实现的，我只是照着它的样子重写了一个我自己的，而`UIActivityViewController`在点击平台的时候也是使用`SLComposeViewController`这个类最终实现,但是`SLComposeViewController`并没有公开里面的机制，不过我猜想应该是将`share Extension`封装为半系统级的，所以不管在哪个app的界面，只要调用这个类都能分享给实现了`share extension`功能的app，比如微信、QQ、微博、Facebook等。顺便提一下，点击分享后的那个弹窗并不是系统写的，而是要分享的那个平台自己使用xcode的`share extension`开发的.



##### SLComposeViewController

```
#import <UIKit/UIKit.h>
#import <Social/SocialDefines.h>

typedef NS_ENUM(NSInteger, SLComposeViewControllerResult) {
    SLComposeViewControllerResultCancelled,
    SLComposeViewControllerResultDone
};

typedef void (^SLComposeViewControllerCompletionHandler)(SLComposeViewControllerResult result); 

// Although you may perform requests on behalf of the user, you cannot append
// text, images, or URLs without the user's knowledge. Hence, you can set the
// initial text and other content before presenting the view to the user, but
// cannot change the content after the user views it. All of the methods used
// to set the content return a Boolean value. The methods return NO if the
// content doesn't fit or if the view was already presented to the user and the
// content can no longer be changed.

SOCIAL_CLASS_AVAILABLE(NA, 6_0)
@interface SLComposeViewController : UIViewController

+ (BOOL)isAvailableForServiceType:(NSString *)serviceType;

+ (SLComposeViewController *)composeViewControllerForServiceType:(NSString *)serviceType;

@property(nonatomic, readonly) NSString *serviceType;

// Sets the initial text to be posted. Returns NO if the sheet has already been
// presented to the user. On iOS 6.x, this returns NO if the specified text
// will not fit within the character space currently available; on iOS 7.0 and
// later, you may supply text with a length greater than the service supports,
// and the sheet will allow the user to edit it accordingly.
- (BOOL)setInitialText:(NSString *)text;

// Adds an image to the post. Returns NO if the additional image will not fit
// within the character space currently available, or if the sheet has already
// been presented to the user.
- (BOOL)addImage:(UIImage *)image;

// Removes all images from the post. Returns NO and does not perform an operation
// if the sheet has already been presented to the user. 
- (BOOL)removeAllImages;


// Adds a URL to the post. Returns NO if the additional URL will not fit
// within the character space currently available, or if the sheet has already
// been presented to the user.
- (BOOL)addURL:(NSURL *)url;


// Removes all URLs from the post. Returns NO and does not perform an operation
// if the sheet has already been presented to the user.
- (BOOL)removeAllURLs;


// Specify a block to be called when the user is finished. This block is not guaranteed
// to be called on any particular thread. It is cleared after being called.
@property (nonatomic, copy) SLComposeViewControllerCompletionHandler completionHandler;
@end
```  

[demo地址](https://github.com/hpzerozero/iOS-custom-shareBoard-using-origin-share.git)
