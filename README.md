# PBAutomaker
### 需求背景
在和后端对接```protobuf```接口时，以```version.ext.proto```举例，如下：

```
message GetLastVersionReq {
    string version = 1;
    string platform = 2; // v050新增，平台 iOS/Android
}

message GetLastVersionRes {
    string version = 1;
    ForceUpdate force_update = 2;
    string remark = 3;
    string pkg = 4;
    HasInstall has_install = 5;
    string date = 6; //日期
}

message InstallReportReq {
    string version = 1;
    string device = 2;
}

message InstallReportRes {
}

message GetViewHideInfoReq {
    int64 id = 1;
}

message GetViewHideInfoRes {
    ViewHideInfo info = 1;
}

service VersionExtObj {
    // 获取最新版本
    rpc GetLastVersion (GetLastVersionReq) returns (GetLastVersionRes);
    // 上报版本更新
    rpc InstallReport (InstallReportReq) returns (InstallReportRes);
    // 获取渠道版本显示规则
    rpc GetViewHideInfo (GetViewHideInfoReq) returns (GetViewHideInfoRes);
}
```
```version.ext.proto```中的```version```代表服务模块，在```service```中```VersionExtObj```代表服务对象。以其中一个```rpc```举例：
```GetLastVersion```：接口方法名  
```GetLastVersionReq```：接口请求对象  
```GetLastVersionRes```：接口响应对象  

由于需要接入公司的网络请求库，提供的发起网络请求的方法如下：  

```
- (void)sendRequestWithReq:(id)req
                  rspClass:(Class)rspClass
               ServiceName:(NSString*)serviceName
              functionName:(NSString*)functionName
                completion:(ZYGServiceRespCompletion)completion;
```
其中```serviceName```为```"xxx.version.VersionExtObj"```, xxx由后台给。所以一个```GetLastVersion```接口对应的oc代码大概长这样子：  
```   
-(void)getLastVersion:(PB3GetLastVersionReq *)req complete:(CompleteHandler)complete{
    [self sendReq:req 
    rspClass:[PB3GetLastVersionRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetLastVersion" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [self handleResponse:rsp error:error info:info complete:complete];
    }];
}
```
当面对成千上万的接口的时候，如：

![](https://github.com/zwp/PBAutomaker/blob/master/QQ20201224-181242.png)

这其中的代码量不言而喻，如何去避免繁重而重复的任务呢？这时候就该```PBAutomaker```上场了！


### 思路
1、解析```.proto```文件，提取其中的```module```模块名称、```service```服务对象名称、```functionName```方法名、```req```请求对象、```res```响应对象；  
2、根据第一步解析的信息，生成每一个```module```对应一个```protocol```协议、一个继承自```HXNetworkServiceComponent```并以```module```命名的实现类，如：  
3、
### 思路
### 思路

