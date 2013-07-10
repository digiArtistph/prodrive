<?php
	$params = array('pgperpage', 'pgbookmark');
	$this->sessionbrowser->getInfo($params);
	$arr = $this->sessionbrowser->mData;
	$perpage = $arr['pgperpage'];
	$controller = $this->uri->segment(1);
	$method = $this->uri->segment(2);
	if( ! function_exists('filterSelected')) {
		function filterSelected($curVal, $pg) {
			if($curVal == $pg)
				return 'selected="selected"';
		}
	}
?>
<div class="clearthis">&nbsp;</div>
<div class="pagination-record">
	
    
    <div class="record-filter">
	   
            View <select prop-controller-method="<?php echo $controller . '/' . $method; ?>" prop-url="<?php echo uri_string(); ?>" name="viewperpage">
            <option <?php echo filterSelected(5, $perpage); ?> value="5">5</option>
            <option <?php echo filterSelected(10, $perpage); ?> value="10">10</option>
            <option <?php echo filterSelected(20, $perpage); ?> value="20">20</option>
            <option <?php echo filterSelected(30, $perpage); ?> value="30">30</option>
            <option <?php echo filterSelected(50, $perpage); ?> value="50">50</option>
            <option <?php echo filterSelected(75, $perpage); ?> value="75">75</option>
            <option <?php echo filterSelected(100, $perpage); ?> value="100">100</option>
            </select> 
            per page
           
  </div>
  
  	<div class="search-keyword">
    	<?php echo form_open(base_url("$controller/$method/section/find")); ?> &nbsp;|| Find: 
            <input type="text" name="search" /> 
      	<input type="submit" value="Go" /> <?php echo form_close(); ?> 
        <?php if(isset($search_keyword)): ?>
			<?php if($search_keyword != ""): ?>
        	|| Searched keyword/s: <?php echo "'<strong>" . $search_keyword . '</strong>"'; ?>
			<?php endif; ?>
		<?php endif; ?>
		
    </div>
    
  	<?php if($paginate !=""): ?>
        <div class="pagination-controls">
            <?php echo $paginate; ?>
        </div>
    <?php endif; ?>
</div>