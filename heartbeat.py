#!/usr/bin/env python3

import subprocess, threading, psutil


observed_process_names = {"master", "sigh"}


try:
    supervisord_pid = int(open("/var/run/supervisord.pid").read())
except (FileNotFoundError, ValueError):
    for process in psutil.process_iter():
        if process.name() == "supervisord":
            supervisord = process
            break
    else:
        supervisord = psutil.Process().parent()
        if not supervisord:
            RuntimeError("No supervisord process found")
else:
    supervisord = psutil.Process(supervisord_pid)


class ObserveProcess(threading.Thread):
    def __init__(self, process):
        super().__init__()
        self.process = process
    def run(self):
        psutil.wait_procs([self.process])
        supervisord.kill()


found_processes = set()
for process in psutil.process_iter():
    name = process.name()
    if name in observed_process_names:
        ObserveProcess(process).start()
        found_processes.add(name)
assert found_processes == observed_process_names
