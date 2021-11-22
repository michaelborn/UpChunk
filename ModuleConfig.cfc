component {
    
    this.name = "UpChunk";
    this.author = "Michael Born";
    this.webUrl = "https://github.com/michaelborn/UpChunk";

    function configure() {
        settings = {
            /**
             * Temporary directory used for storing file chunks during upload.
             */
            tempDir : "./tmp/",

            /**
             * Set the final resting place of uploaded files.
             */
            uploadDir : "/resources/assets/uploads/",

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

        interceptorSettings = {
            customInterceptionPoints = "UpChunk_preUpload,UpChunk_postUpload"
        };

        binder.map( "DropZone@upchunk" )
                .to( "upchunk.models.vendors.DropZone" )
                .asSingleton();

        binder.map( "UpChunk@upchunk" )
                .to( "upchunk.models.vendors.DropZone" )
                .asSingleton();
    }

    function onLoad(){
        var fileSeparator = createObject("java","java.io.File").separator;
        if ( right( settings.tempDir, 1) != fileSeparator ){
            settings.tempDir &= fileSeparator;
        }
        if ( right( settings.uploadDir, 1) != fileSeparator ){
            settings.uploadDir &= fileSeparator;
        }
    }
}