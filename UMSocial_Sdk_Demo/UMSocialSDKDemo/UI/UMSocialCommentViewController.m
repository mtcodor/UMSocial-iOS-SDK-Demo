//
//  UMSocialCommentViewController.m
//  SocialSDK
//
//  Created by Jiahuan Ye on 12-9-1.
//  Copyright (c) umeng.com All rights reserved.
//

#import "UMSocialCommentViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UMSocialAccountEntity.h"
#import "UMStringMock.h"
#import "UMSocialControllerServiceComment.h"
#import "UMSocialMacroDefine.h"
#import "UMSocialShareViewController.h"

@interface UMSocialCommentViewController ()

@end

@implementation UMSocialCommentViewController

-(void)dealloc
{
    [_socialController.socialDataService setUMSocialDelegate:nil];
    SAFE_ARC_RELEASE(_socialController);
    SAFE_ARC_RELEASE(_commentTableView);
    SAFE_ARC_RELEASE(_imageView);
    SAFE_ARC_RELEASE(_activityIndicatorView);
    SAFE_ARC_SUPER_DEALLOC();
}

- (void)viewDidLoad
{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    textLabel.numberOfLines = 4;
    textLabel.text = [UMStringMock commentMockString];
    [self.view addSubview:textLabel];
    SAFE_ARC_RELEASE(textLabel);
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,90 , 150, 120)];
    NSString *imageName = [NSString stringWithFormat:@"yinxing%d.jpg",rand()%4];
    _imageView.image = [UIImage imageNamed:imageName];
    [self.view addSubview:_imageView];
        
    UMSocialData *socialData = [[UMSocialData alloc] initWithIdentifier:@"UMSocialSDK" withTitle:nil];
    _socialController = [[UMSocialControllerServiceComment alloc] initWithUMSocialData:socialData];
    _socialController.socialDataService.socialData.commentText = textLabel.text;        //作为分享到微博内容"//"之后的文字
    _socialController.socialDataService.socialData.commentImage = _imageView.image;
    
    SAFE_ARC_RELEASE(socialData);
    
    UMSocialShareViewController *shareViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    if (shareViewController.postsArray != nil) {
        NSString *title = [[shareViewController.postsArray objectAtIndex:0] valueForKey:@"title"];
        textLabel.text = title;
        socialData.commentText = title;
    }

    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.center = CGPointMake(160, 150);
    [self.view addSubview:_activityIndicatorView];

    CGRect rect;
    if (self.tabBarController != nil) {
        rect = CGRectMake(0, 200, self.tabBarController.view.bounds.size.width, 220);
    }
    else{
        rect = CGRectMake(0, 200, self.view.frame.size.width, 220);
    }
    _commentTableView = [[UITableView alloc] initWithFrame:rect];
    _commentTableView.dataSource = self;
    _commentTableView.delegate = self;
    [self.view addSubview:_commentTableView];

    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SocialShareCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        SAFE_ARC_AUTORELEASE(cell);
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"评论列表";
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"获取评论列表数据";
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"直接发送评论";
    }
    if (indexPath.row == 3) {
        cell.textLabel.text = @"直接发送评论并分享到微博";
    }
    return cell;    
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        UINavigationController *commentList = [_socialController getSocialCommentListController];
        [self presentModalViewController:commentList animated:YES];
    }
    if (indexPath.row == 1) {
        [_activityIndicatorView startAnimating];
        
        [_socialController.socialDataService setUMSocialDelegate:self];
        [_socialController.socialDataService requestCommentList:(-1)];
    }
    if (indexPath.row == 2) {
        [_activityIndicatorView startAnimating];
        
        [_socialController.socialDataService setUMSocialDelegate:self];
        [_socialController.socialDataService postCommentWithContent:[UMStringMock commentMockString]];
    }
    if (indexPath.row == 3) {
        [_activityIndicatorView startAnimating];
        
        CLLocation *location = [[NSClassFromString(@"CLLocation") alloc] initWithLatitude:30.0 longitude:108.0];
        NSDictionary *snsDic = _socialController.socialDataService.socialData.socialAccount;
        NSMutableDictionary *shareToSNSDictionary = [[NSMutableDictionary alloc] init];
        for (id key in snsDic) {
            if (![key isEqualToString:@"defaultAccount"]&&![key isEqualToString:@"loginAccount"]) {
                NSLog(@"key is %@",key);
                [shareToSNSDictionary setObject:[[snsDic objectForKey:key] usid] forKey:key];
            }
        }
        [_socialController.socialDataService setUMSocialDelegate:self];
        [_socialController.socialDataService postCommentWithContent:[UMStringMock commentMockString] image:_socialController.socialData.commentImage templateText:_socialController.socialData.commentText  location:location shareToSNSWithUsid:shareToSNSDictionary];
        SAFE_ARC_RELEASE(location);
        SAFE_ARC_RELEASE(shareToSNSDictionary);
    }
}

#pragma UMSocialDelegate
-(void)didFinishGetUMSocialDataResponse:(UMSocialResponseEntity *)response
{
    NSString *title = nil;
    NSString *message = nil;
    [_activityIndicatorView stopAnimating];
    if (response.responseCode == UMSResponseCodeSuccess) {
        if (response.responseType == UMSResponseAddComment) {
            title = @"成功";
            message = @"亲，您刚才调用的是发送评论的数据级接口，如果要获取发送结果，要像demo这样实现回调方法~";
            
        }
        if (response.responseType == UMSResponseGetCommentList) {
            title = @"成功";
            message = @"亲，您刚才调用的是获取评论的数据级接口，如果要获取发送结果，要像demo这样实现回调方法,数据在respose的data里面~";
        }        
    }
    else
    {
        title = @"失败";
        message = @"亲，您刚才调用的接口失败了，具体原因请看到回调方法response对象的responseCode和message~";
    }
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView show];
    SAFE_ARC_RELEASE(alertView);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        _commentTableView.frame = CGRectMake(_commentTableView.frame.origin.x, _commentTableView.frame.origin.y, self.tabBarController.view.bounds.size.width, _commentTableView.frame.size.height);
        if (_commentTableView.frame.origin.y + _commentTableView.frame.size.height > self.tabBarController.view.bounds.size.width) {
            _commentTableView.center = CGPointMake(50 + _commentTableView.frame.size.width,_commentTableView.frame.size.height/2);
        }
    }
    else{
        _commentTableView.frame = CGRectMake(0, 200, self.tabBarController.view.bounds.size.width, _commentTableView.frame.size.height);
    }
}
@end
