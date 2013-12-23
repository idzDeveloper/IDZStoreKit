IDZ Store Kit for ios non-consumable products This is 1.0 version of IDZStoreKit which supports iOS 5 and above. This kit is for NON-CONSUMABLE PRODUCTS ONLY. All the AFNetworking files are in ARC. You have to add flag -fobjc-arc to those files in target->build phases->compile sources. In-app purchase hosted content is present for iOS 6 and above devices. For below iOS 6 devices you have to use your own server. A demo has also been given with the code provided. You have to just enter your values like productId,Product url,Hosted content present or not for that particular product, etc. All the details regarding using the IDZStoreKit is described below:


Steps:

1) Add InAppPurchase and custom Progress folders to your project. Make sure you have checked copy items into destination group's folder.

2) Add Following Frameworks and library: a) MobileCoreServices.framework b) SystemConfiguration.framework c) StoreKit.framework d) libz.1.2.5.dylib

3) Add -fobjc-arc flag to AfNetworking files in target->build phases->compile sources.

4) import IDZInAppPurchaseHelper.h file in delegate.m file.

(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	[InAppPurchaseHelper sharedInstance]; [self productRequest];
	//// ....... You code ....... //// 
}
-(void)productRequest
{
	if (![[InAppPurchaseHelper sharedInstance] checkProductsAvailable]) {
	     [[InAppPurchaseHelper sharedInstance] requestProductsWithOnCompleteBock:^(BOOL success, NSArray *products) { 
	     if (success) { 
		NSArray *array=products; [[InAppPurchaseHelper sharedInstance] updateProductArray:array];} 
	}];
 } 
}

5) Adding Product Data: 
a) Open IDZInAppPurchaseHelper.h file and in the beginning replace your productId/s. 
b) Open product_detail.plist file and add the product details. 
c) Add Products as required to the plist and accordingly make changes to IDZInAppPurchaseHelper class for adding new Product.


6) import IDZInAppPurchaseHelper.h to the controller/s where you want to check or purchase the product. 
a) for checking if product is purchased or not, add following lines: [[InAppPurchaseHelper sharedInstance] productPurchasedWithProductIdentifier:productId]; where productId = kProductAId/kProductBId/.… 
b)-(void)updateProgressViewOf:(NSString *)identifier withValue:(float)progress delegate method is optional if you want to track downloading status of zip files. For more details you can go through the IDZDownloadFileFromServer and DownloadFileFromServer class code.

you can go through the demo project for any help or you can also contact me at iphonedevidz@gmail.com

7) For iOS 5 server side downloading you can add url of the product to product_detail.plist file. for customising iOS 5 downloading view go to DownloadFileFromServer class which handles downloading from server, unzipping the zip file and saving the path of downloaded folder.


License:
IDZStoreKit uses MIT Licensing And so all of source code can be used royalty-free into your app. Just make sure that you don’t remove the copyright notice from the source code if you make your app open source and in the about page.
