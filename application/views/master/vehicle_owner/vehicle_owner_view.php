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
                    <td><a class="reggrideditbtn" href="<?php echo base_url(). 'master/ownedvehicle/section/editownedvehicle/' . $record->vo_id;?>">Edit</a> <a class="reggriddelbtn delete-record-view" post-url="master/ownedvehicle/ajaxdelvehicle" code="<?php echo $record->vo_id;?>" href="#">Delete</a></td>
                </tr>          
            <?php endforeach; ?>
        </tbody>
    </table>
    
    <?php else: ?>
    	<p>No Record Found.</p>
    <?php endif; ?>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>
</div>
