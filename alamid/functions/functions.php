<?php
/**
 * Add you hooks here
 */

/* meta head */
add_settings('section_metahead', 'funcmeta');
function funcmeta($page) {
	$param = array(
			'meta' => array(
					array('name' => 'description', 'content' => 'Prodrive Motowerks'),
					array('name' => 'keywords', 'content' => 'HTML,CSS,XML,JavaScript'),
					array('name' => 'author', 'content' => 'Mugs and Coffee'),
					array('name' => 'Viewport', 'width' => 'devicewidth')
			)
	);
	
	almd_build_meta($param);
	
}


/* meta style */
add_settings('section_metastyle', 'funcmetastyle');

function funcmetastyle() {
	$param = array(
			'style' => array(
					array('type' => 'text/css', 'href' => 'http://localhost/prodrive/csss/style.css', 'rel' => 'stylesheet')
			)
	);
	
	almd_build_metastyle($param);
}


/* meta script */
add_settings('section_metascript', 'funcmetasript');
function funcmetasript($test) {
	$param = array(
			'script' => array(
					array('type' => 'text/javascript', 'src' => 'http://localhost/alamid/js/jsni.js'),
					array('type' => 'text/javascript', 'src' => '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js')
			)
	);
	
	almd_build_metascript($param);
}



/* masthead */
add_settings('section_masthead', 'funcone');
// add_settings('section_panels', 'functwo');

function funcone($section) {

	$param = array(
				'section_title' => 'Master Files ',
				'items' => array(
							array('menu1', 'url1'),
							array('menu2', 'url2'),
							array('menu3', 'url3'),
							array('menu4', 'url4')
						) 
			);

	almd_draw_window($param,$section);
	
}


/* panels */
add_settings('section_panels', 'functpaste');

function functpaste($arg) {
	$param = array(
			'section_title' => 'Email Servers ',
			'items' => array(
					array('Mail Yahoo', 'http://mail.yahoo.com'),
					array('Gmail', 'http://gmail.com'),
					array('XU Mail', 'http://xu.edu.ph'),
					array('Alamid Mail', 'htpp://mnc.com')
			)
	);
	
	almd_draw_window($param, $arg);
	
}


/* pasteboard */

add_settings('section_pasteboard', 'funcpasteboard');

function funcpasteboard($t) {
	$param = array('content' => 'This is a test content');
	
	almd_draw_window($param, $t);
}

/* toolbars */
add_settings('section_toolbars', 'functoolbar');

function functoolbar($t) {
	$param = array(
			'section_title' => 'Toolbar One',
			'items' => array(
					array('Facebook', 'http://facebook.com'),
					array('Twitter', 'http://twitter.com')					
			)
	);
	
	almd_draw_window($param, $t);
}


/* footers */
add_settings('section_footer', 'footerfunc');

function footerfunc($t) {
	$param = array(
			'section_title' => 'Footer Section',
			'items' => array(
					array('Quick Links', 'http://cnn.com'),
					array('Source', 'http://whitehouse.com')
			)
	);

	almd_draw_window($param, $t);
}


?>