//
//  DownloadBaseTableViewCell.m
//  JFPlayer
//
//  Created by fan on 16/6/13.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "DownloadBaseTableViewCell.h"

@interface DownloadBaseTableViewCell ()
{
    
}

@end

@implementation DownloadBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.tagLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.stateLabel];
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

#pragma mark - funcs
+ (CGFloat)cellHeight
{
    return [UIScreen mainScreen].bounds.size.width / 16 * 8;
}

#pragma mark - setter
- (void)setSessionModel:(JFURLConnection *)sessionModel
{
    _sessionModel = sessionModel;
    
    self.titleLabel.text = sessionModel.videoName;
}

#pragma mark - getter
- (UIImageView *)iconImageView
{
    if (!_iconImageView)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:({
            CGRect rect;
            rect.origin.x = 0;
            rect.origin.y = 0;
            rect.size.width = self.width;
            rect.size.height = [DownloadBaseTableViewCell cellHeight];
            rect;
        })];
        _iconImageView.backgroundColor = [UIColor redColor];
    }
    
    return _iconImageView;
}

- (UILabel *)tagLabel
{
    if (!_tagLabel)
    {
        _tagLabel = [[UILabel alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = self.width - 20;
            rect.size.height = 20;
            rect.origin.x = 10;
            rect.origin.y = 10;
            rect;
        })];
        _tagLabel.textAlignment = NSTextAlignmentRight;
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.font = [UIFont systemFontOfSize:14];
        _tagLabel.text = @"360 全景";
    }
    
    return _tagLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = self.width;
            rect.size.height = 20;
            rect.origin.x = 0;
            rect.origin.y = [DownloadBaseTableViewCell cellHeight] / 2 - CGRectGetHeight(rect) - 5;
            rect;
        })];
        _titleLabel.textColor = self.tagLabel.textColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"魔兽世界";
    }
    
    return _titleLabel;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel)
    {
        _stateLabel = [[UILabel alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = self.width;
            rect.size.height = 15;
            rect.origin.x = 0;
            rect.origin.y = [DownloadBaseTableViewCell cellHeight] / 2 + 5;
            rect;
        })];
        _stateLabel.textColor = self.tagLabel.textColor;
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.text = @"正在下载";
        _stateLabel.font = [UIFont systemFontOfSize:13];
    }
    
    return _stateLabel;
}


@end
