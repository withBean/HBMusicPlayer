//
//  HBLyricModel.h
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

/* 一行歌词为一个model*/

#import <Foundation/Foundation.h>

@interface HBLyricModel : NSObject

/// 某行歌词的内容
@property (nonatomic, copy) NSString *content;
/// 某行歌词开始的时间
@property (nonatomic, assign) NSTimeInterval beginTime;

@end
