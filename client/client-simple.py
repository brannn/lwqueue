from lwqueue import lwqueue

queue = lwqueue('127.0.0.1', 'pythontest')

queue.push('testing')
print queue.pop()

queue.push( [1, 2, 5, 8] )
print queue.pop()