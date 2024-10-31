//
//  MultileMediaplayerControl.m
//  FunSDKDemo
//
//  Created by zhang on 2024/10/24.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "MultileMediaplayerControl.h"

@implementation MultileMediaplayerControl

//MARK: 修改播放窗口模式和显示范围
- (void)updateWindowDisplayMode:(JF_Multiple_Eyes_Fake_Display_Mode)mode playWindowMode:(JFMultipleEyesPlayViewWindowMode)windowMode{
    //mainWindow
    if (self.windowNumber == 0) {
        FUN_MediaSetPlayViewAttr(self.player, (__bridge void*)self.renderWnd, [MultipleEyesManager playViewJsonParamWithDisplayMode:mode].UTF8String);
    }
    else{ //subWindow
        FUN_MediaAddPlayView(self.mainPlayer, (__bridge void*)self.renderWnd, [MultipleEyesManager playViewJsonParamWithDisplayMode:mode].UTF8String);
    }
    self.display_Mode = mode;
    self.playWindowMode = windowMode;
}
@end
