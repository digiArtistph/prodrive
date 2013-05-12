<div>
<h3>Edit Job Order</h3>
	<div class="suggestion"  style="height: 20px"><p><span class="error"></span><span class="total_amount" style="float:right">Php 0.00</span></p></div>
	<form>
		<?php if(!empty($jbo_det)):?>
		<?php foreach ($jbo_det as $jb):?>
		<input class="joborderid" type="hidden" name="joborderid" value="<?php echo $jb->jo_id;?>"/>
		<p><label>Date:</label> <input type="text" name="jo_date" value="<?php echo $jb->trnxdate;?>" /></p>
		<p><label>Customer: </label><select name="customer">
			<?php if (!empty($customers)):?>
			<?php foreach ($customers as $customer):?>
			<?php if ($jb->customer == $customer->custid):?>
			<option value="<?php echo $customer->custid;?>" selected="selected"><?php echo ucfirst($customer->lname) . ', ' . ucfirst($customer->fname). ' ' . ucfirst($customer->mname[0] . '.');?></option>
			<?php else:?>
			<option value="<?php echo $customer->custid;?>"><?php echo ucfirst($customer->lname) . ', ' . ucfirst($customer->fname). ' ' . ucfirst($customer->mname[0] . '.');?></option>
			<?php endif;?>
			<?php endforeach;?>
			<?php endif;?>
			
		</select></p>
		<p><label>Vehicle: </label><select name="vehicle">
			<?php if (!empty($vehicles)):?>
			<?php foreach ($vehicles as $vehicle):?>
			<?php if ($jb->v_id == $vehicle->v_id):?>
			<option value="<?php echo $vehicle->v_id;?>" selected="selected"><?php echo $vehicle->make;?></option>
			<?php else:?>
			<option value="<?php echo $vehicle->v_id;?>"><?php echo $vehicle->make;?></option>
			<?php endif;?>
			<?php endforeach;?>
			<?php endif;?>
			
		</select></p>
		<p><label>Address:</label> <input type="text" name="addr" value="<?php echo $jb->address;?>"/></p>
		<p><label>Plate:</label> <input type="text" name="plate" value="<?php echo $jb->plate;?>"/></p>
		<p><label>Color: </label><select name="color">
			<option value=""></option>
			<?php if (!empty($colors)):?>
			<?php foreach ($colors as $color):?>
			<?php if ($jb->color == $color->clr_id):?>
			<option value="<?php echo $color->clr_id;?>" selected="selected"><?php echo $color->name;?></option>
			<?php else:?>
			<option value="<?php echo $color->clr_id;?>"><?php echo $color->name;?></option>
			<?php endif;?>
			
			
			<?php endforeach;?>
			<?php endif;?>
			<?php endforeach;?>
			<?php endif;?>
			
		</select></p>
		<p><label>Contact No.:</label> <input type="text" name="number" value="<?php echo $jb->contactnumber;?>"/></p>
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
		<?php if(empty($jbo_orders)):?>
			<tr>
				<td colspan="3">No Data has been added</td>
			</tr>
		<?php else:?>
		
		<?php $cnt=1; foreach ($jbo_orders as $jbord):?>
		<?php if($jbord->labor>0):?>
			<tr>
				<td><?php echo $cnt;?></td>
				<td>" + jotypeqry.val() + "</td>
				<td>" + laborqry.val() + "</td>
				<td></td>
				<td>"+ $('.det').val() +"</td>
				<td>" + $('.amnt').val() +"</td>
				<td><a class="edit" href="#">edit</a>|<a class="delete" href="#\">delete</a></td>
				<td></td>
			</tr>
		<?php else :?>
			<tr>
				<td><?php echo $cnt;?></td>
				<td>Parts or Materials</td>
				<td><?php echo $jbord->partmaterial;?></td>
				<td><?php echo $jbord->details;?><</td>
				<td>"+ $('.det').val() +"</td>
				<td>" + $('.amnt').val() +"</td>
				<td><a class="edit" href="#">edit</a>|<a class="delete" href="#\">delete</a></td>
				<td></td>
			</tr>
		<?php endif;?>
		<?php $cnt++; endforeach;?>
		<?php endif;?>
		</tbody>
	</table>
	<p><input class="saveorder" type="button" value="Edit Job Order"  /></p>
</div>