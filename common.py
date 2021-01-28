#!/usr/bin/env python
# -*- coding: utf-8 -*-
import time

target = 'demo'
# proj_path = '../../' + target + '-ios/' + target
user_name = 'zwp'
org = 'XY'
class_prefix = 'HX'

# pb文件夹
pb_path = './proto'

# 本地目录（测试）
# code_path = './' + target + '/Network/'

# iOS工程目录
code_path = '../../' + target + '-ios/' + target + '/Network/'

# 需要自定义模块
custom = ['oss', 'room', 'system', 'user']


# 生成头文件注释部分
def generate_header_comment(file_name, file_type):
    localtime = time.localtime(time.time())
    date_desc = "%d/%d/%d" % (localtime.tm_year, localtime.tm_mon, localtime.tm_mday)
    year = "%d" % localtime.tm_year
    header_desc = "//\n//  %s.%s\n//  %s\n//\n//  Created by %s on %s.\n//  Copyright © %s年 %s. All rights " \
                  "reserved.\n//\n\n" % (
                      file_name, file_type, target, user_name, date_desc, year, org)
    header_desc = header_desc + '//⚠️ 该文件由脚本自动生成，请不要手动更改\n\n'
    return header_desc


# 首字母小写转换函数
def first_char_lower(s):
    return s[:1].lower() + s[1:]


# 首字母da写转换函数
def first_char_upper(s):
    return s[:1].upper() + s[1:]
