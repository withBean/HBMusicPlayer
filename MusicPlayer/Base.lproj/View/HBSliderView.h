//
//  HBSliderView.h
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

/// 歌词显示界面拖动时出现中间的小框. 可点击跳转歌曲进度到拖拽时间点, 停止拖拽后隐藏

#import <UIKit/UIKit.h>

@interface HBSliderView : UIView

/// 滚动所在行歌词的开始时间
@property (nonatomic, assign) NSTimeInterval selectedTime;

@end
