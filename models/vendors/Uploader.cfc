/**
 * Handles file uploads (chunked and non-chunked) from Uploader
 * 
 * https://github.com/simple-uploader/Uploader
 */
component extends="UpChunk.models.AbstractUploader" singleton{
    /**
     * Inspect the current coldbox event
     * and return info about the current upload (if it is an upload.)
     */
    public struct function parseUpload( required struct event ){
        return {
            // is the current request a chunked upload?
            isChunked       : arguments.event.getValue( "totalChunks", "1" ) != "1",
            // what is the uploaded file?
            file            : event.getValue( "file" ),
            // what is the original filename?
            original        : event.getValue( "filename", "" ),
            // An id unique to each chunked file upload session for tracking and organized groups of chunks.
            uuid            : event.getValue( "identifier", "" ),
            // what chunk index is this current request?
            index           : arguments.event.getValue( "dzchunkindex", -1 ),
            // is this the last chunk in the upload
            isFinalChunk    : arguments.event.getValue( "totalChunks", 1 ) == arguments.event.getValue( "chunkNumber", 1 )
        };
    }

}
