```@meta
CurrentModule = Stingray
```

# Usage Guide for Stingray.jl

Documentation for [Stingray.jl](https://github.com/matteobachetti/Stingray.jl).

```@index
```

## Overview
Stingray.jl provides powerful tools for **X-ray spectral timing analysis**, including **Fourier transforms, periodograms, and coherence calculations**. This guide covers the basic usage of the package.

## Importing the Package
After installation, load Stingray.jl in your Julia session:
```julia
using Stingray
```

## Creating a Simulated Light Curve
```julia
using Random, Plots

# Generate Simulated Light Curve
N = 1024  # Number of data points
t = collect(0:0.1:(N-1)*0.1)  # Time array
Random.seed!(42)
light_curve = sin.(2π * 0.5 .* t) + 0.3 * randn(N)  # Sine wave + noise

# Plot Light Curve
plot(t, light_curve, label="Simulated Light Curve", xlabel="Time (s)", ylabel="Intensity", title="X-ray Light Curve", legend=:topright)
```

## Computing a Power Spectrum
```julia
using FFTW

# Compute Fourier Transform
frequencies = fftshift(fftfreq(N, 0.1))  # Compute frequency bins
power_spectrum = abs.(fftshift(fft(light_curve))).^2  # Compute power spectrum

# Plot Power Spectrum
plot(frequencies, power_spectrum, xlabel="Frequency (Hz)", ylabel="Power", title="Power Spectrum", legend=false)
```

```@autodocs
Modules = [Stingray]
```


