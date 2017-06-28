//
//  HPActivityCell.m
//  baicai
//
//  Created by hp on 2017/5/22.
//  Copyright © 2017年 a. All rights reserved.
//

#import "HPActivityCell.h"
#import "Masonry.h"
@interface HPActivityCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation HPActivityCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.iconView = [[UIImageView alloc] init];
        self.iconView.layer.cornerRadius = 5.0;
        self.iconView.layer.masksToBounds = YES;
        [self addSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(5);
            make.left.equalTo(self.mas_left).offset(5);
            make.right.equalTo(self.mas_right).offset(-5);
            make.width.equalTo(self.iconView.mas_height);
        }];
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(-5);
            make.top.equalTo(self.iconView.mas_bottom).offset(5);
        }];
    }
    return self;
}

- (void)setActivity:(HPActivity *)activity {
    _activity = activity;
    self.titleLabel.text = self.activity.activityTitle;
    self.iconView.image = activity.activityImage;
}
@end
