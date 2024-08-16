//
//  XMStateDefine.h
//  XWorld
//
//  Created by Tony Stark on 2020/7/15.
//  Copyright © 2020 xiongmaitech. All rights reserved.
//

#ifndef XMStateDefine_h
#define XMStateDefine_h

typedef NS_ENUM(NSUInteger, XM_REQ_STATE) {
    XM_REQ_NONE,
    XM_REQ_SUCCESS,
    XM_REQ_FAILED,
};

typedef void(^XMRESCALLBACK)(XM_REQ_STATE state,NSDictionary *info);

#endif /* XMStateDefine_h */

