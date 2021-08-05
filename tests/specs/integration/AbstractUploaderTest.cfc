component extends="tests.resources.ModuleIntegrationSpec" appMapping="/app" {

    // reload Coldbox after spec
    this.unLoadColdbox = true;

    function run(){
        describe( "AbstractUploader Suite", function(){
            beforeEach(function() {
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
                expect( fileExists( variables.moduleSettings.uploadDir & "unsplash-cookie.jpg" ) ).toBeTrue();
            } );

            it( "can upload file chunks in order", function() {
                var originalFile = "/tests/resources/files/chunktest.txt";
                var chunkFileObject = fileOpen( originalFile );

                // chunk parameters
                var index = 0;
                var uploadTrackerID = createUUID();
                var chunks = [];

                while( !fileIsEOF( chunkFileObject ) ){
                    var chunk = fileReadLine( chunkFileObject );
                    var chunkFile = getDirectoryFromPath( originalFile ) & "chunktest.#index#.part";
                    fileWrite( chunkFile, chunk );
                    chunks.append( {
                        "file"        : chunkFile,
                        "dzchunkindex": index,
                        "filename"    : "chunktest.txt",
                        "dzuuid"      : uploadTrackerID
                    } );
                    index++;
                }

                var totalChunkCount = index;
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
                    // debug( chunk );
                    // debug( result );
                } );
                expect( result ).toHaveKey( "finalFile" );

                fileClose( chunkFileObject );

                expect( fileExists( result.finalFile ) );
                expect( fileRead( result.finalFile ) ).toBe( fileRead( originalFile ) );

            });

            xit( "can upload a chunked binary", function(){

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
                writeDump( getFileInfo( originalFile ) );
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

}
