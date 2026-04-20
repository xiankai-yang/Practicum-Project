# Practicum Project: Association of Physical Activity and Joint Space Width

## Project Overview
This project investigates the association between physical activity intensity and joint health, measured by **Joint Space Width (JSW)**, using accelerometer data.

The goal is to identify **critical intensity ranges** where activity has the strongest association with joint structure.

---

## Data Source
- Osteoarthritis Initiative (OAI)
- Wearable accelerometer data
- Minute-level activity counts

---

## Methodology
- Functional data representation using **AUC (Area Under Curve)**
- Segmentation-based modeling approach
- Optimization via **Residual Sum of Squares (RSS)**
- Model selection using **BIC**

---

## Key Findings
- Identified a cutpoint at approximately **18% intensity**
- Below the cutpoint: activity is positively associated with JSW
- Above the cutpoint: the association becomes slightly negative

---

## 🧪 Statistical Validation
- Permutation test applied
- Results show statistically significant improvement of the two-segment model (K=2)
- Supports the presence of a non-linear relationship

---

## ⚠️ Limitations
- Observational data (no causal interpretation)
- Segmentation may vary across samples
- Limited adjustment for confounders

---

## 🚀 Future Work
- Incorporate confounders (age, sex, BMI, baseline joint health)
- Test robustness via bootstrap and subgroup analysis
- Explore longitudinal data
- Compare with alternative modeling approaches
