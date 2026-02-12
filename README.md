# Monte Carlo Simulation of the Invisible Higgs Decay at the International Linear Collider

## Code repository for my Master's Thesis at Brazilian Center for Physics Research,
Date: 16 of October, 2025
### Tomáz Antonio Bortoletto Giansante,

### Supervisor: Carsten Hensel

### Installation

Start by sourcing the desired Key4hep version
```bash
source /cvmfs/sw.hsf.org/key4hep/setup.sh -r 2025-01-28
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
The simulation is divided into two runs, for the signal and background files.
The `init.sh` file does both runs and creates two separate output files. 
To run the simulation, do the following command.

```bash
cd build
source init.sh
```

After the Simulation is finished, the resulting files, `signal_hist.root` and `background_hist.root`, are located `output_files` folder.

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
k4run ../example/options/run_example.py --background
```

### Graphs and Plots

The plots are located at the `data` folder at the `histogram.ipynb` jupyter notebook.
