# ClusterManager for HTCondor

export HTCManager, addprocs_htc

struct HTCManager <: ClusterManager
    np::Integer
end

function condor_script(portnum::Integer, np::Integer, params::Dict)
    dir = params[:dir]
    exename = params[:exename]
    exeflags = params[:exeflags]
    extrajdl = get(params, :extrajdl, [])
    extraenv = get(params, :extraenv, [])
    extrainputs = get(params, :extrainputs, [])
    telnetexe = get(params, :telnetexe, "/usr/bin/telnet")
    home = ENV["HOME"]
    hostname = ENV["HOSTNAME"]
    jobname = "julia-$(getpid())"
    tdir = "$home/.julia-htc"
    run(`mkdir -p $tdir`)

    scriptf = open("$tdir/$jobname.sh", "w")
    println(scriptf, "#!/bin/sh")
    for line in extraenv
        println(scriptf, line)
    end
    println(scriptf, "cd $(Base.shell_escape(dir))")
    println(scriptf, "$(Base.shell_escape(exename)) $(Base.shell_escape(exeflags)) -e 'using Distributed; start_worker($(repr(worker_cookie())))' | $telnetexe $(Base.shell_escape(hostname)) $portnum")
    close(scriptf)

    input_files = ["$tdir/$jobname.sh"]
    append!(input_files, extrainputs)
    subf = open("$tdir/$jobname.sub", "w")
    println(subf, "executable = /bin/bash")
    println(subf, "arguments = ./$jobname.sh")
    println(subf, "universe = vanilla")
    println(subf, "should_transfer_files = yes")
    println(subf, "transfer_input_files = $(join(input_files, ','))")
    println(subf, "Notification = Error")
    for line in extrajdl
        println(subf, line)
    end
    for i = 1:np
        println(subf, "output = $tdir/$jobname-$i.o")
        println(subf, "error= $tdir/$jobname-$i.e")
        println(subf, "queue")
    end
    close(subf)

    "$tdir/$jobname.sub"
end

function _my_wait_without_timeout(f::Function; timeout_seconds)
    each_sleep_duration = 5
    for i = 1:each_sleep_duration:timeout_seconds
        sleep(each_sleep_duration)
        result = f()
        if result
            return nothing
        end
    end
    msg = "Timeout ($(timeout_seconds) seconds) exceeded"
    error(msg)
end

function launch(manager::HTCManager, params::Dict, instances_arr::Array, c::Condition)
    let
        mgr_desc = "HTCondor"
        msg = "The $(mgr_desc) functionality in ClusterManagers.jl is currently not actively maintained. " *
              "We are currently looking for a new maintainer. " *
              "If you are an active user of the $(mgr_desc) functionality and are interested in becoming the maintainer, " *
              "Please open an issue on the JuliaParallel/ClusterManagers.jl repo: " *
              "https://github.com/JuliaParallel/ClusterManagers.jl/issues"
        Base.depwarn(msg, Symbol(typeof(manager)))
    end
    try
        portnum = rand(8000:9000)
        portnum, server = listenany(ip"0.0.0.0", portnum)
        np = manager.np

        script = condor_script(portnum, np, params)
        cmd = `condor_submit $script`
        pipeline = Base.pipeline(ignorestatus(cmd); stdout=Base.stdout, stderr=Base.stderr)
        proc = run(pipeline; wait = false)
        _my_wait_without_timeout(; timeout_seconds = 5 * 60) do
            @info "condor_q:"
            run(`condor_q`)
            @info "condor_status:"
            run(`condor_status`)
            Base.process_exited(proc)
        end
        if !Base.process_exited(proc)
            @error "batch queue not available (could not run condor_submit)" Base.process_exited(proc)
            return nothing
        end
        if !success(proc)
            @error "batch queue not available (could not run condor_submit)" Base.process_exited(proc) success(proc)
            return nothing
        end
        print("Waiting for $np workers: ")

        for i=1:np
            conn = accept(server)
            config = WorkerConfig()

            config.io = conn

            push!(instances_arr, config)
            notify(c)
            print("$i ")
        end
        println(".")

   catch ex
        bt = catch_backtrace()
        @error "Error launching HTCondor" exception=(ex,bt)
        # @error "Error launching HTCondor" exception=ex
        println("Error launching condor")
        println(ex)
   end
end

function kill(manager::HTCManager, id::Int64, config::WorkerConfig)
    remotecall(exit,id)
    close(config.io)
end

function manage(manager::HTCManager, id::Integer, config::WorkerConfig, op::Symbol)
    if op == :finalize
        if !isnothing(config.io)
            close(config.io)
        end
#     elseif op == :interrupt
#         job = config[:job]
#         task = config[:task]
#         # this does not currently work
#         if !success(`qsig -s 2 -t $task $job`)
#             println("Error sending a Ctrl-C to julia worker $id (job: $job, task: $task)")
#         end
    end
end

addprocs_htc(np::Integer) = addprocs(HTCManager(np))
