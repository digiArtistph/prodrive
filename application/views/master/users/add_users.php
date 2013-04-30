<div id="container">
<h3>User View</h3>
	<div id="view_form">
	<?php echo form_open( base_url() . 'master/users/validateaddusers' );?>
		<?php if (!empty($error)):?>
		<p><?php echo $error;?></p>
		<?php endif;?>
		<p><label>Username: </label><input type="text" name="username" /><span class="error"><?php echo form_error('username'); ?></span></p>
		<p><label>User type: </label><select name="utype">
			<option value="" selected="selected">Select User Type</option>
			<?php if(!empty($utypes)):?>
				<?php foreach ($utypes as $utype):?>
				<option value="<?php echo $utype->id;?>"><?php echo $utype->type;?></option>
				<?php endforeach;?>
			<?php endif;?>
		</select><span class="error"><?php echo form_error('utype'); ?></span></p>
		<p><label>Password: </label><input type="password" name="pword" /><span class="error"><?php echo form_error('pword'); ?></span></p>
		<p><label>First name: </label><input type="text" name="fname" /><span class="error"><?php echo form_error('fname'); ?></span></p>
		<p><label>Middle name: </label><input type="text" name="mname" /><span class="error"><?php echo form_error('mname'); ?></span></p>
		<p><label>Last name: </label><input type="text" name="lname" /><span class="error"><?php echo form_error('lname'); ?></span></p>
		<p><label>Address: </label><input type="text" name="addr" /><span class="error"><?php echo form_error('addr'); ?></span></p>
		<p><label>Status: </label> Active <input type="radio" name="status" value="1" checked="checked"/> In active<input type="radio" name="status" value="0"/><span class="error"><?php echo form_error('status'); ?></span></p>
		<p><input type="submit" value="Add users" /></p>
	<?php echo form_close();?>
	</div>
</div>