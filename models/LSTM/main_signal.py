import sys

from model_signal import LSTM
from utils import signal_dim
from utils import visualize_signals
from signal_dataset import custom_collate_fn
from signal_dataset import SignalDataset
import pytorch_lightning as pl
import torch

if __name__ == '__main__':
    train_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/signal_splitted/train"
    val_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/signal_splitted/val"
    test_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/signal_splitted/test"

    train_dataset = SignalDataset(train_folder)
    val_dataset = SignalDataset(val_folder)
    test_dataset = SignalDataset(test_folder)

    batch_size = 8
    train_loader = torch.utils.data.DataLoader(train_dataset, collate_fn=custom_collate_fn, batch_size=batch_size,
                                               shuffle=True)
    val_loader = torch.utils.data.DataLoader(val_dataset, collate_fn=custom_collate_fn, batch_size=batch_size)
    test_loader = torch.utils.data.DataLoader(test_dataset, collate_fn=custom_collate_fn, batch_size=batch_size)

    classes, signal_dim = signal_dim(train_loader)

    if 0:
        visualize_signals(train_loader, label=0)
        sys.exit(0)


    # each batches has its own lenght of signals but note that it is padded by collate_fn
    # max length is 30016 which is dividable to 64,32,16,8,4,2,1 ~ [469,938,...]
    input_size = 407
    sequence_length = 64
    hidden_size = 128
    num_classes = classes

    model = LSTM(input_size=input_size,
                 sequence_length=sequence_length,
                 hidden_size=hidden_size,
                 num_layers=8,
                 num_classes=num_classes)

    # Create a trainer
    trainer = pl.Trainer(deterministic=True, max_epochs=30, accelerator='gpu', devices=1)

    # Train the model
    trainer.fit(model, train_loader, val_loader)
