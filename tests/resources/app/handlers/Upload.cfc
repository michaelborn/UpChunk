/**
 * I handle UpChunk test uploads
 */
component extends="coldbox.system.EventHandler" {

    private function upload( event, rc, prc ){
        if ( event.getValue( "file", "" ) == "" ){
			throw( "Upload seems to be missing; did you browse directly to this endpoint?" );
		}

        /**
         * Spin up vendor-specifc implementation and process upload
         */
		var UpChunk = wirebox.getInstance( prc.vendor );
		var results = UpChunk.handleUpload( event );

		if ( results.partial ){
			// don't try to process a "file upload" when it's only a chunk upload!
			event.renderData(
				type = "JSON",
				data = { "error" : false, "messages" : [] },
				statusCode = 206
			).noExecution();
		} else {
			event.renderData(
				type = "JSON",
				data = { "error" : false, "finalFile" : results.finalFile },
				statusCode = 200
			).noExecution();
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
		prc.vendor = "DropZone@UpChunk";

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
		prc.vendor = "Uploader@UpChunk";

        upload( argumentCollection = arguments );
	}

}