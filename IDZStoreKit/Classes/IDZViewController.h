//
//  IDZViewController.h
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



#import <UIKit/UIKit.h>
#import "IDZAppDelegate.h"
#import "IDZInAppPurchaseHelper.h"

@interface IDZViewController : UIViewController<InAppDelegate>{


    IDZAppDelegate *appDelegate;
}
- (IBAction)unlockBtn_Clicked:(id)sender;
- (IBAction)restoreBtn_Clicked:(id)sender;


@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (retain, nonatomic) IBOutlet UIView *progressBar1View;
@property (retain, nonatomic) IBOutlet UIView *progressBar2View;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel1;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel2;

@property (retain, nonatomic) IBOutlet UIView *makeup1View;
@property (retain, nonatomic) IBOutlet UIView *makeup2View;
@property (retain, nonatomic) IBOutlet UIView *makeup4View;


@end
