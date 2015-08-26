<!--- Files are uploaded into the userUploads folder. --->
<cffile action="upload" fileField="Filedata" destination="#ExpandPath ('userUploads')#" nameConflict="makeUnique" />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title> Upload Page </title>
<meta name="Generator" content="EditPlus">
<meta name="Author" content="">
<meta name="Keywords" content="">
<meta name="Description" content="">
</head>

<body>
	<h3>Upload Successful</h3>
</body>
</html>
