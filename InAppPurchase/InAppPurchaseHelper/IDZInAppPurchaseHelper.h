//
//  IDZInAppPurchaseHelper.h
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
#import <StoreKit/StoreKit.h>
#import "IDZDownloadFileFromServer.h"


#define kProductAId @"com.YourCompanyName.productName.unlock1"
#define kProductBId @"com.YourCompanyName.productName.unlock2"
#define kProductCId @"com.YourCompanyName.productName.unlock3"

#define kInAppPurchaseHelperProductPurchasedNotification @"InAppPurchaseHelperProductPurchasedNotification"
//
#define IS_IOS6_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)


UIKIT_EXTERN NSString *const InAppPurchaseHelperProductPurchasedNotification;
typedef void(^RequestProductsOnCompleteBlock)(BOOL success, NSArray *products);

@protocol InAppDelegate

@optional
- (void) updateProgressViewOf:(NSString *)identifier withValue:(float)progress;

@end

@interface InAppPurchaseHelper : NSObject <UIAlertViewDelegate ,SKProductsRequestDelegate, SKPaymentTransactionObserver,downloadFileDelegate>{


    
    

}

+ (InAppPurchaseHelper *)sharedInstance;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithOnCompleteBock:(RequestProductsOnCompleteBlock)onCompleteBlock;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchasedWithProductIdentifier:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
-(BOOL)getDownloadingStatus;
-(NSDictionary *)getDictionary;
-(NSString *)getDirPathForProductId:(NSString*)productIdentifier;


-(void)checkForProductIdentifier:(NSString*)productidentifier inList:(NSArray *)products;
-(BOOL)checkProductsAvailable;
-(void)updateProductArray:(NSArray *)products;
-(NSArray *)getProductArray;
-(void)pauseDownload;
-(void)resumeDownload;


@property (nonatomic,assign) id <InAppDelegate> delegate;
@property (nonatomic,assign) BOOL isDownloading;

@end

