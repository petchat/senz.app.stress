//
//  CircleProgressView.h
//  Stress
//
//  Created by FLYing on 16/1/7.
//  Copyright © 2016年 FLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleProgressView : UIControl

@property (nonatomic) NSTimeInterval elapsedTime;

@property (nonatomic) NSTimeInterval timeLimit;

@property (nonatomic, retain) NSString *status;

@property (assign, nonatomic, readonly) double percent;

@end
