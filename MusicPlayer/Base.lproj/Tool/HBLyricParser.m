//
//  HBLyricParser.m
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import "HBLyricParser.h"
#import "NSDateFormatter+shared.h"
#import "HBLyricModel.h"

@implementation HBLyricParser

+ (NSArray *)parserLyricWithFileName:(NSString *)fileName {
    // 目标: 截取时间和歌词内容

    NSMutableArray *arrM = [NSMutableArray array];

    // 1. 加载歌词文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *lyricStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    // 2. 截取每行歌词
    NSArray *lineStrs = [lyricStr componentsSeparatedByString:@"\n"];

    // 4.1 正则表达格式
    NSString *pattern = @"\\[[0-9]{2}:[0-9]{2}.[0-9]{2}\\]";
    // 4.2 正则表达对象
    NSRegularExpression *regularExp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];

    // 3. 遍历每行歌词
    for (NSString *lineStr in lineStrs) {
//        NSLog(@"%@", lineStr);  // [02:25.00][00:29.00]仍然听见小提琴如泣似诉再挑逗

        // 4. 正则表达式
        // 4.3 匹配正则的内容
        NSArray *results = [regularExp matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];

        // 5. 获取歌词内容
        // 5.1 获取匹配的最后一个结果
        NSTextCheckingResult *lastResult = [results lastObject];
        // 5.2 截取歌词内容
        NSString *content = [lineStr substringFromIndex:lastResult.range.location + lastResult.range.length];
//        NSLog(@"%@", content);  // 仍然听见小提琴如泣似诉再挑逗

        // 6. 获取时间
        for (NSTextCheckingResult *result in results) {
            // 6.1 获取每一个时间字符串
            NSString *timeStr = [lineStr substringWithRange:result.range];
//            NSLog(@"%@", timeStr);  // [00:23.00]

            // 6.2 将字符串转换成NSTimeInterval
//            NSDateFormatter *dateF = [[NSDateFormatter alloc] init];    // NSDateFormatter本来性能就不好, 且forin多层嵌套, 考虑为单例以优化性能
            // 单例模式优化性能
            NSDateFormatter *dateFormatter = [NSDateFormatter sharedDateFormatter];
            // 转换为NSDate
            dateFormatter.dateFormat = @"[mm:ss.SS]";   // ∵timeStr中含`[]`
            NSDate *timeDate = [dateFormatter dateFromString:timeStr];
            NSDate *initDate = [dateFormatter dateFromString:@"[00:00.00]"];
            // 比较时间, 转为NSTimeInterval
            NSTimeInterval time = [timeDate timeIntervalSinceDate:initDate];
//            NSLog(@"%f", time);

            // 给模型赋值并添加到数组
            HBLyricModel *lyric = [[HBLyricModel alloc] init];
            lyric.content = content;
            lyric.time = time;
            [arrM addObject:lyric];
        }
    }

    // 7. 按时间排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    [arrM sortUsingDescriptors:@[sort]];
    for (HBLyricModel *lyric in arrM) {
        NSLog(@"%f %@", lyric.time, lyric.content);
    }

    return arrM;
}

@end
