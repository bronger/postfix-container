#!/usr/bin/env python

import sys, time, logging, psutil, os


logging.basicConfig(filename="/var/log/kill_supervisor.log", level=logging.INFO)


try:
    supervisord_pid = int(open("/var/run/supervisord.pid").read())
except (FileNotFoundError, ValueError):
    for process in psutil.process_iter():
        if process.name() == "supervisord":
            supervisord = process
            break
    else:
        supervisord = psutil.Process(1)
else:
    supervisord = psutil.Process(supervisord_pid)


try:
    termination_grace_period_seconds = int(os.environ.get("terminationGracePeriodSeconds"))
except (ValueError, TypeError):
    termination_grace_period_seconds = 30
termination_grace_period_seconds = max(termination_grace_period_seconds - 10, 0)


while True:
    print("READY", flush=True)
    logging.info("READY")
    line = input()
    logging.info(line)
    headers = dict([item.split(":", 1) for item in line.split()])
    payload = sys.stdin.read(int(headers["len"]))
    logging.info("Payload: " + payload)
    if headers["eventname"] in {"PROCESS_STATE_FATAL", "PROCESS_STATE_EXITED"}:
        payload = dict(item.split(":", 1) for item in payload.split())
        if payload["from_state"] == "RUNNING" and payload["expected"] == "0":
            supervisord.terminate()
            time.sleep(termination_grace_period_seconds)
            supervisord.kill()
            # This code should never be reached
            print("RESULT 4\nFAIL", flush=True, end="")
            logging.info("RESULT 4\\nFAIL")
            continue
    print("RESULT 2\nOK", flush=True, end="")
    logging.info("RESULT 2\\nOK")
