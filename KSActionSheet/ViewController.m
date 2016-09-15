//
//  ViewController.m
//  KSActionSheet
//
//  Created by kivensong on 16/9/15.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "ViewController.h"
#import "KSActionSheetView.h"

@interface ViewController ()<KSActionSheetDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)testBtnClick:(id)sender {
    KSActionSheetView* actionSheet = [[KSActionSheetView alloc] initWithTitle:@"测试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开始", @"停止", nil];
    [actionSheet showActionSheet];
}


- (void)actionSheetCancel:(KSActionSheetView *)actionSheet
{
    NSLog(@"cancel btn click");
}
- (void)actionSheet:(KSActionSheetView *)sheet clickedButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"index:%d btn click", (int)buttonIndex);
}

@end
