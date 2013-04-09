<div>
	<h1>Job order</h1>
	<h2>Details</h2>
	<?php echo form_open(base_url() . 'master/joborder/validateaddform');?>
		<p><label>Date: </label><input type="text" name="jodate" /></p>
		<p><label>Name: </label><input type="text" name="name" /></p>
		<p><label>Address: </label><input type="text" name="addr" /></p>
		<p><label>Vehicle: </label><input type="text" name="vehicle" /></p>
		<p><label>Plate: </label><input type="text" name="plate" /></p>
		<p><label>Color: </label><input type="text" name="color" /></p>
		<p><label>Contact No.: </label><input type="text" name="contact" /></p>
		
	<h2>order</h2>
		<div>
			<table>
				<thead>
					<tr>
						<th>Labor</th>
						<th>Amount</th>
						<th>Parts/Materials</th>
						<th>Amount</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						
					</tr>
				</tbody>
			</table>
		</div>
		
	<p><input value="add job order" type="submit" /></p>
	<?php echo form_close();?>

</div>