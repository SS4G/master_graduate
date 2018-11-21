import sys
if __name__ == "__main__":
    tmp_str = '''
    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_{level}_{idx}(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_{inA}),
    	.inB(tmp_out_{inB}),
    	.outSum(tmp_out_{outS})
    );
    '''
    wires = []
    insts = []
    wr = 0
    #((level_pre ,idxA), (level_pre, idxB), (level, idxO))
    connections = []

    cur_level = [i for i in range(26)] # current level input
    level_idx = 0 # which level is operate
    while len(cur_level) > 1:
        next_level_Idx = 0
        next_level = []
        for cur_level_idx in range(0, len(cur_level), 2):
            inA = cur_level[cur_level_idx]
            inB = cur_level[cur_level_idx + 1] if cur_level_idx + 1 < len(cur_level) else None
            next_level.append(next_level_Idx)
            connections.append({"inA":"%02d_%02d" % (level_idx, inA), "inB": "%02d_%02d" % (level_idx, inB) if inB is not None else '0', "outS":"%02d_%02d" % (level_idx + 1, next_level_Idx)})
            next_level_Idx += 1
        level_idx += 1
        cur_level = next_level
    insts = []

    for con in connections:
        print(con)
        level = con["outS"].split("_")[0]
        idx = con["outS"].split("_")[1]
        tmp_d = {"level": level, "idx": idx}
        tmp_d.update(con)
        insts.append(tmp_str.format(**tmp_d))


    sys.stdout = open("out.txt", "w")

    # define inner wires
    wires = set()
    for c in connections:
        for v in c.values():
            if v != '0':
                wires.add("wire [WIDTH-1:0] tmp_w_{0};".format(v))
    for line in sorted(list(wires)):
        print(line)

    for i in range(26):
        print("assign {0} = {1};".format("tmp_w_0_%02d" % i, "%02d" % i))

    for j in insts:
        print(j)

    sys.stdout.close()