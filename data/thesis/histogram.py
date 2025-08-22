import uproot
import matplotlib.pyplot as plt
import numpy as np

# Open the ROOT file
file = uproot.open("hist.root")

# Access the histogram
h_mumu = file["h_mumu"]

# Get histogram values and bin edges
values = h_mumu.values()
edges = h_mumu.axes[0].edges()

# Compute bin centers for plotting
centers = 0.5 * (edges[:-1] + edges[1:])

# Plot
plt.figure(figsize=(8,6))
plt.bar(centers, values, width=np.diff(edges), align="center",
        edgecolor="black", color="skyblue")

plt.xlabel(r"$M_{\mu\mu}$ [GeV]")
plt.ylabel("Events")
plt.title("Invariant Mass of Two Muons")
plt.grid(alpha=0.3)

plt.savefig("muon_histogram")
