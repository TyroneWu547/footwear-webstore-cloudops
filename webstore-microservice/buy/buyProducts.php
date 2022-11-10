<?php
$servername = "<database-server-IPv4-address>";
$username = "csc547";
$password = "CsCEcE547@Cloud";
$database = "Products";
$port = '3306';

// Create connection
$conn = mysqli_connect($servername, $username, $password, $database, $port);

function lockTable($tableName, $conn)
{
   $sqlCommand = "LOCK TABLE $tableName WRITE;";
   echo $sqlCommand;
   if($conn->query($sqlCommand)){
        echo "lock successfull\n";
   }
  else{
        echo "lock failed\n";
   }
}

function getItemCount($itemID, $conn) {
  echo 'In function\n';
  $sqlCommand = "SELECT * FROM Inventory WHERE ItemID='$itemID'";
  $result = $conn->query($sqlCommand);
  $result = mysqli_query($conn, $sqlCommand);
  $row = $result->fetch_row();
  return $row[1];
}

function unlockTable($tableName, $conn)
{
   $sqlCommand = "UNLOCK TABLES;";
   if($conn->query($sqlCommand))
   {
        echo "unlock successfull\n";
   }
  else{
        echo "unlock failed\n";
   }
}

function updateItemCount($itemID, $updatedQuantity, $conn) {
  echo 'in function';
  $sqlCommand = "UPDATE Inventory SET Count='$updatedQuantity' WHERE ItemID='$itemID'";
   if($conn->query($sqlCommand)){
        echo "updated item count successfully\n";
   }
  else{
        echo "failed to update item count\n";
   }
}

function addCustomerOrder($conn, $customerEmail, $itemID, $quantity){
        $sql = "INSERT INTO `Orders` (`ItemID`, `CustomerEmail`, `Quantity`) VALUES ($itemID,'$customerEmail',$quantity);";
        echo $sql;
        if($conn->query($sql)){
                echo "<br>Inserted new order successfully";
        }
        else {
                echo "<br>Unable to insert new order";
        }
}

$itemID = $_GET['itemID'];
$quantityToBuy = $_GET['quantity'];
$customerEmail = $_GET['customerEmail'];
unlockTable('Inventory', $conn);
$quantityInInventory = getItemCount($itemID, $conn);
if ($quantityInInventory > $quantityToBuy)
{
    lockTable('Inventory', $conn);
    echo 'updating quantity';
    updateItemCount($itemID, $quantityInInventory - $quantityToBuy, $conn);
    unlockTable('Inventory', $conn);
    lockTable('Orders', $conn);
    addCustomerOrder($conn, $customerEmail, $itemID, $quantityToBuy);
    unlockTable('Orders', $conn);
    echo "success";
}
echo "failure";
?>
