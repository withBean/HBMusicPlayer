//
//  HBLyricView.m
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "HBLyricView.h"
#import "Masonry.h"

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
    vScrollView.backgroundColor = [UIColor blueColor];
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
    self.hScrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, 0);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat progress = self.hScrollView.contentOffset.x / self.bounds.size.width;
    NSLog(@"%f", progress);

    if ([self.delegate respondsToSelector:@selector(scrollLyricView:withProgress:)]) {
        [self.delegate scrollLyricView:self withProgress:progress];
    }
}

@end
