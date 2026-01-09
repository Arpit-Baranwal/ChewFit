import torch
import torch.nn as nn
import torch.nn.functional as F
import pytorch_lightning as pl
from torchmetrics.classification import Accuracy
import torch
import math


class PositionalEncoding(nn.Module):
    def __init__(self, d_model, max_len=5000):
        super(PositionalEncoding, self).__init__()

        self.dropout = nn.Dropout(p=0.1)

        pe = torch.zeros(max_len, d_model)
        position = torch.arange(0, max_len, dtype=torch.float).unsqueeze(1)
        div_term = torch.exp(torch.arange(0, d_model, 2).float() * (-math.log(10000.0) / d_model))

        pe[:, 0::2] = torch.sin(position * div_term)
        pe[:, 1::2] = torch.cos(position * div_term)

        self.register_buffer('pe', pe)

    def forward(self, x):
        # x 8x225x512 + 225x512
        x = x + self.pe[:x.size(1), :]
        return self.dropout(x)


class TransformerModel(pl.LightningModule):
    def __init__(self, word_size, output_size, d_model=512, n_head=8, num_layers=6, dim_feedforward=2048, dropout=0.01):
        super(TransformerModel, self).__init__()
        self.embedding_tgt = nn.Linear(output_size, d_model)
        self.word_size = word_size
        self.n_classes = output_size
        # learnable model
        self.embedding = nn.Linear(word_size, d_model)
        self.positional_encoding = PositionalEncoding(d_model)

        self.transformer = nn.Transformer(
            d_model=d_model,
            nhead=n_head,
            num_encoder_layers=num_layers,
            dim_feedforward=dim_feedforward,
            dropout=dropout,
            batch_first=True
        )

        self.train_accuracy = Accuracy(task="multiclass", num_classes=output_size)
        self.val_accuracy = Accuracy(task="multiclass", num_classes=output_size)

        self.fc = nn.Linear(d_model, output_size)

    def forward(self, src, tgt, src_padding, tgt_mask=None):
        x = self.embedding(src)
        x = self.positional_encoding(x)

        tgt = tgt.type(torch.float32)
        y = self.embedding_tgt(tgt)
        output = self.transformer(x, y,
                                  src_key_padding_mask=src_padding,
                                  tgt_mask=tgt_mask)
        output = output.squeeze()
        output = self.fc(output)

        return output

    def __src_tgt_pad(self, source, target, actual_lens):
        seq_length = source.shape[1] // self.word_size

        result_list = (torch.tensor(actual_lens) // self.word_size).to(self.device)
        range_tensor = torch.arange(seq_length).to(self.device)
        mask = range_tensor.unsqueeze(0) < result_list.unsqueeze(1)

        src_padding = mask.float().to(self.device)

        src = source.reshape(-1, seq_length, self.word_size)
        src_padding = src_padding.reshape(-1, seq_length)

        reshaped_tensor = target.view(-1, 1)
        tgt = torch.nn.functional.one_hot(reshaped_tensor, num_classes=self.n_classes)
        return src, tgt, src_padding

    def training_step(self, batch, batch_idx):
        inputs, targets, actual_lens = batch
        src, tgt, src_padd = self.__src_pad(inputs, actual_lens)
        outputs = self(src, tgt, src_padd)

        loss = F.cross_entropy(outputs, targets)
        self.log('train_loss', loss)
        self.train_accuracy(outputs, targets)
        self.log('train_accuracy', self.train_accuracy, on_step=False, on_epoch=True)
        return loss

    def validation_step(self, batch, batch_idx):
        inputs, targets, actual_lens = batch
        src, tgt, src_padd = self.__src_pad(inputs, actual_lens)
        # TODO: make a right mask for this
        target_mask = None
        outputs = self(src, tgt, src_padd, target_mask)

        loss = F.cross_entropy(outputs, targets)
        self.log('val_loss', loss)
        self.val_accuracy(outputs, targets)
        self.log('val_accuracy', self.val_accuracy, on_step=False, on_epoch=True)
        return loss

    def configure_optimizers(self):
        optimizer = torch.optim.Adam(self.parameters(), lr=1e-3)
        return optimizer
