<?php

$servername = "<database-public-IPv4-address>";
$username = "csc547";
$password = "csc547cloud";
$database = "Products";
$port = '3306';

// Create connection
$conn = mysqli_connect($servername, $username, $password, $database, $port);
$sql = "SELECT * FROM Footwear";
// Query all products using SQL
$result = mysqli_query($conn, $sql);
$htmlString = "";
$htmlString .= 
$htmlString .=  "<br>";
$htmlString .=  "<table border='1'>";
$htmlString .=  "<th>Product </th><th>Description</th><th>Cost($)</th><th>Count</th>";
while ($row = mysqli_fetch_assoc($result))
{
    $htmlString .=  "<tr>";
    $htmlString .=  "<td>" . strval($row["Name"]) . "</td>";
    $htmlString .=  "<td>" . strval($row["Description"]) . "</td>";
    $htmlString .=  "<td>" . strval($row["Cost"]) . "</td>";
    $htmlString .=  "<td><select class='productCount' data-productname='".strval($row["Name"])."' data-productid=".strval($row["ItemID"])." name='count'><option value=0>0</option><option value=1>1</option><option value=2>2</option></select></td>";
    $htmlString .=  "</tr>";
}
$htmlString .=  "</table>";
echo $htmlString;
?>
