<p>Footwear Webstore - Microservices</p>
<?php
$displayProductsMicroService = "<display-server-IPv4-address>";
$buyProductsMicroService = "<buy-server-IPv4-address>";
$action = 'view';
if (isset($_GET['action']))
{
   $action = $_GET['action'];
}

if ($action == 'view')
{
     $url = "http://".urlEncode($displayProductsMicroService)."/displayProducts.php";
     $contents = file_get_contents($url);
     if($contents !== false)
     {
        echo $contents;
     }     
}
else if($action == 'buy')
{
     $customerEmail = $_GET['customerEmail'];
     $itemID = $_GET['itemID'];
     $quantityToBuy = $_GET['quantity'];

    $url = 'http://'.urlencode($buyProductsMicroService).'/buyProducts.php?customerEmail='.urlencode($customerEmail).'&itemID='.urlencode($itemID).'&quantity='.urlencode($quantityToBuy);
    //Once again, we use file_get_contents to GET the URL in question.
     $contents = file_get_contents($url);
     if($contents !== false)
     {
        echo $contents;
     } 
}

?>
<script src="https://code.jquery.com/jquery-latest.min.js"></script>
<script type="text/javascript" src="products.js"></script>
<br>
<label for="email">Enter your email:</label>
<input type="email" id="customerEmail" name="email">
<button type="button" id="buyProducts">Buy</button>
<div id="results" style="color: green;">
