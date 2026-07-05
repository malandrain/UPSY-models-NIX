# NIX for reproducibility with UPSY-models

*Alpha version of the documentation, modifications are needed*

## 2 files:
- flake.nix
  Describes the dependencies and build the environment from scratch using
  ```sh
  nix develop

  ```
- flake.lock
  Allow for saving the environment versions at the time of an experiment and allow for perfect reproducibility by including it in the project

## Usage:
To use NIX in order to install UPSY-models:

- [ ] git clone this repository
- [ ] nix develop
- [ ] Compile the programms (tested with compile_UPSY.csh only with LADDIE and UFEMISM compilation set to on) using 

```sh
tcsh ./compile_UPSY.csh perf clean
```

- [ ] Add programs to the path

```sh
export PATH="./build/src/LADDIE/LADDIE_program:$PATH"
export PATH="./build/src/UFEMISM/UFEMISM_program:$PATH"
```

