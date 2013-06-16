<div class="wrapper">
<h3 class="heading">Customers</h3>
<div class="minidashboard">
    	<div class="panelOne"><p>Customer Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/customer/section/addcustomer'; ?>">Add New Customer</a>	
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
        <?php endif; ?></div>
    </div>
	<div id="view_form">
	<?php if(! empty( $customers ) ):?>
	
	<table class="regdatagrid">
    	<thead>
        	<tr> 
            	<th>Name</th>     
            	<th>Address</th>
            	<th>Phone</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
		<?php foreach ($customers as $customer):?>
			<tr>
            	<td><?php echo $customer->fullname; ?></td>
                <td><?php if( empty($customer->addr) ){echo 'No Address';}else{ echo $customer->addr;}?></td>
                <td><?php if( empty($customer->phone) ){echo 'No Phone number';}else{ echo $customer->phone;}?></td>
                <td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/customer/section/editcustomer/' . $customer->custid;?>">Edit</a>|<a class="reggriddelbtn delete-record-view" href="#" post-url="master/customer/ajaxdelcust" code="<?php echo $customer->custid;?>">Delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No Customer Added!!!</p>
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
        <?php endif; ?></div>
    </div>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>