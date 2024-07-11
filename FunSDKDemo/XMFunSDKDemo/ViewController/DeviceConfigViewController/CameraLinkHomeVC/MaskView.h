//
//  fheuhView.h
//   iCSee
//
//  Created by ctrl+c on 2023/4/6.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaskView : UIView{
    NSArray *rectsArray;
    UIColor *backgroundColor;
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor*)color andTransparentRects:(NSArray*)rects; 

@end
