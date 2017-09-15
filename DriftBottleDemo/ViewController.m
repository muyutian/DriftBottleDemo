//
//  ViewController.m
//  漂流瓶   DriftBottleDemo
//
//  Created by zhangzy on 2017/9/14.
//  Copyright © 2017年 zhangzy. All rights reserved.
//

#import "ViewController.h"
#import <CoreGraphics/CoreGraphics.h>

#define BackGroundColor [UIColor colorWithRed:96/255.0f green:159/255.0f blue:150/255.0f alpha:1]
#define WaveColor1 [UIColor colorWithRed:190/255.0f green:227/255.0f blue:255/255.0f alpha:1]
#define WaveColor2 [UIColor colorWithRed:206/255.0 green:233/255.0 blue:255/255.0 alpha:1]

@interface ViewController (){
    //前面的波浪
    CAShapeLayer *_waveLayer1;
    CAShapeLayer *_waveLayer2;
    CALayer*_moveLayer;
    CALayer*_netLayer;
    
    CADisplayLink *_disPlayLink;
    
    //曲线的振幅
    CGFloat _waveAmplitude;
    //曲线角速度
    CGFloat _wavePalstance;
    //曲线初相
    CGFloat _waveX;
    //曲线偏距
    CGFloat _waveY;
    //曲线移动速度
    CGFloat _waveMoveSpeed;
    
    //水花
    CALayer*_waterLayer;
    BOOL _isWater;
    NSTimer*_timer;
    int _index;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
    [self buildData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

//初始化UI
-(void)buildUI
{
    //漂流瓶
    UIImageView*imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50,110)];
    imgView.image=[UIImage imageNamed:@"pingzi"];
    
    _moveLayer=[[CALayer alloc]init];
    _moveLayer.bounds=imgView.frame;
    _moveLayer.anchorPoint = CGPointMake(0, 0);
    _moveLayer.position=CGPointMake((self.view.bounds.size.width+50)/2, self.view.bounds.size.height);
    _moveLayer.affineTransform=CGAffineTransformMakeRotation(M_PI_4);
    _moveLayer.contents=(__bridge id _Nullable)(imgView.image.CGImage);
    [self.view.layer addSublayer:_moveLayer];
    
    //打捞时的网子
    UIImageView*netImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50,70)];
    imgView.image=[UIImage imageNamed:@"pingzi"];
    
    _netLayer=[[CALayer alloc]init];
    _netLayer.bounds=imgView.frame;
    _netLayer.anchorPoint = CGPointMake(0, 0);
    _netLayer.position=CGPointMake((self.view.bounds.size.width+50)/2, self.view.bounds.size.height);
    _netLayer.affineTransform=CGAffineTransformMakeRotation(M_PI_4);
    _netLayer.contents=(__bridge id _Nullable)(imgView.image.CGImage);
    _netLayer.hidden=YES;
    [self.view.layer addSublayer:_moveLayer];
    
    
    
    //初始化波浪
    //底层
    _waveLayer1 = [CAShapeLayer layer];
    _waveLayer1.fillColor = WaveColor1.CGColor;
    _waveLayer1.strokeColor = WaveColor1.CGColor;
    [self.view.layer addSublayer:_waveLayer1];
    
    //上层
    _waveLayer2 = [CAShapeLayer layer];
    _waveLayer2.fillColor = WaveColor2.CGColor;
    _waveLayer2.strokeColor = WaveColor2.CGColor;
    [self.view.layer addSublayer:_waveLayer2];
    
}

//初始化数据
-(void)buildData
{
    //振幅
    _waveAmplitude = 10;
    //角速度
    _wavePalstance = M_PI/self.view.bounds.size.width;
    //偏距
    _waveY = self.view.bounds.size.height;
    //初相
    _waveX = 0;
    //x轴移动速度
    _waveMoveSpeed = _wavePalstance * 10;
    //以屏幕刷新速度为周期刷新曲线的位置
    _disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateWave:)];
    [_disPlayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    _isWater=YES;
}
/**
 保持和屏幕的刷新速度相同，iphone的刷新速度是60Hz,即每秒60次的刷新
 */
-(void)updateWave:(CADisplayLink *)link
{
    //更新X
    _waveX += _waveMoveSpeed;
    if (_waveY>self.view.bounds.size.height/2) {
        _waveY-=5;
    }else{
        if (_moveLayer.position.y>self.view.bounds.size.height/2-70) {
            _moveLayer.position=CGPointMake(_moveLayer.position.x, _moveLayer.position.y-5);
        }else{
            _moveLayer.position=CGPointMake(_moveLayer.position.x, (_waveAmplitude * cos(_wavePalstance + _waveX) + _waveY)-70);
            [_timer invalidate];
        }
        if (_isWater) {
            //开启水花动画
            _index=0;
            [_timer invalidate];
            _timer=[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(addAnimation) userInfo:@"" repeats:YES];
            _isWater=NO;
        }
    }
    [self updateWave1];
    [self updateWave2];
}

//更新第一层曲线
-(void)updateWave1
{
    //波浪宽度
    CGFloat waterWaveWidth = self.view.bounds.size.width;
    //初始化运动路径
    CGMutablePathRef path = CGPathCreateMutable();
    //设置起始位置
    CGPathMoveToPoint(path, nil, 0, _waveY);
    //初始化波浪其实Y为偏距
    CGFloat y = _waveY;
    //正弦曲线公式为： y=Asin(ωx+φ)+k;
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        y = _waveAmplitude * cos(_wavePalstance * x + _waveX) + _waveY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    //填充底部颜色
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.view.bounds.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.view.bounds.size.height);
    CGPathCloseSubpath(path);
    _waveLayer1.path = path;
    CGPathRelease(path);
}

//更新第二层曲线
-(void)updateWave2
{
    //波浪宽度
    CGFloat waterWaveWidth = self.view.bounds.size.width;
    //初始化运动路径
    CGMutablePathRef path = CGPathCreateMutable();
    //设置起始位置
    CGPathMoveToPoint(path, nil, 0, _waveY);
    //初始化波浪其实Y为偏距
    CGFloat y = _waveY;
    //正弦曲线公式为： y=Asin(ωx+φ)+k;
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        y = _waveAmplitude * sin(_wavePalstance * x + _waveX) + _waveY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    //添加终点路径、填充底部颜色
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.view.bounds.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.view.bounds.size.height);
    CGPathCloseSubpath(path);
    _waveLayer2.path = path;
    CGPathRelease(path);
    
}

//水花动画
-(void)addAnimation{
    _index+=1;
    
    _waterLayer=[[CALayer alloc]init];
    _waterLayer.anchorPoint = CGPointMake(0, 0);
    _waterLayer.backgroundColor=[UIColor redColor].CGColor;
    UIImageView*imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30,30)];
    imgView.image=_index%2==0?[UIImage imageNamed:@""]:[UIImage imageNamed:@""];
    _waterLayer.position=CGPointMake((self.view.bounds.size.width-100)/2+arc4random_uniform(100), self.view.bounds.size.height/2);
    _waterLayer.bounds=imgView.frame;
    _waterLayer.contents=(__bridge id _Nullable)(imgView.image.CGImage);
    [self.view.layer addSublayer:_waterLayer];
    
    
    CGPoint fromCenter = _waterLayer.position;
    CGPoint endCenter =_index%2==0 ? CGPointMake(_waterLayer.position.x+60, _waterLayer.position.y) : CGPointMake(_waterLayer.position.x-60, _waterLayer.position.y);
    
    CGPoint controlPoint1 =_index%2==0 ? CGPointMake(_waterLayer.position.x+60/4, _waterLayer.position.y-90) : CGPointMake(_waterLayer.position.x-60/4*3, _waterLayer.position.y-90);
    CGPoint controlPoint2 =_index%2==0 ? CGPointMake(_waterLayer.position.x+60/4*3, _waterLayer.position.y-90) : CGPointMake(_waterLayer.position.x-60/4, _waterLayer.position.y-90);
    
    //抛物线路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:fromCenter];
    [path addCurveToPoint:endCenter controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    
    //旋转
//    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    rotateAnimation.removedOnCompletion = YES;
//    rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
//    rotateAnimation.toValue = [NSNumber numberWithFloat:10 * M_PI];
//    rotateAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //透明度
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.removedOnCompletion = NO;
    alphaAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    alphaAnimation.toValue = [NSNumber numberWithFloat:0];
    
    //组合动画
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[pathAnimation, alphaAnimation];
    groups.duration = 1.2;
    groups.removedOnCompletion=NO;
    groups.fillMode=kCAFillModeForwards;
    [_waterLayer addAnimation:groups forKey:@"group"];
}

#pragma mark - 动画停止

//停止动画
-(void)stop
{
    if (_disPlayLink) {
        [_disPlayLink invalidate];
        _disPlayLink = nil;
    }
}

//回收内存
-(void)dealloc
{
    [self stop];
    if (_waveLayer1) {
        [_waveLayer1 removeFromSuperlayer];
        _waveLayer1 = nil;
    }
    if (_waveLayer2) {
        [_waveLayer2 removeFromSuperlayer];
        _waveLayer2 = nil;
    }
}


@end
