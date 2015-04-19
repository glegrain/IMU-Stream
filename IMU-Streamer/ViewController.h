//
//  ViewController.h
//  IMU-Streamer
//
//  Created by Guillaume Legrain on 4/19/15.
//  Copyright (c) 2015 Guillaume Legrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@end
