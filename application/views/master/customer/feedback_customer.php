<div class="wrapper">
<h3 class="heading">Feedback</h3>
	<?php if(empty($feedback)):?>
	<p>Opps something goes wrong</p>
	<?php else :?>
	<p><?php echo $feedback;?></p>
	<?php endif;?>
</div>