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
@interface AlipaiVC ()
@property (nonatomic, strong) TLTextField *contentTf;
//@property (nonatomic, strong) TLTextField *codeTf;
@property (nonatomic, strong) CaptchaView *captchaView;
@property (nonatomic, strong) TLImagePicker *imagePicker;

@property (nonatomic, strong) UIImageView *QRimageView;

@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, copy) NSString *key;

@end

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
            weakSelf.QRimageView.image = image;
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
    
    self.title = [LangSwitcher switchLang:@"支付宝收款" key:nil];
    [self setUpUI];
    self.view.backgroundColor = kWhiteColor;
    //
//    self.contentTf.text = [TLUser user].email;
    
}

- (void)setUpUI {
    
    [UIBarButtonItem addRightItemWithTitle:[LangSwitcher switchLang:@"完成" key:nil] titleColor:kTextColor frame:CGRectMake(0, 0, 40, 20) vc:self action:@selector(hasDone)];
    
    
    self.contentTf = [[TLTextField alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 45)
                                              leftTitle:[LangSwitcher switchLang:@"支付宝账号" key:nil]
                                             titleWidth:120
                                            placeholder:[LangSwitcher switchLang:@"请输入支付宝账号"    key:nil]];
    
    if ([TLUser user].zfbAccount) {
        self.contentTf.text = [TLUser user].zfbAccount;
    }
    self.contentTf.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:self.contentTf];
    
    
    UIImageView *QRimageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, self.contentTf.yy+20, 150, 150)];
    self.QRimageView = QRimageView;
    QRimageView.contentMode = UIViewContentModeScaleToFill;
    QRimageView.userInteractionEnabled = YES;
    [self.view addSubview:QRimageView];
    QRimageView.layer.cornerRadius = 5;
    QRimageView.layer.borderWidth = 0.5;
    QRimageView.layer.borderColor = kLineColor.CGColor;
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhoto)];
    [QRimageView addGestureRecognizer:tapGestureRecognizer1];
    //让UIImageView和它的父类开启用户交互属性
    [QRimageView setUserInteractionEnabled:YES];
    if ([TLUser user].zfbQr) {
        [QRimageView sd_setImageWithURL:[NSURL URLWithString:[[TLUser user].zfbQr convertImageUrl]]];
        
        
    }
    UILabel *introLab  = [UILabel labelWithTitle: [LangSwitcher switchLang:@"设置收款码" key:nil] frame:CGRectMake(0, self.contentTf.yy+10, 100, 30)];
    if ([TLUser user].zfbQr) {
        introLab.text = [LangSwitcher switchLang:@"设置收款码" key:nil];
    }
    [self.view addSubview:introLab];
    introLab.textColor = kTextColor;
    introLab.font = [UIFont systemFontOfSize:15];
    
    
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
//    TLNetworking *http = [TLNetworking new];
//
//    http.showView = self.view;
//    http.code = @"805097";
//    http.parameters[@"userId"] = [TLUser user].userId;
//    http.parameters[@"zfbAccount"] = self.contentTf.text;
//    http.parameters[@"zfbQr"] = key;
//    [http postWithSuccess:^(id responseObject) {
    
        [TLAlert alertWithSucces:[LangSwitcher switchLang:@"上传成功" key:nil]];
//    self.addButton.hidden = YES;

    
}

- (void)takePhoto
{
    //拍照 或选择相册
   [self.imagePicker picker];
    
}

#pragma mark- 发送验证码
- (void)sendCaptcha {
    
    if (![self.contentTf.text valid]) {
        
        [TLAlert alertWithInfo:[LangSwitcher switchLang:@"请输入支付宝账号" key:nil]];
        return;
    }
    
    
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
    
    NSString *content = self.contentTf.text;
    
    
    if (![content valid]) {
        
        [TLAlert alertWithInfo:[LangSwitcher switchLang:@"请输入支付宝账号" key:nil]];
        return;
    }
    
    if (![self.key valid] && ![TLUser user].zfbQr) {
        
        [TLAlert alertWithInfo:[LangSwitcher switchLang:@"请上传收款二维码" key:nil]];
        return;
    }
    
        TLNetworking *http = [TLNetworking new];
    
        http.showView = self.view;
        http.code = @"805097";
        http.parameters[@"userId"] = [TLUser user].userId;
        http.parameters[@"zfbAccount"] = self.contentTf.text;
        if (![self.key valid]) {
            http.parameters[@"zfbQr"] =[TLUser user].zfbQr;

        }else{
            http.parameters[@"zfbQr"] =self.key;

        }
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
