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
            uploadDir : "/resources/assets/uploads/"
        };

        interceptorSettings = {
            customInterceptionPoints = "UpChunk_preUpload,UpChunk_postUpload"
        };

        binder.map( "DropZone@UpChunk" )
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