<?php if (! defined('BASEPATH')) exit ('No direct script access allowed.');

function almd_draw_window($params = array(), $section) {
	$output = '';

	// wraps it again
 	$output = sprintf("<li>%s</li>", $output);
 	
	switch ($section) {
		case 'section_masthead':
			$output = build_per_section($params);
			Masthead::buildChildDOM($output);
			break;
		case 'section_panels':
			$output = build_per_section($params);
			Panels::buildChildDOM($output);
			break;
		case 'section_pasteboard':
			$output = build_per_section($params, FALSE, FALSE);
			Pasteboard::buildChildDOM($output);
			break;
		case 'section_toolbars':
			$output = build_per_section($params);
			Toolbars::buildChildDOM($output);
			break;
		case 'section_footer':
			$output = build_per_section($params);
			footer::buildChildDOM($output);
			break;
	}

		
}

function build_per_section($params, $hastitle = TRUE, $hasitems = TRUE) {
	global $almd_wrap;
	$output = '';
	
	if($hastitle):
		$title_section = $almd_wrap->wrap(array('node' => 'p', 'prop' => get_elem_properties(array('class' => 'panel-menu-title')), 'child' => $params['section_title']));
		$output = $title_section;
	endif;
	
	if($hasitems)
		$output .= almd_menu_walker($params['items'], '');
	
	if(!$hastitle && !$hasitems)
		$output = (isset($params['content'])) ? $params['content'] : ''; 
	
	return $output;
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

?>