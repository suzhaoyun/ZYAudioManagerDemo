//
//  ZYAudioListCellModel.h
//  ZYAudioPlayerManagerDemo
//
//  Created by ZYSu on 2017/6/26.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYAudioPlayerDelegate.h"

@interface ZYAudioListCellModel : NSObject<ZYAudioPlayerModel>

@property (nonatomic, copy) NSString *audioURL;

@property (nonatomic, assign) ZYAudioPlayerState playAudioState;

@property (nonatomic, assign) float progress;

@property (nonatomic, assign) float duration;

@end
