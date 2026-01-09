import random
import matplotlib.pyplot as plt
import torch
import numpy as np


def quick_data_loader_test(data_loader):
    # Unpack the batch into images and labels
    images, labels = next(iter(data_loader))
    index = random.randint(0, len(images) - 1)

    image = images[index]
    label = labels[index]

    image = image.permute(1, 2, 0).numpy()
    label = label.item()

    # Display the image and label
    plt.imshow(image)
    plt.title(f"Label: {label}")
    plt.show()


def visualize_signals(data_loader, label=None):
    # Unpack the batch into images and labels
    signals, signal_labels, sig_len = next(iter(data_loader))

    x = np.linspace(0, len(signals[0]), len(signals[0]))

    if label is None:
        num_signals = len(signal_labels)
    else:
        indices = np.where(signal_labels.numpy() == label)
        num_signals = len(indices[0])
    # Creating a grid of subplots
    if num_signals == 0:
        return
    fig, axs = plt.subplots(num_signals, 1, figsize=(8, 12))

    # Generating signals and plotting them in separate subplots
    for i in range(num_signals):
        idx = i
        if label is not None:
            idx = indices[0][i]
        signal = signals[idx].numpy()
        axs[i].plot(x, signal)
        axs[i].set_xlabel('X-axis')
        axs[i].set_ylabel('Y-axis')
        axs[i].set_title(f'Signal {i + 1}, Label {signal_labels[idx].item()}')

    plt.tight_layout()
    plt.show()


def spectro_dim(data_loader):
    images, labels = next(iter(data_loader))
    image = images[0]
    # return the number of classes and image dimensions [W, H]
    return len(data_loader.dataset.classes), (image.shape[1], image.shape[2])


def signal_dim(data_loader):
    data, labels, lens = next(iter(data_loader))
    # return the number of classes and image dimensions [W, H]
    return len(data_loader.dataset.classes), data.size(1)


# def custom_collate_fn(batch):
#     # Extract the images and labels from the batch
#     images, labels = zip(*batch)
#
#     # Reshape the images into patches
#     patch_size = 14
#     stride = 16
#     patches = []
#     for image in images:
#         # Convert image to patches
#         image_patches = image.reshape()
#         patches.append(image_patches)
#
#         # Stack the patches and labels
#     patches = torch.stack(patches)
#     labels = torch.tensor(labels)
#
#     return patches, labels
