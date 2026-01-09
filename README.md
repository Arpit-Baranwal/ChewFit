# ChewFit: AI-Powered Chewing Detection for Health & Nutrition Monitoring

[![Universität Freiburg](https://img.shields.io/badge/Universität-Freiburg-blue)](https://uni-freiburg.de/)
[![COSIMA 23](https://img.shields.io/badge/COSIMA-23-orange)](https://cosima23.uni-freiburg.de/)
[![Deep Learning](https://img.shields.io/badge/Deep%20Learning-Powered-green)](https://pytorch.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **"Chew better, live better"** - An intelligent audio classification system using wearable eyewear for real-time dietary monitoring and health analytics.

## 📋 Project Overview

ChewFit is an end-to-end deep learning pipeline that processes acoustic signals from sensor-equipped wearable eyewear to detect chewing events, identify food types, and track nutritional intake. The system addresses the global obesity pandemic by providing automated, non-intrusive dietary monitoring.

![ChewFit Dashboard](docs/chewfit-dashboard.png) *AI Health & Nutrition Dashboard*

## 🎯 The Problem

**Obesity is a global pandemic** (WHO, 2016):
- 1.9 billion adults overweight (39% of global population)
- 650 million clinically obese
- 379 million children under 19 affected

While numerous devices track exercise calories, there's a critical gap in **automated food intake monitoring**. Digestive issues often trace back to improper chewing habits, yet no accessible solution exists for real-time chewing analysis and dietary tracking.

## ✨ Solution: How ChewFit Works

We leverage the unique acoustic signatures of different foods during chewing. Just as an apple has a distinctive "crunch," every food creates characteristic sound patterns that can be identified through deep learning.

```python
# Example: Processing chewing audio signals
audio_signal → Feature Extraction → Deep Learning Model → Food Classification
