#!/usr/bin/env python
# -*- coding: utf-8 -*-
import common


def generate_interface(service, file_name):
    # 生成pb的oc文件名
    oc_file_name = ''
    for item in file_name.split('_'):
        item = common.first_char_upper(item)
        oc_file_name += item
    oc_file_name += 'Ext'

    # 遵循的协议
    s_class = 'NSObject'
    if file_name in common.custom:
        s_class = 'IHXServiceModule'

    # 生成协议
    i_file_name = 'I' + common.class_prefix + service + 'ServiceComponent'
    text = common.generate_header_comment(i_file_name, 'h')
    text = text + '#import \"%s.pbobjc.h\"\n\nNS_ASSUME_NONNULL_BEGIN\n\n@protocol %s ' \
                  '<%s>\n\n' % (oc_file_name, i_file_name, s_class)
    return i_file_name, text


def generate_method(flags):
    func = common.first_char_lower(flags[0])
    text = '-(void)%s:(PB3%s *)req complete:(CompleteHandler)complete;\n\n' % (func, flags[1])
    return text


def generate_end():
    return '@end\n\nNS_ASSUME_NONNULL_END\n\n'
