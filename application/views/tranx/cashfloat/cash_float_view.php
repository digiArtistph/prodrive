<div id="wrapper">
<h3>Cash Float</h3>
	<div id="view_form"><p><a href="<?php echo base_url('tranx/cashfloat/section/addcashfloat'); ?>">Add New Cash Float</a></p>
	<?php if(! empty( $cashfloats ) ):?>
	
	<table>
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
                    <td><?php echo $cf->amnt; ?></td>
                    <td><a href="<?php echo base_url('tranx/cashfloat/section/delete') . '/' . $cf->cf_id; ?>">Delete</a></td>
                </tr>
            <?php endforeach; ?>
            <tr>
            	<td colspan="4"><?php echo 'Total: Php '. $total; ?></td>
               	<td></td>
                <td></td>
                <td></td>
            </tr>
		</tbody>
    </table>
	<?php else:?>
		<p>No cash float entry found</p>
	<?php endif;?>
	</div>
	
</div>