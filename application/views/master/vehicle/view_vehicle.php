<div class="wrapper">
<h3 class="heading">Vehicle</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Category Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
  </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/vehicle/section/addvehicle'; ?>">Add New Vehicle</a></div>
<?php getPagination(); ?>
	<div id="view_form">
		<?php if(!empty($vehicles)):?>
		<table class="regdatagrid">
    	<thead>
        	<tr> 
            	<th>Make</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($vehicles as $vehicle):?>
        	<tr>
        		<td><?php echo search_highlight((isset($search_keyword)) ? $search_keyword : '', $vehicle->make); ?></td>        		
        		<td><a class="reggrideditbtn" href="<?php echo base_url(). 'master/vehicle/section/editvehicle/' . $vehicle->v_id; ?>">Edit</a>|<a class="reggriddelbtn delete-record-view" post-url="master/vehicle/ajaxdelveh" code="<?php echo $vehicle->v_id;?>" href="#">Delete</a></td>
        	</tr>
        <?php endforeach;?>
        </tbody>
        </table>
		<?php else:?>
		<p>No Vehicles</p>
		<?php endif;?>
	</div>
   
<div id="dialog-confirm" title="Delete Record"><p></p></div>
 <?php getPagination(); ?>
</div>