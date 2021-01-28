#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os

import common

router_file_name = 'HXRouter'


def generate_header(file_type):
    header_desc = common.generate_header_comment(router_file_name, file_type)
    if file_type == 'h':
        header_desc = header_desc + "\n\n#import <Foundation/Foundation.h>\n\n"
    elif file_type == 'm':
        header_desc = header_desc + "\n\n#import \"%s.h\"\n\n" % router_file_name
    header_desc = header_desc + '//⚠️ 该文件由脚本自动生成，请不要手动更改\n\n'
    return header_desc


def generate_router():
    # 打开头文件
    h_file = common.proj_path + '/' + router_file_name + '.h'
    h_header = generate_header('h')
    h_handler = open(h_file, 'w')
    h_handler.write(h_header)

    # 打开.m文件
    m_file = common.proj_path + '/' + router_file_name + '.m'
    m_header = generate_header('m')
    m_handler = open(m_file, 'w')
    m_handler.write(m_header)

    # 这些文件夹不用遍历
    paths = ['pb', 'res', 'Network', 'Assets.xcassets', 'Base.lproj', 'Public', '.DS_Store']
    for d in os.listdir(common.proj_path):
        # 过滤部分文件和文件夹
        if d in paths:
            continue
        sub_path = common.proj_path + '/' + d
        if os.path.isfile(sub_path):
            continue

        for root, dirs, files in os.walk(sub_path):
            for fileName in files:
                if fileName.endswith('.h'):
                    names = fileName.split('.')
                    class_name = names[0]
                    if class_name.endswith('ViewController'):
                        # 拼接变量名
                        router = 'hx_router_' + class_name

                        # 写入头文件
                        h_code = 'extern NSString * const %s;\n' % router
                        h_handler.write(h_code)

                        # 写入.m文件
                        m_code = 'NSString * const %s = @"%s";\n' % (router, class_name)
                        m_handler.write(m_code)
    h_handler.close()
    m_handler.close()


if __name__ == '__main__':
    generate_router()
