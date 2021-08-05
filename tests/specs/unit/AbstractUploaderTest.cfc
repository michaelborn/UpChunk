/**
 * The base model test case will use the 'model' annotation as the instantiation path
 * and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
 * responsibility to update the model annotation instantiation path and init your model.
 */
component extends="coldbox.system.testing.BaseModelTest" model="UpChunk.models.AbstractUploader" {

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
        xdescribe( "AbstractUploader Suite", function(){
            xit( "should handle normal file uploads", function(){
            } );

            xit( "should handle file chunk upload", function(){
            } );

            xit( "should merge file chunks", function(){
                // Create a few test chunks and see if they get merged together
            } );
        } );
    }

}
