<div>
	<h3>Load Data</h3>
	
	<?php echo form_open(base_url() . 'temp/validatebackup');?>
	
	<p><label>Select Source: </label><input class="dir" type="text" name="dir"></p>
	<p><label> Data File: </label>
		<select>
			<option>Select Source</option>
			<option>emyat</option>
			<option>pangit</option>
		</select>
	</p>
	<p><input type="submit" value="Restore" /></p>
	<?php echo form_close();?>
</div>