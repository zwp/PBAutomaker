//
//  HXSystemServiceComponent.m
//  demo
//
//  Created by zwp on 2021/1/26.
//  Copyright © 2021年 XY. All rights reserved.
//

//⚠️ 该文件由脚本自动生成，请不要手动更改

#import "HXSystemServiceComponent.h"

@implementation HXSystemServiceComponent

ZYGSERVICE_COMPONENT_DECLARE(IHXSystemServiceComponent, ZYGServiceLoadType_OnNeed, 0)

-(instancetype)init{
    self = [super init];
    if ([self respondsToSelector:@selector(serviceModuleCustomMethod)]) {
        [self serviceModuleCustomMethod];
    }
    return self;
}

 -(void)fetchNotifyNotReadCount:(PB3FetchNotifyNotReadCountReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3FetchNotifyNotReadCountRes class] 
    serviceName:self.serviceModule 
    functionName:@"FetchNotifyNotReadCount" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)fetchNotify:(PB3FetchNotifyReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3FetchNotifyRes class] 
    serviceName:self.serviceModule 
    functionName:@"FetchNotify" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)notifyRead:(PB3NotifyReadReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3NotifyReadRes class] 
    serviceName:self.serviceModule 
    functionName:@"NotifyRead" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)fetchNotifyConcern:(PB3FetchNotifyConcernReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3FetchNotifyConcernRes class] 
    serviceName:self.serviceModule 
    functionName:@"FetchNotifyConcern" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)fetchSoFile:(PB3FetchSoFileReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3FetchSoFileRes class] 
    serviceName:self.serviceModule 
    functionName:@"FetchSoFile" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getSoFile:(PB3GetSoFileReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetSoFileRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetSoFile" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getUploadStat:(PB3GetUploadStatReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetUploadStatRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetUploadStat" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getGeneralSettingByKey:(PB3GetGeneralSettingByKeyReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetGeneralSettingByKeyRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetGeneralSettingByKey" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getWxSubConfig:(PB3GetWxSubConfigReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetWxSubConfigRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetWxSubConfig" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getUserRanked:(PB3GetRankedReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetUserRankedRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetUserRanked" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getGameRanked:(PB3GetRankedReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetGameRankedRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetGameRanked" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)informUser:(PB3InformUserReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3InformUserRes class] 
    serviceName:self.serviceModule 
    functionName:@"InformUser" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getWxConfig:(PB3GetWxConfigReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetWxConfigRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetWxConfig" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getWxOpenId:(PB3GetWxOpenIdReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetWxOpenIdRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetWxOpenId" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getCircleMsg:(PB3GetCircleMsgReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetCircleMsgRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetCircleMsg" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getPopUpConfig:(PB3GetPopUpConfigReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetPopUpConfigRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetPopUpConfig" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)sendSquareMessage:(PB3SendSquareMessageReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3SendSquareMessageRes class] 
    serviceName:self.serviceModule 
    functionName:@"SendSquareMessage" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getSquareImHistory:(PB3GetSquareImHistoryReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetSquareImHistoryRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetSquareImHistory" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp error:error info:info complete:complete];
    }];
}

#pragma mark - property

-(NSString *)serviceModule{
    if (!_serviceModule) {
        _serviceModule = [NSString serverNameForModule:@"system" service:@"SystemExtObj"];
    }
    return _serviceModule;
}

@end