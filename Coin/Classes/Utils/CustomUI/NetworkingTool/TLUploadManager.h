//
//  TLUploadManager.h
//  ZHBusiness
//
//  Created by  蔡卓越 on 2016/12/16.
//  Copyright © 2016年  caizhuoyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuSDK.h"
#import <UIKit/UIKit.h>

@interface TLUploadManager : NSObject

@property (nonatomic, strong) NSData *imgData;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *sec;

@property (nonatomic, copy) NSString *token;

+ (instancetype)manager;

+ (NSString *)imageNameByImage:(UIImage *)img;

- (void)getTokenShowView:(UIView *)showView succes:(void(^)(NSString * token))success
                 failure:(void(^)(NSError *error))failure;

-(void)initAliYun;

-(void)upLoadImageToAliYunWithData :(UIImage*)data succes:(void(^)(NSString * token))success
                            failure:(void(^)(NSError *error))failure;
- (UIImage *)downLoadImageWithToken :(NSString *)token;

@end
