//
//  DLURLSessionOperation.h
//  DownloadManager
//
//  Created by 李五民 on 15/10/27.
//  Copyright © 2015年 Ideamakerz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLURLSessionOperation : NSOperation

- (instancetype)initWithSession:(NSURLSession *)session URLString:(NSString *)urlString;

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSURLSession *session;
- (void)completeOperation;
@end
