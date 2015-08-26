/**
	_________________________________________________________________________________________________________________

	UploadQueue uploads multiple files selected by a user to the remote server and dispatches unified progress events
	for them.

	@class UploadQueue (public)
	@author Oinam Software, http://www.oinam.com/
	@version 1.00 (7/17/2005)
	@availability 6.0+
	@usage <code>new UploadQueue ();</code>
	@example
		<code>
			uploadQueue = new UploadQueue ("uploadFile.cfm");

			var delegate:Function = Delegate.create (this, uploadQueueChanged);
			uploadQueue.addEventListener ("start", delegate);
			uploadQueue.addEventListener ("progress", delegate);
			uploadQueue.addEventListener ("complete", delegate);
			uploadQueue.addEventListener ("error", delegate);

			uploadQueue.start (filesToUpload);

			function uploadQueueChanged (eventObj:Object)
			{
				trace ("uploadQueueChanged : " + eventObj.type);
			};
		</code>

	__________________________________________________________________________________________________________________

	*/

import flash.net.*;
import mx.events.*;

class com.oinam.util.UploadQueue 
{

	// static attributes
	public static var symbolName:String = "UploadQueue";
	static private var classRegistered = EventDispatcher.initialize (UploadQueue.prototype);

	// static methods

	// class attributes
	// array of file references objects selected by the user
	private var files:Array = null;

	// the file index that is currently being uploaded.
	private var currentFile:Number = null;

	// the url on the server to which the file is to be uploaded.
	private var url:String = null;

	// EventDispatcher mixin methods
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;

	// UploadQueue's constructor function
	public function UploadQueue (url:String) 
	{
		super ();

		this.url = url;
	};

	// for tracing purposes.
	public function toString ():String 
	{
		return "[object UploadQueue]";
	};

	/**
		Method starts the upload queue.
	
		@method start (public)
		@usage <code>uploadQueue.start (files);</code>
		@param files (Array) The files to upload to the server.
		@return Void
		@example
			<code>
				uploadQueue.start (myFiles);
			</code>
	
		*/
	public function start (files:Array):Void
	{
		this.files = files;
		currentFile = 0;

		dispatchEvent ({type:"start"});
		uploadNext ();
	};

	/*__________________________________________________________________________________________________________________
	
		Private Methods
		__________________________________________________________________________________________________________________
	*/
	/*
		Method uploads the next file in the queue to the server. If all files have loaded the complete event is dispatched to listeners.
		*/
	private function uploadNext ():Void
	{
		if (currentFile < files.length) 
		{
			var oldFileReference:FileReference = files [currentFile - 1];
			if (oldFileReference != null) 
			{
				oldFileReference.removeListener (this);
			};

			var fileReference:FileReference = files [currentFile];		
			fileReference.addListener (this);
			fileReference.upload (url);
		} 
		else 
		{
			dispatchEvent ({type:"complete"});
		};
	};

	/*__________________________________________________________________________________________________________________
	
		Handle events from the individual FileReference objects.
		__________________________________________________________________________________________________________________
	*/
	/*
		Method dispatches the unified progress event for the entire upload queue.
		*/
	private function onProgress (fileRef:FileReference, bytesLoaded:Number, bytesTotal:Number):Void
	{
		var currentPercent:Number = bytesLoaded/bytesTotal*100;
		var totalFiles:Number = files.length;
		var percentComplete:Number = currentFile/totalFiles*100
		var unitPercent:Number = 1/totalFiles*100;
		var unitPercentComplete:Number = currentPercent*unitPercent/100;
		var currentPercentTotal:Number = (percentComplete + unitPercentComplete);

		dispatchEvent ({type:"progress", percent:currentPercentTotal});
	};

	/*
		Method completes the next file in the upload queue.
		*/
	private function onComplete (fileRef:FileReference):Void
	{
		currentFile++;
		uploadNext ();
	};

	/*
		Dispatches an error event with the received error code.
		*/
	private function onSecurityError (fileRef:FileReference, errorString:String):Void
	{
		onError (errorString);
	};

	/*
		Dispatches an error event with the received error code.
		*/
	private function onIOError (fileRef:FileReference):Void
	{
		onError ("An IO Error occurred.");
	};

	/*
		Dispatches an error event with the received error code.
		*/
	private function onHTTPError (fileRef:FileReference, httpError:String):Void
	{
		onError ("HTTP Error, " + httpError + " occurred.");
	};

	/*
		Dispatches an error event with the received error code.
		*/
	private function onError (errorString:String):Void
	{
		dispatchEvent ({type:"error", info:errorString});
	};

};