<div>
<h3>Job Order</h3>
<div>
	<table>
		<thead>
			<tr>
				<th>Job Order No.</th>
				<th>Vehicle</th>
				<th>customer</th> 	
				<th>Plate No.</th> 	
				<th>color</th> 	
				<th>contactnumber</th>
				<th>address</th>
				<th>trnxdate</th>
				<th>Action</th>
			</tr>
		</thead>
		<tbody>
			<?php if(empty($joborders)):?>
			<tr>
				<td>No Data</td>
			</tr>
			<?php else :?>
			<?php foreach ($joborders as $order):?>
			<tr>
				<td><?php echo $order->jo_num?></td>
				<td><?php echo $order->vehicle;?></td>
				<td><?php echo ucfirst($order->lname). ', ' . ucfirst($order->fname) . ' ' . ucfirst($order->mname[0]);?></td>
				<td><?php echo $order->plate;?></td>
				<td><?php echo $order->color;?></td>
				<td><?php echo $order->num;?></td>
				<td><?php echo $order->addr;?></td>
				<td><?php echo $order->date;?></td>
				<td><a href="<?php echo base_url(). 'tranx/joborder/section/editjoborder/'. $order->jo_id; ?>">edit</a>|<a href="<?php echo base_url(). 'tranx/joborder/section/deletejobrder/' . $order->jo_id; ?>" >delete</a></td>
			</tr>
			<?php endforeach;?>
			<?php endif;?>
		</tbody>
	</table>
			<p><?php echo $links;?></p>
</div>
<p><a href="<?php echo base_url(). 'tranx/joborder/section/addjoborder';?>">Add Job Order</a></p>
</div>