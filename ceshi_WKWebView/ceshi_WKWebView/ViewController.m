//
//  ViewController.m
//  ceshi_WKWebView
//
//  Created by 范奇 on 16/11/20.
//  Copyright © 2016年 fanqi. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "UIView+Frame.h"
#import "FQ_TableViewChildController.h"
#import "FQcollectionLayout.h"
//动态获取设备高度
#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
//动态获取设备宽度
#define IPHONE_WIDTH  [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<WKNavigationDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIWebViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    UIStoryboard * _storyboard;
    //排行榜
    UIButton * _listBtn;
    //最新上传
    UIButton * _newLoadBtn;
    
    BOOL _isTableTitleView;
}
@property (nonatomic, strong) WKWebView *webView;
/**
 组头view.
 */
@property (nonatomic, strong) UIView *sectionView;

@property (nonatomic, strong) UICollectionView *collectionView;

/**
 滑动的view.
 */
@property (nonatomic, strong) UIView *slidingView;
@property (nonatomic, strong) UIView *sectionBackView;
@property (nonatomic, strong) UILabel *titleLableView;
@property (nonatomic, strong)     UITableView * tableView;

@property (nonatomic, strong) FQ_TableViewChildController *childListVC;
@property (nonatomic, strong) FQ_TableViewChildController *childUploadVC;

@end

static NSString * const MainCellID = @"MainCell";
static NSString * const TableViewID = @"TableViewID";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view addSubview:self.webView];
    //动态计算webView的高度
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self setupUI];


     self.navigationItem.titleView = self.titleLableView;
    
}
-(void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    /**添加tableView*/
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, IPHONE_WIDTH, IPHONE_HEIGHT)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"开始"];

    [_tableView setTableHeaderView:self.webView];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"开始"];
    cell.backgroundColor = [UIColor redColor];
    [cell.contentView addSubview:self.collectionView];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IPHONE_HEIGHT-60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

#pragma mark collection代理方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //自定义cell.
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TableViewID forIndexPath:indexPath];
    if (indexPath.item == 0) {
        //创建一个主页子控制器.
        [cell.contentView addSubview:self.childListVC.view];
        
    }else
    {
        [cell.contentView addSubview:self.childUploadVC.view];
    }
    
    return cell;
}




-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGFloat webViewHeight=[self.webView.scrollView contentSize].height;
        self.webView.height = webViewHeight;
        _tableView.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT);
        [_tableView setTableHeaderView:self.webView];
        
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark --ScrollViewDelegate代理方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        //根据他的偏移值.更改不同的状态.
        if (scrollView.contentOffset.x > IPHONE_WIDTH * 0.5) {
            //那么就最新上传选中
            _newLoadBtn.selected = YES;
            _listBtn.selected = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self.slidingView.transform = CGAffineTransformMakeTranslation(IPHONE_WIDTH*0.5 -60, 0);
            }];
        }else{
            _listBtn.selected = YES;
            _newLoadBtn.selected = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self.slidingView.transform = CGAffineTransformIdentity;
            }];
            
        }
    }else if([scrollView isKindOfClass:[UITableView class]])
    {
        if (scrollView.contentOffset.y >= _webView.scrollView.height) {
            //那么就让其title更改.
            if (_isTableTitleView == NO) {
                self.sectionBackView.frame = CGRectMake(0, 0, IPHONE_WIDTH -  120, 30);
                self.navigationItem.titleView = self.sectionBackView;
                
                _isTableTitleView = YES;
            }
            
            
        }else{
            if (_isTableTitleView == YES) {
                self.navigationItem.titleView = self.titleLableView;
                self.sectionBackView.frame = CGRectMake(60, 15, IPHONE_WIDTH -  120, 30);
                [self.sectionView addSubview:self.sectionBackView];
                _isTableTitleView = NO;
            }
        }
    }
    
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"加载完成!");
}


-(WKWebView *)webView
{
    if (_webView == nil) {
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://www.kanshuzhong.com/book/1215/432449.html"]];//随便找的一个连接
        [_webView loadRequest:urlRequest];
        _webView.navigationDelegate = self;

    }
    return _webView;
}


-(UILabel *)titleLableView
{
    if (_titleLableView == nil) {
        _titleLableView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH - 120, 30)];
        _titleLableView.text = @"开始";
        _titleLableView.font = [UIFont systemFontOfSize:17];
        _titleLableView.textAlignment = NSTextAlignmentCenter;
        _titleLableView.textColor = [UIColor whiteColor];
    }
    return _titleLableView;
}



//组头选择标签.
-(UIView *)sectionView
{
    if (_sectionView == nil) {
        _sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, 60)];
        
        [_sectionView addSubview:self.sectionBackView];
        _sectionView.backgroundColor = [UIColor clearColor];
    }
    return _sectionView;
}
-(UIView *)sectionBackView
{
    if (_sectionBackView == nil) {
        UIView *sectionBackView = [[UIView alloc]initWithFrame:CGRectMake(60, 15, IPHONE_WIDTH - 120, 30)];
        sectionBackView.backgroundColor = [UIColor whiteColor];
        [sectionBackView addSubview:self.slidingView];
        [sectionBackView addSubview:[self setRightButton]];
        [sectionBackView addSubview:[self setLeftButton]];
        sectionBackView.layer.masksToBounds = YES;
        sectionBackView.layer.cornerRadius = 5;
        _sectionBackView = sectionBackView;
    }
    return _sectionBackView;
}


-(UIButton *)setRightButton
{
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(IPHONE_WIDTH*0.5-60, 0, IPHONE_WIDTH*0.5-60, 30)];
    [rightBtn setTitle:@"最新上传" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(didRightButton:) forControlEvents:UIControlEventTouchUpInside];
    _newLoadBtn = rightBtn;
    return rightBtn;
}

-(UIButton *)setLeftButton
{
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH*0.5-60, 30)];
    [leftBtn setTitle:@"排行榜" forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    leftBtn.selected = YES;
    [leftBtn addTarget:self action:@selector(didLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    _listBtn = leftBtn;
    return leftBtn;
}


/**
 点击了排行榜按钮
 */
-(void)didLeftButton:(UIButton *)button
{
    [_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}


/**
 点击了最新上传.
 */
-(void)didRightButton:(UIButton *)button
{
    [_collectionView setContentOffset:CGPointMake(IPHONE_WIDTH, 0) animated:YES];
}



-(void)didTopButton
{
    [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        FQcollectionLayout *flowLayout = [[FQcollectionLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:TableViewID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.pagingEnabled = YES;
        //        _collectionView.scrollEnabled = NO;
        
    }
    return _collectionView;
}

-(UIView *)slidingView
{
    if (_slidingView == nil) {
        _slidingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH *0.5 - 60, 30)];
        _slidingView.backgroundColor = [UIColor blueColor];
        _slidingView.layer.masksToBounds = YES;
        _slidingView.layer.cornerRadius = 5;
    }
    return _slidingView;
}

-(FQ_TableViewChildController *)childListVC
{__weak typeof(self) weakSelf = self;
    if (_childListVC == nil) {
        _childListVC = [[FQ_TableViewChildController alloc]init];
        [self addChildViewController:_childListVC];
        _childListVC.view.frame = CGRectMake(0, 0, IPHONE_WIDTH,  IPHONE_HEIGHT);
        _childListVC.topBlock = ^{
            [weakSelf didTopButton];
        };
    }
    return _childListVC;
}

-(FQ_TableViewChildController *)childUploadVC
{
    __weak typeof(self) weakSelf = self;
    if (_childUploadVC == nil) {
        _childUploadVC = [[FQ_TableViewChildController alloc]init];
        [self addChildViewController:_childUploadVC];
        _childUploadVC.view.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT);
        _childUploadVC.topBlock = ^{
            [weakSelf didTopButton];
        };
    }
    return _childUploadVC;
}


@end
