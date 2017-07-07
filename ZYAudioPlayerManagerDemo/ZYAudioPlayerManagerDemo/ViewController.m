//
//  ViewController.m
//  ZYAudioPlayerManagerDemo
//
//  Created by ZYSu on 2017/6/26.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ViewController.h"
#import "ZYAudioListCell.h"
#import "ZYAudioListCellModel.h"
#import "ZYAudioPlayerManager.h"

@interface ViewController ()<ZYAudioPlayerDelegate>
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *datas = @[@"http://ws.stream.qqmusic.qq.com/C100003507bR0gDKBm.m4a?fromtag=38", @"http://cdnringuc.shoujiduoduo.com/ringres/user/a24/026/23604026.aac",@"http://ws.stream.qqmusic.qq.com/C100003507bR0gDKBm.m4a?fromtag=38",@"http://ws.stream.qqmusic.qq.com/C100003507bR0gDKBm.m4a?fromtag=38", @"http://ws.stream.qqmusic.qq.com/C100003507bR0gDKBm.m4a?fromtag=38",@"http://cdnringuc.shoujiduoduo.com/ringres/user/a24/026/23604026.aac",
                       @"http://cdnringuc.shoujiduoduo.com/ringres/user/a24/026/23604026.aac",@"http://cdnringuc.shoujiduoduo.com/ringres/user/a24/026/23604026.aac",@"http://ws.stream.qqmusic.qq.com/C100003507bR0gDKBm.m4a?fromtag=38"];
    _datas = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSString *str in datas) {
        ZYAudioListCellModel *model = [ZYAudioListCellModel new];
        model.audioURL = str;
        [_datas addObject:model];
    }
    [self.tableView reloadData];
    
    [[ZYAudioPlayerManager sharedManager] addDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"stop" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [[ZYAudioPlayerManager sharedManager] stop:note.object];
    }];
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"play" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [[ZYAudioPlayerManager sharedManager] play:note.object progress:^(id<ZYAudioPlayerModel> callBackModel) {
            NSInteger index = [weakSelf.datas indexOfObject:callBackModel];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
}

- (void)playStateChange:(NSArray<id<ZYAudioPlayerModel>> *)changes
{
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZYAudioListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.model = self.datas[indexPath.row];
    return cell;
}
@end
