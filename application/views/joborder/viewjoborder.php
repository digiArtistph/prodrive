<div>
	
		<h2>order</h2>
		<div>
			<table>
				<thead>
					<tr>
						<th>Name</th>
						<th>Address</th>
						<th>Date</th>
						<th>Plate</th>
						<th>Color</th>
						<th>Contact</th>
						<th>Action</th>
					</tr>
				</thead>
				<tbody>
				<?php foreach ($orders as $order):?>
					<tr>
						<td><?php echo $order->name;?></td>
						<td><?php echo $order->address;?></td>
						<td><?php echo $order->jodate;?></td>
						<td><?php echo $order->plate;?></td>
						<td><?php echo $order->color;?></td>
						<td><?php echo $order->contact;?></td>
						<td><a href="<?php echo base_url(). 'master/joborder/section/vieworderlist/' . $order->or_id;?>">view</a>|<a href="<?php echo base_url(). 'master/joborder/section/vieworderlist/' . $order->or_id;?>">edit</a>|<a href="<?php echo base_url(). 'master/joborder/section/vieworderlist/' . $order->or_id;?>">delete</a>|</td>
					</tr>
				<?php endforeach;?>
				</tbody>
			</table>
		</div>
	
</div>