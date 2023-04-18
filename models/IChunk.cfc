/**
 * Defines an interface to handle a particular chunk upload vendor.
 *
 */
interface {

    /**
     * Inspect the provided form scope and return info about the current upload (if it is an upload.)
     *
     * @memento the form scope containing upload parameters. You can pass this from a handler via `UpChunk.handleUpload( arguments.rc )`
     */
    public struct function parseUpload( required struct memento );

    /**
     * Process a non-chunked file upload
     * Runs vendor `parseUpload()` event to retrieve upload parameters
     * Calls {@see handleChunkedUpload} or {@see handleNormalUpload}, depending on upload.isChunked
     */
    public struct function handleUpload( required struct memento );

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
