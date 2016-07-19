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
#import "HBSliderView.h"

@interface HBLyricView ()<UIScrollViewDelegate>

/// 横向滚动的ScrollView, 切换界面
@property (nonatomic, strong) UIScrollView *hScrollView;
/// 竖向滚动的ScrollView, 显示歌词
@property (nonatomic, strong) UIScrollView *vScrollView;
/// 歌词界面滚动时的视图
@property (nonatomic, strong) HBSliderView *sliderView;

@end

@implementation HBLyricView

@synthesize currentLyricIdx = _currentLyricIdx;   // 用@property声明的成员属性,相当于自动生成了setter和getter方法. 重写了set和get方法,与@property声明的成员属性就不是一个成员属性了,是另外一个实例变量,而这个实例变量(_currentLyricIdx)需要手动声明

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

    // 约束
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

    // 3. sliderView
    HBSliderView *sliderView = [[HBSliderView alloc] init];
    sliderView.hidden = YES;  // 默认隐藏
    [self addSubview:sliderView];   // 为什么添加到self.vScrollView上时无效??!
    self.sliderView = sliderView;

    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.mas_equalTo(self.vScrollView); 
        make.height.mas_equalTo(self.rowHeight);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // 设置显示内容
    self.hScrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
    // 设置额外显示区域
    CGFloat top = (self.bounds.size.height - self.rowHeight) * 0.5;
    CGFloat bottom = top;
    self.vScrollView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);    // 开头和结尾时歌词能够位于中央
    self.vScrollView.contentOffset = CGPointMake(0, -top);                  // 一开始就滚动到中央
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.hScrollView) {
        [self hScrollViewDidScroll];
    } else if (scrollView == self.vScrollView) {
        [self vScrollViewDidScroll];
    }
}

// MARK: - sliderView相关
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.vScrollView) {
        self.sliderView.hidden = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.vScrollView) {
        // 延迟2s隐藏, 让用户有时间点击按钮
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 正在拖拽时不要隐藏滚动条
            if (scrollView.isDragging == YES) {
                return;
            }
            // 隐藏
            self.sliderView.hidden = YES;
        });
    }
}

- (void)vScrollViewDidScroll {
    NSInteger index = self.vScrollView.contentOffset.y + self.vScrollView.contentInset.top / self.rowHeight;

    // 设置当前滚动行的显示时间
    HBLyricModel *lyric = self.lyrics[index];
    self.sliderView.selectedTime = lyric.time;
}

- (void)hScrollViewDidScroll {
    CGFloat progress = self.hScrollView.contentOffset.x / self.bounds.size.width;
//    NSLog(@"%f", progress);

    if ([self.delegate respondsToSelector:@selector(scrollLyricView:withProgress:)]) {
        [self.delegate scrollLyricView:self withProgress:progress];
    }
}

#pragma mark - setter & getter -> 显示歌词相关

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
        _rowHeight = 30.0;
    }
    return _rowHeight;
}

/* index 58 beyond bounds [0 .. 57] */
- (NSInteger)currentLyricIdx {
    if (_currentLyricIdx < 0) {
        _currentLyricIdx = 0;
    } else if (_currentLyricIdx > self.lyrics.count - 1) {
        _currentLyricIdx = self.lyrics.count - 1;
    }
    return _currentLyricIdx;
}

- (void)setCurrentLyricIdx:(NSInteger)currentLyricIdx {

    // 3. 播放之后的恢复原值
    HBLyricColorLabel *playedLyricLbl = self.vScrollView.subviews[self.currentLyricIdx];
    playedLyricLbl.font = [UIFont systemFontOfSize:13.0];
    playedLyricLbl.progress = 0;

    _currentLyricIdx = currentLyricIdx;

    // 1. 自动向上滚动 -- 即修改contentOffset的y值
    CGFloat offsetY = self.rowHeight * self.currentLyricIdx - self.vScrollView.contentInset.top;
    self.vScrollView.contentOffset = CGPointMake(0, offsetY);
    // 2. 当前播放字体变大
    HBLyricColorLabel *lyricLbl = self.vScrollView.subviews[currentLyricIdx];
    lyricLbl.font = [UIFont systemFontOfSize:17.0];
}

- (void)setProgress:(NSInteger)progress {
    _progress = progress;

    // 仅当前播放改变颜色
    HBLyricColorLabel *lyricLbl = self.vScrollView.subviews[self.currentLyricIdx];
    lyricLbl.progress = progress;
}

@end
