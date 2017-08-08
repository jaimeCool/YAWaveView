//
//  YAWaveView.m
//  Wave
//
//  Created by Jaime on 2017/3/15.
//  Copyright © 2017年 Yaso. All rights reserved.
//

#import "YAWaveView.h"


@interface YAWaveView ()

@property (nonatomic, strong) CADisplayLink *waveDisplaylink;

@property (nonatomic, strong) CAShapeLayer  *firstWaveLayer;    //里层
@property (nonatomic, strong) CAShapeLayer  *secondWaveLayer;   //外层

@property (nonatomic, strong) CAGradientLayer *gradientLayer;   // 绘制渐变1
@property (nonatomic, strong) CAGradientLayer *sGradientLayer;  // 绘制渐变2
@end

@implementation YAWaveView{
    
    CGFloat waterWaveWidth;     // 宽度
    CGFloat offsetX;            // 波浪x位移
    CGFloat currentWavePointY;  // 当前波浪上升高度Y
    
    CGFloat kExtraHeight;       // 保证水波波峰不被裁剪，增加部分额外的高度
    float variable;             // 可变参数 更加真实 模拟波纹
    BOOL increase;              // 增减变化
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds  = YES;
        [self initial];
    }
    
    return self;
}

- (void)initial {
    self.percent = 0;
    self.waveAmplitude = 0;
    self.waveGrowth = 1.00;
    self.waveSpeed = 0.2/M_PI;
    
    waterWaveWidth  = CGRectGetWidth(self.frame);
    if (waterWaveWidth > 0) {
        self.waveCycle =  1.29 * M_PI / waterWaveWidth;
    }
    
    [self resetProperty];
}

- (void)resetProperty {
    currentWavePointY = CGRectGetHeight(self.frame) * self.percent;
    
    offsetX = 0;
    variable = 1.6;
    increase = NO;
    
    kExtraHeight = 0;
    if (_percent>0 && _percent<1) {
        kExtraHeight = 10;
    }
}

- (void)setPercent:(CGFloat)percent {
    _percent = percent;
    currentWavePointY = CGRectGetHeight(self.frame) * self.percent;
    if (_percent>0 && _percent<1) {
        kExtraHeight = 10;
    }
}

//开始绘制
-(void)startWave {
    
    if (_firstWaveLayer == nil) {
        // 创建第一个波浪Layer
        _firstWaveLayer = [CAShapeLayer layer];
    }
    
    if (_secondWaveLayer == nil) {
        // 创建第二个波浪Layer
        _secondWaveLayer = [CAShapeLayer layer];
    }
    
    // 添加渐变layer
    if (self.gradientLayer) {
        [self.gradientLayer removeFromSuperlayer];
        self.gradientLayer = nil;
    }
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = [self gradientLayerFrame];
    [self.gradientLayer setMask:_firstWaveLayer];
    [self.layer addSublayer:self.gradientLayer];
    
    if (self.sGradientLayer) {
        [self.sGradientLayer removeFromSuperlayer];
        self.sGradientLayer = nil;
    }
    self.sGradientLayer = [CAGradientLayer layer];
    self.sGradientLayer.frame = [self gradientLayerFrame];
    [self.sGradientLayer setMask:_secondWaveLayer];
    [self.layer addSublayer:self.sGradientLayer];
    
    //设置渐变layer相关属性
    [self setupGradientColor];
    
    if (_waveDisplaylink) {
        [self stopWave];
    }
    
    // 启动定时调用
    _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (CGRect)gradientLayerFrame
{
    // gradientLayer在上升完成之后的frame值，如果gradientLayer在上升过程中不断变化frame值会导致一开始绘制卡顿，所以只进行一次赋值
    
    CGFloat gradientLayerHeight = CGRectGetHeight(self.frame) * self.percent + kExtraHeight;
    
    if (gradientLayerHeight > CGRectGetHeight(self.frame))
    {
        gradientLayerHeight = CGRectGetHeight(self.frame);
    }
    
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.frame) - gradientLayerHeight, CGRectGetWidth(self.frame), gradientLayerHeight);
    return frame;
}

- (void)setupGradientColor
{
    // gradientLayer设置渐变色
    if ([self.colors count] < 1) self.colors = [self defaultColors];
    if ([self.sColors count] < 1) self.sColors = [self defaultColors];
    
    self.gradientLayer.colors = self.colors;
    self.sGradientLayer.colors = self.sColors;
    
    //设定颜色分割点
    NSInteger count = [self.colors count];
    CGFloat d = 1.0 / count;
    
    NSMutableArray *locations = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++)
    {
        NSNumber *num = @(d + d * i);
        [locations addObject:num];
    }
    NSNumber *lastNum = @(1.0f);
    [locations addObject:lastNum];
    
    self.gradientLayer.locations = locations;
    self.sGradientLayer.locations = locations;
    
    // 设置渐变方向，从上往下
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(0, 1);
    
    self.sGradientLayer.startPoint = CGPointMake(0, 0);
    self.sGradientLayer.endPoint = CGPointMake(0, 1);
}

- (NSArray *)defaultColors
{
    // 默认的渐变色
    UIColor *color0 = [UIColor colorWithRed:166 / 255.0 green:240 / 255.0 blue:255 / 255.0 alpha:0.5];
    UIColor *color1 = [UIColor colorWithRed:240 / 255.0 green:250 / 255.0 blue:255 / 255.0 alpha:0.5];
    
    NSArray *colors = @[(__bridge id)color0.CGColor, (__bridge id)color1.CGColor];
    return colors;
}

-(void)getCurrentWave:(CADisplayLink *)displayLink {
    
    [self animateWave];
    
    if (![self waveFinished]) {
        currentWavePointY -= self.waveGrowth;
    }
    
    // 波浪位移
    offsetX += self.waveSpeed;
    
    [self setCurrentFirstWaveLayerPath];
    
    [self setCurrentSecondWaveLayerPath];
}


-(void)setCurrentFirstWaveLayerPath {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <=  waterWaveWidth ; x++) {
        // 正弦波浪公式
        y = self.waveAmplitude * sin(self.waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _firstWaveLayer.path = path;
    CGPathRelease(path);
}

-(void)setCurrentSecondWaveLayerPath {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <=  waterWaveWidth ; x++) {
        // 余弦波浪公式
        y = self.waveAmplitude * cos(self.waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _secondWaveLayer.path = path;
    CGPathRelease(path);
}

- (void)animateWave {
    if (increase) {
        variable += 0.01;
    }else{
        variable -= 0.01;
    }
    
    
    if (variable<=1) {
        increase = YES;
    }
    
    if (variable>=1.6) {
        increase = NO;
    }
    
    // 可变振幅
    self.waveAmplitude = variable*3;
}


- (BOOL)waveFinished {
    // 波浪上升动画是否完成
    CGFloat d = CGRectGetHeight(self.frame) - CGRectGetHeight(self.gradientLayer.frame);
    CGFloat extraH = MIN(d, kExtraHeight);
    BOOL bFinished = currentWavePointY <= extraH;
    
    return bFinished;
}

-(void)stopWave {
    [_waveDisplaylink invalidate];
    _waveDisplaylink = nil;
}

- (void)goOnWave {
    if (_waveDisplaylink) {
        [self stopWave];
    }
    
    // 启动定时调用
    _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)reset {
    [self stopWave];
    [self resetProperty];
    
    [_firstWaveLayer removeFromSuperlayer];
    _firstWaveLayer = nil;
    [_secondWaveLayer removeFromSuperlayer];
    _secondWaveLayer = nil;
    
    [_gradientLayer removeFromSuperlayer];
    _gradientLayer = nil;
    [_sGradientLayer removeFromSuperlayer];
    _sGradientLayer = nil;
}

- (void)dealloc {
    [self reset];
}


#pragma mark 背景渐变

- (void)drawRect:(CGRect)rect {
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBgGradient:context:)]) {
        [self.delegate drawBgGradient:self context:context];
    } else {
        //默认径向渐变
        [self drawRadialGradient:context];
    }
    
}

-(void)drawRadialGradient:(CGContextRef)context{
    //使用rgb颜色空间
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    
    /*指定渐变色
     space:颜色空间
     components:颜色数组,注意由于指定了RGB颜色空间，那么四个数组元素表示一个颜色（red、green、blue、alpha），
     如果有三个颜色则这个数组有4*3个元素
     locations:颜色所在位置（范围0~1），这个数组的个数不小于components中存放颜色的个数
     count:渐变个数，等于locations的个数
     */
    CGFloat compoents[8]={
        1.0,1.0,1.0,1.0,
        241.0/255.0,251.0/255.0,255.0/255.0,1
    };
    
    CGFloat locations[2]={0,0.4};
    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, compoents, locations, 2);
    
    /*绘制径向渐变
     context:图形上下文
     gradient:渐变色
     startCenter:起始点位置
     startRadius:起始半径（通常为0，否则在此半径范围内容无任何填充）
     endCenter:终点位置（通常和起始点相同，否则会有偏移）
     endRadius:终点半径（也就是渐变的扩散长度）
     options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，但是到结束位置之后不再绘制，
     kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，但到结束点之后继续填充
     */
    CGPoint center = CGPointMake(waterWaveWidth/2, waterWaveWidth/2);
    CGContextDrawRadialGradient(context, gradient, center,0, center, waterWaveWidth/2, kCGGradientDrawsAfterEndLocation);
    //释放颜色空间
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}
@end

