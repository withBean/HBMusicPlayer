//
//  HBLyricView.m
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "HBLyricView.h"
#import "Masonry.h"
#import "HBLyricModel.h"
#import "HBLyricColorLabel.h"

@interface HBLyricView ()<UIScrollViewDelegate>

/// 横向滚动的ScrollView, 切换界面
@property (nonatomic, strong) UIScrollView *hScrollView;
/// 竖向滚动的ScrollView, 显示歌词
@property (nonatomic, strong) UIScrollView *vScrollView;

@end

@implementation HBLyricView

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
    // 1. hScrollView
    UIScrollView *hScrollView = [[UIScrollView alloc] init];
//    hScrollView.backgroundColor = [UIColor cyanColor];
    hScrollView.showsHorizontalScrollIndicator = NO;
    hScrollView.pagingEnabled = YES;
    hScrollView.bounces = NO;
    hScrollView.delegate = self;
    [self addSubview:hScrollView];
    self.hScrollView = hScrollView;

    // 2. vScrollView
    UIScrollView *vScrollView = [[UIScrollView alloc] init];
//    vScrollView.backgroundColor = [UIColor blueColor];
    [self.hScrollView addSubview:vScrollView];
    self.vScrollView = vScrollView;

    [self.hScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];

//    [self.vScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.mas_equalTo(self.hScrollView);
//        make.left.mas_equalTo(self.hScrollView.bounds.size.width);
//        make.width.mas_equalTo(self.hScrollView.bounds.size.width);
//    }];   // why don't work?

    [self.vScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 设置显示内容
    self.hScrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat progress = self.hScrollView.contentOffset.x / self.bounds.size.width;
    NSLog(@"%f", progress);

    if ([self.delegate respondsToSelector:@selector(scrollLyricView:withProgress:)]) {
        [self.delegate scrollLyricView:self withProgress:progress];
    }
}

#pragma mark - setter & getter -> 显示歌词

- (void)setLyrics:(NSArray *)lyrics {
    _lyrics = lyrics;

    // 先移除所有label (上一曲的)
    [self.vScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // 添加歌词label到vScrollView (本曲)
    for (NSInteger i = 0; i < lyrics.count; i++) {
        //
        HBLyricModel *lyric = lyrics[i];
        HBLyricColorLabel *lyricLbl = [[HBLyricColorLabel alloc] init];
        lyricLbl.text = lyric.content;
        lyricLbl.textColor = [UIColor whiteColor];
        lyricLbl.font = [UIFont systemFontOfSize:13.0];
        [self.vScrollView addSubview:lyricLbl];

        [lyricLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.vScrollView);
            make.top.mas_equalTo(self.vScrollView).offset(_rowHeight * i);
            make.height.mas_equalTo(self.rowHeight);
        }];
    }

    // 设置vScrollView的显示内容范围
    self.vScrollView.contentSize = CGSizeMake(self.vScrollView.bounds.size.width, self.rowHeight * lyrics.count);
}

- (CGFloat)rowHeight {
    if (!_rowHeight) {
        _rowHeight = 30;
    }
    return _rowHeight;
}

@end
