@test Distributed.nprocs() == 1
@test Distributed.nworkers() == 1
@test Distributed.procs() == [1]
@test Distributed.workers() == [1]

mgr = HTCManager(4)
Distributed.addprocs(mgr)

@test Distributed.nprocs() == 5
@test Distributed.nworkers() == 4
@test Distributed.procs() == [1, 2, 3, 4, 5]
@test Distributed.workers() == [2, 3, 4, 5]
