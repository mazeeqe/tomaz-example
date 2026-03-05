# A Study of Invisible Higgs Decays at a Future $e^+e^-$
# Collider Using the $Z(\mu^+\mu^-)$
# Recoil Spectrum $\sqrt{s}=250\,\text{GeV}$


## Code repository for my Master's Thesis at Brazilian Center for Physics Research,
## Date: 4 of March, 2026

### Tomáz Antonio Bortoletto Giansante,

### Supervisor: Carsten Hensel

### Installation

Start by sourcing the desired Key4hep version
```bash
source /cvmfs/sw.hsf.org/key4hep/setup.sh -r 2025-05-29
git clone https://github.com/mazeeqe/tomaz-example.git
```

In case of change in the version of Key4hep, it's maybe necessary to re-complie the code. Start by deleting the `build` and `install` folders and do the following process:
To compile and run the code change to the build folder

```bash
cd tomaz-example/
source setup.sh
mkdir build install
cd build
```

### Compiling
In case of a change in the Gaudi Algorithms, re-complie the code.

```bash
cmake .. -DCMAKE_INSTALL_PREFIX=../install -DPython_EXECUTABLE=$(which python3)
make install
```

### Running the code,

An `bash` script is available that does the simulations for the signal and all process ids. Within the `build` folder, run:

```bash
chmod +x ../scripts/init.sh
```

this will turn the \texttt{init.sh} into a functional bash script, then do:

```bash
../scripts/init.sh
```

after each simulated process, the `.root` files produced are moved to their respective folder in 

### Individual Run

The key4hep file can also be run individually, there's two run options
`--signal` and `--background`. Without specfication, it will do the signal run.
Running the code this way it will produce a `hist.root` file at the build folder.

Without options, signal run:
```bash
cd build
k4run ../example/options/run_example.py
```

With options, signal run:
```bash
cd build
k4run ../example/options/run_example.py --signal
```

Background run:
```bash
cd build
k4run ../example/options/run_example.py --XXXXXX
```

An additional argument is available to split between signal, `--signal`, and background simulation, `--XXXXXX`, where `XXXXX` is an process id, the full list of available ids is present at ANNEX C of my thesis.

### Graphs and Plots

The plots are located at the `data` folder at the `histogram.ipynb` jupyter notebook.
