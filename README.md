Code repository for my Master's Thesis at Brazilian Center for Physics Research,

Tomáz Antonio Bortoletto Giansante,

Supervisor: Carsten Hensel

Installation

```bash
source /cvmfs/sw.hsf.org/key4hep/setup.sh -r 2025-01-28
git clone https://github.com/mazeeqe/tomaz-example.git
cd tomaz-example/
source setup.sh
mkdir build install
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=../install -DPython_EXECUTABLE=$(which python3)
make install

k4run ../example/options/run_example.py

