<div class="wrapper">
<h3 class="heading">Daily Cash Entry</h3>
<?php foreach($dcr as $hdrRec): ?>
    <div class="minidashboard">
    	<div class="panelOne">
        	<p>Begining Balance: Php <?php echo $hdrRec->begbal; ?></p>
            <p>Cash on Hand: Php <?php echo $coh; ?></p>
        </div>
        <div class="panelTwo">
        	<p>Cash Float: Php <?php echo $cashfloat; ?></p>
            <p>Cash Lift: Php <?php echo $cashfloat; ?></p>
        </div>
         <div class="panelThree">
        	<p>Total Check: Php <?php echo $salescheck; ?></p>
            <p>Total Cash: Php <?php echo $salescash; ?></p>
        </div>
    </div><div class="cleafix">&nbsp;</div>

<?php echo form_open(); ?>
<input id="dcr_id" type="hidden" value="<?php echo $hdrRec->dcr_id; ?>" />
<?php endforeach; ?>

<div id="dcrdatagrid">

</div>

<?php echo form_close(); ?>

</div>