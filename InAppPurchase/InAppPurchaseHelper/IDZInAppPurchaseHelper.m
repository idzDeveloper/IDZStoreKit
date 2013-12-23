//
//  InAppPurchaseHelper.m
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

#import "IDZInAppPurchaseHelper.h"
#import "IDZReachability.h"

@interface InAppPurchaseHelper()
{
	SKProductsRequest *_productsRequest;
	RequestProductsOnCompleteBlock _onCompleteBlock;
	NSSet *_productIdentifiers;
    NSArray *_productList;
	NSMutableSet *_purchasedProductIdentifiers;
    NSDictionary *dict_productDetails;
    IDZDownloadFileFromServer *_downloadObj;
    NSMutableDictionary *dict_directoryPath;
    
    
    BOOL chkConnection;
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    BOOL changeReachbility;
    
    BOOL buyFeature;

    
    
    
}

@property (nonatomic,retain)NSDictionary *dict_productDetails;
@end
@implementation InAppPurchaseHelper
@synthesize delegate;
@synthesize isDownloading;
@synthesize dict_productDetails;

+ (InAppPurchaseHelper *)sharedInstance {
	static InAppPurchaseHelper *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        
        NSSet *productIdentifiers=[NSSet setWithObjects:kProductAId,kProductBId,kProductCId, nil];
		sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
        
	});
	return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
	self = [super init];
	if (self != nil){
		//save the product identifiers
		_productIdentifiers = productIdentifiers;
        [self removeProductListInitially];
        _productList = [[NSArray alloc] init];
        self.dict_productDetails=[self getPlistData];
        NSLog(@"dict_productDetails :: %@",self.dict_productDetails);

        
        isDownloading=NO;
        _downloadObj=[[IDZDownloadFileFromServer alloc] initDownloadFile];
        _downloadObj.delegate=self;
        dict_directoryPath=[[NSMutableDictionary alloc] init];
        //check for previously purchased products
		_purchasedProductIdentifiers = [[NSMutableSet alloc] init];
        
        
        
        
		for (NSString *productIdentifier in _productIdentifiers){
			BOOL purchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
			if (purchased){
				[_purchasedProductIdentifiers addObject:productIdentifier];
                
                NSString *key=[NSString stringWithFormat:@"%@_resourcePath",productIdentifier];
                
                NSString *dir=[self downloadableContentPathForProductId:productIdentifier];
                [dict_directoryPath setObject:dir forKey:key];
                
			}
		}
        
		//set this object as the transaction observer
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

-(NSDictionary *)loadPlistData{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //Create a list of paths
    NSString *documentsDirectory = [paths objectAtIndex:0]; //Get a path to your documents directory from the list.
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"product_detail.plist"]]; //Create a full file path.
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
 
    
    return dictionary;
}

-(void)updateProductPlistFile:(NSString *)identifier AddVersion:(NSString *)version{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //Create a list of paths
    NSString *documentsDirectory = [paths objectAtIndex:0]; //Get a path to your documents directory from the list.
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"product_detail.plist"]]; //Create a full file path.
    NSMutableDictionary *main_dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    NSLog(@"self.dict_productDetails %@",self.dict_productDetails);
    NSMutableDictionary *dictionary=[main_dictionary objectForKey:@"Product_details"];

    for (int i=0; i<[dictionary count]; i++) {
        NSMutableDictionary *dict_temp=[dictionary objectForKey:[NSString stringWithFormat:@"Item %d",i+1]];
        NSString *pd=[dict_temp objectForKey:@"product_identifier"];
        NSLog(@"pd ::%@",pd);
        NSLog(@"identifier ::%@",identifier);

        if ([pd isEqualToString:identifier]) {
          
            [dict_temp setObject:version forKey:@"hosted_content_version"];
              NSLog(@"dict_temp %@",dict_temp);
        }
        
    }
    
    [main_dictionary writeToFile:path atomically:YES];

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    NSLog(@"changed_dict %@",dict);

    
    
    
   
}
-(void)removeProductListInitially{

    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //Create a list of paths
    NSString *documentsDirectory = [paths objectAtIndex:0]; //Get a path to your documents directory from the list.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"product_detail.plist"]]; //Create a full file path.
    NSString* bundle = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"product_detail"] ofType:@"plist"]; //Get a path to your plist created before in bundle directory (by Xcode).
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:&error];
    }
  
    [fileManager copyItemAtPath:bundle toPath: path error:&error]; //Copy this plist to your documents directory.
    
}


- (void)requestProductsWithOnCompleteBock:(RequestProductsOnCompleteBlock)onCompleteBlock {
	//keep a copy of the onComplete block to call later
	_onCompleteBlock = [onCompleteBlock copy];
	
	//request information about in-app purchases using product identifiers
	_productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
	_productsRequest.delegate = self;
	[_productsRequest start];
}

-(BOOL)getDownloadingStatus{
    
    return isDownloading;
}
-(NSDictionary *)getDictionary{

    return self.dict_productDetails;
}
-(NSString *)getDirPathForProductId:(NSString*)productIdentifier{
    
    NSString *key =[NSString stringWithFormat:@"%@_resourcePath",productIdentifier];
    NSString *path=[dict_directoryPath objectForKey:key];
    NSLog(@"path inApp :: %@",path);
    
    return path;
    
}


#pragma mark - Product Array
-(NSArray *)getProductArray{
    
    return _productList;
}
-(void)updateProductArray:(NSArray *)products{
    
    _productList=products;
    [_productList retain];
    
    NSLog(@"_products inApp :: %@",_productList);
}


-(BOOL)checkProductsAvailable{
    //   NSLog(@"_products inApp checkProductsAvailable:: %@",[_productList description]);
    
    
    if ([(NSArray*)_productList count] <= 0) {
        return NO;
    }
    
    return YES;
    
}


#pragma mark - Check Netwrok Connection


-(void)checkConnectivity{
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    if (!changeReachbility) {
        
        internetReach = [[Reachability reachabilityForInternetConnection] retain];
        [internetReach startNotifier];
        [self updateInterfaceWithReachability: internetReach];
        
        
        wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
        [wifiReach startNotifier];
        [self updateInterfaceWithReachability: wifiReach];
        
        
    }
    
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    ;
    
	if(curReach == internetReach)
	{
		chkConnection = [self reachability: curReach];
	}
	if(curReach == wifiReach)
	{
		chkConnection = [self reachability: curReach];
	}
	
    
    
}

- (BOOL) reachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    BOOL status;
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
            status=NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            status=YES;
            
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            status=YES;
            
            break;
        }
    }
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
        status=NO;
        
    }
    return status;
}

- (void) reachabilityChanged: (NSNotification* )note
{
    changeReachbility=YES;
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
    changeReachbility=NO;
}

-(void)showNetworkError{
    
    [self showAlertBoxWithMsg:@"Please check your internet connection." title:@"Network Connection Error"];

}



#pragma mark - Buy Feature


-(void)checkForProductIdentifier:(NSString*)productidentifier inList:(NSArray *)products{
    
    for (SKProduct *product in products) {
        NSLog(@"product.productIdentifier %@",product.productIdentifier);
        
        if ([product.productIdentifier isEqualToString:productidentifier]) {
            NSLog(@"product.productIdentifier %@",product.productIdentifier);
            [self buyFeatureIsCalled:product];
            break;
        }
    }
    
}


-(void)buyFeatureIsCalled:(SKProduct *)product{
    
    if ([SKPaymentQueue canMakePayments]) {
        // [ purchaseProUpgrade:product];
        [self purchaseProUpgrade:product];
        
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Your account settings do not allow for In App Purchases."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
}


- (void)purchaseProUpgrade:(SKProduct *)product
{
    [self checkConnectivity];
    
    if (chkConnection) {
        buyFeature=YES;
        [self buyProduct:product];
        
    }
    else{
        [self showNetworkError];
    }
    
}




- (void)buyProduct:(SKProduct *)product {
	NSLog(@"Performing in-app purchase: %@", product.productIdentifier);
	
	//add to payment queue
	SKPayment *payment = [SKPayment paymentWithProduct:product];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}


- (BOOL)productPurchasedWithProductIdentifier:(NSString *)productIdentifier {
	return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"Completing transaction.");
    [self processTransaction:transaction];
    
    
	//[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"Failed transaction.");
	if (transaction.error.code != SKErrorPaymentCancelled){
		NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
	}
    else{
        
        NSLog(@"SKErrorPaymentCancelled");
        
    }
    
    
    //[self showAlertBoxWithMsg:transaction.error.localizedDescription title:[NSString stringWithFormat:@"Error ::%d",transaction.error.code ]];
    
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"Restoring transaction.");
   
    [self checkConnectivity];
    if (chkConnection)
    {
        [self processTransaction:transaction];
    }
    else
    {
        [self showNetworkError];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    
}


-(void)processTransaction:(SKPaymentTransaction *)transaction {
    
    
    NSString *pdIdentifier=nil;
    if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
        pdIdentifier=transaction.payment.productIdentifier;
    }
    else if (transaction.transactionState == SKPaymentTransactionStateRestored){
        pdIdentifier=transaction.originalTransaction.payment.productIdentifier;
        
    }
    
    
    self.dict_productDetails=[self getPlistData];
    NSDictionary *dictionary=[self.dict_productDetails objectForKey:@"Product_details"];
    

    if (IS_IOS6_AND_UP) {
        
        NSLog(@"ios 6 and above");
        
        if (transaction.downloads) {
            if(!isDownloading)
                [self showAlertBoxWithMsg:@"Please wait for a few minutes. The locked product/s is/are downloading.You can press ok and play the others in the meanwhile." title:@"Downloading the In-App Purchase"];
            
            isDownloading=YES;
            [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];

            /*for (SKDownload *download in transaction.downloads)
            {
               
               for (int i=1; i<=[dictionary count]; i++)
                {
                    NSDictionary *dict_temp=[dictionary objectForKey:[NSString stringWithFormat:@"Item %d",i]];
                    NSString *pd=[dict_temp objectForKey:@"product_identifier"];
                    NSString *hs_version=[dict_temp objectForKey:@"hosted_content_version"];
                    
                    NSLog(@"download.contentVersion %@",download.contentVersion );
                    if ([pd isEqualToString:download.transaction.payment.productIdentifier])
                    {
                        if (![hs_version isEqualToString:download.contentVersion])
                        {
                            NSLog(@"version download");
                            [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
                        }
                    }
                }
            
            }*/
                
        }
        else
        {
            
            // unlock features
            isDownloading=NO;
            [self provideContentForProductIdentifier:pdIdentifier versionNo:@"1.0"];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
          
        }
    }
    else{
        NSLog(@"below ios 6");
        
        
        for (int i=1; i<=[dictionary count]; i++) {
            NSDictionary *dict_temp=[dictionary objectForKey:[NSString stringWithFormat:@"Item %d",i]];
            NSNumber *num_host_content = [dict_temp objectForKey:@"host_content"];
            BOOL ishost_content = [num_host_content boolValue];
            
            NSLog(@"ishost_content ::%d identifier ::%@ pdIdentifier::%@",ishost_content,[dict_temp objectForKey:@"product_identifier"],pdIdentifier);
            NSString *pd=[dict_temp objectForKey:@"product_identifier"];
            NSString *version=[dict_temp objectForKey:@"hosted_content_version"];

            if ([pdIdentifier isEqualToString:pd]) {
                
                if (ishost_content) {
                    
                    
                    NSString *url=[dict_temp objectForKey:@"download_url"];
                    NSDictionary *dictionary=[[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:url,pd,version,transaction, nil] forKeys:[NSArray arrayWithObjects:@"product_url",@"product_identifier",@"contentVersion",@"transaction", nil]];
                    
                    NSString *dir=[self downloadableContentPathForProductId:pdIdentifier];
                    
                    NSString *key=[NSString stringWithFormat:@"%@_downloaded",pdIdentifier];
                    BOOL downloaded = [[NSUserDefaults standardUserDefaults] boolForKey:key];
                    
                    
                    if (!downloaded) {
                        
                        [_downloadObj downloadZipFile:dictionary];
                        
                    }
                    
                }
                else{
                    
                    isDownloading=NO;

                    [self provideContentForProductIdentifier:pdIdentifier versionNo:@"1.0"];
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    
                    
                }
                
            }
            
        }
    }
    

    
}



-(void)showAlertBoxWithMsg:(NSString*)message title:(NSString *)title{
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    alert.tag=101;
    [alert show];
    [alert release];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ( [alertView tag] != 101 && buttonIndex == 1)
    {
        [self restoreCompletedTransactions];
    }
 
}

-(NSDictionary *)getPlistData{
    NSDictionary *dict =[[[NSDictionary alloc] initWithDictionary:[self loadPlistData]] autorelease];
    return dict;
}

- (void)restoreCompletedTransactions {
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)provideContentForProductIdentifier:(NSString *)productIdentifier versionNo:(NSString *)version{
	
    //add the product identifier to the set of purchased identifiers
	[_purchasedProductIdentifiers addObject:productIdentifier];
	
	//set the NSUserDefault value to YES
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    
    
    [self updateProductPlistFile:productIdentifier AddVersion:version];
  	//send out notification that the purchase went through for the in-app product
    NSDictionary *userInfo=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:productIdentifier, nil] forKeys:[NSArray arrayWithObjects:@"productIdentifier", nil]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseHelperProductPurchasedNotification object:self userInfo:userInfo];
    
}




#pragma mark - Implement SKProductsRequestDelegate protocol

//Then this delegate Funtion Will be fired
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
       // NSString *productID = transaction.payment.productIdentifier;
    }
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSDictionary *dict =[[NSDictionary alloc] initWithDictionary:[self loadPlistData]];
    self.dict_productDetails=dict;
    [dict release];
    NSDictionary *dictionary=[self.dict_productDetails objectForKey:@"Product_details"];

	for (SKProduct *product in response.products){
        
		NSLog(@"Found product: %@ %@ %0.2f", product.productIdentifier, product.localizedTitle, product.price.floatValue);
        
        if ([self productPurchasedWithProductIdentifier:product.productIdentifier]) {
            
            
            for (int i=1; i<=[dictionary count]; i++)
            {
                NSDictionary *dict_temp=[dictionary objectForKey:[NSString stringWithFormat:@"Item %d",i]];
                NSString *pd=[dict_temp objectForKey:@"product_identifier"];
                NSString *hs_version=[dict_temp objectForKey:@"hosted_content_version"];
                NSString *app_name=[dict_temp objectForKey:@"app_name"];

                if ([pd isEqualToString:product.productIdentifier])
                {
                    if (![hs_version isEqualToString:product.downloadContentVersion])//product.downloadContentVersion
                    {
                        NSString *message=[NSString stringWithFormat:@"New content is available for %@",app_name];
                        UIAlertView *alertForUpdate=[[UIAlertView alloc] initWithTitle:@"Update!" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
                        alertForUpdate.tag=7650+i;
                        [alertForUpdate show];
                        [alertForUpdate release];
                        
                    }
                }
            }
        }
	}
	
	_productsRequest = nil;
	
	//call the onComplete block
    if (_onCompleteBlock != nil) {
        _onCompleteBlock(YES, response.products);
        _onCompleteBlock = nil;
    }
	
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Failed to load list of products.");
    if (error != nil) {
        [self showAlertBoxWithMsg:[NSString stringWithFormat:@"Please Check network connection."] title:@"Error !"];
    }
	_productsRequest = nil;
    
    if (_onCompleteBlock != nil) {
        _onCompleteBlock(NO, nil);
        _onCompleteBlock = nil;
    }
}


# pragma mark - Implement SKPaymentTransactionObserver protocol
-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{
	for (SKPaymentTransaction *transaction in transactions){
        [queue finishTransaction:transaction];
    }


}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for (SKPaymentTransaction *transaction in transactions){
        
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
				break;
            case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			default:
				break;
                
		}
	}
}


#pragma mark - Hosted Content Support
-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads;
{
    //NSLog(@"updatedDownloads");
    
    for (SKDownload *download in downloads) {
        
        if (download.downloadState == SKDownloadStateFinished) {
            [self processDownload:download]; // not written yet
            // now we're done
            isDownloading=NO;
            
            NSString *version =[NSString stringWithFormat:@"%@",download.contentVersion];
            
            [self provideContentForProductIdentifier:download.transaction.payment.productIdentifier versionNo:version];
            
            [queue finishTransaction:download.transaction];
            
        } else if (download.downloadState == SKDownloadStateActive) {
            
            NSString *productID = download.contentIdentifier; // in app purchase identifier
            float progress = download.progress; // 0.0 -> 1.0
            [self updateProgressbarOfId:productID withValue:progress];
            
        } else {
            NSLog(@"Warn: not handled: %d", download.downloadState);
        }
    }
}

- (BOOL) containsString:(NSString*)string  subString:(NSString*)substring
{
    NSRange range = [string rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

-(int) updateProgressbarOfId:(NSString *)pId withValue:(float)val{

    int btnTag=0;
    if (IS_IOS6_AND_UP) {
        [delegate updateProgressViewOf:pId withValue:val];
        btnTag=0;
    }
    else{
    
        int tag=0;
        
        if ([self containsString:pId subString:@"http"]) {
            
            NSDictionary *dict_main=[[InAppPurchaseHelper sharedInstance] getDictionary];
            NSDictionary *dict_Data=[dict_main objectForKey:@"Product_details"];
            for (NSString *dictName in dict_Data) {
                NSDictionary *dict=[dict_Data objectForKey:dictName];
                
                NSString *url = [dict objectForKey:@"download_url"];
                if ([url isEqualToString:pId]) {
                    pId=[dict objectForKey:@"product_identifier"];
                }
                
            }
            
        }
        
        if ([pId isEqualToString:kProductAId]) {
            tag=54321;
        }
        else if ([pId isEqualToString:kProductBId]) {
            tag=54322;
        }
        else if ([pId isEqualToString:kProductCId]) {
            tag=54323;
        }
        
        
        btnTag=tag;
    }
    
    return btnTag;
}


- (void) processDownload:(SKDownload*)download;
{
    // convert url to string, suitable for NSFileManager
    NSString *path = [download.contentURL path];
    
    // files are in Contents directory
    path = [path stringByAppendingPathComponent:@"Contents"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
    NSString *dir = [[InAppPurchaseHelper sharedInstance]downloadableContentPathForProductId:download.contentIdentifier]; // not written yet
    
    for (NSString *file in files) {
        NSString *fullPathSrc = [path stringByAppendingPathComponent:file];
        NSString *fullPathDst = [dir stringByAppendingPathComponent:file];
        
        // not allowed to overwrite files - remove destination file
        [fileManager removeItemAtPath:fullPathDst error:NULL];
        
        if ([fileManager moveItemAtPath:fullPathSrc toPath:fullPathDst error:&error] == NO) {
            NSLog(@"Error: unable to move item: %@", error);
        }
        else{
            
        }
        
    }
    

    
    NSString *key=[NSString stringWithFormat:@"%@_resourcePath",download.contentIdentifier];
    [dict_directoryPath setObject:dir forKey:key];
    // NOT SHOWN: use download.contentIdentifier to tell your model that we've been downloaded
}

- (NSString *) downloadableContentPathForProductId:(NSString *)downloadContentIdentifier
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    directory = [directory stringByAppendingPathComponent:@"Downloads"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:directory] == NO) {
        
        NSError *error;
        if ([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
        }
        else{
        
         //   NSError *error;
            
            /*BOOL success = [[NSURL URLWithString:directory] setResourceValue:[NSNumber numberWithBool:YES]
                                                                      forKey:NSURLIsExcludedFromBackupKey
                                                                       error:&error];
            if (!success) { NSLog(@"can not exclude from backup"); }*/
            
        }
       
        
    }
    
    
    
    
    NSString *param = nil;
    NSRange start = [downloadContentIdentifier rangeOfString:@"com.internetdesignzone."];
    if (start.location != NSNotFound)
    {
        param = [downloadContentIdentifier substringFromIndex:start.location + start.length];
        NSRange end = [param rangeOfString:@"%"];
        if (end.location != NSNotFound)
        {
            param = [param substringToIndex:end.location];
        }
    }

    

    param =[param stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    
    directory = [directory stringByAppendingPathComponent:param];

    if ([fileManager fileExistsAtPath:directory] == NO) {
        
        NSError *error;
        if ([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"Error: Unable to create directory: %@", error);
        }
        else{
        
         
        }
        
        
    }
    
    
    return directory;
    
}

#pragma mark - DownloadFileFromServer Delegate Method
-(void)updateDownloadStatus:(NSDictionary *)dictionary{
    
    SKPaymentTransaction *transaction=[dictionary objectForKey:@"transaction"];
    
    NSString *key=[NSString stringWithFormat:@"%@_downloaded",transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    
    NSString *version=[dictionary objectForKey:@"contentVersion"];
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier versionNo:version];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    
    
    /////////////************** Set Path for Resources ****************///////////////
    NSString *resource_key=[NSString stringWithFormat:@"%@_resourcePath",transaction.payment.productIdentifier];
     NSString *dir=[self downloadableContentPathForProductId:transaction.payment.productIdentifier];
    
    [dict_directoryPath setObject:dir forKey:resource_key];
    
    

}

#pragma mark - Future Implementation (resume/pause Downloading)

//used to pause the download
-(void)pauseDownload{
    NSLog(@"pause purchase");
    
    
}
//used to resume download
-(void)resumeDownload{
    NSLog(@"resume purchase");
    
    
}

@end
