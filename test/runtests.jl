import HTCondorClusterManager
import Test

import Distributed

# Bring some names into scope, just for convenience:
using Distributed: addprocs, rmprocs
using Distributed: workers, nworkers
using Distributed: procs, nprocs
using Distributed: remotecall_fetch, @spawnat
using Test: @testset, @test, @test_skip

using HTCondorClusterManager: addprocs_htc, HTCManager

@testset "HTCondorClusterManager.jl" begin
    include("elastic.jl")

    include("condor.jl")

end # @testset
