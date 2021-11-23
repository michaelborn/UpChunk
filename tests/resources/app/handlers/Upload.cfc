/**
 * I handle UpChunk test uploads
 */
component extends="Main" {

    private function upload( event, rc, prc ){
        if ( event.getValue( "fileUpload", "" ) == "" ){
            throw( "Upload seems to be missing; did you browse directly to this endpoint?" );
        }

        /**
         * Spin up vendor-specifc implementation and process upload
         */
        var UpChunk = wirebox.getInstance( prc.vendor );
        var results = UpChunk.handleUpload( arguments.rc );

        if ( results.isPartial ){
            // don't try to process a "file upload" when it's only a chunk upload!
            event.renderData(
                type = "JSON",
                data = { "error" : false, "messages" : [] },
                statusCode = 206
            );
        } else {
            event.renderData(
                type = "JSON",
                data = { "error" : false, "finalFile" : results.finalFile },
                statusCode = 200
            );
        }
    }

    function index( rc, prc, event ){
    }
    
    /**
     * Dropzone.js vendor test
     *
     * @rc 
     * @prc 
     * @event 
     */
    function dropzone( rc, prc, event ){
        // dropzone now uses the default vendor, with custom `fields` module settings
        prc.vendor = "UpChunk@upchunk";
        upload( argumentCollection = arguments );
    }

    /**
     * Uploader.js vendor test
     *
     * @rc 
     * @prc 
     * @event 
     */
    function uploader( rc, prc, event ){
        prc.vendor = "Uploader@upchunk";

        upload( argumentCollection = arguments );
    }

}