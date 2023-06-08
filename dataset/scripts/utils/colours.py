from colorama import init, Fore, Style


class ColoredText:
    def __int__(self):
        init()

    @staticmethod
    def info(msg):
        return f"{Fore.CYAN}{msg}{Style.RESET_ALL}"

    @staticmethod
    def error(msg):
        return f"{Fore.RED}{msg}{Style.RESET_ALL}"

    @staticmethod
    def warning(msg):
        return f"{Fore.YELLOW}{msg}{Style.RESET_ALL}"

    @staticmethod
    def success(msg):
        return f"{Fore.GREEN}{msg}{Style.RESET_ALL}"
