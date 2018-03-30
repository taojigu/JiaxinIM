//
//  JXEmotion.h
//  JXUIKit
//
//  Created by 刘佳 on 2017/1/20.
//  Copyright © 2017年 DY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JXEmotionTypeNomal,
    JXEmotionTypeEmoji,
} JXEmotionType;

@class JXEmotion;
@interface JXEmotionPackage : NSObject

- (instancetype)initWithEmotions:(NSArray<JXEmotion *> *)emotions andType:(JXEmotionType)type;

@property(nonatomic, strong) NSArray<JXEmotion *> *emotions;

@property(nonatomic, assign) JXEmotionType type;

@end

@interface JXEmotion : NSObject


/**
 表情图片名称
 */
@property(nonatomic, copy) NSString *png;

/**
 表情名称
 */
@property(nonatomic, copy) NSString *chs;

/**
 表情传输字符串
 */
@property(nonatomic, copy) NSString *reg;

/**
 emoji表情
 */
@property(nonatomic, copy) NSString *emoji;

/**
 构造方法
 */
- (instancetype)initWithDict:(NSDictionary *)dict;

/**
 获取表情所有图片

 @param path 表情包plist文件完整路径
 @return 表情包表情数组
 */
+ (NSArray *)emotionsWithPlistPath:(NSString *)path;

+ (NSAttributedString *)attributedEmojiStringWithText:(NSString *)str;

+ (NSMutableString *)mutableStringWithText:(NSString *)str;

+ (NSAttributedString *)attStringFromTextForInputView:(NSString *)aInputText;

@end

@interface JXTextAttachment : NSTextAttachment

@property(nonatomic, strong) NSString *imageName;

@end
