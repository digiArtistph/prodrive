<div id="wrapper">
<h3>Cash Lift</h3>
	<div id="view_form">
	<p><a href="<?php echo base_url('tranx/cashlift/section/addcashlift'); ?>">Add New Cash Lift</a></p>
	<?php if(! empty( $cashlifts ) ):?>
	
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
			<?php foreach($cashlifts as $cl): ?>
            	<tr>
                	<td><?php echo $cl->particulars; ?></td>
                    <td><?php echo $cl->refno; ?></td>
                    <td><?php echo $cl->amnt; ?></td>
                    <td><a href="<?php echo base_url('tranx/cashlift/section/delete') . '/' . $cl->cl_id; ?>">Delete</a></td>
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
		<p>No cash lift entry found</p>
	<?php endif;?>
	</div>
	
</div>