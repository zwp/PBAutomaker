//
//  IHXVersionServiceComponent.h
//  demo
//
//  Created by zwp on 2020/12/24.
//  Copyright © 2020年 XYWL. All rights reserved.
//

//⚠️ 该文件由脚本自动生成，请不要手动更改

#import "HXNetwork.h"
#import "VersionExt.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IHXVersionServiceComponent <NSObject>

-(void)getLastVersion:(PB3GetLastVersionReq *)req complete:(CompleteHandler)complete;

-(void)installReport:(PB3InstallReportReq *)req complete:(CompleteHandler)complete;

-(void)getViewHideInfo:(PB3GetViewHideInfoReq *)req complete:(CompleteHandler)complete;

@end

NS_ASSUME_NONNULL_END

