//
//  KSActionSheetView.m
//  KSActionSheet
//
//  Created by kivensong on 16/9/15.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "KSActionSheetView.h"

#define SCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)

#define GetAValue(argb) (unsigned char)((argb) >> 24)
#define GetRValue(argb) (unsigned char)((argb) >> 16)
#define GetGValue(argb) (unsigned char)((argb) >> 8)
#define GetBValue(argb) (unsigned char)(argb)
#define ARGB2UICOLOR2(argb) [UIColor colorWithRed:(GetRValue((argb)) / 255.0) green:(GetGValue((argb)) / 255.0) blue:(GetBValue((argb)) / 255.0) alpha:(GetAValue((argb)) / 255.0)]
#define RGB2UICOLOR2(rgb) [UIColor colorWithRed:(GetRValue((rgb)) / 255.0) green:(GetGValue((rgb)) / 255.0) blue:(GetBValue((rgb)) / 255.0) alpha:1.0]

const static CGFloat kTitleFontSize = 15.0;
const static CGFloat kButtonHeight = 50.0;
const static CGFloat kCommonLineHeight = 1.0;
const static CGFloat kCancelLineHeight = 8.0;
static CGFloat contentViewWidth = 0;
static CGFloat contentViewHeight = 0;

@interface KSActionSheetView ()
@property (weak, nonatomic) id<KSActionSheetDelegate> delegate;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *cancelButtonTitle;

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *buttonView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIWindow* overWindow;

@property (strong, nonatomic) NSMutableArray *buttonTitleArray;

@end

@implementation KSActionSheetView

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _title = title;
        _delegate = delegate;
        _cancelButtonTitle = cancelButtonTitle;
        _buttonArray = [NSMutableArray array];
        _buttonTitleArray = [NSMutableArray array];
        
        va_list args;
        va_start(args, otherButtonTitles);
        if (otherButtonTitles) {
            [_buttonTitleArray addObject:otherButtonTitles];
            while (1) {
                NSString *otherButtonTitle = va_arg(args, NSString *);
                if (otherButtonTitle == nil) {
                    break;
                } else {
                    [_buttonTitleArray addObject:otherButtonTitle];
                }
            }
          
        }
        va_end(args);
        
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.alpha = 0.4;
        _backgroundView.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonPressed:)];
        [_backgroundView addGestureRecognizer:tapGestureRecognizer];
        [self addSubview:_backgroundView];
        
        [self initContentView];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitleArray:(NSArray *)titleArray
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _title = title;
        _delegate = delegate;
        _cancelButtonTitle = cancelButtonTitle;
        _buttonArray = [NSMutableArray array];
        _buttonTitleArray = [titleArray mutableCopy];
        
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.alpha = 0.4;
        _backgroundView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonPressed:)];
        [_backgroundView addGestureRecognizer:tapGestureRecognizer];
        [self addSubview:_backgroundView];
        
        [self initContentView];
    }
    return self;
}

- (void)setButtonTile:(NSString*)title atIndex:(int)index
{
    if (index >= self.buttonArray.count || !title ||[title isEqualToString:@""]) {
        return;
    }
    
    UIButton* btn = self.buttonArray[index];
    [btn setTitle:title forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)initContentView {
    contentViewWidth = SCREEN_WIDTH;
    contentViewHeight = 0;
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    
    _buttonView = [[UIView alloc] init];
    _buttonView.backgroundColor = [UIColor whiteColor];
    
    [self initTitle];
    [self initButtons];
    [self initCancelButton];
    
    _contentView.frame = CGRectMake(0, self.frame.size.height, contentViewWidth, contentViewHeight);
    [self addSubview:_contentView];
}

- (void)initTitle {
    if (_title != nil && ![_title isEqualToString:@""]) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentViewWidth, kButtonHeight)];
        _titleLabel.text = _title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        [_buttonView addSubview:_titleLabel];
        contentViewHeight += _titleLabel.frame.size.height;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, contentViewHeight, contentViewWidth, kCommonLineHeight)];
        lineView.backgroundColor = [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1.0];
        [_buttonView addSubview:lineView];
        contentViewHeight += kCommonLineHeight;
    }
}

- (void)initButtons {
    if (_buttonTitleArray.count > 0) {
        NSInteger count = _buttonTitleArray.count;
        for (int i = 0; i < count; i++) {
            UIButton* button = [self creatCommonBtn:CGRectMake(0, contentViewHeight, contentViewWidth, kButtonHeight) withTitle:self.buttonTitleArray[i]];
            [_buttonView addSubview:button];
            contentViewHeight += button.frame.size.height;
            
            CGFloat lineHeight = 0;
            if (i != count -1) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, contentViewHeight, contentViewWidth, kCommonLineHeight)];
                lineView.backgroundColor = RGB2UICOLOR2(0xe6e6e6);
                [_buttonView addSubview:lineView];
                lineHeight= kCommonLineHeight;
            }
            
            contentViewHeight += lineHeight;
        }
        
        _buttonView.frame = CGRectMake(0, 0, contentViewWidth, contentViewHeight);
        [_contentView addSubview:_buttonView];
    }
}

-(UIButton*)creatCommonBtn:(CGRect)frame withTitle:(NSString*)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, contentViewHeight + kCommonLineHeight, contentViewWidth, kButtonHeight)];
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:RGB2UICOLOR2(0x000000) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonArray addObject:button];
    return button;
}

- (void)initCancelButton {
    if (_cancelButtonTitle != nil) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, contentViewHeight, contentViewWidth, kCancelLineHeight)];
        lineView.backgroundColor = RGB2UICOLOR2(0xe6e6e6);
        [_buttonView addSubview:lineView];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, contentViewHeight + kCancelLineHeight, contentViewWidth, kButtonHeight)];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
        [_cancelButton setTitleColor:RGB2UICOLOR2(0x000000) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_cancelButton];
        contentViewHeight += _cancelButton.frame.size.height + kCancelLineHeight;
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self initContentView];
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle {
    _cancelButtonTitle = cancelButtonTitle;
    [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
}

- (void)showActionSheet {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIWindow *lastWindow = (UIWindow *)[windows lastObject];
    self.overWindow = nil;
    
    self.overWindow = [[UIWindow alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.overWindow setWindowLevel:lastWindow.windowLevel + 1];
    [self.overWindow addSubview:self];
    [self.overWindow makeKeyAndVisible];
    
    [self addAnimation];
}

- (void)hideActionSheet {
    [self removeAnimation];
}

- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size {
    if (color != nil) {
        _titleLabel.textColor = color;
    }
    
    if (size > 0) {
        _titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setButtonTitleColor:(UIColor *)color bgColor:(UIColor *)bgcolor fontSize:(CGFloat)size atIndex:(int)index {
    UIButton *button = _buttonArray[index];
    if (color != nil) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    if (bgcolor != nil) {
        [button setBackgroundColor:bgcolor];
    }
    
    if (size > 0) {
        button.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setCancelButtonTitleColor:(UIColor *)color bgColor:(UIColor *)bgcolor fontSize:(CGFloat)size {
    if (color != nil) {
        [_cancelButton setTitleColor:color forState:UIControlStateNormal];
    }
    
    if (bgcolor != nil) {
        [_cancelButton setBackgroundColor:bgcolor];
    }
    
    if (size > 0) {
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)addAnimation {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _contentView.frame = CGRectMake(_contentView.frame.origin.x, SCREEN_HEIGHT - _contentView.frame.size.height, _contentView.frame.size.width, _contentView.frame.size.height);
        _backgroundView.alpha = 0.2;
    } completion:^(BOOL finished) {
    }];
}

- (void)removeAnimation {
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        _contentView.frame = CGRectMake(_contentView.frame.origin.x, SCREEN_HEIGHT, _contentView.frame.size.width, _contentView.frame.size.height);
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.overWindow = nil;
    }];
}

- (void)buttonPressed:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedButtonIndex:)]) {
        for (int i = 0; i < _buttonArray.count; i++) {
            if (button == _buttonArray[i]) {
                [_delegate actionSheet:self clickedButtonIndex:i];
                break;
            }
        }
    }
    [self hideActionSheet];
}

- (void)cancelButtonPressed:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [_delegate actionSheetCancel:self];
    }
    [self hideActionSheet];
}

@end
