#!/usr/bin/env python3
"""Shared plotting utilities for ME714 DES result figures."""

from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


ARRIVAL_SIGMA_MAP = {
    "steadyModerate": 999.0,
    "narrowDepartureBank": 0.35,
    "mediumDepartureBank": 1.50,
    "broadDepartureBank": 4.00,
    "stressNarrowDepartureBank": 0.35,
}


def parse_plot_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", required=True, help="Path to DES result CSV.")
    parser.add_argument(
        "--out-dir",
        default=None,
        help="Output directory. Defaults to <project-root>/outputs/figures.",
    )
    parser.add_argument("--cost-scenario", default="baselineCost")
    parser.add_argument("--taxi-scenario", default=None)
    parser.add_argument("--storm-count", type=float, default=None)
    parser.add_argument("--service-index", type=float, default=3.0)
    return parser.parse_args()


def configure_plot_style() -> None:
    plt.rcParams.update({
        "figure.figsize": (6.5, 4.0),
        "figure.dpi": 150,
        "savefig.dpi": 300,
        "font.family": "serif",
        "font.size": 9,
        "axes.labelsize": 9,
        "axes.titlesize": 10,
        "legend.fontsize": 8,
        "xtick.labelsize": 8,
        "ytick.labelsize": 8,
        "axes.linewidth": 0.8,
        "lines.linewidth": 1.2,
        "lines.markersize": 4.5,
        "grid.linewidth": 0.4,
        "grid.linestyle": ":",
        "pdf.fonttype": 42,
        "ps.fonttype": 42,
    })


def find_project_root(start_path: Path) -> Path:
    current = start_path.resolve()

    if current.is_file():
        current = current.parent

    for candidate in [current, *current.parents]:
        if (candidate / "src").is_dir() or (candidate / ".git").exists():
            return candidate

    return current


def resolve_output_directory(out_dir: str | None) -> Path:
    if out_dir is not None:
        return Path(out_dir).resolve()

    project_root = find_project_root(Path(__file__))
    return project_root / "outputs" / "figures"


def load_results(csv_path: Path) -> pd.DataFrame:
    results = pd.read_csv(csv_path)

    required_columns = [
        "arrivalScenarioName",
        "policyK",
        "policyE",
        "costScenarioName",
        "annualNumberOfStorms",
    ]
    missing_columns = [col for col in required_columns if col not in results.columns]

    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}")

    if "sigmaLambda" not in results.columns:
        results["sigmaLambda"] = results["arrivalScenarioName"].map(ARRIVAL_SIGMA_MAP)

    results = results.dropna(subset=["sigmaLambda"]).copy()
    results["policyK"] = results["policyK"].astype(int)
    results["policyE"] = results["policyE"].astype(float)

    return results


def apply_filters(results: pd.DataFrame, args: argparse.Namespace) -> pd.DataFrame:
    filtered = results[results["costScenarioName"] == args.cost_scenario].copy()

    has_taxi_column = "taxiTakeoffScenarioName" in filtered.columns

    if args.taxi_scenario is not None and has_taxi_column:
        filtered = filtered[filtered["taxiTakeoffScenarioName"] == args.taxi_scenario].copy()

    if args.storm_count is not None:
        filtered = filtered[filtered["annualNumberOfStorms"] == args.storm_count].copy()

    if filtered.empty:
        raise ValueError("No rows remain after filtering.")

    return filtered


def save_figure(fig: plt.Figure, output_directory: Path, file_stem: str) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)

    png_path = output_directory / f"{file_stem}.png"
    pdf_path = output_directory / f"{file_stem}.pdf"

    fig.tight_layout()
    fig.savefig(png_path, bbox_inches="tight")
    fig.savefig(pdf_path, bbox_inches="tight")

    print(f"Wrote {png_path}")
    print(f"Wrote {pdf_path}")


def main() -> None:
    args = parse_plot_args()
    configure_plot_style()

    results = load_results(Path(args.csv))
    results = apply_filters(results, args)

    if "totalCancellations" not in results.columns:
        raise ValueError("CSV must contain totalCancellations.")

    results = results[results["policyE"] == args.service_index].copy()

    if results.empty:
        raise ValueError("No rows remain after service-index filtering.")

    summary = (
        results
        .groupby(["sigmaLambda", "policyK"], as_index=False)
        .agg(meanTotalCancellations=("totalCancellations", "mean"))
        .sort_values(["policyK", "sigmaLambda"])
    )

    fig, ax = plt.subplots()

    markers = ["o", "s", "^", "D", "v", "x", "P"]
    line_styles = ["-", "--", "-.", ":", (0, (5, 1)), (0, (3, 1, 1, 1))]

    for i_series, (policy_k, group) in enumerate(summary.groupby("policyK")):
        ax.plot(
            group["sigmaLambda"],
            group["meanTotalCancellations"],
            color="black",
            linestyle=line_styles[i_series % len(line_styles)],
            marker=markers[i_series % len(markers)],
            markerfacecolor="white",
            markeredgecolor="black",
            label=f"k = {policy_k}",
        )

    ax.set_xlabel(r"Arrival spread parameter, $\sigma_{\lambda}$")
    ax.set_ylabel("Mean annual cancellations")
    ax.set_title(r"Cancellations vs. arrival concentration ($e=3$)")
    ax.grid(True)
    ax.legend(frameon=False)

    ax.text(
        0.02,
        0.98,
        r"Lower $\sigma_{\lambda}$ = tighter bank",
        transform=ax.transAxes,
        va="top",
        ha="left",
        fontsize=8,
    )

    save_figure(fig, resolve_output_directory(args.out_dir), "cancellations_vs_sigma_lambda")


if __name__ == "__main__":
    main()
