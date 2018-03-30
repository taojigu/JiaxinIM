//
//  JXMessage.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseModel.h"
#import "JXEnumDefs.h"
#import "UIKit/UIKit.h"

@class JXConversation;

@interface JXMessage : JXBaseModel

/*!
 @class
 @brief 发送方
 */
@property(nonatomic, readonly) NSString *sender;

/*!
 @class
 @brief 接收方
 */
@property(nonatomic, readonly) NSString *receiver;

/*!
 @class
 @brief 消息ID (消息的唯一标识)
 */
@property(nonatomic, readonly) NSString *messageId;

/*!
 @class
 @brief 群聊/聊天室时，获取群聊/聊天室名称
 */
@property(nonatomic, readonly) NSString *conversationChatter;

/*!
 @class
 @brief 消息类型 （文本，语音，图片，位置。。。。）
 */
@property(nonatomic, readonly) JXMessageType type;

/*!
 @class
 @brief 聊天类型 （单聊，群聊，聊天室。。。）
 */
@property(nonatomic, readonly) JXChatType chatType;

/*!
 @class
 @brief 消息的方向 （发送或者接收）
 */
@property(nonatomic, assign) JXMessageDirection direction;

/*!
 @class
 @brief 消息的状态
 */
@property(nonatomic, readonly) JXMessageStatus status;

/*!
 @class
 @brief 创建消息的时间戳
 */
@property(nonatomic, readonly) NSTimeInterval timestamp;

/*!
 @class
 @brief 文本消息的内容
 */
@property(nonatomic, readonly) NSString *textToDisplay;

/*!
 @class
 @brief 文件消息的本地URL字符串
 */
@property(nonatomic, readonly) NSString *localURL;

/*!
 @class
 @brief 文件消息的文件名
 */
@property(nonatomic, readonly) NSString *fileName;

/*!
 @class
 @brief 文件消息的大小
 */
@property(nonatomic, readonly) NSInteger fileSize;

/*!
 @class
 @brief 文件消息的过期时间
 */
@property(nonatomic, readonly) NSTimeInterval expiredTime;

/*!
 @class
 @brief 消息的时长
 */
@property(nonatomic, readonly) NSInteger duration;


/*!
 @class
 @brief 扩展消息的数据
 */
@property(nonatomic, readonly) NSMutableDictionary *extData;

/*!
 @class
 @brief 是否已读  （yes 为已读， no 为未读）
 */
@property(nonatomic, assign) BOOL isRead;

/*!
 @class
 @brief 是否临时消息 (if yes, sdk 不会存储该消息)
 */
@property(nonatomic, assign) BOOL isRobot;

/*!
 @class
 @brief 位置消息的地址描述
 */
@property(nonatomic, copy) NSString *label;

/*!
 @class
 @brief 位置消息的纬度
 */
@property(nonatomic, assign) double latitude;

/*!
 @class
 @brief 位置消息的经度
 */
@property(nonatomic, assign) double longitude;

/*!
 @class
 @brief 富文本(图文)消息的链接
 */
@property(nonatomic, copy) NSString *linkURL;

/*!
 @class
 @brief 富文本(图文)消息的标题
 */
@property(nonatomic, copy) NSString *title;

/*!
 @class
 @brief 富文本(图文)消息的内容
 */
@property(nonatomic, copy) NSString *content;


/*!
 @class
 @brief 图文消息创建时间
 */
@property (nonatomic, copy) NSString *date;

/*!
 @class
 @brief 图文消息图片的链接
 */
//@property (nonatomic, copy) NSString *picUrl;

/*!
 @method
 @brief 通过接收方和聊天类型初始化一个消息对象
 @param to    消息接收方
 @param chatType    消息类型
 @discussion
 @result instancetype  消息对象本身
 */
- (instancetype)initWithReceiver:(NSString *)to andType:(JXChatType)chatType;

/*!
 @method
 @brief 通过会话初始化一个消息对象
 @param conversation    消息接收方
 @discussion
 @result instancetype  消息对象本身
 */
- (instancetype)initWithConversation:(JXConversation *)conversation;

/*!
 @method
 @brief 通过会话初始化一个消息对象
 @param conversation    消息发送方
 @discussion
 @result instancetype  消息对象本身
 */
- (instancetype)initWithSender:(NSString *)from andType:(JXChatType)chatType;

/*!
 @method
 @brief 自定义消息类型
 */
- (void)setCustomMessageType:(NSInteger)type;

/*!
 @method
 @brief  设置文本消息的文本内容
 @param content    文本内容
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setTextContent:(NSString *)content;

/*!
 @method
 @brief  设置文件消息的内容
 @param filePath    文件内容
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setFileContent:(NSData *)filePath;

/*!
 @method
 @brief 设置图片消息的内容
 @param imageData    图片data
 @param compressionRate    压缩比率
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
//- (BOOL)setImageContent:(UIImage *)image isOriginal:(BOOL)isOriginal;
- (BOOL)setImageContent:(NSData *)imageData compressionRate:(CGFloat)rate;


/**
 设置图片

 @param imageUrl
 @return 
 */
- (BOOL)setImageUrl:(NSString *)imageUrl ;

/*!
 @method
 @brief 设置音频消息的内容
 @param filePath    文件路径
 @param duration    时长
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setAudioContent:(NSString *)filePath duration:(NSInteger)duration;

/*!
 @method
 @brief 设置视频消息的内容
 @param filePath    文件路径
 @param thumbPath   文件的首路径 （文件名）
 @param duration    时长
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setVideoContent:(NSString *)filePath thumbPath:(NSString *)thumbPath duration:(NSInteger)duration;

/*!
 @method
 @brief 设置位置消息的内容
 @param label    位置消息的地址
 @param latitude    纬度
 @param longitude   经度
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setLocContent:(NSString *)label latitude:(double)latitude longitude:(double)longitude;

/*!
 @method
 @brief 设置富文本消息的内容
 @param content  文本内容
 @param title    文本标题
 @param url      附带链接
 @param imageData  附带图片
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setRichTextContent:(NSString *)content
                     title:(NSString *)title
                   linkURL:(NSString *)url
                     image:(NSData *)imageData;
/*!
 @method
 @brief 设置富文本消息的内容
 @param content  文本内容
 @param title    文本标题
 @param url      附带链接
 @param imageURL  附带图片地址
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setRichTextContent:(NSString *)content
                      title:(NSString *)title
                    linkURL:(NSString *)url
                   imageURL:(NSString *)imageURL;


/**
 设置图文消息的内容

 @param content 文本内容
 @param title 文本标题
 @param picUrl 图片链接
 @param linkUrl 跳转链接
 @param date 创建时间
 @return yes为成功 no为失败
 */
- (BOOL)setPicTextContent:(NSString *)content
                    title:(NSString *)title
                   picUrl:(NSString *)picUrl
                  linkUrl:(NSString *)linkUrl
                     date:(NSString *)date;

/*!
 @method
 @brief 设置提示消息的内容
 @param tips    提示内容
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setTipsContent:(NSString *)tips;

/*!
 @method
 @brief 设置预知消息的内容
 @param content    消息内容
 @param type       消息类型
 @discussion
 @result BOOL  yes 为设置成功，no 为设置失败
 */
- (BOOL)setForeseeContent:(NSString *)content andType:(JXMessageType)type;

/*!
 @method
 @brief 获得URL的首路径 （文件名）
 @discussion
 @result NSString  显示的URL字符串
 */
- (NSString *)thumbUrlToDisplay;

@end
