//
//  IHXSystemServiceComponent.h
//  demo
//
//  Created by zwp on 2021/1/26.
//  Copyright © 2021年 XY. All rights reserved.
//

//⚠️ 该文件由脚本自动生成，请不要手动更改

#import "SystemExt.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IHXSystemServiceComponent <IHXServiceModule>

-(void)fetchNotifyNotReadCount:(PB3FetchNotifyNotReadCountReq *)req complete:(CompleteHandler)complete;

-(void)fetchNotify:(PB3FetchNotifyReq *)req complete:(CompleteHandler)complete;

-(void)notifyRead:(PB3NotifyReadReq *)req complete:(CompleteHandler)complete;

-(void)fetchNotifyConcern:(PB3FetchNotifyConcernReq *)req complete:(CompleteHandler)complete;

-(void)fetchSoFile:(PB3FetchSoFileReq *)req complete:(CompleteHandler)complete;

-(void)getSoFile:(PB3GetSoFileReq *)req complete:(CompleteHandler)complete;

-(void)getUploadStat:(PB3GetUploadStatReq *)req complete:(CompleteHandler)complete;

-(void)getGeneralSettingByKey:(PB3GetGeneralSettingByKeyReq *)req complete:(CompleteHandler)complete;

-(void)getWxSubConfig:(PB3GetWxSubConfigReq *)req complete:(CompleteHandler)complete;

-(void)getUserRanked:(PB3GetRankedReq *)req complete:(CompleteHandler)complete;

-(void)getGameRanked:(PB3GetRankedReq *)req complete:(CompleteHandler)complete;

-(void)informUser:(PB3InformUserReq *)req complete:(CompleteHandler)complete;

-(void)getWxConfig:(PB3GetWxConfigReq *)req complete:(CompleteHandler)complete;

-(void)getWxOpenId:(PB3GetWxOpenIdReq *)req complete:(CompleteHandler)complete;

-(void)getCircleMsg:(PB3GetCircleMsgReq *)req complete:(CompleteHandler)complete;

-(void)getPopUpConfig:(PB3GetPopUpConfigReq *)req complete:(CompleteHandler)complete;

-(void)sendSquareMessage:(PB3SendSquareMessageReq *)req complete:(CompleteHandler)complete;

-(void)getSquareImHistory:(PB3GetSquareImHistoryReq *)req complete:(CompleteHandler)complete;

@end

NS_ASSUME_NONNULL_END

