//
//  BarcodeScanner.h
//  BarcodeScanner
//
//  Created by Patrícia Gabriele Neri on 16/11/16.
//
//

#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface BarcodeScanner : CDVPlugin  <ZBarReaderDelegate> {

}

- (void)scan:(CDVInvokedUrlCommand*)command;

@end
