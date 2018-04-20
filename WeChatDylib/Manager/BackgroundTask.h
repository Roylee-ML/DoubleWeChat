//
//  BackgroundTask.h
//  WeChat
//
//  Created by roylee on 2018/4/10.
//  Copyright © 2018年 roylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundTask : NSObject

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask;

- (void)endBackgroundTask;

@end
