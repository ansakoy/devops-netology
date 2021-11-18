import time


def counter():
    count = 0
    while True:
        print(count)
        time.sleep(5)
        count += 1


if __name__ == '__main__':
    counter()