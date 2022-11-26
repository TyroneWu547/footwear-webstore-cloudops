import time
import random
from locust import FastHttpUser, task, between

# Valid Quantities in Route page
quantities = [ 1, 2 ]
# Valid item IDs in the inventory
itemIDs = [ 1, 2, 3 ]
# Sample emails
customerEmails = [ "tkwu@ncsu.edu", "ajbulthu@ncsu.edu", 
                    "biudechu@ncsu.edu", "candice@ncsu.edu" ]

class FootwearWebstoreUser(FastHttpUser):
    wait_time = between(1, 5)

    @task
    def route_page(self):
        self.client.get(url=":30000/products.php")
    
    @task
    def buy_item(self):
        quantity = random.choice(quantities)
        itemID = random.choice(itemIDs)
        customerEmail = random.choice(customerEmails)
        self.client.get(url=":30001/buyProducts.php?quantity={}&itemID={}&customerEmail={}"
                            .format(quantity, itemID, customerEmail))
    
    @task
    def display_inventory(self):
        self.client.get(url=":30002/displayProducts.php")
