<div class="wrapper">
<h3 class="heading">Cash Float</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Total Cash Float: Php <strong><?php echo $total; ?></strong></p>            
        </div>        
    </div><div class="toolbar"><a href="<?php echo base_url('tranx/cashfloat/section/addcashfloat'); ?>">Add New Cash Float</a></div>
	<div id="view_form">
    	
	<?php if(! empty( $cashfloats ) ):?>
	
	<table class="regdatagrid">
    	<thead>
        	<tr> 
            	<th>Particulars</th>
                <th>Ref. No.</th>
                <th>Amount</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
			<?php foreach($cashfloats as $cf): ?>
            	<tr>
                	<td><?php echo $cf->particulars; ?></td>
                    <td><?php echo $cf->refno; ?></td>
                    <td class="currency"><?php echo $cf->amnt; ?></td>
                    <td><a class="reggriddelbtn" href="<?php echo base_url('tranx/cashfloat/section/delete') . '/' . $cf->cf_id; ?>">Delete</a></td>
                </tr>
            <?php endforeach; ?>
            
		</tbody>
    </table>
	<?php else:?>
		<p>No cash float entry found</p>
	<?php endif;?>
	</div>
	
</div>