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
        [playMgr playMusicWithFileName:music.mp3];

        [self startUpdateProgress];

    } else if (self.playBtn.selected == YES) {
        self.playBtn.selected = NO;
        [playMgr pause];

        [self stopUpdateProgress];
    }
}

- (IBAction)previous {
    if (self.currentMusicIdx > 0) {     // 解决数组越界的问题
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

//    [self stopUpdateProgress];
//    self.vSingerIcon.transform = CGAffineTransformIdentity;
    [self play];
    self.durationLbl.text = [self stringWithTimeInterval:playMgr.duration];     // 须放在播放音乐之后, 才能获取duration值

    self.playBtn.selected = NO;     // 解决切歌时播放/暂停交替的现象
}

- (NSString *)stringWithTimeInterval:(NSTimeInterval)timeInterval {
    int minute = timeInterval / 60;
    int second = (int)timeInterval % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minute, second];
}

#pragma mark - 进度相关

- (void)startUpdateProgress {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)stopUpdateProgress {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateProgress {
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];
    self.currentTimeLbl.text = [self stringWithTimeInterval:playMgr.currentTime];
    // value 0~1
    self.slider.value = playMgr.currentTime / playMgr.duration;
    // 旋转头像
    self.vSingerIcon.transform = CGAffineTransformRotate(self.vSingerIcon.transform, M_PI * 0.0025);
}

- (IBAction)sliderValueChange {
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];
    // 进度条位置对应的时间 = 进度条value(0~1) * 歌曲总时长
    playMgr.currentTime = self.slider.value * playMgr.duration;
}

#pragma mark - lazy load
- (NSArray *)musics {
    if (!_musics) {
        // MJExtension实现文件转模型
        _musics = [HBMusicModel objectArrayWithFilename:@"mlist.plist"];
    }
    return _musics;
}

@end
