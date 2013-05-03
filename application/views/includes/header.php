<?php

	// define constants here for our CSS & SCRIPTS
	define('REMOTE_JQUERY_MIN', '<link type="text/css"  href="http://localhost/prodrive/alamid/structure/css/main.css"  rel="stylesheet">');
	define('REMOTE_JQUERY_UI_MIN', '<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js"></script>');
	define('UTILITY_JS', '<script type="text/javascript" src="' . base_url('js/utility.js'). '"></script>');
	
	switch ($section) {
		case 'home':
		case 'tranx':
		case 'master':
			echo REMOTE_JQUERY_MIN;
			echo REMOTE_JQUERY_UI_MIN;
			echo UTILITY_JS;
			break;
		case 'reports':
			break;
		default:
			REMOTE_JQUERY_MIN;
			REMOTE_JQUERY_UI_MIN;
			UTILITY_JS;
	}

