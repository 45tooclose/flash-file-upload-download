/**
	_________________________________________________________________________________________________________________

	PhotoPane displays an image with a progress bar in a scrollpane.

	@class PhotoPane (public)
	@author Oinam Software, http://www.oinam.com/
	@version 1.00 (8/24/2005)
	@availability 6.0+
	@usage <code>new PhotoPane ();</code>
	@example
		<code>
			photoPane = new PhotoPane ();
		</code>

	__________________________________________________________________________________________________________________

	*/

import mx.controls.*;
import mx.core.*;
import mx.utils.Delegate;
import mx.containers.*;

class com.oinam.controls.PhotoPane 
	extends UIComponent
{

	// static attributes
	static public var symbolName:String = "__Packages.com.oinam.controls.PhotoPane";
	static public var symbolOwner:Object = PhotoPane;
	static private var classRegistered:Boolean = Object.registerClass (symbolName, PhotoPane);
	static private var mergedClipParameters:Boolean = UIObject.mergeClipParameters (PhotoPane.prototype.clipParameters, UIComponent.prototype.clipParameters);

	// static methods

	//
	//
	// class attributes
	//
	//
	private var className:String = "PhotoPane";
	private var clipParameters:Object = {url:1};

	private var __url:String = null;

	private var contentPane:ScrollPane = null;
	private var progressBar:ProgressBar = null;
	private var contentMC:MovieClip = null;
	private var loader:MovieClipLoader = null;

	/**
		PhotoPane's constructor function

		@example
			<code>
				new PhotoPane ();
			</code>

		*/
	public function PhotoPane () 
	{
		super ();
	};

	/*__________________________________________________________________________________________________________________

		Public Methods
		__________________________________________________________________________________________________________________
	*/

	// for tracing purposes.
	public function toString ():String 
	{
		return "[object com.oinam.controls.PhotoPane]";
	};

	/**
		Method cleans up all external references in the instance. 

		@method dispose (public)
		@usage <code>photoPane.dispose ();</code>
		@return Void
		@example
			<code>
				photoPane.dispose ();
			</code>

		*/
	public function dispose ():Void
	{
		
	};

	/*__________________________________________________________________________________________________________________

		Private Methods
		__________________________________________________________________________________________________________________
	*/
	/*
		Method initializes the photo pane component.
		*/
	private function init ():Void
	{
		super.init ();

		loader = new MovieClipLoader ();
		loader.addListener (this);
	};

	/*
		Method creates children of the photo pane component.
		*/
	private function createChildren ():Void
	{
		super.createChildren ();

		var initObj:Object = new Object ();
		initObj.contentPath = UIComponent.symbolName;

		attachMovie (ScrollPane.symbolName, "contentPane", 0, initObj);

		var content:MovieClip = contentPane.content;
		contentMC = content.createEmptyMovieClip ("contentMC", 0);

		contentPane.hScrollPolicy = "auto";
		contentPane.vScrollPolicy = "auto";

		attachMovie (ProgressBar.symbolName, "progressBar", 1);
		progressBar.mode = "manual";
		progressBar.indeterminate = false;
		progressBar.label = "";
		progressBar.visible = false;

	};

	/*
		Method redraws the photo pane component.
		*/
	private function draw ():Void
	{
		super.draw ();

		if (url != null) 
		{
			loader.loadClip (url, contentMC);
		} 
		else 
		{
			loader.unloadClip (contentMC);
		};
	};

	/*
		Method relayouts the photo pane component.
		*/
	private function size ():Void
	{
		super.size ();

		var progressWidth:Number = 80*width/100;
		var progressHeight:Number = 20*height/100;

		contentPane.setSize (width, height);
		progressBar.setSize (progressWidth, progressHeight);

		progressBar.move (width/2 - progressWidth/2, height/2 - progressHeight/2);
	};

	/*__________________________________________________________________________________________________________________
	
		Loader Events
		__________________________________________________________________________________________________________________
	*/
	/*
		Method reveals the progress bar.
		*/
	private function onLoadStart (targetMC:MovieClip):Void
	{
		setProgress (0);
		progressBar.visible = true;
		progressBar.redraw (true);
	};

	/*
		Method update the progress bar percent.
		*/
	private function onLoadProgress (targetMC:MovieClip, bytesLoaded:Number, bytesTotal:Number):Void
	{
		setProgress (bytesLoaded/bytesTotal*100);
	};

	/*
		Method hides the progress bar and relayouts the component.
		*/
	private function onLoadInit (targetMC:MovieClip):Void
	{
		size ();
		contentPane.redraw (true);
		progressBar.visible = false;
	};

	/*
		Method displays the error in the progress bar label.
		*/
	private function onLoadError (targetMC:MovieClip, errorCode:String):Void
	{
		progressBar.label = errorCode;
	};

	/*
		Method changes the progress displayed in the progress bar.
		*/
	private function setProgress (progress:Number):Void
	{
		progressBar.setProgress (progress, 100);
	};

	/*__________________________________________________________________________________________________________________
	
		Properties
		__________________________________________________________________________________________________________________
	*/
	/**
		Property indicates the url of the photo pane component
	
		@property url (public)
		@return String
		@example 
	
		*/
	public function get url ():String
	{
		return (__url);
	};
	
	public function set url (url:String):Void
	{
		if (__url != url) 
		{
			__url = url;
			invalidate ();
		};
	};

};