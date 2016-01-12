//
//  Session.m
//  Stress
//
//  Created by FLYing on 16/1/7.
//  Copyright © 2016年 FLY. All rights reserved.
//

#import "Session.h"

@implementation Session

- (NSTimeInterval)progressTime {
    
    if (_finishDate) {
        return [_finishDate timeIntervalSinceDate:self.startDate];
    }
    else {
        return [[NSDate date] timeIntervalSinceDate:self.startDate];
    }
}
@end
