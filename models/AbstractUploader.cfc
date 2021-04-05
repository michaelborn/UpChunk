/**
 * Handles chunked file uploads and normal file uploads
 * in a vendor-generic (abstract) manner.
 * 
 * To create a vendor implementation (for FineUploader, for example)
 * extend this component ( `UpChunk.models.AbstractUploader` and override the `parseUpload()` method.
 */
component implements="UpChunk.models.IChunk" accessors="true" singleton{
    property name="settings" inject="coldbox:moduleSettings:UpChunk";

    /**
     * For logging purposes, note the upload vendor name.
     * i.e. "FineUploader" or "Dropzone"
     */
    property name="name" type="string";

    /**
     * OS-safe file separator
     */
    property name="fileSeparator" type="string";

    public component function init(){
        setFileSeparator( createObject("java","java.io.File").separator );
        return this;
    }

    /**
     * Begin the upload process - wraps chunked and non-chunked file uploads
     *
     * @event ColdBox RequestContext - used for grabbing request parameters and headers.
     */
    function handleUpload( required struct event ){
        controller.getInterceptorService().announce( "UpChunk_preUpload" );

        // get chunk info
        var upload = parseUpload( event = event );

        if ( upload.isChunked ) {
            handleChunkedUpload( upload );
        } else {
            handleNormalUpload( upload );
        }

        controller.getInterceptorService().announce( "UpChunk_postUpload" );
    }

    /**
     * Handle a non-chunked file upload.
     *
     * @upload 
     */
    function handleNormalUpload( required struct upload ) {

    }

    /**
     * Order of operations for a chunked upload:
     * 
     * 1. Detect that it's an upload. (and whether it's a chunked upload)
     * 2. validate that it's a valid upload
     * 3. upload/save the chunk to local temp
     * 4. may need to prevent standard event from processing.
     * 5. upload/save final chunk to local and merge all chunks together
     * 6. move finished file to final location determined by module settings
     * 7. run success interception point
     */
    function handleChunkedUpload( required struct upload ){
        
        var chunkDir = "#settings.tempDir##upload.uuid##getFileSeparator()#";
        if ( !directoryExists( chunkDir ) ){
            directoryCreate( chunkDir );
        }
        fileMove( rc.fileUpload, "#chunkDir##upload.index#" );

        if ( upload.isFinalChunk ){
            var finalFile = mergeChunks( upload ).file;
        } else {
            // don't try to process a "file upload" when it's only a chunk upload!
            event.renderData(
                type = "JSON",
                data = { "error" : false, "messages" : [] },
                statusCode = 206
            ).noExecution();
        }
    }

    /**
     * Handle final merging of all upload chunks into a single file
     * Executed only on upload of last file chunk.
     *
     * @upload 
     * @returns String - returns path to completed file
     */
    public string function mergeChunks( required struct upload ){
        var extension = listLast( upload.filename, "." );

        // get final location from settings... preferably a cbfs location.
        var finalFile = expandPath( "#variables.tmpDir##getFileSeparator()##createUUID()#.#extension#" );
        var allChunks = directoryList(
            path = chunkDir,
            recurse = false,
            listInfo = "name",
            type = "file",
            sort = "name asc"
        );

        var fileObject = fileOpen( finalFile, "write" );
        for( var chunkfile in allChunks ){
            fileAppend( fileObject, fileReadBinary( "#chunkDir##getFileSeparator()##chunkfile#" ) );
        }
        fileClose( fileObject );
        directoryDelete( chunkDir, true );

        return finalFile;
    }

}