<div class="wrapper">
	<h3 class="heading">Receiving</h3>
    <div class="minidashboard">
    	<div class="panelOne">        	<p>Received Vehicles Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
    </div><div class="toolbar"><a href="<?php echo base_url('tranx/receiving/section/addreceiving'); ?>">Add New Received Vehicle</a></div>
    <?php getPagination(); ?>
    <?php if(! empty($records)): ?>
    
    <table class="regdatagrid">
    	<thead>
        	<tr>
            	<th>Plate No.</th>
                <th>Customer</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        	<?php foreach($records as $record): ?>
            	<tr>
                	<td><?php echo $record->plateno; ?></td>
                    <td><?php echo $record->customer; ?></td>
                    <td><a class="reggrideditbtn" href="<?php echo base_url() . 'tranx/receiving/section/editreceiving/' . $record->vr_id;?>">Edit</a>|<a class="reggriddelbtn delete-record-view" href="#" post-url="tranx/receiving/ajaxdelvr" code="<?php echo $record->vr_id;?>">Delete</a></td>
            	</tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    <?php getPagination(); ?>
    <div id="dialog-confirm" title="Delete Record!!!"><p></p></div>
    <?php else: ?>
    	<p>No record found.</p>    
    <?php endif; ?>
</div>