
<div class="wrapper">
<div>
	<h3>Quick Search - Job Orders</h3>
    <?php echo form_open(); ?>
    <?php
		/*if(isset($_POST['customer'])) {
			call_debug($_POST);	
		}*/
	?>
    	<p><label>Customer</label><input type="text" name="customer"  /></p>
        <p><label>Plate No</label><input type="text" name="plateno" /></p>
        	<fieldset>
            	<legend>Date</legend>
                <label>From</label><input class="datepicker" type="text" name="datefrom" />
                <label>To</label><input class="datepicker" type="text" name="dateto" />
            </fieldset>
        <p><label for="jounpaid"><input type="checkbox" id="jounpaid" name="jounpaid"  />Include unpaid job orders</label></p>
        <p><label for="jopaid"><input type="checkbox" id="jopaid" name="jopaid" />Include paid job orders</label></p>
        <p><input type="submit" value="Search" /></p>
    <?php echo form_close(); ?>
</div>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Job Order Count: <strong><?php echo $total_rows; ?></strong></p>            
        </div>        
  </div>
<!--<div class="toolbar"><a href="<?php echo base_url(). 'tranx/joborder/section/addjoborder';?>">Add Job Order</a></div>-->
<div class="clearfix"></div>
	<div id="view_form">
	<table class="regdatagrid">
		<thead>
			<tr>
				<th>Order No.</th>
				<!--<th>Vehicle</th>-->
				<th>Customer</th> 	
				<th>Plate No.</th> 	

				<th>Received Date</th>
				<th>Action</th>
			</tr>
		</thead>
		<tbody>
			<?php if(empty($joborders)):?>
			<tr>
				<td>No Job Orders Found.</td>
			</tr>
			<?php else :?>
			<?php foreach ($joborders as $order):?>
			<tr title="Balance: Php <?php echo sCurrency($order->balance); ?> &nbsp;&nbsp; Payment: Php <?php echo sCurrency($order->payment); ?>">
				<td><?php echo $order->jo_num?></td>
				<!--<td><?php echo $order->vehicle;?></td>-->
				<td><?php echo search_highlight((isset($search_keyword)) ? $search_keyword : '',$order->owner);?></td>
				<td><?php echo search_highlight((isset($search_keyword)) ? $search_keyword : '', $order->plate);?></td>
				<!--<td><?php echo $order->color;?></td>
				<td><?php echo $order->num;?></td>
				<td><?php echo $order->addr;?></td>-->
				<td><?php echo longDate($order->date);?></td>
				<td><a class="reggrideditbtn" href="<?php echo base_url(). 'tranx/joborder/section/editjoborder/'. $order->jo_id; ?>">View</a></td>
			</tr>
			<?php endforeach;?>
			<?php endif;?>
		</tbody>
	</table>
    	
</div>

<div id="dialog-confirm" title="Delete Record!!!"><p></p></div>	
</div>