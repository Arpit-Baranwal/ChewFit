import torch
import torch.nn as nn
import torch.optim as optim
import pytorch_lightning as pl
import torchmetrics

class LSTM(pl.LightningModule):
    def __init__(self, input_size, sequence_length, hidden_size, num_layers, num_classes):
        super(LSTM, self).__init__()
        self.hidden_size = hidden_size
        self.sequence_length = sequence_length
        self.input_size = input_size
        self.num_layers = num_layers
        self.num_direction = 2

        self.train_accuracy = torchmetrics.classification.Accuracy(task="multiclass", num_classes=num_classes)
        self.valid_acc = torchmetrics.classification.Accuracy(task="multiclass", num_classes=num_classes)

        self.lstm = nn.LSTM(input_size=input_size,
                            hidden_size=hidden_size,
                            num_layers=num_layers,
                            batch_first=True,
                            bidirectional=True)

        fc_in_ch = self.num_direction * hidden_size
        self.fc1 = nn.Linear(fc_in_ch, fc_in_ch // 2)
        self.fc2 = nn.Linear(fc_in_ch // 2, num_classes)

    def forward(self, x):
        # Initialize hidden and cell states
        h0 = torch.zeros(self.num_layers * self.num_direction, x.size(0), self.hidden_size).to(self.device)
        c0 = torch.zeros(self.num_layers * self.num_direction, x.size(0), self.hidden_size).to(self.device)

        # Forward propagate LSTM
        out, _ = self.lstm(x, (h0, c0))

        # Decode the hidden state of the last time step
        out = self.fc1(out[:, -1, :])
        out = self.fc2(out)
        return out

    def training_step(self, batch, batch_idx):
        x, y, _ = batch
        # batches x 11 x in_size
        x = x.reshape(-1, self.sequence_length, self.input_size)
        y_hat = self.forward(x)
        loss = nn.functional.cross_entropy(y_hat, y)
        self.train_accuracy(y_hat, y)
        # tb_log = {'train_loss': loss}
        self.log("train_loss", loss, on_step=True, on_epoch=False)
        self.log('train_acc', self.train_accuracy, on_step=False, on_epoch=True)
        return loss

    def validation_step(self, batch, batch_idx):
        x, y, _ = batch
        x = x.reshape(-1, self.sequence_length, self.input_size)
        y_hat = self.forward(x)
        loss = nn.functional.cross_entropy(y_hat, y)
        self.valid_acc(y_hat, y)
        self.log("val_loss", loss, on_step=False, on_epoch=True)
        self.log('val_acc', self.valid_acc, on_epoch=True)
        return loss

    def on_training_epoch_end(self, outputs) -> None:
        loss = sum(output['loss'] for output in outputs) / len(outputs)
        print(f'on epoch training loss is {loss}')
    def configure_optimizers(self):
        return torch.optim.Adam(self.parameters(), lr=1e-4)

