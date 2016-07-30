//
//  DownloadTableView.m
//  JFPlayer
//
//  Created by fan on 16/6/12.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "DownloadTableView.h"
#import "UIView+FYAdd.h"
#import "DownloadBaseTableViewCell.h"

NSString *const DownloadStateChanged = @"downloadStateChanged";


@interface DownloadTableView ()

@end

@implementation DownloadTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if ([super initWithFrame:frame style:style])
    {
        self.delegate = self;
        self.dataSource = self;
        
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSelf) name:DownloadStateChanged object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notification
- (void)reloadSelf
{
    [self reloadData];
}

#pragma mark - tableviewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DownloadBaseTableViewCell cellHeight] + 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


@end
