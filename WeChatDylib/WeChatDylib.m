//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  WeChatDylib.m
//  WeChatDylib
//
//  Created by roylee on 2018/4/11.
//  Copyright (c) 2018年 roylee. All rights reserved.
//

#import "WeChatDylib.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import "KeepAliveManager.h"
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#pragma GCC diagnostic ignored "-Wunused-variable"

static NSString *const kWeChatBoundleId = @"com.tencent.xin";

CHConstructor {
    NSLog(INSERT_SUCCESS_WELCOME);
    
    [[NSNotificationCenter defaultCenter] addObserverForName :UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
#ifndef __OPTIMIZE__
        CYListenServer(6666);
#endif
    }];
}

CHDeclareClass(MicroMessengerAppDelegate)
CHDeclareClass(NSDictionary)
/// Main page
CHDeclareClass(NewMainFrameViewController);
CHDeclareClass(MFTitleView);
/// Setting page
CHDeclareClass(NewSettingViewController);
CHDeclareClass(MMTableViewInfo);
CHDeclareClass(MMTableViewSectionInfo);
CHDeclareClass(MMTableViewCellInfo);
CHDeclareClass(MMTableView);


/// Add keep alive on background
CHOptimizedMethod2(self, void, MicroMessengerAppDelegate, application, UIApplication *, application, didFinishLaunchingWithOptions, NSDictionary *, options) {
    CHSuper2(MicroMessengerAppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    NSLog(@"## Load FishConfigurationCenter ##");
    [KeepAliveManager.sharedManager openKeepAliveOnBackground];
}

/// Hook the boundle id
CHOptimizedMethod1(self, id, NSDictionary, objectForKey, id, key) {
    id value = CHSuper1(NSDictionary, objectForKey, key);
    if ([key isKindOfClass:[NSString class]] && [key isEqualToString:(__bridge NSString *)kCFBundleIdentifierKey]){
        return kWeChatBoundleId;
    }
    return value;
}

/// Main page title change
CHOptimizedMethod2(self, void, MFTitleView, updateTitleView, NSInteger, index, title, NSString *, title) {
    if ([title containsString:@"微信"]) {
        title = [title stringByReplacingOccurrencesOfString:@"微信" withString:@"Joanne"];
    }
    CHSuper2(MFTitleView, updateTitleView, index, title, title);
}

/// Hook setting page, add background keep alive switcher.
CHOptimizedMethod0(self, void, NewSettingViewController, reloadTableData) {
    CHSuper0(NewSettingViewController, reloadTableData);
    // Get the table info data.
    MMTableViewInfo *tableInfo = [(id)self valueForKeyPath:@"m_tableViewInfo"];
    
    // Create default section info.
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") performSelector:@selector(sectionInfoDefaut)];
    
    // Create the switch cell info.
    MMTableViewCellInfo *(*switchCellMethod)(id, SEL, SEL, id, NSString *, BOOL) = (MMTableViewCellInfo *(*)(id, SEL, SEL, id, NSString *, BOOL))objc_msgSend;
    MMTableViewCellInfo *switchCellInfo = switchCellMethod(objc_getClass("MMTableViewCellInfo"), @selector(switchCellForSel:target:title:on:), @selector(switchBackgroundKeepAlive), [KeepAliveManager sharedManager], @"后台运行", [JASettingConfig isKeepBackgroundAlive]);
    
    // Add the cell info data to section info data.
    [(id)sectionInfo performSelector:@selector(addCell:) withObject:switchCellInfo];
    
    // Add the section info to the table info.
    [(id)tableInfo performSelector:@selector(insertSection:At:) withObject:sectionInfo withObject:@0];

    // Reload data.
    MMTableView *tableView = [(id)tableInfo performSelector:@selector(getTableView)];
    [(id)tableView performSelector:@selector(reloadData)];
}


CHConstructor {
    CHLoadLateClass(MicroMessengerAppDelegate);
    CHLoadLateClass(NSDictionary);
    CHLoadLateClass(NewMainFrameViewController);
    CHLoadLateClass(NewSettingViewController);
    CHLoadLateClass(MFTitleView);
    
    
    CHHook2(MicroMessengerAppDelegate, application, didFinishLaunchingWithOptions);
    CHHook1(NSDictionary, objectForKey);
    CHHook2(MFTitleView, updateTitleView, title);
    CHHook0(NewSettingViewController, reloadTableData);
}


/*
CHDeclareClass(CustomViewController)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

//add new method
CHDeclareMethod1(void, CustomViewController, newMethod, NSString*, output){
    NSLog(@"This is a new method : %@", output);
}

#pragma clang diagnostic pop

CHOptimizedClassMethod0(self, void, CustomViewController, classMethod){
    NSLog(@"hook class method");
    CHSuper0(CustomViewController, classMethod);
}

CHOptimizedMethod0(self, NSString*, CustomViewController, getMyName){
    //get origin value
    NSString* originName = CHSuper(0, CustomViewController, getMyName);
    
    NSLog(@"origin name is:%@",originName);
    
    //get property
    NSString* password = CHIvar(self,_password,__strong NSString*);
    
    NSLog(@"password is %@",password);
    
    [self newMethod:@"output"];
    
    //set new property
    self.newProperty = @"newProperty";
    
    NSLog(@"newProperty : %@", self.newProperty);
    
    //change the value
    return @"AloneMonkey";
    
}

//add new property
CHPropertyRetainNonatomic(CustomViewController, NSString*, newProperty, setNewProperty);

CHConstructor{
    CHLoadLateClass(CustomViewController);
    CHClassHook0(CustomViewController, getMyName);
    CHClassHook0(CustomViewController, classMethod);
    
    CHHook0(CustomViewController, newProperty);
    CHHook1(CustomViewController, setNewProperty);
}
 */

