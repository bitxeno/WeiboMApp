//  github: https://github.com/AloneMonkey/MonkeyDev
//  github: https://github.com/kshipeng/MonkeyDev-Next
//
//  WeiboMAppDylib.h
//  WeiboMAppDylib
//
//  Created by cxf on 2026/4/27.
//  Copyright (c) 2026 ___ORGANIZATIONNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INSERT_SUCCESS_WELCOME "               🎉!!！congratulations!!！🎉\n👍----------------insert dylib success----------------👍\n"

@interface CustomViewController

@property (nonatomic, copy) NSString* newProperty;

+ (void)classMethod;

- (NSString*)getMyName;

- (void)newMethod:(NSString*) output;

@end

