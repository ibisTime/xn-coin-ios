//
//  AlipaiVC.m
//  Coin
//
//  Created by shaojianfei on 2018/10/30.
//  Copyright © 2018年  tianlei. All rights reserved.
//

#import "AlipaiVC.h"
#import "CoinHeader.h"

#import "TLTextField.h"

#import "NSString+Check.h"
#import "UIBarButtonItem+convience.h"
#import "CaptchaView.h"
//#import "TLCaptchaView.h"
#import "CaptchaView.h"
#import "TLImagePicker.h"
#import "TLUploadManager.h"
#import <UIImageView+WebCache.h>
#import "XWScanImage.h"
#import <MJExtension.h>
#import "QRModel.h"
@interface AlipaiVC ()
@property (nonatomic, strong) TLTextField *contentTf;
//@property (nonatomic, strong) TLTextField *codeTf;
@property (nonatomic, strong) CaptchaView *captchaView;
@property (nonatomic, strong) TLImagePicker *imagePicker;

@property (nonatomic, strong) UIImageView *QRimageView;

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSMutableArray *moneyArrays;

@property (nonatomic, strong) NSMutableArray *qrLists;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) NSInteger currentTag;
@property (nonatomic, copy) NSString *money;

@end
#define Start_X          10.0f      // 第一个按钮的X坐标
#define Start_Y          50.0f     // 第一个按钮的Y坐标
#define Width_Space      5.0f      // 2个按钮之间的横间距
#define Height_Space     20.0f     // 竖间距
#define Button_Height   90.0f    // 高
#define Button_Width    90.0f    // 宽


@implementation AlipaiVC



- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
//    [self.contentTf becomeFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.contentTf resignFirstResponder];
}
-(TLImagePicker *)imagePicker {
    
    if (!_imagePicker) {
        
        CoinWeakSelf;
        
        _imagePicker = [[TLImagePicker alloc] initWithVC:self];
        
        _imagePicker.allowsEditing = YES;
        _imagePicker.pickFinish = ^(NSDictionary *info){
            
            UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
            NSData *imgData = UIImageJPEGRepresentation(image, 0.1);
            UIImageView *imageView = [weakSelf.view viewWithTag:weakSelf.currentTag];
            
            imageView.image = image;
            //进行上传
            TLUploadManager *manager = [TLUploadManager manager];
            
            manager.imgData = imgData;
            manager.image = image;
            [manager upLoadImageToAliYunWithData:image succes:^(NSString *token) {

                [weakSelf changeHeadIconWithKey:token imgData:imgData];

            } failure:^(NSError *error) {
                
            }];
           
        };
    }
    
    return _imagePicker;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.moneyArrays = [NSMutableArray array];
    self.title = [LangSwitcher switchLang:@"支付宝收款码" key:nil];
    [self setUpUI];
    [self loadQrCode];
    self.view.backgroundColor = kWhiteColor;
    //
//    self.contentTf.text = [TLUser user].email;
    
}

- (void)loadQrCode
{

    TLNetworking *http = [TLNetworking new];
    
    http.showView = self.view;
    http.code = @"805970";
    http.parameters[@"userId"] = [TLUser user].userId;
    
    [http postWithSuccess:^(id responseObject) {
        self.qrLists = [QRModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"zfbQrList"]];
        NSLog(@"%@", self.qrLists);
        [self setQrImage];
    } failure:^(NSError *error) {
        
    }];

}

- (void)setQrImage
{
    
    for (int i = 0; i <self.qrLists.count; i++) {
        QRModel *qr = self.qrLists[i];
        UIImageView *image = [self.view viewWithTag:1000+i];
        
        if (qr.zfbQrUrl.length > 0) {
            [image sd_setImageWithURL:[NSURL URLWithString:[qr.zfbQrUrl convertImageUrl]]];
        }
    }
    
}
- (void)setUpUI {
    
//    [UIBarButtonItem addRightItemWithTitle:[LangSwitcher switchLang:@"完成" key:nil] titleColor:kTextColor frame:CGRectMake(0, 0, 40, 20) vc:self action:@selector(hasDone)];
//    
    
//    self.contentTf = [[TLTextField alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 45)
//                                              leftTitle:[LangSwitcher switchLang:@"支付宝账号" key:nil]
//                                             titleWidth:120
//                                            placeholder:[LangSwitcher switchLang:@"请输入支付宝账号"    key:nil]];
//
//    if ([TLUser user].zfbAccount) {
//        self.contentTf.text = [TLUser user].zfbAccount;
//    }
//    self.contentTf.keyboardType = UIKeyboardTypeEmailAddress;
//    [self.view addSubview:self.contentTf];
    
    for (int i = 0 ; i < 12; i++) {
        NSInteger index = i % 3;
        NSInteger page = i / 3;
        //按钮点击方法
        CGFloat btnw = (kScreenWidth-80)/3;
        CGFloat marge = 20;
        CGFloat hmarge = 30;

        CGFloat height = 105;

        UIImageView *QRimageView = [[UIImageView alloc] initWithFrame:CGRectMake(index * (btnw + marge)+marge, page  * (height + hmarge)+Start_Y, btnw, height)];
        
        UILabel *lab = [UILabel labelWithBackgroundColor:kClearColor textColor:kTextColor font:14];
        lab.tag = i+100;
        lab.frame = CGRectMake(index * (btnw + marge)+marge, page  * (height + hmarge)+Start_Y+height, btnw, 22);
        [self.view addSubview:lab];
        self.QRimageView = QRimageView;
        QRimageView.tag = i+1000;
        QRimageView.layer.cornerRadius = 5;
        QRimageView.clipsToBounds = YES;
        
        QRimageView.contentMode = UIViewContentModeScaleToFill;
        QRimageView.userInteractionEnabled = YES;
        [self.view addSubview:QRimageView];
        QRimageView.image = kImage(@"default_pic(1)");
        
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhoto:)];
        [QRimageView addGestureRecognizer:tapGestureRecognizer1];
        
        switch (i) {
            case 0:
                lab.text = @"默认收款码";

                break;
            case 1:
                lab.text = @"100元";
                
                break;
            case 2:
                lab.text = @"200元";
                
                break;
            case 3:
                lab.text = @"300元";
                
                break;
            case 4:
                lab.text = @"400元";
                
                break;
            case 5:
                lab.text = @"500元";
                
                break;
            case 6:
                lab.text = @"1000元";
                
                break;
            case 7:
                lab.text = @"2000元";
                
                break;
            case 8:
                lab.text = @"5000元";
                
                break;
            case 9:
                lab.text = @"10000元";
                
                break;
            case 10:
                lab.text = @"20000元";
                
                break;
            case 11:
                lab.text = @"50000元";
                
                break;
                
            default:
                break;
        }
        //让UIImageView和它的父类开启用户交互属性
        [QRimageView setUserInteractionEnabled:YES];
//        if ([TLUser user].zfbQr) {
//            [QRimageView sd_setImageWithURL:[NSURL URLWithString:[[TLUser user].zfbQr convertImageUrl]]];
//
//
//        }
    }
    

    
//    UILabel *introLab  = [UILabel labelWithTitle: [LangSwitcher switchLang:@"设置收款码" key:nil] frame:CGRectMake(0, self.contentTf.yy+10, 100, 30)];
//    if ([TLUser user].zfbQr) {
//        introLab.text = [LangSwitcher switchLang:@"设置收款码" key:nil];
//    }
//    [self.view addSubview:introLab];
//    introLab.textColor = kTextColor;
//    introLab.font = [UIFont systemFontOfSize:15];
    
    
//    UIButton *addButton = [UIButton buttonWithTitle:@"" titleColor:kTextColor backgroundColor:kClearColor titleFont:13];
//    self.addButton = addButton;
//    addButton.frame = CGRectMake(30, self.contentTf.yy+80, 40, 40);
//    [addButton setBackgroundImage:kImage(@"添加") forState:UIControlStateNormal];
//    [self.view addSubview:addButton];
//
//    [addButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    

    //
//    self.captchaView = [[CaptchaView alloc] initWithFrame:CGRectMake(0, self.contentTf.yy + 0.7, kScreenWidth, 45) leftTitleWidth:80];
//    [self.view addSubview:self.captchaView];
    
    //    self.codeTf = [[TLTextField alloc] initWithFrame:CGRectMake(0, self.contentTf.yy, kScreenWidth, 45)
    //                                           leftTitle:[LangSwitcher switchLang:@"验证码" key:nil]
    //                                          titleWidth:80
    //                                         placeholder:[LangSwitcher switchLang:@"请输入验证码"    key:nil]];
    //    self.codeTf.keyboardType = UIKeyboardTypeNumberPad;
    //    [self.view addSubview:self.codeTf];
    
    
    
}
// - 浏览大图点击事件
-(void)scanBigImageClick1:(UITapGestureRecognizer *)tap{
    NSLog(@"点击图片");
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    [XWScanImage scanBigImageWithImageView:clickedImageView];
}

- (void)changeHeadIconWithKey:(NSString *)key imgData:(NSData *)imgData {
    
    self.key = key;
    TLNetworking *http = [TLNetworking new];

    http.showView = self.view;
    http.code = @"805097";
    if (self.currentTag == 1000) {
        http.parameters[@"userId"] = [TLUser user].userId;
        http.parameters[@"zfbQr"] = key;
        http.parameters[@"zfbQr"] = key;
        http.parameters[@"zfbAccount"] = @"支付宝";

        
    }else if (self.currentTag == 1001 || self.currentTag == 1002)
    {
        http.parameters[@"userId"] = [TLUser user].userId;
        http.parameters[@"zfbQr"] = key;
        http.parameters[@"amount"] = self.money;

    }else{
        http.parameters[@"userId"] = [TLUser user].userId;
        http.parameters[@"zfbQr"] = key;
        http.parameters[@"amount"] = self.money;


    }
   

    [http postWithSuccess:^(id responseObject) {
        [TLAlert alertWithSucces:[LangSwitcher switchLang:@"上传成功" key:nil]];
        [self.moneyArrays addObject:key];
    } failure:^(NSError *error) {
        
    }];

    
}

- (void)takePhoto:(UITapGestureRecognizer*)sender
{
    self.currentTag = sender.view.tag;
    switch ( self.currentTag) {
        case 1000:
            self.money = @"默认收款码";
            
            break;
        case 1001:
            self.money = @"100";
            
            break;
        case 1002:
            self.money = @"200";
            
            break;
        case 1003:
            self.money = @"300";
            
            break;
        case 1004:
           self.money = @"400";
            
            break;
        case 1005:
            self.money = @"500";
            
            break;
        case 1006:
            self.money = @"1000";
            
            break;
        case 1007:
            self.money = @"2000";
            
            break;
        case 1008:
           self.money = @"5000";
            
            break;
        case 1009:
           self.money = @"10000";
            
            break;
        case 1010:
            self.money = @"20000";
            
            break;
        case 1011:
            self.money = @"50000";
            
            break;
            
        default:
            break;
    }
    //拍照 或选择相册
   [self.imagePicker picker];
    
}

- (void)sendCaptcha {
    
    
    
    
    TLNetworking *http = [TLNetworking new];
    http.showView = self.view;
    http.code = @"805952";
    //    http.parameters[@"companyCode"] = @"";
    http.parameters[@"email"] = self.contentTf.text;
    http.parameters[@"bizType"] = @"805081";
    //    http.parameters[@"systemCode"] = [];
    
    [http postWithSuccess:^(id responseObject) {
        //
        [self.captchaView.captchaBtn begin];
        
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)hasDone {
    
   
    
    if (![self.money valid]) {
        
        [TLAlert alertWithInfo:[LangSwitcher switchLang:@"请上传收款二维码" key:nil]];
        return;
    }
    if (self.moneyArrays.count == 0) {
        [TLAlert alertWithInfo:[LangSwitcher switchLang:@"请上传收款二维码" key:nil]];

        return;

    }
    
        TLNetworking *http = [TLNetworking new];
    
        http.showView = self.view;
        http.code = @"805097";
        http.parameters[@"userId"] = [TLUser user].userId;
    
        http.parameters[@"zfbQr"] =self.key;

        [http postWithSuccess:^(id responseObject) {
        
        [TLAlert alertWithSucces:[LangSwitcher switchLang:@"上传二维码成功" key:nil]];
        
        [self.navigationController popViewControllerAnimated:YES];
//        if (self.done) {
//            self.done(content);
//        }
        
    } failure:^(NSError *error) {
        
        
    }];
    
    
    
}


@end
