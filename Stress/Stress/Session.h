//
//  Session.h
//  Stress
//
//  Created by FLYing on 16/1/7.
//  Copyright © 2016年 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSessionStateStart = 0,
    kSessionStateStop = 1
} SessionState;

@interface Session : NSObject
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, readonly) NSTimeInterval progressTime;
@property (nonatomic) SessionState state;

@end
