# custom_cpu_v
# Custom 16-Bit CPU Instruction Set Architecture (ISA)
**Reference Manual v1.0**

## 1. Instruction Formats
The CPU utilizes a fixed 16-bit instruction word length. Based on the decoding logic, there are three primary instruction formats:

**Register Format (R-Type)** - Used for Register-to-Register operations.
| Opcode (4) | Sub-Opcode (4) | R1 / Dest (4) | R2 / Source (4) |
|------------|----------------|---------------|-----------------|
| `[15:12]`  | `[11:8]`       | `[7:4]`       | `[3:0]`         |

**Immediate Format (I-Type)** - Used for Register-to-Immediate operations.
| Opcode (4) | Sub-Opcode (4) | R1 / Dest (4) | Immediate (4) |
|------------|----------------|---------------|---------------|
| `[15:12]`  | `[11:8]`       | `[7:4]`       | `[3:0]`       |

**Branch Format (B-Type)** - Used for Jumps and Conditional Branches.
| Opcode (4) | Sub-Opcode (4) | Offset / Address (8) |
|------------|----------------|----------------------|
| `[15:12]`  | `[11:8]`       | `[7:0]`              |

---

## 2. Registers and Flags
*   **General Purpose Registers:** 16 Registers (`R0` through `R15`), 16-bits each.
*   **Flag Register:** 7-bit register updated by ALU and CMP operations.
    *   `Z` [6]: Zero
    *   `C` [5]: Carry / Borrow
    *   `N` [4]: Negative / Sign
    *   `V` [3]: Signed Overflow
    *   `GT` [2]: Greater Than (Unsigned/Signed based on CMP)
    *   `LT` [1]: Less Than (Unsigned/Signed based on CMP)
    *   `EQ` [0]: Equal

---

## 3. Instruction Set Reference Table

### Arithmetic Instructions
| Mnemonic | Opcode | Sub-Op | Description | Flags Affected |
|:---|:---:|:---:|:---|:---:|
| `ADD R1, R2`  | `0100` | `0000` | R1 = R1 + R2 | Z, C, N, V |
| `ADC R1, R2`  | `0100` | `0001` | R1 = R1 + R2 + Carry | Z, C, N, V |
| `ADI R1, imm` | `0100` | `0010` | R1 = R1 + imm | Z, C, N, V |
| `SUB R1, R2`  | `0111` | `0000` | R1 = R1 - R2 | Z, C, N, V |
| `SBB R1, R2`  | `0111` | `0001` | R1 = R1 - R2 - Borrow | Z, C, N, V |
| `SUBI R1, imm`| `0111` | `0010` | R1 = R1 - imm | Z, C, N, V |
| `MUL R1, R2`  | `1100` | `0000` | R1 = R1 * R2 (Unsigned) | Z, N |
| `MULI R1, imm`| `1100` | `0001` | R1 = R1 * imm (Unsigned) | Z, N |
| `MULS R1, R2` | `1101` | `0000` | R1 = R1 * R2 (Signed) | Z, N |
| `MULSI R1, imm`| `1101` | `0001` | R1 = R1 * imm (Signed) | Z, N |
| `INC1 R1`     | `1110` | `0000` | R1 = R1 + 1 | Z, C, N, V |
| `INC2 R1`     | `1110` | `0001` | R1 = R1 + 2 | Z, C, N, V |
| `INC4 R1`     | `1110` | `0010` | R1 = R1 + 4 | Z, C, N, V |
| `INC8 R1`     | `1110` | `0011` | R1 = R1 + 8 | Z, C, N, V |
| `DEC1 R1`     | `1110` | `1000` | R1 = R1 - 1 | Z, C, N, V |
| `DEC2 R1`     | `1110` | `1001` | R1 = R1 - 2 | Z, C, N, V |
| `DEC4 R1`     | `1110` | `1010` | R1 = R1 - 4 | Z, C, N, V |
| `DEC8 R1`     | `1110` | `1011` | R1 = R1 - 8 | Z, C, N, V |

### Logical Instructions
| Mnemonic | Opcode | Sub-Op | Description | Flags Affected |
|:---|:---:|:---:|:---|:---:|
| `AND R1, R2`  | `1000` | `0000` | R1 = R1 & R2 | Z, N |
| `ANDI R1, imm`| `1000` | `0001` | R1 = R1 & imm | Z, N |
| `OR R1, R2`   | `1011` | `0000` | R1 = R1 \| R2 | Z, N |
| `ORI R1, imm` | `1011` | `0001` | R1 = R1 \| imm | Z, N |
| `XOR R1, R2`  | `1010` | `0000` | R1 = R1 ^ R2 | Z, N |
| `XORI R1, imm`| `1010` | `0001` | R1 = R1 ^ imm | Z, N |
| `NOT R1`      | `1001` | `0000` | R1 = ~R1 | Z, N |

### Shift and Rotate Instructions
*(Assuming Bug #7 fix is applied to carry out)*
| Mnemonic | Opcode | Sub-Op | Description | Flags Affected |
|:---|:---:|:---:|:---|:---:|
| `LSH R1, R2`  | `0011` | `0000` | Logical Shift Left by R2 | Z, N, C |
| `LSHI R1, imm`| `0011` | `0001` | Logical Shift Left by imm | Z, N, C |
| `RSH R1, R2`  | `0011` | `0010` | Logical Shift Right by R2 | Z, N, C |
| `RSHI R1, imm`| `0011` | `0011` | Logical Shift Right by imm | Z, N, C |
| `ASH R1, R2`  | `0011` | `0100` | Arithmetic Shift Right by R2 | Z, N, C |
| `ASHI R1, imm`| `0011` | `0101` | Arithmetic Shift Right by imm | Z, N, C |
| `ROR R1, R2`  | `0011` | `0110` | Rotate Right by R2 | Z, N, C |
| `RORI R1, imm`| `0011` | `0111` | Rotate Right by imm | Z, N, C |
| `ROL R1, R2`  | `0011` | `1000` | Rotate Left by R2 | Z, N, C |
| `ROLI R1, imm`| `0011` | `1001` | Rotate Left by imm | Z, N, C |

### Data Transfer & Memory Instructions
| Mnemonic | Opcode | Sub-Op | Description | Flags Affected |
|:---|:---:|:---:|:---|:---:|
| `MOV R1, R2`  | `0001` | `0000` | R1 = R2 | None |
| `MOVI R1, imm`| `0001` | `0001` | R1 = imm | None |
| `LDR R1, [R2]`| `0101` | `0001` | R1 = Memory[R2] | None |
| `STR [R1], R2`| `0110` | `0001` | Memory[R1] = R2 | None |
| `STRI [R1], im`| `0110` | `0010` | Memory[R1] = imm | None |

### Compare & Branch Instructions
| Mnemonic | Opcode | Sub-Op | Description | Flags Affected |
|:---|:---:|:---:|:---|:---:|
| `CMP R1, R2`  | `0010` | `1110` | Unsigned compare | Z, N, V, GT, LT, EQ |
| `CMPS R1, R2` | `0010` | `1111` | Signed compare | Z, N, V, GT, LT, EQ |
| `JMP offset`  | `0010` | `0000` | Unconditional jump | None |
| `BZ offset`   | `0010` | `0001` | Branch if Zero (Z=1) | None |
| `BNZ offset`  | `0010` | `0010` | Branch if Not Zero (Z=0) | None |
| `BCS offset`  | `0010` | `0011` | Branch if Carry Set (C=1) | None |
| `BCC offset`  | `0010` | `0100` | Branch if Carry Clear (C=0) | None |
| `BVS offset`  | `0010` | `0101` | Branch if Overflow (V=1) | None |
| `BVC offset`  | `0010` | `0110` | Branch if No Overflow (V=0) | None |
| `BEQ offset`  | `0010` | `1000` | Branch if Equal (EQ=1) | None |
| `BNE offset`  | `0010` | `1001` | Branch if Not Equal (EQ=0) | None |
| `BGT offset`  | `0010` | `1010` | Branch if Greater Than (GT=1) | None |
| `BLT offset`  | `0010` | `1011` | Branch if Less Than (LT=1) | None |
| `BGE offset`  | `0010` | `1100` | Branch if Greater or Equal | None |
| `BLE offset`  | `0010` | `1101` | Branch if Less or Equal | None |

### System Instructions
| Mnemonic | Opcode | Sub-Op | Description | Flags Affected |
|:---|:---:|:---:|:---|:---:|
| `RESET`       | `0000` | `0000` | Resets Program Counter | None |
| `HALT`        | `1111` | `0000` | Halts CPU execution | None |
