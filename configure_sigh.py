#!/usr/bin/env python3

import os, glob, shutil, stat, sys, subprocess
from pathlib import Path


root = Path(sys.argv[1])


certificates = {}

for path_key in [Path(path) for path in glob.glob("/etc/mailcerts/*_key.pem")]:
    name = path_key.name.rpartition("_")[0]
    email = name.replace("-at-", "@", 1)
    cert_plus_key = open(path_key.parent/(name + "_cert.pem")).read() + open(path_key).read()
    path_cert_plus_key = root/(name + "-cert+key.pem")
    with open(path_cert_plus_key, "w") as file_cert_plus_key:
        os.chmod(file_cert_plus_key.fileno(), stat.S_IRUSR | stat.S_IWUSR)
        file_cert_plus_key.write(cert_plus_key)
    path_chain = path_key.parent/(name + "_chain.pem")
    if path_chain.exists():
        new_path_chain = root/(name + "-chain.pem")
        shutil.copy(path_chain, new_path_chain)
        os.chmod(new_path_chain, stat.S_IRUSR | stat.S_IWUSR)
    certificates[email] = path_cert_plus_key

with open("/tmp/signingtable.txt", "w") as cdb_source_file:
    for email, path_cert_plus_key in certificates.items():
        cdb_source_file.write("{} {}\n".format(email, path_cert_plus_key))
subprocess.check_call(["cdb", "-c", "-m", root/"signingtable.cdb", "/tmp/signingtable.txt"])
