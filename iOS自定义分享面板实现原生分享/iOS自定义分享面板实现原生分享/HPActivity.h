//
//  HPActivity.h
//  baicai
//
//  Created by hp on 2017/5/22.
//  Copyright © 2017年 a. All rights reserved.
//

#import <UIKit/UIKit.h>
UIKIT_EXTERN UIActivityType const HPActivityTypeQQ;
UIKIT_EXTERN UIActivityType const HPActivityTypeWeChat;
@interface HPActivity : UIActivity

/** */
@property (assign, nonatomic) UIActivityCategory activityCategory;

- (instancetype)initWithName:(NSString *)name
                   imageName:(NSString *)imageName
                        type:(NSString *)type
                    category:(UIActivityCategory)category;
@end
