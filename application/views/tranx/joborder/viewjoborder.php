<div class="wrapper">
<h3 class="heading">Job Order</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Job Order Count: <strong><?php echo $total_rows; ?></strong></p>            
        </div>        
  </div>
<div class="toolbar"><a href="<?php echo base_url(). 'tranx/joborder/section/addjoborder';?>">Add Job Order</a></div>
<?php getPagination(); ?>
	<div id="view_form">
	<table class="regdatagrid">
		<thead>
			<tr>
				<th>Order No.</th>
				<!--<th>Vehicle</th>-->
				<th>Customer</th> 	
				<th>Plate No.</th> 	

				<th>Received Date</th>
				<th>Action</th>
			</tr>
		</thead>
		<tbody>
			<?php if(empty($joborders)):?>
			<tr>
				<td>No Job Orders Found.</td>
			</tr>
			<?php else :?>
			<?php foreach ($joborders as $order):?>
			<tr title="Balance: Php <?php echo sCurrency($order->balance); ?> &nbsp;&nbsp; Payment: Php <?php echo sCurrency($order->payment); ?>">
				<td><?php echo $order->jo_num?></td>
				<!--<td><?php echo $order->vehicle;?></td>-->
				<td><?php echo search_highlight((isset($search_keyword)) ? $search_keyword : '',$order->owner);?></td>
				<td><?php echo search_highlight((isset($search_keyword)) ? $search_keyword : '', $order->plate);?></td>
				<!--<td><?php echo $order->color;?></td>
				<td><?php echo $order->num;?></td>
				<td><?php echo $order->addr;?></td>-->
				<td><?php echo longDate($order->date);?></td>
				<td><a class="reggrideditbtn" href="<?php echo base_url(). 'tranx/joborder/section/editjoborder/'. $order->jo_id; ?>">Edit</a>|<a class="reggriddelbtn deljo" jocode="<?php echo  $order->jo_id;;?>" href="#">Delete</a></td>
			</tr>
			<?php endforeach;?>
			<?php endif;?>
		</tbody>
	</table>
    	
</div>
<?php getPagination(); ?>
<div id="dialog-confirm" title="Delete Record!!!"><p></p></div>	
</div>