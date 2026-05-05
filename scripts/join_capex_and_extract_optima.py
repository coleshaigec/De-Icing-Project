import pandas as pd
from pathlib import Path

des_path = Path('/mnt/data/annual_simulation_results_20260505_001055.csv')
capex_path = Path('/mnt/data/capex_sweep_results_20260505_100935.csv')
out_dir = Path('/mnt/data')

des = pd.read_csv(des_path)
capex = pd.read_csv(capex_path)

opex_col = 'totalOperatingCost'
if opex_col not in des.columns:
    raise ValueError(f"Missing expected annual OPEX column: {opex_col}")

# Align join-key types.
des['policyK'] = des['policyK'].astype(int)
capex['policyK'] = capex['policyK'].astype(int)
des['policyE'] = des['policyE'].astype(float)
capex['policyE'] = capex['policyE'].astype(float)

# Collapse CAPEX to cheapest annualized implementation by policy.
capex_min = (
    capex
    .groupby(['policyK', 'policyE'], as_index=False)
    .agg(minAnnualizedCapex=('annualizedCapex', 'min'))
)

joined = des.merge(capex_min, on=['policyK', 'policyE'], how='inner')

joined['annualOpexCost'] = joined[opex_col]
joined['totalAnnualCost'] = joined['annualOpexCost'] + joined['minAnnualizedCapex']
joined['capexShareOfTotalCost'] = joined['minAnnualizedCapex'] / joined['totalAnnualCost']

# Extract optimal policy per meaningful operating scenario.
scenario_cols = [
    c for c in [
        'modelType',
        'arrivalScenarioName',
        'serviceScenarioName',
        'taxiTakeoffScenarioName',
        'costScenarioName',
        'annualNumberOfStorms',
    ]
    if c in joined.columns
]

idx = joined.groupby(scenario_cols, dropna=False)['totalAnnualCost'].idxmin()
optimal = joined.loc[idx].copy().sort_values(scenario_cols).reset_index(drop=True)

# Also create a compact policy-count diagnostic.
policy_counts = (
    optimal
    .groupby(['modelType', 'costScenarioName', 'policyK', 'policyE'], dropna=False)
    .size()
    .reset_index(name='numScenarioOptima')
    .sort_values(['modelType', 'costScenarioName', 'numScenarioOptima'], ascending=[True, True, False])
)

joined_path = out_dir / 'joined_total_operating_cost_plus_min_capex.csv'
optimal_path = out_dir / 'optimal_policies_total_operating_cost_plus_min_capex.csv'
counts_path = out_dir / 'optimal_policy_counts_total_operating_cost_plus_min_capex.csv'

joined.to_csv(joined_path, index=False)
optimal.to_csv(optimal_path, index=False)
policy_counts.to_csv(counts_path, index=False)

print(f"Saved joined table: {joined_path}")
print(f"Saved optimal policy table: {optimal_path}")
print(f"Saved policy-count diagnostic: {counts_path}")
print(f"Joined rows: {len(joined):,}")
print(f"Optimal rows: {len(optimal):,}")

print("\nOptimal policy counts:")
print(policy_counts.to_string(index=False))

print("\nOptimal preview:")
preview_cols = [c for c in scenario_cols + [
    'policyK', 'policyE', 'annualOpexCost', 'minAnnualizedCapex',
    'totalAnnualCost', 'capexShareOfTotalCost',
    'totalDepartures', 'totalCancellations', 'totalHOTViolations'
] if c in optimal.columns]
print(optimal[preview_cols].head(30).to_string(index=False))
