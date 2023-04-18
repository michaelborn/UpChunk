component extends="tests.specs.ModuleIntegrationSpec" appMapping="/app" {

    // reload Coldbox after spec
    this.unLoadColdbox = true;

    variables.testTmpDir = expandPath( "/resources/files/tmp/" );

    function run(){
        describe( "UpChunk Suite", function(){
            beforeEach( function(){
                ensureDirectoryExists( variables.moduleSettings.tempDir );
                ensureDirectoryExists( variables.moduleSettings.uploadDir );
                ensureDirectoryExists( variables.testTmpDir );

                var original = expandPath( "/resources/files/unsplash-cookie.jpg" );

                /**
                 * We create a dummy copy because the upload will move the upload tmp file into its final location.
                 */
                variables.uploadTestFile = variables.testTmpDir & "UPLOAD-TEST.jpg";
                if ( !fileExists( uploadTestFile ) ) {
                    fileCopy( original, uploadTestFile );
                }
            } );
            it( "can upload a non-chunked file", function(){
                var memento = {
                    "fileUpload": variables.uploadTestFile,
                    "filename"  : "UPLOAD-TEST.jpg"
                };
                var event = post(
                    route  = "/upload/dropzone",
                    method = "POST",
                    params = memento
                );
                expect( fileExists( variables.moduleSettings.uploadDir & "UPLOAD-TEST.jpg" ) ).toBeTrue();
            } );

            it( "matches the original file extension", function(){
                var originalFile = expandPath( "/resources/files/chunktest.txt" );

                // chunk parameters
                var totalChunkCount = 0;
                var uploadTrackerID = createUUID();
                var chunks          = [];

                readFileIntoChunks(
                    originalFile,
                    100000,
                    function( chunk, size, index ){
                        var chunkFile = variables.testTmpDir & "chunktest.#index#.part";
                        fileWrite( chunkFile, chunk );
                        chunks.append( {
                            "fileUpload"  : chunkFile,
                            "dzchunkindex": index,
                            "filename"    : "chunktest.txt",
                            "dzuuid"      : uploadTrackerID
                        } );
                        totalChunkCount++;
                    }
                );

                /**
                 * upload all chunks and check the resulting file
                 */
                var result = {};
                chunks.each( function( chunk ){
                    chunk[ "dztotalchunkcount" ] = totalChunkCount;
                    var event                    = post(
                        route  = "/upload/dropzone",
                        method = "GET",
                        params = chunk
                    );
                    result = event.getRenderData().data;
                } );

                debug( result );
                expect( result ).toHaveKey( "finalFile" );
                expect( result ).toHaveKey( "error" );

                expect( result.error ).toBeFalse();
                expect( fileExists( result.finalFile ) );
                expect( listLast( result.finalFile, "." ) ).toBe(
                    listLast( originalFile, "." ),
                    "uploaded file extension should match original"
                );
            } );

            it( "can upload .txt file chunks in order", function(){
                var originalFile = expandPath( "/resources/files/chunktest.txt" );

                // chunk parameters
                var totalChunkCount = 0;
                var uploadTrackerID = createUUID();
                var chunks          = [];

                readFileIntoChunks(
                    originalFile,
                    100000,
                    function( chunk, size, index ){
                        var chunkFile = variables.testTmpDir & "chunktest.#index#.part";
                        fileWrite( chunkFile, chunk );
                        chunks.append( {
                            "fileUpload"  : chunkFile,
                            "dzchunkindex": index,
                            "filename"    : "chunktest.txt",
                            "dzuuid"      : uploadTrackerID
                        } );
                        totalChunkCount++;
                    }
                );

                var result = {};
                chunks.each( function( chunk ){
                    chunk[ "dztotalchunkcount" ] = totalChunkCount;
                    var event                    = post(
                        route  = "/upload/dropzone",
                        method = "GET",
                        params = chunk
                    );
                    result = event.getRenderData().data;
                } );
                expect( result ).toHaveKey( "finalFile" );

                expect( fileExists( result.finalFile ) );
                expect( fileRead( result.finalFile ) ).toBe(
                    fileRead( originalFile ),
                    "merged/uploaded file should match original byte for byte"
                );
            } );

            it( "can upload a larger chunked .jpg", function(){
                var originalFile = expandPath( "/resources/files/cookie-large.jpg" );

                // chunk parameters
                var totalChunkCount = 0;
                var uploadTrackerID = createUUID();
                var chunks          = [];

                readFileIntoChunks(
                    originalFile,
                    100000,
                    function( chunk, size, index ){
                        var chunkFile = variables.testTmpDir & "chunktest.#index#.part";
                        fileWrite( chunkFile, chunk );
                        chunks.append( {
                            "fileUpload"  : chunkFile,
                            "dzchunkindex": index,
                            "filename"    : "chunked-file-upload.jpg",
                            "dzuuid"      : uploadTrackerID
                        } );
                        totalChunkCount++;
                    }
                );

                expect( totalChunkCount ).toBe( 20 );

                var result = {};
                chunks.each( function( chunk ){
                    chunk[ "dztotalchunkcount" ] = totalChunkCount;
                    var event                    = post(
                        route  = "/upload/dropzone",
                        method = "GET",
                        params = chunk
                    );
                    result = event.getRenderData().data;
                    // debug( chunk );
                    // debug( result );
                } );
                expect( result ).toHaveKey( "finalFile" );

                expect( fileExists( result.finalFile ) );
                expect( fileRead( result.finalFile ) ).toBe( fileRead( originalFile ) );
            } );
            it( "can run integration specs with the module activated", function(){
                expect( getController().getModuleService().isModuleRegistered( "UpChunk" ) ).toBeTrue();

                var event = execute(
                    event         = "Main.index",
                    renderResults = true
                );
                expect( event.getPrivateCollection().welcomeMessage ).toBe( "Welcome to ColdBox!" );
            } );
        } );
    }

    /**
     * Read a file in XX size binary chunks.
     * Used for creating a dozen or so chunks to test the chunk upload processing.
     *
     * @filename full path to binary file to read in as byte stream
     * @chunkSize Make byte chunks this size or smaller (last chunk will prob. be smaller)
     * @processChunk closure to run on each chunk. Use for saving the chunks to disk. `function( binary, chunkLength, chunkIndex ){}`
     *
     * @cite https://javabeat.net/java-split-merge-files/
     */
    private function readFileIntoChunks(
        required string filename,
        required chunkSize,
        required function processChunk
    ){
        var inputFile   = createObject( "java", "java.io.File" ).init( arguments.filename );
        var inputStream = createObject( "java", "java.io.FileInputStream" ).init( inputFile );

        var fileSize   = inputFile.length();
        var chunkIndex = 0;

        while ( fileSize > 0 ) {
            // var binaryChunk = createObject( "java", "lucee.runtime.op.Caster" ).binaryChunk(  );
            var binaryChunk = inputStream.readNBytes( arguments.chunkSize );
            var chunkLength = arrayLen( binaryChunk );

            fileSize -= chunkLength;
            processChunk( binaryChunk, chunkLength, chunkIndex );

            // avoid memory overflow
            binaryChunk = javacast( "null", 0 );
            chunkIndex++;
        }
        inputStream.close();
    }

    private function ensureDirectoryExists( required string directory ){
        if ( directoryExists( arguments.directory ) ) {
            directoryDelete( arguments.directory, true );
        }
        directoryCreate( arguments.directory );
    }

}
