/**
 * Defines an interface to handle a particular chunk upload vendor.
 * 
 */
interface{

    /**
     * Process a non-chunked file upload
     */
    function handleUpload( required struct upload );

    /**
     * Process a file upload chunked
     */
    function handleChunkedUpload( required struct upload );

    /**
     * Collate all chunks for the current chunked upload into a single file
     * and move to location defined in module settings.
     */
    public void function mergeChunks( required struct upload );
}