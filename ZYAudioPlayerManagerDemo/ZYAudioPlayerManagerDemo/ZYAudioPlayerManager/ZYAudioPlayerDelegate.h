//
//  ZYAudioPlayer.h
//  ZYAudioPlayerManagerDemo
//
//  Created by ZYSu on 2017/6/26.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ZYAudioPlayerStateStop,
    ZYAudioPlayerStateLoading,
    ZYAudioPlayerStatePause,
    ZYAudioPlayerStatePlaying
} ZYAudioPlayerState;

@protocol ZYAudioPlayerModel <NSObject>

@property (nonatomic, copy) NSString *audioURL;

@property (nonatomic, assign) ZYAudioPlayerState playAudioState;

@property (nonatomic, assign) float progress;

@property (nonatomic, assign) float duration;

@end

@protocol ZYAudioPlayerDelegate <NSObject>


/**
 可能是多个model 如果之前有正在播放的model,changes就有两个model

 @param changes changes description
 */
- (void)playStateChange:(NSArray<id<ZYAudioPlayerModel>> *)changes;

@end

