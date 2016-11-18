//
//  BarcodeScanner.m
//  BarcodeScanner
//
//  Created by Patrícia Gabriele Neri on 16/11/16.
//
//

#import "BarcodeScanner.h"
#import <AVFoundation/AVFoundation.h>
#import "PgnScanner.h"

#pragma mark - State

@interface BarcodeScanner ()
@property bool scanInProgress;
@property NSString *scanCallbackId;
@property PgnScanner *scanReader;

@end

#pragma mark - Synthesize

@implementation BarcodeScanner

@synthesize scanInProgress;
@synthesize scanCallbackId;
@synthesize scanReader;

#pragma mark - Cordova Plugin

- (void)pluginInitialize {
    self.scanInProgress = NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    return;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Plugin API

- (void)scan: (CDVInvokedUrlCommand*)command;
{
    [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
                               withObject:(__bridge id)((void*)UIInterfaceOrientationMaskPortrait)];
                               
    if (self.scanInProgress) {
        [self.commandDelegate
         sendPluginResult: [CDVPluginResult
                            resultWithStatus: CDVCommandStatus_ERROR
                            messageAsString:@"A scan is already in progress."]
         callbackId: [command callbackId]];
        
    } else {
        self.scanInProgress = YES;
        self.scanCallbackId = [command callbackId];
        self.scanReader = [PgnScanner new];
        self.scanReader.readerDelegate = self;
        [self.scanReader.scanner setSymbology: ZBAR_UPCA config: ZBAR_CFG_ENABLE to: 0];
        self.scanReader.readerView.zoom = 1.0;
        
        
        
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        CGFloat screenWidth = screenRect.size.width;
//        CGFloat screenHeight = screenRect.size.height;
//        
//        BOOL portrait = screenWidth < screenHeight ? YES : NO;
//        CGFloat polyWidth = (screenWidth / 1.1);
//        CGFloat polyHeight = (screenWidth / 1.1);
//        CGFloat polyPosX = (screenWidth/2) - ((screenWidth / 1.1)/2);
//        CGFloat polyPosY = (screenHeight/2) - ((screenWidth / 1.1)/2);
//        
//        if(portrait == NO) {
////             polyWidth = (screenWidth / 1.1);
////             polyHeight = (screenHeight / 1.1);
////             polyPosX = 0;
////             polyPosY = 0;
//        }
//        
////CGFloat dim = screenWidth < screenHeight ? screenWidth / 1.1 : screenHeight / 1.1;
////UIView *polygonView = [[UIView alloc] initWithFrame: CGRectMake  ( (screenWidth/2) - (dim/2), (screenHeight/2) - (dim/2), dim, dim)];
////
////UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,dim / 2, dim, 1)];
////lineView.backgroundColor = [UIColor redColor];
//
//        
//        UIView *polygonView = [[UIView alloc] initWithFrame: CGRectMake  ( polyPosX, polyPosY, polyWidth, polyHeight)];
//        polygonView.backgroundColor = [UIColor redColor];
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,(screenHeight/1.1) / 2, (screenWidth/1.1), 1)];
//        lineView.backgroundColor = [UIColor redColor];
//        [polygonView addSubview:lineView];
//
//        self.scanReader.cameraOverlayView = polygonView;

        [self.viewController presentViewController:self.scanReader animated:YES completion:nil];
    }
}


#pragma mark - Helpers

- (void)sendScanResult: (CDVPluginResult*)result {
    [self.commandDelegate sendPluginResult: result callbackId: self.scanCallbackId];
}

#pragma mark - ZBarReaderDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    return;
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    if ([self.scanReader isBeingDismissed]) {
        return;
    }

    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];

    ZBarSymbol *symbol = nil;
    for (symbol in results) break; // get the first result

    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsString: symbol.data]];
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                                resultWithStatus: CDVCommandStatus_ERROR
                                messageAsString: @"cancelled"]];
    }];
}

- (void) readerControllerDidFailToRead:(ZBarReaderController*)reader withRetry:(BOOL)retry {
    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                                resultWithStatus: CDVCommandStatus_ERROR
                                messageAsString: @"Failed"]];
    }];
}

@end
