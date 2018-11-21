from master_graduate.src.fpga_cnn.obj2module.obj2module import Signal, Module, ModuleUtil

# 向不同的模块定义函数中传递不同的
# 调用模块定义函数 会创建一个对应的声明具有该参数的 模块定义Verilog文件 以及对应的python表示的对象(在一个全局字典中 key是模块对应的名称 保存在module.pickle中)


def instReplaceCheck(inst_strs):
    for codePart in inst_strs:
        for line in codePart.split('\n'):
            assert "$" not in line, "存在未填充的信号"
            # 待添加检查 在inst上的信号是否属于模块本身
            # 待添加检查 添加到inst中的信号应该是有效的 不应该是高阻态之类的东西

def createAddPrimitive(moduleLib, width=32):
    """
    创建定点加法器模板
    :return:
    """
    moduleName = "AddPrim_width_{width}".format(width=width)
    adderPrimitive = Module(moduleName)
    adderPrimitive.inputPorts = {
        "A": Signal("A", sigType='wire', width=width),
        "B": Signal("B", sigType='wire', width=width),
        "CLK": Signal("CLK", sigType='wire', width=width)
    }  # 模块的输入参数
    adderPrimitive.outputPorts = {
        "S": Signal("S", sigType='wire', width=width),
    } # 模块的输出参数
    adderPrimitive.isPrimitive = True # 是否是原语 如果是原语 那么将不会有模块内部定义 只会有实例化


    adderPrimitive.outputModuleToFile("./verilog_generated")
    moduleLib[moduleName] = adderPrimitive

def createMulPrimitive(moduleLib, width=64):
    """
    创建定点乘法器模板
    :param moduleLib:
    :param width:
    :return:
    """
    moduleName = "MulPrim_width_{width}".format(width=width)
    mulPrimitive = Module(moduleName)
    mulPrimitive.inputPorts = {
        "A": Signal("A", sigType='wire', width=width),
        "B": Signal("B", sigType='wire', width=width),
        "CLK": Signal("CLK", sigType='wire', width=width)
    }  # 模块的输入参数
    mulPrimitive.outputPorts = {
        "P": Signal("P", sigType='wire', width=width)
    } # 模块的输出参数
    mulPrimitive.isPrimitive = True # 是否是原语 如果是原语 那么将不会有模块内部定义 只会有实例化

    mulPrimitive.outputModuleToFile("./verilog_generated")
    moduleLib[moduleName] = mulPrimitive

def createAdderModule(moduleLib, width=32):
    moduleName = "FixAdd_width_{width}".format(width=width)
    fixAdd = Module(moduleName)

    fixAdd.inputPorts = {
        "inA": Signal("inA", sigType='wire', width=width),
        "inB": Signal("inB", sigType='wire', width=width),  # 模块的输入参数
        "clk": Signal("clk", sigType='wire', width=1)
    }

    fixAdd.outputPorts = {
        "outS": Signal("outS", sigType='wire', width=width)

    } # 模块的输出参数
    fixAdd.isPrimitive = False # 是否是原语 如果是原语 那么将不会有模块内部定义 只会有实例化

    #inst here 填充实例化部分
    addPrimType0 = "AddPrim_width_{width}".format(width=width)
    fixAdd.instModules[addPrimType0] = moduleLib[addPrimType0]

    #addPrimInstPorts = fixAdd.instModules["add_prime_{width}".format(width=width)].getPorts()
    tmpInstTemplate = fixAdd.instModules[addPrimType0].getModuleInst("inst_0")

    #将实例化信号映射关系填入
    tmpInstTemplate.addSignalMap("A", "inA")
    tmpInstTemplate.addSignalMap("B", "inB")
    tmpInstTemplate.addSignalMap("S", "outS")
    tmpInstTemplate.addSignalMap("CLK", "clk")
    fixAdd.instCode.append(tmpInstTemplate.__repr__())

    fixAdd.outputModuleToFile("./verilog_generated")
    moduleLib[moduleName] = fixAdd

def createMulModule(width, point):
    """
    :param width: 模块总字长
    :param point: 模块部分
    :return:
    """
    pass

def createMulVecModule(width=32):
    moduleName = "FixAdd_width_{width}".format(width=width)
    fixAdd = Module(moduleName)
    items = []
    for i in range(25):
        items.append((str(i), Signal("inA_{:0>2d}".format(i), sigType='wire', width=width)))
        items.append((str(i), Signal("inB_{:0>2d}".format(i), sigType='wire', width=width)))

    for i in range(25):


        items.append((str(i), Signal("inA_{:0>2d}".format(i), sigType='wire', width=width)))

    fixAdd.inputPorts = {
        "inA": Signal("inA", sigType='wire', width=width),
        "inB": Signal("inB", sigType='wire', width=width),  # 模块的输入参数
        "clk": Signal("clk", sigType='wire', width=1)
    }

    fixAdd.outputPorts = {
        "outS": Signal("outS", sigType='wire', width=width)

    } # 模块的输出参数

def createAddTreeModule():
    pass

def createVectorInnerProuctModule():
    pass

def createCnnModule():
    pass

def createReluModule():
    pass

def createPoolModule():
    pass

def createDenseModule():
    pass

if __name__ == "__main__":
    moduleLib = {}
    createAddPrimitive(moduleLib, 32)
    createMulPrimitive(moduleLib, 32)
    createAdderModule(moduleLib, 32)