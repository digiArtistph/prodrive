<div id="wrapper">
<h3>Customer View</h3>
	<div id="view_form">
	<?php if(! empty( $customers ) ):?>
	
	<table>
    	<thead>
        	<tr> 
            	<th>Name</th>     
            	<th>Address</th>
            	<th>Phone</th>
            	<th>Status</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
		<?php foreach ($customers as $customer):?>
			<tr>
            	<td><?php if( empty($customer->fname) && empty($customer->mname) && empty($customer->lname) ){echo 'No Name Acquired';} ?><?php if(!empty($customer->fname)){  echo ucfirst($customer->fname);}?> <?php if(!empty($customer->mname)){ echo ucfirst($customer->mname[0]) . '.';}?> <?php if(!empty($customer->lname)){ echo ucfirst($customer->lname);}?></td>
                <td><?php if( empty($customer->addr) ){echo 'No Address';}else{ echo $customer->addr;}?></td>
                <td><?php if( empty($customer->phone) ){echo 'No Phone number';}else{ echo $customer->phone;}?></td>
                <td><?php if ( $customer->status == 1){ echo 'Active';}else{ echo 'In Active';}?></td>
                <td><a href="<?php echo base_url() . 'master/customer/section/editcustomer/' . $customer->custid;?>">edit</a>|<a href="<?php echo base_url() . 'master/customer/section/deletecustomer/' . $customer->custid;?>">delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No Customer Added!!!</p>
	<?php endif;?>
	</div>
	<p><a href="<?php echo base_url() . 'master/customer/section/addcustomer'; ?>">Add Customer</a></p>
</div>