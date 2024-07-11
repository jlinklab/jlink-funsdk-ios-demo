//
//  PTZCorrectionViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2024/7/4.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "PTZCorrectionViewController.h"
#import "FunSDK/FunSDK.h"
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"


@interface PTZCorrectionViewController ()
@property (weak, nonatomic) IBOutlet UIButton *ptzCorrectionButton;
@property (weak, nonatomic) IBOutlet UILabel *ptzLabel;

@property (nonatomic,assign) int msgHandle;

@end

@implementation PTZCorrectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ptzCorrectionButton setTitle:TS("PTZ_Correction") forState:UIControlStateNormal];
    
    self.ptzLabel.text = TS("PTZ_Correction_Tips");
    
    self.msgHandle = FUN_RegWnd((__bridge void*)self);
}

//云台校正
- (IBAction)startPtzCorrection:(id)sender {
    [SVProgressHUD show];
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    NSString *cfgName = @"OPPtzAutoAdjust";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 1450, cfgName.UTF8String, -1, 60000,cfg, (int)strlen(cfg) + 1, -1, 102);
}


-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            int result = msg->param1;
            if (result >= 0) {
                //success
                [SVProgressHUD dismissWithSuccess:TS("Success")];
            }else{
                //error
                [MessageUI ShowErrorInt:(int)result];
            }
        }
            break;
        default:
            break;
    }
}



@end
