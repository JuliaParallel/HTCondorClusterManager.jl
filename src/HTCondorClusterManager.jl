module HTCondorClusterManager

import Distributed
import Sockets
import Pkg

using Distributed: launch, manage, kill, init_worker, connect

export launch, manage, kill, init_worker, connect


worker_cookie() = begin Distributed.init_multi(); cluster_cookie() end
worker_arg() = `--worker=$(worker_cookie())`

include("condor.jl")

end
