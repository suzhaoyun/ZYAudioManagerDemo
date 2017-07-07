//
//  ZYAudioPlayerManager.m
//  ZYAudioPlayerManagerDemo
//
//  Created by ZYSu on 2017/6/26.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ZYAudioPlayerManager.h"
#import "DouAudioStreamer/DOUAudioStreamer.h"
#import <AVFoundation/AVFoundation.h>
#import "DOUAudioStreamer_Private.h"

@interface ZYAudioFile : NSObject <DOUAudioFile>
@property (nonatomic, strong) NSURL *audioFileURL;
@end

@implementation ZYAudioFile
@end


@interface ZYAudioPlayerManager ()

@property (nonatomic, strong) DOUAudioStreamer *streamer;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSPointerArray *delegates;

@property (nonatomic, copy) CallBackType progressChange;

@end

@implementation ZYAudioPlayerManager

+ (instancetype)sharedManager
{
    static ZYAudioPlayerManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (void)addDelegate:(id<ZYAudioPlayerDelegate>)delegate
{
    if (delegate) {
        for (NSInteger i = 0; i < self.delegates.count;i++ ) {
            if ([self.delegates pointerAtIndex:i] == (__bridge void * _Nullable)(delegate)) {
                return;
            }
        }
        [self.delegates addPointer:(__bridge void * _Nullable)(delegate)];
    }
}

- (void)removeDelegate:(id<ZYAudioPlayerDelegate>)delegate
{
    if (delegate) {
        for (NSInteger i = 0; i < self.delegates.count;i++ ) {
            if ([self.delegates pointerAtIndex:i] == (__bridge void * _Nullable)(delegate)) {
                [self.delegates removePointerAtIndex:i];
                return;
            }
        }
    }
}

- (void)play:(id<ZYAudioPlayerModel>)model progress:(CallBackType)progressChange
{
    if (model == nil || model.audioURL.length == 0) {
        NSLog(@"URL无效........");
        return;
    }
    
    // 如果当前模型在播放
    if (self.currentModel == model) {
        
        // 继续播放就行了
        if (self.streamer.status == DOUAudioStreamerPaused && self.streamer.currentTime > 0) {
            model.playAudioState = ZYAudioPlayerStatePlaying;
            [self startTimer];
            [self.streamer play];
        }else{
            // 创建streamer
            [self createStreamer];
        }
        
        [self callback:@[model]];
        
        _progressChange = progressChange;
        
    }else{
        if (self.currentModel) {
            // 停止上一个model的播放状态
            self.currentModel.playAudioState = ZYAudioPlayerStateStop;
            self.currentModel.progress = 0.0f;
        }
        
        // 执行新的播放逻辑
        id last = self.currentModel;
        _currentModel = model;
        model.playAudioState = ZYAudioPlayerStateStop;
        _progressChange = progressChange;
        
        // 回调状态
        [self callback:last?@[last, model]:@[model]];
        
        // 创建streamer
        [self createStreamer];
        
    }
}

- (void)stop:(id<ZYAudioPlayerModel>)model
{
    if (model == nil) {
        return;
    }
    
    if (self.currentModel == model && self.streamer.currentTime > 0) {
        if (self.streamer.status == DOUAudioStreamerPlaying) {
            [self.streamer pause];
            model.playAudioState = ZYAudioPlayerStatePause;
        }else{
            model.playAudioState = ZYAudioPlayerStateStop;
            model.progress = 0.0f;
            [self.streamer stop];
        }
        // 回调状态
        [self callback:@[model]];
    }
}

- (void)createStreamer {
    ZYAudioFile *file = [ZYAudioFile new];
    file.audioFileURL = [NSURL URLWithString:self.currentModel.audioURL];
    [_streamer removeObserver:self forKeyPath:@"status"];
    [_streamer stop];
    _streamer = nil;
    _streamer = [DOUAudioStreamer streamerWithAudioFile:file];
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.streamer play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateStatus];
        });
    }
}

- (void)updateProgress
{
    float progress = 0.0f;
    
    if (self.streamer.duration > 0){
        progress = self.streamer.currentTime / self.streamer.duration;
        _currentModel.duration = self.streamer.duration;
    }
    
    if (progress < 0){
        progress = 0;
    }
    if (progress >= 1) {
        progress = 0;
        _currentModel.playAudioState = ZYAudioPlayerStateStop;
    }
    
    _currentModel.progress = progress;
    _progressChange?_progressChange(_currentModel):NULL;
}

- (void)updateStatus
{
    
    NSLog(@"status ----- %zd", _streamer.status);
    
    switch (_streamer.status) {
        case DOUAudioStreamerPlaying:
        {
            [self startTimer];
            _currentModel.playAudioState = ZYAudioPlayerStatePlaying;
            break;
        }
        case DOUAudioStreamerPaused:
        {
            [self stopTimer];
            _currentModel.playAudioState = ZYAudioPlayerStatePause;
            break;
        }
        case DOUAudioStreamerIdle:
        {
            [self stopTimer];
            _currentModel.playAudioState = ZYAudioPlayerStateStop;
            _currentModel.progress = 0.0f;
            break;
        }
            
        case DOUAudioStreamerFinished:
        {
            [self stopTimer];
            _currentModel.playAudioState = ZYAudioPlayerStateStop;
            _currentModel.progress = 0.0f;
            break;
        }
        case DOUAudioStreamerBuffering:
        {
            _currentModel.playAudioState = ZYAudioPlayerStateLoading;
            break;
        }
            // 发生了其他错误
        default:
        {
            [self stopTimer];
            _currentModel.playAudioState = ZYAudioPlayerStateStop;
            _currentModel.progress = 0.0f;
            break;
        }
    }
    
    [self callback:@[_currentModel]];
    
    if (self.streamer.status == DOUAudioStreamerFinished) {
        _currentModel = nil;
    }
}

- (void)callback:(NSArray *)models
{
    for (id<ZYAudioPlayerDelegate> d in self.delegates) {
        if (d && [d respondsToSelector:@selector(playStateChange:)]) {
            [d playStateChange:models];
        }
    }
}

- (NSPointerArray *)delegates
{
    if (_delegates == nil) {
        _delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return _delegates;
}

- (void)startTimer
{
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    // 如果注释下面这句话,在tableView滚动时进度不会更新. 打开的话可能会有闪烁
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

@end


