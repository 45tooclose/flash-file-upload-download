<cfcontent type="text/xml" />
<cfheader name="expires" value="mon, 06 jan 1990 00:00:01 gmt">
<cfheader name="pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache">

<cfdirectory action="list" directory="#ExpandPath ('userUploads')#" name="uploadedFiles" filter="*.*" sort="dateLastModified DESC" />
<files>
	<cfoutput query="uploadedFiles">
		<f name="#name#" size="#size#" path="userUploads/#name#" />
	</cfoutput>
</files>