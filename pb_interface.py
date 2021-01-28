#!/usr/bin/env python
# -*- coding: utf-8 -*-
import common


def generate_interface(service):
    file_name = common.class_prefix + service + 'ServiceComponent'
    i_file_name = 'I' + file_name
    text = common.generate_header_comment(file_name, 'h')
    text += '#import \"%s.h\"\n\nNS_ASSUME_NONNULL_BEGIN\n\n@interface ' \
            '%s : NSObject<%s>\n\n@property (nonatomic, copy) NSString ' \
            '*serviceModule;\n\n@end\n\nNS_ASSUME_NONNULL_END' % (
                i_file_name, file_name, i_file_name)

    return file_name, text
