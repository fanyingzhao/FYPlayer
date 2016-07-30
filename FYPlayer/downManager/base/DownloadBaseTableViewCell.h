//
//  DownloadBaseTableViewCell.h
//  JFPlayer
//
//  Created by fan on 16/6/13.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+FYAdd.h"
#import "VideoDownloadManager.h"
#import "JFURLConnection.h"

@interface DownloadBaseTableViewCell : UITableViewCell
{
    
}
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UILabel* tagLabel;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* stateLabel;

@property (nonatomic, strong) JFURLConnection* sessionModel;

+ (CGFloat)cellHeight;

@end
