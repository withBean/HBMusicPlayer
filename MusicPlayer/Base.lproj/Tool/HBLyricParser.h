//
//  HBLyricParser.h
//  MusicPlayer
//
//  Created by Beans on 16/7/19.
//  Copyright © 2016年 iceWorks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBLyricParser : NSObject

+ (NSArray *)parserLyricWithFileName:(NSString *)fileName;

@end
