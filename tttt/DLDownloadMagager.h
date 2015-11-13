//
//  DLDownloadMagager.h
//  DownLoadTest
//
//  Created by 李五民 on 15/10/26.
//  Copyright © 2015年 李五民. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLURLSessionOperation.h"
@interface DLDownloadMagager : NSObject

- (void)addOperationWithUrlString:(NSString *)urlString;
@property (nonatomic ,strong) NSURLSession *session;
- (void)addOperation:(DLURLSessionOperation *)op;
@property (nonatomic, copy) NSString *urlString;
@end
