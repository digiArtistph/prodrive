<div id="wrapper">
<h3>Add Customer</h3>
	<div id="add_form">
		<?php echo form_open(base_url() . 'master/customer/validateaddcustomer');?>
		<p><label>First name: </label> <input type="text" name="fname" /><span class="error"><?php echo form_error('fname');?></span></p>
		<p><label>Middle name: </label> <input type="text" name="mname" /><span class="error"><?php echo form_error('mname');?></span></p>
		<p><label>Last name: </label> <input type="text" name="lname" /><span class="error"><?php echo form_error('lname');?></span></p>
		<p><label>Address: </label> <input type="text" name="addr" /><span class="error"><?php echo form_error('addr');?></span></p>
		<p><label>Phone No. : </label> <input type="text" name="phone" /><span class="error"><?php echo form_error('phone');?></span></p>
		<p><label>Status :</label> 
		Active <input type="radio" name="cu_status" checked="checked" value="1"/>
		In active <input type="radio" name="cu_status"  value="0"/><span class="error"><?php echo form_error('cu_status');?></span></p>
		<p><input type="submit" value="Add Customer"/></p>
		<?php echo form_close();?>
	</div>
</div>