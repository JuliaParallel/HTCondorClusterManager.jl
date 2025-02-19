# HTCondorClusterManager.jl

The `HTCondorClusterManager.jl` package implements code for HTCondor clusters.

Implemented in this package:

| Job queue system | Command to add processors |
| ---------------- | ------------------------- |
| HTCondor | `addprocs_htc(np::Integer)` or `addprocs(HTCManager(np))` |

The functionality in this package originally used to live in [ClusterManagers.jl](https://github.com/JuliaParallel/ClusterManagers.jl).
