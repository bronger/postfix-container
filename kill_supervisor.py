#!/usr/bin/env python3

import sys, os, signal, time, logging

logging.basicConfig(filename="/tmp/toll.log", level=logging.INFO)

while True:
    print("READY", flush=True)
    logging.info("READY")
    line = input()
    logging.info(line)
    headers = dict([x.split(":") for x in line.split()])
    payload = sys.stdin.read(int(headers['len']))
    logging.info("Payload: " + payload)
    if headers["eventname"] == "PROCESS_STATE_FATAL" and \
       dict([x.split(":") for x in payload.split()])["processname"] == "heartbeat":
        try:
            with open("/var/run/supervisord.pid") as pid_file:
                pid = int(pid_file.read())
            os.kill(pid, signal.SIGKILL)
        except Exception as error:
            pass
        print("RESULT 4\nFAIL", flush=True, end="")
        logging.info("RESULT 4\\nFAIL")
    else:
        print("RESULT 2\nOK", flush=True, end="")
        logging.info("RESULT 2\\nOK")
