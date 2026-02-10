<div class="users index">
	<h2><?= __('Users') ?></h2>
	<table cellpadding="0" cellspacing="0">
		<thead>
			<tr>
				<th><?= $this->Paginator->sort('id') ?></th>
				<th><?= $this->Paginator->sort('username') ?></th>
				<th><?= $this->Paginator->sort('email') ?></th>
				<th><?= $this->Paginator->sort('created') ?></th>
				<th class="actions"><?= __('Actions') ?></th>
			</tr>
		</thead>
		<tbody>
			<?php foreach ($users as $user): ?>
			<tr>
				<td><?= h($user->id) ?></td>
				<td><?= h($user->username) ?></td>
				<td><?= h($user->email) ?></td>
				<td><?= h($user->created->format('Y-m-d')) ?></td>
				<td class="actions">
					<?= $this->Html->link(__('View'), ['action' => 'view', $user->id]) ?>
					<?= $this->Html->link(__('Edit'), ['action' => 'edit', $user->id]) ?>
				</td>
			</tr>
			<?php endforeach; ?>
		</tbody>
	</table>
	<?= $this->Paginator->numbers() ?>
</div>
