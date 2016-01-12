//
//  ViewController.m
//  Stress
//
//  Created by FLYing on 16/1/5.
//  Copyright © 2016年 FLY. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MonitorController.h"
#import "Session.h"
#import <AVOSCloud/AVOSCloud.h>
#import <GPUImage/GPUImage.h>
#import <AFSoundManager.h>

@interface ViewController ()
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    MonitorController *monitorController;
}

@property (strong,nonatomic) NSTimer *timer;
@property (nonatomic) Session *session;
@property (nonatomic,strong) AFSoundPlayback *playback;
@property (nonatomic,strong) AFSoundQueue *queue;
@property (nonatomic,strong) NSMutableArray *item;
@property (nonatomic,strong) NSMutableArray *rateList;


@property (strong, nonatomic) IBOutlet UIButton *measureBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UILabel *guideLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //view background
    self.view.backgroundColor = [UIColor whiteColor];

    //monitor peaked
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peaked:) name:@"peaked" object:nil];
    //Setup heartRateMonitorController
    monitorController = [MonitorController getInstance];

    //set session
    self.session = [[Session alloc]init];
    self.session.state = kSessionStateStop;

    self.circleProgressView.status = @"not started";
    self.circleProgressView.elapsedTime = 0;
    
     
    //set actionButton
    [_measureBtn setTintColor:[UIColor lightTextColor]];
    
    //init ViedoCamera
    [self initViedoCamera];
    
    //init Sounds
    [self initSounds];
    
    //set startTimer
    [self startTimer];
    
    [_measureBtn setExclusiveTouch:YES];
    _playBtn.hidden=YES;
    _guideLabel.hidden=YES;
    [_playBtn setExclusiveTouch:YES];
}

//init VideoCamera for measure
- (void)initViedoCamera {
    
    
    // Setup video camera
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    // Setup average color filter
    GPUImageAverageColor *averageColor = [[GPUImageAverageColor alloc] init];
    [averageColor setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime){
        [monitorController update:redComponent greenComponent:greenComponent blueComponent:blueComponent];
    }];
    
    
    // Setup exposure filter, using max value to reduce noise
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
    [exposureFilter setExposure:8.0];
    
    // Apply average color filter to exposure filter
    [exposureFilter addTarget:averageColor];
    
    filter = exposureFilter;
    
    [videoCamera addTarget:filter];
}

//init mindfulness Sounds
- (void)initSounds {
    
    AFSoundItem *item1 = [[AFSoundItem alloc]initWithLocalResource:@"demo1.mp3" atPath:nil];
    AFSoundItem *item2 = [[AFSoundItem alloc]initWithLocalResource:@"demo2.mp3" atPath:nil];
    AFSoundItem *item3 = [[AFSoundItem alloc]initWithLocalResource:@"demo3.mp3" atPath:nil];
    AFSoundItem *item4 = [[AFSoundItem alloc]initWithLocalResource:@"demo4.mp3" atPath:nil];
    AFSoundItem *item5 = [[AFSoundItem alloc]initWithLocalResource:@"demo5.mp3" atPath:nil];
    
    _item = [NSMutableArray arrayWithObjects:item1,item2,item3,item4,item5, nil];
    _queue = [[AFSoundQueue alloc]initWithItems:_item];
    [_queue pause];

}


- (void) viewDidDisappear:(BOOL)animated{
    [self turnTorchOn:NO];
    [self.timer invalidate];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Timer

- (void)startTimer {
    if ((!self.timer) || (![self.timer isValid])) {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.00
                                                      target:self
                                                    selector:@selector(poolTimer)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)poolTimer
{
    if ((self.session) && (self.session.state == kSessionStateStart))
    {
        self.circleProgressView.elapsedTime = self.session.progressTime;
    }
}

#pragma mark - User Interaction

- (IBAction)playMusic:(id)sender {
    if (self.session.state == kSessionStateStop) {
    
        [_queue playCurrentItem];
    
        NSLog(@"queue.duration = %ld",(long)_queue.getCurrentItem.duration);
    
        self.session.startDate = [NSDate date];
        self.session.finishDate = nil;
        self.session.state = kSessionStateStart;

        UIColor *tintColor = [UIColor colorWithRed:46/255.0 green:188/255.0 blue:228/255.0 alpha:1.0];
        self.circleProgressView.timeLimit = _queue.getCurrentItem.duration;
        self.circleProgressView.status = @"in progress";
        self.circleProgressView.tintColor = tintColor;
        self.circleProgressView.elapsedTime = 0;

        NSLog(@"elapsedTime = %f,progressTime = %f,timeLimit = %f,finishDate = %@",self.circleProgressView.elapsedTime,self.session.progressTime,self.circleProgressView.timeLimit,self.session.finishDate);

        
        [_queue listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
            NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
            if (item.timePlayed >= item.duration-1){
                _playBtn.hidden = YES;
                _measureBtn.hidden =NO;
                self.stressNum.text = @"再次测量压力";
                [_queue pause];
            }else {
                _playBtn.hidden = YES;
            }
        
        } andFinishedBlock:^(AFSoundItem *nextItem) {
        
            NSLog(@"Finished item, next one is %@", nextItem.title);
        }];
//        [_playBtn setTitle:@"Stop" forState:UIControlStateNormal];
        self.stressNum.text = @"请带上耳机";
//        [_playBtn setTitle:@"" forState:UIControlStateNormal];
        
    }
    else {
        [_queue pause];
        
        self.session.finishDate = [NSDate date];
        self.session.state = kSessionStateStop;
        
        NSLog(@"session.progressTime = %f",self.session.progressTime);
        self.circleProgressView.status = @"not started";
        self.circleProgressView.tintColor = [UIColor blackColor];
        self.circleProgressView.elapsedTime = self.session.progressTime;
        
        [_playBtn setTitle:@"重听" forState:UIControlStateNormal];
    }
    
}


- (IBAction)measureStress:(id)sender {

    self.stressNum.text = @"Senz";
    
    [videoCamera startCameraCapture];
    [self turnTorchOn:YES];

    //set circleProgressView
    self.circleProgressView.status = @"not started";
    self.circleProgressView.timeLimit = 15;
    self.circleProgressView.elapsedTime = 0;

    self.session.startDate = [NSDate date];
    self.session.finishDate = nil;
    self.session.state = kSessionStateStart;

    UIColor *tintColor = [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0];
    self.circleProgressView.status = @"in progress";
    self.circleProgressView.tintColor = tintColor;
    self.circleProgressView.elapsedTime = 0;

    NSLog(@"elapsedTime = %f,progressTime = %f,timeLimit = %f,finishDate = %@",self.circleProgressView.elapsedTime,self.session.progressTime,self.circleProgressView.timeLimit,self.session.finishDate);
    
    _measureBtn.hidden = YES;
    _guideLabel.numberOfLines = 3;
    _guideLabel.hidden = NO;
    
}
/*
    else if(self.session.state == kSessionStateStart && self.circleProgressView.percent < 1) {
        [videoCamera stopCameraCapture];
        
        
        self.session.finishDate = [NSDate date];
        self.session.state = kSessionStateStop;
        
        self.circleProgressView.status = @"not started";
        self.circleProgressView.tintColor = [UIColor blackColor];
        self.circleProgressView.elapsedTime = self.session.progressTime;
        
        NSLog(@"elapsedTime = %f,progressTime = %f,timeLimit = %f,finishDate = %@",self.circleProgressView.elapsedTime,self.session.progressTime,self.circleProgressView.timeLimit,self.session.finishDate);
        
        [self turnTorchOn:NO];
        
        [_measureBtn setTitle:@"Restart" forState:UIControlStateNormal];
        [_measureBtn setTintColor:[UIColor whiteColor]];
    }
 */


- (void) turnTorchOn:(BOOL) on {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]) {
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            }else{
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}


-(void) peaked : (NSNotification *) notif
{
    NSNumber *rate = (NSNumber *)notif.object;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.stressNum.text = [[NSString alloc]initWithFormat:@"压力值：%.0f",[rate doubleValue]*2/3];
        _guideLabel.hidden= YES;
        _playBtn.hidden=NO;
        [_playBtn setUserInteractionEnabled:NO];

        
//        self.session.state = kSessionStateStop;
        
//        self.circleProgressView.status = @"not started";

        NSLog(@"%@",self.stressNum.text);
    }];
    while (self.circleProgressView.percent ==1 ) {
        [self turnTorchOn:NO];
        [videoCamera stopCameraCapture];
        [_playBtn setUserInteractionEnabled:YES];
        
        if (self.session.state == kSessionStateStart) {
            self.session.finishDate = [NSDate date];
            self.session.state = kSessionStateStop;
        }
        if ([self.circleProgressView.status  isEqual: @"in progress"]) {
            self.circleProgressView.status = @"not started";
            self.circleProgressView.tintColor = [UIColor blackColor];
            self.circleProgressView.elapsedTime =0;
        }

        /*
        self.session.finishDate = [NSDate date];
        self.session.state = kSessionStateStop;
        
        self.circleProgressView.status = @"not started";
        self.circleProgressView.tintColor = [UIColor blackColor];
        self.circleProgressView.elapsedTime = self.session.progressTime;
         */
    }

}


@end
