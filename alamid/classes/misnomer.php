<?php

class Misnomer {
	
	public static function load (array $classes = array()){
		
		$classes = array_merge($classes,
					array(
							'Wrapper' => 'Enclose',
							'Almdtables' => 'Querytables',
							'Xmlparser' => 'FormElementParser'					
							)
				);
		
		foreach($classes as $key => $val) {
			alias(trim($key), trim($val));
		}
		
	}
}