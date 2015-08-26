import mx.controls.*;
import mx.utils.Delegate;
import flash.net.*;
import com.oinam.util.UploadQueue;
import com.oinam.controls.*;

var browseLabel:Label;
var browseButton:Button;
var clearButton:Button;
var uploadFilesList:List;
var uploadButton:Button;
var uploadProgressBar:ProgressBar;

var downloadLabel:Label;
var downloadFilesList:List;
var downloadButton:Button;
var downloadProgress:ProgressBar;

function main () 
{
	Stage.scaleMode = "noScale";
	Stage.align = "TL";
	stop ();

	// files that can be uploaded
	fileTypes = [
		{description:"Images", extension:"*.jpg;*.gif;*.png"}
	];

	// to be provided via flashvars
	if (uploadUrl == null) 
	{
		uploadUrl = "http://localhost/flash/8/beta/beta1/practice/upload/3/bin/uploadFile.cfm";
	};

	// to be provided via flashvars
	if (downloadListUrl == null) 
	{
		downloadListUrl = "http://localhost/flash/8/beta/beta1/practice/upload/3/bin/viewFiles.cfm";
	};

	// in kb
	if (maxFileSize == null) 
	{
		maxFileSize = 25;
	};

	appUrl = _url.substring (0, _url.lastIndexOf ("/"));

	browseButton.enabled = true;
	uploadButton.enabled = false;
	uploadProgressBar.visible = false;

	uploadFilesList.dataProvider = [];
	uploadFilesList.labelFunction = function (data:Object):String 
	{
		return (data.name + " (" + Math.round (data.size/1024) + "kb)");
	};

	var buttonDelegate:Function = Delegate.create (this, buttonChanged);
	browseButton.addEventListener ("click", buttonDelegate);
	clearButton.addEventListener ("click", buttonDelegate);
	uploadButton.addEventListener ("click", buttonDelegate);
	refreshButton.addEventListener ("click", buttonDelegate);
	downloadButton.addEventListener ("click", buttonDelegate);

	uploadRefList = new FileReferenceList ();
	uploadRefListener = new Object ();
	uploadRefListener.onSelect = function (refList:FileReferenceList) 
	{
		var invalidFiles:Number = 0;
		var n:Number = refList.fileList.length;
		var s:String = "Only images smaller than " + maxFileSize + "kb are allowed. ";
		var file:FileReference;
		for (var i:Number = 0; i < n; ++i) 
		{
			file = refList.fileList [i];
			if (file.size/1024 > maxFileSize) 
			{
				refList.fileList.splice (i, 1);
				invalidFiles++;
			};
		};

		if (invalidFiles > 0) 
		{
			s += invalidFiles + " files were ignored.";
			showAlert ("Error", s);
		};

		uploadFilesList.dataProvider = uploadFilesList.dataProvider.concat (refList.fileList);
		uploadButton.enabled = uploadFilesList.dataProvider.length;
	};

	uploadRefList.addListener (uploadRefListener);

	uploadQueue = new UploadQueue (uploadUrl);
	uploadDelegate = Delegate.create (this, uploadQueueChanged);

	uploadQueue.addEventListener ("start", uploadDelegate);
	uploadQueue.addEventListener ("progress", uploadDelegate);
	uploadQueue.addEventListener ("error", uploadDelegate);
	uploadQueue.addEventListener ("complete", uploadDelegate);

	downloadFilesList.dataProvider = [];
	downloadFilesList.labelFunction = function (data:Object) 
	{
		return (data.attributes.name + " (" + Math.round (data.attributes.size/1024) + "kb)");
	};
	downloadFilesList.addEventListener ("change", Delegate.create (this, downloadListChanged));

	downloadFileListener = new Object ();
	downloadFileListener.onOpen = function () 
	{
		downloadProgressBar.label = "Downloading File ...";
	};

	downloadFileListener.onProgress = function (fileRef:FileReference, bytesLoaded:Number, bytesTotal:Number) 
	{
		downloadProgressBar.setProgress (bytesLoaded/bytesTotal*100, 100);
	};

	downloadFileListener.onComplete = function (fileRef:FileReference) 
	{
		downloadProgressBar.label = "Download complete";
	};

	downloadFileListener.onIOError = function (fileRef:FileReference) 
	{
		showAlert ("Error", "An IOError occurred");
	};

	downloadFileListener.onSecurityError = function (fileRef:FileReference, errorCode:String) 
	{
		showAlert ("Error", errorCode);
	};

	/*
	imageLoader.setStyle ("borderStyle", "solid");
	delegate = Delegate.create (this, imageLoaderChanged);
	imageLoader.addEventListener ("progress", delegate);
	imageLoader.addEventListener ("complete", delegate);
	loaderProgressBar.visible = false;
	*/

	attachMovie (PhotoPane.symbolName, "photoPane", 5);
	photoPane.setSize (252, 140);
	photoPane.move (285, 249);

	loadUploadList ();

};

function showAlert (title:String, message:String) 
{
	message += "\t\r\r\r";

	Alert.yesLabel = "Ok";
	Alert.show (message, title, Alert.OK);
};

function trace2 () 
{
	trace (arguments.join (" : "));
};

function imageLoaderChanged (eventObj:Object) 
{
	switch (eventObj.type) 
	{
	
		case "progress":
			loaderProgressBar.visible = true;
			loaderProgressBar.setProgress (imageLoader.percentLoaded, 100);
			break;
		
		case "complete":
			loaderProgressBar.visible = false;
			break;
		
		default :
			;
	};
};

function buttonChanged (eventObj:Object) 
{
	switch (eventObj.target) 
	{
	
		case browseButton:
			uploadRefList.browse (fileTypes);
			break;
		
		case clearButton:
			uploadFilesList.dataProvider = [];
			uploadButton.enabled = false;
			break;

		case uploadButton:
			uploadQueue.start (uploadFilesList.dataProvider);
			break;

		case refreshButton:
			loadUploadList ();
			break;

		case downloadButton:
			var selectedFile:Object = downloadFilesList.selectedItem;
			if (selectedFile != null) 
			{
				var url:String = appUrl + "/" + selectedFile.attributes.path;
				downloadFile = new FileReference ();
				downloadFile.addListener (downloadFileListener);
				downloadFile.download (url, selectedFile.attributes.name);
			};
			break;
		
	};
};

function loadUploadList () 
{
	filesXml = new XML ();
	filesXml.ignoreWhite = true;
	filesXml.onLoad = function (success:Boolean) 
	{
		if (success) 
		{
			downloadFilesList.dataProvider = this.firstChild.childNodes;
		} 
		else 
		{
			trace2 ("Error unable to load download file list");
		};
	};

	filesXml.load (downloadListUrl);
};

function uploadQueueChanged (eventObj:Object) 
{
	switch (eventObj.type) 
	{
	
		case "start":
			uploadProgressBar.visible = true;
			uploadProgressBar.label = "Uploading Files ...";
			uploadButton.enabled = false;
			break;
		
		case "progress":
			uploadProgressBar.setProgress (eventObj.percent, 100);
			break;

		case "complete":
			uploadProgressBar.label = "Upload Complete";
			uploadButton.enabled = true;
			clearButton.dispatchEvent ({type:"click"});
			loadUploadList ();
			break;

		case "error":
			uploadButton.enabled = true;
			showAlert (eventObj.info, "Error");
			break;
		
	};
};

function downloadListChanged (eventObj:Object) 
{
	downloadButton.enabled = eventObj.target.selectedItem != null;
	var url:String = eventObj.target.selectedItem.attributes.path;
	photoPane.url = url;
};

main ();