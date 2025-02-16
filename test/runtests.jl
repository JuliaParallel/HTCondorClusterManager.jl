import HTCondorClusterManager
import Test

import Distributed

# Bring some names into scope, just for convenience:
using Distributed: addprocs, rmprocs
using Distributed: workers, nworkers
using Distributed: procs, nprocs
using Distributed: remotecall_fetch, @spawnat
using Test: @testset, @test, @test_skip

@testset "HTCondorClusterManager.jl" begin
    @warn "The HTCondorClusterManager.jl package currently does not have any tests"
    @test_skip false
end # @testset
