//
//  HBLyricView.h
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

/// 相当于一个蒙版+容器(如果直接加在中间视图, 歌词与图片重叠, 很不美观). 其上添加2层scrollView, 一个两倍于屏幕宽度左右滑动用于切换界面(滑动过程原视图透明渐变), 另一个上下滑动用于显示歌词.

#import <UIKit/UIKit.h>

@class HBLyricView;
@protocol HBLyricViewDelegate <NSObject>

@optional
- (void)scrollLyricView:(HBLyricView *)lyricView withProgress:(CGFloat)progress;

@end

@interface HBLyricView : UIView

@property (nonatomic, weak) id<HBLyricViewDelegate> delegate;

/// 歌词模型数组
@property (nonatomic, strong) NSArray *lyrics;
/// label高度
@property (nonatomic, assign) CGFloat rowHeight;

@end
