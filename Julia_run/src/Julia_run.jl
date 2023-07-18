
module Julia_run

import BattMo

function jsondict(dict)
    println(dict)
end

function setup_wrapper(exported)
    println(exported)
    states, reports, extra, exported = BattMo.run_battery(exported);

    # timesteps = extra[:timesteps]
    
    # time = cumsum(timesteps)
    # E    = [state[:BPP][:Phi][1] for state in states]

    # plt = plot(time, E;
    #        title     = "Discharge Voltage",
    #        size      = (1000, 800),
    #        label     = "BattMo.jl",
    #        xlabel    = "Time / s",
    #        ylabel    = "Voltage / V",
    #        linewidth = 4,
    #        xtickfont = font(pointsize = 15),
    #        ytickfont = font(pointsize = 15)
    # )
    #display(plt)
end

end # module
