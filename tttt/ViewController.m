//
//  ViewController.m
//  tttt
//
//  Created by 李五民 on 15/10/27.
//  Copyright © 2015年 李五民. All rights reserved.
//

#import "ViewController.h"
#import "DLDownloadMagager.h"
#import "DLURLSessionOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DLDownloadMagager *manager = [[DLDownloadMagager alloc] init];
    DLURLSessionOperation *operation1 = [[DLURLSessionOperation alloc] initWithSession:manager.session URLString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    //operation1.queuePriority = 1;
    DLURLSessionOperation *operation2 = [[DLURLSessionOperation alloc] initWithSession:manager.session URLString:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"];
    //operation2.queuePriority = 2;
    DLURLSessionOperation *operation3 = [[DLURLSessionOperation alloc] initWithSession:manager.session URLString:@"http://120.25.226.186:32812/resources/videos/minion_03.mp4"];
    //operation3.queuePriority = 3;
//    [manager addOperationWithUrlString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
//    [manager addOperationWithUrlString:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"];
//    [manager addOperationWithUrlString:@"http://120.25.226.186:32812/resources/videos/minion_03.mp4"];
    //[operation1 addDependency:operation2];
    [manager addOperation:operation1];
//    double delayInSeconds = 0.5;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [operation1 cancel];
//    });
    [manager addOperation:operation2];
    [manager addOperation:operation3];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
