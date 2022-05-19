def increment(index):
    index += 1
    return index


def get_square(numb):
    return numb * numb


def print_numb(numb):
    print("Number is {}".format(numb))


idx = 0
while idx < 10:
    idx = increment(idx)
    print_numb(get_square(idx))
