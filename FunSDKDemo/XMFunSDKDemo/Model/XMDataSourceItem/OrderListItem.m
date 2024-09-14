//
//  OrderListItem.m
//   
//
//  Created by Tony Stark on 2022/3/4.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "OrderListItem.h"
#import <CoreServices/CoreServices.h>

@implementation OrderListItem

- (instancetype)init{
    self = [super init];
    if (self){
        self.titleName = @"";
        self.titleNameSelected = @"";
        self.subTitle = @"";
        self.leftIconName = @"";
        self.middleIconName = @"";
        self.middleIconNameSelected = @"";
    }
    
    return self;
}

// NSItemProviderWriting 协议方法
+ (NSArray<NSString *> *)writableTypeIdentifiersForItemProvider {
    return @[(NSString *)kUTTypePlainText];
}

- (NSProgress *)loadDataWithTypeIdentifier:(NSString *)typeIdentifier forItemProviderCompletionHandler:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionHandler {
    NSData *data = [NSData data];
    completionHandler(data, nil);
    return [NSProgress progressWithTotalUnitCount:100];
}

// NSItemProviderReading 协议方法
+ (NSArray<NSString *> *)readableTypeIdentifiersForItemProvider {
    return @[(NSString *)kUTTypePlainText];
}

+ (instancetype)objectWithItemProviderData:(NSData *)data typeIdentifier:(NSString *)typeIdentifier error:(NSError * _Nullable *)outError {
    NSString *title = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [[self alloc] init];
}

@end
