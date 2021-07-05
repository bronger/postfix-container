#!/usr/bin/env python

import os, glob, shutil, stat, sys, pwd
from pathlib import Path


root = Path(sys.argv[1])
uid = pwd.getpwnam("filter").pw_uid
gid = pwd.getpwnam("filter").pw_gid


certificates = []

for path_key in [Path(path) for path in glob.glob("/etc/mailcerts/*_key.pem")]:
    name = path_key.name.rpartition("_")[0]
    email = name.replace("-at-", "@", 1)
    print(f"configure_sigh.py: Found S/MIME certificate for {email}")

    new_path_key = root/path_key.name
    with open(new_path_key, "w") as new_key_file:
        os.chmod(new_key_file.fileno(), stat.S_IRUSR | stat.S_IWUSR)
        os.chown(new_key_file.fileno(), uid, gid)
        new_key_file.write(open(path_key).read())

    cert_plus_chain = open(path_key.parent/(name + "_cert.pem")).read()
    path_chain = path_key.parent/(name + "_chain.pem")
    if path_chain.exists():
        cert_plus_chain += open(path_chain).read()
    path_cert_plus_chain = root/(name + "_cert+chain.pem")
    with open(path_cert_plus_chain, "w") as file_cert_plus_chain:
        os.chmod(file_cert_plus_chain.fileno(), stat.S_IRUSR | stat.S_IWUSR)
        os.chown(file_cert_plus_chain.fileno(), uid, gid)
        file_cert_plus_chain.write(cert_plus_chain)

    certificates.append((email, path_key, path_cert_plus_chain))

if not certificates:
    print("configure_sigh.py: WARNING: No S/MIME certificates found")

with open("/etc/sigh/mapfile.txt", "w") as map_file:
    for email, path_key, path_cert_plus_chain in certificates:
        map_file.write("{} key:{},cert:{}\n".format(email, path_key, path_cert_plus_chain))
