/**
 * The base model test case will use the 'model' annotation as the instantiation path
 * and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
 * responsibility to update the model annotation instantiation path and init your model.
 */
component extends="coldbox.system.testing.BaseModelTest" model="upchunk.models.vendors.Uploader" {

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
        describe( "Uploader vendor Suite", function(){
            it( "can initialize", function(){
                expect( variables.model ).toBeComponent();
            } );

            /**
             * This test won't pass until can load the UpChunk module in our test suite.
             * (i.e. this test would make more sense in an integration spec, where the module is actually loaded and active.)
             */
            xit( "can getInstance", function() {
                expect( application.wirebox.getInstance( "Uploader@upchunk" ) ).toBeComponent();
            });

            describe( "+parseUpload", function() {
                it( "can parse minimal upload", function() {
                    var memento = {
                        "file"             : "letspretendImabinary",
                        "filename"         : "IMG_20210416_1.jpg",
                        "uuid"             : createUUID(),
                        "dzchunkindex"     : 0,
                        "dztotalchunkcount": 1
                    };

                    var upload = variables.model.parseUpload( memento );
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
        } );
    }

}