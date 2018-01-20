#!/usr/bin/env python3

import sys, time, logging, psutil


logging.basicConfig(filename="/var/log/kill_supervisor.log", level=logging.INFO)


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


while True:
    print("READY", flush=True)
    logging.info("READY")
    line = input()
    logging.info(line)
    headers = dict([x.split(":") for x in line.split()])
    payload = sys.stdin.read(int(headers['len']))
    logging.info("Payload: " + payload)
    if headers["eventname"] in {"PROCESS_STATE_FATAL", "PROCESS_STATE_EXITED"}:
        payload = dict(item.split(":", 1) for item in payload.split())
        if payload["from_state"] == "RUNNING" and payload["expected"] == "0":
            supervisord.terminate()
            time.sleep(30)
            supervisord.kill()
            # This code should never be reached
            print("RESULT 4\nFAIL", flush=True, end="")
            logging.info("RESULT 4\\nFAIL")
            continue
    print("RESULT 2\nOK", flush=True, end="")
    logging.info("RESULT 2\\nOK")
