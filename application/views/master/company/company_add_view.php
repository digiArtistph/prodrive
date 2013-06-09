<div class="wrapper">
<h3 class="heading">Add New Company</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/company'); ?>">Cancel New Company</a></div>
	<div id="add_form">
		<?php echo form_open(base_url() . 'master/company/validateaddcompany');?>
		<p>
		  <label>Company Name </label> <input type="text" name="companyname" value="<?php echo set_value('companyname'); ?>" /><?php echo form_error('companyname', '<span class="error">', '</span>');?></p>
		<p>
		  <label>Address </label> <input type="text" name="addr" /><?php echo form_error('addr', '<span class="error">', '</span>');?>
          </p>
		<p><label>Phone No.</label>
		  <input type="text" name="phone" /><?php echo form_error('phone', '<span class="error">','</span>' );?></p>
		<p>
		  <label>FaxNo.</label> <input type="text" name="fax" /><?php echo form_error('fax', '<span class="error">','</span>' );?></p>
          
    <p>
		  <label>Email </label> <input type="text" name="email" /><?php echo form_error('email', '<span class="error">','</span>' );?></p>
          <p>
		  <label>Website </label> 
		  <input type="text" name="url" /><?php echo form_error('url', '<span class="error">','</span>' );?></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
	</div>
</div>