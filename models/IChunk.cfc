/**
 * Defines an interface to handle a particular chunk upload vendor.
 * 
 */
interface{

    /**
     * Process a non-chunked file upload
     */
    function handleUpload( required struct event );

    /**
     * Process a file upload chunked
     */
    function handleChunkedUpload( required struct upload );

    /**
     * Handle final merging of all upload chunks into a single file
     * Executed only on upload of last file chunk.
     *
     * @upload 
     * @returns String - returns path to completed file
     */
    public string function mergeChunks( required struct upload );
}