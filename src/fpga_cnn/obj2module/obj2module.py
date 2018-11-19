class Signal:
    def __init__(self, sigName, sigType, isPort, width=1, isConst=False, constVal='0\'b0'):
        self.sigName = sigName
        self.sigType = sigType  # 'wire or reg'
        self.width = width
        self.isConst = isConst
        self.constVal = constVal

    def __repr__(self):
        return '{0} {1} [{2}:0]'.format(self.sigType, self.sigName, self.width - 1)

class Condition:
    def __init__(self, sigA, sigB, op):
        self.sigA = sigA
        self.sigB = sigB
        self.op = op

class Module:
    def __init__(self, moduleName):
        # 模块本身具有的对象
        self.moduleName = moduleName
        self.inputPorts = {}  # 模块的输入参数
        self.outputPorts = {} # 模块的输出参数
        self.innerSigs = {}   # 模块的内部信号 即除input 和output之外的reg wire
        self.parameters = {}  # 包含模块的内部参数
        self.isPrimitive = False # 是否是原语 如果是原语 那么将不会有模块内部定义 只会有实例化
        self.innerInst = {}    # 模块本身包含的内部其他模块实例

        # 模块内部组合逻辑关系
        self.combineLogic = []  # 内部包含多个信号组合关 目前可以认为 组合逻辑全部由assign生成

        # 模块内部时序逻辑关系
        self.timingLogic = []   # 内部包含多个状态机 #认为状态输出

    def printModuleDefine(self):
        """
        生成定义代码
        :return:
        """
        pass

    def printModuleInst(self):
        pass