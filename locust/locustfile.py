import time
from locust import HttpUser, task, between

class FootwearWebstoreUser(HttpUser):
    wait_time = between(0, 5)

    @task
    def route_page(self):
        # "/products.php" implicitly calls "/displayProducts.php"
        self.client.get(url="/products.php")
