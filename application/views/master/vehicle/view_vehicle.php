<div id="wrapper">
<h3>Vehicle View</h3>
	<div id="view_form">
		<?php if(!empty($vehicles)):?>
		<table>
    	<thead>
        	<tr> 
            	<th>Make</th>
            	<th>Status</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($vehicles as $vehicle):?>
        	<tr>
        		<td><?php echo $vehicle->make;?></td>
        		<td><?php if($vehicle->status == 1){echo 'Active';}else{echo 'In active';}?></td>
        		<td><a href="<?php echo base_url(). 'master/vehicle/section/editvehicle/' . $vehicle->v_id; ?>">edit</a>|<a href="<?php echo base_url(). 'master/vehicle/section/deletevehicle/' . $vehicle->v_id;  ?>">delete</a></td>
        	</tr>
        <?php endforeach;?>
        </tbody>
        </table>
		<?php else:?>
		<p>No Vehicles</p>
		<?php endif;?>
	<p><a href="<?php echo base_url() . 'master/vehicle/section/addvehicle';?>">Add Vehicle</a></p>
	</div>
</div>