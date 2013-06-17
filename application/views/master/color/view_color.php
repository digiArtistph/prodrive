<div class="wrapper">
<h3 class="heading">Color</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Color Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
</div>
	<div class="toolbar"><a href="<?php echo base_url() . 'master/color/section/addcolor'; ?>">Add New Color</a></div>
    <?php getPagination(); ?>
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
    <?php getPagination(); ?>
<div id="dialog-confirm" title="Delete Record!!!"><p></p></div>	
</div>