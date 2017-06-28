//
//  HPActivityViewController.h
//  baicai
//
//  Created by hp on 2017/5/22.
//  Copyright © 2017年 a. All rights reserved.
//

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
