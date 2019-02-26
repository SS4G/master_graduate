from master_graduate.logging import ColorLogging
from functools import reduce, partial


# 探索定点数和浮点数的区别 以及定点数的加法运算
# 所有的加法运算都使用二进制字符串来表述
# 测试时位宽默认16bit
class BinaryCalcUtil:
    """
    使用二进制完成整数的加法乘法计算
    """

    @staticmethod
    def reverseBit(binStr):
        return "".join(['1' if i == '0' else '0' for i in binStr])

    @staticmethod
    def adder(binStr1, binStr2, bits=16):
        """
        实现数字逻辑加法器的功能 均按照无符号的数字来处理
        binStr1 binStr2 从左到右是高位到低位
        """
        assert len(binStr1) == len(binStr2) == bits, "invalid width"
        carry = 0
        res = ['0', ] * bits
        for i in range(bits - 1, -1, -1):
            thisBit = int(binStr1[i]) + int(binStr2[i]) + carry
            res[i] = '1' if thisBit % 2 == 1 else '0'
            carry = 0 if int(binStr1[i]) + int(binStr2[i]) + carry < 2 else 1

            #print(i, res[i], carry)
        return "".join(res)

    @staticmethod
    def multipliexerUnsigned(binStr1, binStr2, bits=16):
        res = []  # 保证不为空
        for idx, c in enumerate(reversed(binStr1)):
            if c == '1':
                tmp_res = []
                tmp_res.append('0' * (bits - idx))
                tmp_res.append(binStr2)
                tmp_res.append('0' * idx)
                res.append("".join(tmp_res))
        print(res)
        tmpRes = '0' * (2 * bits)
        for i in res:
            tmpRes = BinaryCalcUtil.adder(tmpRes, i, bits=2 * bits)
        return tmpRes

    @staticmethod
    def multipliexer(binStr1, binStr2, bits=16, signed=False):
        if not signed:
            return BinaryCalcUtil.multipliexerUnsigned(binStr1, binStr2, bits=bits)
        else:
            posFlag1 = True
            posFlag2 = True
            if binStr1[0] == '1':
                posFlag1 = False
                binStr1 = BinaryCalcUtil.add_1(BinaryCalcUtil.reverseBit(binStr1))
            if binStr2[0] == '1':
                posFlag2 = False
                binStr2 = BinaryCalcUtil.add_1(BinaryCalcUtil.reverseBit(binStr2))
            absRes = BinaryCalcUtil.multipliexerUnsigned(binStr1, binStr2, bits=bits)
            if posFlag1 is posFlag2:
                return absRes
            else:
                return BinaryCalcUtil.add_1(BinaryCalcUtil.reverseBit(absRes))

    @staticmethod
    def sub_1(binStr):
        """
        对无符号数执行减一操作
        :param binStr:
        :param bits:
        :return:
        """
        res = list(binStr)
        i = len(binStr) - 1
        while i >= 0:
            if res[i] == '1':
                res[i] = '0'
                break
            else:
                res[i] = '1'
            i -= 1
        return ''.join(res)

    @staticmethod
    def add_1(binStr):
        """
        :return:
        """
        res = list(binStr)
        i = len(binStr) - 1
        while i >= 0:
            if res[i] == '0':
                res[i] = '1'
                break
            else:
                res[i] = '0'
            i -= 1
        return ''.join(res)

    @staticmethod
    def reverseSignedNum(binStr):
        if binStr[0] == '0':
            return BinaryCalcUtil.add_1(BinaryCalcUtil.reverseBit(binStr))
        else:
            return BinaryCalcUtil.reverseBit(BinaryCalcUtil.sub_1(binStr))

    @staticmethod
    def floatToBin(floatVal, bits):
        assert floatVal < 1, "a"
        res = []
        for i in range(bits):
            bitVal = 1 / (2 ** (i + 1))
            if abs(floatVal - bitVal) < 0.000000000000001:
                res.append('1')
                floatVal -= bitVal
            elif floatVal > bitVal:
                res.append('1')
                floatVal -= bitVal
            elif floatVal < bitVal:
                res.append('0')
        return "".join(res)

    @staticmethod
    def toBinStr(intVal, bits):
        if intVal >= 0:
            binStr = bin(intVal)[2:]
            return '0' * (bits - len(binStr)) + binStr
        else:
            binStr = bin(abs(intVal))[2:]
            binStr = '0' * (bits - len(binStr)) + binStr
            binStr = BinaryCalcUtil.add_1(BinaryCalcUtil.reverseBit(binStr))
            return binStr

    @staticmethod
    def toIntVal(binStr, signed=True):
        posFlag = True
        if signed:
            if binStr[0] == '1':
                posFlag = False
                binStr = BinaryCalcUtil.reverseBit(BinaryCalcUtil.sub_1(binStr))
        res = 0
        for idx, c in enumerate(reversed(binStr)):
            res += 0 if c == '0' else 1 << idx
        return res if posFlag else -res

class UnsignedBinaryNum:
    """
    整数的二进制表示
    """

    def __init__(self, val, bits=16):
        assert val >= 0, "must > 0"
        self.bits = bits
        self.strVal = self.uint2bin_(val, bits)
        self.decVal = val

    def __repr__(self):
        return "{0} {1}bits".format(self.decVal, self.bits)

    def __str__(self):
        return "{0} {1}bits".format(self.decVal, self.bits)

    def __add__(self, other):
        # 模拟加法溢出
        resVal = (self.decVal + other.decVal) & ((1 << self.bits) - 1)
        return UnsignedBinaryNum(resVal, bits=self.bits)

    def __mul__(self, other):
        # 模拟乘法溢出
        resVal = (self.decVal * other.decVal) & ((1 << (self.bits * 2)) - 1)
        return UnsignedBinaryNum(resVal, bits=2 * self.bits)

    def __eq__(self, other):
        return self.decVal == other.decVal

    def __ne__(self, other):
        return self.decVal != other.decVal

    def __ge__(self, other):
        return self.decVal >= other.decVal

    def __le__(self, other):
        return self.decVal <= other.decVal

    def __gt__(self, other):
        return self.decVal > other.decVal

    def __lt__(self, other):
        return self.decVal < other.decVal

    def uint2bin_(self, uintVal, bits=16):
        tmp_str = bin(uintVal)[2:]
        assert len(tmp_str) <= bits, "value is too large"
        res = '0' * (bits - len(tmp_str)) + tmp_str
        return res


class SignedBinaryNum:
    def __init__(self, val=0, bits=16, strVal=None):
        if strVal is not None:
            self.bits = len(strVal)
            self.strVal = strVal
        else:
            if val >= 0:
                assert val <= (1 << (bits - 1)) - 1, "out of range"
                self.bits = bits
                self.strVal = bin(val)[2:]
            else:
                assert abs(val) <= (1 << (bits - 1)), "out of range"
                self.bits = bits
                self.strVal = bin(abs(val))[2:]
                self.strVal = BinaryCalcUtil.reverseBit(BinaryCalcUtil.add_1(self.strVal))

    def getDecVal(self):
        if self.strVal[0] == '0':
            return int(self.strVal[1:], 2)
        else:
            return -int(BinaryCalcUtil.reverseSignedNum(self.strVal), 2)

    def __repr__(self):
        return "{0} {1}bits".format(self.getDecVal(), self.bits)

    def __str__(self):
        return "{0} {1}bits".format(self.getDecVal(), self.bits)

    def __add__(self, other):
        # 模拟加法溢出
        assert other.bits == self.bits, "bits no equal"
        resStrVal = BinaryCalcUtil.adder(self.strVal, other.strVal, bits=self.bits)
        return SignedBinaryNum(strVal=resStrVal)

    def __mul__(self, other):
        # 模拟乘法 乘法无论如何不会溢出
        resVal = self.getDecVal() * other.getDecVal()
        return SignedBinaryNum(val=resVal, bits=self.bits * 2)

    def __eq__(self, other):
        return self.getDecVal() == other.getDecVal()

    def __ne__(self, other):
        return self.getDecVal() != other.getDecVal()

    def __ge__(self, other):
        return self.getDecVal() >= other.getDecVal()

    def __le__(self, other):
        return self.getDecVal() <= other.getDecVal()

    def __gt__(self, other):
        return self.getDecVal() > other.getDecVal()

    def __lt__(self, other):
        return self.getDecVal() < other.getDecVal()


class FixPointNum:
    """
    二进制表示的定点数
    """
    def __init__(self, floatVal=None, intBits=8, pointBits=16, fixVal=None):
        self.pointBits = pointBits
        self.intBits = intBits
        if fixVal is None:
            self.fixValue = int(floatVal * (1 << pointBits))
        else:
            self.fixValue = fixVal

        if not (-(2 ** (pointBits + intBits - 1)) <= self.fixValue <= 2 ** (pointBits + intBits - 1) - 1): #out of range
            tmp_bin_str = BinaryCalcUtil.toBinStr(self.fixValue, bits=64)[-(intBits+pointBits):]
            #print("------", BinaryCalcUtil.toBinStr(self.fixValue, bits=64))
            #print(tmp_bin_str)

            if tmp_bin_str[0] == '0':
                self.fixValue = int(tmp_bin_str, 2)
            else:
                # 128 may cause
                if tmp_bin_str == '1' + ('0' * (intBits + pointBits)):
                    self.fixValue = -int(tmp_bin_str, 2)
                self.fixValue = -int(BinaryCalcUtil.reverseBit(BinaryCalcUtil.sub_1(tmp_bin_str)), 2)
                #print("fixed value", self.fixValue)
        #self.binstr = BinaryCalcUtil.toBinStr(self.fixValue, intBits + pointBits)
        #print(self.binstr)

    def __add__(self, other):
        #assert other.intBits == self.intBits and other.pointBits == self.pointBits, "invalid fix num"
        return FixPointNum(fixVal=self.fixValue + other.fixValue, intBits=self.intBits, pointBits=self.pointBits)

    def __mul__(self, other):
        #assert other.intBits == self.intBits and other.pointBits == self.pointBits, "invalid fix num"
        return FixPointNum(fixVal=(self.fixValue * other.fixValue) >> self.pointBits , intBits=self.intBits, pointBits=self.pointBits)

    def __le__(self, other):
        return self.fixValue <= other.fixValue

    def __ge__(self, other):
        return self.fixValue >= other.fixValue

    def __lt__(self, other):
        return self.fixValue < other.fixValue

    def __gt__(self, other):
        return self.fixValue > other.fixValue

    def __eq__(self, other):
        return self.fixValue == other.fixValue

    def __ne__(self, other):
        return self.fixValue != other.fixValue

    def getFloatVal(self):
        return self.fixValue / (2 ** self.pointBits)

    def getFixVal(self):
        return self.fixValue

    def __repr__(self):
        #return "{0} Bin:{1}.{2}, Fix:{3}".format(self.getFloatVal(), self.binstr[:self.intBits], self.binstr[self.intBits:], self.fixValue)
        return "{0}".format(self.getFloatVal())


def test(testCases):
    for casea, caseb in testCases:
        fixNuma = FixPointNum(floatVal=casea, pointBits=16, intBits=16)
        fixNumb = FixPointNum(floatVal=caseb, pointBits=16, intBits=16)

        print(casea, "*" ,caseb)
        res = fixNuma * fixNumb
        #print(res)
        print(abs(res.getFloatVal() - (casea * caseb)))

        print(casea, "+" ,caseb)
        res = fixNuma + fixNumb
        #print(res)
        print(abs(res.getFloatVal() - (casea + caseb)))


if __name__ == "__main__":
    floatVal = 0.75
    testCaseNormal = [
        (3.0, 0.75),
        (4.0, 0.75),
        (-3.0, 0.75),
        (-4.0, 0.25),
        (127, 0.25),
        (3.726191231, 0.2509108211),
    ]

    testCaseOverflow = [
        (127.0, 127.0),
        (255.0, 255.0),
        (-1.0, -128.0),
        (-128.0, -128.0),
        (-255.0, -255.0)
    ]

    #test(testCaseNormal)

    #print("----------------------")
    ##test(testCaseOverflow)
    #
    #print(FixPointNum(floatVal=127.0, pointBits=8, intBits=8))
    #print(FixPointNum(floatVal=255.0, pointBits=8, intBits=8))
    #print(FixPointNum(floatVal=128.0, pointBits=8, intBits=8))
    #print(FixPointNum(floatVal=-128.0, pointBits=8, intBits=8))
    #print(FixPointNum(floatVal=-1.0, pointBits=8, intBits=8))
    binRes = BinaryCalcUtil.multipliexer('11111111', '11111111', bits=8)
    print(binRes)
    print(BinaryCalcUtil.toIntVal(binRes, signed=True))

