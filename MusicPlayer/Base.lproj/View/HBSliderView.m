//
//  HBSliderView.m
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "HBSliderView.h"
#import "Masonry.h"
#import "HBPlayManager.h"
#import "HBTimeTool.h"

@interface HBSliderView ()

/// 设置背景颜色
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *timeLbl;
@property (nonatomic, strong) UILabel *tipLbl;
@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation HBSliderView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
//    self.backgroundColor = [UIColor cyanColor];
    // 1. 初始化
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.image = [UIImage imageNamed:@"lyric_tipview_backimg"];
    [self addSubview:bgImageView];
    self.bgImageView = bgImageView;

    UILabel *timeLbl = [[UILabel alloc] init];
    timeLbl.text = @"00:00";
    timeLbl.textColor = [UIColor whiteColor];
    timeLbl.font = [UIFont systemFontOfSize:15.0];
    [self addSubview:timeLbl];
    self.timeLbl = timeLbl;

    UILabel *tipLbl = [[UILabel alloc] init];
    tipLbl.text = @"请点击右边按钮开始播放";
    tipLbl.textColor = [UIColor whiteColor];
    tipLbl.font = [UIFont systemFontOfSize:15.0];
    [self addSubview:tipLbl];
    self.tipLbl = tipLbl;

    UIButton *playBtn = [[UIButton alloc] init];
    [playBtn setImage:[UIImage imageNamed:@"slide_icon_play"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"slide_icon_play_pressed"] forState:UIControlStateHighlighted];
    [playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playBtn];
    self.playBtn = playBtn;

    // 2. 约束
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.centerY.mas_equalTo(self);
    }];
    [self.tipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-8);
        make.centerY.mas_equalTo(self);
    }];
}

- (void)playBtnClick {
    HBPlayManager *playMgr = [HBPlayManager sharedPlayManager];
    // 设置当前播放时间
    playMgr.currentTime = self.selectedTime;
}

#pragma mark - setter & getter
- (void)setSelectedTime:(NSTimeInterval)selectedTime {
    _selectedTime = selectedTime;
    self.timeLbl.text = [HBTimeTool stringWithTimeInterval:self.selectedTime];
}

@end
