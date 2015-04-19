//
//  ViewController.m
//  IMU-Streamer
//
//  Created by Guillaume Legrain on 4/19/15.
//  Copyright (c) 2015 Guillaume Legrain. All rights reserved.
//

#import "ViewController.h"
#import "AsyncSocket.h"

@interface ViewController ()

@end

@implementation ViewController {
    AsyncSocket *_socket;
    NSMutableArray *_connectedSockets;
    CLLocationCoordinate2D _currentCoordinate;
    CLHeading *_currentHeading;
    NSTimer *timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init networking
    [self initServer];
    
    // init location services
    [self startHeadingEvents];
    
    // init timer
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sendSensorInformation) userInfo:nil repeats:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initServer
{
    if (!_socket) {
        _socket = [[AsyncSocket alloc] init];
        [_socket setDelegate:self];
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    int port = 10001;
    
    NSError *error = nil;
    if(![_socket acceptOnPort:port error:&error]) {
        NSLog(@"Error starting server: %@", error);
        return;
    }
    self.statusLabel.text = [NSString stringWithFormat:@"Listening on port %d ...", port];
}

- (void)onSocket:(AsyncSocket *)socket didAcceptNewSocket:(AsyncSocket *)newSocket
{
    [_connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port
{
    self.statusLabel.text = [NSString stringWithFormat:@"%@ connected on port %d", host, port];
    
    NSString *message = @"Welcome :)";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data withTimeout:-1 tag:0];
}

- (void)startHeadingEvents
{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
    }
    
    // Start location services to get the true heading.
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // All movements are reported
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter = 0.1;
        [self.locationManager startUpdatingHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    _currentHeading = newHeading;
    self.headingLabel.text = [NSString stringWithFormat:@"%fº",newHeading.trueHeading];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.lastObject;
    _currentCoordinate = location.coordinate;
    
    // update view
    self.locationLabel.text = [NSString stringWithFormat:@"%fº %fº", _currentCoordinate.latitude, _currentCoordinate.longitude];

}

-(void)sendSensorInformation
{
    // send data
    // "$accelx,accely,accelz,gyrox,gyroy,gyroz,magx,magy,magz#"
    // '$lat,lon,heading#'
    NSString *message = [NSString stringWithFormat:@"$%f,%f,%f#", _currentCoordinate.latitude, _currentCoordinate.longitude, _currentHeading.trueHeading];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    for (AsyncSocket *socket in _connectedSockets) {
        [socket writeData:data withTimeout:-1 tag:0];
    }
}

@end
