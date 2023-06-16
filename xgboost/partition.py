"""
Module for helper functions for manipulating data and datasets.
"""

from dataclasses import dataclass
import pandas as pd

@dataclass
class PartitionedDataset:
  train: pd.DataFrame
  test: pd.DataFrame
  validation: pd.DataFrame

def partition(df) -> PartitionedDataset:
  train = df[df["lon"] < -55]
  test = df[(df["lon"] >= -55) & (df["lat"] > -2.85)]
  validation = df[(df["lon"] >= -55) & (df["lat"] <= -2.85)]
  return PartitionedDataset(train, test, validation)

def print_split(dataset: PartitionedDataset) -> None:
  total_len = len(dataset.train)+len(dataset.validation)+len(dataset.test)
  print(f"Train: {100*len(dataset.train)/total_len:.2f}% ({len(dataset.train)})")
  print(f"Test: {100*len(dataset.test)/total_len:.2f}% ({len(dataset.test)})")
  print(f"Validation: {100*len(dataset.validation)/total_len:.2f}% ({len(dataset.validation)})")