<div class="wrapper">
<h3 class="heading">Edit Job Order</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('tranx/joborder'); ?>">Cancel Edit Job Order</a></div>
	<div id="add_form">
	<div class="suggestion"  style="height: 20px"><p><span class="error"></span><span class="total_amount" style="float:right">
		<?php if(!empty($jbo_orders)):?><?php $total=0; foreach ($jbo_orders as $job){ $total += ($job->laboramnt + $job->partmaterialamnt); } echo number_format($total, 2, '.', ''); else: echo 'Php 0.00'; endif;?></span></p></div>
	<form>
		<?php if(!empty($jbo_det)):?>
		<?php foreach ($jbo_det as $jb):?>
		
		<input class="joborderid" type="hidden" name="joborderid" value="<?php echo $jb->jo_id;?>"/>
		<p><label>Job Order No.:</label> <input type="text" name="jo_number" value="<?php echo $jb->jo_number;?>" /></p>
		<p><label>Date:</label> <input type="text" name="jo_date" value="<?php echo $jb->trnxdate;?>" /></p>
		<p><label>Customer: </label><select name="customer">
			<?php if (!empty($customers)):?>
			<option value=""></option>
			<?php foreach ($customers as $customer):?>
			<?php if ($jb->customer == $customer->custid):?>
			<?php if(!empty($customer->mname) ){ $mname = ucfirst($customer->mname[0]) ; }else{$mname = '';}?> 
			<option value="<?php echo $customer->custid;?>" selected="selected"><?php echo ucfirst($customer->lname) . ', ' . ucfirst($customer->fname). ' ' . $mname;?></option>
			<?php else:?>
			<?php if(!empty($customer->mname) ){ $mname = ucfirst($customer->mname[0]) ; }else{$mname = '';}?>
			<option value="<?php echo $customer->custid;?>"><?php echo ucfirst($customer->lname) . ', ' . ucfirst($customer->fname). ' ' . $mname . '.';?></option>
			<?php endif;?>
			<?php endforeach;?>
			<?php endif;?>
			
		</select></p>
		<p><label>Vehicle: </label><select name="vehicle">
			<?php if (!empty($vehicles)):?>
			<option value=""></option>
			<?php foreach ($vehicles as $vehicle):?>
			<?php if ($jb->v_id == $vehicle->v_id):?>
			<option value="<?php echo $vehicle->v_id;?>" selected="selected"><?php echo $vehicle->make;?></option>
			<?php else:?>
			<option value="<?php echo $vehicle->v_id;?>"><?php echo $vehicle->make;?></option>
			<?php endif;?>
			<?php endforeach;?>
			<option value=""></option>
			<?php endif;?>
			
		</select></p>
		<p><label>Address:</label> <input type="text" name="addr" value="<?php echo $jb->address;?>"/></p>
		<p><label>Plate:</label> <input type="text" name="plate" value="<?php echo $jb->plate;?>"/></p>
		<p><label>Color: </label><select name="color">
			<option value=""></option>
			<?php if (!empty($colors)):?>
			<option value=""></option>
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
	<table id="entryfield">
		<thead>
			<tr>
				<th>Job Type</th>
				<th class="jotypename">Labor/Parts/Material</td>
				<th>Details</th>
				<th>Amount</th>
				<th>Action</th>
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
	
	<table id="datagrid" class="jodet" >
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
		
		<?php $cnt=0; foreach ($jbo_orders as $jbord):?>
		<?php if($jbord->labor > 0):?>
			<tr>
				<td><?php echo $cnt;?></td>
				<td>labor</td>
				<td><?php echo $jbord->labort;?></td>
				<td></td>
				<td><?php echo $jbord->details;?></td>
				<td><?php echo $jbord->laboramnt;?></td>
				<td><a class="edit" href="#">edit</a>|<a class="delete" href="#">delete</a></td>
				<td></td>
			</tr>
		<?php else :?>
			<tr>
				<td><?php echo $cnt;?></td>
				<td>Parts or Materials</td>
				<td></td>
				<td><?php echo $jbord->partmaterial;?></td>
				<td><?php echo $jbord->details;?></td>
				<td><?php echo $jbord->partmaterialamnt;?></td>
				<td><a class="edit" href="#">edit</a>|<a class="delete" href="#">delete</a></td>
				<td></td>
			</tr>
		<?php endif;?>
		<?php $cnt++; endforeach;?>
		<?php endif;?>
		</tbody>
	</table>
	<p class="submit"><input class="saveorder" type="submit" value="Save"/></p>
	</div>
</div>