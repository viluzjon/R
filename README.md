# Esophageal Cancer Treatment Response Dataset Analysis

## Overview
This project analyzes a dataset containing treatment response data for esophageal cancer, sourced from [Kaggle](https://www.kaggle.com/datasets/lijsbeth/cancer-treatment-response). The dataset includes 1234 observations with 13 variables across five types, including two categorical variables. The goal is to explore how factors like gender, age, cancer stage, and smoking status influence treatment response and survival time.

## Data Source
The data originates from Toxopeus, E. L. A., Nieboer, D., Shapiro, J., Biermann, K., van der Gaast, A., van Rij, C. M., et al. (2015). _Nomogram for predicting pathologically complete response after neoadjuvant chemoradiotherapy for oesophageal cancer_. Published in *Radiotherapy and Oncology*, 115(3), 392‐398.

### Dataset Columns
- **ID**: Character, Universal Unique Identifier.
- **Age**: Integer, age range 65‐94.
- **Sex**: Binary, "M" for male, "F" for female.
- **Tumor_type**: Categorical, "squamous cell carcinoma" or "adenocarcinoma".
- **Differentiation_grade**: Ordinal, tumor differentiation grade (G1-G4; Gx for unknown).
- **T_stage**: Ordinal, main tumor stage (T0 for no tumor found, T1-T4 for size/extent, Tx for unmeasured).
- **N_stage**: Ordinal, lymph node involvement (N0 for no lymph nodes affected, N1-N3 for number affected, Nx for unmeasured).
- **M_stage**: Ordinal, metastasis (M0 for no metastasis, M1 for metastasis present, Mx for unmeasured).
- **Survival_time_days**: Float, survival time in days.
- **Overall_stage**: Ordinal, cancer stage (I-IV).
- **Smoking**: Ordinal, smoking frequency ("None", "Rarely", "Yes").
- **Weight_loss_percent**: Float, weight loss percentage.
- **Tumor_location**: Categorical, tumor location ("Distal", "Junction", "Middle").
- **Complete_response_probability**: Float, probability of complete response to treatment.

## Usage
This dataset provides valuable insights into cancer treatment response and survival factors, suitable for predictive modeling in oncology.

## License
See the `LICENSE` file for licensing details.
