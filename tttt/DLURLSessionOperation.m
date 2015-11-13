//
//  DLURLSessionOperation.m
//  DownloadManager
//
//  Created by 李五民 on 15/10/27.
//  Copyright © 2015年 Ideamakerz. All rights reserved.
//

#import "DLURLSessionOperation.h"
#import "NSString+hash.h"

@interface DLURLSessionOperation ()
{
    BOOL _finished;
    BOOL _executing;
}
@property (nonatomic, assign) NSUInteger downloadedLength;

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, copy) NSString *contentPath;


@end

@implementation DLURLSessionOperation

//初始化
- (instancetype)initWithSession:(NSURLSession *)session URLString:(NSString *)urlString {
    
    if (self = [super init]) {
        self.urlString = urlString;
        self.session = session;
        self.contentPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:urlString];;
    }
    return self;
}

//下载任务
- (NSURLSessionDownloadTask *)task{
    
    if (_task == nil) {
        self.downloadedLength = [NSData dataWithContentsOfFile:_contentPath].length;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.urlString.md5String]];
        
        if (dict){
            NSInteger contentLength = [dict[self.urlString] integerValue];
            
            if (self.downloadedLength == contentLength) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                }];
                
                return nil;
            }
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        
        [request setValue:[NSString stringWithFormat:@"bytes=%zd-",self.downloadedLength] forHTTPHeaderField:@"Range"];
        
        _task = [self.session downloadTaskWithRequest:request];
        _task.taskDescription = self.urlString;
        
    }
    
    return _task;
}

//开始下载
- (void)start {
    
    [self.task resume];
}

//暂停下载
- (void)suspend{
    
    [self.task suspend];
}

- (void)cancel {
    [super cancel];
    [self.task cancel];
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
