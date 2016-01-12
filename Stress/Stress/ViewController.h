//
//  ViewController.h
//  Stress
//
//  Created by FLYing on 16/1/5.
//  Copyright © 2016年 FLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressView.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet CircleProgressView *circleProgressView;
@property (strong, nonatomic) IBOutlet UILabel *stressNum;


@end

