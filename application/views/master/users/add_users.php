<div class="wrapper">
<h3 class="heading">Add New User</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/users'); ?>">Cancel New User</a></div>
	<div id="add_form">
	<?php echo form_open( base_url() . 'master/users/validateaddusers' );?>
		<?php if (!empty($error)):?>
		<p><?php echo $error;?></p>
		<?php endif;?>
		<p>
		  <label>Username </label><input type="text" name="username" value="<?php echo set_value('username'); ?>"/><?php echo form_error('username', '<span class="error">', '</span>'); ?></p>
		<p>
		  <label>User Type </label><select name="utype">
			<option value="" selected="selected">-- Select user type --</option>
			<?php if(!empty($utypes)):?>
				<?php foreach ($utypes as $utype):?>
				<option value="<?php echo $utype->id;?>"><?php echo $utype->type;?></option>
				<?php endforeach;?>
			<?php endif;?>
		</select><?php echo form_error('utype', '<span class="error">', '</span>'); ?></p>
		<p>
		  <label>Password </label><input type="password" name="pword" /><?php echo form_error('pword', '<span class="error">', '</span>'); ?></span></p>
		<p>
		  <label>First Name </label><input type="text" name="fname" value="<?php echo set_value('fname'); ?>"/><?php echo form_error('fname', '<span class="error">', '</span>'); ?></p>
		<p>
		  <label>Middle Name </label><input type="text" name="mname" value="<?php echo set_value('mname'); ?>"/><?php echo form_error('mname', '<span class="error">', '</span>'); ?></p>
		<p>
		  <label>Last Name </label><input type="text" name="lname" value="<?php echo set_value('lname'); ?>" /><?php echo form_error('lname', '<span class="error">', '</span>'); ?></p>
		<p>
		  <label>Address </label><input class="email" type="text" name="addr" value="<?php echo set_value('addr'); ?>"/><?php echo form_error('addr', '<span class="error">', '</span>'); ?></p>
		<p class="submit"><input type="submit" value="Save"/></p>
	<?php echo form_close();?>
	</div>
</div>