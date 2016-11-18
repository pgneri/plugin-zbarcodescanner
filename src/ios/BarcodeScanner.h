//
//  BarcodeScanner.h
//  BarcodeScanner
//
//  Created by Patrícia Gabriele Neri on 16/11/16.
//
//

#import <Cordova/CDV.h>
#import "ZBarSDK.h"
#import <UIKit/UIKit.h>

@interface BarcodeScanner : CDVPlugin  <ZBarReaderDelegate> {

}

- (void)scan:(CDVInvokedUrlCommand*)command;
@property (nonatomic, retain) UILabel *scanningLabel;
@property (nonatomic, retain) UIButton *backButton;

@end
