# YAWaveView

>一个渐变水波视图，水波视图相信大家已经司空见惯，但是最近视觉要求绘制一个波浪是渐变色的，且背景是径向渐变的水波，于是在原来的基础上做了相应改进。

**先来看下效果图：**

![渐变水波](http://upload-images.jianshu.io/upload_images/669742-9d5f8ee94182c712?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


**基本实现以下功能：**

- 支持自定义水波形状
- 支持自定义背景渐变
- 支持自定义两层水波独立渐变色
- 支持波纹周期、速度、振幅等自定义
·····

Demo见github [YAWaveView](https://github.com/jaimeCool/YAWaveView)，喜欢的话请star下^_^
### 使用说明

 YAWaveView 目前已经支持CocoaPods，可以在很短的时间内被添加到任何工程中。

#### 安装
YAWaveView 的安装，最简单的方法是使用CocoaPods，在PodFile里添加如下：
```
pod 'YAWaveView', '~> 0.0.1'
```
或者直接将```YAWaveView.h```和```YAWaveView.m```两个源文件直接拖进自己的项目工程中。

#### 集成
* 首先导入头文件
```
#import "YAWaveView.h"
```
* 遵循相应协议
```
@interface ViewController () <YAWaveViewDelegate> {
    YAWaveView *_wave;
    YAWaveView *_rectWave;
}
```
* 初始化
```
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
   
    //方形波浪
    _rectWave = [[YAWaveView alloc]initWithFrame:CGRectMake(200, 560, 140, 100)];
    [self.view addSubview:_rectWave];
    _rectWave.colors = colors;
    _rectWave.sColors = sColors;
    _rectWave.percent = 0.7;
    _rectWave.delegate = self;
```
* 开始绘制
```
 [_wave startWave];
 [_rectWave startWave];
```
* 实现相应协议
```
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
```

完成上述步骤，渐变水波已经集成到我们的项目中了，当然YAWaveView还提供了一系列的对外属性变量，使我们可以高度自定义水波，如下：

```
@property (nonatomic, assign) CGFloat percent;           // 百分比      默认:0
@property (nonatomic, assign) CGFloat waveAmplitude;     // 波纹振幅     默认:0
@property (nonatomic, assign) CGFloat waveCycle;         // 波纹周期     默认:1.29 * M_PI / self.frame.size.width
@property (nonatomic, assign) CGFloat waveSpeed;         // 波纹速度     默认:0.2/M_PI
@property (nonatomic, assign) CGFloat waveGrowth;        // 波纹上升速度  默认:1.00
@property (nonatomic, assign) BOOL isRound;              // 圆形/方形    默认:YES

@property (nonatomic, strong) NSArray *colors;   // 渐变的颜色数组1
@property (nonatomic, strong) NSArray *sColors;  // 渐变的颜色数组2
····
```

另外还提供了相关API控制水波
```
// 开始波浪
- (void)startWave;
// 停止波动
- (void)stopWave;
// 继续波动
- (void)goOnWave;
// 清空波浪
- (void)reset;
```
等等一系列，具体可参考```YAWaveView.h```