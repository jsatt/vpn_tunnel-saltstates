#!/usr/bin/env python3
from crypt import crypt, mksalt
import sys

def mkpasswd(passwd):
    salt = mksalt()
    return crypt(passwd, salt)


if __name__ == '__main__':
    try:
        passwd = sys.argv[1]
    except IndexError:
        print('you must provide a password')
    else:
        print(mkpasswd(passwd))
