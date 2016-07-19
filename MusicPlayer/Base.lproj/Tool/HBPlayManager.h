//
//  HBMusicManager.h
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface HBPlayManager : NSObject

/// 歌曲总时长
@property (nonatomic, assign) NSTimeInterval duration;
/// 歌曲当前播放时间
@property (nonatomic, assign) NSTimeInterval currentTime;

/// 单例
+ (instancetype)sharedPlayManager;
/// 播放音乐
- (void)playMusicWithFileName:(NSString *)fileName completed:(void(^)())completed;
// 暂停音乐
- (void)pause;

@end
