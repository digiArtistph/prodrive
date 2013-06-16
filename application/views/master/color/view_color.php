<div class="wrapper">
<h3 class="heading">Color</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Color Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
</div>
	<div class="toolbar"><a href="<?php echo base_url() . 'master/color/section/addcolor'; ?>">Add New Color</a></div>
    <div class="pagination-record">
	<div class="pagination-controls">
    	<!--1&nbsp;<a href="#">2</a>&nbsp;<a href="#">3</a>&nbsp;<a href="#">4</a>--><?php echo $paginate; ?>
    </div>
    <div class="record-filter"><select name="viewperpage">
        <option value="10">10</option>
        <option value="20">20</option>
        <option value="30">30</option>
        <option value="50">50</option>
        <option value="75">75</option>
        <option value="100">100</option>
        <option value="-1">All</option>
        </select> per page</div>
    </div>
	<div id="view_form">
	<?php if(! empty( $colors ) ):?>
	
	<table class="regdatagrid">
    	<thead>
        	<tr> 
            	<th>Color</th> 
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
		<?php foreach ($colors as $color):?>
			<tr>
				<td><?php echo $color->name;?></td>
            	<td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/color/section/editcolor/' . $color->clr_id;?>">Edit</a>|<a class="reggriddelbtn delete-record-view" post-url="master/color/ajaxdelclr" code="<?php echo $color->clr_id;?>" href="#">Delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No Color Added!!!</p>
	<?php endif;?>
	
	</div>
<div id="dialog-confirm" title="Delete Record!!!"><p></p></div>	
</div>