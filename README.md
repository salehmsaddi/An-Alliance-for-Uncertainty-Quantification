# An-Alliance-for-Uncertainty-Quantification-Type-2-Fuzzy-Logic-Systems-with-Conformal-Prediction
MATLAB implementation of the following paper:

```text
S. Msaddi, T. Kumbasar, 2025. An Alliance for Uncertainty Quantification: Type-2 Fuzzy Logic Systems with Conformal Prediction, IEEE Transactions on Emerging Topics in Computational Intelligence.
```

We kindly ask that you cite the above-mentioned paper if you use this **Alliance Framework** in your research or publish work based on these codes.

## Overview

This repository provides a MATLAB implementation of an **Alliance for Uncertainty Quantification**, a model-agnostic framework that integrates *Type-2 Fuzzy Logic Systems* with *Conformal Prediction* to calibrate the prediction intervals of Type-2 Fuzzy Logic Systems and generate high-quality prediction intervals. 

The repository contains:
- A `simulate.m` script to run experiments and save results into a structure.
- A `getResults.m` script to post-process the results and generate the tables and figures used in the paper.

Please note that: 
- a single run of `simulate.m` would generate the results of 1 type of CSCM. Thus, you need to run the `simulate.m` file twice to get the results of KM CSCM and WKM CSCM (`simulate.m` line 23)
- the `simulate.m` runs for the Boston dataset. You can access and load other datasets from the `datasets` folder
- you need to have the results of KM CSCM and WKM CSCM to be able to run `getResults.m`
- specify the name of the dataset that you wish to process the results and generate the tables and figures (`getResults.m` line 7)
- the numerical results might vary due to random seed variation (`simulate.m` line 97)

If you prefer not to re-run the simulations, you can directly use the .mat files in `paper results` and proceed with `getResults.m`.



---

> *Feel free to explore, experiment, and build on top of this work. Contributions, feedback, and extensions are always welcome.*

---

## Contact

For questions, feedback, or collaborations, feel free to open an issue or contact the authors directly.
