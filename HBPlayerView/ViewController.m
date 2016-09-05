//
//  ViewController.m
//  HBPlayerView
//
//  Created by hebing on 16/9/5.
//  Copyright © 2016年 hebing. All rights reserved.
//

#import "ViewController.h"
#import "HBPlayerView.h"
#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<HBPlayerViewDelegate>
{
    HBPlayerView *playerView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    playerView=[[HBPlayerView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_width*9/16)];
    playerView.url = @"http://7rfkz6.com1.z0.glb.clouddn.com/480p_20160229_T2.mp4";
    playerView.delegate=self;
    playerView.type=HBPlayerViewTypeVideo;
    [self.view addSubview:playerView];
    playerView.title=@"测试";
    [playerView play];

}
- (void)backClick
{
   //[self.navigationController popViewControllerAnimated:YES];
}
- (void)VideoPlayCompleted
{
    
}
@end
