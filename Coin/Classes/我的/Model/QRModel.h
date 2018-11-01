//
//  QRModel.h
//  Coin
//
//  Created by shaojianfei on 2018/11/1.
//  Copyright © 2018年 chengdai. All rights reserved.
//

#import "TLBaseModel.h"

@interface QRModel : TLBaseModel
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *zfbQrUrl;

@end
