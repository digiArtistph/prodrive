<div>
	<h3>Load Data</h3>
	
	<?php echo form_open(base_url() . 'temp/validaterestore');?>
	
	<p><label>Select Source: </label><input class="dir" type="text" name="dir"></p>
	<p><label> Data File: </label>
		<select class="datafile" name="datafile">
			<option selected="selected" value="">Select source file</option>
		</select>
	</p>
	<p><input type="submit" value="Restore" /></p>
	<?php echo form_close();?>
</div>