import sys

def main():
    if len(sys.argv) == 1:
        print("python3 c8_to_p8.py filename.c8")
        return

    c8_file = sys.argv[1]
    c8_base = c8_file.split(".")[0]

    with open(c8_file, "rb") as read_file, open(c8_base.lower() + ".p8", "w") as write_file:
        write_file.write("game={")
        byte = read_file.read(1)
        while byte:
            write_file.write('0x{:02x},'.format(ord(byte)))
            byte = read_file.read(1)

        write_file.write("}")

if __name__ == "__main__":
    main()
