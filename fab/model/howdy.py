def hello():
    raise Exception('error')

def sub():
    hello()
    print('ok')

sub()