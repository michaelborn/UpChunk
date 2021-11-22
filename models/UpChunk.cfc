/**
 * Handles file uploads (chunked and non-chunked) from DropZone
 */
component extends="upchunk.models.AbstractUploader" implements="upchunk.models.IChunk" singleton {

    /**
     * Inspect the current coldbox event
     * and return info about the current upload (if it is an upload.)
     */
    public struct function parseUpload( required struct memento ){
        var defaultValidationError = "`{field}` parameter is required for chunked uploads.";
        if ( !arguments.memento.keyExists( settings.fields.filename ) ){
            throw( message = replace( defaultValidationError, '{field}', settings.fields.filename, "ALL" ) );
        }
        if ( !arguments.memento.keyExists( settings.fields.file ) ){
            throw( message = replace( defaultValidationError, '{field}', settings.fields.file, "ALL" ) );
        }

        var chunkIndex = arguments.memento.keyExists( settings.fields.chunkIndex ) ? arguments.memento[ settings.fields.chunkIndex ] : -1;
        var totalChunks = arguments.memento.keyExists( settings.fields.totalChunks ) ? arguments.memento[ settings.fields.totalChunks ] : 0;

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
            isFinalChunk : totalChunks == ( chunkIndex + 1 )
        };
    }

}
