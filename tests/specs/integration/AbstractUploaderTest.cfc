component extends="tests.resources.ModuleIntegrationSpec" appMapping="/app" {

    // reload Coldbox after spec
    this.unLoadColdbox = true;

    function run(){
        describe( "AbstractUploader Suite", function(){
            it( "can upload a non-chunked file", function(){
                var event = request(
                    route         = "/upload/dropzone",
                    method        = "POST",
                    params        = {
                                    "file" : fileRead( "/resources/files/unsplash-cookie.jpg" )
                    }
                );
                writeDump( event.getRenderData() );abort;
                expect( event.getPrivateCollection().welcomeMessage ).toBe( "Welcome to ColdBox!" );
            } );

            xit( "should handle file chunk upload", function(){
            } );

            xit( "should merge file chunks", function(){
                // Create a few test chunks and see if they get merged together
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
