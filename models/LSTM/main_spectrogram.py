import torchvision.transforms as transforms
from model_spectrogram import LSTM
from utils import spectro_dim
import torchvision
from torchvision.datasets import ImageFolder
import pytorch_lightning as pl
import torch


if __name__ == '__main__':

    train_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/spectrogram_splitted/train"
    val_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/spectrogram_splitted//val"
    test_folder = "C:/Users/Alil/Documents/Courses/SS2023/2ES/repo/data_analysis/root/spectrogram_splitted/test"

    transform = transforms.Compose([
        transforms.Grayscale(),
        transforms.Resize((224, 224)),
        transforms.ToTensor()
    ])

    train_dataset = ImageFolder(train_folder, transform=transform)
    val_dataset = ImageFolder(val_folder, transform=transform)
    test_dataset = ImageFolder(test_folder, transform=transform)

    batch_size = 32
    train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_loader = torch.utils.data.DataLoader(val_dataset, batch_size=batch_size)
    test_loader = torch.utils.data.DataLoader(test_dataset, batch_size=batch_size)

    transform = transforms.Compose([
        transforms.ToTensor(),  # Convert images to tensors
    ])

    # # Load the MNIST dataset
    # train_dataset = torchvision.datasets.MNIST(root='./data', train=True, transform=transform, download=True)
    # val_dataset = torchvision.datasets.MNIST(root='./data', train=False, transform=transform, download=True)
    #
    # batch_size = 32
    # # Create data loaders
    # train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    # val_loader = torch.utils.data.DataLoader(val_dataset, batch_size=batch_size)


    classes, img_dim = spectro_dim(train_loader)
    # input_size = 28 * 4
    # sequence_length = int(28 / 4)

    input_size = 16 * img_dim[0]
    sequence_length = int(224//16)
    hidden_size = 256
    num_classes = classes

    model = LSTM(input_size=input_size,
                 sequence_length=sequence_length,
                 hidden_size=hidden_size,
                 num_layers=16,
                 num_classes=num_classes)



    # Create a trainer
    trainer = pl.Trainer(deterministic=True, max_epochs=20, accelerator='gpu', devices=1)

    # Train the model
    trainer.fit(model, train_loader, val_loader)
