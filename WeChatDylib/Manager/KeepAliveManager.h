//
//  KeepAliveManager.h
//  WeChat
//
//  Created by roylee on 2018/4/10.
//  Copyright © 2018年 roylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JASettingConfig.h"

@interface KeepAliveManager : NSObject

@property (class, nonatomic, readonly) KeepAliveManager *sharedManager;

/// Open the backgorund alive function, here is using location to
/// keep alive.
- (void)openKeepAliveOnBackground;

/// Close background keep alive.
- (void)closeKeepAliveOnBackground;

/// Switch background keep alive.
- (void)switchBackgroundKeepAlive;

@end
