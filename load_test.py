from locust import HttpLocust, TaskSet

def monitor(l):
    l.client.get("/monitor/51.50809/-0.1291379")

class UserBehavior(TaskSet):
    tasks = {monitor: 1}

    def on_start(self):
        monitor(self)

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000
