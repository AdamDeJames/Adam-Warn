<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<title>Warns</title>
        <style>
			.header1{
				align-items:center;
			}
			table{
				table-layout: fixed;
				border-bottom-color: #00F;
				border-top-width:thin;
				border-top-color:#00F;
				border-left-width:medium;
				border-left-color:#00F;
				border-right-width:medium;
				border-right-color:#00F;
			}
			td { 
			width: 5%;
			border-top:none;
			border-bottom:none;
			border-left:none;
			border-right:none;
			}
		</style>
	</head>
	
	<body>
		<h1>Search Warnings</h1>
		<div id="header1">
			<form action="index.php?search=" method="get">
				<p>SteamID or WarnID:</p>
				<input type="text" name="search">
               	<input type="submit" value="Search">
            </form>
            <form action="index.php" method="get">
                <input type="submit" value="Reset">
         	 </form>
		</div>
	</div>
 <?php

   $server = "127.0.0.1";
   $dbuser = "root";
   $dbpass = "";
   $dbname = "warnings";
   
$db = mysqli_connect($server, $dbuser, $dbpass);
mysqli_select_db($db, $dbname);
if(isset($_GET["search"])){
	$input = $_GET['search'];
	$q1 = "SELECT * FROM warns WHERE steamid = '".mysqli_escape_string($db, $input)."' OR name LIKE '%".mysqli_escape_string($db, $input)."%' OR id LIKE '%".mysqli_escape_string($db, $input)."%';";
	$result = mysqli_query($db, $q1);
	if($result == false or $result == nil){
		echo "Error; sql error: ".mysqli_error($db);
		exit;
	}
	while($row = mysqli_fetch_assoc($result)){
		echo "<table width=100% border=1 cellpadding=3 cellspacing=0>";
		echo "<tr style=\"font-weight:bold\">
		<td>ID</td>
		<td>Name</td>
		<td>SteamID</td>
		<td>Reason</td>
		<td>Time Warned</td>
		<td>Admin</td>
		</tr>";
		echo "<td>".$row["id"]."</td>";
		echo "<td>".$row["name"]."</td>";
		echo "<td>"."<a href=\"index.php?search=".$row["steamid"]."\">".$row["steamid"]."</td>";
		echo "<td>".$row["reason"]."</td>";
		echo("<td>Never</td>");	
		echo "<td>".$row["admin"]."</td>";
		
		echo "</table>";
	}
}else{
	$q1 = "SELECT * FROM warns";
	$result = mysqli_query($db, $q1);
	if($result == false or $result == nil){
		echo "Error; ".mysqli_error($db);
	}
	while($row = mysqli_fetch_assoc($result)){
		echo "<table width=100% border=1 cellpadding=3 cellspacing=0>";
		echo "<tr style=\"font-weight:bold\">
		<td>ID</td>
		<td>Name</td>
		<td>SteamID</td>
		<td>Reason</td>
		<td>Time Warned</td>
		<td>Admin</td>
		</tr>";
		echo "<td>".$row["id"]."</td>";
		echo "<td>".$row["name"]."</td>";
		echo "<td>"."<a href=\"index.php?search=".$row["steamid"]."\">".$row["steamid"]."</td>";
		echo "<td>".$row["reason"]."</td>";
		echo("<td>Never</td>");	
		echo "<td>".$row["admin"]."</td>";
		
		echo "</table>";
	}
}
?>
    Created by Adam James
<div>
</body>
</html>