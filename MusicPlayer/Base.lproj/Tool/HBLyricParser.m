//
//  HBLyricParser.m
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "HBLyricParser.h"
#import "HBLyricModel.h"

@implementation HBLyricParser

+ (NSArray *)parserLyricWithFileName:(NSString *)fileName {
// 目标: 截取时间和歌词内容

    // 1. 加载歌词文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *lyricStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    // 2. 截取每行歌词
    NSArray *lineStrs = [lyricStr componentsSeparatedByString:@"\n"];

    // 3. 遍历每行歌词
    for (NSString *lineStr in lineStrs) {
        NSLog(@"%@", lineStr);
        // [04:08.00][03:29.00][01:33.00]她似这月儿仍然是不开口
    }

    // 4. 正则表达式

    // 5. 获取歌词内容

    // 6. 获取时间

    // 7. 按时间排序

    return nil;
}

@end
