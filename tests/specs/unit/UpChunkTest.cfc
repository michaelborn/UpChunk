/**
 * The base model test case will use the 'model' annotation as the instantiation path
 * and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
 * responsibility to update the model annotation instantiation path and init your model.
 */
component extends="coldbox.system.testing.BaseModelTest" model="upchunk.models.UpChunk" {

    /*********************************** LIFE CYCLE Methods ***********************************/

    function beforeAll(){
        super.beforeAll();

        // setup the model
        super.setup();

        // init the model object
        model.init();
    }

    function afterAll(){
        super.afterAll();
    }

    /*********************************** BDD SUITES ***********************************/

    function run(){
        describe( "UpChunk vendor Suite", function(){
            it( "can initialize", function(){
                expect( variables.model ).toBeComponent();
            } );

            /**
             * This test won't pass until can load the UpChunk module in our test suite.
             * (i.e. this test would make more sense in an integration spec, where the module is actually loaded and active.)
             */
            xit( "can getInstance with module mapping", function() {
                expect( application.wirebox.getInstance( "UpChunk@upchunk" ) ).toBeComponent();
            });

            describe( "+parseUpload", function() {
                beforeEach( function() {
                    variables.model.$property(
                        propertyName = "settings",
                        mock = {
                            "fields" : {
                                "file"       : "fileUpload",
                                "filename"   : "filename",
                                "uniqueId"   : "dzuuid",
                                "chunkIndex" : "dzchunkindex",
                                "totalChunks": "dztotalchunkcount"
                            }
                        }
                    );
                });

                it( "can parse minimal upload", function() {
                    var eventMock = {
                        "fileUpload"       : "letspretendImabinary",
                        "filename"         : "IMG_20210416_1.jpg",
                        "uuid"             : createUUID(),
                        "dzchunkindex"     : 0,
                        "dztotalchunkcount": 1
                    };

                    var upload = variables.model.parseUpload( eventMock );
                    expect( upload ).toBeStruct()
                                    .toHaveKey( "isChunked" )
                                    .toHaveKey( "file" )
                                    .toHaveKey( "original" )
                                    .toHaveKey( "uuid" )
                                    .toHaveKey( "index" )
                                    .toHaveKey( "isFinalChunk" );
                    
                    expect( upload.isChunked ).toBeTrue();
                    expect( upload.file ).toBe( "letspretendImabinary" );
                    expect( upload.original ).toBe( "IMG_20210416_1.jpg" );
                    expect( upload.isFinalChunk ).toBeTrue();
                });
            });
            xdescribe( "+handleUpload", function(){
                it( "should handle normal file uploads", function(){
                } );
    
                it( "should handle file chunk upload", function(){
                } );
    
                it( "should merge file chunks", function(){
                    // Create a few test chunks and see if they get merged together
                } );
            } );
        } );
    }

}