//
//  HPActivity.m
//  baicai
//
//  Created by hp on 2017/5/22.
//  Copyright © 2017年 a. All rights reserved.
//

#import "HPActivity.h"
UIActivityType const HPActivityTypeQQ = @"HPActivityTypeQQ";
UIActivityType const HPActivityTypeWeChat = @"HPActivityTypeWeChat";
@interface HPActivity ()
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * imageName;
@property (nonatomic, copy) NSString * type;

@end

@implementation HPActivity

- (instancetype)initWithName:(NSString *)name
                   imageName:(NSString *)imageName
                        type:(NSString *)type
                    category:(UIActivityCategory)category
{
    self = [super init];
    if (self) {
        self.title = name;
        self.imageName = imageName;
        self.type = type;
        self.activityCategory = category;
    }
    return self;
}

+ (UIActivityCategory)activityCategory
{
    return [[self alloc] activityCategory];
}

- (UIActivityCategory)activityCategory{
    return _activityCategory;
}
- (nullable UIActivityType)activityType       // default returns nil. subclass may override to return custom activity type that is reported to completion handler
{
    return self.type;
}
- (nullable NSString *)activityTitle     // default returns nil. subclass must override and must return non-nil value
{
    return self.title;
}
- (nullable UIImage *)activityImage       // default returns nil. subclass must override and must return non-nil value
{
    return [UIImage imageNamed:self.imageName];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems;   // override this to return availability of activity based on items. default returns NO
{
    
    return YES;
}
- (void)prepareWithActivityItems:(NSArray *)activityItems;      // override to extract items and set up your HI. default does nothing
{
    
}

@end
