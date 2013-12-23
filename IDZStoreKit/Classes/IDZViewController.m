//
//  IDZViewController.m
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

#import "IDZViewController.h"
#import "IDZProgressBar.h"
@interface IDZViewController ()

@end

@implementation IDZViewController

- (void)viewDidLoad
{
    
    appDelegate=(IDZAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [InAppPurchaseHelper sharedInstance].delegate=self;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kInAppPurchaseHelperProductPurchasedNotification object:nil];
    [self chkPurchase];

}
-(void)viewDidDisappear:(BOOL)animated{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseHelperProductPurchasedNotification object:nil];
    
    [super viewDidDisappear:animated];

    
}
- (IBAction)restoreBtn_Clicked:(id)sender {
    if ([sender tag] == 4) {
        NSLog(@"Item 1 restore btn clicked");
    }
    else if ([sender tag] == 5){
        NSLog(@"Item 2 restore btn clicked");
    }
    else if ([sender tag] == 6){
        NSLog(@"Item 3 restore btn clicked");
    }
    [[InAppPurchaseHelper sharedInstance] restoreCompletedTransactions];

}
- (IBAction)unlockBtn_Clicked:(id)sender {
    
    if (![[InAppPurchaseHelper sharedInstance] checkProductsAvailable]) {
        [appDelegate productRequest];
    }
    
    NSLog(@"sender tag :: %d",[sender tag]);

    if ([sender tag] == 1){
        [[InAppPurchaseHelper sharedInstance] checkForProductIdentifier:kProductAId inList:[[InAppPurchaseHelper sharedInstance] getProductArray]];
        
    }

    if ([sender tag] == 2){
        
        [[InAppPurchaseHelper sharedInstance] checkForProductIdentifier:kProductBId inList:[[InAppPurchaseHelper sharedInstance] getProductArray]];
        
    }
    if ([sender tag] == 3){
        
        [[InAppPurchaseHelper sharedInstance] checkForProductIdentifier:kProductCId inList:[[InAppPurchaseHelper sharedInstance] getProductArray]];
    }
    
}


#pragma mark - Add Progress View
-(void)addProgressBar{
    
    IDZProgressBar *progressBar1,*progressBar2;
    
    int gap=5;
    UIImage *prBorder;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        progressBar1 = [[IDZProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progress_bar~ipad.png"] progressMask:[UIImage imageNamed:@"progress_mask~ipad.png"] insets:CGSizeMake(0, 0)];
        progressBar2 = [[IDZProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progress_bar~ipad.png"] progressMask:[UIImage imageNamed:@"progress_mask~ipad.png"] insets:CGSizeMake(0, 0)];
        prBorder=[UIImage imageNamed:@"progress_border~ipad.png"];
        gap=10;
    }
    else{
        progressBar1 = [[IDZProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progress_bar.png"] progressMask:[UIImage imageNamed:@"progress_mask.png"] insets:CGSizeMake(0, 0)];
        progressBar2 = [[IDZProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progress_bar.png"] progressMask:[UIImage imageNamed:@"progress_mask.png"] insets:CGSizeMake(0, 0)];
        prBorder=[UIImage imageNamed:@"progress_border.png"];
        gap=5;
        
    }
    
    
    _progressView.backgroundColor = [UIColor clearColor];
    _progressBar1View.backgroundColor = [UIColor clearColor];
    _progressBar2View.backgroundColor = [UIColor clearColor];
    
    
    
    progressBar1.tag=54322;
    progressBar1.maxValue=1.0;
    progressBar1.currentValue=0.0;
    progressBar1.hidden=YES;
    progressBar1.backgroundColor=[UIColor blueColor];
    progressBar1.center=CGPointMake( _progressBar1View.frame.size.width/2, _progressBar1View.frame.size.height/2+gap);
    [_progressBar1View addSubview:progressBar1];
    
    
    _progressLabel1.text = [NSString stringWithFormat:@"Downloading Makeup 2.."];
    _progressLabel1.backgroundColor = [UIColor clearColor];
    _progressLabel1.textColor=[UIColor whiteColor];
    _progressLabel1.textAlignment=UITextAlignmentCenter;
    _progressLabel1.numberOfLines = 1;
    _progressLabel1.hidden=YES;
    
    
    
    
    progressBar2.tag=54323;
    progressBar2.maxValue=1.0;
    progressBar2.currentValue=0.0;
    progressBar2.hidden=YES;
    progressBar2.backgroundColor=[UIColor blueColor];
    progressBar2.center=CGPointMake(_progressBar2View.frame.size.width/2, _progressBar2View.frame.size.height/2+gap);
    [_progressBar2View addSubview:progressBar2];
    
    
    
    
    _progressLabel2.text = [NSString stringWithFormat:@"Downloading Makeup 3.."];
    _progressLabel2.backgroundColor = [UIColor clearColor];
    _progressLabel2.textColor=[UIColor whiteColor];
    _progressLabel2.textAlignment=UITextAlignmentCenter;
    _progressLabel2.numberOfLines = 1;
    _progressLabel2.hidden=YES;
    
    
    [progressBar1 release];
    [progressBar2 release];
    
    
    _progressView.hidden=YES;
    
    
}

-(BOOL)containsString:(NSString*)string  subString:(NSString*)substring{
    NSRange range = [string rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

-(void)updateProgressViewOf:(NSString *)identifier withValue:(float)progress{
    
    
    if (!IS_IOS6_AND_UP) {
        return;
    }
    
    _progressView.hidden=NO;
    
    IDZProgressBar *progressBar;
    
    
    ///////////// hide progressbar if product is already purchased. //////////////
    //////////////////////////////////////////////////////////////////////////////
    
    NSArray *productArray=[NSArray arrayWithObjects:kProductAId,kProductBId,kProductCId, nil];
    int chkTag=54321;
    
    
    for (int i=chkTag; i<[productArray count]; i++) {
        
        if ([[InAppPurchaseHelper sharedInstance] productPurchasedWithProductIdentifier:[productArray objectAtIndex:i]]) {
            switch (i) {
                case 54321:
                    progressBar = (IDZProgressBar *)[_progressBar1View viewWithTag:i];
                    progressBar.hidden=YES;
                    break;
                case 54322:
                    progressBar = (IDZProgressBar *)[_progressBar2View viewWithTag:i];
                    progressBar.hidden=YES;
                    
                    break;
                case 54323:
                    progressBar = (IDZProgressBar *)[_progressBar2View viewWithTag:i];
                    progressBar.hidden=YES;
                    break;
                    
            }
        }
    }
    /////////////////////////     update progress bars    ////////////////////////
    //////////////////////////////////////////////////////////////////////////////
    int tag=0;
    
    if ([self containsString:identifier subString:@"http"]) {
        
        NSDictionary *dict_main=[[InAppPurchaseHelper sharedInstance] getDictionary];
        NSDictionary *dict_Data=[dict_main objectForKey:@"Product_details"];
        for (NSString *dictName in dict_Data) {
            NSDictionary *dict=[dict_Data objectForKey:dictName];
            NSLog(@"dict ::%@",dict);
            NSString *url = [dict objectForKey:@"download_url"];
            
            
            if ([url isEqualToString:identifier]) {
                identifier=[dict objectForKey:@"product_identifier"];
            }
            
        }
        
    }
    
    if ([identifier isEqualToString:kProductAId]) {
        tag=54321;
        
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 11) {
                
                view.backgroundColor=[UIColor yellowColor];
                
                for (UIView *view1 in [view subviews])
                {
                    
                    if (view1.tag >=1&& view1.tag <=6){
                        [view1 removeFromSuperview];}
                    if ([view1 isKindOfClass:[UILabel class]]) {
                        
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Purchasing Item 1.";
                        
                    }
                    
                }
            }
            
        }
        
        
    }
    else if ([identifier isEqualToString:kProductBId]) {
        tag=54322;
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 12) {
                view.backgroundColor=[UIColor yellowColor];

                for (UIView *view1 in [view subviews])
                {
                    
                    if (view1.tag >=1&& view1.tag <=6){
                        [view1 removeFromSuperview];}
                    if ([view1 isKindOfClass:[UILabel class]]) {
                        
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Purchasing Item 2.";
                        
                    }
                    
                }
            }
            
        }
        
    }
    else if ([identifier isEqualToString:kProductCId]) {
        tag=54323;
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 13) {
                
                view.backgroundColor=[UIColor yellowColor];

                
                for (UIView *view1 in [view subviews])
                {
                    
                    if (view1.tag >=1&& view1.tag <=6){
                        [view1 removeFromSuperview];}
                    if ([view1 isKindOfClass:[UILabel class]]) {
                        
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Purchasing Item 3.";
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    
    progressBar = (IDZProgressBar *)[_progressView viewWithTag:tag];
    
    if (tag>=54321) {
        
        if (progress > progressBar.currentValue) {
            
            [progressBar setCurrentValue:progress];
            
            if (tag==54321) {
                
                progressBar.hidden=NO;
                _progressLabel1.hidden=NO;
                
                _progressLabel1.text = [NSString stringWithFormat:@"Downloading Item 1 : %d %%",(int)(progress*100)];
                
            }

            
            if (tag==54322) {
                
                progressBar.hidden=NO;
                _progressLabel1.hidden=NO;
                
                _progressLabel1.text = [NSString stringWithFormat:@"Downloading Item 2 : %d %%",(int)(progress*100)];
                
            }
            
            if (tag==54323) {
                
                progressBar.hidden=NO;
                _progressLabel2.hidden=NO;
                
                _progressLabel2.text = [NSString stringWithFormat:@"Downloading Item 3 : %d %%",(int)(progress*100)];
                
            }
        }
        
        
        if (IS_IOS6_AND_UP) {
            
            if (progressBar.currentValue<=0.01) {
                _progressView.hidden=NO;
            }
            
            
        }
        
    }
    [self chkPurchase];
    
    //////////////////////////////////////////////////////////////////////////////
    
}

#pragma mark -  Purchase checking


-(void)chkPurchase{
    
    if ([[InAppPurchaseHelper sharedInstance] productPurchasedWithProductIdentifier:kProductAId])
    {
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 11)
            {
                view.backgroundColor=[UIColor greenColor];

                for (UIView *view1 in [view subviews])
                {
                    if (view1.tag >=1&& view1.tag <=6)
                    {
                        [view1 removeFromSuperview];
                    }
                    if ([view1 isKindOfClass:[UILabel class]])
                    {
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Item 1 Purchased.";
                    }
                }
            }
        }
        
        //// Do changes for unlocking the view 1 ..

    }
    
    if ([[InAppPurchaseHelper sharedInstance] productPurchasedWithProductIdentifier:kProductBId])
    {
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 12)
            {
                view.backgroundColor=[UIColor greenColor];

                for (UIView *view1 in [view subviews])
                {
                    if (view1.tag >=1&& view1.tag <=6)
                    {
                        [view1 removeFromSuperview];
                    }
                    if ([view1 isKindOfClass:[UILabel class]])
                    {
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Item 2 Purchased.";
                    }
                }
            }
        }
        
        //// Do changes for unlocking the view 2 ..

        
    }
    
    if ([[InAppPurchaseHelper sharedInstance] productPurchasedWithProductIdentifier:kProductCId])
    {
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 13)
            {
                view.backgroundColor=[UIColor greenColor];

                for (UIView *view1 in [view subviews])
                {
                    if (view1.tag >=1&& view1.tag <=6)
                    {
                        [view1 removeFromSuperview];
                    }
                    if ([view1 isKindOfClass:[UILabel class]])
                    {
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Item 3 Purchased.";
                    }
                }
            }
        }
        
        
        //// Do changes for unlocking the view 3 ..
        
        
    }

    
    
}


-(void)productPurchased:(NSNotification *)notify{
    
    NSDictionary *dict=[notify userInfo];
    NSLog(@"dict downloaded::%@",dict);
    NSString *product=[dict objectForKey:@"productIdentifier"];
    NSString *resourcePath=[[InAppPurchaseHelper sharedInstance] getDirPathForProductId:product];
    
    if ([product isEqualToString:kProductAId]) {
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 11) {
                
                view.backgroundColor=[UIColor greenColor];

                for (UIView *view1 in [view subviews])
                {
                    
                    if (view1.tag >=1&& view1.tag <=6){
                        [view1 removeFromSuperview];}
                    if ([view1 isKindOfClass:[UILabel class]]) {
                        
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Item 1 Purchased.";
                        
                    }
                }
            }
        }
    }
    
    else if ([product isEqualToString:kProductBId]) {
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 12) {
                view.backgroundColor=[UIColor greenColor];

                for (UIView *view1 in [view subviews])
                {
                    
                    if (view1.tag >=1&& view1.tag <=6){
                        [view1 removeFromSuperview];}
                    if ([view1 isKindOfClass:[UILabel class]]) {
                        
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Item 2 Purchased.";
                        
                    }
                    
                }
            }
            
        }
    }
    else if ([product isEqualToString:kProductCId]) {
        for (UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UIView class]] && view.tag == 13) {
                view.backgroundColor=[UIColor greenColor];

                for (UIView *view1 in [view subviews])
                {
                    
                    if (view1.tag >=1&& view1.tag <=6){
                        [view1 removeFromSuperview];}
                    if ([view1 isKindOfClass:[UILabel class]]) {
                        
                        UILabel *lbl=(UILabel *)view1;
                        lbl.text=@"Item 3 Purchased.";
                        
                    }
                    
                }
            }
            
        }
    }
    
    _progressView.hidden=YES;
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Data downloaded!" message:[NSString stringWithFormat:@"Thank you for your pessions. Data is downloaded successfully. Now you can enjoy the App."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
    NSLog(@"resourcePath %@",resourcePath);
    
}





// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_progressView release];
    [_progressBar1View release];
    [_progressBar2View release];
    [_progressLabel1 release];
    [_progressLabel2 release];
    [_makeup1View release];
    [_makeup2View release];
    [_makeup4View release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setProgressView:nil];
    [self setProgressBar1View:nil];
    [self setProgressBar2View:nil];
    [self setProgressLabel1:nil];
    [self setProgressLabel2:nil];
    [self setMakeup1View:nil];
    [self setMakeup2View:nil];
    [self setMakeup4View:nil];
    [super viewDidUnload];
}
@end
