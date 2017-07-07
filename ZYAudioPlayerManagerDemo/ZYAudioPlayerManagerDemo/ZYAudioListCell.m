//
//  ZYAudioListCell.m
//  ZYAudioPlayerManagerDemo
//
//  Created by ZYSu on 2017/6/26.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ZYAudioListCell.h"
#import <AVFoundation/AVFoundation.h>
#import "ZYAudioPlayerManager.h"

@interface ZYAudioListCell ()
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *progressV;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@end

@implementation ZYAudioListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(ZYAudioListCellModel *)model
{
    _model = model;
    if (model.playAudioState == ZYAudioPlayerStatePlaying) {
        [self.playBtn setTitle:@"停止" forState:UIControlStateNormal];
    }else if (model.playAudioState == ZYAudioPlayerStateLoading){
        
        [self.playBtn setTitle:@"加载" forState:UIControlStateNormal];
    }else{
        [self.playBtn setTitle:@"开始" forState:UIControlStateNormal];
    }
    
    self.progressV.value = model.progress;
    
    self.timeL.text = [NSString stringWithFormat:@"%ds", (int)model.duration];
}
- (IBAction)playClick:(id)sender {
    
    if (self.model.playAudioState == ZYAudioPlayerStateLoading) {
        return;
    }else if (self.model.playAudioState == ZYAudioPlayerStatePlaying){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stop" object:self.model];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"play" object:self.model];
    }
}
@end
