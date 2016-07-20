//
//  ViewController.m
//  MusicPlayer
//
//  Created by Beans on 16/7/17.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "MJExtension.h"
#import "HBMusicModel.h"
#import "HBPlayManager.h"
#import "HBLyricParser.h"
#import "HBLyricModel.h"
#import "HBLyricView.h"
#import "HBTimeTool.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<HBLyricViewDelegate>
#pragma mark - H&V
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *durationLbl;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lyricLbls;

#pragma mark - H
@property (weak, nonatomic) IBOutlet UIView *hCenterView;
@property (weak, nonatomic) IBOutlet UIImageView *hSingerIcon;

#pragma mark - V
@property (weak, nonatomic) IBOutlet UIView *vCenterView;
@property (weak, nonatomic) IBOutlet UIImageView *vSingerIcon;
@property (weak, nonatomic) IBOutlet UILabel *singerLbl;
@property (weak, nonatomic) IBOutlet UILabel *albumLbl;
/// 歌词界面
@property (weak, nonatomic) IBOutlet HBLyricView *lyricView;


#pragma mark - 私有属性
@property (nonatomic, strong) NSArray *musics;
/// 当前歌曲的索引
@property (nonatomic, assign) NSInteger currentMusicIdx;
@property (nonatomic, strong) NSTimer *timer;
/// 歌词模型数组 (一个模型对应一行歌词)
@property (nonatomic, strong) NSArray *lyrics;
/// 当前歌词的索引
@property (nonatomic, assign) NSInteger currentLyricIdx;

@end

@implementation ViewController

#pragma mark - lazy load
- (NSArray *)musics {
    if (!_musics) {
        // MJExtension框架实现文件转模型
        _musics = [HBMusicModel objectArrayWithFilename:@"mlist.plist"];
    }
    return _musics;
}

#pragma mark - UI界面

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1. 毛玻璃效果
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleBlack;
    [self.bgImageView addSubview:toolbar];  // 添加在bgImageView, 只让背景图毛玻璃效果
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bgImageView);
    }];

    // 2. 切圆角
    self.vSingerIcon.layer.cornerRadius = self.vSingerIcon.bounds.size.width * 0.5;
    self.vSingerIcon.layer.masksToBounds = YES;

    [self changeMusic]; // 启动时播放并显示信息

    self.lyricView.delegate = self;

    // MARK: - 接收打断通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - 基本功能

- (IBAction)play {
    HBMusicModel *music = self.musics[self.currentMusicIdx];
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];

    // 播放与暂停
    if (self.playBtn.selected == NO) {      // 不要写self.playBtn.selected != self.playBtn.selected, 因为切歌时也在调用play, 会导致紊乱
        self.playBtn.selected = YES;
        // 本曲播放完后自动进入下一曲 (playMgr代理方法判断正常播放完毕, block回调实现下一曲)
        [playMgr playMusicWithFileName:music.mp3 completed:^{
            [self next];
        }];

        [self startUpdateProgress];

    } else if (self.playBtn.selected == YES) {
        self.playBtn.selected = NO;
        [playMgr pause];

        [self stopUpdateProgress];
    }
}

- (IBAction)previous {
    if (self.currentMusicIdx > 0) {     // 解决歌曲索引的数组越界的问题
        self.currentMusicIdx--;
    } else {
        self.currentMusicIdx = self.musics.count - 1;
    }

    [self changeMusic];
}

- (IBAction)next {
    if (self.currentMusicIdx < self.musics.count - 1) {
        self.currentMusicIdx++;
    } else {
        self.currentMusicIdx = 0;
    }

    [self changeMusic];
}

/// 切歌
- (void)changeMusic {
    HBMusicModel *music = self.musics[self.currentMusicIdx];
    self.bgImageView.image = [UIImage imageNamed:music.image];
    self.hSingerIcon.image = [UIImage imageNamed:music.image];
    self.vSingerIcon.image = [UIImage imageNamed:music.image];
    self.singerLbl.text = [NSString stringWithFormat:@"%@ - %@", music.singer, music.name];
    self.albumLbl.text = music.album;

    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];

    [self stopUpdateProgress];      // 放在播放之前, 解决暂停后切歌图片旋转问题
    self.vSingerIcon.transform = CGAffineTransformIdentity;

    self.playBtn.selected = NO;     // 解决切歌时播放/暂停交替的现象; 放在播放之前, 否则timer逻辑错误而多创建 -- 表现为暂停后图片仍旋转, 再次播放后2倍速度旋转加快, 再暂停后1倍速旋转. 当然还另一种思路为:每次创建timer前判断一下
    [self play];

    self.durationLbl.text = [HBTimeTool stringWithTimeInterval:playMgr.duration];     // 须放在播放音乐之后, 才能获取duration值, 否则为上一曲的

    // 解析歌词
    self.lyrics = [HBLyricParser parserLyricWithFileName:music.lrc];
    self.currentLyricIdx = 0;   // 重置当前歌词索引. 屏蔽歌曲演唱完后切歌崩溃 (下一曲歌词长度比当前短时)

    // lyricView传值
    self.lyricView.lyrics = self.lyrics;
}

#pragma mark - 进度相关

- (IBAction)sliderValueChange {
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];
    // 进度条位置对应的时间 = 进度条value(0~1) * 歌曲总时长
    playMgr.currentTime = self.slider.value * playMgr.duration;
}

- (void)startUpdateProgress {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
}

- (void)stopUpdateProgress {
    [self.timer invalidate];
    self.timer = nil;
}

/// 更新进度 -- timer事件(每0.1s调用一次)
- (void)updateProgress {
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];
    self.currentTimeLbl.text = [HBTimeTool stringWithTimeInterval:playMgr.currentTime];
    // value 0~1
    self.slider.value = playMgr.currentTime / playMgr.duration;
    // 旋转头像
    self.vSingerIcon.transform = CGAffineTransformRotate(self.vSingerIcon.transform, M_PI * 0.0025);

    // 更新歌词
    [self updateLyric];
}

- (void)updateLyric {
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];
    HBLyricModel *lyric = self.lyrics[self.currentLyricIdx];
    HBLyricModel *nextLyric = nil;

    // 屏蔽最后一句数组越界而崩溃
    /* index 27 beyond bounds [0 .. 26] */
    if (self.currentLyricIdx >= self.lyrics.count - 1) {
        nextLyric = [[HBLyricModel alloc] init];
        nextLyric.time = playMgr.duration;  // 解决播放最后一句时崩溃
    } else {
        nextLyric = self.lyrics[self.currentLyricIdx + 1];
    }

    // 1.1 调整进度
    /* index 18446744073709551615 beyond bounds [0 .. 26] */
    if (playMgr.currentTime < lyric.time && self.currentLyricIdx != 0) {    // 解决切歌时崩溃(下一曲引起), -1数组越界(有的歌不是[00:00.00]). `&& self.currentLyricIdx != 0`
        self.currentLyricIdx--;
        [self updateLyric];
    }
    if (playMgr.currentTime > nextLyric.time && self.currentLyricIdx != self.lyrics.count - 1) {    // 解决切歌时崩溃(当前歌最后一句歌词导致), `&& self.currentLyricIdx != self.lyrics.count - 1`
        self.currentLyricIdx++;
        [self updateLyric];
    }
    // 1.2 显示歌词 -- KVC赋值(H&V)
    [self.lyricLbls setValue:lyric.content forKey:@"text"];

    // 2. 歌词颜色
    // 进度 = (当前播放时间 - 歌词开始时间) / (下行歌词开始时间 - 这行歌词开始时间)
    CGFloat progress = (playMgr.currentTime - lyric.time) / (nextLyric.time - lyric.time);
    [self.lyricLbls setValue:@(progress) forKey:@"progress"];   // HBLyricColorLabel
//    [self.lyricLbls setValue:[UIColor magentaColor] forKey:@"currentColor"];

    // 3. lyricView传值
    self.lyricView.currentLyricIdx = self.currentLyricIdx;
    self.lyricView.progress = progress;

    // 锁屏界面
    [self updateLockScreen];
}

#pragma mark - HBLyricViewDelegate
/// 滑动过程中间视图渐变为透明
- (void)scrollLyricView:(HBLyricView *)lyricView withProgress:(CGFloat)progress {
    self.vCenterView.alpha = 1 - progress;
}

#pragma mark - 锁屏界面
/*
 // MPMediaItemPropertyAlbumTitle            专辑名称
 // MPMediaItemPropertyAlbumTrackCount
 // MPMediaItemPropertyAlbumTrackNumber
 // MPMediaItemPropertyArtist                歌手
 // MPMediaItemPropertyArtwork               专辑图片
 // MPMediaItemPropertyComposer
 // MPMediaItemPropertyDiscCount
 // MPMediaItemPropertyDiscNumber
 // MPMediaItemPropertyGenre
 // MPMediaItemPropertyPersistentID
 // MPMediaItemPropertyPlaybackDuration      歌曲的总时长
 // MPMediaItemPropertyTitle                 歌曲名
 */
// 设置锁屏界面歌曲信息
- (void)updateLockScreen {
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];
    HBMusicModel *music = self.musics[self.currentMusicIdx];

    // 创建锁屏界面对象
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    // 设置属性
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[MPMediaItemPropertyAlbumTitle] = music.album;
    info[MPMediaItemPropertyArtist] = music.singer;
    info[MPMediaItemPropertyTitle] = music.name;
//    info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:music.image]];
    info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[self updateImageWithLyric]];
    info[MPMediaItemPropertyPlaybackDuration] = @(playMgr.duration);
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(playMgr.currentTime); // 当前播放时间

    playingInfoCenter.nowPlayingInfo = info;
}

// 绘制歌词到图片上
- (UIImage *)updateImageWithLyric {
    HBMusicModel *music = self.musics[self.currentMusicIdx];
    UIImage *image = [UIImage imageNamed:music.image];

    // 1. 开启图形上下文
    UIGraphicsBeginImageContext(image.size);

    // 2.1 画专辑图片 [背景图片 + 歌词]
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    // 2.2 画背景图片(做歌词背景色)
    UIImage *maskImage = [UIImage imageNamed:@"lock_lyric_mask"];
    CGFloat maskImgH = 40;
    [maskImage drawInRect:CGRectMake(0, image.size.height - maskImgH, image.size.width, maskImgH)];
    // 颜色
    [[UIColor whiteColor] set];
    // 2.3 画歌词
    HBLyricModel *lyric = self.lyrics[self.currentLyricIdx];
    [lyric.content drawInRect:CGRectMake(0, image.size.height - maskImgH + 20, image.size.width, 30) withFont:[UIFont systemFontOfSize:13.0] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

    // 3. 获取图片
    UIImage *drawnImage = UIGraphicsGetImageFromCurrentImageContext();

    // 4. 关闭图形上下文
    UIGraphicsEndImageContext();

    return drawnImage;
}

#pragma mark - 接收远程控制事件
/*
 // available in iPhone OS 3.0
 UIEventSubtypeNone                              = 0,

 // for UIEventTypeMotion, available in iPhone OS 3.0
 UIEventSubtypeMotionShake                       = 1,

 // for UIEventTypeRemoteControl, available in iOS 4.0
 UIEventSubtypeRemoteControlPlay                 = 100,
 UIEventSubtypeRemoteControlPause                = 101,
 UIEventSubtypeRemoteControlStop                 = 102,
 UIEventSubtypeRemoteControlTogglePlayPause      = 103,     // 从暂停到播放
 UIEventSubtypeRemoteControlNextTrack            = 104,
 UIEventSubtypeRemoteControlPreviousTrack        = 105,
 UIEventSubtypeRemoteControlBeginSeekingBackward = 106,     // 开始快退
 UIEventSubtypeRemoteControlEndSeekingBackward   = 107,     // 结束快退
 UIEventSubtypeRemoteControlBeginSeekingForward  = 108,     // 开始快进
 UIEventSubtypeRemoteControlEndSeekingForward    = 109,     // 结束快进
 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self play];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;

        default:
            break;
    }
}

#pragma mark - 打断通知`AVAudioSessionInterruptionNotification` (短信/电话等)
// 1. 接收通知 已写

// 2. 通知事件
- (void)audioSessionInterruptionNotification:(NSNotification *)noti {
//    NSLog(@"%@", noti.userInfo);
    /*
     AVAudioSessionInterruptionOptionKey = 1
     AVAudioSessionInterruptionTypeKey = 0      // 被打断
     */

    AVAudioSessionInterruptionType interruptionType = [noti.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntValue];
    /*
     AVAudioSessionInterruptionTypeBegan = 1,  //the system has interrupted your audio session
     AVAudioSessionInterruptionTypeEnded = 0,  // the interruption has ended
     */
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        // 暂停
        self.playBtn.selected = YES;
        [self play];
    } else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
        // 播放 (保险起见, 多写几次)
        self.playBtn.selected = NO;
        [self play];
        self.playBtn.selected = YES;
        [self play];
        self.playBtn.selected = NO;
        [self play];
    }
}

// 3. 取消通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
