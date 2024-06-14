import logging
import logging.config

class Logger:
    def __init__(self, config=None, name='app_logger', log_file='app_logger.log'):
        if config:
            logging.config.dictConfig(config)
            self.logger = logging.getLogger(name)
        else:
            self.logger = logging.getLogger(name)
            self.logger.setLevel(logging.DEBUG)

            # 创建一个文件处理器
            fh = logging.FileHandler(log_file)
            fh.setLevel(logging.DEBUG)

            # 创建一个控制台处理器
            ch = logging.StreamHandler()
            ch.setLevel(logging.DEBUG)

            # 创建一个格式器并将其添加到处理器
            formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
            fh.setFormatter(formatter)
            ch.setFormatter(formatter)

            # 将处理器添加到日志器
            self.logger.addHandler(fh)
            self.logger.addHandler(ch)

    def get_logger(self):
        return self.logger
