//
//  JASettingConfig.m
//  WeChatDylib
//
//  Created by roylee on 2018/4/11.
//  Copyright © 2018年 roylee. All rights reserved.
//

#import "JASettingConfig.h"

static NSString *const kJASettingConfigKeepAlive = @"kJASettingConfigKeepAlive";

@implementation JASettingConfig

+ (void)setKeepBackgroundAlive:(BOOL)keepBackgroundAlive {
    [[NSUserDefaults standardUserDefaults] setBool:keepBackgroundAlive forKey:kJASettingConfigKeepAlive];
}

+ (BOOL)isKeepBackgroundAlive {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kJASettingConfigKeepAlive];
}

@end
