//
//  HBPlayerView.h
//  MeiTuanDemo
//
//  Created by hebing on 16/6/2.
//  Copyright © 2016年 hebing. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    
    HBPlayerViewTypeVideo=0,//视频播放
    HBPlayerViewTypeLive,//直播
    
}HBPlayerViewType;

@protocol HBPlayerViewDelegate<NSObject>

- (void)backClick;

- (void)VideoPlayCompleted;

@end


@interface HBPlayerView : UIView

/*!*  @brief  url 播放地址*/
@property (nonatomic,strong) NSString *url;
/*!* @brief  title 视频标题*/
@property (nonatomic,strong) NSString *title;
/*!* @brief  type 播放模式*/
@property (nonatomic,assign) HBPlayerViewType type;

@property (nonatomic,weak)  id<HBPlayerViewDelegate>delegate;
//播放
- (void)play;

- (void)pause;

- (void)reloadPlayer;
@end
