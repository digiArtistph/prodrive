<div id="wrapper">
<h3>Feedback</h3>
	<?php if(empty($feedback)):?>
	<p>Opps something goes wrong</p>
	<?php else :?>
	<p><?php echo $feedback;?></p>
	<?php endif;?>
</div>