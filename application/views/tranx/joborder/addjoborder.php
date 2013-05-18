<div>
<h3>Job Order</h3>
	<div class="suggestion"  style="height: 20px"><p><span class="error"></span><span class="total_amount" style="float:right">Php 0.00</span></p></div>
	<form>
		<input class="joborderid" type="hidden" name="joborderid" value="0"/>
		<p><label>Job Order No.:</label> <input type="text" name="jo_number" value="" /></p>
		<p><label>Date:</label> <input type="text" name="jo_date" value="<?php echo curdate();?>" /></p>
		<p><label>Customer: </label><select name="customer">
			<option value=""></option>
			<?php if (!empty($customers)):?>
			<?php foreach ($customers as $customer):?>
			<option value="<?php echo $customer->custid;?>"><?php echo ucfirst($customer->lname) . ', ' . ucfirst($customer->fname). ' ' . ucfirst($customer->mname[0] . '.');?></option>
			<?php endforeach;?>
			<?php endif;?>
			
		</select></p>
		<p><label>Vehicle: </label><select name="vehicle">
			<option value=""></option>
			<?php if (!empty($vehicles)):?>
			<?php foreach ($vehicles as $vehicle):?>
			<option value="<?php echo $vehicle->v_id;?>"><?php echo $vehicle->make;?></option>
			<?php endforeach;?>
			<?php endif;?>
			
		</select></p>
		<p><label>Address:</label> <input type="text" name="addr"/></p>
		<p><label>Plate:</label> <input type="text" name="plate"/></p>
		<p><label>Color: </label><select name="color">
			<option value=""></option>
			<?php if (!empty($colors)):?>
			<?php foreach ($colors as $color):?>
			<option value="<?php echo $color->clr_id;?>"><?php echo $color->name;?></option>
			<?php endforeach;?>
			<?php endif;?>
			
		</select></p>
		<p><label>Contact No.:</label> <input type="text" name="number"/></p>
	</form>
	<table>
		<thead>
			<tr>
				<td>Job Type</td>
				<td class="jotypename">Labor/Parts/Material</td>
				<td>Details</td>
				<td>Amount</td>
				<td>Action</td>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td><select class="jotype">
					<option value="" selected="selected">Select Job Type</option>
					<option value="labor">Labor</option>
					<option value="Parts or Materials">Parts/Materials</option>
				</select></td>
				<td><input class="labor" type="text" /></td>
				<td><input class="det" type="text" /></td>
				<td><input class="amnt" type="text" /></td>
				<td><input class="addjodetails" type="button" value="Add" /></td>
			</tr>
		</tbody>
	</table>
	
	<table class="jodet" >
		<thead>
			<tr>
				<th>No.</th>
				<th>Job Type</th>
				<th>Labor</th>
				<th>Parts/Material</th>
				<th>Details</th>
				<th>Amount</th>
				<th>Action</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td colspan="3">No Data has been added</td>
			</tr>
		</tbody>
	</table>
	<p><input class="saveorder" type="button" value="Add Job Order"  /></p>
</div>