<div class="wrapper">
<h3 class="heading">Job Order</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('tranx/joborder'); ?>">Cancel New Job Order</a></div>
	<div id="add_form">
	<div class="suggestion"  style="height: 20px"><p><span class="error"></span><span class="total_amount" style="float:right">Php 0.00</span></p></div>
	<form>
		<input class="joborderid" type="hidden" name="joborderid" value="0"/>
		<p><label>Job Order No.</label> <input type="text" name="jo_number" value="" /></p>
		<p><label>Date</label> <input type="text" name="jo_date" value="<?php echo curdate();?>" /></p>
		<p><label>Customer </label> <input class="customer" type="text" name="customer" /></p>
		<input class="cust_id" type="hidden" value="0"/>
		<p><label>Vehicle </label> <input class="vehicle" type="text" name="vehicle" /></p>
		<input class="v_id" type="hidden" value="0"/>
		<p><label>Address</label> <input type="text" name="addr"/></p>
		<p><label>Plate</label> <input type="text" name="plate"/></p>
		<p><label>Color</label> <input class="color" type="text" name="color"/></p>
		<input class="clr_id" type="hidden" value="0"/>
		<p><label>Contact No.</label> <input type="text" name="number"/></p>
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
	
	<table class="jodet regdatagrid" >
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
	<p class="submit"><input class="saveorder" type="submit" value="Save"/></p>
	</div>
</div>