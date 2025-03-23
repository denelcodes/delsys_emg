import random
import time

FILENAME = "finger_log.txt"

while True:
    with open(FILENAME, "w") as f:
        f.write(random.choice(["i", "i"]))
    time.sleep(0.5)  # delay in seconds