import time
import random
from locust import HttpUser, task, between

# Valid Quantities in Route page
quantities = [ 1, 2 ]
# Valid item IDs in the inventory
itemIDs = [ 1, 2, 3 ]
# Sample emails
customerEmails = [ "tkwu@ncsu.edu", "ajbulthu@ncsu.edu", "biudechu@ncsu.edu", "candice@ncsu.edu" ]

class FootwearWebstoreUser(HttpUser):
    wait_time = between(0, 5)

    @task
    def route_display_page(self):
        # implicitly calls "/displayProducts.php"
        self.client.get(url="/products.php")
    
    @task
    def buy_item(self):
        quantity = random.choice(quantities)
        itemID = random.choice(itemIDs)
        customerEmail = random.choice(customerEmails)
        self.client.get(url="/products.php?action=buy&quantity={}&itemID={}&customerEmail={}".format(quantity, itemID, customerEmail))
