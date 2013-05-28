<div id="loginmaincontainer">
	<div id="maindialog">
    	<div class="titlebar">
        	<h4>Prodrive Motowerks System</h4>
        </div>
        <?php echo form_open(base_url('login/validatelogin')); ?>
	        
        <div class="controlgroup">
		<?php if(isset($uerror)){echo '<span class="error">' . $uerror . '</span>';}?>
       		<p><label><i class="sprite loginusernameicon"></i> Username</label><input type="text" name="username" /><?php echo form_error('username');?></p>
            <p><label><i class="sprite loginpasswordicon"></i> Password</label><input type="password" name="pword" /><?php echo form_error('pword');?></p>
            <p class="loginsubmit"><input type="submit" value="Login" /></p>
            <div class="logincalendar">Today is: Tuesday, May 28, 2013</div>
        </div>
        <?php echo form_close(); ?>
    </div>
</div>