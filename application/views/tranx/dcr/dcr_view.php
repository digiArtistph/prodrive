<div class="wrapper">
<h3 class="heading">Daily Collection Entry</h3>
<?php foreach($dcr as $hdrRec): ?>
    <div class="minidashboard">
    	<div class="panelOne">
        	<p>Begining Balance: Php <?php echo $hdrRec->begbal; ?></p>
            <p>Cash on Hand: Php <?php echo $coh; ?></p>
        </div>
        <div class="panelTwo">
        	<p>Cash Float: Php <?php echo $cashfloat; ?></p>
            <p>Cash Lift: Php <?php echo $cashlift; ?></p>
        </div>
         <div class="panelThree">
        	<p>Total Check: Php <?php echo $salescheck; ?></p>
            <p>Total Collection: Php <?php echo $salescash; ?></p>
        </div>
    </div><div class="cleafix">&nbsp;</div>

<?php echo form_open(); ?>
<input id="dcr_id" type="hidden" value="<?php echo $hdrRec->dcr_id; ?>" />
<?php endforeach; ?>

<div id="dcrdatagrid">

</div>

<?php echo form_close(); ?>
    <div id="dcr_dialog">
		<p class="curJoBalance" style="display:none;"></p>
        <select disabled="disabled" name="jovehicleselection" 
        multiple="multiple">
		
        </select>
        <p class="dcrpaymentamnt">Payment: Php 0.00</p>
        <p class="jobalanceamnt">Balance: Php 0.00</p>
        <p><label>Particulars: </label><input class="dcrparticular" type="text" name="dcrparticular" /></p>
    </div>
</div>