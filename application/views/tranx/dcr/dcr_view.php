<div class="wrapper">
<h3 class="heading">Daily Cash Entry</h3>
<?php foreach($dcr as $hdrRec): ?>
    <div class="minidashboard">
    	<div class="panelOne">
        	<p>Begining Balance: Php <?php echo $hdrRec->begbal; ?></p>
            <p>Grand Total: Php</p>
        </div>
        <div class="panelTwo">
        	<p>Cash Float: Php 250.00</p>
            <p>Cash Lift: Php 500.00</p>
        </div>
         <div class="panelThree">
        	<p>Total Check: Php 2500.00</p>
            <p>Total Cash: Php 1500.00</p>
        </div>
    </div><div class="cleafix">&nbsp;</div>

<?php echo form_open(); ?>
<input id="dcr_id" type="hidden" value="<?php echo $hdrRec->dcr_id; ?>" />
<?php endforeach; ?>

<div id="dcrdatagrid">

</div>

<?php echo form_close(); ?>

</div>