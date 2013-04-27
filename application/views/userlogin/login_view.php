<div>
<h3>User Authorization</h3>
	<?php echo form_open(base_url(). 'login/validatelogin');?>
	<?php if(isset($uerror)){echo $uerror;}?>
	<p><label>Username: </label><input type="text" name="username" /><?php echo form_error('username');?></p>
	<p><label>Password: </label><input type="password" name="pword" /><?php echo form_error('pword');?></p>
	<p><input type="submit" value="login"/></p>
	<?php echo form_close();?>
</div>