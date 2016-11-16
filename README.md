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

### Options

|         Option       | Default Value |        Description        |
|----------------------|---------------|---------------------------|
| preferFrontCamera | false |  |
| showFlipCameraButton | false |  |
| prompt | "" | supported on Android only |
| formats | all |  "QR_CODE,PDF_417" |
| orientation | "landscape" | Android only (portrait|landscape), default unset so it rotates with the device |

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
       alert("Scanning failed: " + error);
   },
   {
       "preferFrontCamera" : true, // iOS and Android
       "showFlipCameraButton" : true, // iOS and Android
       "prompt" : "Place a barcode inside the scan area", // supported on Android only
       "formats" : "QR_CODE,PDF_417", // default: all but PDF_417 and RSS_EXPANDED
       "orientation" : "landscape" // Android only (portrait|landscape), default unset so it rotates with the device
   }
);
```
