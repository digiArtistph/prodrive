<?php echo form_open(); ?>
<h3>Daily Collection Entry</h3>

<p><label>Tranx Date: </label><input type="text" name="tranxdate" /></p>
<p><label>User: </label><input type="text" name="user" /></p>
<div>
<table>
<thead>
<tr>
<th>Particular</th><th>Tender</th><th>Ref No.</th><th>Amount</th>
</tr>
</thead>
<tbody>
<tr>
<td><input name="particular" type="text" /></td>
<td><select name="tender">
	<option value="1">Cash</option>
    <option value="2">Check</option>
</select>
</td>
<td><select name="refno">
	<option value="">-- Select a reference number</option>
    <option value="1">JO04302013</option>
    <option value="1">JO05012013</option>
</select>
</td>
<td>
<input type="text" name="amount" />
</td>
</tr>
</tbody>
</table>

<table>
<thead>
<tr>
<th>Particular</th><th>Tender</th><th>Ref No.</th><th>Amount</th>
</tr>
</thead>
<tbody>

</tbody>
</table>
<div>
<p><label>Cashier: </label><input type="text" /></p>
</div>
<?php echo form_close(); ?>