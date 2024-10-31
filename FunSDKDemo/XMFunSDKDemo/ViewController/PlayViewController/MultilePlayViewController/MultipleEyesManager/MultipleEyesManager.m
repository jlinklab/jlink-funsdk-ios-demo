//
//  MultipleEyesManager.m
//  FunSDKDemo
//
//  Created by zhang on 2024/10/25.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "MultipleEyesManager.h"

@implementation MultipleEyesManager

/**
 @brief 获取窗口显示模式对应的json数据 具体裁剪范围可以根据业务设计自行调整
 */
+ (NSString *)playViewJsonParamWithDisplayMode:(JF_Multiple_Eyes_Fake_Display_Mode)mode {
    /**
     static const GLfloat coordVertices[] = {
         0.0f, 1.0f,  // 左上
         1.0f, 1.0f,  // 右上
         0.0f,  0.0f, // 左下
         1.0f,  0.0f, // 右下
     };
     注意：纹理坐标系统可能是从顶部到底部的
     */
    //默认模式 显示全部
    NSDictionary *dicJson = @{@"play_view":@{@"render_enable":[NSNumber numberWithBool:true],
                                             @"coord_vertices":@{@"left":[NSNumber numberWithFloat:0],
                                                                 @"right":[NSNumber numberWithFloat:1],
                                                                 @"top":[NSNumber numberWithFloat:1],
                                                                 @"bottom":[NSNumber numberWithFloat:0]}}};
    if (mode == JF_MEFD_Original_Mode) {
        
    }else if (mode == JF_MEFD_Top_Half_Mode) {
        dicJson = @{@"play_view":@{@"render_enable":[NSNumber numberWithBool:true],
                                   @"coord_vertices":@{@"left":[NSNumber numberWithFloat:0],
                                                     @"right":[NSNumber numberWithFloat:1],
                                                     @"top":[NSNumber numberWithFloat:0.5],
                                                     @"bottom":[NSNumber numberWithFloat:0]}}};
    }else if (mode == JF_MEFD_Bottom_Half_Mode) {
        dicJson = @{@"play_view":@{@"render_enable":[NSNumber numberWithBool:true],
                                   @"coord_vertices":@{@"left":[NSNumber numberWithFloat:0],
                                                     @"right":[NSNumber numberWithFloat:1],
                                                     @"top":[NSNumber numberWithFloat:1],
                                                     @"bottom":[NSNumber numberWithFloat:0.5]}}};
    }else if (mode == JF_MEFD_Top_Left_Middel_Mode) {//上半部分 左侧往右2/3 高度2/3
        dicJson = @{@"play_view":@{@"render_enable":[NSNumber numberWithBool:true],
                                   @"coord_vertices":@{@"left":[NSNumber numberWithFloat:0],
                                                         @"right":[NSNumber numberWithFloat:2/3.0],
                                                         @"top":[NSNumber numberWithFloat:0.5 * (2 / 3.0 + 1 / 6.0)],
                                                         @"bottom":[NSNumber numberWithFloat:0.5 * (1 / 6.0)]}}};
    }else if (mode == JF_MEFD_Top_Right_Middel_Mode) {//上半部分 右侧侧往左2/3 高度2/3
        dicJson = @{@"play_view":@{@"render_enable":[NSNumber numberWithBool:true],
                                   @"coord_vertices":@{@"left":[NSNumber numberWithFloat:1 / 3.0],
                                                     @"right":[NSNumber numberWithFloat:1],
                                                     @"top":[NSNumber numberWithFloat:0.5 * (2 / 3.0 + 1 / 6.0)],
                                                     @"bottom":[NSNumber numberWithFloat:0.5 * (1 / 6.0)]}}};
    }
    
    NSString *jsonStr = [MultipleEyesManager convertToJSONData:dicJson];
    
    return jsonStr;
}


//MARK:字典转字符串
+(NSString*)convertToJSONData:(id)infoDict
{
    if (!infoDict) {
        return @"";
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}
@end
