#line 1 "/Volumes/UsbDrive/Dev/WeiboMApp/WeiboMAppDylib/Logos/WeiboMAppDylib.xm"


#import "ZXCodeFloor.h"
#import <UIKit/UIKit.h>

static __attribute__((constructor)) void _logosLocalCtor_6abe01d2(int __unused argc, char __unused **argv, char __unused **envp){
[ZXRequestBlock handleRequest:^NSURLRequest *(NSURLRequest *request) {
    return request;
} responseBlock:^NSData *(NSURLResponse *response, NSData *data) {
    
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSURL *url = httpResponse.URL;
    
#ifdef DEBUG
    NSLog(@"拦截到请求url-%@", httpResponse.URL);
    NSLog(@"拦截到响应数据-%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

#endif
    
    
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
        }
    }
    
    
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

























