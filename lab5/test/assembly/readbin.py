from struct import Struct

header = """memory_initialization_radix  = 16;
memory_initialization_vector ="""

def read_records(format, f):
    record_struct = Struct(format)
    chunks = iter(lambda: f.read(record_struct.size), b'')
    return (record_struct.unpack(chunk) for chunk in chunks)

# Example
if __name__ == '__main__':
    with open('test.bin','rb') as f:
        print(header)
        for rec in read_records('i', f):
            print('{:08x}'.format(rec[0] % (1 << 32)))
