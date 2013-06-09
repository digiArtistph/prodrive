<div class="wrapper">
<h3 class="heading">Vehicle</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Category Count: <strong><?php ''; ?></strong></p>            
        </div>        
  </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/vehicle/section/addvehicle'; ?>">Add New Vehicle</a></div>
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
        		<td><?php echo $vehicle->make;?></td>        		
        		<td><a class="reggrideditbtn" href="<?php echo base_url(). 'master/vehicle/section/editvehicle/' . $vehicle->v_id; ?>">edit</a>|<a class="reggriddelbtn delete-record-view" post-url="master/vehicle/ajaxdelveh" code="<?php echo $vehicle->v_id;?>" href="#">delete</a></td>
        	</tr>
        <?php endforeach;?>
        </tbody>
        </table>
		<?php else:?>
		<p>No Vehicles</p>
		<?php endif;?>
	</div>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>