//
//  FunSDKBaseView.m
//  FunSDKDemo
//
//  Created by feimy on 2024/6/26.
//  Copyright © 2024 feimy. All rights reserved.
//

#import "FunSDKBaseView.h"
#import "FunSDK/FunSDK.h"

@implementation FunSDKBaseView


-(instancetype)init{
    self = [super init];
    self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
    return self;
    
}

-(void)dealloc{
    
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
    
}

@end
