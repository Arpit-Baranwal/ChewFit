import os.path
import torch
import pytorch_lightning as pl
from transformer import TransformerModel
from signal_dataset import SignalDataset, custom_collate_fn
from pytorch_lightning.callbacks.early_stopping import EarlyStopping
from utils import signal_dim
from ConfigSpace import Configuration, ConfigurationSpace
from smac import HyperparameterOptimizationFacade, Scenario, acquisition


def hp_function(config: Configuration, seed: int) -> float:
    # SMAC always minimizes the value returned from the target function.
    model = TransformerModel(coeff=int(config['coeff']),
                             input_size=int(config['input_size']),
                             n_head=int(config['n_head']),
                             d_model=int(config['d_model']),
                             num_layers=int(config['num_layers']),
                             dim_feedforward=int(config['dim_feedforward']),
                             output_size=classes,
                             )
    # Create a trainer
    trainer = pl.Trainer(deterministic=True, max_epochs=30, accelerator='gpu', devices=1,
                         callbacks=[early_stop_callback])

    # Train the model
    trainer.fit(model, train_loader, val_loader)
    # print(f"val metric {trainer.callback_metrics['val_accuracy']}")
    # Return the evaluation metric (e.g., validation accuracy)
    return trainer.callback_metrics['val_loss']


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

    early_stop_callback = EarlyStopping(
        monitor='val_accuracy',
        min_delta=0.00,
        patience=10,
        verbose=False,
        mode='max'
    )

    # HP OPTIMIZATION
    # configuration space
    configspace = ConfigurationSpace({"word_size": [64, 32, 16, 8, 4, 2],
                                      "n_head": [2, 4, 8, 16, 32],
                                      "d_model": [128, 256, 512, 1024],
                                      "num_layers": [2, 4, 8, 16],
                                      "dim_feedforward": [64, 128, 256, 512, 1024, 2048, 4096]})
    # configspace = ConfigurationSpace({"coeff": [5, 9, 15, 25, 45, 75],
    #                                   "input_size": [5 * 22, 9 * 22, 15 * 22, 25 * 22, 45 * 22, 75 * 22],
    #                                   "n_head": [2, 4, 8],
    #                                   "d_model": [256, 512, 1024],
    #                                   "num_layers": [4, 8],
    #                                   "dim_feedforward": [128, 256, 512]})

    scenario = Scenario(configspace, deterministic=True, n_trials=100)

    # Use SMAC to find the best configuration/hyperparameters
    # smac = HyperparameterOptimizationFacade(scenario, hp_function)
    smac = acquisition.function.expected_improvement.EI()
    # incumbent = smac.optimize()

    incumbent = {'d_model': 512, 'dim_feedforward': 128, 'word_size': 64, 'n_head': 8, 'num_layers': 8}

    print("Incumbent (Best Configuration):")
    print(incumbent)

    if 1:
        print("*" * 50)
        print("FINAL MODEL")
        print("-" * 50)

        # 26048 dividable by (64,32,16,8,4,2) let's say each word length is 64 and the sentences having 407
        model = TransformerModel(word_size=int(incumbent['word_size']),
                                 n_head=int(incumbent['n_head']),
                                 d_model=int(incumbent['d_model']),
                                 num_layers=int(incumbent['num_layers']),
                                 dim_feedforward=int(incumbent['dim_feedforward']),
                                 output_size=classes,
                                 )

        # Create a trainer
        trainer = pl.Trainer(deterministic=True,
                             max_epochs=20,
                             accelerator='gpu',
                             devices=1)
        # callbacks=[early_stop_callback])

        # Train the model
        trainer.fit(model, train_loader, val_loader)
