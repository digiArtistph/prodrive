<div class="wrapper">
<h3 class="heading">Job Order</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Total : Php <strong><span class="total_amount">0.00<?php echo ''; ?></span></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('tranx/joborder'); ?>">Cancel New Job Order</a></div>
	<div id="add_form">
	<div class="suggestion"  style="height: 20px"><p><span class="error"></span></p></div>
    <div class="jovehicledialog">
    	<select style="width:100%; height:100%;" name="jovehicleselection" multiple="multiple">
        
        </select>
    </div>
	<form class="jo_form">
		<input class="joborderid" type="hidden" name="joborderid" value="0"/>

		<p><label>Job Order No.</label> <input disabled="disabled" type="text" name="jo_number" value="<?php echo dmax(); ?>" /></p>

		<p><label>Date</label> <input class="datepicker" type="text" name="jo_date" value="<?php echo curdate();?>" /></p>
		<p><label>Customer </label> <input name="cust_id" class="cust_id" type="hidden" value="<?php echo set_value('cust_id'); ?>"/><input tabindex="1" class="jocustomer" type="text" name="customer" value="<?php echo set_value('customer'); ?>"/><?php echo form_error('customer', '<span class="error">','</span>'); ?></p>
		<p><label>Vehicle </label><input name="v_id" class="v_id" type="hidden" value="0"/><input disabled="disabled" tabindex="2" class="vehicle" type="text" name="vehicle" /></p>
		<p><label>Tax</label> <input tabindex="3"  type="text" name="tax" value="0.00"/></p>
        <p><label>Discount</label> <input tabindex="4"  type="text" name="discount" value="0.00"/></p>

		
	</form>

	<div class="jo_buildform">
	</div>

	<p class="submit"><input class="saveorder" type="submit" value="Save"/></p>
	</div>
<div id="dialogerror"><p></p></div>
</div>