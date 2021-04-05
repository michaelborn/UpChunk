# UpChunk

[![All Contributors](https://img.shields.io/github/contributors/michaelborn/UpChunk?style=flat-square)](https://github.com/michaelborn/DocBox/graphs/contributors)
|
[![Master Branch Build Status](https://img.shields.io/travis/michaelborn/UpChunk/master.svg?style=flat-square&label=master)](https://travis-ci.org/michaelborn/UpChunk) 
| 
[![Development Branch Build Status](https://img.shields.io/travis/michaelborn/UpChunk/development.svg?style=flat-square&label=development)](https://travis-ci.org/michaelborn/UpChunk)
|
![Latest release](https://img.shields.io/github/v/release/michaelborn/UpChunk?style=flat-square)

## Getting Started

1. Install this module into your ColdBox app: `box install UpChunk`
2. Configure UpChunk by placing a `moduleSettings.UpChunk` structure in `config/Coldbox.cfc`:

```js
moduleSettings = {
    UpChunk : {
      /**
       * Temporary directory used for storing file chunks during upload.
       */
      tempDir : "./tmp/",

      /**
       * Set the final resting place of uploaded files.
       */
      uploadDir : "resources/assets/uploads/",

      /**
       * Wirebox ID that points to the vendor CFC to use for uploads.
       * 
       * You can write and use your own custom upload vendor...
       * ...but it must implement UpChunk.models.iChunk and extend UpChunk.models.AbstractUploader.
       */
      strategy : "DropZone@UpChunk"
    }
};
```

3. In your ColdBox handler, inject and init your vendor of choice.
4. Run the `handleUpload()` method, making sure to pass the current Event object:

```js
function upload( event, rc, prc ){
    var UpChunk = wirebox.getInstance( "DropZone@UpChunk" );
    var finalFile = UpChunk.handleUpload( arguments.event );

    writeOutput( "Uploaded file to #finalFile#" );
}
```

## Extending UpChunk

You can write and use your own custom upload vendor, but it *must* extend `UpChunk.models.AbstractUploader` (which also implements `UpChunk.models.iChunk`.)

```js
component extends="UpChunk.models.AbstractUploader" {

}
```

Then add a `parseUpload()` method which takes in the RequestContext object and returns a struct of info about the current upload:

```js
/**
	 * Inspect the current coldbox event
	 * and return info about the current upload (if it is an upload.)
	 */
	public struct function parseUpload( required struct event ){
		return {
			// is the current request a chunked upload?
			isChunked    : arguments.event.getValue( "dzchunkindex", "" ) != "",
			// what is the upload filename?
			filename     : event.getValue( "file" ),
			// An id unique to each chunked file upload session for tracking and organized groups of chunks.
			uuid         : event.getValue( "dzuuid", "" ),
			// what chunk index is this current request?
			index        : arguments.event.getValue( "dzchunkindex", -1 ),
			// is this the last chunk in the upload
			isFinalChunk : arguments.event.getValue( "dztotalchunkcount", 0 ) == (
				arguments.event.getValue( "dzchunkindex", -1 ) + 1
			)
		};
	}
```

This will vary depending on the parameters passed in the request. DropZone prepends all chunking parameters with `dz`, for instance.

For more complex scenarios, you may find it necessary to overwrite the parent `handleUpload()`, `handleNormalUpload()` or `handleChunkedUpload()` methods defined in `AbstractUploader.cfc`:

```
/**
 * FunkyUploader
 * Handle abnormal Funky uploads
 */
component extends="UpChunk.models.AbstractUploader" {

   /**
    * FunkyUploads does a funny way of chunking,
    * so we need to massage the chunks a bit to get the upload working right.
    */
   function handleChunkedUpload( required struct upload ){
       // do funky stuff
   }
}
```