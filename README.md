
### 需求背景
在和后端对接```protobuf```接口时，以```version.ext.proto```举例，如下：

```go
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

```objective-c
- (void)sendRequestWithReq:(id)req
                  rspClass:(Class)rspClass
               ServiceName:(NSString*)serviceName
              functionName:(NSString*)functionName
                completion:(ZYGServiceRespCompletion)completion;
```
其中```serviceName```为```"xxx.version.VersionExtObj"```, xxx由后台给。所以一个```GetLastVersion```接口对应的oc代码大概长这样子：  
```   objective-c
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
使用时
```objective-c
- (void)checkVersion{
    PB3GetLastVersionReq *req = [[PB3GetLastVersionReq alloc] init];
    req.platform = @"iOS";
    req.version = [NSString appVersion];
    [ZYGService(IHXVersionServiceComponent) getLastVersion:req
                                                  complete:^(HXRequestResponseStatus response, id  _Nullable result) {
        if (response == HXNetworkResponseNormal && [result isKindOfClass:[PB3GetLastVersionRes class]]) {
            PB3GetLastVersionRes *res = result;
            // 处理逻辑
        }
    }];
}
```

> 注：  
> 1、`IHXVersionServiceComponent`是一个协议，包含`version`这个模块所有的接口的调用方法；
>
> 2、`HXVersionServiceComponent`遵循`IHXVersionServiceComponent`协议，是它的的实现类；
>
> 3、```ZYGService(IHXVersionServiceComponent)```可以理解为获取一个遵循了```IHXVersionServiceComponent```协议的单例对象。
所以一个模块的代码结构大致为：  

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gm3f01ha27j30f204hq37.jpg)



随着项目的拓展，当面对多个服务模块的时候，如：

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gm3exvd1coj30es0ihabm.jpg)

这意味着每个服务模块都需要创建一个对应的```ServiceComponent```，为了避免繁重而重复的任务，该脚本应运而生。

### 效果

先来看看效果：

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gm3e21z2nlj30ab0gswf8.jpg)






### 实现
##### 解析```.proto```文件  
提取其中的```module```模块名称、```service```服务对象名称、```functionName```方法名、```req```请求对象、```res```响应对象，主要代码如下：

```python

def update_service():
    for roots, dirs, files in os.walk(common.pb_path):
        for item in files:
            flags = item.split('.')
            if len(flags) != 3:
                # 不是外部接口文件
                continue
            file_name = os.path.join(common.pb_path, item)
            content = open(file_name).read()

            # 查找 service 关键字所在那一行，取出 ExtObj
            match = re.search(r"service.*" + "([\s\S]*?)\{", content)
            if not match:
                continue
            service_obj = match.group().split(' ')[1]
            service_module = service_obj[:-6]

            # protocol
            i_tuple = pb_proto.generate_interface(service_module, flags[0])
            i_file_name = i_tuple[0]
            i_content = i_tuple[1]

            # .m
            m_tuple = pb_imp.generate_imp(service_module)
            m_file_name = m_tuple[0]
            m_content = m_tuple[1]

            # 取出完整的service，并解析出 function、req、res
            service_obj_text = re.search(r"service.*" + service_obj + "([\s\S]*?)\}", content).group()
            service_obj_text = remove_comments(service_obj_text)
            rpc = re.finditer(r"rpc([\s\S]*?);", service_obj_text)
            for r in rpc:
                line_text = r.group()
                # 解析出req、res
                p = re.compile(r'[(](.*?)[)]', re.S)
                array = re.findall(p, line_text)

                # 解析function
                func = re.search(r"rpc([\s\S]*?)\(", line_text).group()
                for s in ['rpc', '(']:
                    func = func.replace(s, '')
                func = func.strip()
                array.insert(0, func)
                # 解析结果 array: ['GetLastVersion', 'GetLastVersionReq', 'GetLastVersionRes']

                # 生成协议方法
                i_content = i_content + pb_proto.generate_method(array)
                # 生成实现方法
                m_content = m_content + pb_imp.generate_method(array)

            i_content = i_content + pb_proto.generate_end()
            m_content = m_content + pb_imp.generate_end(flags[0], service_obj)
            d = common.code_path + service_module
            if not os.path.exists(d):
                os.makedirs(d)
                print('创建文件夹' + service_module)

            # protocol
            i_fh = open(d + '/' + i_file_name + '.h', 'w')
            i_fh.write(i_content)
            i_fh.close()

            # .h
            h_tuple = pb_interface.generate_interface(service_module)
            h_file_name = h_tuple[0]
            h_content = h_tuple[1]
            h_fh = open(d + '/' + h_file_name + '.h', 'w')
            h_fh.write(h_content)
            h_fh.close()

            # .m
            m_fh = open(d + '/' + m_file_name + '.m', 'w')
            m_fh.write(m_content)
            m_fh.close()

```



##### 生成oc文件  
根据第一步解析的信息，生成每一个```module```对应的一个```protocol```协议、一个继承自```HXNetworkServiceComponent```并以```module```命名的实现类，以`version`服务为例：

`IHXVersionServiceComponent.h`

```objective-c
#import "HXNetwork.h"
#import "VersionExt.pbobjc.h"

@protocol IHXVersionServiceComponent <NSObject>

-(void)getLastVersion:(PB3GetLastVersionReq *)req complete:(CompleteHandler)complete;

-(void)installReport:(PB3InstallReportReq *)req complete:(CompleteHandler)complete;

-(void)getViewHideInfo:(PB3GetViewHideInfoReq *)req complete:(CompleteHandler)complete;

@end


```

`HXVersionServiceComponent.h`

```objective-c

#import "HXNetworkServiceComponent.h"
#import "IHXVersionServiceComponent.h"

@interface HXVersionServiceComponent : HXNetworkServiceComponent<IHXVersionServiceComponent>

@end

```

`HXVersionServiceComponent.m`

```objc

#import "HXVersionServiceComponent.h"

@implementation HXVersionServiceComponent

ZYGSERVICE_COMPONENT_DECLARE(IHXVersionServiceComponent, ZYGServiceLoadType_OnNeed, 0)

-(void)getLastVersion:(PB3GetLastVersionReq *)req complete:(CompleteHandler)complete{
    [self sendReq:req 
    rspClass:[PB3GetLastVersionRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetLastVersion" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [self handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)installReport:(PB3InstallReportReq *)req complete:(CompleteHandler)complete{
    [self sendReq:req 
    rspClass:[PB3InstallReportRes class] 
    serviceName:self.serviceModule 
    functionName:@"InstallReport" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [self handleResponse:rsp error:error info:info complete:complete];
    }];
}

-(void)getViewHideInfo:(PB3GetViewHideInfoReq *)req complete:(CompleteHandler)complete{
    [self sendReq:req 
    rspClass:[PB3GetViewHideInfoRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetViewHideInfo" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [self handleResponse:rsp error:error info:info complete:complete];
    }];
}

#pragma mark - property

-(NSString *)serviceModule{
    return [NSString serverNameForModule:@"version" service:@"VersionExtObj"];
}

@end
```



`HXNetworkServiceComponent`的代码如下：

`HXNetworkServiceComponent.h`：

```objective-c
#import <Foundation/Foundation.h>

@interface HXNetworkServiceComponent : NSObject
  
// 提供给子类实现
@property (nonatomic, copy, readonly) NSString *serviceModule;

// 提供给子类的分类在 init 方法中完成一些初始化工作，如：订阅服务端发过来的推送消息
-(void)customMethod;


-(void)handleResponse:(id)rsp

​        error:(ZYGNetworkServiceError *)error

​         info:(ZYGServiceWupStatInfo *)info

​       complete:(CompleteHandler)complete;


- (void)sendReq:(id)req

​    rspClass:(Class)rspClass

  serviceName:(NSString*)serviceName

  functionName:(NSString*)functionName

   completion:(ZYGServiceRespCompletion)completion;

@end
```

`HXNetworkServiceComponent.m`：

```objective-c
#import "HXNetworkServiceComponent.h"

@interface HXNetworkServiceComponent ()<NetWorkServiceDelegate>

@end
  
@implementation HXNetworkServiceComponent

-(instancetype)init{
    if (self = [super init]) {
        [self initSelf];
        [self customMethod];
    }
    return self;
}

-(void)initSelf{
  	[self configNetwork];
  	[self registeNetworkStatusNotifications];
}

-(void)configNetwork{
		//初始化网络请求
}

-(void)customMethod{
    
}

-(void)registeNetworkStatusNotifications{
  //监听网络状态
}

#pragma mark - NetWorkServiceDelegate

-(void)serviceLog:(NSString *)msg{
    NSLog(@"%@", msg);
}

- (void)sendReq:(id)req
       rspClass:(Class)rspClass
    serviceName:(NSString*)serviceName
   functionName:(NSString*)functionName
     completion:(ZYGServiceRespCompletion)completion{
       
    // 设置默认的请求头
    NSMutableDictionary *header = [self defaultHeader];
       
    // 调用中台网络库的请求方法
    [ZYGService(IZYGNetworkService) sendRequestWithReq:req
                                                header:header
                                           channelType:ZYGChannelType_ShortConn
                                              rspClass:rspClass
                                           ServiceName:serviceName
                                          functionName:functionName
                                            completion:completion];
}

```



##### 模块的自定义

当某个模块的对象需要在初始化完成后进行一些操作，比如注册服务端的推送消息、数据的初始化或者注册通知等。为了避免直接修改脚本生成的代码，这时候就需要创建一个模块对应的分类，并使用`method swizzling`替换掉父类的`customMethod`方法。

`HXSystemServiceComponent+custom.h`

```objective-c

#import "HXSystemServiceComponent.h"

@interface HXSystemServiceComponent (custom)<ZYGNetWorkServiceBroadCastDelegate>

@end
```

`HXSystemServiceComponent+custom.m`

```objective-c

#import "HXSystemServiceComponent+custom.h"
#import "HXRuntime.h"

@implementation HXSystemServiceComponent (custom)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      	// 方法交换，替换掉父类的customMethod方法(确保只发生一次替换)
        hx_swizzleMethod([self class], @selector(customMethod), @selector(hx_swizzled_customMethod));
    });
}

-(void)hx_swizzled_customMethod{
    [ZYGService(IZYGNetworkService) addDelegate:self];
    [ZYGService(IZYGNetworkService) registerCmdid:PB3SystemCmdId_SystemMsgCmdId
                                         forClass:[PB3PushCircleMsg class]];
}

#pragma mark - ZYGNetWorkServiceBroadCastDelegate

- (void)handleCmdid:(uint32_t)cmdid serverPush:(ZYGPROTOServerPush *)serverPush withObj:(id)obj {
    NSLog(@"%d\n %@\n %@\n", cmdid, serverPush, obj);
    switch (serverPush.cmdId) {
        case PB3SystemCmdId_SystemMsgCmdId:
            // 处理系统的推送消息
            break;
            
        default:
            break;
    }
}
```



### 总结

`auto_proto.sh`脚本主要做一下几件事：

1、根据传入的分支拉取pb仓库最新的代码；

2、执行`Python`脚本，删除部分无用的文件，只留下`*.ext.proto`文件;

3、将`*.ext.proto`中的`message`、`enum`等转化成oc实体类；

4、解析、提取`*.ext.proto`文件中的`service`相关信息；

5、根据提取的信息生成oc文件。
