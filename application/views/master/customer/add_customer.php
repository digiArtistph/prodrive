<div class="wrapper">
<h3 class="heading">Add New Customer</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/customer'); ?>">Cancel New Customer</a></div>
	<div id="add_form">
		<?php echo form_open(base_url() . 'master/customer/validateaddcustomer');?>
		<p>
		  <label>First Name </label> <input type="text" name="fname" /><?php echo form_error('fname', '<span class="error">', '</span>');?></p>
		<p>
		  <label>Middle Name </label> <input type="text" name="mname" /><?php echo form_error('mname', '<span class="error">', '</span>');?></p>
		<p>
		  <label>Last Name </label> <input type="text" name="lname" /><?php echo form_error('lname', '<span class="error">','</span>' );?></p>
		<p>
		  <label>Address </label> <input type="text" name="addr" /><?php echo form_error('addr', '<span class="error">','</span>' );?></p>
          <p>
		  <label>Company </label>
          <select name="company">
		  	<option value="">-- Select a company --</option>
            <?php foreach($companies as $company): ?>
            	<option value=""><?php echo $company->name; ?></option>
            <?php endforeach; ?>
		  </select></p>
		<p>
		  <label>Phone No. </label> <input type="text" name="phone" /><?php echo form_error('phone', '<span class="error">','</span>' );?></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
	</div>
</div>