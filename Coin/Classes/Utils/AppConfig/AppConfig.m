//
//  AppConfig.m
//  YS_iOS
//
//  Created by 蔡卓越 on 2017/5/11.
//  Copyright © 2017年 caizhuoyue. All rights reserved.
//

#import "AppConfig.h"

void TLLog(NSString *format, ...) {
    
    if ([AppConfig config].runEnv != RunEnvRelease) {
        
        va_list argptr;
        va_start(argptr, format);
        NSLogv(format, argptr);
        va_end(argptr);
    }
    
}

@implementation AppConfig

+ (instancetype)config {
    
    static dispatch_once_t onceToken;
    static AppConfig *config;
    dispatch_once(&onceToken, ^{
        
        config = [[AppConfig alloc] init];
        config.isUploadCheck = NO;
        
    });
    
    return config;
}

- (void)setRunEnv:(RunEnv)runEnv {
    
    _runEnv = runEnv;
    
    self.companyCode = @"CD-COIN000017";
    self.systemCode = @"CD-COIN000017";
    
    switch (_runEnv) {
            
        case RunEnvRelease: {
            self.qiniuDomain = @"http://image.bjdd.hichengdai.com";

            self.ossDomain = @"http://kkkotc.oss-cn-shenzhen.aliyuncs.com/";
//            self.addr = @"https://www.bcoin.im/api";
            self.addr = @"https://kkkotc.com/api";

        }break;
            
        case RunEnvDev: {
            //apidev.bcoin.im:4001
            self.ossDomain = @"http://kkkotc.oss-cn-shenzhen.aliyuncs.com/";
//            self.addr = @"178.128.208.125:5501";
            self.addr = @"https://loveotc.com/api";
//            self.addr = @"http://47.98.46.31:5501";
            self.qiniuDomain = @"http://image.bjdd.hichengdai.com";
        }break;
            
        case RunEnvTest: {
            self.qiniuDomain = @"http://image.bjdd.hichengdai.com";

            self.ossDomain = @"http://kkkotc.oss-cn-shenzhen.aliyuncs.com/";
            self.addr = @"https://kkkotc.com/api";

        } break;
            
    }
    
}

- (NSString *)apiUrl {
    
    if ([self.addr hasSuffix:@"api"]) {
        
        return self.addr;
        
    }
    
    return [self.addr stringByAppendingString:@"/forward-service/api"];
}

//- (NSString *)ipUrl {
//
//    return [self.addr stringByAppendingString:@"/forward-service/ip"];
//
//}

- (NSString *)getUrl {

    return [self.addr stringByAppendingString:@"/forward-service/api"];
}

- (NSString *)wxKey {
    
    return @"wx8cb7c18fa507f630";
}

@end
