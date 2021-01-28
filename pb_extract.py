#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import re
import pb_proto
import pb_interface
import pb_imp
import common


def remove_comments(text):
    def replacer(match):
        s = match.group(0)
        if s.startswith('/'):
            return " "  # note: a space and not an empty string
        else:
            return s

    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|\'(?:\\.|[^\\\'])*\'|"(?:\\.|[^\\"])*"',
        re.DOTALL | re.MULTILINE
    )
    return re.sub(pattern, replacer, text)


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
            m_tuple = pb_imp.generate_imp(service_module, flags[0])
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


if __name__ == '__main__':
    update_service()
