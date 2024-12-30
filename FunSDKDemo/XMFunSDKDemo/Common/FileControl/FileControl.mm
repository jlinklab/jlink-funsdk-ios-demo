//
//  FileControl.m
//  FunSDKDemo
//
//  Created by XM on 2018/11/30.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "FileControl.h"

@implementation FileControl

- (NSMutableArray *)getLocalImage {
    NSString *path = [NSString getPhotoPath];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *imageList = [NSMutableArray arrayWithArray:array];
    if (!imageList) {
        return [NSMutableArray array];
    }
    for (int i =(int)imageList.count-1; i>=0; i--) {
        NSString *imagePath = [imageList objectAtIndex:i];
        if (![imagePath  containsString:@"jpg"]) {
            [imageList removeObjectAtIndex:i];
        }else{
            [imageList replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@/%@",path,imagePath]];
        }
    }
    return imageList;
}
- (NSMutableArray *)getLocalVideo {
    NSString *path = [NSString getVideoPath];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *videoList = [NSMutableArray arrayWithArray:array];
    if (!videoList) {
        return [NSMutableArray array];
    }
    for (int i =(int)videoList.count-1; i>=0; i--) {
        NSString *videoPath = [videoList objectAtIndex:i];
        if ((![videoPath  containsString:@"mp4"])  && (![videoPath  containsString:@"fvideo"])) {
            [videoList removeObjectAtIndex:i];
        }else{
            [videoList replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@/%@",path,videoPath]];
        }
    }
    return videoList;
}
//判断录像文件类型是不是H265
- (BOOL)getVideoTypeH265:(NSString*)path {
    int videoType = FUN_MediaGetCodecType([path UTF8String]); 
    if (videoType == 3) {
        return YES;
    }
    return NO;
}
//判断录像文件类型是不是鱼眼视频
- (BOOL)getVideoTypeFish:(NSString*)path {
    if ([path containsString:@".fvideo"]) {
        return YES;
    }
    return NO;
}
@end
