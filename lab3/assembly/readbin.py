from struct import Struct

def read_records(format, f):
    record_struct = Struct(format)
    chunks = iter(lambda: f.read(record_struct.size), b'')
    return (record_struct.unpack(chunk) for chunk in chunks)

# Example
if __name__ == '__main__':
    with open('test.bin','rb') as f:
        for rec in read_records('i', f):
            print('{:032b}'.format(rec[0] % (1 << 32)))