<?php foreach($dcr as $hdrRec): ?>
<?php echo form_open(); ?>
<h3>Daily Collection Entry</h3>
<p><label>Tranx Date: </label><input type="text" name="tranxdate" value="<?php echo longDate($hdrRec->trnxdate); ?>"/></p>
<p><label>User: </label><input type="text" name="user"  readonly="readonly" value="<?php echo $hdrRec->username; ?>"/></p>
<p><label>Beginning Balance: </label><input type="text" value="<?php echo $hdrRec->begbal; ?>" readonly="readonly" /></p>
<p><label>Cash Float: </label><input type="text" value="0.00" readonly="readonly" /></p>
<p><label>Cash Lift: </label><input type="text" value="0.00" readonly="readonly" /></p>
<p><label>Total Cash: </label><input type="text" value="0.00" readonly="readonly" /></p>
<p><label>Total Check: </label><input type="text" value="0.00" readonly="readonly" /></p>
<p><label>Grand Total: </label><input type="text" value="0.00" readonly="readonly" /></p>

<?php endforeach; ?>

<div id="dcrdatagrid">

</div>
<?php echo form_close(); ?>