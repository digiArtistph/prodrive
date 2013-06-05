<?php

	// define constants here for our CSS & SCRIPTS
	define('MAIN_CSS', '<link type="text/css"  href="http://localhost/prodrive/alamid/structure/css/main.css"  rel="stylesheet">');
	define('LOGIN_CSS', '<link type="text/css"  href="http://localhost/prodrive/alamid/structure/css/login.css"  rel="stylesheet">');
	define('JQUERY_CSS', '<link type="text/css"  href="'. base_url('js/jquery-ui-1.10.2.custom/css/prodrive/jquery-ui-1.10.2.custom.css') .'"  rel="stylesheet">');
	define('FAVICON', '<link rel="shortcut icon" href="' . base_url('images/favicon.ico') . '" />');
	define('LOCAL_JQUERY_MIN', '<script src="' . base_url() . 'js/jquery-ui-1.10.2.custom/development-bundle/jquery-1.9.1.js"></script>');
	define('LOCAL_JQUERY_UI_MIN', '<script src="' . base_url() . 'js/jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.min.js"></script>');
	define('JQUERY_COMBOBOX', '<script type="text/javascript" src="' . base_url('js/jquery-ui-1.10.2.custom/js/jquery-combobox.js'). '"></script>');
	define('UTILITY_JS', '<script type="text/javascript" src="' . base_url('js/utility.js'). '"></script>');
	define('DCR_UTILITY_JS', '<script type="text/javascript" src="' . base_url('js/dcr_utility.js'). '"></script>');
	define('DCR_PLUGIN_JS', '<script type="text/javascript" src="' . base_url('js/jquery.dcrgrid.js'). '"></script>');
	define('JOTBL_PLUGIN_JS', '<script type="text/javascript" src="' . base_url('js/jquery.populatetable.js'). '"></script>');
	define('DATAVALIDATION_PLUGIN_JS', '<script type="text/javascript" src="' . base_url('js/jquery.datavalidation.js'). '"></script>');
	define('VEHICLE_OWNER_PLUGIN_JS', '<script type="text/javascript" src="' . base_url('js/jquery.owned.vehicle.js'). '"></script>');
	
	switch ($section) {
		case 'home':
		case 'tranx':
		case 'master':
		case 'reports':
			echo MAIN_CSS;
			echo FAVICON;
			echo JQUERY_CSS;
			echo LOCAL_JQUERY_MIN;
			echo LOCAL_JQUERY_UI_MIN;
			echo JOTBL_PLUGIN_JS;
			echo DCR_PLUGIN_JS;
			echo DATAVALIDATION_PLUGIN_JS;
			echo VEHICLE_OWNER_PLUGIN_JS;
			echo UTILITY_JS;					
			break;
		case 'login':
			echo LOGIN_CSS;
			echo FAVICON;;
			break;
		default:
			echo MAIN_CSS;
			echo FAVICON;
			echo JQUERY_CSS;
	}

?>
