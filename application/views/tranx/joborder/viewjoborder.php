<div class="wrapper">
<h3 class="heading">Job Order</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Job Order Count: <strong><?php echo $total_rows; ?></strong></p>            
        </div>        
  </div>
<div class="toolbar"><a href="<?php echo base_url(). 'tranx/joborder/section/addjoborder';?>">Add Job Order</a></div>
<div class="pagination-record">
	<div class="pagination-controls">
    	<!--1&nbsp;<a href="#">2</a>&nbsp;<a href="#">3</a>&nbsp;<a href="#">4</a>--><?php echo $paginate; ?>
    </div>
    <div class="record-filter"><select name="viewperpage">
        <option value="10">10</option>
        <option value="20">20</option>
        <option value="30">30</option>
        <option value="50">50</option>
        <option value="75">75</option>
        <option value="100">100</option>
        <option value="-1">All</option>
        </select> per page</div>
    </div>
	<div id="view_form">
	<table class="regdatagrid">
		<thead>
			<tr>
				<th>Order No.</th>
				<th>Vehicle</th>
				<th>Customer</th> 	
				<th>Plate No.</th> 	

				<th>Received Date</th>
				<th>Action</th>
			</tr>
		</thead>
		<tbody>
			<?php if(empty($joborders)):?>
			<tr>
				<td>No Data</td>
			</tr>
			<?php else :?>
			<?php foreach ($joborders as $order):?>
			<tr title="Balance: Php <?php echo sCurrency($order->balance); ?> &nbsp;&nbsp; Payment: Php <?php echo sCurrency($order->payment); ?>">
				<td><?php echo $order->jo_num?></td>
				<td><?php echo $order->vehicle;?></td>
				<td><?php echo ucfirst($order->lname). ', ' . ucfirst($order->fname);?></td>
				<td><?php echo $order->plate;?></td>
				<!--<td><?php echo $order->color;?></td>
				<td><?php echo $order->num;?></td>
				<td><?php echo $order->addr;?></td>-->
				<td><?php echo longDate($order->date);?></td>
				<td><a class="reggrideditbtn" href="<?php echo base_url(). 'tranx/joborder/section/editjoborder/'. $order->jo_id; ?>">Edit</a>|<a class="reggriddelbtn deljo" jocode="<?php echo  $order->jo_id;;?>" href="#">Delete</a></td>
			</tr>
			<?php endforeach;?>
			<?php endif;?>
		</tbody>
	</table>
</div>
<div id="dialog-confirm" title="Delete Record!!!"><p></p></div>	
</div>