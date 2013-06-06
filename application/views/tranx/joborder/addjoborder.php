<div class="wrapper">
<h3 class="heading">Job Order</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Total : Php <strong><span class="total_amount">0.00<?php echo ''; ?></span></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('tranx/joborder'); ?>">Cancel New Job Order</a></div>
	<div id="add_form">
	<div class="suggestion"  style="height: 20px"><p><span class="error"></span></p></div>
	<form class="jo_form">
		<input class="joborderid" type="hidden" name="joborderid" value="0"/>
		<p><label>Job Order No.</label> <input readonly="readonly" type="text" name="jo_number" value="" /></p>
		<p><label>Date</label> <input class="datepicker" type="text" name="jo_date" value="<?php echo curdate();?>" /></p>
		<p><label>Customer </label> <input class="cust_id" type="hidden" value="<?php echo set_value('cust_id'); ?>"/><input class="jocustomer" type="text" name="customer" value="<?php echo set_value('customer'); ?>"/><?php echo form_error('customer', '<span class="error">','</span>'); ?></p>
		
		<p><label>Vehicle </label><input class="v_id" type="hidden" value="0"/><input readonly="readonly" class="vehicle" type="text" name="vehicle" /></p>
		
		
		<p><label>Plate</label> <input readonly="readonly" type="text" name="plate"/></p>
		
	</form>

	<div class="jo_buildform">
	</div>

	<p class="submit"><input class="saveorder" type="submit" value="Save"/></p>
	</div>
</div>