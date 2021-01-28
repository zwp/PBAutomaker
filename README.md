
### 需求背景
项目后端使用的是```protobuf```，通常拿到一个```xxx```服务模块的接口文件为```xxx.ext.proto```，以```version.ext.proto```举例，该文件包含了```version```这个服务提供的所有接口，如下所示：

```go
message GetLastVersionReq {
    ...
}

message GetLastVersionRes {
    ...
}

service VersionExtObj {
    // 获取最新版本
    rpc GetLastVersion (GetLastVersionReq) returns (GetLastVersionRes);
    rpc ...
    rpc ...
    rpc ...
} 
```
用```protobuf```编译器将pb文件生成的OC文件中只有一些```enum``` 和 ```message```对象，并不包含```service```对象，而```service```中的每个```rpc```对应着一个网络请求接口。请求接口要走公司的网络请求库，如下：
```objective-c
- (void)sendRequestWithReq:(id)req
                  rspClass:(Class)rspClass
               ServiceName:(NSString*)serviceName
              functionName:(NSString*)functionName
                completion:(ZYGServiceRespCompletion)completion;
```
其中```serviceName```为```"项目名称.version.VersionExtObj"```， 所以一个```GetLastVersion```接口对应的OC代码大概长这样子：  
```   objective-c
PB3GetLastVersionReq *req = [[PB3GetLastVersionReq alloc] init];
[ZYGService(IZYGNetworkService) sendRequestWithReq:req 
rspClass:[PB3GetLastVersionRes class] 
serviceName:"xxx.version.VersionExtObj" 
functionName:@"GetLastVersion" 
completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
	if ([rsp isKindOfClass:[PB3GetLastVersionRes class]]) {
    PB3GetLastVersionRes *res = rsp;
    // 处理逻辑
  }
}];
```
除了```version```模块，项目所有的```.proto```接口文件如下：

![](https://github.com/zwp/PBConvert/blob/master/res/WX20210128-222022.png)

面对这么多接口，如果按照上面那样的方式来编写请求接口的代码势必会非常繁琐，因为每次都需要对照`.proto`文件，将 ```req``` ```rspClass``` ```functionName```一一对应。那该怎么优化代码呢？

### 实现

##### 一、拆分模块

为了方便管理、分清各个服务模块，将每个```.proto```文件对应的```OC```代码都包含了一个协议头文件一个继承自```NSObject```的实现类，以`version`模块举例如下：

`IHXVersionServiceComponent.h`

```objective-c
#import "VersionExt.pbobjc.h"

@protocol IHXVersionServiceComponent <NSObject>

-(void)getLastVersion:(PB3GetLastVersionReq *)req complete:(CompleteHandler)complete;

...
...

@end

```

`HXVersionServiceComponent.h`

```objective-c
#import "IHXVersionServiceComponent.h"

@interface HXVersionServiceComponent : NSObject<IHXVersionServiceComponent>
  
@property (nonatomic, copy) NSString *serviceModule;

@end

```

`HXVersionServiceComponent.m`

```objc
#import "HXVersionServiceComponent.h"

@implementation HXVersionServiceComponent

ZYGSERVICE_COMPONENT_DECLARE(IHXVersionServiceComponent, ZYGServiceLoadType_OnNeed, 0)

-(void)getLastVersion:(PB3GetLastVersionReq *)req complete:(CompleteHandler)complete{
    [ZYGService(IHXNetworkServiceComponent) sendReq:req 
    rspClass:[PB3GetLastVersionRes class] 
    serviceName:self.serviceModule 
    functionName:@"GetLastVersion" 
    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {
         [ZYGService(IHXNetworkServiceComponent) handleResponse:rsp
          																								error:error 
          																				 				 info:info 
          																		 				 complete:complete];
    }];
}

...
...

#pragma mark - property

-(NSString *)serviceModule{
    if (!_serviceModule) {
        _serviceModule = [NSString serverNameForModule:@"version" service:@"VersionExtObj"];
    }
    return _serviceModule;
}
@end
```

> 注：`IHXNetworkServiceComponent`也是一个协议，`HXNetworkServiceComponent`实现类遵循了该协议，用于网络环境的初始化和网络请求的发起，`ZYGService(IHXNetworkServiceComponent)`可以认为是获取该实现类的单利对象。



##### 二、脚本自动生成代码

第一步虽然接口代码是按照模块分离了，但每个接口还是需要照着`.proto`文件一个个对应上，能不能通过什么途径去避免这些繁杂的工作呢？

经过仔细分析文件结构，我发现只要按照一定的格式，这些文件完全可以用脚本生成，而且`.proto`文件中的```req``` ```rspClass``` ```functionName```等都可以通过正则解析后提取出来。所以处理流程如下：

以以下`service`文件举例：

```go
service VersionExtObj {
    rpc GetLastVersion (GetLastVersionReq) returns (GetLastVersionRes);
} 

```

1、解析`.proto`文件，提取`service`对象，拿到最终的服务模块名称（即文件名称中的第一个单词）；

`Python`脚本

```python
# 读取.proto文件
content = open(file_name).read()
# 查找 service 关键字所在那一行，取出 ExtObj
match = re.search(r"service.*" + "([\s\S]*?)\{", content)
# 取出 VersionExtObj
service_obj = match.group().split(' ')[1]
# 取出 Version， 与 version.ext.proto 中的 version 对应
service_module = service_obj[:-6]
```

拿到了服务模块的名称，就可以根据名称生成对应的OC文件名、协议、实现类。



2、提取`service`对象中的所有`rpc`，并将接口名、请求对象、响应对象存入数组中；

```python
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
```



3、将解析结果按照固定格式拼接OC生成文件，具体代码在以下文件中。

[pb_extract.py](https://github.com/zwp/PBConvert/blob/master/pb_extract.py)：主文件

[pb_proto.py](https://github.com/zwp/PBConvert/blob/master/pb_proto.py)：协议文件

[pb_interface.py](https://github.com/zwp/PBConvert/blob/master/pb_interface.py)：实现类.h文件

[pb_imp.py](https://github.com/zwp/PBConvert/blob/master/pb_imp.py)：实现类.m文件



##### 三、模块的自定义

上面的第二个步骤避免了需要手动编写大量重复代码的问题，但是当某个模块的需要在初始化完成后进行一些自定义操作，比如注册服务端的推送消息、数据的初始化或者注册通知等。为了避免修改脚本生成的代码，这时候就需要创建一个模块对应的分类，在分类中完成一些自定义的操作。

`IHXSystemServiceComponent.h`

```objective-c
/// IHXSystemServiceComponent.h
/// 当某个接口模块需要自定义初始化方法时，遵循该协议，创建一个category，在category中实现该方法
@protocol IHXServiceModule <NSObject>
@optional
-(void)serviceModuleCustomMethod;
@end
  
@protocol IHXSystemServiceComponent <IHXServiceModule>
  
@end

// HXSystemServiceComponent.m 文件中添加实现init方法
-(instancetype)init{
    self = [super init];
    if ([self respondsToSelector:@selector(serviceModuleCustomMethod)]) {
        [self serviceModuleCustomMethod];
    }
    return self;
}
```

`HXSystemServiceComponent+custom.h`

```objective-c
#import "HXSystemServiceComponent.h"
@interface HXSystemServiceComponent (custom)<ZYGNetWorkServiceBroadCastDelegate>
  
@end
```

`HXSystemServiceComponent+custom.m`

```objective-c
#import "HXSystemServiceComponent+custom.h"
@implementation HXSystemServiceComponent (custom)
  
-(void)serviceModuleCustomMethod{
    [ZYGService(IZYGNetworkService) addDelegate:self];
    [ZYGService(IZYGNetworkService) registerCmdid:PB3SystemCmdId_SystemSquareComMsgCmdId
                                         forClass:[PB3CommonMsgInfo class]];
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



##### 四、最后

[`auto_proto.sh`](https://github.com/zwp/PBConvert/blob/master/auto_proto.sh)脚本主要做一下几件事：

1、根据传入的分支拉取pb仓库最新的代码；

2、执行`Python`脚本，删除部分无用的文件，只留下`*.ext.proto`文件;

3、用`protobuf`编译器将`*.ext.proto`中的`message`、`enum`等编译转化成OC实体类；

4、解析、提取`*.ext.proto`文件中的`service`相关信息；

5、根据提取的信息生成OC文件。

