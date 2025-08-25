import uproot
import matplotlib.pyplot as plt
import numpy as np

# Constants
z_mass = 91.1880
h_mass = 125.20

# Open the ROOT file
file = uproot.open("hist.root")
tree = file["events"]


# Convert branches to numpy arrays
invMass = tree["invMass"].array(library="np")
recoilMass = tree["recoilMass"].array(library="np")


# Plot
plt.figure(figsize=(8,6))

#Invariant mass
plt.hist(invMass, bins=100, range=(0,200), histtype='step', color='blue')

#Recoil mass
plt.hist(recoilMass, bins=100, range=(0,200), histtype='step', color='green')

# Vertical line for Z mass
plt.axvline(
    z_mass,
    color='red',            # line colour
    linestyle='--',        # dashed line (solid, dashdot, etc.)
    linewidth=2,
    label=f'Constant = {z_mass}'
)

# Vertical line for Z mass
plt.axvline(
    h_mass,
    color='yellow',            # line colour
    linestyle='--',        # dashed line (solid, dashdot, etc.)
    linewidth=2,
    label=f'Constant = {h_mass}'
)

plt.xlabel(r"$M_{\mu\mu}$ [GeV]")
plt.ylabel("Events")
plt.title("Invariant Mass and Recoil Mass of Two Muons")
plt.grid(alpha=0.3)

plt.savefig("muon_histogram.png")
