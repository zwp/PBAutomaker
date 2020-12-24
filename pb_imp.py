#!/usr/bin/env python
# -*- coding: utf-8 -*-
import common


def generate_imp(service):
    file_name = common.class_prefix + service + 'ServiceComponent'
    i_file_name = 'I' + file_name
    text = common.generate_header_comment(file_name, 'm')
    text = text + '#import \"%s.h\"\n\n@implementation %s\n\nZYGSERVICE_COMPONENT_DECLARE(%s, ' \
                  'ZYGServiceLoadType_OnNeed, 0)\n\n' % (
               file_name, file_name, i_file_name)

    text += '-(instancetype)init{\n    self = [super init];\n    [self customInitSelf];\n    return self;\n}\n\n'
    text += '-(void)customInitSelf{\n\n}\n\n'
    return file_name, text


def generate_method(flags):
    func = common.first_char_lower(flags[0])
    res_name = 'PB3' + flags[2]
    text = '-(void)%s:(PB3%s *)req complete:(CompleteHandler)complete{\n' \
           '    [self sendReq:req \n' \
           '    rspClass:[%s class] \n' \
           '    serviceName:self.serviceModule \n' \
           '    functionName:@\"%s\" \n' \
           '    completion:^(id rsp, ZYGNetworkServiceError *error, ZYGServiceWupStatInfo *info) {\n ' \
           '        [self handleResponse:rsp error:error info:info complete:complete];\n' \
           '    }];\n}\n\n' % (func, flags[1], res_name, flags[0])
    return text


def generate_end(module, obj):
    return '#pragma mark - property\n\n-(NSString *)serviceModule{\n    return [NSString serverNameForModule:@\"%s\" ' \
           'service:@\"%s\"];\n}\n\n@end' % (module, obj)
