//
//  OrderListItem.m
//   
//
//  Created by Tony Stark on 2022/3/4.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "OrderListItem.h"

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

@end
