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

@interface ViewController ()
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
}

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

    self.durationLbl.text = [self stringWithTimeInterval:playMgr.duration];     // 须放在播放音乐之后, 才能获取duration值, 否则为上一曲的

    // 解析歌词
    self.lyrics = [HBLyricParser parserLyricWithFileName:music.lrc];
}

- (NSString *)stringWithTimeInterval:(NSTimeInterval)timeInterval {
    int minute = timeInterval / 60;
    int second = (int)timeInterval % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minute, second];
}

#pragma mark - 进度相关

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
    self.currentTimeLbl.text = [self stringWithTimeInterval:playMgr.currentTime];
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
    HBLyricModel *nextLyric = self.lyrics[self.currentLyricIdx + 1];

    // 调整进度
    if (playMgr.currentTime < lyric.time) {
        self.currentLyricIdx--;
        [self updateLyric];
    }
    if (playMgr.currentTime > nextLyric.time) {
        self.currentLyricIdx++;
        [self updateLyric];
    }
    // 显示歌词 -- KVC赋值(H&V)
    [self.lyricLbls setValue:lyric.content forKey:@"text"];
}

- (IBAction)sliderValueChange {
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];
    // 进度条位置对应的时间 = 进度条value(0~1) * 歌曲总时长
    playMgr.currentTime = self.slider.value * playMgr.duration;
}

#pragma mark - lazy load
- (NSArray *)musics {
    if (!_musics) {
        // MJExtension框架实现文件转模型
        _musics = [HBMusicModel objectArrayWithFilename:@"mlist.plist"];
    }
    return _musics;
}

@end
