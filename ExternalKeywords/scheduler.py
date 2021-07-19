import schedule
import time

def do_print():
    print("Hello")

schedule.every(10).seconds.do(do_print)
#schedule.every.wednesday.at('1:00').do(do_print)

while 1:
    schedule.run_pending()
    time.sleep(2)