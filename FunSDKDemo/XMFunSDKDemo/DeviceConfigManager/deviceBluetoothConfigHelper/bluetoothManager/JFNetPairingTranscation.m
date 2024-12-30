//
//  JFNetPairingTranscation.m
//   iCSee
//
//  Created by Megatron on 2024/10/18.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFNetPairingTranscation.h"

@implementation JFNetPairingTranscation

- (instancetype)initWithType:(JFNetPairingType)type result:(NSString *)result {
    self = [super init];
    if (self) {
        self.passwordErrorNeedRestart = YES;
        self.netPairingType = type;
        self.result = result;
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.passwordErrorNeedRestart = YES;
    }
    
    return self;
}

@end
