'''
Generator for Cumin functions. 
'''

import os

# func constrain<A, B, C>(fn: (A, B) -> C) -> BaseClosure<(A, B), C> {
#     return BaseClosure(fn: fn).setCurry { a in return [fn(try convert(a[0], to: A.self), try convert(a[1], to: B.self)) as! AnyObject]}
# }

template = '''
func constrain<$genericList>(fn: ($params) -> ($returns)) -> BaseClosure<($params), ($returns)> {
    return BaseClosure(fn: fn).setCurry { a in return [fn(try convert(a[0], to: A.self), try convert(a[1], to: B.self)) as! AnyObject]}
}
'''

PATH = 'Deferred/AnyFunction.swift'

generics = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
returns = ['R', 'S', 'T', 'U', 'V', 'X', 'Y', 'Z']


def render(template, args, ret):
    name = stringIntegers[len(args)]
    cumin = ', '.join(["%s.self <- a[%s]" % (x, i) for i, x in enumerate(args)])
    both = ', '.join([x + ": PR" for x in args] + [x + ": PR" for x in ret])
    args = ', '.join(args)
    invokcation = "fn(%s)" % cumin

    return (template % (name, both, args, invokcation,)).replace("<>", "")


# Replaces the exising lines with these new lines
def foldLines(f, addition):
    start_marker = '// Start Generic Shotgun'
    end_marker = '// End Generic Shotgun'
    ret = []

    with open(f) as inf:
        ignoreLines = False
        written = False

        for line in inf:
            if end_marker in line:
                ignoreLines = False

            if ignoreLines:
                if not written:
                    written = True
                    [ret.append(x) for x in addition]
            else:
                ret.append(line)

            if start_marker in line:
                ignoreLines = True

    return ret


def foldAndWrite(fileName, lines):
    lines = foldLines(fileName, lines)

    with open(fileName, 'w') as f:
        [f.write(x) for x in lines]


if __name__ == '__main__':
    lines = []

    for j in range(6):  # The number of return types
        for i in range(7):  # Number of parameters
            lines.append(render(template, generics[:i], returns[:j]))

    foldAndWrite(PATH, lines)
