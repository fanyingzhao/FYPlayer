//
//  DownloadingTableView.m
//  JFPlayer
//
//  Created by fan on 16/6/12.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "DownloadingTableView.h"
#import "DownloadingTableViewCell.h"

@implementation DownloadingTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if ([super initWithFrame:frame style:style]) {
        [self registerClass:[DownloadingTableViewCell class] forCellReuseIdentifier:NSStringFromClass([DownloadingTableViewCell class])];
    }
    
    return self;
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [VideoDownloadManager sharedDownloadManager].downloadingList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadingTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DownloadingTableViewCell class])];
    __block JFURLConnection *downloadObject = [VideoDownloadManager sharedDownloadManager].downloadingList[indexPath.row];
    cell.sessionModel = downloadObject;
    downloadObject.progressBlock = ^(NSString* fileName, NSUInteger fileSize, NSUInteger speed, NSUInteger downloadSize){
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.stateLabel.text = [NSString stringWithFormat:@"正在下载  %.f%%",((float)downloadSize) / fileSize * 100];
        });
    };
    downloadObject.finishBlock = ^(NSString* fileName, NSString* filePath, NSUInteger fileSize, NSError* error){
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadStateChanged object:nil];
    };
    
    return cell;
}

@end
