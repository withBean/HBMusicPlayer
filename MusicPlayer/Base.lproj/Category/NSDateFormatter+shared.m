//
//  NSDateFormatter+sharedInstance.m
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "NSDateFormatter+shared.h"

static NSDateFormatter *_dateFormatter;
@implementation NSDateFormatter (sharedInstance)

+ (instancetype)sharedDateFormatter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[self alloc] init];
    });
    return _dateFormatter;
}

@end
