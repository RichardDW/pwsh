def gen123():
	yield 1
	yield 2
	yield 3

for x in gen123():
	print(x)
