# Stochastic Capacity Planning for Airport De-Icing Operations

Hybrid analytical and discrete-event simulation (DES) framework for studying airport de-icing capacity planning under stochastic winter operating conditions and congestion-driven recirculation effects.

This repository contains the full MATLAB implementation developed for the ME714 course project at Boston University.

## Overview

Airport de-icing operations create a stochastic congestion problem in which insufficient throughput can induce severe delay, repeated de-icing cycles, and flight cancellations under winter weather conditions. This project develops:

* a simplified analytical approximation using queueing-inspired first-moment methods,
* and a higher-fidelity discrete-event simulation (DES)

to study how de-icing capacity policies behave under congestion, uncertainty, and holdover time (HOT) recirculation effects.

The core policy variables are:

* `k`: number of de-icing pads (parallel servers),
* `e`: service process configuration governing de-icing speed and variability.

The simulation framework evaluates how operating performance changes under varying:

* arrival structures,
* weather exposure levels,
* taxi/takeoff congestion regimes,
* service-process assumptions,
* and cost structures.

The project is intentionally framed as a stochastic capacity-planning model rather than a production-grade airport surface movement simulator.

## Main Features

### Analytical approximation

* Pointwise stationary approximation (PSA)-style queueing framework
* Congestion-sensitive taxi/takeoff approximation
* HOT recirculation approximation using geometric workload amplification
* Rapid sensitivity-analysis capability

### Discrete-event simulation (DES)

* Aircraft-level event-driven simulation
* Explicit queueing and resource competition
* HOT violation handling and recirculation
* Cancellation modeling
* Monte Carlo aggregation over stochastic weather realizations

### Economic analysis

* Delay cost
* Fluid cost
* Activation cost
* Cancellation cost
* CAPEX versus OPEX tradeoff analysis

## Repository Structure

```text
src/
├── CAPEX/
│   ├── buildGridsForCAPEXSweep.m
│   ├── runCAPEXSweep.m
│   └── writeCAPEXResultsToCSV.m
│
├── config/
│   ├── buildSimulationParameterGridsForAnalyticModel.m
│   ├── getNumberOfTaxiTakeoff...
│   └── getServiceTimeMultiplier...
│
├── orchestration/
│   └── execution/
│       ├── runAllSimulations.m
│       ├── runSingleDaySimulation.m
│       ├── runSingleYearSimulation.m
│       ├── aggregateSingleModel...
│       └── writeSimulationResults...
│
├── simulation/
│   ├── DES_Resources/
│   ├── eventCalendar/
│   ├── eventHandling/
│   ├── queues/
│   ├── sampling/
│   ├── simulationStats/
│   └── stateManagement/
│
├── utilities/
│   ├── constants/
│   └── templates/
│
├── main.m
└── startup.m

outputs/
└── Generated CSV outputs and experiment results
```

## Running the Project

### Step 1: Open MATLAB

Open MATLAB and navigate to the project root directory.

### Step 2: Initialize the project

Run:

```matlab
startup
```

This adds the project directories to the MATLAB path.

### Step 3: Configure experiments

All experimental scenarios are configured in:

```matlab
buildSimulationParameterGridsForAnalyticModel.m
```

This file defines:

* policy sweeps,
* weather scenarios,
* arrival structures,
* taxi/takeoff regimes,
* service-process assumptions,
* and cost structures.

For reproducibility, the experiment configurations used in the final report are intentionally left hard-coded in this file.

### Step 4: Execute the workflow

Run:

```matlab
main
```

This executes the configured simulation workflow.

## Outputs

Simulation outputs are written automatically to:

```text
outputs/
```

The repository includes utilities for writing:

* simulation-result CSVs,
* annualized summaries,
* and CAPEX sweep outputs.

### Important note on CSV output naming

Output filenames are controlled through:

```matlab
utilities/constants/getOutputCSVFileName.m
```

If the filename is not changed between runs, previous CSV outputs may be overwritten.

## Reproducibility Notes

The project is fully synthetic and does not rely on external datasets.

All distributions, operating assumptions, and cost parameters are heuristic approximations chosen to support stochastic experimentation and operational sensitivity analysis rather than empirical forecasting.

The analysis and publication-quality figures used in the final report were generated separately using external Python scripts that are not included in this repository.

## Computational Notes

Some experiment configurations can produce very large outputs.

In particular:

* large CAPEX sweeps may generate CSV files exceeding 1 GB,
* high-congestion scenarios can substantially increase simulation runtime,
* and aggressive parameter sweeps may require careful runtime control.

The `.gitignore` file contains protections against committing large generated outputs.

## Key Modeling Assumptions

### Arrival process

Aircraft arrivals are modeled using a nonhomogeneous Poisson process (NHPP) with Gaussian-pulse structure to approximate temporally concentrated departure banks.

### Taxi/takeoff subsystem

The downstream taxi/takeoff process is modeled as a reduced-form stochastic congestion process rather than a full airport surface movement simulation.

### Weather process

Storm occurrence and severity are modeled exogenously.

### HOT recirculation

Aircraft violating holdover time constraints may return for repeated de-icing, creating congestion amplification effects.

## Limitations

This project intentionally prioritizes tractable stochastic experimentation over complete airport operational realism.

The framework does NOT model:

* detailed airport surface topology,
* runway sequencing,
* gate assignment,
* pushback coordination,
* taxiway routing conflicts,
* or air traffic control procedures.

The DES should therefore be interpreted as a stochastic capacity-planning tool rather than a production-grade airport operations simulator.

## Future Extensions

Potential future improvements include:

* empirically calibrated arrival processes,
* Markov-modulated Poisson process (MMPP) arrivals,
* richer weather-process coupling,
* full airport surface movement simulation,
* adaptive scheduling/control policies,
* and calibration against real airport operational data.

## Report

The accompanying report documents:

* the analytical approximation,
* DES methodology,
* experimental design,
* policy results,
* analytic-versus-simulation comparison,
* and modeling limitations.

## Author

Cole H. Shaigec
Boston University — ME714 Project
