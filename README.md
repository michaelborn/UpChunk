# UpChunk

![Cookie chunks](cookie.png)

[![All Contributors](https://img.shields.io/github/contributors/michaelborn/UpChunk?style=flat-square)](https://github.com/michaelborn/DocBox/graphs/contributors)
|
[![Master Branch Build Status](https://img.shields.io/travis/michaelborn/UpChunk/master.svg?style=flat-square&label=master)](https://travis-ci.org/michaelborn/UpChunk) 
| 
[![Development Branch Build Status](https://img.shields.io/travis/michaelborn/UpChunk/development.svg?style=flat-square&label=development)](https://travis-ci.org/michaelborn/UpChunk)
|
![Latest release](https://img.shields.io/github/v/release/michaelborn/UpChunk?style=flat-square)
</center>

## Features

* Chunked uploads
* Non-chunked uploads
* DropZone support
* Uploader.js support
* Easily extendable for other vendors

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
      uploadDir : "resources/assets/uploads/"
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

### Extending UpChunk

For more complex scenarios, you may find it necessary to extend UpChunk.

You can do this by overwriting any or all of the UpChunk methods `handleUpload()`, `handleNormalUpload()` or `handleChunkedUpload()` defined in `AbstractUploader.cfc`:

```js
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

## TODO

* [Pull original filename from form field parts](https://stackoverflow.com/questions/14143076/storing-file-name-when-uploading-using-coldfusion)
* Add TestBox specs:
  * integration test chunked uploads
  * integration test non-chunked uploads
  * unit test vendor providers

## The Good News

> For all have sinned, and come short of the glory of God ([Romans 3:23](https://www.kingjamesbibleonline.org/Romans-3-23/))

> But God commendeth his love toward us, in that, while we were yet sinners, Christ died for us. ([Romans 5:8](https://www.kingjamesbibleonline.org/Romans-5-8))

> That if thou shalt confess with thy mouth the Lord Jesus, and shalt believe in thine heart that God hath raised him from the dead, thou shalt be saved. ([Romans 10:9](https://www.kingjamesbibleonline.org/Romans-10-9/))
 
## Repository

Copyright 2021 (and on) - [Michael Born](https://michaelborn.me/)

* [Homepage](https://github.com/michaelborn/UpChunk)
* [Issue Tracker](https://github.com/michaelborn/UpChunk/issues)
* [New BSD License](https://github.com/michaelborn/UpChunk/blob/master/LICENSE.txt)