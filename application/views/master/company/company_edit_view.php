<div class="wrapper">
<h3 class="heading">Edit Company</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/company'); ?>">Cancel Edit Company</a></div>
	<div id="add_form">
    <?php if(! empty($companies)): ?>
		<?php echo form_open(base_url() . 'master/company/validateeditcompany');?>
        <?php foreach($companies as $company): ?>
		<p><input type="hidden" name="co_id"  value="<?php echo $company->co_id;?>"/>
		  <label>Company Name </label> <input type="text" name="companyname" value="<?php echo $company->name; ?>" /><?php echo form_error('companyname', '<span class="error">', '</span>');?></p>
		<p>
		  <label>Address </label> <input type="text" name="addr" value="<?php echo $company->addr; ?>"/><?php echo form_error('addr', '<span class="error">', '</span>');?>
          </p>
		<p><label>Phone No.</label>
		  <input type="text" name="phone" value="<?php echo $company->phone; ?>"/><?php echo form_error('phone', '<span class="error">','</span>' );?></p>
		<p>
		  <label>FaxNo.</label> <input type="text" name="fax" value="<?php echo $company->fax; ?>" /><?php echo form_error('fax', '<span class="error">','</span>' );?></p>
          
    <p>
		  <label>Email </label> <input type="text" name="email" value="<?php echo $company->email; ?>" /><?php echo form_error('email', '<span class="error">','</span>' );?></p>
          <p>
		  <label>Website </label> 
		  <input type="text" name="url" value="<?php echo $company->url; ?>"/><?php echo form_error('url', '<span class="error">','</span>' );?></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
<?php endforeach; ?>
<?php else: ?>
	
<?php endif; ?>
	</div>
</div>