# NIX for reproducibility with UPSY-models

*Alpha version of the documentation, modifications are needed*
e.g. **pre-commit not installed in the flake yet**

## 2 files:
- flake.nix
  Describes the dependencies and build the environment from scratch using
  ```sh
  nix develop

  ```
- flake.lock
  Allow for saving the environment versions at the time of an experiment and allow for perfect reproducibility by including it in the project

## Procedure for installing UPSY-models with NIX:
To use NIX in order to install UPSY-models:

```sh
git clone git@github.com:malandrain/UPSY-models-NIX.git
git submodule init
git submodule update --recursive --remote
nix develop
module purge #For HPCs infrastructure with module implemented that can cause conflicts
tcsh ./compile_UPSY.csh perf clean #Will perform a clean install and remove the previous builds - "changed" instead of clean when just updating for faster compilation

# Add both programs to the path 
export PATH="./build/src/LADDIE/LADDIE_program:$PATH"
export PATH="./build/src/UFEMISM/UFEMISM_program:$PATH"

# Run the tests for both models
mpirun -n 2 LADDIE_program src/LADDIE/validation/integrated_tests/Antarctica/test_coarse.cfg
mpirun -n 2 UFEMISM_program automated_testing/integrated_tests/realistic/Antarctica/initialisation/Ant_init_20kyr_invBMB_invfric_40km/config.cfg
```
