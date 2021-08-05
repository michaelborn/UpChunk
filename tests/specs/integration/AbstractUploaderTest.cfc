component extends="tests.resources.ModuleIntegrationSpec" appMapping="/app" {

    // reload Coldbox after spec
    this.unLoadColdbox = true;

    function run(){
        describe( "AbstractUploader Suite", function(){
            beforeEach(function() {
                if ( directoryExists( variables.moduleSettings.tempDir ) ){
                    directoryDelete( variables.moduleSettings.tempDir, true );
                }
                directoryCreate( variables.moduleSettings.tempDir );
                if ( directoryExists( variables.moduleSettings.uploadDir ) ){
                    directoryDelete( variables.moduleSettings.uploadDir, true );
                }
                directoryCreate( variables.moduleSettings.uploadDir );
                var original = "/tests/resources/files/unsplash-cookie.jpg";

                /**
                 * We create a dummy copy because the upload will move the upload tmp file into its final location.
                 */
                variables.uploadTestFile = getDirectoryFromPath( original ) & "UPLOAD-TEST.jpg";
                if ( !fileExists( uploadTestFile ) ){
                    fileCopy( original, uploadTestFile );
                }
            });
            it( "can upload a non-chunked file", function(){
                var event = request(
                    route         = "/upload/dropzone",
                    method        = "POST",
                    params        = {
                        "file" : variables.uploadTestFile
                    }
                );
                expect( fileExists( variables.moduleSettings.uploadDir & "UPLOAD-TEST.jpg" ) ).toBeTrue();
            } );

            it( "can upload .txt file chunks in order", function() {
                var originalFile = "/tests/resources/files/chunktest.txt";
                var chunkFileObject = fileOpen( originalFile );

                // chunk parameters
                var totalChunkCount = 0;
                var uploadTrackerID = createUUID();
                var chunks = [];

                readFileIntoChunks( expandPath( originalFile ), 100000, function( chunk, size, index ){
                    var chunkFile = getDirectoryFromPath( originalFile ) & "chunktest.#index#.part";
                    fileWrite( chunkFile, chunk );
                    chunks.append( {
                        "file"        : chunkFile,
                        "dzchunkindex": index,
                        "filename"    : "chunktest.txt",
                        "dzuuid"      : uploadTrackerID
                    } );
                    totalChunkCount++;
                } );

                // var index = 0;
                // while( !fileIsEOF( chunkFileObject ) ){
                //     var chunk = fileReadLine( chunkFileObject );
                //     var chunkFile = getDirectoryFromPath( originalFile ) & "chunktest.#index#.part";
                //     fileWrite( chunkFile, chunk );
                //     chunks.append( {
                //         "file"        : chunkFile,
                //         "dzchunkindex": index,
                //         "filename"    : "chunktest.txt",
                //         "dzuuid"      : uploadTrackerID
                //     } );
                //     index++;
                // }

                var result = {};
                chunks.each( function( chunk ) {
                    chunk[ "dztotalchunkcount" ] = totalChunkCount;
                    var event = request(
                        route         = "/upload/dropzone",
                        method        = "GET",
                        params        = chunk
                    );
                    result = event.getRenderData().data;

                    expect( result ).toHaveKey( "error" );
                    expect( result.error ).toBeFalse();
                    debug( chunk );
                    debug( result );
                } );
                expect( result ).toHaveKey( "finalFile" );

                fileClose( chunkFileObject );

                expect( fileExists( result.finalFile ) );
                expect( fileRead( result.finalFile ) ).toBe( fileRead( originalFile ) );

            });

            it( "can upload a larger chunked .jpg", function(){

                /**
                 * Steps to testing the chunked uploader:
                 * 1. Find a sizeable file
                 * 2. Read 100 KB chunks from the file
                 * 3. send each chunk to the uploader with the appropriate params
                 * 4. test the response
                 * 5. when complete, test the result - i.e., the final file.
                 * 
                 * @see https://stackoverflow.com/q/4431945
                 */
                var originalFile = "/tests/resources/files/cookie-large.jpg";
                var chunkFileObject = fileOpen( originalFile );

                // chunk parameters
                var totalChunkCount = 0;
                var uploadTrackerID = createUUID();
                var chunks = [];

                readFileIntoChunks( expandPath( originalFile ), 100000, function( chunk, size, index ){
                    var chunkFile = getDirectoryFromPath( originalFile ) & "chunktest.#index#.part";
                    fileWrite( chunkFile, chunk );
                    chunks.append( {
                        "file"        : chunkFile,
                        "dzchunkindex": index,
                        "filename"    : "chunked-file-upload.jpg",
                        "dzuuid"      : uploadTrackerID
                    } );
                    totalChunkCount++;
                } );

                expect( totalChunkCount ).toBe( 20 );

                var result = {};
                chunks.each( function( chunk ) {
                    chunk[ "dztotalchunkcount" ] = totalChunkCount;
                    var event = request(
                        route         = "/upload/dropzone",
                        method        = "GET",
                        params        = chunk
                    );
                    result = event.getRenderData().data;

                    expect( result ).toHaveKey( "error" );
                    expect( result.error ).toBeFalse();
                    debug( chunk );
                    debug( result );
                } );
                expect( result ).toHaveKey( "finalFile" );

                fileClose( chunkFileObject );

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

    private function readFileIntoChunks( required string filename, required chunkSize, required function processChunk ){
        var inputFile = createObject( "java", "java.io.File").init( arguments.filename );
        var inputStream = createObject( "java", "java.io.FileInputStream" ).init( inputFile );

        var fileSize = inputFile.length();
        var chunkIndex = 0;
        var maxRead = arguments.chunkSize;

        while (fileSize > 0) {
            // var binaryChunk = createObject( "java", "lucee.runtime.op.Caster" ).binaryChunk(  );
            var binaryChunk = inputStream.readNBytes( arguments.chunkSize );
            var chunkLength = arrayLen( binaryChunk );

            fileSize -= chunkLength;

            processChunk( binaryChunk, chunkLength, chunkIndex )

            byteChunkPart = javaCast( "null", 0 );
            chunkIndex++;
        }
        inputStream.close();

    }

}
