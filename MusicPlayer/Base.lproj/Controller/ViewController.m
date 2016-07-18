//
//  ViewController.m
//  MusicPlayer
//
//  Created by Beans on 16/7/17.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "ViewController.h"

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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play {
}

- (IBAction)previous {
}

- (IBAction)next {
}

- (IBAction)sliderValueChange {
}

@end
