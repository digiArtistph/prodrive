<div class="wrapper">
<h3 class="heading">Customers</h3>
<div class="minidashboard">
    	<div class="panelOne"><p>Customer Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/customer/section/addcustomer'; ?>">Add New Customer</a>	
</div>
	<?php getPagination(); ?>
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
            	<td><?php echo search_highlight((isset($search_keyword)) ? $search_keyword : '', $customer->fullname); ?></td>
                <td><?php if( empty($customer->addr) ){echo 'No Address';}else{ echo $customer->addr;}?></td>
                <td><?php if( empty($customer->phone) ){echo 'No Phone number';}else{ echo $customer->phone;}?></td>
                <td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/customer/section/editcustomer/' . $customer->custid;?>">Edit</a>|<a class="reggriddelbtn delete-record-view" href="#" post-url="master/customer/ajaxdelcust" code="<?php echo $customer->custid;?>">Delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No Customers Found.</p>
	<?php endif;?>
	</div>
    
<div id="dialog-confirm" title="Delete Record"><p></p></div>
<?php getPagination(); ?>
</div>