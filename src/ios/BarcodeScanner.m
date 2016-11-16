//
//  BarcodeScanner.m
//  BarcodeScanner
//
//  Created by Patrícia Gabriele Neri on 16/11/16.
//
//

#import "BarcodeScanner.h"

@implementation BarcodeScanner

- (void)scan:(CDVInvokedUrlCommand*)command {
    // NSString *prompt = [command argumentAtIndex:0];
    // NSString preferFrontCamera = [command argumentAtIndex:2];
    // NSString showFlipCameraButton = [command argumentAtIndex:1];
    // NSString formats = [command argumentAtIndex:3];
    // NSString orientation = [command argumentAtIndex:4];

    ZBarReaderViewController *reader = [ZBarReaderViewController new];
   reader.readerDelegate = self;

   [reader.scanner setSymbology: ZBAR_UPCA config: ZBAR_CFG_ENABLE to: 0];
   reader.readerView.zoom = 1.0;

   [self presentViewController:reader animated:YES completion:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];

    ZBarSymbol *symbol = nil;

    for(symbol in results){

        NSString *upcString = symbol.data;

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scanned UPC" message:[NSString stringWithFormat:@"The UPC read was: %@", upcString] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];

        [alert show];

        [reader dismissViewControllerAnimated:YES
                                           completion:nil];
    }


}


@end
