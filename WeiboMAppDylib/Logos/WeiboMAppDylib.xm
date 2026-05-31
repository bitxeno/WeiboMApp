// See http://iphonedevwiki.net/index.php/Logos

#import "ZXCodeFloor.h"
#import <UIKit/UIKit.h>

%ctor{
[ZXRequestBlock handleRequest:^NSURLRequest *(NSURLRequest *request) {
    return request;
} responseBlock:^NSData *(NSURLResponse *response, NSData *data) {
    //拦截响应数据
    //如果为http请求，则响应为NSHTTPURLResponse，可进行强制转换
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSURL *url = httpResponse.URL;
    
#ifdef DEBUG
    NSLog(@"拦截到请求url-%@", httpResponse.URL);
//    NSLog(@"拦截到响应数据-%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    printf("拦截到响应数据-\n%s\n", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] UTF8String]);
#endif
    
    // 开屏广告
    if ([url.path containsString:@"/v1/ad/preload"]) {
        NSError *jsonError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *jsonDict = [(NSDictionary *)jsonObject mutableCopy];
            NSArray *ads = jsonDict[@"ads"];
            if ([ads isKindOfClass:[NSArray class]] && ads.count > 0) {
                jsonDict[@"ads"] = @[];
                NSData *newData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
                if (newData != nil) {
#ifdef DEBUG
                    NSLog(@"已拦截广告接口: %@", httpResponse.URL);
#endif
                    return newData;
                }
            }
        } else {
#ifdef DEBUG
            NSLog(@"❌ 错误详情：%@", jsonError); // 完整错误堆栈
#endif
            NSString *jsonStr = @"{\"code\":200,\"background_interval\":5,\"last_ad_show_interval\":1800,\"realtime_api_timeout\":1000,\"realtime_video_stall_time\":300,\"ads\":[]}";
            NSData *newData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            if (newData != nil) {
    #ifdef DEBUG
                NSLog(@"已拦截广告接口: %@", httpResponse.URL);
    #endif
                return newData;
            }
        }
    }
    
    // 微博中插广告
    if ([url.path containsString:@"/2/ad/weibointl"]) {
        NSString *jsonStr = @"{\"data\": [],\"errno\": 0,\"error\": \"\"}";
        NSData *newData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        if (newData != nil) {
#ifdef DEBUG
            NSLog(@"已拦截广告接口: %@", httpResponse.URL);
#endif
            return newData;
        }
    }


    return data;
}];
}


// 
// 去掉注释可去除应用BundleId校验
// 替换“逆向App Bundle id”

//%hook NSBundle
//- (NSString *)bundleIdentifier{
//    NSString *str =  @"逆向App Bundle ID";
//    NSArray *address = [NSThread callStackReturnAddresses];
//    NSDictionary *dic = [[NSBundle mainBundle]infoDictionary];
//    [dic setValue:@"逆向App Bundle ID" forKey:@"CFBundleIdentifier"];
//    Dl_info info = {0};
//    if(dladdr((void *)[address[2] longLongValue], &info) == 0) return %orig;
//    NSString *path = [NSString stringWithUTF8String:info.dli_fname];
//    if ([path hasPrefix:NSBundle.mainBundle.bundlePath]) {
//            NSLog(@"!!!!!!!!!!!!!");
//            return str;
//    } else {
//        //  二进制是系统或者越狱插件
//            NSLog(@"!!!!!!系统!!!!!!");
//            return %orig;
//    }
//}
//%end
