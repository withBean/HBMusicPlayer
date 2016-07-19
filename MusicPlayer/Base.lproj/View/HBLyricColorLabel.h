//
//  HBLyricColorLabel.h
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

/// 显示歌词的label. 通过继承方式自定义label, 扩展颜色和进度(改width)属性. 因为category类扩展只能增加方法而不能扩展属性.

#import <UIKit/UIKit.h>

@interface HBLyricColorLabel : UILabel

/// 当前播放歌词的颜色 (default is GreenColor)
@property (nonatomic, strong) UIColor *currentColor;
/// 歌词播放进度
@property (nonatomic, assign) CGFloat progress;

@end
