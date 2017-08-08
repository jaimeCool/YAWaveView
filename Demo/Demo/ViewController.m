//
//  ViewController.m
//  Demo
//
//  Created by Jaime on 2017/8/5.
//  Copyright © 2017年 Yaso. All rights reserved.
//

#import "ViewController.h"
#import "YAWaveView.h"
@interface ViewController () <YAWaveViewDelegate> {
    YAWaveView *_wave;
    YAWaveView *_rectWave;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupUI {
    NSArray *colors = @[(__bridge id)[UIColor colorWithRed:134/255.0 green:208/255.0 blue:248/255.0 alpha:0.75].CGColor, (__bridge id)[UIColor whiteColor].CGColor];  //里
    NSArray *sColors = @[(__bridge id)[UIColor colorWithRed:166/255.0 green:240/255.0 blue:255/255.0 alpha:0.5].CGColor, (__bridge id)[UIColor colorWithRed:240/255.0 green:250/255.0 blue:255/255.0 alpha:0.5].CGColor];  //外

    
    //默认圆形波浪
    CGFloat waveWidth = 160;
    _wave = [[YAWaveView alloc]initWithFrame:CGRectMake(100, 100, waveWidth, waveWidth)];
    [self.view addSubview:_wave];
    _wave.layer.cornerRadius = waveWidth/2;
    _wave.clipsToBounds = YES;
    _wave.colors = colors;
    _wave.sColors = sColors;
    _wave.percent = 0.7;
    [_wave startWave];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    startBtn.frame = CGRectMake(80, 300, 50, 40);
    [startBtn setTitle:@"start" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    resetBtn.frame = CGRectMake(220, 300, 50, 40);
    [resetBtn setTitle:@"reset" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pauseBtn.frame = CGRectMake(80, 360, 50, 40);
    [pauseBtn setTitle:@"stop" forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseBtn];
    
    UIButton *goOnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    goOnBtn.frame = CGRectMake(220, 360, 50, 40);
    [goOnBtn setTitle:@"go on" forState:UIControlStateNormal];
    [goOnBtn addTarget:self action:@selector(goOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goOnBtn];
    
    
    //自定义背景渐变-圆形波浪
    YAWaveView *customWave = [[YAWaveView alloc]initWithFrame:CGRectMake(10, 420, waveWidth, waveWidth)];
    [self.view addSubview:customWave];
    customWave.layer.cornerRadius = waveWidth/2;
    customWave.clipsToBounds = YES;
    customWave.colors = colors;
    customWave.sColors = sColors;
    customWave.percent = 0.4;
    customWave.delegate = self;
    [customWave startWave];

    
    //方形波浪
    _rectWave = [[YAWaveView alloc]initWithFrame:CGRectMake(200, 560, 140, 100)];
    [self.view addSubview:_rectWave];
    _rectWave.colors = colors;
    _rectWave.sColors = sColors;
    _rectWave.percent = 0.7;
    _rectWave.delegate = self;
    [_rectWave startWave];
}

- (void)startClicked:(id)sender {
    [_wave startWave];
}

- (void)resetClicked:(id)sender {
    [_wave reset];
    [_rectWave reset];
}

- (void)stopClicked:(id)sender {
    [_wave stopWave];
}

- (void)goOnClicked:(id)sender {
    [_wave goOnWave];
}


//自定义背景渐变
- (void)drawBgGradient:(YAWaveView *)waveView context:(CGContextRef)context {
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGFloat compoents[8]={
        1.0,1.0,1.0,1.0,
        166/255.0,240/255.0,255.0/255.0,1
    };
    
    CGFloat locations[2]={0,0.7};
    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, compoents, locations, 2);
    
    CGFloat width = CGRectGetWidth(waveView.frame);
    CGFloat height = CGRectGetHeight(waveView.frame);
    CGPoint center = CGPointMake(width/2, height/2);
    
    if (waveView == _rectWave) {
        //线性渐变
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(width, height), kCGGradientDrawsAfterEndLocation);
    } else {
        //径向渐变
        CGContextDrawRadialGradient(context, gradient, center,0, center, width/2, kCGGradientDrawsAfterEndLocation);
    }
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}
@end
