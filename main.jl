using Bilevel, BilevelBenchmark
import Printf.@printf
using Suppressor
import LinearAlgebra.norm
using JLD

NRUNS = 1

function configure(output_dir="./")
    all_data_dir = string(output_dir, "output")
    summary_data_dir = string(output_dir, "summary")
    
    !isdir(all_data_dir)     && mkdir(all_data_dir)
    !isdir(summary_data_dir) && mkdir(summary_data_dir)

end

function getBilevel(fnum, D_ul, D_ll)
    F(x, y) = PMM_leader(x, y, fnum)
    f(x, y) = PMM_follower(x, y, fnum)

    bounds_ul = Array([ -10ones(D_ul) 10ones(D_ul) ]')
    bounds_ll = Array([ -10ones(D_ll) 10ones(D_ll) ]')

    return F, f, bounds_ul, bounds_ll

end

function getQBCA(fnum, D_ul, D_ll)
    F, f, bounds_ul, bounds_ll = getBilevel(fnum, D_ul, D_ll)
    method = QBCA(size(bounds_ul, 2); options = Bilevel.Options(F_tol=1e-4, f_tol=1e-4, store_convergence=true))
    result = nothing
    @suppress begin
        result = optimize(F, f, bounds_ul, bounds_ll, method, Bilevel.Information(F_optimum=0.0, f_optimum=0.0))
    end
    result
end

function main()
    D_ul = 2
    D_ll = 3
    configure()

    for fnum = 1:5
        F, f, bounds_ul, bounds_ll = getBilevel(fnum, D_ul, D_ll)
        result_list = []
        for r = 1:NRUNS
            result = getQBCA(fnum, D_ul, D_ll)
            @printf("PMM%d \t run = %d \t F = %.4e \t f = %.4e \t ‖x‖ = %.4e  ‖y‖ = %.4e \n", fnum, r, result.best_sol.F, result.best_sol.f, norm(result.best_sol.x), norm(result.best_sol.y))
            println("x = ", result.best_sol.x)
            println("y = ", result.best_sol.y)
            # store data
            # save("output/SMD_$(D_ul)_$(D_ll)/SMD$(fnum)_r$(r).jld", "result", result)
            push!(result_list, result)
        end
        # save("output/SMD_$(D_ul)_$(D_ll)/SMD$(fnum).jld", "result_list", result_list)
    end
end

main()
