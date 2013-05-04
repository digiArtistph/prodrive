<div>
<h3>Job Order</h3>
	<form>
		<p><label>Date:</label> <input type="text" name="jo_date" value="<?php echo curdate();?>" /></p>
		<p><label>Customer:</label> <input type="text" name="customer"/></p>
		<p><label>Vehicle:</label> <input class="vehicle"  type="text" name="vehicle"/></p>
		<p><label>Make:</label> <input type="text" name="make"/></p>
		<p><label>Plate:</label> <input type="text" name="plate"/></p>
		<p><label>Color:</label> <input class="color" type="text" name="color"/></p>
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
					<option value="pnm">Parts/Materials</option>
				</select></td>
				<td><input class="labor" type="text" /></td>
				<td><input class="det" type="text" /></td>
				<td><input class="amnt" type="text" /></td>
				<td><input class="addjodetails" type="submit" value="Add" /></td>
			</tr>
		</tbody>
	</table>
	
	<table class="jodet">
		<thead>
			<tr>
				<td>Job Type</td>
				<td>Labor</td>
				<td>Parts/Material</td>
				<td>Details</td>
				<td>Amount</td>
				<td>Action</td>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>None</td>
				<td>None</td>
				<td>None</td>
				<td>None</td>
				<td>None</td>
				<td>None</td>
			</tr>
		</tbody>
	</table>
</div>