<div class="wrapper">
<h3 class="heading">Edit Customer</h3>
<div class="toolbar"><a class="canceleditbtn" href="<?php echo base_url('master/customer'); ?>">Cancel Edit Customer</a></div>
	<div id="edit_form">
		<?php foreach ($customers as $customer):?>
		<?php echo form_open(base_url() . 'master/customer/validateeditcustomer');?>
		<input type="hidden" value="<?php echo $customer->custid;?>" name="ct_id"/>
		<p>
		  <label>First Name </label> <input type="text" name="fname" value="<?php echo $customer->fname;?>" /><?php echo form_error('fname', '<span class="error">', '</span>');?></p>
		<p>
		  <label>Middle Name </label> <input type="text" name="mname" value="<?php echo $customer->mname;?>" /><?php echo form_error('mname', '<span class="error">', '</span>');?></p>
		<p>
		  <label>Last Name </label> <input type="text" name="lname" value="<?php echo $customer->lname;?>" /><?php echo form_error('lname', '<span class="error">', '</span>');?></p>
		<p>
		  <label>Address </label> <input type="text" name="addr" value="<?php echo $customer->addr;?>" /><?php echo form_error('addr', '<span class="error">', '</span>');?></p>
          <p>
		  <label>Company </label>
          <select name="company">
		  	<option value="">-- Select a company --</option>
            <?php foreach($companies as $company): ?>
            	<option <?php echo ($customer->company == $company->co_id) ? 'selected="selected"' : '' ; ?> value="<?php echo $company->co_id; ?>"><?php echo $company->name; ?></option>
            <?php endforeach; ?>
		  </select></p>
		<p>
		  <label>Phone No.  </label> <input type="text" name="phone" value="<?php echo $customer->phone;?>" /><?php echo form_error('phone', '<span class="error">', '</span>');?></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
		<?php endforeach;?>
	</div>
</div>