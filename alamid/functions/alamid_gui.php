<?php if (! defined('BASEPATH')) exit ('No direct script access allowed.');

function almd_draw_panel($params = array(), $section) {
	global $almd_wrap;
	$output = '';
	
	$title_section = $almd_wrap->wrap(array('node' => 'p', 'prop' => get_elem_properties(array('class' => 'panel-menu-title')), 'child' => $params['section_title']));
// 	call_debug($title_section);
	$output = $title_section;
	$output .= almd_menu_walker($params['items'], '');

	
	// wraps it again
 	$output = sprintf("<li>%s</li>", $output);
 	
	switch ($section) {
		case 'section_masthead':
			Masthead::buildChildDOM($output);
			break;
		case 'section_panels':
			Panels::buildChildDOM($output);
			break;
		case 'section_toolbars':
			Toolbars::buildChildDOM($output);
			break;
		case 'section_footer':
			footer::buildChildDOM($output);
			break;
	}

		
}

function almd_menu_walker($params, $section) {
	global $almd_wrap;
	$output = '';	
	$item = '';
	
	foreach($params as $val) {
		
		$dom = array(
					'node' => 'a',
					'prop' => sprintf(' href="%s" ', $val[1]),
					'child' => $val[0]
				);
		
		$item .= $almd_wrap->wrap($dom);
		
		$dom_li = array('node' => 'li', 'prop' => get_elem_properties(array('class' => 'menu-item')), 'child' => $item);
		$output .= $almd_wrap->wrap($dom_li);
		
		// resets some values
		$item = '';
		
		}
		
		// here you'd add some config settings for the parent container
		$output = sprintf("<ul>%s</ul>", $output);
	
		return $output;

}
