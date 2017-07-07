//
//  ZYAudioPlayerManager.h
//  ZYAudioPlayerManagerDemo
//
//  Created by ZYSu on 2017/6/26.
//  Copyright © 2017年 ZYSu. All rights reserved.
//  (多播代理, 面向协议处理音频播放中的复杂逻辑)

#import <Foundation/Foundation.h>
#import "ZYAudioPlayerDelegate.h"

typedef void(^CallBackType)(id<ZYAudioPlayerModel> callBackModel);

@interface ZYAudioPlayerManager : NSObject

/**
 拿到管理者
 */
+ (instancetype)sharedManager;

/**
 多播代理
 *  所有有播放的控制器都可以实现. 不移除都会受到回调
 @param delegate 实现代理方法的对象
 */

- (void)addDelegate:(id<ZYAudioPlayerDelegate>)delegate;

/**
 移除delegate 可以在界面消失的时候移除代理
 
 @param delegate delegate description
 */
- (void)removeDelegate:(id<ZYAudioPlayerDelegate>)delegate;

/**
 进度条回调很频繁 所以没有在多播代理里实现 只回调当前在播放的model的进度
 如果model之前是暂停, 自动续播放, 会自动停止上一个正在播放的model
 @param model 播放对象
 @param progressChange 进度发生变化
 */

- (void)play:(id<ZYAudioPlayerModel>)model progress:(CallBackType)progressChange;

/**
 获取当前正在播放的model.  可用于界面离开显示时,主动停止.
 */

@property (nonatomic, strong, readonly) id<ZYAudioPlayerModel> currentModel;

/**
 停止播放
 不要被名字迷惑,默认是暂停播放. 没有停止播放的概念.
 @param model model description
 */

- (void)stop:(id<ZYAudioPlayerModel>)model;

@end
