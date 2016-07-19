//
//  HBLyricColorLabel.m
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "HBLyricColorLabel.h"

@implementation HBLyricColorLabel

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    // 颜色
    [self.currentColor set];
    // 宽度
    rect.size.width *= self.progress;

    // 设置图形混合模式
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}

#pragma mark - getter & setter

- (UIColor *)currentColor {
    if (!_currentColor) {
        _currentColor = [UIColor greenColor];
    }
    return _currentColor;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    // 重绘
    [self setNeedsDisplay];
}

@end
