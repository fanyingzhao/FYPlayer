//
//  DownloadFinishedTableView.m
//  JFPlayer
//
//  Created by fan on 16/6/12.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "DownloadFinishedTableView.h"
#import "DownloadFinishedTableViewCell.h"

@implementation DownloadFinishedTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if ([super initWithFrame:frame style:style])
    {
        [self registerClass:[DownloadFinishedTableViewCell class] forCellReuseIdentifier:NSStringFromClass([DownloadFinishedTableViewCell class])];
    }
    
    return self;
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [VideoDownloadManager sharedDownloadManager].downloadFinishedList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadFinishedTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DownloadFinishedTableViewCell class])];
    __block JFURLConnection *downloadObject = [VideoDownloadManager sharedDownloadManager].downloadFinishedList[indexPath.row];
    cell.sessionModel = downloadObject;
    
    return cell;
}


@end
