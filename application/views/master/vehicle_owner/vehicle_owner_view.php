<div class="wrapper">
	<h3 class="heading">Owned-Vehicles</h3>
    <div class="minidashboard">
    	<div class="panelOne">        	<p>Owned Vehicles Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/ownedvehicle/section/addownedvehicle'; ?>">Add New Owned-Vehicle</a></div>
<div id="view_form">
	<?php if(! empty($records)): ?>
    <table class="regdatagrid">
    	<thead>
        	<tr>
            	<th>Vehicles</th><th>Plate No.</th><th>Owner</th><th>Action</th>
            </tr>
        </thead>
        <tbody>
        	<?php foreach($records as $record): ?>
            	<tr>
                	<td><?php echo $record->make; ?></td>
                    <td><?php echo $record->plateno; ?></td>
                    <td><?php echo $record->owner; ?></td>
                    <td><a href="#">Edit</a> <a href="#">Delete</a></td>
                </tr>          
            <?php endforeach; ?>
        </tbody>
    </table>
    
    <?php else: ?>
    	<p>No Record Found.</p>
    <?php endif; ?>
</div>
</div>
