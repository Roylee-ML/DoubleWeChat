//
//  KeepAliveManager.m
//  WeChat
//
//  Created by roylee on 2018/4/10.
//  Copyright © 2018年 roylee. All rights reserved.
//

#import "KeepAliveManager.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BackgroundTask.h"

static CGFloat const kKeepAliveRestartDelay = 120.f;
static CGFloat const kKeepAliveStopDelay = 10.f;

@interface KeepAliveManager () <CLLocationManagerDelegate, UIAlertViewDelegate> {
    BOOL _isLocationUpdating;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) BackgroundTask *backgroundTask;

@end

@implementation KeepAliveManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

+ (instancetype)sharedManager {
    static KeepAliveManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [KeepAliveManager new];
    });
    return manager;
}

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        if (@available(iOS 9.0, *)) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.delegate = self;
        // Use `kCLDistanceFilterNone` to refresh the locaiton when did not move.
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return _locationManager;
}

- (BackgroundTask *)backgroundTask {
    if (_backgroundTask == nil) {
        _backgroundTask = [BackgroundTask new];
    }
    return _backgroundTask;
}

#pragma mark - Public

- (void)openKeepAliveOnBackground {
    if ([JASettingConfig isKeepBackgroundAlive]) {
        [self startLocationMonitor];
    }
}

- (void)closeKeepAliveOnBackground {
    [self stopLocationMonitor];
}

- (void)switchBackgroundKeepAlive {
    [JASettingConfig setKeepBackgroundAlive:![JASettingConfig isKeepBackgroundAlive]];
    
    if ([JASettingConfig isKeepBackgroundAlive]) {
        [self openKeepAliveOnBackground];
    }else {
        [self closeKeepAliveOnBackground];
    }
}

#pragma mark - Private

- (void)startLocationMonitor {
    if ([CLLocationManager locationServicesEnabled] == NO) {
        [[[UIAlertView alloc] initWithTitle:@"提示"
                                    message:@"当前设备的定位服务不可用"
                                   delegate:nil
                          cancelButtonTitle:@"知道了"
                          otherButtonTitles:nil] show];
        return;
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    
    if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted) {
        [[[UIAlertView alloc] initWithTitle:@"定位不可用"
                                    message:@"当前设备的定位服务已经关闭，请在【设置】中打开【始终】获取定位服务，以便能够及时收到消息哦😉~"
                                   delegate:self
                          cancelButtonTitle:@"稍后再说"
                          otherButtonTitles:@"立即开启", nil] show];
    }else if (authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [[[UIAlertView alloc] initWithTitle:@"定位服务修改"
                                    message:@"亲，只有在【设置】中打开【始终】获取定位服务，才能够及时的收到消息哦😉~"
                                   delegate:self
                          cancelButtonTitle:@"稍后再说"
                          otherButtonTitles:@"立即修改", nil] show];
    }else {
        if([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
}

- (void)restartLocationMonitor {
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // Add a background task.
    [self.backgroundTask beginNewBackgroundTask];
}

- (void)stopLocationMonitor {
    _isLocationUpdating = NO;
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - UIApplication

- (void)applicationDidBecomeActive {
    // Cancel all the start & stop action.
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // Stop the location updating when become active.
    [self stopLocationMonitor];
}

- (void)applicationEnterBackground {
    [self restartLocationMonitor];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    [self openSystemSetting];
}

- (void)openSystemSetting {
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES&path=com.roylee.xin"]];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (_isLocationUpdating) {
        return;
    }
    [self performSelector:@selector(stopLocationMonitor) withObject:nil afterDelay:kKeepAliveStopDelay];
    [self performSelector:@selector(restartLocationMonitor) withObject:nil afterDelay:kKeepAliveRestartDelay];
    _isLocationUpdating = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    switch(error.code) {
        case kCLErrorNetwork: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络连接" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert show];
        }
            break;
        case kCLErrorDenied: {
            [[[UIAlertView alloc] initWithTitle:@"请开启后台定位"
                                        message:@"当前设备的后台定位服务已经关闭，请在【设置】-【通用】中打开后台应用刷新服务，以便能够及时收到消息哦😉~"
                                       delegate:self
                              cancelButtonTitle:@"稍后再说"
                              otherButtonTitles:@"立即开启", nil] show];
        }
            break;
        default:
            break;
    }
}

@end
