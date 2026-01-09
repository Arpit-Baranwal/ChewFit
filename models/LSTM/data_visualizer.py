from signal_dataset import  custom_collate_fn
from signal_dataset import SignalDataset
from utils import visualize_signals
import torch

if __name__ == "__main__":

    train_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/signal_splitted/train"
    val_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/signal_splitted/val"
    test_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/signal_splitted/test"

    train_dataset = SignalDataset(train_folder)
    val_dataset = SignalDataset(val_folder)
    test_dataset = SignalDataset(test_folder)

    batch_size = 16
    train_loader = torch.utils.data.DataLoader(train_dataset, collate_fn=custom_collate_fn, batch_size=batch_size, shuffle=True)
    val_loader = torch.utils.data.DataLoader(val_dataset,collate_fn=custom_collate_fn, batch_size=batch_size)
    test_loader = torch.utils.data.DataLoader(test_dataset,collate_fn=custom_collate_fn, batch_size=batch_size)

    visualize_signals(train_loader, label=2)