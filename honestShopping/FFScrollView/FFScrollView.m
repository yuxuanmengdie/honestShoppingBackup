//
//  FFScrollView.m
//  ScrollViewDemo
//
//  Created by Juncy_Fan on 13-11-11.
//  Copyright (c) 2013年. All rights reserved.
//

#import "FFScrollView.h"
#import "UIImageView+WebCache.h"
#import "UIView+HSLayout.h"

@implementation FFScrollView
@synthesize scrollView;
@synthesize pageControl;
@synthesize selectionType;
@synthesize pageViewDelegate;
@synthesize sourceArr;

static const float kTimerInterval = 5.0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        selectionType = FFScrollViewSelecttionTypeTap;
        _imageContentMode = UIViewContentModeScaleToFill;
        _isFirstLoad = NO;
    }
    return self;
}

#pragma mark-- init methods
- (id)initPageViewWithFrame:(CGRect)frame views:(NSArray *)views
{
    self = [super initWithFrame:frame];
    if (self) {
        selectionType = FFScrollViewSelecttionTypeTap;
        sourceArr = views;
        _isFirstLoad = NO;
        self.userInteractionEnabled = YES;
        [self iniSubviewsWithFrame:frame];
    }
    return self;
}

-(void)iniSubviewsWithFrame:(CGRect)frame
{
    if (sourceArr.count < 1) {
        return;
    }
    
    for (UIView *sub in self.scrollView.subviews) {
        [sub removeFromSuperview];
    }
    
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGRect fitRect = CGRectMake(0, 0, width, height);
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:fitRect];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(width*(sourceArr.count+2), height);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    __weak typeof(self) wself = self;
    NSString *lastModel = [sourceArr lastObject];
    UIImageView *firstImageView = [[UIImageView alloc]initWithFrame:fitRect];
    firstImageView.contentMode = _imageContentMode;
    [firstImageView sd_setImageWithURL:[NSURL URLWithString:lastModel] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [wself p_imageLoadFinished:[wself p_imageViewHeightWithWid:width imageSize:image.size]];
        }
    }];
    [self.scrollView addSubview:firstImageView];
    
    for (int i = 0; i < sourceArr.count; i++) {
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(width*(i+1), 0, width, height)];
        imageview.contentMode = _imageContentMode;
        NSString *model = [sourceArr objectAtIndex:i];
        [imageview sd_setImageWithURL:[NSURL URLWithString:model] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [wself p_imageLoadFinished:[wself p_imageViewHeightWithWid:width imageSize:image.size]];
            }
        }];
//       imageview.image = [UIImage imageNamed:model.img];
        [self.scrollView addSubview:imageview];
        
    }
    
    NSString *firstModel = [sourceArr firstObject];
    UIImageView *lastImageView = [[UIImageView alloc]initWithFrame:CGRectMake(width*(sourceArr.count+1), 0, width, height)];
    lastImageView.contentMode = _imageContentMode;
    [lastImageView sd_setImageWithURL:[NSURL URLWithString:firstModel] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [wself p_imageLoadFinished:[wself p_imageViewHeightWithWid:width imageSize:image.size]];
        }
    }];
    [self.scrollView addSubview:lastImageView];
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, height-30, width, 30)];

    self.pageControl.numberOfPages = sourceArr.count;
    self.pageControl.currentPage = 0;
    self.pageControl.enabled = YES;
    CGPoint center = self.pageControl.center;
    center.x = self.center.x;
    self.pageControl.center = center;
    
    [self addSubview:self.pageControl];
    
    //[self.scrollView scrollRectToVisible:CGRectMake(width, 0, width, height) animated:NO];
    [self.scrollView setContentOffset:CGPointMake(width, 0) animated:NO];
    if ([timer isValid]) {
        [timer invalidate];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(nextPage:) userInfo:nil repeats:YES];
    
    if (_singleTap == nil) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        _singleTap = singleTap;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];

    }
}

/*
#pragma mark -
#pragma mark 自动布局来构建
- (void)initSubViewsByAutolayout:(CGRect)frame;
{
    if (sourceArr.count < 1) {
        return;
    }
    
    for (UIView *sub in self.scrollView.subviews) {
        [sub removeFromSuperview];
    }
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    __weak typeof(self) wself = self;
    NSString *lastModel = [sourceArr lastObject];
    UIImageView *firstImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    firstImageView.contentMode = _imageContentMode;
    firstImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:firstImageView];
    [firstImageView sd_setImageWithURL:[NSURL URLWithString:lastModel] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [wself p_imageLoadFinished:[wself p_imageViewHeightWithWid:width imageSize:image.size]];
        }
    }];


    for (int i = 0; i < sourceArr.count; i++) {
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(width*(i+1), 0, width, height)];
        imageview.translatesAutoresizingMaskIntoConstraints = NO;
        imageview.contentMode = _imageContentMode;
        NSString *model = [sourceArr objectAtIndex:i];
        [imageview sd_setImageWithURL:[NSURL URLWithString:model] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [wself p_imageLoadFinished:[wself p_imageViewHeightWithWid:width imageSize:image.size]];
            }
        }];
        [self.scrollView addSubview:imageview];
        
    }
    
    NSString *firstModel = [sourceArr firstObject];
    UIImageView *lastImageView = [[UIImageView alloc]initWithFrame:CGRectMake(width*(sourceArr.count+1), 0, width, height)];
    lastImageView.contentMode = _imageContentMode;
    [lastImageView sd_setImageWithURL:[NSURL URLWithString:firstModel] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [wself p_imageLoadFinished:[wself p_imageViewHeightWithWid:width imageSize:image.size]];
        }
    }];
    [self.scrollView addSubview:lastImageView];
    lastImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, height-30, width, 30)];
    
    self.pageControl.numberOfPages = sourceArr.count;
    self.pageControl.currentPage = 0;
    self.pageControl.enabled = YES;
    CGPoint center = self.pageControl.center;
    center.x = self.center.x;
    self.pageControl.center = center;
    
    [self addSubview:self.pageControl];
    
    [self.scrollView scrollRectToVisible:CGRectMake(width, 0, width, height) animated:NO];
    if ([timer isValid]) {
        [timer invalidate];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(nextPage:) userInfo:nil repeats:YES];
    
    if (_singleTap == nil) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        _singleTap = singleTap;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
    }
}
*/

#pragma mark --- custom methods
//自动滚动到下一页
-(IBAction)nextPage:(id)sender
{
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int currentPage = self.scrollView.contentOffset.x/pageWidth;
    if (currentPage == 0) {
        self.pageControl.currentPage = sourceArr.count-1;
    }
    else if (currentPage == sourceArr.count+1) {
        self.pageControl.currentPage = 0;
    }
    else {
        self.pageControl.currentPage = currentPage-1;
    }
    int currPageNumber = (int)self.pageControl.currentPage;
    CGSize viewSize = self.scrollView.frame.size;
    CGRect rect = CGRectMake((currPageNumber+2)*pageWidth, 0, viewSize.width, viewSize.height);
    [self.scrollView scrollRectToVisible:rect animated:YES];
    currPageNumber++;
    if (currPageNumber == sourceArr.count) {
//        CGRect newRect=CGRectMake(viewSize.width, 0, viewSize.width, viewSize.height);
//        [self.scrollView scrollRectToVisible:newRect animated:NO];
        [self performSelector:@selector(scrollToFirst) withObject:nil afterDelay:0.5];
        currPageNumber = 0;
    }
    self.pageControl.currentPage = currPageNumber;
    
   
}

- (void)scrollToFirst
{
    CGSize viewSize = self.scrollView.frame.size;
    CGRect newRect=CGRectMake(viewSize.width, 0, viewSize.width, viewSize.height);
    [self.scrollView scrollRectToVisible:newRect animated:NO];
}

//点击图片的时候 触发
- (void)singleTap:(UITapGestureRecognizer *)tapGesture
{
    if (selectionType != FFScrollViewSelecttionTypeTap) {
        return;
    }
    
    if (pageViewDelegate && [pageViewDelegate respondsToSelector:@selector(scrollViewDidClickedAtPage:)]) {
        [pageViewDelegate scrollViewDidClickedAtPage:self.pageControl.currentPage];
    }
}

#pragma mark---- UIScrollView delegate methods
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //开始拖动scrollview的时候 停止计时器控制的跳转
    [timer invalidate];
    timer = nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat heigth = self.scrollView.frame.size.height;
    //当手指滑动scrollview，而scrollview减速停止的时候 开始计算当前的图片的位置
    int currentPage = self.scrollView.contentOffset.x/width;
    if (currentPage == 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(width*sourceArr.count, 0, width, heigth) animated:NO];
        self.pageControl.currentPage = sourceArr.count-1;
    }
    else if (currentPage == sourceArr.count+1) {
        [self.scrollView scrollRectToVisible:CGRectMake(width, 0, width, heigth) animated:NO];
        self.pageControl.currentPage = 0;
    }
    else {
        self.pageControl.currentPage = currentPage-1;
    }
    //拖动完毕的时候 重新开始计时器控制跳转
    timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(nextPage:) userInfo:nil repeats:YES];
    
}

#pragma mark -
#pragma mark 计算image的高度
- (CGFloat)p_imageViewHeightWithWid:(float)width imageSize:(CGSize)imgSize
{
    float hei = 0.0;
    if (imgSize.width == 0) {
        hei = 0.0;
    }
    else
    {
        hei = (float)width * ((float)imgSize.height / imgSize.width);
    }
    return hei;
}

- (void)p_imageLoadFinished:(float)height
{
    if (!_isFirstLoad && self.heightBlock && height > 0.0) {
        _isFirstLoad = YES;
        self.heightBlock(height);
        
        CGRect scrollFrame = self.scrollView.frame;
        scrollFrame.size.height = height;
        self.scrollView.frame = scrollFrame;
        
        for (UIView *sub in self.scrollView.subviews) {
            CGRect frame = sub.frame;
            frame.size.height = height;
            sub.frame = frame;
        }
        
        CGRect frame = self.pageControl.frame;
        frame.size.height = height - 30;
        self.pageControl.frame = frame;
    }
}

- (void)dealloc
{
    if ([timer isValid]) {
        [timer invalidate];
    }
}


@end
