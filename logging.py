class ColorLogging:
    """
        分级别答应不同颜色的日志
    """

    def __init__(self):
        pass



    @staticmethod
    def getTimeStr():
        import datetime as dt
        return dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    @staticmethod
    def colorStr(str0, color="yellow", highlight=True):
        """
        -------------------------------------------
        -------------------------------------------
        字体色     |       背景色     |      颜色描述
        -------------------------------------------
        30        |        40       |       黑色
        31        |        41       |       红色
        32        |        42       |       绿色
        33        |        43       |       黃色
        34        |        44       |       蓝色
        35        |        45       |       紫红色
        36        |        46       |       青蓝色
        37        |        47       |       白色
        -------------------------------------------
        :param info:
        :param color:
        :return:
        """
        colorStr = {
            "red":      '\033[{highlight};31;40m {str0} \033[0m',
            "green":    '\033[{highlight};32;40m {str0} \033[0m',
            "yellow":   '\033[{highlight};33;40m {str0} \033[0m',
            "blue":     '\033[{highlight};34;40m {str0} \033[0m',
            "purple":   '\033[{highlight};35;40m {str0} \033[0m',
            "greenblue":'\033[{highlight};36;40m {str0} \033[0m',
            "white":    '\033[{highlight};37;40m {str0} \033[0m',
        }

        return colorStr[color].format(highlight= 1 if highlight else 0, str0=str0)

    @staticmethod
    def debug(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="DEBUG", time=ColorLogging.getTimeStr(), info=info), color="blue"))

    @staticmethod
    def info(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="INFO", time=ColorLogging.getTimeStr(), info=info), color="green"))

    @staticmethod
    def warn(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="WARNING", time=ColorLogging.getTimeStr(), info=info), color="yellow"))

    @staticmethod
    def error(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="ERROR", time=ColorLogging.getTimeStr(), info=info), color="red"))

    @staticmethod
    def critical(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="CRITICAL", time=ColorLogging.getTimeStr(), info=info), color="purple"))
