; RUN: llc -filetype=obj -o %t.o %s
; RUN: llc -filetype=obj %p/Inputs/explicit-section.ll -o %t2.o
; RUN: wasm-ld --export=get_start --export=get_end --export=foo --export=var1 %t.o %t2.o -o %t.wasm
; RUN: obj2yaml %t.wasm | FileCheck %s
; RUN: llvm-objdump -d --no-show-raw-insn %t.wasm | FileCheck %s --check-prefix=ASM

target triple = "wasm32-unknown-unknown"

@foo = global i32 3, section "mysection", align 4
@bar = global i32 4, section "mysection", align 4

@__start_mysection = external global ptr
@__stop_mysection = external global ptr

define ptr @get_start() {
  ret ptr @__start_mysection
}

define ptr @get_end() {
  ret ptr @__stop_mysection
}

define void @_start()  {
entry:
  ret void
}

;      CHECK:   - Type:            DATA
; CHECK-NEXT:     Segments:
; CHECK-NEXT:       - SectionOffset:   7
; CHECK-NEXT:         InitFlags:       0
; CHECK-NEXT:         Offset:
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           1024
; CHECK-NEXT:         Content:         03000000040000002A0000002B000000

;       ASM: 0000006e <get_start>:
; ASM-EMPTY:
;  ASM-NEXT:        70:     i32.const 1024
;  ASM-NEXT:        76:     end

;       ASM: 00000077 <get_end>:
; ASM-EMPTY:
;  ASM-NEXT:        79:     i32.const 1040
;  ASM-NEXT:       7f:     end
