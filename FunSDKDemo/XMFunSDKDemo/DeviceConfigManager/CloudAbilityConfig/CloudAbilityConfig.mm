//
//  CloudAbilityConfig.m
//  FunSDKDemo
//
//  Created by XM on 2018/12/27.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "CloudAbilityConfig.h"
#import "CloudAbilityDataSource.h"
#import <CommonCrypto/CommonDigest.h>
@interface CloudAbilityConfig ()
{
    CloudAbilityDataSource *dataSource;
}

@property (nonatomic, assign) long long requestCount;
@end

@implementation CloudAbilityConfig
- (id)init {
    self = [super init];
    if (self) {
        self.requestCount = 0;
        dataSource = [[CloudAbilityDataSource alloc] init];
    }
    return self;
}

#pragma mark 请求服务器端云存储能力集
-(void)getCloudAbilityServer{
    //新接口
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    NSArray *caps = @[@"xmc.service"];
    NSDictionary *jsonDic = @{@"hw":@"",@"sw":@"",@"tp":@0,@"appType":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],@"sn":channel.deviceMac,@"caps":caps,@"ver":@2};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    Fun_SysGetDevCapabilitySet(self.msgHandle, [pCfgBufString UTF8String], 0);
    
}

- (void)getOEMInfo{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    // 先向服务器请求
    NSString *urlHead = @"https://rs.xmeye.net";
    NSString *timeMills = [self getRequestTimeMillis];
    NSString *strUrl = [NSString stringWithFormat:@"%@/api/queryDevice/v2/%@/%@.caps?sn=%@",urlHead,timeMills,[self getMD5EncryptSignatureTimeMills:timeMills],channel.deviceMac];
    NSURL *url = [NSURL URLWithString:strUrl];
    // 创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod =  @"GET";
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    // 发送请求
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data && error == nil) {
                // 解析JSON
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSDictionary *dicDevice = [dict objectForKey:@"device"];
                NSString *oemID = [dicDevice objectForKey:@"chipOemId"];
                NSString *numbermfrsOemId = [dicDevice objectForKey:@"mfrsOemId"];
                if (numbermfrsOemId && [numbermfrsOemId isKindOfClass:[NSString class]]) {
                    dataSource.OEMID = numbermfrsOemId;
                }
                if (oemID == nil || oemID.length == 0) {
                    [self getOEMFromDevice];
                }else{
                    dataSource.chipOemId = oemID;
                    if ([self.delegate respondsToSelector:@selector(getOEMIDResult:)]) {
                        [self.delegate getOEMIDResult:1];
                    }
                }
            }else{
                // 网络请求不支持 通过设备端接口再获取一遍
                [self getOEMFromDevice];
            }
        });
    }];
    //开始执行
    [dataTask resume];
}

//MARK: 获取OEMID信息 (从服务端未获取到时，可以从设备端获取。连接设备成功时，也可以直接从设备获取)
- (void)getOEMFromDevice{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    NSDictionary *dic = @{@"Name":@"EncyptChipInfo",@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    char cfg[1024];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 1020, "EncyptChipInfo", 4096, 10000,cfg, (int)strlen(cfg) + 1, -1, 0);
}


#pragma mark   读取云服务状态
- (NSString*)getCloudState {//获取云存储状态
    return  [dataSource getCloudString];
}
- (NSString*)getVideoEnable{ //获取云视频支持情况
    return  [dataSource getVideoString];
}
- (NSString*)getPicEnable{ //获取云图片支持情况
    return  [dataSource getPicString];
}

#pragma mark   读取设备其他信息
- (NSString*)getOEMID{ //获取设备OEMID
    return dataSource.OEMID;
}
- (NSString*)getICCID{ //获取设备流量卡ICCID
    
    if (dataSource.ICCID) {
        return dataSource.ICCID;
    }
    return @"";
}
- (NSString*)getIMEI{ //获取设备流量卡IMEI
    if (dataSource.IMEI) {
        return dataSource.IMEI;
    }
    return @"";
}
- (NSString*)getchipOemId{ //获取设备chipOemId
    return dataSource.chipOemId;
}


//  "xmc.css.pic.support"  云服务图片支持
//  "xmc.css.pic.enable"   云服务图片开通
//  "xmc.css.vid.support"  云服务录像支持
//  "xmc.css.vid.enable"   云服务录像开通
//  "xmc.css.vid.expirationtime"  云服务过期时间（通过时间戳计算云服务是否过期）
-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    switch (msg->id) {
        case EMSG_SYS_GET_DEV_CAPABILITY_SET: {
            if (msg->param1 < 0) {
                if (msg->seq == 0) {
                    dataSource.cloudState = CloudState_UnSupport;
                }
                if ([self.delegate respondsToSelector:@selector(getCloudAbilityResult:)]) {
                    [self.delegate getCloudAbilityResult:msg->param1];
                }
            } else {
                NSString *content = NSSTR(msg->szStr);
                [content stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                
                NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *tempDictQueryDiamond = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSDictionary *tempDictCaps = [tempDictQueryDiamond objectForKey:@"caps"];
                
                //录像和图片支持情况
                if ([tempDictCaps objectForKey:@"xmc.css.pic.support"] || [tempDictCaps objectForKey:@"xmc.css.vid.support"]) {
                    if ([[tempDictCaps objectForKey:@"xmc.css.pic.support"] boolValue]) {
                        if ([[tempDictCaps objectForKey:@"xmc.css.vid.support"] boolValue]) {
                            dataSource.VideoOrPicState = VideoOrPicCloudState_All;
                        }
                        else{
                            dataSource.VideoOrPicState = VideoOrPicCloudState_Pic;
                        }
                    }
                    else{
                        //录像支持情况
                        if ([[tempDictCaps objectForKey:@"xmc.css.vid.support"] boolValue]) {
                            dataSource.VideoOrPicState = VideoOrPicCloudState_Video;
                        }
                        else{
                            dataSource.VideoOrPicState = VideoOrPicCloudStateNone;
                        }
                    }
                    if ([self.delegate respondsToSelector:@selector(getVideoOrPicAbilityResult:)]) {
                        [self.delegate getVideoOrPicAbilityResult:msg->param1];
                    }
                }
                
                if ([tempDictCaps objectForKey:@"xmc.service.support"]) {
                    dataSource.cloudState = CloudState_UnSupport;
                    
                    if ([[tempDictCaps objectForKey:@"xmc.service.support"] boolValue] == YES) {
                        if ([[tempDictCaps objectForKey:@"xmc.css.vid.enable"] boolValue]) {
                            
                            //录像已开通时，可以认为录像和图片都已经开通（只支持云服务录像的除外）
                            dataSource.VideoOrPicState = VideoOrPicState_AllOpen;
                            
                            if ([[tempDictCaps objectForKey:@"xmc.service.normal"] boolValue]) {
                                dataSource.cloudState = CloudState_Open;
                                
                                //根据过期时间判断是否过期
                                BOOL result = NO;
                                if ([tempDictCaps objectForKey:@"xmc.css.vid.expirationtime"]) {
                                    NSInteger time = [[tempDictCaps objectForKey:@"xmc.css.vid.expirationtime"] integerValue];
                                    
                                    NSDate *date = [NSDate date];
                                    NSInteger curTime = [date timeIntervalSince1970];
                                    
                                    if (curTime >= time) { // 表示过期
                                        result = YES;
                                    }
                                }
                                
                                if (result) {
                                    dataSource.cloudState = CloudState_Open_Expired;
                                }
                            }
                            else{
                                dataSource.cloudState = CloudState_Open_Expired;
                            }
                        }
                        else{
                            dataSource.cloudState = CloudState_NotOpen;
                        }
                    }else{
                        
                    }
                }
                if ([[tempDictQueryDiamond allKeys] containsObject:@"mfrsOemId"]) {
                    NSString *oemid = [tempDictQueryDiamond objectForKey:@"mfrsOemId"];
                    dataSource.OEMID = oemid;
                }
                if ([[tempDictCaps allKeys] containsObject:@"net.cellular.iccid"]) {
                    NSString *iccid = [tempDictCaps objectForKey:@"net.cellular.iccid"];
                    dataSource.ICCID = iccid;
                }
                if ([[tempDictCaps allKeys] containsObject:@"net.cellular.imei"]) {
                    NSString *imei = [tempDictCaps objectForKey:@"net.cellular.imei"];
                    dataSource.IMEI = imei;
                }
                
                if ([self.delegate respondsToSelector:@selector(getCloudAbilityResult:)]) {
                    [self.delegate getCloudAbilityResult:msg->param1];
                }
            }
        }
            break;
        case EMSG_DEV_CMD_EN:
        {
            if (strcmp(msg->szStr, "EncyptChipInfo") == 0) {
                if (msg->param1 >= 0) {
                    if (msg->pObject == NULL) {
                        if ([self.delegate respondsToSelector:@selector(getOEMIDResult:)]) {
                            [self.delegate getOEMIDResult:-1];
                        }
                        return;
                    }
                    
                    NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    NSError *error;
                    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                    if(error){
                        if ([self.delegate respondsToSelector:@selector(getOEMIDResult:)]) {
                            [self.delegate getOEMIDResult:-1];
                        }
                        return;
                    }
                    
                    NSDictionary *dicEncyptChipInfo = [jsonDic objectForKey:@"EncyptChipInfo"];
                    NSString *numbermfrsOemId = [dicEncyptChipInfo objectForKey:@"mfrsOemId"];
                    if (numbermfrsOemId && [numbermfrsOemId isKindOfClass:[NSString class]]) {
                        dataSource.OEMID = numbermfrsOemId;
                    }
                    
                    if ([dicEncyptChipInfo objectForKey:@"OEMID"]) {
                        NSString *oemID = [dicEncyptChipInfo objectForKey:@"OEMID"];
                        dataSource.chipOemId = oemID;
                        if ([self.delegate respondsToSelector:@selector(getOEMIDResult:)]) {
                            [self.delegate getOEMIDResult:1];
                        }
                    }else{
                        if ([self.delegate respondsToSelector:@selector(getOEMIDResult:)]) {
                            [self.delegate getOEMIDResult:-1];
                        }
                    }
                }else{
                    if ([self.delegate respondsToSelector:@selector(getOEMIDResult:)]) {
                        [self.delegate getOEMIDResult:-1];
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}


//MARK:获取请求时间戳标记
- (NSString *)getRequestTimeMillis{
    return [[self getRequestCountStr] stringByAppendingString:[self getCurTimeStr]];
}

//MARK:获取请求次数字符串 防止并发
- (NSString *)getRequestCountStr{
    self.requestCount++;
    if (self.requestCount < 10) {
        return [NSString stringWithFormat:@"000000%lli",self.requestCount];
    }else if (self.requestCount < 100) {
        return [NSString stringWithFormat:@"00000%lli",self.requestCount];
    }else if (self.requestCount < 1000) {
        return [NSString stringWithFormat:@"0000%lli",self.requestCount];
    }else if (self.requestCount < 10000) {
        return [NSString stringWithFormat:@"000%lli",self.requestCount];
    }else if (self.requestCount < 100000) {
        return [NSString stringWithFormat:@"00%lli",self.requestCount];
    }else if (self.requestCount < 1000000) {
        return [NSString stringWithFormat:@"0%lli",self.requestCount];
    }else if (self.requestCount < 10000000) {
        return [NSString stringWithFormat:@"%lli",self.requestCount];
    }else{
        self.requestCount = 1;
        return [NSString stringWithFormat:@"000000%lli",self.requestCount];
    }
}


- (NSString *)getCurTimeStr{
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    
    long long millis = interval * 1000;
    return [NSString stringWithFormat:@"%lli",millis];
}

- (NSString *)getMD5EncryptSignatureTimeMills:(NSString *)timeMillis{
    NSString *content = [NSString stringWithFormat:@"%@%@%@%@",[NSString stringWithUTF8String:APPUUID],[NSString stringWithUTF8String:APPKEY],[NSString stringWithUTF8String:APPSECRET],timeMillis];

    //移位
    int moveCard = MOVECARD;
    NSData *dataChange = [content dataUsingEncoding:NSUTF8StringEncoding];
    Byte *changeByte = (Byte *)[dataChange bytes];
    Byte temp;
    for (int i = 0; i < [dataChange length]; i++) {
        temp = ((i % moveCard) > (([dataChange length] - i) % moveCard)) ? changeByte[i] : changeByte[[dataChange length] - (i + 1)];
        changeByte[i] = changeByte[[dataChange length] - (i + 1)];
        changeByte[[dataChange length] - (i + 1)] = temp;
    }
    
    //合并
    NSData *dataMerge = [content dataUsingEncoding:NSUTF8StringEncoding];
    Byte *mergeByte = (Byte *)[dataMerge bytes];
    int encryptLength = (int)[dataMerge length];
    int encryptLength2 = encryptLength * 2;
    Byte *mergeTemp = (Byte *)malloc(encryptLength2);
    
    for (int i = 0; i < [dataMerge length]; i++) {
        mergeTemp[i] = mergeByte[i];
        mergeTemp[encryptLength2 - 1 - i] = changeByte[i];
    }
    
    //byte数组 md5加密
    NSData *strdata = [[NSData alloc] initWithBytes:mergeTemp length:encryptLength2];
    NSString *valueStr = [[NSString alloc] initWithData:strdata encoding:NSUTF8StringEncoding];
    
    const char *value = [valueStr UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    free(mergeTemp);
    return outputString;
}
@end
