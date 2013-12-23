//
//  IDZDownloadFileFromServer.h
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


#import <Foundation/Foundation.h>
#import "IDZProgressBar.h"


@class AFDownloadRequestOperation;

@protocol downloadFileDelegate

-(void)updateDownloadStatus:(NSDictionary *)dictionary;
-(NSString *)downloadableContentPathForProductId:(NSString *)downloadContentIdentifier;

@optional
-(int)updateProgressbarOfId:(NSString *)pId withValue:(float)val;
-(void)showAlertBoxWithMsg:(NSString*)message title:(NSString *)title;






@end

@interface IDZDownloadFileFromServer : NSObject
{

    NSOperationQueue *myQueue;
    // AFDownloadRequestOperation *myOperation;
    
    
    /////////********* progress bar variables ***********/////////
    UIView *loadView;
    UIView *progressView;
    float percentDone;
    IDZProgressBar *progressBar1,*progressBar2;
    
    UILabel *progressLabel;

}

@property(nonatomic,retain) NSMutableArray *downloadObjectArray;

@property(nonatomic,strong) NSString *urlPath;
@property(nonatomic,assign)id <downloadFileDelegate> delegate;

-(id)initDownloadFile;
-(void)downloadZipFile:(NSDictionary *)dictDownload;


@end
