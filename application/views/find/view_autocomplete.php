<div>
	<form>
		<p><label>Search on Table: </label>
			<select class="find_tbl">
				<option value="">select table</option>
				<?php if(!empty($tables)):?>
				<?php foreach ( $tables as $table):?>
				<option value="<?php echo $table;?>"><?php echo $table;?></option>
				<?php endforeach;?>
				<?php endif;?>
			</select>
		</p>
		<p><label>Table Column: </label><input class="find_tblclmn"  type="text" /></p>
		<p><label>Find: </label><input class="find_val"  type="text" /></p>
		
	</form>
</div>