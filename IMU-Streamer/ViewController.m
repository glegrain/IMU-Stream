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
    AsyncSocket *socket;
    NSMutableArray *connectedSockets;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	socket = [[AsyncSocket alloc] init];
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    [socket setDelegate:self];
    [self initServer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initServer
{
    int port = 10001;
    
    NSError *error = nil;
    if(![socket acceptOnPort:port error:&error]) {
        NSLog(@"Error starting server: %@", error);
        return;
    }
    self.statusLabel.text = [NSString stringWithFormat:@"Listening on port %d ...", port];
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    [connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"didConnectToHost");
    NSLog(@"%@ connected on port %d", host, port);
    
    NSString *message = @"Welcome :)";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:data withTimeout:-1 tag:0];
    //[sock readDataToData:[AsyncSocket CRLFData] withTimeout: 10 tag:0];
}

@end
