//
//  DLDownloadMagager.m
//  DownLoadTest
//
//  Created by 李五民 on 15/10/26.
//  Copyright © 2015年 李五民. All rights reserved.
//

#import "DLDownloadMagager.h"
#import "NSString+Hash.h"
//#import "DLDownloadModel.h"
#import "DLURLSessionOperation.h"

@interface DLDownloadMagager()<NSURLSessionDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSOutputStream *stream;
@property (nonatomic, assign) NSUInteger contentLength;
@property (nonatomic, assign) NSUInteger downloadedLength;
@property (nonatomic, copy) NSString *contentPath;
@property (nonatomic, strong) NSMutableArray *downloadArray;
//@property (nonatomic, strong) DLDownloadModel *downloadModel;

@end

@implementation DLDownloadMagager

- (id)init{
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"yanxiu.tttt"];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        self.downloadArray = [[NSMutableArray alloc] init];
        //self.contentPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"minion2.mp4"];
    }
    return self;
}

//输入管道
-(NSOutputStream *)stream{
    
    if (_stream == nil) {
        _stream = [NSOutputStream outputStreamToFileAtPath:_contentPath append:YES];
    }
    
    return _stream;
}

#pragma mark - session代理方法
//接受到数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    //通过管道写入下载数据
    [self.stream write:data.bytes maxLength:data.length];
    NSLog(@"%@",dataTask.taskDescription);
    //拿到当前下载长度
    self.downloadedLength += data.length;
    //求得下载进度
    Float32 progress = 1.0 * self.downloadedLength / self.contentLength;
    
    //把下载进度传给代理
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        if (self.progress) {
//            self.progress(progress);
//        }
//    }];
    
    
}

//接受到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    //拿到内容数据长度
    NSUInteger contentLength = [response.allHeaderFields[@"Content-Length"] integerValue];
    
    
    //赋值数据总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.urlString.md5String]];
    if (dict == nil){
        self.contentLength = contentLength;
        
        dict = [NSMutableDictionary dictionary];
        dict[dataTask.taskDescription] = @(self.contentLength);
        [dict writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.urlString.md5String] atomically:YES];
    }else{
        self.contentLength = [dict[self.urlString] integerValue];
    }
    
    //打开输入管道
    [self.stream open];
    
    //允许接受请求
    completionHandler(NSURLSessionResponseAllow);
}

////完成
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//    
//    
////    //关闭输入管道
////    [self.stream close];
////    
////    //通知代理已下载完毕
////    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//////        if (self.completion){
//////            self.completion();
//////        }
////    }];
////    
////    
////    //清空任务，输入管道
////    self.stream = nil;
////    task = nil;
//}

- (void)addOperationWithUrlString:(NSString *)urlString {
    DLURLSessionOperation *operation = [[DLURLSessionOperation alloc] initWithSession:self.session URLString:urlString];
    //[self.queue addOperation:operation];
    //[operation start];
    self.urlString = urlString;
//    DLDownloadModel *downloadModel = [[DLDownloadModel alloc] init];
//    downloadModel.operation = operation;
//    downloadModel.urlModel.url = urlString;
}

- (void)addOperation:(DLURLSessionOperation *)op{

//    [self.queue addOperationWithBlock:^{
//        [op start];
//    }];
    [self.downloadArray addObject:op];
    [self.queue addOperation:op];
    //[self.queue addOperation:<#(nonnull NSOperation *)#>]
}


#pragma mark - NSURLSession Delegates -
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%@",downloadTask.taskDescription);
//    for(NSMutableDictionary *downloadDict in downloadingArray)
//    {
//        if([downloadTask isEqual:[downloadDict objectForKey:kMZDownloadKeyTask]])
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                float progress = (double)downloadTask.countOfBytesReceived/(double)downloadTask.countOfBytesExpectedToReceive;
//                
//                NSTimeInterval downloadTime = -1 * [[downloadDict objectForKey:kMZDownloadKeyStartTime] timeIntervalSinceNow];
//                
//                float speed = totalBytesWritten / downloadTime;
//                
//                NSInteger indexOfDownloadDict = [downloadingArray indexOfObject:downloadDict];
//                NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:indexOfDownloadDict inSection:0];
//                MZDownloadingCell *cell = (MZDownloadingCell *)[bgDownloadTableView cellForRowAtIndexPath:indexPathToRefresh];
//                
//                [cell.progressDownload setProgress:progress];
//                
//                NSMutableString *remainingTimeStr = [[NSMutableString alloc] init];
//                
//                unsigned long long remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten;
//                
//                int remainingTime = (int)(remainingContentLength / speed);
//                int hours = remainingTime / 3600;
//                int minutes = (remainingTime - hours * 3600) / 60;
//                int seconds = remainingTime - hours * 3600 - minutes * 60;
//                
//                if(hours>0)
//                    [remainingTimeStr appendFormat:@"%d Hours ",hours];
//                if(minutes>0)
//                    [remainingTimeStr appendFormat:@"%d Min ",minutes];
//                if(seconds>0)
//                    [remainingTimeStr appendFormat:@"%d sec",seconds];
//                
//                NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
//                                             [MZUtility calculateFileSizeInUnit:(unsigned long long)totalBytesExpectedToWrite],
//                                             [MZUtility calculateUnit:(unsigned long long)totalBytesExpectedToWrite]];
//                
//                NSMutableString *detailLabelText = [NSMutableString stringWithFormat:@"File Size: %@\nDownloaded: %.2f %@ (%.2f%%)\nSpeed: %.2f %@/sec\n",fileSizeInUnits,
//                                                    [MZUtility calculateFileSizeInUnit:(unsigned long long)totalBytesWritten],
//                                                    [MZUtility calculateUnit:(unsigned long long)totalBytesWritten],progress*100,
//                                                    [MZUtility calculateFileSizeInUnit:(unsigned long long) speed],
//                                                    [MZUtility calculateUnit:(unsigned long long)speed]
//                                                    ];
//                
//                if(progress == 1.0)
//                    [detailLabelText appendFormat:@"Time Left: Please wait..."];
//                else
//                    [detailLabelText appendFormat:@"Time Left: %@",remainingTimeStr];
//                
//                [cell.lblDetails setText:detailLabelText];
//                
//                [downloadDict setObject:[NSString stringWithFormat:@"%f",progress] forKey:kMZDownloadKeyProgress];
//                [downloadDict setObject:detailLabelText forKey:kMZDownloadKeyDetails];
//            });
//            break;
//        }
//    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
//    DLURLSessionOperation * opreation = [self.downloadArray objectAtIndex:0];
//    [opreation cancel];
//    DLURLSessionOperation * opreation1 = [self.downloadArray objectAtIndex:1];
//    [opreation1 start];
//    NSInteger  count =  self.queue.operationCount;
//    NSLog(@"%@",self.queue.operations );

    //    for(NSMutableDictionary *downloadInfo in downloadingArray)
//    {
//        if([[downloadInfo objectForKey:kMZDownloadKeyTask] isEqual:downloadTask])
//        {
//            NSString *fileName = [downloadInfo objectForKey:kMZDownloadKeyFileName];
//            NSString *destinationPath = [fileDest stringByAppendingPathComponent:fileName];
//            NSURL *fileURL = [NSURL fileURLWithPath:destinationPath];
//            NSLog(@"directory Path = %@",destinationPath);
//            
//            if (location) {
//                NSError *error = nil;
//                [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error];
//                if (error)
//                    [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
//            }
//            
//            break;
//        }
//    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
        DLURLSessionOperation * opre = [self.downloadArray objectAtIndex:0];
        [opre completeOperation];
//    NSInteger errorReasonNum = [[error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] integerValue];
//    
//    if([error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] &&
//       (errorReasonNum == NSURLErrorCancelledReasonUserForceQuitApplication ||
//        errorReasonNum == NSURLErrorCancelledReasonBackgroundUpdatesDisabled))
//    {
//        NSString *taskInfo = task.taskDescription;
//        
//        NSError *error = nil;
//        NSData *taskDescription = [taskInfo dataUsingEncoding:NSUTF8StringEncoding];
//        NSMutableDictionary *taskInfoDict = [[NSJSONSerialization JSONObjectWithData:taskDescription options:NSJSONReadingAllowFragments error:&error] mutableCopy];
//        
//        if(error)
//            NSLog(@"Error while retreiving json value: %@",error);
//        
//        NSString *fileName = [taskInfoDict objectForKey:kMZDownloadKeyFileName];
//        NSString *fileURL = [taskInfoDict objectForKey:kMZDownloadKeyURL];
//        
//        NSMutableDictionary *downloadInfo = [[NSMutableDictionary alloc] init];
//        [downloadInfo setObject:fileName forKey:kMZDownloadKeyFileName];
//        [downloadInfo setObject:fileURL forKey:kMZDownloadKeyURL];
//        
//        NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
//        if(resumeData)
//            task = [sessionManager downloadTaskWithResumeData:resumeData];
//        else
//            task = [sessionManager downloadTaskWithURL:[NSURL URLWithString:fileURL]];
//        [task setTaskDescription:taskInfo];
//        
//        [downloadInfo setObject:task forKey:kMZDownloadKeyTask];
//        
//        [self.downloadingArray addObject:downloadInfo];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.bgDownloadTableView reloadData];
//            [self dismissAllActionSeets];
//        });
//        return;
//    }
//    for(NSMutableDictionary *downloadInfo in downloadingArray)
//    {
//        if([[downloadInfo objectForKey:kMZDownloadKeyTask] isEqual:task])
//        {
//            NSInteger indexOfObject = [downloadingArray indexOfObject:downloadInfo];
//            
//            if(error)
//            {
//                if(error.code != NSURLErrorCancelled)
//                {
//                    NSString *taskInfo = task.taskDescription;
//                    
//                    NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
//                    if(resumeData)
//                        task = [sessionManager downloadTaskWithResumeData:resumeData];
//                    else
//                        task = [sessionManager downloadTaskWithURL:[NSURL URLWithString:[downloadInfo objectForKey:kMZDownloadKeyURL]]];
//                    [task setTaskDescription:taskInfo];
//                    
//                    [downloadInfo setObject:RequestStatusFailed forKey:kMZDownloadKeyStatus];
//                    [downloadInfo setObject:(NSURLSessionDownloadTask *)task forKey:kMZDownloadKeyTask];
//                    
//                    [downloadingArray replaceObjectAtIndex:indexOfObject withObject:downloadInfo];
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
//                        [self.bgDownloadTableView reloadData];
//                        [self dismissAllActionSeets];
//                    });
//                }
//            }
//            else
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString *fileName = [[downloadInfo objectForKey:kMZDownloadKeyFileName] copy];
//                    
//                    [self presentNotificationForDownload:[downloadInfo objectForKey:kMZDownloadKeyFileName]];
//                    
//                    [downloadingArray removeObjectAtIndex:indexOfObject];
//                    
//                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfObject inSection:0];
//                    [bgDownloadTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//                    
//                    if([self.delegate respondsToSelector:@selector(downloadRequestFinished:)])
//                        [self.delegate downloadRequestFinished:fileName];
//                    
//                    [self dismissAllActionSeets];
//                });
//            }
//            break;
//        }
//    }
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if (appDelegate.backgroundSessionCompletionHandler) {
//        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
//        appDelegate.backgroundSessionCompletionHandler = nil;
//        completionHandler();
//    }
//    
//    NSLog(@"All tasks are finished");
}

@end
