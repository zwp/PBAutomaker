//
//  HXVersionServiceComponent.m
//  demo
//
//  Created by zwp on 2021/1/26.
//  Copyright © 2021年 XY. All rights reserved.
//

//⚠️ 该文件由脚本自动生成，请不要手动更改

#import "HXVersionServiceComponent.h"

@implementation HXVersionServiceComponent

ZYGSERVICE_COMPONENT_DECLARE(IHXVersionServiceComponent, ZYGServiceLoadType_OnNeed, 0)

-(void)getLastVersion:(PB3GetLastVersionReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetLastVersionRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetLastVersion" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)installReport:(PB3InstallReportReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3InstallReportRes class] 
    serviceName:self.serviceModule 
    functionName:@"InstallReport" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getViewHideInfo:(PB3GetViewHideInfoReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetViewHideInfoRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetViewHideInfo" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getChannelStatus:(PB3GetChannelStatusReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetChannelStatusRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetChannelStatus" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

#pragma mark - property

-(NSString *)serviceModule{
    if (!_serviceModule) {
        _serviceModule = [NSString serverNameForModule:@"version" service:@"VersionExtObj"];
    }
    return _serviceModule;
}

@end