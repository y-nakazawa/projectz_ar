//
//  CameraViewController.m
//  Camera
//
//  Created by 中澤 祐一 on 13/02/26.
//  Copyright (c) 2013年 中澤 祐一. All rights reserved.
//

#import "ARViewController.h"
#import "ViewController.h"

@interface ARViewController ()


@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 電子コンパス起動
    [self locationMngCheckAndStart];
    // 加速度センサ及び、ジャイロセンサの起動
    [self motionManagerCheckAndStart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ロケーションマネージャ（電子コンパス、位置情報）の使用有無と開始
- (void)locationMngCheckAndStart
{
    // 電子コンパス及び、GPS使用可能？
    if (([CLLocationManager headingAvailable]) && ([CLLocationManager locationServicesEnabled]))
    {
        self._locationManager = [[CLLocationManager alloc] init];
        self._locationManager.delegate = self;
        // コンパスの使用を開始する
        [self._locationManager startUpdatingHeading];
        
        // GPS最大精度
        self._locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // GPS取得間隔
        self._locationManager.distanceFilter = kCLDistanceFilterNone;
        // GPSの使用を開始する
        [self._locationManager startUpdatingLocation];
    }
    
    
}

// 加速度センサ及び、ジャイロセンサの使用有無と開始
- (void)motionManagerCheckAndStart
{
    self._motionManager = [[CMMotionManager alloc]init];
    
    // 向きを検知可能かどうかをチェックする
    if (self._motionManager.deviceMotionAvailable) {
        // 更新間隔を設定する
        self._motionManager.deviceMotionUpdateInterval = 1.0f / 6.0f;
        
        // ハンドラを設定する
        CMDeviceMotionHandler   deviceMotionHandler;
        deviceMotionHandler = ^ (CMDeviceMotion* motion, NSError* error) {
            // デバイスの向きを表示する
            NSLog(@"motion { %f, %f, %f }",
                  motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw);
            
            // 加速度を設定する
            self.arView.gravity = motion.gravity;
            
            // デバイスの向きを設定する
            self.arView.roll = motion.attitude.roll;
            self.arView.pitch = motion.attitude.pitch;
            self.arView.yaw = motion.attitude.yaw;
        };
        
        // 向きの更新通知を開始する
        [self._motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:deviceMotionHandler];
        
    }
}

- (IBAction)showCameraSheet
{
    // アクションシートを作る
    UIActionSheet* sheet;
    
    sheet = [[UIActionSheet alloc]
             initWithTitle:@"Select Source Type"
             delegate:self
             cancelButtonTitle:@"Cancel"
             destructiveButtonTitle:nil
             otherButtonTitles:@"Photo Libraty", @"Cameta",@"AR",
             @"Save Photos", @"menu",nil
             ];
    //    [sheet autorelease];
    
    // アクションシートを表示する
    [sheet showInView:self.view];
}

// アクションシートのイベントハンドラ
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ボタンインデックスをチェックする
    if (buttonIndex >= 5 ) {
        return;
    }
    
    // ソースタイプを決定する
    UIImagePickerControllerSourceType souceType = 0;
    
    switch (buttonIndex) {
        case 0 :
            souceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 1 :
            souceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 2 :
            souceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 3 :
            souceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        case 4 :
            souceType = 0;
            break;
        default:
            break;
    }
    
    
    if ( souceType != 0 ) {
        // 使用可能かどうかチェックする
        if (![UIImagePickerController isSourceTypeAvailable:souceType]) {
            return;
        }

        //　イメージピッカーを作る
        UIImagePickerController* imagePicker;
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = souceType;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;

        UIImage *image = [UIImage imageNamed:@"cat.png"];

        if (buttonIndex == 2) { // AR？
        //        self.arView = [[ARView alloc] initWithFrame:CGRectMake(0,0,500,500)];
            self.arView = [[ARView alloc] initWithFrame:CGRectMake(0,0,320,480)];

        /*
            // 電子コンパス起動
            [self locationMngCheckAndStart];
            // 加速度センサ及び、ジャイロセンサの起動
            [self motionManagerCheckAndStart];
        */        
            // カメラコントロールを隠す
            imagePicker.showsCameraControls = NO;
            // カメラオーバーレイビューを追加する
            imagePicker.cameraOverlayView = self.arView;
            
            // イメージピッカーを表示
            [self presentViewController: imagePicker animated:NO completion: nil];
            
            // アニメーションを開始する
            [self.arView startAnimation];
        } else {
            // カメラコントロールを表示
            imagePicker.showsCameraControls = YES;
            
            // イメージピッカーを表示する
            //    [self presentModalViewController:imagePicker animated:YES];
            [self presentViewController: imagePicker animated:YES completion: nil];
        }
    } else {
        if ( buttonIndex == 4 ) {
            //遷移先ViewControllerクラスのインスタンス生成
            ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vc"];//手順1で付けた名前
            [self presentViewController:vc animated:YES completion: nil];
        }
    }
}

// カメラ撮影後に呼ばれるデリゲード
- (void)imagePickerController:(UIImagePickerController*)picker
        didFinishPickingImage:(UIImage*)image
                  editingInfo:(NSDictionary*)editingInfo
{
    // イメージピッカーを隠す
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
    // オリジナル画像を取得する
    UIImage* originalImage;
    originalImage = [editingInfo objectForKey:UIImagePickerControllerOriginalImage];

/*
    // グラフックコンキストを作る
    CGSize  size = { 300, 400 };
    UIGraphicsBeginImageContext(size);
    
    // 画像を縮小して描画
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [originalImage drawInRect:rect];
    
    // 描画した画像を取得する
    UIImage* shrinkedImage;
    shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
*/
    UIImage* shrinkedImage;
    UIImage* effectedImage;
    
    shrinkedImage = [self normalPictureEdit:originalImage];
    effectedImage = [self effectPicture:shrinkedImage];
    
    // 画像を表示する。
//    self._imageView.image = shrinkedImage;
    self._imageView.image = effectedImage;
    
}

// 画像の縮小をし、UIImageオブジェクトを返す
- (UIImage *)normalPictureEdit:(UIImage* )orgimg {
    // グラフックコンキストを作る
    CGSize  size = { 300, 400 };
    UIGraphicsBeginImageContext(size);
    
    // 画像を縮小して描画
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [orgimg drawInRect:rect];
    
    // 描画した画像を取得する
    UIImage* editImage;
    editImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 画像を表示する。
    return editImage;
}

// 画像の縮小をし、UIImageオブジェクトを返す
- (UIImage *)effectPicture:(UIImage* )orgimg {
    // CGImageを取得する。
    CGImageRef cgImage;
    cgImage = orgimg.CGImage;
    
    // 画像情報を取得する。
    size_t                  width;
    size_t                  height;
    size_t					bitsPerComponent;
    size_t					bitsPerPixel;
    size_t					bytesPerRow;
    CGColorSpaceRef			colorSpace;
    CGBitmapInfo			bitmapInfo;
    bool					shouldInterpolate;
    CGColorRenderingIntent  intent;
    
    // 各種画像情報を取得
    width = CGImageGetWidth(cgImage);
    height = CGImageGetHeight(cgImage);
    bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
    bytesPerRow = CGImageGetBytesPerRow(cgImage);
    colorSpace = CGImageGetColorSpace(cgImage);
    bitmapInfo = CGImageGetBitmapInfo(cgImage);
    shouldInterpolate = CGImageGetShouldInterpolate(cgImage);
    intent = CGImageGetRenderingIntent(cgImage);
    
    
    // CGImageからCGDataProviderを取り出す
    CGDataProviderRef dataProvider;
    dataProvider = CGImageGetDataProvider(cgImage);
    
    // ビットマップデータを取得する
    CFDataRef data;
    CFMutableDataRef inputData;
    UInt8 *   buffer;

// iOS6からこの処理じゃないとメモリ参照エラーになる
//    data = CGDataProviderCopyData(dataProvider);
//    buffer = (UInt8 *)CFDataGetBytePtr(data);
    data = CGDataProviderCopyData(dataProvider);
    inputData = CFDataCreateMutableCopy(0, 0, data);
    buffer = (UInt8 *)CFDataGetBytePtr(inputData);
    
    // ビットマップに効果を与える
    NSInteger i,j;
    for (j=0; j < height; j++) {
        for (i=0; i < width; i++) {
            // ピクセルのポインタを取得
            UInt8*  tmp;
            tmp = buffer + j * bytesPerRow + i * 4;
//            tmp = buffer + j * bytesPerRow + i * bitsPerPixel / 8;
            
            // RGBの値を取得する
            UInt8 r, g, b;

            r = *(tmp + 3);
            g = *(tmp + 2);
            b = *(tmp + 1);
/*
            r = *(tmp + 2);
            g = *(tmp + 1);
            b = *(tmp + 0);
*/
            // 輝度値を計算する
            UInt8 y;
//            y = (77 * r + 28 * g + 151 * b) / 256;
            y = (70 * r + 35 * g + 151 * b) / 256;
            
            // 輝度の値をRGB値として設定する

            *(tmp + 1) = y;
            *(tmp + 2) = y;
            *(tmp + 3) = y;
/*
            *(tmp + 0) = y;
            *(tmp + 1) = y;
            *(tmp + 2) = y;
*/
        }
    }
    
    // 効果を与えたデータを作成する
    CFDataRef effectedData;
//    effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(inputData));
    
    // 効果を与えたデータプロバイダを作成する
    CGDataProviderRef   effectedDataProvider;
    effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
    // 画像を作成する
    CGImageRef effectedCgImage;
    UIImage*    effectedImage;
    
    effectedCgImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, effectedDataProvider, NULL, shouldInterpolate, intent);
    
    effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
    CGImageRelease(effectedCgImage);
    CFRelease(effectedData);
    CFRelease(inputData);
    CFRelease(data);
    return effectedImage;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // イメージピッカーを隠す
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// 方位変化時によばれるデリゲード
- (void) locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading {
    // 方位を表示する
    NSLog(@"trueHeading %f, magneticHeading %f", newHeading.trueHeading, newHeading.magneticHeading);
    // 方位を設定する
    self.arView.heading = newHeading.trueHeading;
}

// 位置情報変化時によばれるデリゲード
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation*)newLocation
        fromLocation:(CLLocation*)oldLocation {
    
    self._latitude = newLocation.coordinate.latitude;
    self._longitude = newLocation.coordinate.longitude;
    
    // 位置情報の向きを表示する
    NSLog(@"location { %f, %f }",
          self._latitude, self._longitude);
}
@end
