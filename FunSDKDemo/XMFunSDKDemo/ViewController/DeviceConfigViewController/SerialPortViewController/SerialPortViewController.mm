//
//  SerialPortViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2024/6/20.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "SerialPortViewController.h"
#import "SerialPortManager.h"

@interface SerialPortViewController () <SerialPortManagerDelegate>
{
    SerialPortManager *_manager;
}
@property (weak, nonatomic) IBOutlet UIButton *openButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UITextField *SerialTypeTf;
@property (weak, nonatomic) IBOutlet UITextField *SerialDataTf;
@property (weak, nonatomic) IBOutlet UIButton *SendDataButton;

@property (weak, nonatomic) IBOutlet UITextView *callbackView;

@property (weak, nonatomic) IBOutlet UITextView *descriptionView;


@end

@implementation SerialPortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
}

- (IBAction)StartEvent:(id)sender {
    [SVProgressHUD show];
    
    int serialType = [self.SerialTypeTf.text intValue];
    if (serialType != 0 && serialType != 1) {
        //串口类型目前只有0和1,以后不确定会不会新增
        [MessageUI ShowError:TS("Please confirm if the serial port type is correct")];
        return;
    }
    [self.manager open:serialType];
}
- (IBAction)closeEvent:(id)sender {
    [SVProgressHUD show];
    
    [self.manager close];
}
- (IBAction)sendData:(id)sender {
    [SVProgressHUD show];
    
    NSString *dataString = self.SerialDataTf.text;
    [self.manager send:dataString seq:1];
}


#pragma mark - 接口回调 callback
- (void)openSerialResult:(NSInteger)result{
    if (result < 0) {
        [MessageUI ShowErrorInt:result];
    }else{
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }
}
-(void)closeSerialResult:(NSInteger)result{
    if (result < 0) {
        [MessageUI ShowErrorInt:result];
    }else{
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }
}
-(void)sendSerialDataResult:(NSInteger)result{
    if (result < 0) {
        [MessageUI ShowErrorInt:result];
    }else{
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }
}

- (void)deviceBackSerialDataResult:(NSInteger)result {
    NSString *data = [self.manager readData];
    self.callbackView.text = data;
}

#pragma mark - 界面和数据初始化 init
- (void)initDataSource {
    [self.openButton setTitle:TS("Open serial port") forState:UIControlStateNormal];
    [self.closeButton setTitle:TS("Close serial port") forState:UIControlStateNormal];
    [self.SendDataButton setTitle:TS("Send data") forState:UIControlStateNormal];
    
    self.SerialTypeTf.placeholder = TS("Input serial port type");
    self.SerialDataTf.placeholder = TS("Input serial port data");
    
    self.descriptionView.text = TS("serial port Description");
}

- (SerialPortManager*)manager{
    if (!_manager) {
        _manager = [[SerialPortManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}
@end
