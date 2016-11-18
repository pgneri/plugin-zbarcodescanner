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
UIView *_bottomPanel;
UILabel *_topTitle;
NSString *_prompt;
NSString *_orientation;
NSString *_flash;
UIButton *_backButton;

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
        
        NSDictionary* options = command.arguments.count == 0 ? [NSNull null] : [command.arguments objectAtIndex:0];

        if ([options isKindOfClass:[NSNull class]]) {
          options = [NSDictionary dictionary];
        }
//        BOOL preferFrontCamera = [options[@"preferFrontCamera"] boolValue];
//        BOOL showFlipCameraButton = [options[@"showFlipCameraButton"] boolValue];
        _prompt = options[@"prompt"];
        _orientation = options[@"orientation"];
        _flash = options[@"flash"];

        self.scanInProgress = YES;
        self.scanCallbackId = [command callbackId];
        self.scanReader = [PgnScanner new];
        self.scanReader.readerDelegate = self;
        [self.scanReader.scanner setSymbology: ZBAR_UPCA config: ZBAR_CFG_ENABLE to: 0];
        self.scanReader.readerView.zoom = 1.0;
        
        
        if ([_flash isEqualToString:@"on"]) {
            self.scanReader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        } else if ([_flash isEqualToString:@"off"]) {
            self.scanReader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        } else if ([_flash isEqualToString:@"auto"]) {
            self.scanReader.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        } else {
            self.scanReader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        }
        
         // Hack to hide the bottom bar's Info button... originally based on http://stackoverflow.com/a/16353530
        NSInteger infoButtonIndex;
        if ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending) {
            infoButtonIndex = 1;
        } else {
            infoButtonIndex = 3;
        }
        UIView *infoButton = [[[[[self.scanReader.view.subviews objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:infoButtonIndex];
        [infoButton setHidden:YES];
        
        UIButton *cancelButton = [[[[[[[self.scanReader.view.subviews objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[cancelButton titleLabel] setFont:[UIFont systemFontOfSize:18]];
        [cancelButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [cancelButton setTitle:@"Cancelar" forState:UIControlStateNormal];

        
        //self.scanReader.showsZBarControls = NO;

        [self.scanReader.view addSubview:[self createOverlay]];
        
        if([_orientation  isEqual: @"landscape"]){
            NSLog(@"LANDINHO");
            [self.scanReader.view.layer addSublayer:[self createOverlayLandscape]];
        } else {
            NSLog(@"PORTRAITINHO");
            [self.scanReader.view.layer addSublayer:[self createOverlayPortrait]];

        }
        
        
        
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

#pragma mark - Overlay


//- (UIView*)createOverlayPortrait {
//
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        CGFloat screenWidth = screenRect.size.width;
//        CGFloat screenHeight = screenRect.size.height;
//        
//        CGFloat polyWidth = (screenWidth / 1.1);
//        CGFloat polyHeight = (screenWidth / 1.1);
//        CGFloat polyPosX = (screenWidth/2) - ((screenWidth / 1.1)/2);
//        CGFloat polyPosY = (screenHeight/2) - ((screenWidth / 1.1)/2);
//    
//        UIView *polygonView = [[UIView alloc] initWithFrame: CGRectMake  ( polyPosX, polyPosY, polyWidth, polyHeight)];
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,(screenWidth / 1.1) / 2, (screenWidth/1.1), 1)];
//        lineView.backgroundColor = [UIColor redColor];
//        [polygonView addSubview:lineView];
//
//        return polygonView;
//}

//- (UIView*)createOverlayLandscape {
//
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        CGFloat screenWidth = screenRect.size.width;
//        CGFloat screenHeight = screenRect.size.height;
//        
//        CGFloat polyWidth = (screenWidth / 1.1);
//        CGFloat polyHeight = (screenWidth / 1.1);
//        CGFloat polyPosX = (screenWidth/2) - ((screenWidth / 1.1)/2);
//        CGFloat polyPosY = (screenHeight/2) - ((screenWidth / 1.1)/2);
//    
//        UIView *polygonView = [[UIView alloc] initWithFrame: CGRectMake  ( polyPosX, polyPosY, polyWidth, polyHeight)];
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,(screenWidth / 1.1) / 2, (screenWidth/1.1), 1)];
//        lineView.backgroundColor = [UIColor redColor];
//        [polygonView addSubview:lineView];
//
//        return polygonView;
//}

- (UIView*)createOverlay {
    UIView *overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _topTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    [_topTitle setBackgroundColor: [UIColor clearColor]];
    [_topTitle setText:[NSString stringWithFormat:@"%@", _prompt]];
    [_topTitle setTextColor:[UIColor whiteColor]];
    [_topTitle setFont:[UIFont systemFontOfSize:16]];
    [_topTitle setTextAlignment:NSTextAlignmentCenter];
    [overlay addSubview:_topTitle];
    
    _bottomPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [_bottomPanel setBackgroundColor: [UIColor blackColor]];
    [overlay addSubview:_bottomPanel];

    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setTitle:[NSString stringWithFormat:@"Cancelar"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:18]];
//    [_backButton addTarget:self action:@selector(imagePickerControllerDidCancel) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_backButton];

    return overlay;
}

- (CALayer*)createOverlayLandscape {
    CGRect bounds = [[UIScreen mainScreen] bounds];

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((bounds.size.width/4), 0, bounds.size.width-(bounds.size.width/2), bounds.size.height) cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height) cornerRadius:0];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    fillLayer.opacity = 0.5;

    return fillLayer;
}


- (CALayer*)createOverlayPortrait {
    CGRect bounds = [[UIScreen mainScreen] bounds];

    int radius = bounds.size.width;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height) cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, (bounds.size.height-bounds.size.width)/2, radius, radius) cornerRadius:0];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];

    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    fillLayer.opacity = 0.5;

    return fillLayer;
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
