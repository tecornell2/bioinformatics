#!/usr/bin/env python3

# chr_plot_relative_size.py
# Scaffold-to-chromosome map for RagTag output with relative scaffold sizes
# Green = + orientation, Red = - orientation

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# -----------------------------
# INPUT FILES
# -----------------------------
ragtag_file = "ragtag_scaffold_summary.txt"      # RagTag summary: ReferenceCM\tScaffold\tOrientation
ref_map_file = "chromosome_map.txt"             # Chromosome mapping: <name of chromosome> <digit>
                                                                    # ptg001.1                1
sizes_file = "scaffolds_final.chrom.sizes"      # Scaffold lengths: Scaffold\tLength

# -----------------------------
# LOAD AND CLEAN RAGTAG SUMMARY
# -----------------------------
ragtag = pd.read_csv(ragtag_file, sep="\t", header=None, names=["CM","Scaffold","Orientation"], dtype=str)
ragtag = ragtag.dropna(subset=["CM","Scaffold","Orientation"])
ragtag["CM"] = ragtag["CM"].str.strip().str.replace(r"_RagTag$", "", regex=True)
ragtag["Scaffold"] = ragtag["Scaffold"].str.strip()
ragtag["Orientation"] = ragtag["Orientation"].str.strip()

# -----------------------------
# LOAD CHROMOSOME MAP
# -----------------------------
ref_map = pd.read_csv(ref_map_file, sep="\t", header=None, names=["CM","Chromosome"], dtype=str)
ref_map = ref_map.dropna(subset=["CM","Chromosome"])
ref_map["CM"] = ref_map["CM"].str.strip()
ref_map["Chromosome"] = ref_map["Chromosome"].str.strip()

# -----------------------------
# MERGE RagTag with Chromosome Map
# -----------------------------
df = ragtag.merge(ref_map, on="CM", how="inner")
missing_count = len(ragtag) - len(df)
if missing_count > 0:
    print(f"Warning: {missing_count} scaffolds in RagTag summary did not match chromosome map and were ignored.")
if df.empty:
    raise ValueError("No scaffolds to plot after merging. Check your input files.")
  
# -----------------------------
# LOAD SCAFFOLD LENGTHS
# -----------------------------
sizes = pd.read_csv(sizes_file, sep="\t", header=None, names=["Scaffold","Length"], dtype={"Scaffold": str, "Length": int})
sizes["Scaffold"] = sizes["Scaffold"].str.strip()
df = df.merge(sizes, on="Scaffold", how="left")
missing_lengths = df["Length"].isna().sum()
if missing_lengths > 0:
    print(f"Warning: {missing_lengths} scaffolds have no length info. They will be set to 1.")
    df["Length"] = df["Length"].fillna(1)
# Optional: log-scale for very large scaffolds (uncomment if needed)
# df["PlotLength"] = np.log10(df["Length"] + 1)
# Use actual lengths for now
df["PlotLength"] = df["Length"]

# -----------------------------
# ADD UNPLACED SCAFFOLDS
# -----------------------------
unplaced = sizes[~sizes["Scaffold"].isin(df["Scaffold"])].copy()
if not unplaced.empty:
    print(f"{len(unplaced)} scaffolds are unplaced. Adding to 'Unplaced' pseudo-chromosome.")
    unplaced["Chromosome"] = "Unplaced"
    unplaced["Orientation"] = "+"
    unplaced["PlotLength"] = unplaced["Length"]
    df = pd.concat([df, unplaced], ignore_index=True)
  
# -----------------------------
# PLOT
# -----------------------------
chromosomes = sorted(df["Chromosome"].unique(), key=lambda x: (not x.isdigit(), x))
fig_height = max(2, len(chromosomes)*0.6)
fig, ax = plt.subplots(figsize=(15, fig_height))
yticks = []
ytlabels = []
for i, chrom in enumerate(chromosomes):
    chrom_scaffs = df[df["Chromosome"] == chrom]
    start = 0
    for _, row in chrom_scaffs.iterrows():
        end = start + row["PlotLength"]
        color = "green" if row["Orientation"] == "+" else "red"
        ax.barh(i, width=row["PlotLength"], left=start, color=color, edgecolor="black")
        # Only label scaffolds large enough to read
        if row["PlotLength"] > max(df["PlotLength"].max() / 100, 1e5):
            ax.text(start + row["PlotLength"]/2, i, row["Scaffold"], ha="center", va="center", fontsize=6)
        start = end
    yticks.append(i)
    ytlabels.append(f"Chr {chrom}")
ax.set_yticks(yticks)
ax.set_yticklabels(ytlabels)
ax.set_xlabel("Scaffold length (bp)")
ax.set_title("C. scutulatus scaffolds mapped to C. adamanteus chromosomes\nGreen=+ orientation, Red=- orientation")
plt.tight_layout()

# -----------------------------
# SAVE FIGURES
# -----------------------------
output_png = "scaffold_chromosome_map.png"
output_pdf = "scaffold_chromosome_map.pdf"
plt.savefig(output_png, dpi=300, bbox_inches="tight")
plt.savefig(output_pdf, bbox_inches="tight")
print(f"Plots saved to:\n - {output_png}\n - {output_pdf}")
