<div class="wrapper">
	
    <h3 class="heading">Current Backup Data</h3>
    <div class="minidashboard">
    	<div class="panelOne">        	<p>Backup Database Count: <strong><?php echo ''; ?></strong></p>            
        </div>        
    </div>
    <table class="regdatagrid">
    	
	<?php if(empty($sqlfiles)):?>
	<thead>
        	<tr> 
            	<th>Stored data on datawarehouse</th> 
            </tr>
       </thead>
		<tbody>
			<tr>
				<td colspan="2">NO BACKUP DATABASE FOUND</td>
			</tr>
	<?php else:?>
		<thead>
        	<tr> 
        		<th>No.</th> 
            	<th>Prodrive Database</th> 
            	<th>Action</th> 
            </tr>
        </thead>
		<tbody>
		<?php $cnt = 1; foreach ($sqlfiles as $file):?>
			<tr>
				<td><?php echo $cnt; $cnt++;?></td>
				<td><?php echo $file;?></td>
				<td><a class="restore_db" href="#">Restore</a></td>
			</tr>
		<?php endforeach;?>
	<?php endif;?>
        </tbody>
    </table>
    <div class="dialog" title="Restoring Database">
    	 <p></p>
    </div>
</div>