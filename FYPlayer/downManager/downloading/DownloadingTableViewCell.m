//
//  DownloadingTableViewCell.m
//  JFPlayer
//
//  Created by fan on 16/6/12.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "DownloadingTableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DownloadingTableViewCell ()


@end

@implementation DownloadingTableViewCell

#pragma mark - setter
- (void)setSessionModel:(JFURLConnection *)sessionModel
{
    [super setSessionModel:sessionModel];
}

@end
