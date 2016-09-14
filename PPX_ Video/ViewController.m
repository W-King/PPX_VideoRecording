//
//  ViewController.m
//  PPX_ Video
//
//  Created by pipixia on 16/9/12.
//  Copyright © 2016年 pipixia. All rights reserved.
//

#import "ViewController.h"
#import "PPX_RecordVideoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor brownColor];
    
    UIButton *recordVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordVideoButton.backgroundColor = [UIColor redColor];
    recordVideoButton.frame = CGRectMake(100, 100, 100, 100);
    [recordVideoButton setTitle:@"录制" forState:UIControlStateNormal];
    [recordVideoButton addTarget:self action:@selector(recordVideoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordVideoButton];
}
- (void)recordVideoButtonClicked
{
    PPX_RecordVideoViewController *recordVideoVC = [[PPX_RecordVideoViewController alloc]init];
    [self.navigationController pushViewController:recordVideoVC animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
