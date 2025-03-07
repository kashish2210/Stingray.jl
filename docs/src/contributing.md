```@meta
CurrentModule = Stingray
```

# Installation Guide for Stingray.jl

Documentation for [Stingray.jl](https://github.com/matteobachetti/Stingray.jl).

```@index
```

## Installing Julia
Before installing Stingray.jl, ensure you have **Julia v1.7 or later** installed. If you haven’t installed Julia yet, follow these steps:
1. Download Julia from the official site: [https://julialang.org/downloads/](https://julialang.org/downloads/)
2. Follow the installation instructions for your operating system.
3. Add Julia to your system’s PATH for easy command-line access.

## Installing Stingray.jl
To install Stingray.jl, open a Julia REPL (press `]` to enter the package manager) and run:

```julia
using Pkg
Pkg.add("Stingray")
```

This will download and install all necessary dependencies.

## Cloning the Development Version
If you want the latest features, clone the GitHub repository and work in development mode:

```julia
Pkg.add(url="https://github.com/matteobachetti/Stingray.jl")
Pkg.develop("Stingray")
```

## Checking Your Installation
To verify the installation, run the following in the Julia REPL:

```julia
using Stingray
@info "Stingray.jl loaded successfully!"
```

```@autodocs
Modules = [Stingray]
```


