import requests
# from bs4 import BeautifulSoup
# import schedule
# import time

response = requests.get("https://192.168.40.158/login.html")
print(response)

# def buy_ticket():
#     # 1. 发送HTTP请求获取购买页面的HTML内容
#     response = requests.get("https://192.168.40.158/login.html")
#     print(response)

#     # 2. 解析HTML内容，提取相关信息
#     soup = BeautifulSoup(response.text, 'html.parser')
#     ticket_info = soup.find("div", class_="ticket-info")  # 假设票价和数量信息在一个类名为"ticket-info"的div中

#     # 3. 根据相关信息进行抢票逻辑
#     # ...

#     # 4. 提交订单或其他购票操作
#     # ...

# def schedule_ticket():
#     # 设置抢票的执行时间，这里以演唱会开售前10分钟为例
#     schedule.every().day.at("09:50").do(buy_ticket)

#     while True:
#         schedule.run_pending()
#         time.sleep(1)

# # 启动抢票程序
# # schedule_ticket()
