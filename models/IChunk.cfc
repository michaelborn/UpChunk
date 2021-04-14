/**
 * Defines an interface to handle a particular chunk upload vendor.
 *
 */
interface {

    /**
     * Process a non-chunked file upload
     * Runs vendor `parseUpload()` event to retrieve upload parameters
     * Calls {@see handleChunkedUpload} or {@see handleNormalUpload}, depending on upload.isChunked
     */
    public struct function handleUpload( required struct event );

    /**
     * Process a file upload chunked
     * @upload {Struct} parameters for upload, parsed from event and defined in vendor parseUpload() method
     */
    public string function handleChunkedUpload( required struct upload );

    /**
     * Handle final merging of all upload chunks into a single file
     * Executed only on upload of last file chunk.
     *
     * @upload {Struct} parameters for upload, parsed from event and defined in vendor parseUpload() method
     * @returns String - returns path to completed file
     */
    public string function mergeChunks( required struct upload );

}
