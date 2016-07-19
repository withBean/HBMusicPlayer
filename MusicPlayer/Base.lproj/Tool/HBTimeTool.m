//
//  HBTimeTool.m
//  MusicPlayer
//
//  Created by Beans on 16/7/20.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "HBTimeTool.h"

@implementation HBTimeTool

+ (NSString *)stringWithTimeInterval:(NSTimeInterval)timeInterval {
    int minute = timeInterval / 60;
    int second = (int)timeInterval % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minute, second];
}

@end
