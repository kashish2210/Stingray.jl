using Stingray
using Test
using FFTW, Distributions, Statistics, StatsBase, HDF5
using Random
using Distributions
using Stingray.PowerColors: DEFAULT_COLOR_CONFIGURATION

rng = Random.Xoshiro(1259723)
Random.seed!(42)

include("test_fourier.jl")
include("test_gti.jl")
include("test_power_colors.jl")
