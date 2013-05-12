<?php foreach($dcr as $hdrRec): ?>
<?php echo form_open(); ?>
<h3>Daily Collection Entry</h3>
<p><label>Tranx Date: </label><input type="text" name="tranxdate" readonly="readonly" value="<?php echo longDate($hdrRec->trnxdate); ?>"/></p>
<p><label>User: </label><input type="text" name="user"  readonly="readonly" value="<?php echo $hdrRec->username; ?>"/></p>
<p><label>Beginning Balance: </label><input type="text" value="<?php echo $hdrRec->begbal; ?>" readonly="readonly" /></p>
<p><label>Cash Float: </label><input type="text" value="0.00" readonly="readonly" /></p>
<p><label>Cash Lift: </label><input type="text" value="0.00" readonly="readonly" /></p>
<p><label>Total Cash: </label><input type="text" value="0.00" readonly="readonly" /></p>
<p><label>Total Check: </label><input type="text" value="0.00" readonly="readonly" /></p>
<p><label>Grand Total: </label><input type="text" value="0.00" readonly="readonly" /></p>
<div>
<?php endforeach; ?>
<table>
<thead>
<tr>
<th>Particular</th><th>Tender</th><th>Ref No.</th><th>Amount</th><th>Action</th>
</tr>
</thead>
<tbody>
<tr>
<td><input id="particular" name="particular" type="text" /></td>
<td><select id="tender" name="tender">
	<option value="1">Cash</option>
    <option value="2">Check</option>
</select>
</td>
<td><select id="refno" name="refno">
	<option value="">-- Select a reference number</option>
    <option value="JO04302013">JO04302013</option>
    <option value="JO05012013">JO05012013</option>
</select>
</td>
<td>
<input id="amount" type="text" name="amount" />
</td>
<td>
	<input type="submit" value="Add" id="dcr_add_btn" />
</td>
</tr>
</tbody>
</table>

<table  id="dcr_master_details">
<thead>
<tr>
<th>Particular</th><th>Tender</th><th>Ref No.</th><th>Amount</th>
</tr>
</thead>
<tbody>
<td></td>
<td> -- </td>
<td> -- </td>
<td> -- </td>
</tbody>
</table>
<div>

</div>
<?php echo form_close(); ?>