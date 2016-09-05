//
//  HBPlayerView.m
//  MeiTuanDemo
//
//  Created by hebing on 16/6/2.
//  Copyright © 2016年 hebing. All rights reserved.
//

#import "HBPlayerView.h"
#import "UIView+HBFrame.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#define HBToolBarHeight 44
#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)
#define FX(view)    view.frame.origin.x
#define FY(view)    view.frame.origin.y
#define FW(view)    view.frame.size.width
#define FH(view)    view.frame.size.height
#define IMG(x)  [UIImage imageNamed:x]
#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
@interface HBPlayerView()
{
    CGRect mRect;
    id _timeReload;
}
/* 播放器 */
@property (nonatomic, strong) AVPlayer *player;

// 播放器的Layer
@property (weak, nonatomic) AVPlayerLayer *playerLayer;

/* playItem */
@property (nonatomic, weak) AVPlayerItem *currentItem;
//顶部工具栏
@property (nonatomic,strong) UIView *topToolBar;
//视频播放底部工具栏
@property (nonatomic,strong) UIView *bottomTooBar;
//视频标题
@property (nonatomic,strong) UILabel *titleLabel;
//返回按钮
@property (nonatomic,strong) UIButton *backButton;
//播放\暂停按钮
@property (nonatomic,strong) UIButton *playButton;
//全屏按钮
@property (nonatomic,strong) UIButton *switchFullScreenBtn;
//时间
@property (nonatomic,strong) UILabel *timeLabel;
//缓冲进度条
@property (nonatomic,strong) UIProgressView *progressView;
//进度条
@property (nonatomic,strong) UISlider *slider;
/*! 当前播放时间 */
@property (nonatomic,assign,readonly) CGFloat currentTime;

/*! 总播放时间 */
@property (nonatomic,assign,readonly) CGFloat totalTime;

//音量调节按钮
@property (nonatomic,strong) UISlider *volumeSlider;

@end
@implementation HBPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor=[UIColor blackColor];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        mRect=frame;
        
        [self initAVPlayer];//创建播放器

        [self creatVolumeSlider];
        

    }
    
    return self;
}
- (void)setType:(HBPlayerViewType)type
{
    _type=type;
    
    if (type==HBPlayerViewTypeVideo) {
        
        [self initVideoToolBar];
    }
    else
    {
        [self initLiveToolBar];
    }
}
#pragma mark 创建播放器
- (void)initAVPlayer
{
    _player = [[AVPlayer alloc]init];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.bounds;
    [self.layer addSublayer:_playerLayer];
    
}
- (void)addPlayerObserver
{
    // 监控状态属性(AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态)
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监控网络加载情况属性
    [self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // 监控是否可播放
    [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}
#pragma mark 添加通知
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    // 添加AVPlayerItem播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
#pragma mark 移除通知
- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)playBackFinished:(NSNotification *)noti
{
    
}
#pragma mark - ***** 通知
- (void)appwillResignActive:(NSNotification *)note
{
    if (self)
    {
        [self pause];
    }
    
}

- (void)appDidEnterBackground:(NSNotification*)note
{
    if (self)
    {
        [self pause];
    }
    
}

- (void)appWillEnterForeground:(NSNotification*)note
{
    if (self)
    {
        [self pause];
    }
    
}

- (void)appBecomeActive:(NSNotification *)note
{
    if (self)
    {
        [self continuePlay];
        
    }
}
- (void)playerItemDidReachEnd:(NSNotification *)note
{
    NSLog(@"完成了 。。。。知道么。。");
    
    if ([self.delegate respondsToSelector:@selector(VideoPlayCompleted)]) {
        
        [self.delegate VideoPlayCompleted];
    }
    
}
#pragma mark 移除KVO监控
- (void)removeObserver
{
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}
#pragma mark 通过KVO监控回调
/*! keyPath 监控属性 object 监视器 change 状态改变 context 上下文 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        
    }
    else if ([keyPath isEqualToString:@"rate"])
    {
        
    }
    else if ([keyPath isEqualToString:@"status"])
    {
        if ([self.currentItem status] == AVPlayerStatusReadyToPlay) {
            
            _currentTime=CMTimeGetSeconds(_player.currentTime);
            _totalTime=CMTimeGetSeconds([_player.currentItem duration]);
            
            [self addGesture];
            
        } else if ([self.currentItem status] == AVPlayerStatusFailed) {
            
            NSLog(@"播放失败");
        }
        else if ([self.currentItem status]==AVPlayerStatusUnknown)
        {
            NSLog(@"未知");
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        // 监控网络加载情况属性
        NSArray *array=_player.currentItem.loadedTimeRanges;
        
        // 本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
        CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
        // 现有缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        
        [_progressView setProgress:totalBuffer/_totalTime animated:NO];
    }
    
}
#pragma mark - 创建工具栏
- (void)initVideoToolBar
{
    self.topToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, HBToolBarHeight)];
    self.topToolBar.backgroundColor = RGBA(0, 0, 0, 0.4);
    [self addSubview:self.topToolBar];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font=[UIFont systemFontOfSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.frame = CGRectMake(60, 0, FW(self.topToolBar)-60*2, FH(self.topToolBar));
    [self.topToolBar addSubview:self.titleLabel];
    
    self.backButton=[UIButton new];
    [self.backButton setImage:IMG(@"vidoe_back") forState:UIControlStateNormal];
    self.backButton.frame=CGRectMake(0, 0, HBToolBarHeight, 50);
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.topToolBar addSubview:self.backButton];
    
    self.topToolBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.bottomTooBar = [[UIView alloc] initWithFrame:CGRectMake(0,self.height-HBToolBarHeight,self.width,HBToolBarHeight)];
    self.bottomTooBar.backgroundColor = RGBA(0, 0, 0, 0.4);
    [self addSubview:self.bottomTooBar];
    
    // 播放\暂停
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(5,HBToolBarHeight/2-30/2,30,30)];
    self.playButton.showsTouchWhenHighlighted = YES;
    self.playButton.selected=YES;
    [self.playButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setImage:IMG(@"live_play") forState:UIControlStateNormal];
    [self.playButton setImage:IMG(@"live_pause") forState:UIControlStateSelected];
    [self.bottomTooBar addSubview:self.playButton];

    // 切换全屏
    self.switchFullScreenBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width-35,HBToolBarHeight/2-30/2,30,30)];
    self.switchFullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.switchFullScreenBtn addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventTouchUpInside];
    [self.switchFullScreenBtn setImage:IMG(@"fullscreen") forState:UIControlStateNormal];
    [self.switchFullScreenBtn setImage:IMG(@"nonfullscreen") forState:UIControlStateSelected];
    [self.bottomTooBar addSubview:self.switchFullScreenBtn];

    // 时间
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.switchFullScreenBtn.frame.origin.x-80,0,80,HBToolBarHeight)];
    self.timeLabel.textAlignment=NSTextAlignmentCenter;
    self.timeLabel.text = @"00:00/00:00";
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.bottomTooBar addSubview:self.timeLabel];

    // 缓冲进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(self.playButton.frame.origin.x +self.playButton.frame.size.width,HBToolBarHeight/2,CGRectGetMinX(_timeLabel.frame)-CGRectGetMaxX(_playButton.frame),2);
    self.progressView.progressTintColor = [UIColor lightGrayColor];
    self.progressView.trackTintColor = [UIColor darkGrayColor];
    [self.bottomTooBar insertSubview:self.progressView belowSubview:_playButton];

    // 进度条
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(_progressView.frame.origin.x-2,_progressView.frame.origin.y-14,_progressView.bounds.size.width+2,30)];
    [self.slider setThumbImage:IMG(@"dot") forState:UIControlStateNormal];
    self.slider.minimumTrackTintColor = [UIColor whiteColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    [self.slider addTarget:self action:@selector(sliderChange) forControlEvents:UIControlEventValueChanged];
    [self.bottomTooBar insertSubview:self.slider aboveSubview:_progressView];
    
    self.bottomTooBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    self.playButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    self.switchFullScreenBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.slider.autoresizingMask= UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    
    [self performSelector:@selector(hideToolBar) withObject:nil afterDelay:8.0f];
    

}
#pragma mark - 创建直播工具栏
- (void)initLiveToolBar
{
    self.topToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, HBToolBarHeight)];
    self.topToolBar.backgroundColor = RGBA(0, 0, 0, 0.4);
    [self addSubview:self.topToolBar];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font=[UIFont systemFontOfSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.frame = CGRectMake(60, 0, FW(self.topToolBar)-60*2, FH(self.topToolBar));
    [self.topToolBar addSubview:self.titleLabel];
    
    self.backButton=[UIButton new];
    [self.backButton setImage:IMG(@"vidoe_back") forState:UIControlStateNormal];
    self.backButton.frame=CGRectMake(0, 0, HBToolBarHeight, 50);
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.topToolBar addSubview:self.backButton];
    
    self.topToolBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.bottomTooBar = [[UIView alloc] initWithFrame:CGRectMake(0,self.height-HBToolBarHeight,self.width,HBToolBarHeight)];
    self.bottomTooBar.backgroundColor = RGBA(0, 0, 0, 0.4);
    [self addSubview:self.bottomTooBar];
    
    // 播放\暂停
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(5,HBToolBarHeight/2-30/2,30,30)];
    self.playButton.showsTouchWhenHighlighted = YES;
    self.playButton.selected=YES;
    [self.playButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setImage:IMG(@"live_play") forState:UIControlStateNormal];
    [self.playButton setImage:IMG(@"live_pause") forState:UIControlStateSelected];
    [self.bottomTooBar addSubview:self.playButton];
    
    // 切换全屏
    self.switchFullScreenBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width-35,HBToolBarHeight/2-30/2,30,30)];
    self.switchFullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.switchFullScreenBtn addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventTouchUpInside];
    [self.switchFullScreenBtn setImage:IMG(@"fullscreen") forState:UIControlStateNormal];
    [self.switchFullScreenBtn setImage:IMG(@"nonfullscreen") forState:UIControlStateSelected];
    [self.bottomTooBar addSubview:self.switchFullScreenBtn];
    

    self.bottomTooBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    self.playButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    self.switchFullScreenBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    
    
    [self performSelector:@selector(hideToolBar) withObject:nil afterDelay:8.0f];
}
#pragma mark - 音量控制
- (void)creatVolumeSlider
{
    // 音量
    MPVolumeView *mpVolumeView=[[MPVolumeView alloc] initWithFrame:CGRectMake(50,50,40,40)];
    for (UIView *view in [mpVolumeView subviews])
    {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"])
        {
            _volumeSlider=(UISlider*)view;
            break;
        }
    }
    [mpVolumeView setHidden:YES];
    [mpVolumeView setShowsVolumeSlider:YES];
    [mpVolumeView sizeToFit];
    
}
#pragma mark - 添加手势
- (void)addGesture
{
    // 单击
    UITapGestureRecognizer *tapClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureClick:)];
    [self addGestureRecognizer:tapClick];
    
    // 双击
    UITapGestureRecognizer *doubleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureClick:)];
    doubleClick.numberOfTouchesRequired = 1;
    doubleClick.numberOfTapsRequired = 2;
    [tapClick requireGestureRecognizerToFail:doubleClick];
    [self addGestureRecognizer:doubleClick];
    
    // 拖动
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:panGesture];
}
#pragma mark -刷新时间
- (void)reloadTime
{
    __weak typeof (self) weakSelf = self;
    _timeReload = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0,1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        CGFloat current=CMTimeGetSeconds(time);
        CGFloat total=CMTimeGetSeconds([weakSelf.currentItem duration]);
        
        if (current) {
            
            _currentTime = current;
            _totalTime = total;
            
            weakSelf.slider.value = _currentTime/_totalTime;
            [weakSelf updateTabelTime:current];
            
        }
    }];
}
#pragma mark 更新播放时间
- (void)updateTabelTime:(CGFloat)playTime
{
    NSInteger a = playTime/60;
    NSInteger b = _totalTime/60;
    NSInteger c = playTime-a*60;
    NSInteger d = _totalTime-b*60;
    
    if (_timeLabel)
    {
        _timeLabel.text=[NSString stringWithFormat:@"%ld:%02ld/%ld:%02ld",(long)a,(long)c,(long)b,(long)d];
    }
}
#pragma mark - 播放或者暂停
- (void)playOrPause
{
    self.playButton.selected=!self.playButton.selected;
    
    if (self.playButton.selected) {
        
        [self continuePlay];
    }
    else
    {
        [self pause];
    }
}
#pragma mark - 是否全屏
- (void)switchClick
{
    self.switchFullScreenBtn.selected=!self.switchFullScreenBtn.selected;
    if (self.switchFullScreenBtn.selected) {
        
        // 全屏
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
        self.frame = CGRectMake(0, 0, screen_width, screen_height);
        self.playerLayer.frame= self.bounds;
    }
    else
    {
        // 非全屏
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.transform = CGAffineTransformIdentity;
        self.frame = mRect;
        CGRect frame=CGRectMake(0, 0, mRect.size.width, mRect.size.height);
        self.playerLayer.frame= frame;
       
    }
}
#pragma mark 拖动slider时,改变当前播放时间
- (void)sliderChange
{
    if (_totalTime == 0)
    {
        return;
    }

    [self seeTime:_slider.value*_totalTime];
    
    [self updateTabelTime:_slider.value*_totalTime];
}
#pragma mark 改变当前播放时间到time
- (void)seeTime:(CGFloat)time
{
    [_player seekToTime:CMTimeMakeWithSeconds(time,1) completionHandler:^(BOOL finished)
     {
         
     }];
}
#pragma mark - 隐藏工具栏
- (void)hideToolBar
{
    [UIView animateWithDuration:1.0 animations:^{
        
        self.bottomTooBar.hidden= YES;
        
        self.topToolBar.hidden= YES;
    }];

}
#pragma mark - 显示工具栏
- (void)showToolBar
{
    [UIView animateWithDuration:1.0 animations:^{
        self.bottomTooBar.hidden=NO;
        self.topToolBar.hidden=NO;
    }];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBar) object:nil];
    [self performSelector:@selector(hideToolBar) withObject:nil afterDelay:8.0f];
}
#pragma mark - 手势点击
- (void)gestureClick:(UITapGestureRecognizer *)tap
{
    if (tap.numberOfTapsRequired==2) {
        
        [self switchClick];
        
    }
    else
    {
        if (self.bottomTooBar.hidden) {
            
            [self showToolBar];
        }
        else
        {
            [self hideToolBar];
        }
    }
}
#pragma mark - 手势拖动
- (void)panGesture:(UIPanGestureRecognizer *)pan
{
    if(pan.numberOfTouches>1)
    {
        return;
    }
    
    CGPoint translationPoint = [pan translationInView:self];
    [pan setTranslation:CGPointZero inView:self];
    
    CGFloat x = translationPoint.x;
    CGFloat y = translationPoint.y;
    
    if ((x==0 && fabs(y)>=5) || fabs(y)/fabs(x)>=3)
    {

        CGFloat ratio = ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound)?20000.0f:13000.0f;
        CGPoint velocity = [pan velocityInView:self];
        
        CGFloat nowValue = _volumeSlider.value;
        CGFloat changedValue = 1.0f * (nowValue - velocity.y / ratio);
        if(changedValue < 0)
        {
            changedValue = 0;
        }
        if(changedValue > 1)
        {
            changedValue = 1;
        }
        
        [_volumeSlider setValue:changedValue animated:YES];
        
        [_volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        if (_type==HBPlayerViewTypeVideo) {
            
            //默认UI左右拖动调节进度
            if((y == 0 && fabs(x)>=5) || fabs(x)/fabs(y)>=3)
            {
                if (_totalTime == 0)
                {
                    return;
                }
                
                _slider.value=_slider.value+(x/self.bounds.size.width);
                
                [self seeTime:_slider.value*_totalTime];
                [self updateTabelTime:_slider.value*_totalTime];
            }
            if (pan.state == UIGestureRecognizerStateEnded)
            {
                
            }

        }
    }

}
- (void)setTitle:(NSString *)title
{
    _title=title;
    
    if (_title) {
        
        self.titleLabel.text=_title;
    }
}
- (void)setUrl:(NSString *)url
{
    _url=url;
    
    if (_url) {
    
        if (!self.currentItem) {
           
            [self reloadPlayer];
        }
    }
    
}
#pragma mark - 播放
- (void)play
{
    [_player play];
}
#pragma mark - 暂停
- (void)pause
{
    [_player pause];
}
#pragma mark - 返回
- (void)back
{
    if (self.switchFullScreenBtn.selected) {
        
        [self switchClick];
        
        return;
    }
    
    [self destroyPlayer];
    
    if ([self.delegate respondsToSelector:@selector(backClick)]) {
        
        [self.delegate backClick];
    }
}
#pragma mark - 放入新的currentItem
- (void)reloadPlayer
{
    [self removeObserver];
    [self removeNotification];
    
    NSLog(@"url====%@",self.url);
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.url]];
    self.currentItem=playerItem;
    [_player replaceCurrentItemWithPlayerItem:self.currentItem];
    // 添加播放器监控
    [self addPlayerObserver];
    //添加播放器通知
    [self addNotification];
    
    if (self.type==HBPlayerViewTypeVideo) {
        
        //刷新时间
        [self reloadTime];
    }

}
- (void)destroyPlayer
{
    
    [self removeObserver];
    [self removeNotification];
    
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    
    [_player removeTimeObserver:_timeReload];
    _timeReload = nil;
    
    [_player cancelPendingPrerolls];
    
    [_player replaceCurrentItemWithPlayerItem:nil];
    
    self.currentItem=nil;
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    for (CALayer *subLayer in self.layer.sublayers)
    {
        [subLayer removeFromSuperlayer];
        
    }
}
#pragma mark - 继续播放
- (void)continuePlay
{
    if (self.type==HBPlayerViewTypeVideo) {
        
        [self play];
    }
    else
    {
        [self reloadPlayer];
        
        [self play];
    }
}
- (void)dealloc
{
    [self destroyPlayer];
    NSLog(@"释放了......");
}
@end
