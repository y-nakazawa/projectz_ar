//
//  LocationEditViewController.h
//  AR
//
//  Created by 中澤 祐一 on 13/05/05.
//  Copyright (c) 2013年 中澤 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationEditViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *_txt_location;
@property (strong, nonatomic) IBOutlet UITextField *_txt_latitude;
@property (strong, nonatomic) IBOutlet UITextField *_txt_longitude;
@property (strong, nonatomic) IBOutlet UITextField *_txt_remarks;
@end
