# webView-tableView

**项目需求就是上面是webView.下面是tableView,然后下拉到webView消失就正常显示为tableView.可下拉刷新.拉到一定值的时候.让其滚动到webView最顶层.
![需求效果.png](http://upload-images.jianshu.io/upload_images/2100495-187d80c0e5dd9fbe.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)**

下拉到webView完全消失.就让切换的View成为titleView.
![组头变为titleView.png](http://upload-images.jianshu.io/upload_images/2100495-52c20b135ae01388.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此时正常为tableView的使用,当下拉到一定层度的时候.让组头还原,并且webView置顶.
![QQ20161121-6.png](http://upload-images.jianshu.io/upload_images/2100495-005d1c75e47e34a3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![QQ20161121-5.png](http://upload-images.jianshu.io/upload_images/2100495-71485c58857d15e8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

整体思路:
1.一个tableview.让webView作为headView.
2.让切换排行榜和最新上传的view作为组头
3.下面只有一个tableViewCell,里面是一个collectionView.
4.collectionView里面有两个cell,并且每一个cell里面对应两个控制器的view,
5.然后切换按钮,联动偏移collectionView,
(下面把最外层的tableView叫做大tableView,另外两个叫小tableView)

有一个地方需要注意:
下面嵌入的是tableview.当整个tableView下拉到webView消失的时候,下拉只是刷新的效果.并不会回到webView的顶部.

![下拉刷新.png](http://upload-images.jianshu.io/upload_images/2100495-85135458515c1d0a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

需求就是拉到100以下.就是刷新,100以上就是置顶到webView,(这个100根据你们项目需求,我个人测试过.100还不错)


在两个小 talView的控制器里面的scrollView代理方法中做回调.

    - (void)scrollViewDidScroll:(UIScrollView *)scrollView
    {
        NSLog(@"===>%f",scrollView.contentOffset.y);
        if (scrollView.contentOffset.y <= -100) {
            //回调偏移
            if (_topBlock != nil) {
                _topBlock();
            }
        }
    }


在大的tabView的控制器实现.collectionView的代理方法:

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

回调实现:

     _childListVC.topBlock = ^{
      [weakSelf didTopButton];
    }; 

大的tableView置顶

    -(void)didTopButton
    {
        [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }

在大的tableView里面的ScrollViewDelegate代理方法切换titleView.

    -(void)scrollViewDidScroll:(UIScrollView *)scrollView
    {
        if ([scrollView isKindOfClass:[UICollectionView class]]) {
            if (scrollView.contentOffset.x > screen_width * 0.5) {
                    _newLoadBtn.selected = YES;
                    _listBtn.selected = NO;
                [UIView animateWithDuration:0.5 animations:^{
                    self.slidingView.transform = CGAffineTransformMakeTranslation(screen_width*0.5 -60, 0);
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
            if (scrollView.contentOffset.y >= _headerView.height) {
                //那么就让其title更改.
                if (_isTableTitleView == NO) {
                    self.sectionBackView.frame = CGRectMake(0, 0, screen_width -  120, 30);
                    self.navigationItem.titleView = self.sectionBackView;//更改titleView
                    _isTableTitleView = YES;
                }
            }else{
                if (_isTableTitleView == YES) {
                    self.navigationItem.titleView = self.titleLableView;//还原为文字的View.
                    self.sectionBackView.frame = CGRectMake(60, 15, screen_width -  120, 30);
                    [self.sectionView addSubview:self.sectionBackView];
                    _isTableTitleView = NO;
                }
            }
        }
    }
  
注意:title的切换.最好都用titleView.如果一个是title.一个是titleView.不方便切换.我反正没有搞成功,你们可以试试.

![效果图1.gif](http://upload-images.jianshu.io/upload_images/2100495-439556ab92cd4f58.gif?imageMogr2/auto-orient/strip)

注:只为成长记录:希望能得到您们的宝贵意见.
