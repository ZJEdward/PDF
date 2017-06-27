//
//  ViewController.m
//  PDF
//
//  Created by Edward on 2017/6/27.
//  Copyright © 2017年 钟进. All rights reserved.
//

#import "ViewController.h"
#import "PDFViewController.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)pushPDFVC:(id)sender {
    
    PDFViewController *pdfVC = [PDFViewController new];
    pdfVC.fileURL = @"https://cxd-contract.oss-cn-beijing.aliyuncs.com/pdf/17/04/2017041700000210.pdf";
    pdfVC.fileID = [NSString stringWithFormat:@"%@.pdf", @"000123"];
    [self.navigationController pushViewController:pdfVC animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
