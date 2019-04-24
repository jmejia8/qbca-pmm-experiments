using Bilevel, BilevelBenchmark

function getBilevel(fnum, D)
    F(x, y) = PMM_leader(x, y, fnum)
    f(x, y) = PMM_follower(x, y, fnum)

    bounds = Array([ -10ones(D) 10ones(D) ]')

    return F, f, bounds, bounds

end

function main()
    fnum = 1
    D = 6

    F, f, bounds_ul, bounds_ll = getBilevel(fnum, D)

    optimize(F, f, bounds_ul, bounds_ll, QBCA(D))

end

main()