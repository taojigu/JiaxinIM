//
//  GTMcsChatConfig.h
//  JXUIKit
//
//  Created by 刘佳 on 2017/12/15.
//  Copyright © 2017年 DY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JXGoodsInfoModel <NSObject>

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, strong) UIImage *image;

@end

@interface JXMcsChatConfig : NSObject

/**
 商品信息模型
 */
@property(nonatomic, strong) id<JXGoodsInfoModel> goodsInfo;

/**
 导航栏颜色
 */
@property(nonatomic, strong) UIColor *navColor;

/**
 请求人工客服按钮图片
 */
@property(nonatomic, strong) UIImage *requestCSItemImage;

/**
 消息箱按钮图片
 */
@property(nonatomic, strong) UIImage *msgBoxItemImage;

/**
 留言按钮图片
 */
@property(nonatomic, strong) UIImage *leaveMsgItemImage;

/**
 关闭会话按钮图片
 */
@property(nonatomic, strong) UIImage *terminalCSItemImage;

/**
 是否显示消息箱
 */
@property(nonatomic, assign) BOOL showMsgBoxItem;

/**
 访客头像
 */
@property(nonatomic, strong) UIImage *avatorImage;

/**
 导航栏文字颜色
 */
@property(nonatomic, strong) UIColor *navTitleColor;

/**
 导航栏文字字体
 */
@property(nonatomic, strong) UIFont *navFont;

+ (instancetype)defaultConfig;

@end
