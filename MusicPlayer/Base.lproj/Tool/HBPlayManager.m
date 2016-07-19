//
//  HBMusicManager.m
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "HBPlayManager.h"

@interface HBPlayManager ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, copy) NSString *fileName;

@end

@implementation HBPlayManager

static HBPlayManager *_playManager;
+ (instancetype)sharedPlayManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _playManager = [[self alloc] init];
    });
    return _playManager;
}

- (void)playMusicWithFileName:(NSString *)fileName {

    if (![self.fileName isEqualToString:fileName]) {    // 解决暂停后播放从头开始的bug
        // 创建播放器
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [self.audioPlayer prepareToPlay];

        self.fileName = fileName;
    }
    // 播放
    [self.audioPlayer play];
}

- (void)pause {
    [self.audioPlayer pause];
}

@end
