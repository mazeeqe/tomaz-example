import uproot
import matplotlib.pyplot as plt
import numpy as np

# Constants
z_mass = 91.1880

# Open the ROOT file
file = uproot.open("hist.root")

def file_reader(column: str):
        data = file[column]

        # Get histogram values and bin edges
        values = data.values()
        edges = data.axes[0].edges()

        # Compute bin centers for plotting
        centers = 0.5 * (edges[:-1] + edges[1:])

        return centers, values

# Access the histogram
h_mumu = file["h_mumu"]
h_recoil = file["h_recoil"]

# Get histogram values and bin edges
values = h_mumu.values()
edges = h_mumu.axes[0].edges()

# Compute bin centers for plotting
centers = 0.5 * (edges[:-1] + edges[1:])

mumu_centers, mumu_values = file_reader("h_mumu")
recoil_centers, recoil_values = file_reader("h_recoil")

# Plot
plt.figure(figsize=(8,6))

#Invariant mass
plt.bar(mumu_centers, mumu_values, width=np.diff(edges), align="center",
        edgecolor="black", color="skyblue")

#Recoil mass
plt.bar(recoil_centers, recoil_values, width=np.diff(edges), align="center",
        edgecolor="black", color="green")

# Vertical line for Z mass
plt.axvline(
    z_mass,
    color='red',            # line colour
    linestyle='--',        # dashed line (solid, dashdot, etc.)
    linewidth=2,
    label=f'Constant = {z_mass}'
)

plt.xlabel(r"$M_{\mu\mu}$ [GeV]")
plt.ylabel("Events")
plt.title("Invariant Mass and Recoil Mass of Two Muons")
plt.grid(alpha=0.3)

plt.savefig("muon_histogram")
