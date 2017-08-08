//
//  YAWaveView.h
//  Wave
//
//  Created by Jaime on 2017/3/15.
//  Copyright © 2017年 Yaso. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YAWaveView;
@protocol YAWaveViewDelegate <NSObject>

@optional
//自定义背景渐变
- (void)drawBgGradient:(YAWaveView*)waveView context:(CGContextRef)context;
@end

@interface YAWaveView : UIView

@property (nonatomic, assign) CGFloat percent;           // 百分比      默认:0
@property (nonatomic, assign) CGFloat waveAmplitude;     // 波纹振幅     默认:0
@property (nonatomic, assign) CGFloat waveCycle;         // 波纹周期     默认:1.29 * M_PI / self.frame.size.width
@property (nonatomic, assign) CGFloat waveSpeed;         // 波纹速度     默认:0.2/M_PI
@property (nonatomic, assign) CGFloat waveGrowth;        // 波纹上升速度  默认:1.00
@property (nonatomic, assign) BOOL isRound;              // 圆形/方形    默认:YES

@property (nonatomic, strong) NSArray *colors;   // 渐变的颜色数组1
@property (nonatomic, strong) NSArray *sColors;  // 渐变的颜色数组2

@property (nonatomic, weak) id<YAWaveViewDelegate>delegate;


// 开始波浪
- (void)startWave;
// 停止波动
- (void)stopWave;
// 继续波动
- (void)goOnWave;
// 清空波浪
- (void)reset;
@end
