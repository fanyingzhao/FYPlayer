//
//  DownManagerViewController.m
//  JFPlayer
//
//  Created by fan on 16/6/12.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "DownManagerViewController.h"
#import "UIView+FYAdd.h"
#import "DownloadingTableView.h"
#import "DownloadFinishedTableView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
static const CGFloat indicatorAnaimtionDuration = 0.3;
#define kSelectedColor  0x999999
#define knormalColor  0xFFFFFF
#define kSaveUnit           1024

@interface DownManagerViewController ()
{
    BOOL _showDownloadFinish;               // 当前显示的板块
    CGRect _indicatorLeftRect;
    CGRect _indicatorRightRect;
    
    CGFloat spaceSize;                      // 剩余空间大小
}
@property (nonatomic, strong) UIView* topView;
@property (nonatomic, strong) UIButton* downloadFinishBtn;
@property (nonatomic, strong) UIButton* downloadingBtn;
@property (nonatomic, strong) UIView* indicatorView;

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) DownloadFinishedTableView* downloadFinishedTableView;
@property (nonatomic, strong) DownloadingTableView* downloadingTableView;

@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic, strong) UILabel* spaceInfoLabel;
@end

@implementation DownManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUp];
}

#pragma mark - initializaiton
- (void)setUp
{
    self.title = @"下载管理";
    
    _showDownloadFinish = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addUI];
}

#pragma mark - ui
- (void)addUI
{
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.downloadFinishBtn];
    [self.topView addSubview:self.downloadingBtn];
    [self.topView addSubview:self.indicatorView];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.downloadFinishedTableView];
    [self.scrollView addSubview:self.downloadingTableView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.spaceInfoLabel];
}

- (void)updateTopViewBtn
{
    if (_showDownloadFinish)
    {
        [_downloadFinishBtn setTitleColor:UIColorFromRGB(knormalColor) forState:UIControlStateNormal];
        [_downloadingBtn setTitleColor:UIColorFromRGB(kSelectedColor) forState:UIControlStateNormal];
    }
    else
    {
        [_downloadFinishBtn setTitleColor:UIColorFromRGB(kSelectedColor) forState:UIControlStateNormal];
        [_downloadingBtn setTitleColor:UIColorFromRGB(knormalColor) forState:UIControlStateNormal];
    }
}

#pragma mark - animation
- (void)indicatorViewAnimationLeft
{
    [UIView animateWithDuration:indicatorAnaimtionDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
       
        self.indicatorView.frame = _indicatorLeftRect;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)indicatorViewAnimationRight
{
    [UIView animateWithDuration:indicatorAnaimtionDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.indicatorView.frame = _indicatorRightRect;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - tools
- (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark - events
- (void)downloadFinishBtnClick:(UIButton*)sender
{
    if (_showDownloadFinish)
    {
        return;
    }
    
    _showDownloadFinish = YES;
    [self.scrollView setContentOffset:({
        CGPoint point;
        point.x = 0;
        point.y = 0;
        point;
    }) animated:YES];
    [self updateTopViewBtn];
    [self indicatorViewAnimationLeft];
}

- (void)downloadingBtnClick:(UIButton*)sender
{
    if (!_showDownloadFinish)
    {
        return;
    }
    
    _showDownloadFinish = NO;
    [self.scrollView setContentOffset:({
        CGPoint point;
        point.x = self.view.width;
        point.y = 0;
        point;
    }) animated:YES];
    [self updateTopViewBtn];
    [self indicatorViewAnimationRight];
}

- (void)backBtnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editBtnClick
{
    self.downloadingTableView.editing = YES;
    self.downloadFinishedTableView.editing = YES;
}

#pragma mark - getter
- (UIView *)topView
{
    if (!_topView)
    {
        _topView = [[UIView alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = self.view.width;
            rect.size.height = 40;
            rect.origin.x = 0;
            rect.origin.y = 64;
            rect;
        })];
        _topView.backgroundColor = [UIColor blueColor];
    }
    
    return _topView;
}

- (UIButton *)downloadFinishBtn
{
    if (!_downloadFinishBtn)
    {
        _downloadFinishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadFinishBtn.frame = ({
            CGRect rect;
            rect.size.width = self.view.width / 2;
            rect.size.height = self.topView.height;
            rect.origin.x = 0;
            rect.origin.y = 0;
            rect;
        });
        _downloadFinishBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_downloadFinishBtn setTitle:@"已下载" forState:UIControlStateNormal];
        [_downloadFinishBtn setTitleColor:UIColorFromRGB(knormalColor) forState:UIControlStateNormal];
        [_downloadFinishBtn addTarget:self action:@selector(downloadFinishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _downloadFinishBtn;
}

- (UIButton *)downloadingBtn
{
    if (!_downloadingBtn)
    {
        _downloadingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadingBtn.frame = ({
            CGRect rect;
            rect.size = self.downloadFinishBtn.size;
            rect.origin.x = self.view.width / 2;
            rect.origin.y = 0;
            rect;
        });
        _downloadingBtn.titleLabel.font = self.downloadFinishBtn.titleLabel.font;
        [_downloadingBtn setTitle:@"正在下载" forState:UIControlStateNormal];
        [_downloadingBtn setTitleColor:UIColorFromRGB(kSelectedColor) forState:UIControlStateNormal];
        [_downloadingBtn addTarget:self action:@selector(downloadingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _downloadingBtn;
}

- (UIView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIView alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = self.view.width / 2 - 40;
            rect.size.height = 2;
            rect.origin.x = 20;
            rect.origin.y = self.topView.height - CGRectGetHeight(rect);
            rect;
        })];
        _indicatorView.backgroundColor = [UIColor greenColor];
        _indicatorView.layer.cornerRadius = _indicatorView.height / 2;
        _indicatorLeftRect = _indicatorView.frame;
        _indicatorRightRect = ({
            CGRect rect;
            rect.size.width = self.view.width / 2 - 40;
            rect.size.height = 2;
            rect.origin.x = self.view.width / 2 + 20;
            rect.origin.y = self.topView.height - CGRectGetHeight(rect);
            rect;
        });
    }
    
    return _indicatorView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:({
            CGRect rect;
            rect.origin.x = 0;
            rect.origin.y = self.topView.bottom;
            rect.size.width = self.view.width;
            rect.size.height = self.view.height - self.topView.bottom;
            rect;
        })];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = ({
            CGSize size;
            size.width = self.view.width * 2;
            size.height = _scrollView.height;
            size;
        });
    }
    
    return _scrollView;
}

- (DownloadFinishedTableView *)downloadFinishedTableView
{
    if (!_downloadFinishedTableView)
    {
        _downloadFinishedTableView = [[DownloadFinishedTableView alloc] initWithFrame:({
            CGRect rect;
            rect.origin.x = 0;
            rect.origin.y = 0;
            rect.size.width = self.view.width;
            rect.size.height = self.scrollView.height - self.bottomView.height;
            rect;
        }) style:UITableViewStylePlain];
    }
    
    return _downloadFinishedTableView;
}

- (DownloadingTableView *)downloadingTableView
{
    if (!_downloadingTableView)
    {
        _downloadingTableView = [[DownloadingTableView alloc] initWithFrame:({
            CGRect rect;
            rect.origin.x = self.view.width;
            rect.origin.y = 0;
            rect.size.width = self.view.width;
            rect.size.height = self.scrollView.height - self.bottomView.height;
            rect;
        }) style:UITableViewStylePlain];
    }
    
    return _downloadingTableView;
}

- (UIView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [[UIView alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = self.view.width;
            rect.size.height = 40;
            rect.origin.x = 0;
            rect.origin.y = self.view.height - CGRectGetHeight(rect);
            rect;
        })];
        _bottomView.backgroundColor = [UIColor blueColor];
    }
    
    return _bottomView;
}

- (UILabel *)spaceInfoLabel
{
    if (!_spaceInfoLabel)
    {
        _spaceInfoLabel = [[UILabel alloc] initWithFrame:self.bottomView.bounds];
        _spaceInfoLabel.font = [UIFont systemFontOfSize:14];
        _spaceInfoLabel.textAlignment = NSTextAlignmentCenter;
        _spaceInfoLabel.textColor = UIColorFromRGB(0xeeeeee);
        
        CGFloat total = [[self totalDiskSpace] floatValue] / kSaveUnit / kSaveUnit;
        CGFloat free = [[self freeDiskSpace] floatValue] / kSaveUnit / kSaveUnit;
        _spaceInfoLabel.text = [NSString stringWithFormat:@"已下载%.2fKB, 剩余可用%.2fMB",0.f,free];
    }
    
    return _spaceInfoLabel;
}

@end
