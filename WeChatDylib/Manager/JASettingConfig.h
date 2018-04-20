//
//  JASettingConfig.h
//  WeChatDylib
//
//  Created by roylee on 2018/4/11.
//  Copyright © 2018年 roylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JASettingConfig : NSObject

/// Background keep alive setting.
@property (class, nonatomic, getter=isKeepBackgroundAlive) BOOL keepBackgroundAlive;

@end
