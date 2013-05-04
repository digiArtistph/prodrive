<?php

	// define constants here for our CSS & SCRIPTS
	define('MAIN_CSS', '<link type="text/css"  href="http://localhost/prodrive/alamid/structure/css/main.css"  rel="stylesheet">');
	define('JQUERY_CSS', '<link type="text/css"  href="'. base_url('js/jquery-ui-1.10.2.custom/css/prodrive/jquery-ui-1.10.2.custom.css') .'"  rel="stylesheet">');
	define('REMOTE_JQUERY_MIN', '<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>');
	define('REMOTE_JQUERY_UI_MIN', '<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js"></script>');
	define('UTILITY_JS', '<script type="text/javascript" src="' . base_url('js/utility.js'). '"></script>');
	define('DCR_UTILITY_JS', '<script type="text/javascript" src="' . base_url('js/dcr_utility.js'). '"></script>');
	
	switch ($section) {
		case 'home':
		case 'tranx':
		case 'master':
			echo MAIN_CSS;
			echo JQUERY_CSS;
			echo REMOTE_JQUERY_MIN;
			echo REMOTE_JQUERY_UI_MIN;
			echo UTILITY_JS;
			echo DCR_UTILITY_JS;
			break;
		case 'reports':
			break;
		default:
			echo MAIN_CSS;
			echo JQUERY_CSS;
			echo REMOTE_JQUERY_MIN;
			echo REMOTE_JQUERY_UI_MIN;
			echo UTILITY_JS;
	}

