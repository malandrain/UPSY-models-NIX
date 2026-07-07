{
  description = "Environnement de développement pour UFEMISM et LADDIE (UPSY)";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ... }@inputs:
  let
    systems = [ "x86_64-linux" "x86_64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems f;
  in {
    devShells = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
	cshCompat = pkgs.writeShellScriptBin "csh" ''
		exec ${pkgs.tcsh}/bin/tcsh "$@"
	'';
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          numpy 
          netcdf4 
          xarray 
          matplotlib 
          cartopy 
          #cmocean 
          dask
          geopandas 
          pyproj 
          pyshp 
          scipy 
          shapely 
          tqdm 
          ipython 
          ipykernel 
          setuptools
        ]);
        hdf5Parallel = pkgs.hdf5.override {
            mpiSupport = true;
            mpi = pkgs.openmpi;
            fortranSupport = true;
            cppSupport = false;
          };
        netcdfParallel = pkgs.netcdf.override {
          hdf5 = hdf5Parallel;
        };
        netcdfFortranParallel = pkgs.netcdffortran.override {
          hdf5 = hdf5Parallel;
          netcdf = netcdfParallel;
        };
        hdf5ParallelFull = pkgs.symlinkJoin {
            name = "hdf5-mpi-full";
            paths = [hdf5Parallel hdf5Parallel.dev];
          };
      in {
        default = pkgs.mkShell {
          name = "ufemism-laddie-env";
          buildInputs = with pkgs; [
            gfortran
            cmake
            ninja
            pkg-config
            openmpi
            petsc
            netcdfParallel
            hdf5ParallelFull
            netcdfFortranParallel
            tcsh
	    cshCompat
            git
            wget
            coreutils
            gnused
            gnumake
            gawk
          ];
          shellHook = ''
            export PETSC_DIR=${pkgs.petsc}
            export PETSC_ARCH=${if system == "x86_64-darwin" then "darwin" else "linux-gnu"}
            export HDF5_ROOT=${hdf5ParallelFull}
            export NETCDF_FORTRAN_INCLUDE=${netcdfFortranParallel}/include
            export NETCDF_FORTRAN_LIB=${netcdfFortranParallel}/lib
            export FC=${pkgs.gfortran}/bin/gfortran
            export CC=${pkgs.gcc}/bin/gcc
            export CXX=${pkgs.gcc}/bin/g++
            export CMAKE_PREFIX_PATH="${pkgs.petsc}:${netcdfFortranParallel}:${pkgs.openmpi}:${hdf5ParallelFull}:$CMAKE_PREFIX_PATH"
            export PYTHONPATH="${pythonEnv}/lib/python3.12/site-packages:$PYTHONPATH"
            export OMPI_MCA_osc="^ucx"
            export PATH="${pythonEnv}/bin:$PATH"
            echo "🎉 Environnement UFEMISM/LADDIE prêt (via Flakes) !"
          '';
        };
      });
  };
}
