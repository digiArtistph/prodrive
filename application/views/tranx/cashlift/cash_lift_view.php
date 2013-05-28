<div class="wrapper">
<h3 class="heading">Cash Lift</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Total Cash Lift: Php <strong><?php echo $total; ?></strong></p>            
        </div>        
    </div><div class="toolbar"><a href="<?php echo base_url('tranx/cashlift/section/addcashlift'); ?>">Add New Cash Lift</a></div>
	<div id="view_form">
	<?php if(! empty( $cashlifts ) ):?>
	
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
			<?php foreach($cashlifts as $cl): ?>
            	<tr>
                	<td><?php echo $cl->particulars; ?></td>
                    <td><?php echo $cl->refno; ?></td>
                    <td class="currency"><?php echo $cl->amnt; ?></td>
                    <td><a class="reggriddelbtn" href="<?php echo base_url('tranx/cashlift/section/delete') . '/' . $cl->cl_id; ?>">Delete</a></td>
                </tr>
            <?php endforeach; ?>
            
		</tbody>
    </table>
	<?php else:?>
		<p>No cash lift entry found</p>
	<?php endif;?>
	</div>
	
</div>