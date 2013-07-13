<?php
	
?>
<div class="wrapper">
<h3 class="heading">Job Order</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Total Payable: Php <strong><span class="total_amount"><?php echo sCurrency($total); ?></span></strong></p>
			<p>
        		Payment: Php <strong><span class="total_amount"><?php echo sCurrency($payments); ?></span></strong>

            </p>
            <p>
        		Balance: Php <strong><span class="total_amount"><?php echo sCurrency($balance); ?></span></strong>
        	</p>
    </div>        
    </div>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('tranx/joborder'); ?>">Cancel Edit Job Order</a> &nbsp; <a href="#">Bill to customer</a> &nbsp; <!--<a class="jotagaspaidbtn" href="#">Fully paid</a>-->  </div>
	<div id="add_form">
	<div class="suggestion"  style="height: 20px"><p><span class="error"></span></p></div>
    <div class="jovehicledialog">
    	<select style="width:100%; height:100%;" name="jovehicleselection" multiple="multiple">
        
        </select>
    </div>
    <?php if(!empty($jbo_order)):?>
    <?php foreach ($jbo_order as $order):?>
	<form class="jo_form">
		<input class="joborderid" type="hidden" name="joborderid" value="<?php echo $order->id;?>"/>

		<p><label>Job Order No.</label> <input readonly="readonly" type="text" name="jo_number" value="<?php echo $order->number;?>" /></p>

		<p><label>Date</label> <input class="datepicker" type="text" name="jo_date" value="<?php echo $order->trnxdate;?>" /></p>
		<p><label>Customer </label> <input name="cust_id" class="cust_id" type="hidden" value="<?php echo $order->custid;?>"/><input class="jocustomer" type="text" name="customer" value="<?php echo $order->custname;?>"/><?php echo form_error('customer', '<span class="error">','</span>'); ?></p>
		<p><label>Vehicle </label><input name="v_id" class="v_id" type="hidden" value="<?php echo $order->vehicleid;?>"/><input readonly="readonly" tabindex="0" class="vehicle" type="text" name="vehicle" value="<?php echo $order->plate;?>"/></p>
		<p><label>WithholdingTax</label>
	    <input  type="text" name="tax" value="<?php echo $order->tax;?>"/></p>
      <p><label>Discount</label> <input  type="text" name="discount" value="<?php echo $order->discount;?>" /></p>
		
	</form>
	<?php endforeach;?>
	
	<div class="jo_buildform">
			<table class="jodet regdatagrid">
				<thead>
					<tr>
						<th>No.</th>
						<th>Job Type</th>
						<th>Labor</th>
						<th>Parts/Material</th>
						<th>Details</th>
						<th>Amount</th>
						<th>Action</th>
					</tr>
				</thead>
				<?php if ( !empty($jbo_det) ):?>
				<tbody class="jo_orders">
					<?php $cnt=1; foreach ($jbo_det as $ordet):?>
					<tr id="<?php echo $ordet->trace_id;?>" lbr="<?php echo $ordet->labor;?>">
						<td><?php echo $cnt;?></td>
						
						<?php if($ordet->labor == 0):?>
						<td>Parts or Material</td>
						<td></td>
						<td><?php echo $ordet->partmaterial;?></td>
						<?php else:?>
						<td>Labor</td>
						<td><?php echo $ordet->lbrname;?></td>
						<td></td>
						<?php endif;?>
						
						<td><?php echo $ordet->details;?></td>
						<td><?php echo $ordet->amnt;?></td>
						<td><a class="edit_jodet reggrideditbtn" href="#">Edit</a> | <a class="del_jodet reggriddelbtn" href="#">Delete</a>
						</td>
					</tr>
					<?php $cnt++; endforeach;?>
				</tbody>
				<?php endif;?>
			</table>
		</div>

	<p class="jo-save-btn"><input class="submitedit" type="submit" value="Save"/></p>
	</div>
	<?php endif;?>
<div id="dialogerror"><p></p></div>
</div>

<div id="dialog-close-jo">
	<p>Tagging this job order as "Paid" will remove from the current list of job orders. Are you sure?</p>
</div>