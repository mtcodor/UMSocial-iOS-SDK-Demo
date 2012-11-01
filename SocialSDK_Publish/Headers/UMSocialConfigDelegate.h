//
//  UMSocialConfigDelegate.h
//  SocialSDK
//
//  Created by jiahuan ye on 12-8-21.
//  Copyright (c) 2012年 umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 在UI层的api中进行的一些设置，例如出现的分享平台等。
 */
@protocol UMSocialConfigDelegate <NSObject>

@optional

/** 
 设置显示的sns平台类型
 
 @param 由NSNumber组成的NSArray，可以选的有新浪微博、腾讯微博、人人网、豆瓣。我们分别用`UMShareToTypeSina`、`UMShareToTypeTenc`、`UMShareToTypeRenr`、`UMShareToTypeDouban`，、`UMShareToTypeQzone`然后分别初始化成NSNumber，再组成NSArray
 */
- (NSArray *)shareToPlatforms;

/** 
 设置评论页面是否出现分享按钮,默认为出现,出现的平台默认为4个，可以用shareToPlatforms设置

 */
- (BOOL)shouldCommentWithShare;

/** 
 设置评论页面是否出现分享地理位置信息的按钮，默认出现
 
 */
- (BOOL)shouldCommentWithLocation;

/**
 设置分享编辑页面是否等待完成之后再关闭页面还是立即关闭，默认等待分享完成之后再关闭
 
 */
- (BOOL)shouldShareSynchronous;

/** 
 设置所有页面背景颜色，默认的颜色是[UIColor colorWithRed:0.22 green:0.24  blue:0.27 alpha:1.0]，如果想改变上面导航栏的颜色，可以换相应的图片
 */
- (UIColor *)defaultColor;


/**
 分享列表中第二个section最后一栏返回一个自定义的`UITableViewCell`对象，sdk会取该`UITableViewCell`对象的textLabel的text和imageView的image，分别作为该UITableViewCell的文字和图片
 
 @return `UITableViewCell`对象
 */
-(UITableViewCell *)customCellForShareListTableView;

/**
 点击该自定义`UITableViewCell`后的回调操作
 
 */
-(void)didSelectShareListTableViewCell;

@end
