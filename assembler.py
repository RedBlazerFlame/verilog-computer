import argparse

"""
An assembler for .asm files using the instruction set described in codes.xlsx

Note to self:
- Test the CAL and RET commands
"""

# Defining constants
MAX_INST_LEN = 1024

# Storing the expected number of inputs per instruction
inst_numarg = {
    "ADI": 2,
    "SBI": 2,
    "MOV": 2,
    "CMP": 2,
    "NOP": 0,
    "HLT": 0,
    "ADD": 3,
    "SUB": 3,
    "NOR": 3,
    "AND": 3,
    "XOR": 3,
    "RSH": 3,
    "LDI": 2,
    "MUL": 3,
    "JMP": 1,
    "BRH": 2,
    "CAL": 1,
    "RET": 0,
    "LOD": 3,
    "STR": 3,
}

inst_codenum = {
    "NOP": 0,
    "HLT": 1,
    "ADD": 2,
    "SUB": 3,
    "NOR": 4,
    "AND": 5,
    "XOR": 6,
    "RSH": 7,
    "LDI": 8,
    "MUL": 9,
    "JMP": 10,
    "BRH": 11,
    "CAL": 12,
    "RET": 13,
    "LOD": 14,
    "STR": 15,
}

BRH_CHECK_CODES = set(["zero", "notzero", "carry", "notcarry"])
BRH_CHECK_CODE_BINS = {
    "notzero": 0,
    "zero": 1,
    "notcarry": 2,
    "carry": 3
}
HLT_CODE = int("0001000000000000", base=2)
THREE_INP_CODES = set(["ADD", "SUB", "NOR", "AND", "XOR", "RSH", "MUL"])
MEM_CODES = set(["LOD", "STR"])
SINGLE_INST_ADDR_CODES = set(["JMP", "CAL"])
NUM_REG = 16

# Convert to fixed bin length
def fw_bin(i, s):
    b = bin(i)[2:]
    return ("0" * (s - len(b))) + b

# Checks if a number matches the format "rNUMBER"
def is_reg_format(s):
    if(len(s) == 0):
        return False
    
    if(s[0] != "r"):
        return False
    
    try:
        int(s[1:])
    except ValueError:
        return False
    return True

def extract_reg_num(s):
    return int(s[1:]) if is_reg_format(s) else -1

def is_int(s):
    try: int(s)
    except ValueError: return False
    return True

# Converts Pseudo-instructions to Actual Instructions
def parse_pseudoinst(inst, inst_num=None, flags=set()):
    inst_tokens = inst.split(" ")
    marker_flag = None

    if(inst_tokens[0].startswith(".")):
        marker_flag = inst_tokens[0]
        inst_tokens.pop(0)
    
    # Process all pseudo-commands
    cmd = inst_tokens[0]

    if(cmd not in inst_numarg.keys()):
        raise SyntaxError(f"Line {inst_num + 1}: Unrecognized opcode '{cmd}'")

    if(len(inst_tokens[1:]) != inst_numarg[cmd]):
        raise SyntaxError(f"Line {inst_num + 1}: {cmd} expects {inst_numarg[cmd]} argument{'' if inst_numarg[cmd] == 1 else 's'}, found {len(inst_tokens[1:])}")

    if(cmd == "ADI"):
        """
        .flag ADI ra immediate
        ->
        .flag LDI r15 immediate
        ADD ra r15 ra
        """

        [ra, immediate] = inst_tokens[1:]

        ra_num = extract_reg_num(ra)

        if(ra_num < 0 or ra_num >= NUM_REG):
            raise SyntaxError(f"Line {inst_num + 1}: {ra} is not a valid register")

        if(not is_int(immediate)):
            raise SyntaxError(f"Line {inst_num + 1}: The immediate value to be loaded is not an integer")
        
        immediate_int = int(immediate)

        if(immediate_int < 0 or immediate_int >= 256):
            raise SyntaxError(f"Line {inst_num + 1}: The immediate value to be loaded must be in the range [0, 255]")

        return [
            (marker_flag, ["LDI", "r15", immediate]),
            (None, ["ADD", ra, "r15", ra]),
        ]
    elif(cmd == "SBI"):
        """
        .flag SBI ra immediate
        ->
        .flag LDI r15 immediate
        SUB ra r15 ra
        """

        [ra, immediate] = inst_tokens[1:]

        ra_num = extract_reg_num(ra)

        if(ra_num < 0 or ra_num >= NUM_REG):
            raise SyntaxError(f"Line {inst_num + 1}: {ra} is not a valid register")

        if(not is_int(immediate)):
            raise SyntaxError(f"Line {inst_num + 1}: The immediate value to be loaded is not an integer")
        
        immediate_int = int(immediate)

        if(immediate_int < 0 or immediate_int >= 256):
            raise SyntaxError(f"Line {inst_num + 1}: The immediate value to be loaded must be in the range [0, 255]")

        return [
            (marker_flag, ["LDI", "r15", immediate]),
            (None, ["SUB", ra, "r15", ra]),
        ]
    elif(cmd == "MOV"):
        """
        .flag MOV ra rb
        ->
        .flag ADD ra r0 rb
        """

        [ra, rb] = inst_tokens[1:]

        ra_num = extract_reg_num(ra)
        rb_num = extract_reg_num(rb)

        if(ra_num < 0 or ra_num >= NUM_REG):
            raise SyntaxError(f"Line {inst_num + 1}: {ra} is not a valid register")
        
        if(rb_num < 0 or rb_num >= NUM_REG):
            raise SyntaxError(f"Line {inst_num + 1}: {rb} is not a valid register")
        return [
            (marker_flag, ["ADD", ra, "r0", rb]),
        ]
    elif(cmd == "CMP"):
        """
        .flag CMP ra rb
        ->
        .flag SUB ra rb r15
        """

        [ra, rb] = inst_tokens[1:]

        ra_num = extract_reg_num(ra)
        rb_num = extract_reg_num(rb)

        if(ra_num < 0 or ra_num >= NUM_REG):
            raise SyntaxError(f"Line {inst_num + 1}: {ra} is not a valid register")
        
        if(rb_num < 0 or rb_num >= NUM_REG):
            raise SyntaxError(f"Line {inst_num + 1}: {rb} is not a valid register")
        return [
            (marker_flag, ["SUB", ra, rb, "r15"]),
        ]
    elif(cmd in THREE_INP_CODES):
        r1 = extract_reg_num(inst_tokens[1])
        r2 = extract_reg_num(inst_tokens[2])
        r3 = extract_reg_num(inst_tokens[3])
        if((r1 < 0 or r1 >= NUM_REG) or (r2 < 0 or r2 >= NUM_REG) or (r3 < 0 or r3 >= NUM_REG)):
            raise SyntaxError(f"Line {inst_num + 1}: One of the arguments is not a valid register")
    elif(cmd in MEM_CODES):
        r1 = extract_reg_num(inst_tokens[1])
        r2 = extract_reg_num(inst_tokens[2])
        if((r1 < 0 or r1 >= NUM_REG) or (r2 < 0 or r2 >= NUM_REG)):
            raise SyntaxError(f"Line {inst_num + 1}: One of the first two arguments is not a valid register")
        
        offset = inst_tokens[3]

        if(not is_int(offset)):
            raise SyntaxError(f"Line {inst_num + 1}: The offset is not a valid integer")
        
        offset_int = int(offset)
        if(offset_int < 0 or offset_int >= 16):
            raise SyntaxError(f"Line {inst_num + 1}: The offset must be in the range [0, 15], received {offset_int}")
    elif(cmd in SINGLE_INST_ADDR_CODES):
        inst_addr = inst_tokens[1]

        if((not is_int(inst_addr)) and (inst_addr[0] != ".")):
            raise SyntaxError(f"Line {inst_num + 1}: The provided instruction address is not an integer")
        
        if(is_int(inst_addr)):
            if(not (0 <= int(inst_addr) < MAX_INST_LEN)):
                raise SyntaxError(f"Line {inst_num + 1}: The provided instruction address is not in the range [0, {MAX_INST_LEN - 1}]")
        else:
            if(inst_addr not in flags):
                raise SyntaxError(f"Line {inst_num + 1}: The provided instruction address flag '{inst_addr}' does not appear anywhere else")
    elif(cmd == "BRH"):
        z = inst_tokens[1]
        if(z not in BRH_CHECK_CODES):
            raise SyntaxError(f"Line {inst_num + 1}: The check code '{z}' is not valid. Check code must be one of ({', '.join(list(BRH_CHECK_CODES))})")

        inst_addr = inst_tokens[2]

        if((not is_int(inst_addr)) and (inst_addr[0] != ".")):
            raise SyntaxError(f"Line {inst_num + 1}: The provided instruction address is not an integer")
        
        if(is_int(inst_addr)):
            if(not (0 <= int(inst_addr) < MAX_INST_LEN)):
                raise SyntaxError(f"Line {inst_num + 1}: The provided instruction address is not in the range [0, {MAX_INST_LEN - 1}]")
        else:
            if(inst_addr not in flags):
                raise SyntaxError(f"Line {inst_num + 1}: The provided instruction address flag '{inst_addr}' does not appear anywhere else")
    elif(cmd == "LDI"):
        r1 = extract_reg_num(inst_tokens[1])
        if(r1 < 0 or r1 >= NUM_REG):
            raise SyntaxError(f"Line {inst_num + 1}: {inst_tokens[1]} is not a valid register")
        immediate = inst_tokens[2]

        if(not is_int(immediate)):
            raise SyntaxError(f"Line {inst_num + 1}: The immediate value to be loaded is not an integer")
        
        immediate_int = int(immediate)

        if(immediate_int < 0 or immediate_int >= 256):
            raise SyntaxError(f"Line {inst_num + 1}: The immediate value to be loaded must be in the range [0, 255]")
    
    return [
        (marker_flag, inst_tokens),
    ]

# Reduces a sequence of pseudo-instructions to machine-level instructions
def reduce_pseudoinst(insts):
    if(len(insts) > MAX_INST_LEN):
        raise SyntaxError(f"At most {MAX_INST_LEN} lines of asm allowed. {len(insts)} line(s) received.v (Hint: Some pseudoinstructions may expand to multiple lines of primitive instructions. Check that you are not using too many pseudoinstructions)")

    flags = set()
    for i, inst in enumerate(insts):
        first_entry = inst.split(" ")[0]
        if(len(first_entry) > 0 and first_entry[0] == "."):
            if(first_entry in flags):
                raise SyntaxError(f"Line {i + 1}: The flag {first_entry} is ambiguous. Ensure that each flag refers to a unique line.")
            else:
                flags.add(first_entry)
    res = []
    for i, inst in enumerate(insts):
        res.extend(parse_pseudoinst(inst, i, flags))
    return res


# Reduces a machine instruction into a 16-bit integer, and further reduces the integer into the correct radix
def reduce_insts(insts):
    flag_lines = dict()

    for i, inst in enumerate(insts):
        flag = inst[0]
        if(flag is not None):
            flag_lines[flag] = i

    # Converting to Machine Code
    res = []

    for inst in insts:
        flag = inst[0]
        opcode = inst[1][0]
        args = inst[1][1:]

        if(opcode == "NOP"):
            res.append(0)
        elif(opcode == "HLT"):
            res.append(HLT_CODE)
        elif(opcode in THREE_INP_CODES):
            res.append(int(f"{fw_bin(inst_codenum[opcode], 4)}{fw_bin(extract_reg_num(args[0]), 4)}{fw_bin(extract_reg_num(args[1]), 4)}{fw_bin(extract_reg_num(args[2]), 4)}", base=2))
        elif(opcode in MEM_CODES):
            res.append(int(f"{fw_bin(inst_codenum[opcode], 4)}{fw_bin(extract_reg_num(args[0]), 4)}{fw_bin(extract_reg_num(args[1]), 4)}{fw_bin(int(args[2]), 4)}", base=2))
        elif(opcode in SINGLE_INST_ADDR_CODES):
            addr_int = 0
            if(is_int(args[0])):
                addr_int = int(args[0])
            else:
                addr_int = flag_lines[args[0]]
            res.append(int(f"{fw_bin(inst_codenum[opcode], 4)}00{fw_bin(addr_int, 10)}", base=2))
        elif(opcode == "BRH"):
            addr_int = 0
            if(is_int(args[1])):
                addr_int = int(args[1])
            else:
                addr_int = flag_lines[args[1]]
            res.append(int(f"{fw_bin(inst_codenum[opcode], 4)}{fw_bin(BRH_CHECK_CODE_BINS[args[0]], 2)}{fw_bin(addr_int, 10)}", base=2))
        elif(opcode == "LDI"):
            res.append(int(f"{fw_bin(inst_codenum[opcode], 4)}{fw_bin(extract_reg_num(args[0]), 4)}{fw_bin(int(args[1]), 8)}", base=2))
        
    return res

# Parsing Arguments
parser = argparse.ArgumentParser(description="An assembler for my computer")
parser.add_argument("filename", type=str, help="The name of the assembly file to assemble")

args = parser.parse_args()

rawlines = []

try:
    with open(args.filename, "r") as f:
        rawlines = f.readlines()
except FileNotFoundError:
    print(f"Error: File {args.filename} does not exist!")
    exit(1)

rawlines = list(map(lambda x: x.strip(), rawlines))

machinsts = reduce_pseudoinst(rawlines)

to_print = []
for i, machinst in enumerate(reduce_insts(machinsts)):
    to_print.append(f"mem[10'd{i}] = 16'h{hex(machinst)[2:]};")

with open(args.filename[:-4] + ".mccode", "w") as f:
    f.write("\n".join(to_print))