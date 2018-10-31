//
//  TLUploadManager.m
//  ZHBusiness
//
//  Created by  蔡卓越 on 2016/12/16.
//  Copyright © 2016年  caizhuoyue. All rights reserved.
//

#import "TLUploadManager.h"
#import "TLNetworking.h"
#import "TLUser.h"
#import "TLAlert.h"
#import "APICodeMacro.h"
#import <AliyunOSSiOS.h>
@interface TLUploadManager()
{
    OSSClient *_client;
}

@property (nonatomic,strong) QNUploadManager *qnUploadManager;


@end
NSString * const BUCKET_NAME = @"kkkotc";
NSString * const DOWNLOAD_OBJECT_KEY = @"object-key";
@implementation TLUploadManager

- (QNUploadManager *)qnUploadManager {

    if (!_qnUploadManager) {
        
        _qnUploadManager = [[QNUploadManager alloc] init];
    }
    
    return _qnUploadManager;

}

+ (instancetype)manager {

    static TLUploadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TLUploadManager alloc] init];
    });

    return manager;
}

-(UIImage *)downLoadImageWithToken:(NSString *)token
{
    
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    request.bucketName = BUCKET_NAME;
    request.objectKey = token;
    // 图片处理
    request.xOssProcess = @"image/resize,m_lfit,w_100,h_100";
    OSSTask * getTask = [_client getObject:request];
    [getTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"download image success!");
            OSSGetObjectResult * getResult = task.result;
            NSLog(@"download image data: %@", getResult.downloadedData);
            return [UIImage imageWithData:getResult.downloadedData];
        } else {
            NSLog(@"download object failed, error: %@" ,task.error);
            return nil;

        }
        return nil;
    }];
    return nil;

}
-(void)initAliYun
{
    
    NSString *endpoint = @"http://oss-cn-shenzhen.aliyuncs.com";
    
    // 由阿里云颁发的AccessKeyId/AccessKeySecret构造一个CredentialProvider。
    // 明文设置secret的方式建议只在测试时使用，更多鉴权模式请参考后面的访问控制章节。
    OSSStsTokenCredentialProvider *p = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:self.key secretKeyId:self.sec securityToken:self.token];
//    OSSPlainTextAKSKPairCredentialProvider *provider = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:@"STS.NHCqkbHmzfgqufGuR1EZMzAh1" secretKey:@"GeZynyywkxJnTgpCqeCvttN4XKs9ejA9jxx19fMWuULU"];
    [OSSLog enableLog];
    
    _client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:p];
}
-(void)upLoadImageToAliYunWithData:(UIImage *)data succes:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    NSData *imageData;
    if (UIImagePNGRepresentation(data)) {
        //返回为png图像。
        UIImage *imagenew = [self imageWithImageSimple:data scaledToSize:CGSizeMake(200, 200)];
        imageData = UIImagePNGRepresentation(imagenew);
    }else {
        //返回为JPEG图像。
        UIImage *imagenew = [self imageWithImageSimple:data scaledToSize:CGSizeMake(200, 200)];
        imageData = UIImageJPEGRepresentation(imagenew, 0.1);
    }
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = BUCKET_NAME;
    NSString *objectKeys = [NSString stringWithFormat:@"%@%@.jpg",[TLUser user].userId,[self getTimeNow]];
    put.uploadingData = imageData;
    
    put.objectKey = objectKeys;
    OSSTask * putTask = [_client putObject:put];
    
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        task = [_client presignPublicURLWithBucketName:BUCKET_NAME
                                         withObjectKey:objectKeys];
        NSLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {
            if (success) {
                
                success(objectKeys);
            }
            
            
            
        
            NSLog(@"upload object success!");
            
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
            if (failure) {
                failure;
            }
        }
        return nil;
    }];
    
}

- (UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)images:(NSArray *)images {
    
   

}

- (NSString *)getTimeNow
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddhhmmssSSS"];
    date = [formatter stringFromDate:[NSDate date]];
    //取出个随机数
    int last = arc4random() % 10000;
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@-%i", date,last];
    NSLog(@"%@", timeNow);
    return timeNow;
}
- (void)uploadImage:(UIImage *)image success:(void(^)(void))success failure:(void(^)())failure{

    TLNetworking *getUploadToken = [TLNetworking new];
    getUploadToken.code = IMG_UPLOAD_CODE;
    getUploadToken.parameters[@"token"] = [TLUser user].token;
    [getUploadToken postWithSuccess:^(id responseObject) {
     //获取token
        
        NSData *data = UIImageJPEGRepresentation(image, 1);
        NSString *imageName = [[self class] imageNameByImage:image];
        [self.qnUploadManager putData:data key:imageName token:@"" complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            
            if (1) {
                
                
                
            } else {
            
                if (failure) {
                    failure();
                }
            
            }
            
        } option:nil];
        
        
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure();
        }
        
    }];
    
}

- (void)getTokenShowView:(UIView *)showView succes:(void(^)(NSString * token))success
                 failure:(void(^)(NSError *error))failure
{

    TLNetworking *getUploadToken = [TLNetworking new];
    
    getUploadToken.showView = showView;
    getUploadToken.code = IMG_UPLOAD_CODE;
    getUploadToken.parameters[@"token"] = [TLUser user].token;
    [getUploadToken postWithSuccess:^(id responseObject) {
        
        NSString *token = responseObject[@"data"][@"uploadToken"];
        
        QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.zone = [QNZone zone0];
        }];
        
        QNUploadManager *manager = [[QNUploadManager alloc] initWithConfiguration:config];
        
        [manager putData:self.imgData key:[TLUploadManager imageNameByImage:self.image] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            
            if (info.error) {
                
                [TLAlert alertWithError:@"修改头像失败"];
                NSLog(@"info.error = %@", info.error);
                
                return ;
            }
            
            if (success) {
                
                success(key);
            }
            
        } option:nil];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];


}


+ (NSString *)imageNameByImage:(UIImage *)img{
    CGSize imgSize = img.size;//
    
    NSDate *now = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%f",now.timeIntervalSince1970];
    timestamp = [timestamp stringByReplacingOccurrencesOfString:@"." withString:@""];
 
    NSString *imageName = [NSString stringWithFormat:@"IOS_%@_%.0f_%.0f.jpg",timestamp,imgSize.width,imgSize.height];
    
    return imageName;
    
}


@end
