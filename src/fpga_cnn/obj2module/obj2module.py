import pickle
import re

class ModuleUtil:
    @staticmethod
    def gePortsFromInstTemplate(templateStr=None, file=None):
        lines = []
        if file is not None:
            with open(file, "r") as f:
                lines.append(f.readline())
        else:
            lines = templateStr.split("\n")
        sigs = []
        for line in lines:
            tmp = re.search("\\$\\w+", line)
            if tmp is not None:
                sig = tmp.group(0).lstrip("$")
                sigs.append(sig)
        return sigs

    @staticmethod
    def getContent(file):
        """
        :param file: 文件的路径
        :return:
        """
        with open(file, "r") as f:
            return "\n".join(f.readlines())

class Signal:
    def __init__(self, sigName, sigType, width=1, isConst=False, constVal='0\'b0'):
        self.sigName = sigName
        self.sigType = sigType  # 'wire or reg'
        self.width = width
        self.isConst = isConst
        self.constVal = constVal

    def __repr__(self):
        return '{0} {1} [{2}:0]'.format(self.sigType, self.sigName, self.width - 1)

class CombineLogic:
    def __init__(self, signals):
        self.signals = signals
        self.combineCode = []

class TimingLogic:
    def __init__(self, signals):
        self.signals = signals
        self.timingCode = []

class InstTemplate:
    """
    从定义好的模块中返回的替换模板类
    """
    def __init__(self, str0):
        self.instStr = str0

    def addSignalMap(self, tempSig, realSig):
        """
        :param tempSig: 原始信号名称
        :param realSig: 要添加到括号的信号名称
        :return:
        """
        self.instStr = self.instStr.replace("${0}".format(tempSig), "{1}".format(realSig))

    def __repr__(self):
        return self.instStr

class Module:
    """
    这个类描述了一个模块的模板应该有的具体的框架

    如果要定义一个带有具体参数的模块 需要填充具体的内容到该类的对象的属性中

    如果要从一个定义好的模块对象中获取信息 可以使用这个对象的 获取
    """
    def __init__(self, moduleName):
        # 模块本身具有的对象
        self.moduleName = moduleName
        self.inputPorts = {}  # 模块的输入参数
        self.outputPorts = {} # 模块的输出参数
        self.innerSigs = {}   # 模块的内部信号 即除input 和output之外的reg wire
        self.parameters = {}  # 包含模块的内部参数
        self.isPrimitive = False # 是否是原语 如果是原语 那么将不会有模块内部定义 只会有实例化

        self.instModules = {}  # 模块本身包含的内部其他模块的具体对象
        self.instCode = []    # 模块本身包含的内部其他模块实例代码段 即一个或者多个其他模块对象的实例化代码

        # 模块内部组合逻辑关系
        self.combineLogic = []  # 内部包含多个信号组合关 目前可以认为 组合逻辑代码段

        # 模块内部时序逻辑关系
        self.timingLogic = []   # 内部包含多个状态机 多个代码段

    def getModuleDefine(self):
        """
        生成定义代码
        :return:
        """
        assert not self.isPrimitive, "原语不可实例化"

        # 模块前置定义
        res = []
        res.append("module {0}(".format(self.moduleName))
        res.extend(["{port_name},".format(port_name=isig.sigName) for isig in self.inputPorts.values()])
        res.extend(["{port_name},".format(port_name=osig.sigName) for osig in self.outputPorts.values()])
        res.append("dummy);")
        res.append("")

        res.append("")

        # 模块参数定义
        for item in self.parameters.items():
            res.append("parameter {param_name} = {val};".format(param_name=item[0], val=item[1]))

        # 输入端口定义
        res.append("//input signals")

        for isig in self.inputPorts.values():
            line = []
            line.append("input")
            if isig.width > 1:
                line.append("[{0}:0]".format(isig.width - 1))
            line.append(isig.sigName + ";")
            res.append("\t".join(line))
        #res.extend(["input [{width}: 0] {port_name};".format(port_name=isig.sigName, width=isig.width - 1) for isig in self.inputPorts.values()])

        res.append("")
        # 模块输出定义
        res.append("//output signals")
        for osig in self.outputPorts.values():
            line = []
            line.append("output")
            if osig.sigType == 'reg':
                line.append('reg')
            if osig.width > 1:
                line.append("[{0}:0]".format(osig.width - 1))
            line.append(osig.sigName + ";")
            res.append("\t".join(line))

        # 模块内部信号定义
        res.append("")
        res.append("//inner signal define")

        res.extend(["output [{width}: 0] {port_name};".format(port_name=osig.sigName, width=osig.width - 1) for osig in self.outputPorts.values()])

        #实例化部分
        res.extend(self.instCode)

        res.append("\n"*3)

        # 组合逻辑部分
        res.extend(self.combineLogic)
        res.append("\n" * 3)

        #时序逻辑部分
        res.extend(self.timingLogic)
        res.append("\n" * 3)

        res.append("endmodule")
        return "\n".join(res)

    def getModuleInst(self, instName="default_inst"):
        res = []
        res.append("{0} {1} (".format(self.moduleName, instName))
        for isig in self.inputPorts.values():
            res.append(".{0}(${0}),".format(isig.sigName))
        for osig in self.outputPorts.values():
            res.append(".{0}(${0}),".format(osig.sigName))
        res.append(".dummy(1'b1));")
        return InstTemplate("\n".join(res))

    def outputModuleToFile(self, outputPath):
        instStr = self.getModuleInst()

        with open("{0}/{1}_inst_template.v".format(outputPath, self.moduleName), "w") as f:
            f.write(instStr)

        if not self.isPrimitive:
            moduleDefineStr = self.getModuleDefine()
            with open("{0}/{1}.v".format(outputPath, self.moduleName), "w") as f:
                f.write(moduleDefineStr)

        with open("{0}/{1}.pickle".format(outputPath, self.moduleName), "wb") as f:
            pickle.dump(self, f)

    def getPorts(self):
        res = {}
        res.update(self.inputPorts)
        res.update(self.outputPorts)
        for k in res:
            assert k == res[k].sigName
        return res