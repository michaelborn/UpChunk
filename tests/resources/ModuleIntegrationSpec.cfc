component extends="coldbox.system.testing.BaseTestCase" {

    this.loadColdBox = true;

    function beforeAll() {
        super.beforeAll();

        getController().getModuleService()
            .registerAndActivateModule( "UpChunk", "testingModuleRoot" );

        getWireBox().autowire( this );

        variables.moduleSettings = getModuleSettings( "upChunk" );
    }

    /**
    * @beforeEach
    */
    function setupIntegrationTest() {
        setup();
    }


    /**********************************************************
     * Helper methods grabbed from the Supertype.
     **********************************************************/

	/**
	* Get a module's settings structure or a specific setting if the setting key is passed
	* @module.hint The module to retrieve the configuration settings from
	* @setting.hint The setting to retrieve if passed
	* @defaultValue.hint The default value to return if setting does not exist
	*
	* @return struct or any
	*/
	any function getModuleSettings( required module, setting, defaultValue ){
		var moduleSettings = getModuleConfig( arguments.module ).settings;
		// return specific setting?
		if( structKeyExists( arguments, "setting" ) ){
			return ( structKeyExists( moduleSettings, arguments.setting ) ? moduleSettings[ arguments.setting ] : arguments.defaultValue );
		}
		return moduleSettings;
	}

	/**
	* Get a module's configuration structure
	* @module.hint The module to retrieve the configuration structure from
	*/
	struct function getModuleConfig( required module ){
		var mConfig = controller.getSetting( "modules" );
		if( structKeyExists( mConfig, arguments.module ) ){
			return mConfig[ arguments.module ];
		}
		throw( message="The module you passed #arguments.module# is invalid.",
			   detail="The loaded modules are #structKeyList( mConfig )#",
			   type="FrameworkSuperType.InvalidModuleException");
	}
}
