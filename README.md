### Description

Cordova plugin zBarCodeScanner.

### Using the plugin

```js
cordova.plugins.barcodeScanner.scan(success, failure, [ options ]);
```

Note: Since iOS 10 it's mandatory to add a NSCameraUsageDescription in the info.plist.

NSCameraUsageDescription describes the reason that the app accesses the user’s camera. When the system prompts the user to allow access, this string is displayed as part of the dialog box.

To add this entry you can pass the following variable on plugin install.

cordova plugin add https://github.com/pgneri/plugin-zbarcodescanner --variable CAMERA_USAGE_DESCRIPTION="To scan barcodes"

The following barcode types are currently supported:

## Android

* QR_CODE
* DATA_MATRIX
* UPC_E
* UPC_A
* EAN_8
* EAN_13
* CODE_128
* CODE_39
* CODE_93
* CODABAR
* ITF
* RSS14
* RSS_EXPANDED
Not by default, but supported if you pass in the "formats" option:
* PDF417
* AZTEC

## iOS

* QR_CODE
* DATA_MATRIX
* UPC_E
* UPC_A
* EAN_8
* EAN_13
* CODE_128
* CODE_39
* ITF

### Supported Platforms

* Android
* iOS

Note: the Android source forked https://github.com/phonegap/phonegap-plugin-barcodescanner version 6.0.3.

### Options

|         Option       | Default Value |        Description        |
|----------------------|---------------|---------------------------|
| preferFrontCamera | false | Android Only |
| showFlipCameraButton | false | Android Only |
| prompt | "" | Description value |
| formats | all |  Android Only, use example: "QR_CODE,PDF_417" |
| orientation | "portrait" | default portrait, alter overlay mask |
| flash | off |  iOS only, use 'off', 'on' or 'auto' |
| titleButtonCancel | Cancel |  iOS only, title text to cancel button. |


### Example

```js
cordova.plugins.barcodeScanner.scan(
         function (result) {
             alert("We got a barcode\n" +
                   "Result: " + result.text + "\n" +
                   "Format: " + result.format + "\n" +
                   "Cancelled: " + result.cancelled);
         },
         function (error) {
             if(error.cancelled==1){
                  alert("Cancelled");
             } else {
                  alert("Scanning failed: " + error);
             }
         },
         {
             "preferFrontCamera" : true, //  Android Only
             "showFlipCameraButton" : true, //  Android Only
             "prompt" : "Place a barcode inside the scan area", // supported on Android only
             "formats" : "QR_CODE,PDF_417", // Android Only
             "orientation" : "landscape", //  default portrait
             "flash" : "auto", // iOS only
             "titleButtonCancel":"Cancel" // iOS only
         }
      );

```
Example app:
https://github.com/pgneri/cordova.app.exampleUsePlugins
