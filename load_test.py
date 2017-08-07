from locust import HttpLocust, TaskSet
import random

lats = [random.uniform(50.0,55.0) for _ in xrange(10000)]
lngs = [random.uniform(-10.0,10.0) for _ in xrange(10000)]

def monitor(l, lat, lng):
    url = "/monitor/{0}/{1}".format(lat, lng)
    l.client.get(url)

class UserBehavior(TaskSet):
    tasks = {monitor: 3}

    def on_start(self):
        monitor(self, random.choice(lats), random.choice(lngs))

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000
