//
//  KSActionSheetView.h
//  KSActionSheet
//
//  Created by kivensong on 16/9/15.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSActionSheetView : UIView
- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitleArray:(NSArray *)titleArray;

- (void)showActionSheet;
- (void)hideActionSheet;
- (void)setButtonTile:(NSString*)title atIndex:(int)index;
- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size;
- (void)setButtonTitleColor:(UIColor *)color bgColor:(UIColor *)bgcolor fontSize:(CGFloat)size atIndex:(int)index;
- (void)setCancelButtonTitleColor:(UIColor *)color bgColor:(UIColor *)bgcolor fontSize:(CGFloat)size;

@end

@protocol KSActionSheetDelegate <NSObject>
@optional
- (void)actionSheetCancel:(KSActionSheetView *)actionSheet;
- (void)actionSheet:(KSActionSheetView *)sheet clickedButtonIndex:(NSInteger)buttonIndex;

@end
