//
//  Header.h
//  iOS自定义分享面板实现原生分享
//
//  Created by hp on 2017/6/28.
//  Copyright © 2017年 hpone. All rights reserved.
//

#ifndef Header_h
#define Header_h
#pragma mark - 尺寸适配

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
// 竖屏 按手机屏幕的比例来确定坐标
/** iphone 5*/
#define W(x) (x * kScreenWidth / 320.0)
#define H(y) (y * kScreenHeight / 568.0)
/** iphone 6*/
#define WIP6(x) (x * kScreenWidth / 375.0)
#define HIP6(y) (y * kScreenHeight / 667.0)
/** iphone 6+*/
#define IP6PWIDTH(x) (x * kScreenWidth / 414.0)
#define IP6PHEIGHT(y) (y * kScreenHeight / 736.0)
// 横屏 按手机屏幕的比例来确定坐标
#define WR(y) (y * kScreenHeight / 320.0)
#define HR(X) (x * kScreenWeight / 568.0)
#define kRGB(x, y, z, a) [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:a]

#endif /* Header_h */
