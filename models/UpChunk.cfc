/**
 * Handles chunked file uploads and normal file uploads
 * in a vendor-generic (abstract) manner.
 *
 * To create a vendor implementation (for FineUploader, for example)
 * extend this component ( `UpChunk.models.AbstractUploader` and override the `parseUpload()` method.
 */
component
    implements="IChunk"
    accessors ="true"
    singleton
{

    property name="settings"           inject="coldbox:moduleSettings:UpChunk";
    property name="interceptorService" inject="coldbox:interceptorService";
    property name="log"                inject="logbox:logger:{this}";

    /**
     * OS-safe file separator
     */
    property name="fileSeparator" type="string";

    public component function init(){
        setFileSeparator( createObject( "java", "java.io.File" ).separator );
        return this;
    }

    /**
     * Inspect the provided form scope and return info about the current upload (if it is an upload.)
     * 
     * @memento the form scope containing upload parameters. You can pass this from a handler via `UpChunk.handleUpload( arguments.rc )`
     */
    public struct function parseUpload( required struct memento ){

        // TODO: Move to extendable `validateUpload()` method
        var defaultValidationError = "`{field}` parameter is required for chunked uploads.";
        if ( !arguments.memento.keyExists( settings.fields.filename ) ){
            throw( message = replace( defaultValidationError, '{field}', settings.fields.filename, "ALL" ) );
        }
        if ( !arguments.memento.keyExists( settings.fields.file ) ){
            throw( message = replace( defaultValidationError, '{field}', settings.fields.file, "ALL" ) );
        }

        var chunkIndex = arguments.memento.keyExists( settings.fields.chunkIndex ) ? arguments.memento[ settings.fields.chunkIndex ] : -1;
        var totalChunks = arguments.memento.keyExists( settings.fields.totalChunks ) ? arguments.memento[ settings.fields.totalChunks ] : 0;

        if ( settings.isIndexZeroBased ){
            chunkIndex = chunkIndex + 1;
        }

        return {
            // is the current request a chunked upload?
            isChunked    : arguments.memento.keyExists( settings.fields.chunkIndex ),
            // what is the uploaded file?
            file         : arguments.memento[ settings.fields.file ],
            // what is the original filename?
            original     : arguments.memento[ settings.fields.filename ],
            // An id unique to each chunked file upload session for tracking and organized groups of chunks.
            uuid         : arguments.memento.keyExists( settings.fields.uniqueId ) ? arguments.memento[ settings.fields.uniqueId ] : createUUID(),
            // what chunk index is this current request?
            index        : chunkIndex,
            // is this the last chunk in the upload
            isFinalChunk : totalChunks <= chunkIndex
        };
    }

    /**
     * Begin the upload process - wraps chunked and non-chunked file uploads
     *
     * @memento the form scope containing upload parameters. You can pass this from a handler via `UpChunk.handleUpload( arguments.rc )`
     */
    public struct function handleUpload( required struct memento ){
        // get chunk info
        var upload = parseUpload( memento = arguments.memento );
        if ( log.canDebug() ) {
            log.debug( "Parsed upload:", upload );
        }
        interceptorService.announce( "UpChunk_preUpload", upload );

        if ( upload.isChunked ) {
            var uploadedFile = handleChunkedUpload( upload );
        } else {
            var uploadedFile = handleNormalUpload( upload );
        }

        /**
         * The inability to introspect a file upload
         * means that the original filename needs to be passed
         * via frontend user scripts.
         *
         * Here is where that filename is utilized to correct the file extension
         * and set the final filename.
         */
        if ( listLast( uploadedFile, "." ) == "upload" ) {
            var fileExtension = listLast( upload.original, "." );
            var finalFile     = replace(
                uploadedFile,
                ".upload",
                ".#fileExtension#"
            );
            fileMove( uploadedFile, finalFile );
        } else {
            var finalFile = uploadedFile;
        }

        interceptorService.announce( "UpChunk_postUpload", upload );

        return {
            isPartial: upload.isChunked && !upload.isFinalChunk,
            finalFile: finalFile
        };
    }

    /**
     * Handle a non-chunked file upload.
     *
     * @upload {Struct} parameters for upload, parsed from event and defined in vendor parseUpload() method
     */
    public string function handleNormalUpload( required struct upload ){
        fileMove(
            arguments.upload.file,
            settings.uploadDir
        );
        var filename = listLast(
            arguments.upload.file,
            getFileSeparator()
        );
        return "#settings.uploadDir##filename#";
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
     *
     * @upload {Struct} parameters for upload, parsed from event and defined in vendor parseUpload() method
     */
    public string function handleChunkedUpload( required struct upload ){
        arguments.upload.chunkDir = "#settings.tempDir##arguments.upload.uuid##getFileSeparator()#";
        if ( !directoryExists( arguments.upload.chunkDir ) ) {
            directoryCreate( arguments.upload.chunkDir );
        }
        var chunkFile = "#arguments.upload.chunkDir##arguments.upload.index#";
        fileMove( arguments.upload.file, chunkFile );

        if ( arguments.upload.isFinalChunk ) {
            return mergeChunks( arguments.upload );
        } else {
            return chunkFile;
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
        var extension = listLast( arguments.upload.original, "." );

        // get final location from settings... preferably a cbfs location.
        if ( !directoryExists( settings.uploadDir ) ) {
            directoryCreate( settings.uploadDir );
        }
        var finalFile = "#settings.uploadDir##arguments.upload.uuid#.#extension#";
        var allChunks = directoryList(
            arguments.upload.chunkDir,
            false,
            "name",
            "*",
            "name asc",
            "file"
        );
        // if ( arrayLen( allChunks ) != rc.dztotalchunkcount ){
        //     throw(
        //         message = "Invalid upload; cannot continue. The number of uploaded chunks does not match the supposed chunk count.",
        //         type = "MissingChunkException",
        //         detail = serializeJSON( { "chunksOnDisk" : arrayLen( allChunks ), "total chunk count": rc.dztotalchunkcount } )
        //     );
        // }

        if ( log.canDebug() ) {
            log.debug( "Merging #arrayLen( allChunks )# upload chunks found in #arguments.upload.chunkDir#" );
        }

        /**
         * chunk order is EXTREMELY important.
         * If a single chunk is appended to the final file out of order, the file will be corrupted.
         */
        arraySort( allChunks, "numeric", "asc" );
        for ( var filename in allChunks ) {
            var chunkFile = "#upload.chunkDir##filename#";
            if ( log.canDebug() ) {
                log.debug( "Moving chunk #chunkfile# to #finalFile#, file exists: #fileExists( chunkFile )#" );
            }
            if ( !fileExists( chunkFile ) ) {
                fileWrite(
                    finalFile,
                    fileReadBinary( chunkFile )
                );
            } else {
                // For ACF compat, this may need to be a file Object.
                fileAppend(
                    finalFile,
                    fileReadBinary( chunkFile )
                );
            }
        }
        directoryDelete( arguments.upload.chunkDir, true );

        return finalFile;
    }

}
