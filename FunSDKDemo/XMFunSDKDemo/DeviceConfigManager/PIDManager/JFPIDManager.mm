//
//  JFPIDManager.m
//  FunSDKDemo
//
//  Created by zhang on 2024/10/18.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "JFPIDManager.h"
#import "LoginShowControl.h"
#import "DeviceControl.h"

@interface JFPIDManager ()
{
    DeviceObject *device;
}
@end
@implementation JFPIDManager

- (void)requestPropvalue:(id)object {
    
    
    device = object;
    //1.初始化Session
    NSURLSession *session = [NSURLSession sharedSession];
    //2、初始化URL
    NSURL *url = [NSURL URLWithString:kGetDeviceTypePropUrl];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = kPOST;
    //5.设置请求体
    NSDictionary * bodyDic = @{@"pid": device.sPid  ? device.sPid  : @"",@"page":@(0), @"limit":@(99)};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonData];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    [request setValue:@"zh_CN" forHTTPHeaderField:@"Accept-Language"];
    
    NSString *token = [[LoginShowControl getInstance] getLoginToken];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                NSLog(@"get_propValue_data_nil");
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dict == nil) {
                NSLog(@"get_propValue_dict_nil");
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                NSDictionary *dicPropCode = [self propCodeDictionaryFromInfo:JFSafeDictionary(dict, @"data")];
                
                
                //备注说明只有支持PID的设备才有pid属性，pid属性说明设备支持的功能
                if ([dicPropCode.allKeys containsObject:@"aovFunc"] ) {
                   //AOV设备
                    device.sysFunction.AovMode = YES;
                }
                if ([dicPropCode.allKeys containsObject:@"threeScreen"] ) {
                   //支持APP裁剪3画面分屏
                    NSDictionary *dicThreeScreen = JFSafeDictionary(dicPropCode, @"threeScreen");
                    NSString *usedValue = JFSafeDictionary(JFSafeDictionary(dicThreeScreen, @"propValue"), @"usedValue");
                    if (usedValue != @"none") {
                        device.threeScreen = usedValue;
                    }
                }
                if ([dicPropCode.allKeys containsObject:@"digitalZoom"] ) {
                   //APP数字变倍效果
                    NSDictionary *dicDigitalZoom = JFSafeDictionary(dicPropCode, @"digitalZoom");
                    NSString *usedValue = JFSafeDictionary(JFSafeDictionary(dicDigitalZoom, @"propValue"), @"usedValue");
                    if ([usedValue isKindOfClass:[NSString class]]) {
                        NSArray *array = JFForceArray([usedValue componentsSeparatedByString:@"+"]);
                        if (array.count > 1) {
                            int realNum = [[array objectAtIndex:0] intValue];
                            int displayNum = [[array objectAtIndex:1] intValue];
                            device.iSupportAPPZoomScreen = 1;
                            device.iAPPZoomScreenMaxNum = realNum;
                            device.iAPPZoomScreenMaxDisplayNum = displayNum;
                        }
                    }
                }
                if ([dicPropCode.allKeys containsObject:@"batteryPower"] ) {
                   //设备电池电量
                }
                if ([dicPropCode.allKeys containsObject:@"sleepState"] ) {
                   //说明设备支持休眠状态
                }
                [[DeviceControl getInstance] saveDeviceList];
                
            }else{
                NSLog(@"get_propValue_data_unSuccess");
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}

///将获取到的列表数据转换成字典 方便快速通过propCode读取
- (NSMutableDictionary *)propCodeDictionaryFromInfo:(NSDictionary *)dicInfo{
    NSMutableDictionary *dicPropCode = [[NSMutableDictionary alloc] initWithCapacity:0];
    int total = [JFSafeDictionary(dicInfo, @"total") intValue];
    if (total > 0) {
        NSArray *list = JFForceArray(JFSafeDictionary(dicInfo, @"data"));
        for (int i = 0; i < list.count; i++) {
            NSDictionary *dicProp = JFForceDictionary([list objectAtIndex:i]);
            NSString *propCode = JFSafeDictionary(dicProp, @"propCode");
            if (propCode) {
                [dicPropCode setObject:dicProp forKey:propCode];
            }
        }
    }
    
    return dicPropCode;
}
@end
