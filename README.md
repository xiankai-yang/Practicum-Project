# Practicum Project: Association of Physical Activity and Joint Space Width

## Project Overview
This project investigates the association between physical activity intensity and joint health, measured by **Joint Space Width (JSW)**, using accelerometer data.
The goal is to identify **critical intensity ranges** where activity has the strongest association with joint structure.

---

## Data Source
- Osteoarthritis Initiative (OAI)
- Wearable accelerometer data
- Minute-level activity counts
## Methodology
- Functional data representation using **AUC (Area Under Curve)**
- Segmentation-based modeling approach
- Optimization via **Residual Sum of Squares (RSS)**
- Model selection using **BIC**
## Key Findings
- Identified a cutpoint at approximately **18% intensity**
- Below the cutpoint: activity is positively associated with JSW
- Above the cutpoint: the association becomes slightly negative
## Statistical Validation
- Permutation test applied
- Results show statistically significant improvement of the two-segment model (K=2)
- Supports the presence of a non-linear relationship
## Limitations
- Observational data (no causal interpretation)
- Segmentation may vary across samples
- Limited adjustment for confounders
## Future Work
- Incorporate confounders (age, sex, BMI, baseline joint health)
- Test robustness via bootstrap and subgroup analysis
- Compare with alternative modeling approaches

---

## 📖 How to Read This Repository
This repository is organized to guide the reader from research motivation to modeling and results.
For first-time readers, it is recommended to follow the structure below:
1. **Start with `01_Project Overview/`**  
   - Read `01_01_Abstract.pdf` for a high-level summary of the research question, motivation, and key findings.
2. **Explore `04_Slides for process/`**  
   - These slides provide an intuitive explanation of the workflow, including data processing, OTC/AUC construction, and model development.
3. **Review `02_Codes/`**  
   - `02_01_Data Overview & OTC, AUC...` explains how raw accelerometer data are transformed into model-ready features.  
   - `02_02_testing.R` contains implementation and testing of the modeling approach.
4. **Check `03_Model Ready Data/`**  
   - These datasets (`J = 60, 100, 200`) are the processed inputs used in the modeling stage.
5. **View `05_Presetation Slides/`**  
   - Final presentation materials summarizing the results and interpretation.
6. **See `06_Reference/`**  
   - Supporting literature and reference materials.

For a quick overview, reading the abstract and final slides is sufficient.  
For a deeper understanding, follow the full sequence above.

---
