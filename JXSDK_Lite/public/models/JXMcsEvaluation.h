//
//  JXMcsEvaluation.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JXSatisficationType) {
    JXSatisficationTypeSingleSelection = 1,
    JXSatisficationTypeScore,
    JXSatisficationTypeStar,
    JXSatisficationTypeCustom
};

@interface JXMcsEvaluationItem : NSObject

@property(nonatomic, copy) NSString *text;
@property(nonatomic, assign) NSInteger value;

@end

@interface JXMcsEvaluation : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *thanksMsg;
@property(nonatomic, strong) NSArray *itemList;
@property (nonatomic, assign) BOOL satisfyInviteFlag;
@property (nonatomic, assign) BOOL satisfyThanksFlag;
@property(nonatomic, assign) JXSatisficationType type;

@end
