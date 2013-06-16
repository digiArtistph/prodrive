<div class="wrapper">
<h3 class="heading">Vehicle</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Category Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
  </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/vehicle/section/addvehicle'; ?>">Add New Vehicle</a></div>
<div class="clearthis">&nbsp;</div>
<div class="pagination-record">
	<div class="pagination-controls">
    	<?php echo $paginate; ?>
    </div>
    
    <div class="record-filter">
	    <?php if($paginate !=""): ?>
            View <select name="viewperpage">
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="30">30</option>
            <option value="50">50</option>
            <option value="75">75</option>
            <option value="100">100</option>
            <option value="-1">All</option>
            </select> per page
        <?php endif; ?>
        </div>
    </div>
	<div id="view_form">
		<?php if(!empty($vehicles)):?>
		<table class="regdatagrid">
    	<thead>
        	<tr> 
            	<th>Make</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($vehicles as $vehicle):?>
        	<tr>
        		<td><?php echo $vehicle->make;?></td>        		
        		<td><a class="reggrideditbtn" href="<?php echo base_url(). 'master/vehicle/section/editvehicle/' . $vehicle->v_id; ?>">Edit</a>|<a class="reggriddelbtn delete-record-view" post-url="master/vehicle/ajaxdelveh" code="<?php echo $vehicle->v_id;?>" href="#">Delete</a></td>
        	</tr>
        <?php endforeach;?>
        </tbody>
        </table>
		<?php else:?>
		<p>No Vehicles</p>
		<?php endif;?>
	</div>
    <div class="clearthis">&nbsp;</div>
<div class="pagination-record">
	<div class="pagination-controls">
    	<?php echo $paginate; ?>
    </div>
    
    <div class="record-filter">
	    <?php if($paginate !=""): ?>
            View <select name="viewperpage">
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="30">30</option>
            <option value="50">50</option>
            <option value="75">75</option>
            <option value="100">100</option>
            <option value="-1">All</option>
            </select> per page
        <?php endif; ?>
        </div>
    </div>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>