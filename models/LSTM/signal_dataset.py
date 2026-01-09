import numpy as np
import torch
import os
from torch.utils.data import Dataset
from torch.nn.utils.rnn import pad_sequence


class SignalDataset(Dataset):
    def __init__(self, data_folder, transform=None):
        self.transform = transform
        self.root_dir = data_folder
        self.transform = transform

        self.classes = sorted(os.listdir(data_folder))
        self.class_to_idx = {class_name: i for i, class_name in enumerate(self.classes)}

        self.samples = []
        for class_name in self.classes:
            class_dir = os.path.join(data_folder, class_name)
            file_names = os.listdir(class_dir)
            for file_name in file_names:
                file_path = os.path.join(class_dir, file_name)
                self.samples.append((file_path, self.class_to_idx[class_name]))

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, index):
        file_path, label = self.samples[index]
        data = []
        with open(file_path, 'r') as file:
            for line in file:
                value = float(line.strip())
                data.append(value)

        if self.transform:
            data = self.transform(data)

        return torch.tensor(data), label


def custom_collate_fn(batch):
    desired_length = 26048
    sequences, labels = zip(*batch)
    sorted_batch = sorted(zip(sequences, labels), key=lambda x: x[0].size(0), reverse=True)
    sorted_sequences, sorted_labels = zip(*sorted_batch)

    # Pad sequences to the desired length
    padded_sequences = []
    for seq in sorted_sequences:
        pad_length = desired_length - seq.size(0)
        padded_seq = torch.nn.functional.pad(seq, (0, pad_length), value=-np.inf)
        padded_sequences.append(padded_seq)

    # Convert the padded sequences into a batch tensor
    padded_batch = torch.stack(padded_sequences, dim=0)

    label_tensor = torch.tensor(sorted_labels)
    lengths = [seq.size(0) for seq in sorted_sequences]

    return padded_batch, label_tensor, lengths
