```@meta
CurrentModule = Stingray
```

# Welcome to Stingray.jl

Documentation for [Stingray.jl](https://github.com/matteobachetti/Stingray.jl).

```@index
```

## Overview
**Stingray.jl** is a Julia package for **X-ray spectral timing analysis**, designed for high-performance astrophysical data processing.

### Features:
- **Fast Fourier Transforms (FFT)** for analyzing periodic signals.
- **Periodograms** to measure signal variability.
- **Cross-spectra and coherence analysis** for multi-band signals.
- **Optimized for performance** with Julia’s native speed advantages.

## Get Started
🚀 **New to Stingray.jl?** Follow these steps:

1. **[Installation Guide](installation.md)** → Set up Stingray.jl.
2. **[Usage Guide](usage.md)** → Learn how to analyze time-series data.
4. **[Contributing](contributing.md)** → Want to help improve Stingray.jl?

## Quick Example
Here's a simple example to analyze an X-ray light curve:
```julia
using Stingray, Random, Plots

# Generate Simulated Light Curve
N = 1024  # Number of data points
t = collect(0:0.1:(N-1)*0.1)  # Time array
Random.seed!(42)
light_curve = sin.(2π * 0.5 .* t) + 0.3 * randn(N)  # Sine wave + noise

# Plot Light Curve
plot(t, light_curve, label="Simulated Light Curve", xlabel="Time (s)", ylabel="Intensity", title="X-ray Light Curve", legend=:topright)
```

🚀 **Start exploring Stingray.jl today!**