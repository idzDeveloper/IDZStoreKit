//
//  IDZDownloadFileFromServer.m
//  Copyright (c) 2013 IDZ.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.



#import "IDZDownloadFileFromServer.h"
#import "ZipArchive.h"
#import "AFNetworking.h"
#import "AFURLConnectionOperation.h"
#import "AFDownloadRequestOperation.h"
#import "DownloadObject.h"
@implementation IDZDownloadFileFromServer
@synthesize delegate;
@synthesize downloadObjectArray;


-(id)initDownloadFile{
    
    self = [super init];
    if (!self) {
        
    }
    self.downloadObjectArray=[NSMutableArray array];
    
    
    return self;
    
}
-(void)setUrlPath:(NSString *)urlPath{
    
    self.urlPath=urlPath;
    
}


-(void)downloadZipFile:(NSDictionary *)dictDownload{
    
    if (!myQueue) {
        myQueue=[[NSOperationQueue alloc] init];
    }
    
    NSString *urlpath=[dictDownload objectForKey:@"product_url"];
    
    
    for (DownloadObject *object in self.downloadObjectArray)
    {
        if ([object.title isEqualToString:urlpath]) {
            
            if (object.status == kDownloadObjectStatusInProgress || object.status == kDownloadObjectStatusDoneSucceeded) {
                return;
            }
        }
    }
    
    DownloadObject *object =[[DownloadObject alloc] init];
    object.title=[NSString stringWithFormat:@"%@",urlpath];
    object.status=kDownloadObjectStatusNotStarted;
    object.progress=[NSNumber numberWithFloat:0.0];
    [self.downloadObjectArray addObject:object];
    
    
    NSURL *sourceURL =[NSURL URLWithString:urlpath];
    NSURLRequest *request = [NSURLRequest requestWithURL:sourceURL];
    
    NSString *proId=[dictDownload objectForKey:@"product_identifier"];
    
    NSString *path=[delegate downloadableContentPathForProductId:proId];
    path=[path stringByAppendingString:@".zip"];
    
    [self deleteDirectoryAtPath:path];
    
    if (loadView == nil) {
        [self addLoadView];
        
    }
    
    AFDownloadRequestOperation *myOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:YES];
    [myOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        object.status=kDownloadObjectStatusDoneSucceeded;
        
        BOOL downloading=NO;
        
        for (DownloadObject *obj in self.downloadObjectArray) {
            
            if (obj.status == kDownloadObjectStatusInProgress) {
                downloading=YES;
            }
            
        }
        
        if (!downloading) {
            [self removeLoadView];
        }
        
        
        [self unZipData:path url:sourceURL dictionary:dictDownload];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        object.status=kDownloadObjectStatusDoneFailed;
        BOOL downloading=NO;
        for (DownloadObject *obj in self.downloadObjectArray) {
            
            if (obj.status == kDownloadObjectStatusInProgress) {
                downloading=YES;
            }
        }
        
        if (!downloading) {
            [self removeLoadView];
            
            NSString *errormsg=[NSString stringWithFormat:@"%@",error];
            
            [delegate showAlertBoxWithMsg:errormsg title:@"Error!!"];
        }
        
        
        
    }];
    
    
    [myOperation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *op1,NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        object.status=kDownloadObjectStatusInProgress;
        
        percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpected));
        
        if (!((int)(percentDone*100) %2)) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *urlStr = [NSString stringWithFormat:@"%@",myOperation.request.URL];
                
                int tag = [delegate updateProgressbarOfId:urlStr withValue:percentDone];
                [self updateProgressBarWithTag:tag withValue:percentDone];
                if (loadView != nil) {
                    progressLabel.text=[NSString stringWithFormat:@"Please wait for a few minutes. The locked data are getting downloaded. Do not close the app."];
                }
                
            });
            
        }
        
    }];
    
    [myQueue addOperation:myOperation];
    
}


-(void)updateProgressBarWithTag:(int)tag withValue:(float)value{
    
    if (tag==54322) {
        if (value*100>0) {
            progressBar1.hidden=NO;
        }
        if (progressBar1.currentValue < value) {
            [progressBar1 setCurrentValue:value];
        }
    }
    else if (tag == 54323){
        if (value*100>0) {
            progressBar2.hidden=NO;
        }
        if (progressBar2.currentValue < value) {
            [progressBar2 setCurrentValue:value];
        }
    }
    
}

-(float)getPercentDone{
    
    return percentDone;
}


-(void)updateProgressBarWithValue:(float)value{
    
            if (progressBar1.currentValue < value) {
            [progressBar1 setCurrentValue:value];
        }
    
    
}

-(NSString *)unZipData:(NSString *)filePath url:(NSURL *)sourceURL dictionary:(NSDictionary *)dict{
  
    ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
    BOOL success = [zip UnzipOpenFile:filePath];
    if (!success) {
        return nil;
    }
    
    NSString* path1=[filePath stringByDeletingLastPathComponent];
    NSString* path2 = [[filePath lastPathComponent] stringByDeletingPathExtension];
    NSString* zipDirName=[path1 stringByAppendingString:[NSString stringWithFormat:@"/%@",path2]];
    
    [self deleteDirectoryAtPath:zipDirName];
    success = [zip UnzipFileTo:zipDirName overWrite:YES];
    
    if (success) {
        [self deleteDirectoryAtPath:filePath];
    }
    else{
        NSLog(@"Failed to unzip zip");
        return nil;
    }
    
    NSError *error;
    
    NSString *subdirPath=[sourceURL.lastPathComponent stringByDeletingPathExtension];
    NSString *sourcePath=[zipDirName stringByAppendingPathComponent:subdirPath];
    
    
    [delegate updateDownloadStatus:dict];
    [self deleteDirectoryAtPath:sourcePath];
    
    
    // Enumerate directory
    NSArray * items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:zipDirName error:&error];
    NSLog(@"items count %d",[items count]);
    if (error) {
        NSLog(@"Could not enumerate %@", zipDirName);
        return nil;
    }
    
    
    return zipDirName;
    
    
}
-(BOOL)transferFilesFromPath:(NSString *)sourcePath toPath:(NSString *)destPath{
    
    NSError *error;
    NSArray *resContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:&error];
    [resContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSError* error;
         if (![[NSFileManager defaultManager]
               copyItemAtPath:[sourcePath stringByAppendingPathComponent:obj]
               toPath:[destPath stringByAppendingPathComponent:obj]
               error:&error]){
             NSLog(@"error on transfer :: %@", [error localizedDescription]);
             return;
         }
         else{
             NSLog(@"transferreed file : %@",[destPath stringByAppendingPathComponent:obj]);
         }
     }];
    
    return true;
}

- (void) deleteDirectoryAtPath:(NSString *)deleteDir
{
    [[NSFileManager defaultManager] removeItemAtPath:deleteDir error:nil];
}


#pragma mark - Load view



-(void)addLoadView{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    CGRect frame=[[UIScreen mainScreen] bounds];
    loadView=[[UIView alloc] initWithFrame:frame];
    loadView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    progressView=[[UIView alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        progressView.frame = CGRectMake(0, 0, 500, 200);
        progressView.center = CGPointMake(loadView.center.x+loadView.center.x/20, loadView.center.y);
        
    }else{
        progressView.frame = CGRectMake(0, 0, 200, 150);
        progressView.center = CGPointMake(loadView.center.x-loadView.center.x/20, loadView.center.y);
        
    }
    
    progressView.backgroundColor=[UIColor clearColor];
    
    
    progressLabel = [[UILabel alloc] init];
    
    
    UIImage *prBorder;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        progressBar1 = [[IDZProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progress_bar~ipad.png"] progressMask:[UIImage imageNamed:@"progress_mask~ipad.png"] insets:CGSizeMake(0, 0)];
        progressBar2 = [[IDZProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progress_bar~ipad.png"] progressMask:[UIImage imageNamed:@"progress_mask~ipad.png"] insets:CGSizeMake(0, 0)];
        prBorder=[UIImage imageNamed:@"progress_border~ipad.png"];
    }
    else{
        progressBar1 = [[IDZProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progress_bar.png"] progressMask:[UIImage imageNamed:@"progress_mask.png"] insets:CGSizeMake(0, 0)];
        progressBar2 = [[IDZProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progress_bar.png"] progressMask:[UIImage imageNamed:@"progress_mask.png"] insets:CGSizeMake(0, 0)];
        prBorder=[UIImage imageNamed:@"progress_border.png"];
        
    }
    
    progressBar1.maxValue=1.0;
    progressBar1.currentValue=0.0;
    progressBar1.backgroundColor=[UIColor redColor];
    progressBar1.center=CGPointMake(progressView.frame.size.width/2, progressView.frame.size.height/2);
    progressBar1.hidden=YES;
    [progressView addSubview:progressBar1];
    
    
    progressBar2.maxValue=1.0;
    progressBar2.currentValue=0.0;
    progressBar2.backgroundColor=[UIColor redColor];
    progressBar2.center=CGPointMake(progressView.frame.size.width/2, (progressView.frame.size.height/2)-(progressBar2.frame.size.height));
    progressBar2.hidden=YES;
    [progressView addSubview:progressBar2];
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        progressLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold" size:15];
        progressLabel.frame=CGRectMake(0, 0, progressBar1.frame.size.width+progressBar1.frame.size.width/2, 100);
        progressLabel.center=CGPointMake(progressView.frame.size.width/2, progressBar1.frame.origin.y-50);
        
    }
    else{
        progressLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold" size:11];
        progressLabel.frame=CGRectMake(0, 0, progressBar1.frame.size.width+progressBar1.frame.size.width/2, 70);
        progressLabel.center=CGPointMake(progressView.frame.size.width/2, progressBar1.frame.origin.y-40);
        
    }
    
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.textColor=[UIColor whiteColor];
    progressLabel.textAlignment=UITextAlignmentCenter;
    progressLabel.numberOfLines = 5;
    
    progressLabel.text=[NSString stringWithFormat:@"Please wait for a few minutes. The locked data are getting downloaded. Do not close the app."];
    
    
    [progressView addSubview:progressLabel];
    
    
    
    [loadView addSubview:progressView];
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    [keyWindow addSubview:loadView];
    [keyWindow bringSubviewToFront:loadView];

    
    
	
    UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
	CGFloat angle = 0;
	switch (o) {
		case UIDeviceOrientationLandscapeLeft: angle = 90; break;
		case UIDeviceOrientationLandscapeRight: angle = -90; break;
		default: break;
	}
    
    CGAffineTransform newTransform = CGAffineTransformMakeRotation((CGFloat)(angle * M_PI / 180.0));
    progressView.layer.affineTransform = newTransform;
    
    NSLog(@"loadView frame :: %@",NSStringFromCGRect(frame));
    
}

- (void)orientationChanged:(NSNotification *)notification
{
	
	UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
	CGFloat angle = 0;
	switch (o) {
		case UIDeviceOrientationLandscapeLeft: angle = 180; break;
		case UIDeviceOrientationLandscapeRight: angle = -180; break;
		default: break;
	}
    
    
    
}

-(void)removeLoadView{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (loadView != nil) {
        [progressBar1 removeFromSuperview];
        [progressView removeFromSuperview];
        [loadView removeFromSuperview];
        [progressLabel removeFromSuperview];
        progressBar1 = nil;
        progressBar2 = nil;
        loadView=nil;
        
        
    }
    
    
}

@end
