using Plots
using Interpolations
using LinearAlgebra
using colors
using Interpolations

DEFAULT_COLOR_CONFIGURATION = Dict(
    "center" => [4.51920, 0.453724],
    "ref_angle" => 3 * pi / 4,
    "state_definitions" => Dict(
        "HSS" => Dict("hue_limits" => [300, 360], "color" => "red"),
        "LHS" => Dict("hue_limits" => [-20, 140], "color" => "blue"),
        "HIMS" => Dict("hue_limits" => [140, 220], "color" => "green"),
        "SIMS" => Dict("hue_limits" => [220, 300], "color" => "yellow")
    ),
    "rms_spans" => Dict(
        -20 => [0.3, 0.7],
        0 => [0.3, 0.7],
        10 => [0.3, 0.6],
        40 => [0.25, 0.4],
        100 => [0.25, 0.35],
        150 => [0.2, 0.3],
        170 => [0.0, 0.3],
        200 => [0, 0.15],
        370 => [0, 0.15]
    )
)

using Interpolations

function _get_rms_span_functions(configuration=DEFAULT_COLOR_CONFIGURATION)
    rms_spans = configuration["rms_spans"]

    x = collect(keys(rms_spans))
    ymin = [v[1] for v in values(rms_spans)]
    ymax = [v[2] for v in values(rms_spans)]

    ymin_func = LinearInterpolation(x, ymin)
    ymax_func = LinearInterpolation(x, ymax)

    return ymin_func, ymax_func
end

function _create_rms_hue_plot(; polar=false, plot_spans=false, configuration=DEFAULT_COLOR_CONFIGURATION)
    if polar
        fig = plot(proj=:polar)
        rlims!(fig, (0, 0.75))
        yticks!(fig, [0, 0.25, 0.5, 0.75, 1])
        grid!(fig, true)
    else
        fig = plot(xlims=(0, 360), ylims=(0, 0.7), xlabel="Hue", ylabel="Fractional rms")
    end

    if !plot_spans
        return fig
    end

    ymin_func, ymax_func = _get_rms_span_functions(configuration)

    for (state, details) in configuration["state_definitions"]
        color = parse(Colorant, details["color"])
        xmin, xmax = details["hue_limits"]

        x_func = x -> x
        if polar
            x_func = x -> deg2rad(x)
        end

        xs = range(x_func(xmin), stop=x_func(xmax), length=20)
        ymin_vals = ymin_func(range(xmin, stop=xmax, length=20))
        ymax_vals = ymax_func(range(xmin, stop=xmax, length=20))

        plot!(fig, xs, ymin_vals, fill_between=(ymin_vals, ymax_vals), fillalpha=0.1, color=color, label="")

        if xmin < 0 && !polar
            xs_extra = range(x_func(xmin + 360), stop=x_func(360), length=20)
            ymin_vals_extra = ymin_func(range(xmin, stop=0, length=20))
            ymax_vals_extra = ymax_func(range(xmin, stop=0, length=20))
            plot!(fig, xs_extra, ymin_vals_extra, fill_between=(ymin_vals_extra, ymax_vals_extra), fillalpha=0.1, color=color, label="")
        end
        if xmax > 360 && !polar
            xs_extra = range(x_func(0), stop=x_func(xmax - 360), length=20)
            ymin_vals_extra = ymin_func(range(360, stop=xmax, length=20))
            ymax_vals_extra = ymax_func(range(360, stop=xmax, length=20))
            plot!(fig, xs_extra, ymin_vals_extra, fill_between=(ymin_vals_extra, ymax_vals_extra), fillalpha=0.1, color=color, label="")
        end
    end

    return fig
end

function _limit_angle_to_360(angle)
    while angle >= 360
        angle -= 360
    end
    while angle < 0
        angle += 360
    end
    return angle
end

function _hue_line_data(center, angle, ref_angle=3 * pi / 4)
    plot_angle = mod(-angle + ref_angle, 2 * pi)

    m = tan(plot_angle)
    if isinf(m)
        x = fill(center[1], 20)
        y = range(-4, stop=4, length=20)
    else
        x = range(0, stop=4, length=20) .* sign(cos(plot_angle)) .+ center[1]
        y = center[2] .+ m .* (x .- center[1])
    end
end

function _trace_states(ax, configuration=DEFAULT_COLOR_CONFIGURATION; kwargs...)
    center = log10.(configuration["center"])
    for (state, details) in configuration["state_definitions"]
        color = details["color"]
        hue0, hue1 = details["hue_limits"]
        hue_mean = (hue0 + hue1) / 2
        hue_angle = mod(-deg2rad(hue_mean) + 3 * pi / 4, 2 * pi)

        radius = 1.4
        txt_x = radius * cos(hue_angle) + center[1]
        txt_y = radius * sin(hue_angle) + center[2]
        annotate!(ax, txt_x, txt_y, text(state, :black, :center))

        x0, y0 = _hue_line_data(center, deg2rad(hue0), ref_angle=configuration["ref_angle"])
        next_angle = hue0 + 5.0
        x1, y1 = _hue_line_data(center, deg2rad(hue0), ref_angle=configuration["ref_angle"])

        while next_angle <= hue1
            x0, y0 = x1, y1
            x1, y1 = _hue_line_data(center, deg2rad(next_angle), ref_angle=configuration["ref_angle"])
            
            polygon!(ax, [x0[1], x0[end], x1[end]], [y0[1], y0[end], y1[end]], color=color, lw=0, label="")
            next_angle += 5.0
        end
    end
end

function _create_pc_plot(xrange=[-2, 2], yrange=[-2, 2], plot_spans=false, configuration=DEFAULT_COLOR_CONFIGURATION)
    fig = plot()
    xlabel!("log_{10}PC1")
    ylabel!("log_{10}PC2")
    
    if !plot_spans
        xlims!(xrange)
        ylims!(yrange)
        return fig
    end
    
    center = log10.(configuration["center"])
    xlims!(center[1] .+ xrange)
    ylims!(center[2] .+ yrange)
    
    for angle in 0:20:360
        x, y = _hue_line_data(center, deg2rad(angle), ref_angle=configuration["ref_angle"])
        plot!(x, y, lw=0.2, ls=:dot, color=:black, alpha=0.3)
    end
    
    scatter!([center[1]], [center[2]], marker=:+, color=:black)
    
    limit_angles = Set(vcat([configuration["state_definitions"][state]["hue_limits"] for state in keys(configuration["state_definitions"]) ]...))
    limit_angles = [_limit_angle_to_360(angle) for angle in limit_angles]
    
    for angle in limit_angles
        x, y = _hue_line_data(center, deg2rad(angle), ref_angle=configuration["ref_angle"])
        plot!(x, y, lw=1, ls=:dot, color=:black, alpha=1)
    end
    
    _trace_states(fig, configuration=configuration, alpha=0.1)
    
    return fig
end

#using number instead of float64(julia) to allow broader values
function plot_power_colors(
    p1,
    p1e,
    p2,
    p2e;
    plot_spans=false,
    configuration=DEFAULT_COLOR_CONFIGURATION
    )
    """
    Plot power colors.

    Parameters
    ----------
    p1 : Number
        The first power value.
    p1e : Number
        The error in the first power value.
    p2 : Number
        The second power value.
    p2e : Number
        The error in the second power value.

    Other Parameters
    ----------------
    center : (Number, Number)
        The center coordinates of the plot. Default is (4.51920, 0.453724).
    plot_spans : Bool
        Whether to plot the spans. Default is false.
    configuration: Dict
        The color configuration to use. Default is DEFAULT_COLOR_CONFIGURATION.

    Returns
    -------
    fig : Plot
        The Julia Plot object representing the power color plot.
    """
    p1e = 1 / p1 * p1e
    p2e = 1 / p2 * p2e
    p1 = log10(p1)
    p2 = log10(p2)
    
    fig = _create_pc_plot(plot_spans=plot_spans, configuration=configuration)
    
    scatter!([p1], [p2], marker=:circle, color=:black, zorder=10)
    errorbar!([p1], [p2], xerr=[p1e], yerr=[p2e], alpha=0.4, color=:black)
    
    return fig
end

#add docstring for documentation
function plot_hues(rms, 
    rmse, 
    pc1,
    pc2; 
    polar=false, 
    plot_spans=false, 
    configuration=DEFAULT_COLOR_CONFIGURATION
    )
    """
    Plot hues.

    Parameters
    ----------
    rms : Array{Number}
        The root mean square values.
    rmse : Array{Number}
        The errors in the root mean square values.
    pc1 : Array{Number}
        The first power color component.
    pc2 : Array{Number}
        The second power color component.

    Other Parameters
    ----------------
    polar : Bool
        Whether to use a polar plot. Default is false.
    plot_spans : Bool
        Whether to plot the spans. Default is false.
    configuration: Dict
        The color configuration to use. Default is DEFAULT_COLOR_CONFIGURATION.

    Returns
    -------
    ax : Plot
        The Julia Plot object representing the hues plot.
    """
    hues = hue_from_power_color(collect(pc1), collect(pc2))  # Ensure arrays
    
    ax = _create_rms_hue_plot(polar=polar, plot_spans=plot_spans, configuration=configuration)
    hues = mod.(hues, 2 * pi)
    if !polar
        hues = rad2deg.(hues)
    end
    
    plot!(hues, rms, yerror=rmse, seriestype=:scatter, alpha=0.5)  # Correct error bars
    
    return ax
end

