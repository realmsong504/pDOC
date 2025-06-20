# pDOC v2.0
**Prognostication of chronic disorders of consciousness using individualized functional connectivity networks derived from resting-state fMRI and clinical characteristics**

---

## Introduction

Severe brain injury can lead to disorders of consciousness (DOC). Prognostication is a critical concern for DOC patients, as medical treatment and rehabilitation planning depend heavily on expected outcomes. However, accurately predicting long-term recovery remains a significant challenge.

For research purposes, we present **pDOC v2.0**, an updated software package designed to predict outcomes in chronic DOC patients (i.e., more than one month after the initial injury). This version provides a probability estimate of consciousness recovery for individual patients.

---

## 🔄 What's New in v2.0

Compared to v1.0, the main enhancement in **pDOC v2.0** is the introduction of:

### ✅ **Individualized Regions of Interest (ROIs)**

- Brain functional networks are now calculated based on *subject-specific ROIs* instead of standard group-defined regions.
- This individualized approach improves the sensitivity of the prognostic model, reducing false negatives.
- Functional connectivity features derived from individualized ROIs are integrated with clinical characteristics in a combined model.

This new model demonstrated improved robustness and interpretability.

> 📄 For methodological details, see our original publication:  
> [https://elifesciences.org/articles/36173](https://elifesciences.org/articles/36173)  
> *(Note: v2.0 improvements are ongoing research and not yet reflected in the publication above.)*

---

## Models Included

- **Clinical Model** – based on clinical characteristics only.
- **Combined Model (Group ROI)** – integrates clinical data with functional connectivity features derived from standard, group-defined ROIs (as in v1.0).
- **Combined Model (Individualized ROI)** – integrates clinical data with functional connectivity based on subject-specific, individualized ROIs (introduced in v2.0).


---

## Important Note

This software is provided **for research and informational purposes only**. It is not intended for clinical diagnosis or treatment.

We make no warranties, express or implied, regarding the accuracy, completeness, or fitness of the software for any specific purpose. Always consult a qualified healthcare professional for clinical decisions.

---

## Prerequisite Software

- **MATLAB** (version 2010 or later)  
- **SPM8** or later  
- **3D nii NIfTI format support** for fMRI data  

---

## How to Use

Please refer to the documentation:  
📄 `How_to_use.docx`

This document provides step-by-step instructions for:

- Data preparation
- ROI extraction
- Model input formatting
- Running the prediction
- Interpreting results

> In the graphical user interface (GUI), selecting **individual_ROI** via the corresponding radio button enables prediction using individualized ROIs.  
> The software will automatically compute and display results from **both the group ROI model** and the **individualized ROI model**, allowing for easy comparison.
---

## Citation

If you use this tool in your research, please cite our original publication:

> **Ming Song, Yi Yang, et al. (2018)** Prognosticating chronic disorders of consciousness using resting-state fMRI and clinical characteristics. *eLife* 7:e36173.  
> [https://doi.org/10.7554/eLife.36173](https://doi.org/10.7554/eLife.36173)

> *For pDOC v2.0, an updated manuscript is in preparation.*

---

## License

This repository is distributed for **non-commercial, academic research use only**.  
For commercial use or redistribution, please contact the authors.

---

## Contact

For questions, bug reports, or collaboration inquiries, please contact:  
📧 *msong@nlpr.ia.ac.cn*

---
