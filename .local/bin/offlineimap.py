#! /usr/bin/env python
from subprocess import check_output
import subprocess

def get_pass(account):
    return check_output("pass " + account, shell=True).splitlines()[0]

def get_token(email_address):
    return subprocess.run(["oama", "access", email_address], capture_output=True, text=True).stdout
