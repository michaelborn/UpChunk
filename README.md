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
2. Configure UpChunk by placing a `moduleSettings.cbfs` structure in `config/Coldbox.cfc`:

```js
moduleSettings = {
    "cbfs" : {
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

3. In your ColdBox handler, inject and init your vendor of choice. Make sure to pass the RequestContext for help grabbing the request parameters.

```js
function upload( event, rc, prc ){
    var UpChunk = wirebox.getInstance( "DropZone@UpChunk" );
    var finalFile = UpChunk.handleUpload( arguments.event );

    writeOutput( "Uploaded file to #finalFile#" );
}
```