# UpChunk

![Cookie chunks](https://raw.githubusercontent.com/michaelborn/UpChunk/master/cookie.png)

[![All Contributors](https://img.shields.io/github/contributors/michaelborn/UpChunk?style=flat-square)](https://github.com/michaelborn/upchunk/graphs/contributors)
|
![Release](https://github.com/michaelborn/upchunk/actions/workflows/release.yml/badge.svg)
</center>

## Features

* Chunked uploads 🥧
* Non-chunked uploads 🍪
* DropZone support ✅
* Uploader.js support ✅
* Easily extendable for other vendors 🔧
* Supports Adobe 2016, 2018, 2021, and Lucee 5.3.8+ 📒

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
       * what field names should we look for in the rc memento?
       */
      "fields" : {
          // see #Configuration
      }
    }
};
```

By default, UpChunk ships with DropZone-compatible `fields` config. See #Configuration for more details.

3. In your ColdBox handler, inject and init your vendor of choice, like `DropZone@UpChunk`.
4. Run the `handleUpload()` method, making sure to pass the current `rc` object:

```js
function upload( event, rc, prc ){
    var UpChunk = wirebox.getInstance( "UpChunk@upchunk" );
    var finalFile = UpChunk.handleUpload( arguments.rc );

    writeOutput( "Uploaded file to #finalFile#" );
}
```

## How It Works

UpChunk primarily works in three steps:

1. Parsing the upload. UpChunk reads the provided `rc` memento to determine what sort of upload this is (chunked or non-chunked, i.e. an entire file) and the various parameters specific to the upload, such as which field has the binary, what filename to use, the current chunk number, etc.
2. Uploading the file or file chunk. If this is an entire file, the upload is complete and UpChunk responds with a result struct.
3. For chunked uploads, the final chunk uploaded triggers a compilation process. UpChunk will save the final chunk, and iterate through the entire set of chunks for the current upload, appending each to the final file. Once the file is complete, UpChunk responds with a result struct.
## Configuration

### Uploader Configuration

Configuration for[simple-uploader.js](https://github.com/simple-uploader/Uploader).

> **Note:** simple-uploader.js [utilizes base 1 numbering for `chunkNumber` and `totalChunks`](https://github.com/simple-uploader/Uploader#how-do-i-set-it-up-with-my-server). For this reason, we need to set `isIndexZeroBased: false`.


> **Note:** simple-uploader.js supports a custom `file` parameter name in their frontend options. If you have changed this, please ensure that you change the `fileUpload` value below 👇 as well.

```js
moduleSettings["UpChunk"] = {
    "isIndexZeroBased" : false,
   /**
    * what field names should we look for in the rc memento?
    */
    "fields" : {
      // points to the location of the uploaded binary
      "file"       : "file",
      // filename, helpful for creating a user-friendly final filename
      "filename"   : "filename",
      // An id unique to each chunked file upload session for tracking and organized groups of chunks.
      "uniqueId"   : "identifier",
      // what chunk index is this current request?
      "chunkIndex" : "chunkNumber",
      // total number of upload chunks, helps determine when the file is fully uploaded
      "totalChunks": "totalChunks"
    }
};
```

### DropZone Configuration

Here's the configuration for [DropZone.js](https://www.dropzone.dev/js/) support.

> **Note:** DropZone supports a custom `file` parameter name in their frontend options. If you have changed this, please ensure that you change the `fileUpload` value below 👇 as well.

```js
moduleSettings["UpChunk"] = {
   /**
    * what field names should we look for in the rc memento?
    */
    "fields" : {
      // points to the location of the uploaded binary
      "file"       : "fileUpload",
      // filename, helpful for creating a user-friendly final filename
      "filename"   : "filename",
      // An id unique to each chunked file upload session for tracking and organized groups of chunks.
      "uniqueId"   : "dzuuid",
      // what chunk index is this current request?
      "chunkIndex" : "dzchunkindex",
      // total number of upload chunks, helps determine when the file is fully uploaded
      "totalChunks": "dztotalchunkcount"
    }
};
```

## UpChunk Vendors

UpChunk supports the concept of "vendors", i.e. components which perform additional work to add support for a specific javascript uploader vendor, such as `simple-uploader.js` via `Uploader@upchunk`.

Feel free to write your own upload vendor, but it *must* extend `UpChunk.models.UpChunk`:

```js
component extends="UpChunk.models.UpChunk" {

}
```

Feel free to overload any of the methods outlined in the `IChunk.cfc` interface:

```js
/**
 * Defines an interface to handle a particular chunk upload vendor.
 *
 */
interface {

    /**
     * Inspect the provided form scope and return info about the current upload (if it is an upload.)
     * 
     * @memento the form scope containing upload parameters. You can pass this from a handler via `UpChunk.handleUpload( arguments.rc )`
     */
    public struct function parseUpload( required struct memento );

    /**
     * Process a non-chunked file upload
     * Runs vendor `parseUpload()` event to retrieve upload parameters
     * Calls {@see handleChunkedUpload} or {@see handleNormalUpload}, depending on upload.isChunked
     */
    public struct function handleUpload( required struct memento );

    /**
     * Process a file upload chunked
     * @upload {Struct} parameters for upload, parsed from event and defined in vendor parseUpload() method
     */
    public string function handleChunkedUpload( required struct upload );

    /**
     * Handle final merging of all upload chunks into a single file
     * Executed only on upload of last file chunk.
     *
     * @upload {Struct} parameters for upload, parsed from event and defined in vendor parseUpload() method
     * @returns String - returns path to completed file
     */
    public string function mergeChunks( required struct upload );

}
```

Once you've written your vendor, you simply inject it and use it like the standard `UpChunk` object:

```js
var upload = getInstance( "MyCustomUploadVendor" )
                .handleUpload();
```

In this example ☝, the `handleUpload()` method in UpChunk will call `parseUpload()` to check for a chunked or non-chunked upload, and will then process the upload as normal.

Though if you need a new feature not currently supported, would you consider [opening a new issue](https://github.com/michaelborn/UpChunk/issues)?

### Extending UpChunk

For more complex scenarios, you may find it necessary to extend UpChunk.

You can do this by overwriting any or all of the UpChunk methods `handleUpload()`, `handleNormalUpload()` or `handleChunkedUpload()` defined in `UpChunk.cfc`:

```js
/**
 * FunkyUploader
 * Handle abnormal Funky uploads
 */
component extends="UpChunk.models.UpChunk" {

   /**
    * FunkyUploads does a funny way of chunking,
    * so we need to massage the chunks a bit to get the upload working right.
    */
   function handleChunkedUpload( required struct upload ){
       // do funky stuff
   }
}
```

## CONTRIBUTING

* All contributions welcome!
* Feel free to write a test, fix a README typo, or add a new vendor
* Take a look at the `vendors/DropZone.cfc` to get started with a new upload vendor

To get started hacking on UpChunk:

1. Clone the module - `git clone git@github.com:michaelborn/UpChunk.git`
2. Install dependencies - `box install`
3. Run tests - `cd tests && box testbox run`
4. Write code
5. Run tests
6. Push up a pull request

## TODO

* [Pull original filename from form field parts](https://stackoverflow.com/questions/14143076/storing-file-name-when-uploading-using-coldfusion)
* Add docs for more upload vendors

## The Good News

> For all have sinned, and come short of the glory of God ([Romans 3:23](https://www.kingjamesbibleonline.org/Romans-3-23/))

> But God commendeth his love toward us, in that, while we were yet sinners, Christ died for us. ([Romans 5:8](https://www.kingjamesbibleonline.org/Romans-5-8))

> That if thou shalt confess with thy mouth the Lord Jesus, and shalt believe in thine heart that God hath raised him from the dead, thou shalt be saved. ([Romans 10:9](https://www.kingjamesbibleonline.org/Romans-10-9/))
 
## Repository

Copyright 2021 (and on) - [Michael Born](https://michaelborn.me/)

* [Homepage](https://github.com/michaelborn/UpChunk)
* [Issue Tracker](https://github.com/michaelborn/UpChunk/issues)
* [New BSD License](https://github.com/michaelborn/UpChunk/blob/master/LICENSE)