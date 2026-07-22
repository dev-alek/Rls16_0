/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы со штрих кодами

Автор: Перваков Михаил Сергеевич
Дата создания: 10/26/04
Author: Mikhail Pervakov
Creation date: 10/26/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable ean13_bits_a as character no-undo extent 10
  initial
  ["0001101"
  ,"0011001"
  ,"0010011"
  ,"0111101"
  ,"0100011"
  ,"0110001"
  ,"0101111"
  ,"0111011"
  ,"0110111"
  ,"0001011"
  ].

define variable ean13_bits_b as character no-undo extent 10
  initial
  ["0100111"
  ,"0110011"
  ,"0011011"
  ,"0100001"
  ,"0011101"
  ,"0111001"
  ,"0000101"
  ,"0010001"
  ,"0001001"
  ,"0010111"
  ].

define variable ean13_bits_c as character no-undo extent 10
  initial
  ["1110010"
  ,"1100110"
  ,"1101100"
  ,"1000010"
  ,"1011100"
  ,"1001110"
  ,"1010000"
  ,"1000100"
  ,"1001000"
  ,"1110100"
  ].

define variable ean13_parity as character no-undo extent 10
  initial
  ["AAAAAACCCCCC"
  ,"AABABBCCCCCC"
  ,"AABBABCCCCCC"
  ,"AABBBACCCCCC"
  ,"ABAABBCCCCCC"
  ,"ABBAABCCCCCC"
  ,"ABBBAACCCCCC"
  ,"ABABABCCCCCC"
  ,"ABABBACCCCCC"
  ,"ABBABACCCCCC"
  ] .


define variable bc_3of9_alphabet as character no-undo
  initial "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ-. *$/+%" .

define variable bc_3of9_checkbet as character no-undo
  initial "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%"  .

/* The first 40 symbols repeat this bar pattern */
define variable bc_3of9_bits     as character no-undo extent 44
  initial
  ["111010001010111"
  ,"101110001010111"
  ,"111011100010101"
  ,"101000111010111"
  ,"111010001110101"
  ,"101110001110101"
  ,"101000101110111"
  ,"111010001011101"
  ,"101110001011101"
  ,"101000111011101"
  ,"111010100010111"
  ,"101110100010111"
  ,"111011101000101"
  ,"101011100010111"
  ,"111010111000101"
  ,"101110111000101"
  ,"101010001110111"
  ,"111010100011101"
  ,"101110100011101"
  ,"101011100011101"
  ,"111010101000111"
  ,"101110101000111"
  ,"111011101010001"
  ,"101011101000111"
  ,"111010111010001"
  ,"101110111010001"
  ,"101010111000111"
  ,"111010101110001"
  ,"101110101110001"
  ,"101011101110001"
  ,"111000101010111"
  ,"100011101010111"
  ,"111000111010101"
  ,"100010111010111"
  ,"111000101110101"
  ,"100011101110101"
  ,"100010101110111"
  ,"111000101011101"
  ,"100011101011101"
  ,"100010111011101"
  ,"100010001000101"
  ,"100010001010001"
  ,"100010100010001"
  ,"101000100010001"
  ] .

/* a light margin */
/* a start character A, B or C */
/* a FNC 1 character */
/* Data (Application Identifier + data field) */
/* a symbol check character */
/* a stop character */
/* a light margin*/

define variable ean128_bits  as character no-undo extent 107
  initial
  ["11011001100"
  ,"11001101100"
  ,"11001100110"
  ,"10010011000"
  ,"10010001100"
  ,"10001001100"
  ,"10011001000"
  ,"10011000100"
  ,"10001100100"
  ,"11001001000"
  ,"11001000100"
  ,"11000100100"
  ,"10110011100"
  ,"10011011100"
  ,"10011001110"
  ,"10111001100"
  ,"10011101100"
  ,"10011100110"
  ,"11001110010"
  ,"11001011100"
  ,"11001001110"
  ,"11011100100"
  ,"11001110100"
  ,"11101101110"
  ,"11101001100"
  ,"11100101100"
  ,"11100100110"
  ,"11101100100"
  ,"11100110100"
  ,"11100110010"
  ,"11011011000"
  ,"11011000110"
  ,"11000110110"
  ,"10100011000"
  ,"10001011000"
  ,"10001000110"
  ,"10110001000"
  ,"10001101000"
  ,"10001100010"
  ,"11010001000"
  ,"11000101000"
  ,"11000100010"
  ,"10110111000"
  ,"10110001110"
  ,"10001101110"
  ,"10111011000"
  ,"10111000110"
  ,"10001110110"
  ,"11101110110"
  ,"11010001110"
  ,"11000101110"
  ,"11011101000"
  ,"11011100010"
  ,"11011101110"
  ,"11101011000"
  ,"11101000110"
  ,"11100010110"
  ,"11101101000"
  ,"11101100010"
  ,"11100011010"
  ,"11101111010"
  ,"11001000010"
  ,"11110001010"
  ,"10100110000"
  ,"10100001100"
  ,"10010110000"
  ,"10010000110"
  ,"10000101100"
  ,"10000100110"
  ,"10110010000"
  ,"10110000100"
  ,"10011010000"
  ,"10011000010"
  ,"10000110100"
  ,"10000110010"
  ,"11000010010"
  ,"11001010000"
  ,"11110111010"
  ,"11000010100"
  ,"10001111010"
  ,"10100111100"
  ,"10010111100"
  ,"10010011110"
  ,"10111100100"
  ,"10011110100"
  ,"10011110010"
  ,"11110100100"
  ,"11110010100"
  ,"11110010010"
  ,"11011011110"
  ,"11011110110"
  ,"11110110110"
  ,"10101111000"
  ,"10100011110"
  ,"10001011110"
  ,"10111101000"
  ,"10111100010"
  ,"11110101000"
  ,"11110100010"
  ,"10111011110"
  ,"10111101110"
  ,"11101011110"
  ,"11110101110"
  ,"11010000100"
  ,"11010010000"
  ,"11010011100"
  ,"1100011101011"
  ] .

&scoped-define ean128_start_a 103
&scoped-define ean128_start_b 104
&scoped-define ean128_start_c 105
&scoped-define ean128_stop    106
&scoped-define ean128_shift    98
&scoped-define ean128_code_a  101
&scoped-define ean128_code_b  100
&scoped-define ean128_code_c   99
&scoped-define ean128_func_1  102
&scoped-define ean128_func_2   97
&scoped-define ean128_func_3   96

/*/* FUNC_4 is CODE_A when in A and CODE_B when in B */    */
/*#define NEED_CODE_A(c) ((c)<32 || (c)==0x80)             */
/*#define NEED_CODE_B(c) ((c)>=96 && (c)<128)              */
/*/* code is either 'A' or 'B', and value must be valid */ */
/*static int Barcode_encode_as(int code, int value)        */
/*{                                                        */
/*  /* first check the special chars */                    */
/*  if (value == 0xC1) return FUNC_1;                      */
/*  if (value == 0xC2) return FUNC_2;                      */
/*  if (value == 0xC3) return FUNC_3;                      */
/*  if (value == 0xC4) { /* F4 */                          */
/*    if (code == 'A') return CODE_A;                      */
/*    return CODE_B;                                       */
/*  }                                                      */
/*  /* then check ascii values */                          */
/*  if (value >= 0x20 && value <= 0x5F)                    */
/*    return value - 0x20; /* both codes */                */
/*  if (value == 0x80) return 64; /* code A */             */
/*  if (value < 0x20) return value+64; /* code A */        */
/*  if (value >= 0x60) return value - 0x20; /* code B */   */
/*                                                         */
/*  return -1;                                             */
/*}                                                        */



procedure bar-code_get-bits :

  define input  parameter p-digit   as integer   no-undo .
  define input  parameter p-pattern as character no-undo .
  define output parameter p-bits    as character no-undo .

  do
  on error undo, return error return-value
  :

    if p-digit < 0
    or p-digit > 9
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение параметра p-pattern" skip
        "p-pattern" p-pattern skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    case p-pattern
    :
      when "A":u
      then do:
        assign
          p-bits = ean13_bits_a[p-digit + 1]
        .
      end.
      when "B":u
      then do:
        assign
          p-bits = ean13_bits_b[p-digit + 1]
        .
      end.
      when "C":u
      then do:
        assign
          p-bits = ean13_bits_c[p-digit + 1]
        .
      end.
      otherwise
      do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение параметра p-pattern" skip
          "p-pattern" p-pattern skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
  end.

end procedure. /* bar-code_get-bits */

procedure bar-code_ean8 :

  define input  parameter p-bar-code   as character no-undo .
  define output parameter p-bit-string as character no-undo .

  do
  on error undo, return error return-value
  :

    define variable v-bit-string as character no-undo .
    define variable v-ind        as integer   no-undo .
    define variable v-bits       as character no-undo .

    assign
      v-bit-string = "101"
    .

    do v-ind = 1 to 4
    :
      run bar-code_get-bits in this-procedure
        (input  integer(substring(p-bar-code, v-ind, 1))
        ,input  "A"
        ,output v-bits
        ) .
      assign
        v-bit-string = v-bit-string + v-bits
      .
    end.

    assign
      v-bit-string = v-bit-string + "01010"
    .

    do v-ind = 5 to 8
    :
      run bar-code_get-bits in this-procedure
        (input  integer(substring(p-bar-code, v-ind, 1))
        ,input  "C"
        ,output v-bits
        ) .
      assign
        v-bit-string = v-bit-string + v-bits
      .
    end.

    assign
      v-bit-string = v-bit-string + "101"
    .

    assign
      p-bit-string = v-bit-string
    .
  end.

end procedure. /* bar-code_ean13 */


procedure bar-code_ean13 :

  define input  parameter p-bar-code   as character no-undo .
  define output parameter p-bit-string as character no-undo .

  do
  on error undo, return error return-value
  :

    define variable v-bit-string as character no-undo .
    define variable v-ind        as integer   no-undo .
    define variable v-pattern    as character no-undo .
    define variable v-bits       as character no-undo .

    assign
      v-pattern = ean13_parity[integer(substring(p-bar-code, 1, 1)) + 1]
    .

    assign
      v-bit-string = "101"
    .

    do v-ind = 1 to 6
    :
      run bar-code_get-bits in this-procedure
        (input  integer(substring(p-bar-code, v-ind + 1, 1))
        ,input  substring(v-pattern,  v-ind, 1)
        ,output v-bits
        ) .
      assign
        v-bit-string = v-bit-string + v-bits
      .
    end.

    assign
      v-bit-string = v-bit-string + "01010"
    .

    do v-ind = 7 to 12
    :
      run bar-code_get-bits in this-procedure
        (input  integer(substring(p-bar-code, v-ind + 1, 1))
        ,input  substring(v-pattern,  v-ind, 1)
        ,output v-bits
        ) .
      assign
        v-bit-string = v-bit-string + v-bits
      .
    end.

    assign
      v-bit-string = v-bit-string + "101"
    .

    assign
      p-bit-string = v-bit-string
    .
  end.

end procedure. /* bar-code_ean13 */


procedure bar-code_ean128 :

  define input  parameter p-bar-code   as character no-undo .
  define output parameter p-bit-string as character no-undo .

  define variable v-bit-string      as character no-undo .
  define variable v-bit-index       as integer   no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-length-bar-code as integer   no-undo .
  define variable v-ascii-code      as integer   no-undo .
  define variable v-bar-code        as integer   no-undo .
  define variable v-check-sum       as integer   no-undo .
  define variable v-current-mode    as integer   no-undo .

  do
  on error undo, return error return-value
  :

    if p-bar-code = '':u
    or p-bar-code = ?
    then do:
      assign
        p-bit-string = '':u
      .
      return . /* --->>>--- */
    end.

    assign
      v-ascii-code = asc(substring(p-bar-code, 1, 1))
    .
    assign
      v-current-mode = {&ean128_code_a}
    .
/*    if v-ascii-code < 32*/
/*    or v-ascii-code = 128*/
/*    then do:*/
/*      assign*/
/*        v-current-mode = {&ean128_code_a}*/
/*      .*/
/*    end.*/
    if  v-ascii-code >= 96
    and v-ascii-code < 128
    then do:
      assign
        v-current-mode = {&ean128_code_b}
      .
    end.
    if  v-ascii-code >= 48
    and v-ascii-code <= 57
    and asc(substring(p-bar-code, 2, 1)) >= 48
    and asc(substring(p-bar-code, 2, 1)) <= 57
    then do:
      assign
        v-current-mode = {&ean128_code_c}
      .
    end.

    case v-current-mode
    :
      when {&ean128_code_a}
      then do:
        assign
          v-bit-string = ean128_bits[{&ean128_start_a} + 1]
          v-bit-index  = 0
          v-check-sum  = {&ean128_start_a}
        .
      end.
      when {&ean128_code_b}
      then do:
        assign
          v-bit-string = ean128_bits[{&ean128_start_b} + 1]
          v-bit-index  = 0
          v-check-sum  = {&ean128_start_b}
        .
      end.
      when {&ean128_code_c}
      then do:
        assign
          v-bit-string = ean128_bits[{&ean128_start_c} + 1]
          v-bit-index  = 0
          v-check-sum  = {&ean128_start_c}
        .
      end.
    end.

    assign
      v-length-bar-code = length(p-bar-code)
    .

    assign
      v-ind = 1
    .

    do while v-ind <= v-length-bar-code
    :
      assign
        v-ascii-code = asc(substring(p-bar-code, v-ind, 1))
      .

      if (v-ascii-code < 32
          or v-ascii-code = 128
        )
      and v-current-mode <> {&ean128_code_a}
      then do:
        assign
          v-current-mode = {&ean128_code_a}
        .
        assign
          v-bit-string = v-bit-string
                      + ean128_bits[{&ean128_code_a} + 1]
          v-bit-index  = v-bit-index + 1
          v-check-sum  = v-check-sum
                      + {&ean128_code_a} * v-bit-index
        .
      end.
      if  v-ascii-code >= 96
      and v-ascii-code < 128
      and v-current-mode <> {&ean128_code_b}
      then do:
        assign
          v-current-mode = {&ean128_code_b}
        .
        assign
          v-bit-string = v-bit-string
                       + ean128_bits[{&ean128_code_b} + 1]
          v-bit-index  = v-bit-index + 1
          v-check-sum  = v-check-sum
                       + {&ean128_code_b} * v-bit-index
        .
      end.

      if  v-current-mode = {&ean128_code_c}
      and not(v-ascii-code >= 48
              and v-ascii-code <= 57
              and v-ind < v-length-bar-code
              and asc(substring(p-bar-code, v-ind + 1, 1)) >= 48
              and asc(substring(p-bar-code, v-ind + 1, 1)) <= 57
          )
      then do:
        if  v-ascii-code >= 96
        and v-ascii-code < 128
        then do:
          assign
            v-current-mode = {&ean128_code_b}
          .
          assign
            v-bit-string = v-bit-string
                         + ean128_bits[{&ean128_code_b} + 1]
            v-bit-index  = v-bit-index + 1
            v-check-sum  = v-check-sum
                         + {&ean128_code_b} * v-bit-index
          .
        end.
        else do:
          assign
            v-current-mode = {&ean128_code_a}
          .
          assign
            v-bit-string = v-bit-string
                         + ean128_bits[{&ean128_code_a} + 1]
            v-bit-index  = v-bit-index + 1
            v-check-sum  = v-check-sum
                         + {&ean128_code_a} * v-bit-index
          .
        end.
      end.
      if  v-ascii-code >= 48
      and v-ascii-code <= 57
      and v-ind < v-length-bar-code
      and asc(substring(p-bar-code, v-ind + 1, 1)) >= 48
      and asc(substring(p-bar-code, v-ind + 1, 1)) <= 57
      and v-current-mode <> {&ean128_code_c}
      then do:
        assign
          v-current-mode = {&ean128_code_c}
        .
        assign
          v-bit-string = v-bit-string
                       + ean128_bits[{&ean128_code_c} + 1]
          v-bit-index  = v-bit-index + 1
          v-check-sum  = v-check-sum
                       + {&ean128_code_c} * v-bit-index
        .
      end.


      case v-current-mode
      :
        when {&ean128_code_a}
        then do:
          if  v-ascii-code = 193
          then do:
            assign
              v-bar-code = {&ean128_func_1}
            .
          end.
          if  v-ascii-code = 194
          then do:
            assign
              v-bar-code = {&ean128_func_2}
            .
          end.
          if  v-ascii-code = 195
          then do:
            assign
              v-bar-code = {&ean128_func_3}
            .
          end.
          if  v-ascii-code = 196
          then do:
            assign
              v-bar-code = {&ean128_code_a}
            .
          end.
          if  v-ascii-code >= 32
          and v-ascii-code <= 95
          then do:
            assign
              v-bar-code = v-ascii-code - 32
            .
          end.
          if v-ascii-code = 128
          then do:
            assign
              v-bar-code = 64
            .
          end.
          if v-ascii-code < 32
          then do:
            assign
              v-bar-code = v-ascii-code + 64
            .
          end.

          assign
            v-ind = v-ind + 1
          .
        end.
        when {&ean128_code_b}
        then do:
          if  v-ascii-code = 193
          then do:
            assign
              v-bar-code = {&ean128_func_1}
            .
          end.
          if  v-ascii-code = 194
          then do:
            assign
              v-bar-code = {&ean128_func_2}
            .
          end.
          if  v-ascii-code = 195
          then do:
            assign
              v-bar-code = {&ean128_func_3}
            .
          end.
          if  v-ascii-code = 196
          then do:
            assign
              v-bar-code = {&ean128_code_b}
            .
          end.
          if  v-ascii-code >= 32
          then do:
            assign
              v-bar-code = v-ascii-code - 32
            .
          end.

          assign
            v-ind = v-ind + 1
          .
        end.
        when {&ean128_code_c}
        then do:
          assign
            v-bar-code = (v-ascii-code - 48) * 10
                       + asc(substring(p-bar-code, v-ind + 1, 1)) - 48
          .

          assign
            v-ind = v-ind + 2
          .
        end.
      end.

      assign
        v-bit-string = v-bit-string
                     + ean128_bits[v-bar-code + 1]
        v-bit-index  = v-bit-index + 1
        v-check-sum  = v-check-sum
                     + v-bar-code * v-bit-index
      .
    end.

    assign
      v-check-sum = v-check-sum modulo 103 + 1
    .

    assign
      v-bit-string = v-bit-string
                   + ean128_bits[v-check-sum]
                   + ean128_bits[{&ean128_stop} + 1]
    .

    assign
      p-bit-string = v-bit-string
    .
  end.

end procedure. /* bar-code_ean128 */


procedure bar-code_3of9 :

  define input  parameter p-bar-code   as character no-undo .
  define output parameter p-bit-string as character no-undo .

  define variable v-length         as integer   no-undo .
  define variable v-ind            as integer   no-undo .
  define variable v-alphabet-index as integer   no-undo .
  define variable v-bit-string     as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-length     = length(p-bar-code)
      v-bit-string = '':u
    .

    do v-ind = 1 to v-length
    :
      assign
        v-alphabet-index = index(bc_3of9_alphabet, substring(p-bar-code,v-ind, 1))
      .

      if v-alphabet-index = 0
      then do:
        undo, return error substitute("Неизвестный символ &1"
                                     ,substring(p-bar-code,v-ind, 1)
                                     ) .
      end.

      assign
        v-bit-string = v-bit-string
                     + (if v-bit-string <> '':u then '0':u else '':u)
                     + bc_3of9_bits[v-alphabet-index]
      .
    end.

    assign
      p-bit-string = v-bit-string
    .
  end.

end procedure. /* bar-code_3of9 */


procedure bar-code_bit-string-to-text :

  define input  parameter p-bit-string as character no-undo .
  define output parameter p-text       as character no-undo .

  define variable v-text as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-text = replace(p-bit-string, "1", chr(162))
      v-text = replace(v-text, "0", chr(161))
      p-text = v-text + fill( chr(161), length(v-text) modulo 5)
    .
  end.

end procedure. /* bar-code_bit-string-to-text */

/* $Workfile$ e n d */