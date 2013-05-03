//
//  ARViewController.h
//  AR
//
//  Created by 中澤 祐一 on 13/02/26.
//  Copyright (c) 2013年 中澤 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
//@class ARView;
#import "ARView.h"

@interface ARViewController : UIViewController<UIActionSheetDelegate> {
    
//    ARView*   arView;
}
//@property (strong, nonatomic) IBOutlet UIImageView *_imageView;
@property (strong, nonatomic) IBOutlet UIImageView *_imageView;
@property (strong, nonatomic) IBOutlet UILabel *_label;
@property (strong, nonatomic) CLLocationManager *_locationManager;
@property (strong, nonatomic) CMMotionManager *_motionManager;

@property (nonatomic) double _latitude;
@property (nonatomic) double _longitude;

@property (strong, nonatomic) ARView* arView;
-(IBAction)showCameraSheet;
@end
