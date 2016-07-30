//
//  DownloadFinishedTableViewCell.m
//  JFPlayer
//
//  Created by fan on 16/6/12.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "DownloadFinishedTableViewCell.h"

@implementation DownloadFinishedTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.stateLabel.text = @"已缓存";
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
