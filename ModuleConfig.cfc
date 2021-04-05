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
            uploadDir : "resources/assets/uploads/",

            /**
             * Wirebox ID that points to the vendor CFC to use for uploads.
             * 
             * You can write and use your own custom upload vendor...
             * ...but it must implement UpChunk.models.iChunk and extend UpChunk.models.AbstractUploader.
             */
            strategy : "DropZone@UpChunk"

        };
    }

    function onLoad(){
        var fileSeparator = createObject("java","java.io.File").separator;
        if ( right( settings.tempDir, 1) != fileSeparator ){
            settings.tempDir &= fileSeparator;
        }
    }
}