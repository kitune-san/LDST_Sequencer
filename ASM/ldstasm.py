import sys
import argparse

class LDSTAssembleError(Exception):
    pass

class LDSTAssembler:
    def __init__(self):
        self.symbol_list = {"A": 0, "B": 1, "FLAGS": 2, "ALU": 3,
                "AND": 0x00, "NAND": 0x04, "OR": 0x20, "NOR": 0x24, "NOT": 0x2C,
                "XOR": 0x40, "XNOR": 0x44, "ADD": 0x80, "ADC": 0x81, "SUB": 0x82,
                "SBC": 0x83, "SHL": 0xA0, "SHCL": 0xA1, "SHR": 0xC0, "SHCR": 0xC1,
                "SAR": 0xE0}
        self.object = []


    def set_symbol(self, symbol, value):
        if symbol not in self.symbol_list.keys():
            try:
                self.symbol_list[symbol] = int(value, 0)
            except ValueError:
                raise LDSTAssembleError("ERROR : Invalid literal : {0}".format(value))
        else:
            raise LDSTAssembleError("ERROR : {0} is already defined.".format(symbol))


    def check_eol(self, token, token_num):
        if token_num < len(token):
            if not token[token_num].startswith(';'):
                raise LDSTAssembleError("ERROR : Syntax error.")


    def parser(self, token):
        try:
            if not token:
                pass
            elif token[0].startswith(';'):
                pass
            elif token[0].endswith(':'):
                self.set_symbol(token[0].rstrip(':'), str(len(self.object)))
                self.check_eol(token, 2);
            elif token[0] == "DEFINE":
                self.set_symbol(token[1], token[2])
                self.check_eol(token, 3);
            elif token[0] == "LD":
                if token[1].startswith("#"):
                    self.object.append([0b0010, token[1].lstrip('#')])
                else:
                    self.object.append([0b0000, token[1]])
                self.check_eol(token, 2);
            elif token[0] == "LDI":
                self.object.append([0b0010, token[1]])
                self.check_eol(token, 2);
            elif token[0] == "ST":
                self.object.append([0b0001, token[1]])
                self.check_eol(token, 2);
            elif token[0] == "CALL":
                self.object.append([0b0100, token[1]])
                self.check_eol(token, 2);
            elif token[0] == "RET":
                self.object.append([0b0101, None])
                self.check_eol(token, 1);
            elif token[0] == "JZ":
                self.object.append([0b1001, token[1]])
                self.check_eol(token, 2);
            elif token[0] == "JC":
                self.object.append([0b1010, token[1]])
                self.check_eol(token, 2);
            elif token[0] == "JO":
                self.object.append([0b1100, token[1]])
                self.check_eol(token, 2);
            elif token[0] == "JMP":
                self.object.append([0b1000, token[1]])
            else:
                raise LDSTAssembleError("ERROR : Syntax error.")
        except IndexError:
            raise LDSTAssembleError("ERROR : Syntax error.")


    def resolver(self):

        for i in range(len(self.object)):
            value = self.object[i][1];
            if value == None:
                value = "0"
            try:
                self.object[i][1] = int(value, 0)
            except ValueError:
                h_flag = False

                if value.endswith(".H"):
                    h_flag = True
                    value = value.rstrip(".H")
                elif value.endswith(".L"):
                    value = value.rstrip(".L")

                try:
                    value = self.symbol_list[value]
                except KeyError:
                    raise LDSTAssembleError("ERROR : symbol {} is not defined.".format(value))

                if h_flag:
                    self.object[i][1] = (value & 0xFF00) >> 8
                else:
                    self.object[i][1] = (value & 0x00FF)


    def assemble(self, filename):
        line_number = 1
        try:
            with open(filename, "r") as file:
                for line in file:
                    token = line.upper().split()
                    self.parser(token)
                    line_number = line_number + 1
        except LDSTAssembleError as e:
            raise LDSTAssembleError("{0} : {1} : {2}".format(filename, line_number, e))

        self.resolver()


def output_memfile(filename, object):
    with open(filename, "w") as file:
        for o in object:
            file.write("{0:01x}{1:02x}\n".format(o[0], o[1]))


def output_verilogfile(filename, object):
    address_bit = len(object).bit_length();

    with open(filename, "w") as file:
        file.write("module LDST_PROGRAM_ROM (clock, address, data_out);\n")
        file.write("    input clock;\n")
        file.write("    input [{0}:0] address;\n".format(address_bit-1))
        file.write("    output reg [12:0] data_out;\n")
#        file.write("    reg [12:0] data_out;\n")
        file.write("\n")
        file.write("    always @ (posedge clock)\n")
        file.write("    begin\n")
        file.write("        case (address)\n")

        for i, o in enumerate(object):
            file.write("            {0}'h{1:04x}: data_out = 12'h{2:01x}{3:02x};\n".format(address_bit, i, o[0], o[1]))

        file.write("            default: data_out = 12'hxxx;\n")
        file.write("        endcase\n")
        file.write("    end\n")
        file.write("endmodule\n")


if __name__ == '__main__':

    parser = argparse.ArgumentParser(prog='LDST Assembler')

    parser.add_argument('asmfile')
    parser.add_argument('-o', '--out')

    args = parser.parse_args()

    asm  = LDSTAssembler()

    try:
        asm.assemble(args.asmfile)

        if not args.out:
            output_memfile("a.mem", asm.object)
        elif args.out.endswith(".mem"):
            output_memfile(args.out, asm.object)
        elif args.out.endswith(".v"):
            output_verilogfile(args.out, asm.object)
        else:
            output_memfile(args.out, asm.object)

    except FileNotFoundError as e:
        print(e)
        sys.exit(-1)
    except LDSTAssembleError as e:
        print(e)
        sys.exit(-1)

