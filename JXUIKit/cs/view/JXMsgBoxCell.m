//
//  JXMsgBoxCell.m
//  mcs_demo
//
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import "JXMsgBoxCell.h"
#import "JXBubbleView+Text.h"

@interface JXMsgBoxCell ()

@end

@implementation JXMsgBoxCell

- (BOOL)isCustomBubbleView:(JXMessage *)message {
    return YES;
}

- (void)setCustomMessage:(JXMessage *)message {
    self.nameLabel.text = message.nickname;
    self.avatarView.image = JXImage(@"head_receiver");
    //    self.bubbleView.textLabel.text = message.textToDisplay;
    if (message.attributedText) {
        [message.attributedText
                addAttribute:NSFontAttributeName
                       value:self.messageTextFont
                       range:NSMakeRange(0, [message.attributedText.string length])];
        [self.bubbleView.textLabel setAttributedText:message.attributedText];
    } else {
        self.bubbleView.textLabel.text = message.textWithEmoji;
        self.bubbleView.textLabel.font = self.messageTextFont;
    }
    self.bubbleView.textLabel.textColor = self.messageTextColor;
    [self updateMessageStatus];
}

- (void)setupCustomBubbleView:(JXMessage *)message {
    [self.bubbleView setupTextBubbleView];
    self.bubbleView.textLabel.font = self.messageTextFont;
    self.bubbleView.textLabel.textColor = self.messageTextColor;
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin message:(JXMessage *)message {
    [self.bubbleView updateTextMargin:bubbleMargin];
}

@end
