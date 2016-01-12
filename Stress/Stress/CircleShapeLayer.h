//
//  CircleShapeLayer.h
//  Stress
//
//  Created by FLYing on 16/1/7.
//  Copyright © 2016年 FLY. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CircleShapeLayer : CAShapeLayer

@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) NSTimeInterval timeLimit;
@property (assign, nonatomic, readonly) double percent;
@property (nonatomic) UIColor *progressColor;

@end
