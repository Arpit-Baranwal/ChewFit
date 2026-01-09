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
        self.num_direction = 1
        self.lstm = nn.LSTM(input_size=input_size, hidden_size=hidden_size, num_layers=num_layers, batch_first=True,
                            bidirectional=True if self.num_direction == 2 else False)
        self.fc = nn.Linear(self.num_direction * hidden_size, num_classes)
        self.train_accuracy = torchmetrics.classification.Accuracy(task="multiclass", num_classes=num_classes)
        self.valid_acc = torchmetrics.classification.Accuracy(task="multiclass", num_classes=num_classes)

    def forward(self, x):
        # Initialize hidden and cell states
        h0 = torch.zeros(self.num_layers * self.num_direction, x.size(0), self.hidden_size).to(self.device)
        c0 = torch.zeros(self.num_layers * self.num_direction, x.size(0), self.hidden_size).to(self.device)

        # Forward propagate LSTM
        out, _ = self.lstm(x, (h0, c0))

        # Decode the hidden state of the last time step
        out = self.fc(out[:, -1, :])
        return out

    def training_step(self, batch, batch_idx):
        x, y = batch
        # batches x seq_len(14) x size(16*224)
        x = x.squeeze(dim=1)
        x = x.reshape(-1, self.sequence_length, self.input_size)
        y_hat = self.forward(x)
        loss = nn.functional.cross_entropy(y_hat, y)
        self.log("train_loss", loss, on_step=True, on_epoch=False)
        self.train_accuracy(y_hat, y)
        self.log('train_acc', self.train_accuracy, on_step=False, on_epoch=True)
        return loss

    def validation_step(self, batch, batch_idx):
        x, y = batch
        x = x.squeeze(dim=1)
        x = x.reshape(-1, self.sequence_length, self.input_size)
        y_hat = self.forward(x)
        loss = nn.functional.cross_entropy(y_hat, y)
        self.valid_acc(y_hat, y)
        self.log("val_loss", loss, on_step=False, on_epoch=True)
        self.log('val_acc', self.valid_acc, on_epoch=True)
        return loss

    def configure_optimizers(self):
        optimizer = optim.Adam(self.parameters(), lr=1e-4)
        return optimizer
