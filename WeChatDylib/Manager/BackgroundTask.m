//
//  BackgroundTask.m
//  WeChat
//
//  Created by roylee on 2018/4/10.
//  Copyright © 2018年 roylee. All rights reserved.
//

#import "BackgroundTask.h"

@interface BackgroundTask () {
    UIBackgroundTaskIdentifier _currentBackgroundTaskIdfy;
}
@end

@implementation BackgroundTask

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentBackgroundTaskIdfy = UIBackgroundTaskInvalid;
    }
    return self;
}

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask {
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = UIBackgroundTaskInvalid;

    backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        if (backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            [application endBackgroundTask:backgroundTaskIdentifier];
            backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
    
    // Stop the last background task if it still runing.
    if (_currentBackgroundTaskIdfy != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:_currentBackgroundTaskIdfy];
    }
    
    _currentBackgroundTaskIdfy = backgroundTaskIdentifier;
    
    return backgroundTaskIdentifier;
}

- (void)endBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:_currentBackgroundTaskIdfy];
    _currentBackgroundTaskIdfy = UIBackgroundTaskInvalid;
}

@end
