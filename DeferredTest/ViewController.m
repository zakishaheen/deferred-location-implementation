//
//  ViewController.m
//  DeferredTest
//
//  Created by Zaki Shaheen on 9/13/16.
//  Copyright © 2016 Zaki Shaheen. All rights reserved.
//

#import "ViewController.h"

@import CoreLocation;
@import CocoaLumberjack;
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;


@interface ViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL isDeferringUpdates;
@end

@implementation ViewController

- (void) initializeLumberjack {

  DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
  fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
  fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
  fileLogger.logFormatter = self;
  [DDLog addLogger:fileLogger];

  DDLogInfo(@"Initialized file logging");
}

- (void) initializeLocationManager{
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.allowsBackgroundLocationUpdates = YES;
  self.locationManager.pausesLocationUpdatesAutomatically = NO;
  self.locationManager.activityType = CLActivityTypeFitness;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  self.locationManager.distanceFilter = kCLDistanceFilterNone;
  self.locationManager.headingFilter = kCLHeadingFilterNone;
  
  self.locationManager.delegate = self;

  DDLogInfo(@"Initialized location manager");
}
- (IBAction)startTapped:(id)sender {
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
    [self.locationManager requestAlwaysAuthorization];
  }

  [self.locationManager startUpdatingLocation];

  DDLogInfo(@"Starting updating location");
}

- (IBAction)stopTapped:(id)sender {
  [self.locationManager stopUpdatingLocation];
  DDLogInfo(@"Stopped location updates");
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self initializeLumberjack];
  [self initializeLocationManager];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppBecomesActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppBackgrounded:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) handleAppBecomesActive:(NSNotification *)notification{
  if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways){
    return;
  }

  if (self.isDeferringUpdates) {
    // Should invoke didFinishDeferredUpdatedWithError with kCLErrorDeferringCancelled
    [self.locationManager disallowDeferredLocationUpdates];
    DDLogInfo(@"App foregrounded, cancelled deferring");
  }
}

- (void) handleAppBackgrounded:(NSNotification *)notification{
  if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways){
    return;
  }

  [self.locationManager stopUpdatingLocation];  // should trigger deferring cancelled
  [self.locationManager startUpdatingLocation];
  DDLogInfo(@"App backgrounded, will restart deferring on next location update");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
  if (status == kCLAuthorizationStatusAuthorizedAlways) {
    [self.locationManager startUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
  DDLogInfo(@"LocationManager failed: %@", [error debugDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
  if (locations.count > 1) {
    DDLogInfo(@"Deferred %ld location", locations.count);
  }

  UIApplicationState state = [[UIApplication sharedApplication] applicationState];

  if (state == UIApplicationStateActive) {
    return;
  }else if (!self.isDeferringUpdates) {
    [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:180];
    self.isDeferringUpdates = YES;
  }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
  self.isDeferringUpdates = NO;

  if (error) {
    DDLogInfo(@"Deferring failed, error: %@", [error debugDescription]);
  }else{
    DDLogInfo(@"Deferring ended successfully");
  }
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{
  DDLogInfo(nil);
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{
  DDLogInfo(nil);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage{
  UIApplicationState state = [[UIApplication sharedApplication] applicationState];

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
  formatter.timeZone = [NSTimeZone systemTimeZone];

  return [NSString stringWithFormat:@"%@ %@ %@ %ld", [formatter stringFromDate:logMessage.timestamp], logMessage.function, logMessage.message, state];
}

@end
