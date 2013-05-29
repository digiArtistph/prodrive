<div class="wrapper">
<h3 class="heading">Edit Customer</h3>
<div class="toolbar"><a class="canceleditbtn" href="<?php echo base_url('master/customer'); ?>">Cancel Edit Customer</a></div>
	<div id="edit_form">
		<?php foreach ($customers as $customer):?>
		<?php echo form_open(base_url() . 'master/customer/validateeditcustomer');?>
		<input type="hidden" value="<?php echo $customer->custid;?>" name="ct_id"/>
		<p><label>First name: </label> <input type="text" name="fname" value="<?php echo $customer->fname;?>" /><?php echo form_error('fname', '<span class="error">', '</span>');?></p>
		<p><label>Middle name: </label> <input type="text" name="mname" value="<?php echo $customer->mname;?>" /><?php echo form_error('mname', '<span class="error">', '</span>');?></p>
		<p><label>Last name: </label> <input type="text" name="lname" value="<?php echo $customer->lname;?>" /><?php echo form_error('lname', '<span class="error">', '</span>');?></p>
		<p><label>Address: </label> <input type="text" name="addr" value="<?php echo $customer->addr;?>" /><?php echo form_error('addr', '<span class="error">', '</span>');?></p>
		<p><label>Phone No. : </label> <input type="text" name="phone" value="<?php echo $customer->phone;?>" /></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
		<?php endforeach;?>
	</div>
</div>