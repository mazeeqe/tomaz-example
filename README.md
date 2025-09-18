Code repository for my Master's Thesis at Brazilian Center for Physics Research,

Tomáz Antonio Bortoletto Giansante,

Supervisor: Carsten Hensel

Installation

```bash
source /cvmfs/sw.hsf.org/key4hep/setup.sh -r 2025-01-28
git clone https://github.com/mazeeqe/tomaz-example.git
```

To compile and run the code change to the build folder

```bash
cd tomaz-example/
source setup.sh
mkdir build install #Tirar
cd build
```

Compiling,
In case of a change in the Gaudi Algorithms, re-complie the code.

```bash
cmake .. -DCMAKE_INSTALL_PREFIX=../install -DPython_EXECUTABLE=$(which python3)
make install
```

Running the code,
To run the simulation, do the following command.

```bash
k4run ../example/options/run_example.py
```
