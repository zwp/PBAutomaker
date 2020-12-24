# coding=utf-8
import os
import re
import shutil
import sys

# pb文件存放路径
dir_pb = './proto'

# 这几个文件不用处理
black_list = [
    'advertising',
    'activity',
    'uauth_common',
    'uauth',
    'user_status',
    'match'
]


# 移除一整个消息对象
def remove_hole_message(text):
    arg_len = len(sys.argv)
    # debug模式，直接返回
    if arg_len <= 1:
        return text

    keywords = ["ViewHideInfo",
                "GetViewHideInfoReq", "GetViewHideInfoRes",
                ]
    i = 0
    while i < len(keywords):
        text = re.sub(r"message.*" + keywords[i] + "([\s\S]*?)\}", '', text)
        text = re.sub(r"rpc.*" + keywords[i] + "([\s\S]*?);", "", text)
        text = re.sub(r"enum.*" + keywords[i] + "([\s\S]*?)\}", '', text)
        i += 1
    return text


# 移除关键字所在的一整行
def remove_hole_line(text):
    arg_len = len(sys.argv)
    # debug模式，直接返回
    if arg_len <= 1:
        return text

    keywords = ["ViewHideInfo", "GetViewHideInfo"]
    i = 0
    while i < len(keywords):
        # print(keywords[i])
        text = re.sub(r".*" + keywords[i] + ".*", '', text)
        i += 1
    return text


# 移除注释
def remove_comments(text):
    arg_list = sys.argv
    arg_len = len(sys.argv)
    if arg_len >= 2 and arg_list[1] == "Release":
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
    else:
        return text


if __name__ == '__main__':
    for filename in os.listdir(dir_pb):
        path = os.path.join(dir_pb, filename)
        if os.path.isdir(path):
            # 删除文件夹
            shutil.rmtree(path)
        else:
            if not filename.endswith('.proto'):
                os.remove(path)
            else:
                seps = filename.split('.')
                if seps[1] == 'int' or len(seps) == 2:
                    os.remove(path)
                    print '删除文件：' + path
                    continue
                # 删除不需要处理的文件
                for item in black_list:
                    if filename.startswith(item):
                        if os.path.exists(path):
                            print '删除文件黑名单：' + path
                            os.remove(path)
                if not os.path.exists(path):
                    print '文件已删除：' + path
                    continue

                # ext文件
                print filename
                code_original = open(path).read()
                code_new = remove_hole_message(code_original)
                code_new = remove_hole_line(code_new)
                code_new = remove_comments(code_new)
                fh = open(path, "w")
                fh.write(code_new)
                fh.close()
