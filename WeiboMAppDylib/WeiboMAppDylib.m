//  github: https://github.com/AloneMonkey/MonkeyDev
//  github: https://github.com/kshipeng/MonkeyDev-Next
//
//  WeiboMAppDylib.m
//  WeiboMAppDylib
//
//  Created by cxf on 2026/4/27.
//  Copyright (c) 2026 ___ORGANIZATIONNAME___. All rights reserved.
//

#import "WeiboMAppDylib.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import <MDCycriptManager.h>
#import "ZXCodeFloor.h"

CHConstructor{
#ifdef DEBUG
    printf(INSERT_SUCCESS_WELCOME);
#endif
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
#ifdef DEBUG
        printf("🔍--------------------Debug Mode--------------------🔍\n");
        CYListenServer(6666);

        MDCycriptManager* manager = [MDCycriptManager sharedInstance];
        [manager loadCycript:NO];

        NSError* error;
        NSString* result = [manager evaluateCycript:@"UIApp" error:&error];
        NSLog(@"result: %@", result);
        if(error.code != 0){
            NSLog(@"error: %@", error.localizedDescription);
        }
#endif
        
        [ZXHookUtil showToast:@"NoAds Tweak"];
        
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
