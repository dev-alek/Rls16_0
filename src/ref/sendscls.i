/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для работы с весами

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/fileslsh.i }
{ gbl/cur-time.i }

&SCOPED-DEFINE type-only  string(" " + t-scales.scales-type)
&SCOPED-DEFINE num-only   string(" N " + string(t-scales.scales-num))
&SCOPED-DEFINE num-name   string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name)
&SCOPED-DEFINE num-name-type  string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name + " тип " + t-scales.scales-type)

/* Пригодится для определения программы весов т.к. новый exe файл может отсылать, но не удалять */
&SCOPED-DEFINE scale-prog-16 replace(ENTRY(LOOKUP("CAS_LP-15v1.6", ini-types), ini-progs), "\", "/")

/* Так же нужно завести для 5000j если останется старый exe и будет новый */

PROCEDURE SetCurrentDirectoryA EXTERNAL "KERNEL32.DLL":
    DEFINE INPUT PARAMETER chrCurDir AS CHARACTER.
    DEFINE RETURN PARAMETER SetCurrentDirectoryAResult AS LONG.
END PROCEDURE.


FUNCTION get-tara-string RETURNS CHARACTER (buffer loc-scales for ub.scales):
DEFINE VARIABLE var-tara-string as character no-undo .
DEFINE VARIABLE var-param-code as character no-undo .
DEFINE VARIABLE v-value as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
  CASE loc-scales.scales-type:
    when "TIGER":U
    or
    when "MIRA":U
    or
    when "TIGER2"
    or
    when "TIGER-SPCT2"
    or
    when "TIGER-SPCT1"
    then do:
      run scl-attr-value  in this-procedure (
                                              input  loc-scales.db-num
                                              ,input  loc-scales.scales-num
                                              ,input  {&scl-attr-tare-weight}
                                              ,output v-value
                                              ,output par-type) no-error .
      IF not error-status:error then
      assign
      var-tara-string = v-value
      .
    end.
    otherwise do:
      assign
      var-tara-string = "":U
      .
    end.
  END CASE.
return var-tara-string.
END FUNCTION.




FUNCTION get-wt-cart RETURNS CHARACTER (input p-scales-type as character
                                      , INPUT par-wt-cart as decimal
                                      , INPUT par-db-num as integer
                                      , INPUT par-scales-num as integer
                                      , INPUT par-tara-string as character
                                      , INPUT p-dec-delim as character
                                      ):
DEFINE VARIABLE var-wt-cart-str as character no-undo .
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE var-dop-dec as decimal no-undo .
DEFINE VARIABLE ii as integer no-undo .
  CASE par-tara-string:
    when "":U then do:
      case p-scales-type:
        when "TIGER-SPCT2"
        or
        when "TIGER-SPCT1"
        then do:
          return '00':U.
        end.
        when "SHTRIH-M" then do:
          assign
          var-wt-cart-str = string(par-wt-cart , "->>>>9.999")
          .
          if p-dec-delim = {&comma-char} then do:
            var-wt-cart-str = replace(var-wt-cart-str, ".", {&comma-char}).
          end.
        end.
        when "CAS_LP-15v1.6" then do:
            if {&scale-prog-16} = "exe/CAScentre.exe" then
                assign
                var-wt-cart-str = trim(string(par-wt-cart)).
            else 
                assign
                var-wt-cart-str = string(par-wt-cart * 1000, "->>,>>9.999").
        end.
        otherwise do:
          assign
          var-wt-cart-str = string(par-wt-cart * 1000, "->>,>>9.999")
          .
        end.
      end case.
    end.
    otherwise do:
      CASE p-scales-type:
        when "TIGER-SPCT2"
        or
        when "TIGER-SPCT1"
        then do:
          assign
          var-wt-cart-str = string(0, "99")
          .
        end.
        otherwise do:
          assign
          var-wt-cart-str = string(0)
          .
        end.
      end case.
      _ii:
      do ii = 1 to num-entries(par-tara-string, ";":U):
        assign
        var-entry = trim(entry(ii, par-tara-string, ";":U))
        var-dop-dec = decimal(trim(entry(2, var-entry, "=":U)))
        no-error
        .
        if error-status:error then do:
          message
          substitute("Неверное значение атрибута весов <ВЕСА и КОДЫ ТАРЫ>&1" +
                     "для весов &2"
                     ,{&new-line}
                     ,par-scales-num)
          view-as alert-box error .
          NEXT _ii.
        end.
        if var-dop-dec = par-wt-cart then do:
          assign
          var-wt-cart-str = trim(entry(1, var-entry, "=":U))
          .
          LEAVE _ii.
        end.
      end.
    end.
  END CASE.
return var-wt-cart-str.
END FUNCTION.

FUNCTION get-struct returns character (  input p-gds-code as integer
                                        ,input p-plu as integer
                                        ,input p-struct as character
                                        ,input p-scales-type as character
                                        ,input p-db-num as integer
                                        ,input p-scales-num as integer
                                        ):
define variable ii as integer no-undo .
define variable v-rows as integer no-undo .
define variable v-struct as character no-undo .
define variable v-entry as character no-undo .
define variable v-rows-num as integer no-undo .
define variable v-line-length as integer no-undo .
define variable v-format as character no-undo .
define variable v-attr-code as character no-undo .
define variable v-dop as character no-undo .
define variable v-struct1 as character no-undo .

CASE p-scales-type:
  when "CAS_lp-16x" then do:
    assign
    v-struct = " 0    0  " /*номер группы и номер клавиши*/
    v-rows-num = 8
    v-format = "X(50)"
    v-line-length = 50
    v-attr-code = {&attr-8x50}
    .
  end.
  when "CAS_LP-15v1.6_new" then do:
      assign
      v-rows-num = 8
      v-format = "X(50)"
      v-line-length = 50
      v-attr-code = {&attr-8x50}
      .
  end.
  when "DIGI-SM" then do:
    assign
    v-rows-num = 15
    v-format = "X(80)"
    v-line-length = 80
    v-attr-code = {&attr-15x80}
    .
  end.
  when "TIGER-SPCT2"
  or
  when "TIGER-SPCT1"
  then do:
    assign
    v-rows-num = 1
    v-format = "X(199)"
    v-line-length = 199
    v-attr-code = '':U
    .
  end.
  when "CAS_CL5000J"
  or when "CAS_CL5000"
  then do:
    assign
    v-struct = " 0    0  " /*номер группы и номер клавиши*/
    v-rows-num = 6
    v-format = "X(50)"
    v-line-length = 50
    v-attr-code = {&attr-6x50}
    .
  end.
  when "SHTRIH-M" then do:
    assign
    v-struct = "|" /*номер группы и номер клавиши*/
    v-rows-num = 8
    v-format = "X(50)"
    v-line-length = 50
    v-attr-code = {&attr-8x50}
    .
  end.
  
END CASE.
if v-attr-code <> '':U
and p-gds-code > 0
then do:
  run gds-attr-value in this-procedure (
   input  p-gds-code
  ,input  v-attr-code
  ,output v-struct1
  ,output v-dop /*p-type*/
  ) no-error.
  if error-status:error
  or (p-struct <> '':U
  and v-struct1 = '') then do:
     p-struct = replace(p-struct, {&new-line}, {&space-char}).
     do ii = 1 to min(v-rows-num, length(p-struct)  modulo v-line-length):
       assign
       v-struct1 = v-struct1 + (if ii = 1 then '':U else {&delim-par}) + substring(p-struct
                                                                        , (ii - 1) * v-line-length + 1
                                                                        , v-line-length)
                                                                        .
     end.
     p-struct = v-struct1.
  end.
  else do:
    p-struct = v-struct1.
  end.
end.

if num-entries(p-struct, {&delim-par}) > v-rows-num
then v-rows = v-rows-num.
else v-rows = num-entries(p-struct, {&delim-par}) .
CASE p-scales-type:
  when 'DIGI-SM':U then do:
    do ii = 1 to min(v-rows-num, num-entries(p-struct, {&delim-par})):
      assign
      v-entry = replace(entry(ii, p-struct, {&delim-par}), {&double-quote}, {&space-char} )
      v-entry = replace(v-entry, {&single-quote}, {&space-char} )
      .
      assign
      v-struct = v-struct +  (if ii = 1
                              then ({&new-line}  + 'I':U + '000000':U + string(p-plu, '999999999':U))
                              else {&delim-key}) +
                 trim(string(v-entry, v-format))
      .
    end.
    if p-struct <> '':U then do:
      assign
      v-struct = v-struct + {&delim-key}.
    end.
  end.
  when 'CAS_lp-16x':U
  or
  when 'CAS_CL5000J':U
  or
  when 'CAS_CL5000':U
  then do:
    do ii = 1 to min(v-rows-num, num-entries(p-struct, {&delim-par})):
      assign
      v-entry = replace(entry(ii, p-struct, {&delim-par}), {&double-quote}, {&space-char} )
      v-entry = replace(v-entry, {&single-quote}, {&space-char} )
      v-entry = replace(v-entry, {&new-line}, {&space-char} )
      .
      assign
      v-struct = v-struct +  {&space-char} +  {&double-quote} +  string(v-entry, v-format) + "" + {&double-quote}
      .
    end.
    if v-rows < v-rows-num then do:
      do ii = 1  to (v-rows-num - v-rows):
        assign
        v-struct = v-struct + {&space-char} + {&double-quote} + fill( {&space-char} , v-line-length) + {&double-quote}
        .
      end.
    end.
  end.
  when 'TIGER-SPCT2':U
  or
  when 'TIGER-SPCT1':U
  then do:
    if p-struct <> '':U  then do:
      assign
      v-struct =  {&new-line} +
                      '00020900000001' + string(p-scales-num, "99") +
                      /*
                      CMDHEADER
                      U01 -0 передача
                      S05 - код команды - 207
                      S04 - 0000- write
                      S04 - номер отдела 0001
                      U02 - номер весов
                      */
                      string(p-plu, '9999') +
                      string(replace(replace(p-struct, {&delim-par}, {&space-char}), {&new-line}, {&space-char}), "X(200)")
                      .
    end.
  end.
  when 'SHTRIH-M':U
  then do:
    do ii = 1 to min(v-rows-num, num-entries(p-struct, {&delim-par})):
      assign
      v-entry = replace(entry(ii, p-struct, {&delim-par}), {&double-quote}, {&space-char} )
      v-entry = replace(v-entry, {&single-quote}, {&space-char} )
      v-entry = replace(v-entry, {&new-line}, {&space-char} )
      .
      assign
      v-struct = v-struct + string(v-entry, v-format) + "'".
      .
    end.
  end.
  when "CAS_LP-15v1.6_new"
  then do:
    if {&scale-prog-16} = "exe/CAScentre.exe" then do:
        /* Всё в одну строчку. Т.к. это csv то ; заменим */
        do ii = 1 to min(v-rows-num, num-entries(p-struct, {&delim-par})):
          assign
          v-entry = trim(entry(ii, p-struct, {&delim-par}))
          v-entry = replace(v-entry, ";", {&space-char} )
          v-entry = replace(v-entry, {&new-line}, {&space-char} )
          .
          assign
          v-struct = v-struct + (if v-entry <> "" then " " else "") + v-entry.
          .
        end.
    end.
  end.
  otherwise do:
  end.
END CASE.
return v-struct.
END FUNCTION.

FUNCTION main-record-string returns character ( buffer buf_goods for ub.goods
                                               ,input p-mode as character
                                               ,input p-scales-db-num as integer
                                               ,input p-scales-type as character
                                               ,input p-scales-num as integer
                                               ,input p-plu-code  as integer
                                               ,input p-plu-type as integer
                                               ,input p-b-str as character
                                               ,input p-price-sale as decimal
                                               ,input p-deadline as integer
                                               ,input p-deaddate as date
                                               ,input p-deadflag as integer
                                               ,input p-wt-cart as decimal
                                               ,input p-tara-string as character
                                               ,input p-dec-delim as character
                                               ):
define variable v-main-string as character no-undo .
define variable name-buf1 as character no-undo .
define variable name-buf2 as character no-undo .
define variable v-row-length as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-struct as character no-undo.

/* В CAScentre.exe работает только создание, поэтому прийдётся подправить */
if p-scales-type = "CAS_LP-15v1.6"  and {&scale-prog-16} = "exe/CAScentre.exe" and p-mode = {&update} then p-scales-type = "CAS_LP-15v1.6_new".

CASE p-scales-type:
  when 'DIGI-SM' then do:
    if p-mode = {&update} then do:
      run create-name-str in this-procedure ( buffer buf_goods, output name-buf1) .
      assign
      v-main-string = 'A':U +
                      entry(1, (if p-plu-type = integer({&sc-gds-weight})
                                then substring(varscales-pref, 1, 2)
                                else substring(varpgscales-pref, 1, 2))) +
                      string(p-b-str, "x(5)") + '00000':U +
                      '000000':U + string(p-plu-code, '999999999':U) +
                      '0000':U + /*dummy1*/
                      '0000':U + /*dummy2*/
                      (if p-plu-type = integer({&sc-gds-weight})
                      then '0':U
                      else '1':U)  + /*весовой товар или штучный*/
                      '0':U + /*цена идет за единицу измерения весов*/
                        string(p-price-sale, '99999.99') +
                        string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), "999") +
                        '0000':U + /*dummy3*/
                        string(name-buf1, "X(80)").
    end.
    if p-mode = {&deletion}
    or p-mode = "purge"
    or p-mode = "purge-all"
    then do:
      assign
      v-main-string = 'A':U +
                      entry(1, (if p-plu-type = integer({&sc-gds-weight})
                                then substring(varscales-pref, 1, 2)
                                else substring(varpgscales-pref, 1, 2))) +
                      string(p-b-str, "x(5)")  + '00000':U +
                      '000000':U + string(p-plu-code, '999999999':U) +
                      '0000':U + /*dummy1*/
                      '0000':U + /*dummy2*/
                      '0':U + /*весовой товар*/
                      '0':U + /*цена идет за единицу измерения весов*/
                      string(0.01, '99999.99') +
                      string(0, "999") +
                      '0000':U + /*dummy3*/
                      string('':U, "X(80)").

    end.
  end.
  when "TIGER-SPCT2":U
  or
  when "TIGER-SPCT1":U
  then do:
    if p-mode = {&update} then do:
      if p-scales-type = "TIGER-SPCT2" then do:
        run create-name-str-2 in this-procedure ( buffer buf_goods, input 30, output name-buf1, output name-buf2) .
      end.
      else do:
        run create-name-str in this-procedure ( buffer buf_goods, output name-buf1) .
      end.
      assign
      v-main-string = '00020700000001' + string(p-scales-num, "99") +
                      /*
                      CMDHEADER
                      U01 -0 передача
                      S05 - код команды - 207
                      S04 - 0000- write
                      S04 - номер отдела 0001
                      U02 - номер весов
                      */
                      string(p-plu-code, '999999':U) +
                      (if p-plu-type = integer({&sc-gds-weight})
                      then (
                      entry(1, varscales-pref) + '000000':U + string(p-b-str, "x(5)")
                      )
                      else (
                      substring(entry(1, varpgscales-pref), 1, 2) + '000000':U + string(p-b-str, "x(5)")
                      )
                      )
                      +
                      (if p-scales-type = "TIGER-SPCT2"
                      then
                      (string( name-buf1, "x(30)" ) +
                      string( name-buf2, "x(30)" ))
                      else
                      string( name-buf1, "x(28)" )
                      )
                      +
                      {&space-char}  +
                      replace(string(p-price-sale, '999999.99'), ".", "") +
                      '0' + /*taxrate*/
                      replace(get-wt-cart(p-scales-type, p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim), ".", "") +
                      '0000':U + /*dummy1*/
                      '00000000000':U + /*fixweight*/
                      '0000':U + /*groupno*/
                      (if p-plu-type = integer({&sc-gds-weight})
                      then '0020':U
                      else '0021':U)  + /*флаги*/
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), "999") +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), "999") +
                      (if buf_goods.struct <> '':U
                      then string(p-plu-code, '999')
                      else '000':U)
                      .
    end.
    if p-mode = {&deletion} then do:
      assign
      v-main-string = '00020700000001' + string(p-scales-num, "99") +
                      /*
                      CMDHEADER
                      U01 -0 передача
                      S05 - код команды - 207
                      S04 - 0000- write
                      S04 - номер отдела 0001
                      U02 - номер весов
                      */
                      string(p-plu-code, '999999':U) +
                      '0000000000000':U  +
                      (if p-scales-type = "TIGER-SPCT2"
                      then
                      (
                      fill( {&space-char} , 30) +
                      fill( {&space-char} , 30))
                      else
                      fill( {&space-char} , 28))
                      +
                      {&space-char}  +
                      replace(string(0.0, '999999.99'), ".", "") +
                      '0' + /*taxrate*/
                      '00' +
                      '0000':U + /*dummy1*/
                      '00000000000':U + /*fixweight*/
                      '0000':U + /*groupno*/
                      '0020':U + /*флаги*/
                      "000" +
                      "000" +
                      "000"
                      .
    end.
    if p-mode = "purge" then do:
      assign
      v-main-string = "D:":U + string(p-plu-code, ">>>9").
    end.
    if p-mode = "purge-all" then do:
      assign
      v-main-string = "D:A":U
      .
    end.
  end.
  when "SHTRIH-M" then do:
    if p-mode = {&update} then do:
      run create-name-str-2 in this-procedure ( buffer buf_goods, input 56, output name-buf1, output name-buf2) .
      name-buf1 = trim(name-buf1).
      assign
      v-main-string = string(1) + "|" +       /*добавление*/
                      string(p-pLU-code) + "|"  +
                      string(p-b-str, "x(5)") + "|" +
                      string(replace(name-buf1, "|", " "), "x(56)" ) + "|" +
                      /*вторая строка названия зарезерв*/ "" + "|" +    
                      get-wt-cart(p-scales-type, p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim) + "|" +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), ">>>>9") + "|" +
                      (if p-dec-delim = {&comma-char}
                      then replace(string(p-price-sale, ">>>>>>>>9.99"), ".", {&comma-char})
                      else string(p-price-sale, ">>>>>>>>9.99"))
                      .
    end.
    if p-mode = {&deletion}
    or p-mode = "purge"
    or p-mode = "purge-all"
    then do:
      assign
      v-main-string = (if p-mode = "purge-all" then string(2) else string(0)) + "|" +       /*удаление*/
                      string(p-pLU-code) + "|"  +
                      string(p-b-str, "x(5)") + "|" +
                      string(replace(name-buf1, "|", " "), "x(29)" ) + "|" +
                      /*вторая строка названия зарерзви*/ "" + "|" +
                      get-wt-cart(p-scales-type, p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim) + "|" +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), ">>>>9") + "|" +
                      (if p-dec-delim = {&comma-char}
                      then replace(string(p-price-sale, ">>>>>>>>9.99"), ".", {&comma-char})
                      else string(p-price-sale, ">>>>>>>>9.99"))
                      .
    end.
  end.
  when "DIGI_AW-4600_FX":U then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    if not (p-mode = {&deletion}
            or p-mode = "purge"
            or p-mode = "purge-all") then do:
      run create-name-str in this-procedure ( buffer buf_goods, output name-buf1) .
    end.
    assign
    v-main-string = substitute('&1&2&3,,1,&4,&5,&6&7000000,&8,'
                               , string(year(v-today), "9999")
                               , string(month(v-today), "99")
                               , string(day(v-today), "99")
                               , p-plu-code
                               , (if p-mode = {&deletion}
                                  or p-mode = "purge"
                                  or p-mode = "purge-all"
                                  then 1
                                  else 0) /*для добавления и 1 для удаления*/
                               , 21 /*v-prefix*/
                               , string(p-b-str, "x(5)")
                               , 25 /*формат штрихкода*/
                               ) +
                  substitute('&1,"&2”,0,,0,,0,,0,,0,&3,,'
                             , 19 /*флаг длины названия*/
                             , name-buf1
                             , 0 /*флаг взвешиваемого 0 - весовой*/
                             )
                    +  substitute("&1,0,0,0,0,0,0,,0,0,0,0,1,,1,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,,,,0,0,0,,,,0,,,,0,,,,,,,0,,,,,,,,,,,,,0,,,0,0,0,,,0,0,0,,0,,,,,,,,,0,0,,,,,,,,0,0,0,0,0,0,,,,,,,,,,0,0,0,0,,,,0,0,,,,,,,,,,,,,,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
                                                  ,trim(string(p-price-sale * 100, ">>>>>9"), {&space-char})
                              )
                 .
  end.
  when "CAS_LP-15v1.6_new" then do: /* Для 5000j будет такой же способ (порядок полей) */
      run create-name-str-2 in this-procedure ( buffer buf_goods, input 28, output name-buf1, output name-buf2).
      v-struct = trim(get-struct(input buf_goods.gds-code, p-plu-code, buf_goods.struct, p-scales-type, p-scales-db-num, p-scales-num)).
      /* Состав получим в этой же строке а не в &ingridients как у других */
      v-main-string = substitute("1;&1;1;&2;&3;;0;&8;0;&4;&5;0;0;&6;0;&1;&7;0;0;0;0;0;0;0;0;0;0;",
                                 p-plu-code, trim(name-buf1), trim(name-buf2), trim(string(p-price-sale * 100, ">>>>>>>>9")),
                                 trim(get-wt-cart("CAS_LP-15v1.6", p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim)),
                                 trim(string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), ">>>>9") ),
                                 v-struct,
								 p-b-str
                                ).
  end.
  otherwise do:
    case p-scales-type:
      when 'CAS_CL5000J'
      or
      when 'CAS_CL5000'
      then do:
        v-row-length = 0.
      end.
      otherwise do:
        v-row-length = 26.
      end.
    end case.
    if p-mode = {&update} then do:
      run create-name-str-2 in this-procedure ( buffer buf_goods, input (v-row-length - 1), output name-buf1, output name-buf2) .
      assign
      v-main-string = string(p-pLU-code, ">>>9") + {&space-char}  +
                      (if p-scales-type = 'CAS_CL5000J' or p-scales-type = 'CAS_CL5000'
                      then  (string((if p-plu-type = integer({&sc-gds-weight}) then "01" else "02"), "x(2)") + {&space-char} )
                      else '')  +
                      string(p-b-str, "x(5)") + {&space-char} +
                      string( "~"" + string( name-buf1 ) + "~"", substitute("x(&1)", length(name-buf1) + 2)) + {&space-char} +
                      string( "~"" + string( name-buf2 ) + "~"", substitute("x(&1)", length(name-buf2) + 2)) + {&space-char} +
                      string(p-price-sale * 100, ">>>>>>>>9") + {&space-char} +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), ">>>>9") + {&space-char} +
                      get-wt-cart(p-scales-type, p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim).
    end.
    if p-mode = {&deletion}
    or p-mode = "purge"
    or p-mode = "purge-all"
    then do:
      assign
      v-main-string = string(p-plu-code, ">>>9") + {&space-char} +
                      (if p-scales-type = 'CAS_CL5000J' or p-scales-type = 'CAS_CL5000'
                      then (string("00", "x(2)") + {&space-char})
                      else '') +
                      string(0, "99999") + {&space-char} +
                      string( {&double-quote} + fill({&space-char}, v-row-length) + {&double-quote}, substitute("x(&1)", v-row-length + 2)) + {&space-char} +
                      string( {&double-quote} + fill({&space-char}, v-row-length) + {&double-quote}, substitute("x(&1)", v-row-length + 2)) + {&space-char} +
                      string(0, ">>>>>>>>9") + {&space-char} +
                      string(0, ">>>>9") + {&space-char} +
                      string(0,">>>9").
    end.
  end.
END CASE.
return v-main-string.
END FUNCTION.


PROCEDURE general-send:
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE PARAMETER BUFFER t-scales for ub.scales.
DEFINE INPUT PARAMETER SendOption as Char NO-UNDO.
define input parameter send-rid-list as character no-undo .
DEFINE INPUT PARAMETER ObjectOption as CHar NO-UNDO.

define variable name-buf1 as char no-undo .
define variable name-buf2 as char no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE var-tara-string as character no-undo .
define variable g#report-num as integer no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable rep-rec as recid no-undo .
define variable res as integer no-undo.
define variable err-scl-num-list as character no-undo .
define variable err-codes-list as character no-undo .
define variable i-section as integer no-undo .
define variable i-key as integer no-undo .
define variable v-sections as character no-undo .
define variable v-section as character no-undo .
define variable v-keys as character no-undo .
define variable v-out-key as character no-undo .
define variable v-file-name as character no-undo .
define variable v-file-mask as character no-undo .
define variable v-file-mask-1 as character no-undo .
define variable v-file-mask-2 as character no-undo .
define variable v-out-dir as character no-undo .
define variable v-mode as character no-undo .
define variable v-stream as character no-undo .
define buffer buf_shop for ub.shop.
define buffer b-scales for ub.scales.
define buffer buf_goods for ub.goods.
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_gds-obj-attr for ub.gds-obj-attr .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_gdsolist for gdsolist.

&scop ingridients (if t-scales.scales-type = "CAS_lp-16x"  ~
                   or t-scales.scales-type = "DIGI-SM"   ~
                   or t-scales.scales-type = "TIGER-SPCT2"   ~
                   or t-scales.scales-type = "TIGER-SPCT1"   ~
                   or t-scales.scales-type = "CAS_CL5000j"   ~
                   or t-scales.scales-type = "CAS_CL5000"   ~
                   or t-scales.scales-type = "SHTRIH-M" ~
               then get-struct ( input buf_goods.gds-code       ~
                               , input buf_scales-gds.plu-code   ~
                               , input buf_goods.struct          ~
                               , input t-scales.scales-type ~
                               , input t-scales.db-num ~
                               , input t-scales.scales-num ~
                               )    ~
               else '':U)

&scop ingridients-del (if t-scales.scales-type = "CAS_lp-16x" ~
                       or t-scales.scales-type = "DIGI-SM"   ~
                       or t-scales.scales-type = "TIGER-SPCT2"   ~
                       or t-scales.scales-type = "TIGER-SPCT1"   ~
                       or t-scales.scales-type = "CAS_CL5000j"   ~
                       or t-scales.scales-type = "CAS_CL5000"   ~
               then get-struct( input 0    ~
                              , input 0    ~
                              , input '':U ~
                              , input t-scales.scales-type ~
                              , input t-scales.db-num ~
                              , input t-scales.scales-num ~
                              )    ~
               else '':U)



scale-prog = ?.
&SCOPED-DEFINE status-code STRING(t-scales.sts)
if t-scales.sts = integer({&deleted-status-int}) then do:
  return error substitute("Весы &1 имеют статус &2&3Пересылка запрещена"
                       , t-scales.scales-name
                       , {&status-int-name}
                       , {&new-line}).
end.
assign
scale-prog = ENTRY(LOOKUP(t-scales.scales-type, ini-types), ini-progs) no-error.
if not (t-scales.scales-type = "DIGI-SM"
        or t-scales.scales-type = "TIGER-SPCT2"
        or t-scales.scales-type = "TIGER-SPCT1"
        or t-scales.scales-type = "DIGI_AW-4600_FX"
        )
then do:
  if scale-prog = ? then do:
    SendOption = "".
    return error substitute("Ошибка! Не удалось определить программу для работы с типом весов &1", {&type-only}).
  end.
  scale-prog = SEARCH(scale-prog).
  if scale-prog = ? then do:
    SendOption = "".
    return error substitute("Не найден файл программы работы с весами &1", {&num-name-type}).
  end.
end.
/*если это новые весы типа TIGER то надо найти для них настройку - соответствие кодов тары весу тары*/
assign
var-tara-string = "":U
var-tara-string = get-tara-string(buffer t-scales)
no-error
.

run get-report-num  in parParentProc(output g#report-num).
CASE t-scales.scales-type:
  when 'DIGI-SM' then do:
  v-sections = 'scales'.
  v-keys = 'out,digi-sm-out'.
end.
  when 'TIGER-SPCT2' then do:
    v-sections = 'scales'.
    v-keys = 'out,tiger-spct2-install-dir'.
  end.
  when 'TIGER-SPCT1' then do:
    v-sections = 'scales'.
    v-keys = 'out,tiger-spct1-install-dir'.
  end.
  otherwise do:
    v-sections = 'scales,kassa-ibm'.
    v-keys = 'out'.
  end.
end.
_i-section:
do i-section = 1 to num-entries(v-sections):
  _i-key:
  do i-key = 1 to num-entries(v-keys):
    RUN verify-ini-entry in this-procedure (
                           input entry(i-key, v-keys)
                          ,input entry(i-section, v-sections)
                          ,input  substitute("отсутствует путь к подкаталогу [&1]&2 для отсылки информации на весы&2"
                                          , entry(i-key, v-keys)
                                          , {&new-line}
                                          )
                          ,input yes
                          ,output v-out-dir) no-error.
    if error-status:error or v-out-dir = ? then do:
      if i-section = 1
      and t-scales.scales-type <> 'DIGI-SM'
      and t-scales.scales-type <> 'TIGER-SPCT2'
      and t-scales.scales-type <> 'TIGER-SPCT1'
      then do:
        next _i-key.
      end.
      if (t-scales.scales-type = 'DIGI-SM'
      or t-scales.scales-type = 'TIGER-SPCT2'
      or t-scales.scales-type = 'TIGER-SPCT1'
      )
      or i-section = 2 then do:
        SendOption = "".
        return error return-value .
      end.
    end.
    run gbl/return_.p .
    v-out-dir = prepare-path ( input v-out-dir) + {&slash-char}.
    RUN verify-file( input v-out-dir
                    ,input substitute("Не найден каталог &1 &2 -параметр &3, секция &4 ini-файла"
                                    , v-out-dir
                                    , {&new-line}
                                    , entry(i-key, v-keys)
                                    , v-section)
                    ,input yes
                    ,output glog) no-error.
    if error-status:error or not glog then do:
      SendOption = "".
      return error return-value .
    end.
    run gbl/return_.p .
    if i-section = 1 and i-key = 1
    or not (t-scales.scales-type = 'DIGI-SM'
            or
            t-scales.scales-type = 'TIGER-SPCT2'
            or
            t-scales.scales-type = 'TIGER-SPCT1'
            )
    then do:
      assign
      out-dir = v-out-dir.
      if t-scales.scales-type <> 'DIGI-SM'
      and t-scales.scales-type <> 'TIGER-SPCT2'
      and t-scales.scales-type <> 'TIGER-SPCT1'
      and  out-dir <> '':U then leave _i-section.
    end.
    if t-scales.scales-type = 'DIGI-SM'
    and i-key = 2
    and i-section = 1
    then do:
      assign
      digi-out-dir = v-out-dir.
      leave  _i-section.
    end.
    if t-scales.scales-type = 'TIGER-SPCT2'
    and i-key = 2
    and i-section = 1
    then do:
      assign
      tiger-spct2-out-dir = v-out-dir.
      tiger-spct2-install-dir = v-out-dir.
    end.
    if t-scales.scales-type = 'TIGER-SPCT1'
    and i-key = 2
    and i-section = 1
    then do:
      assign
      tiger-spct1-out-dir = v-out-dir.
      tiger-spct1-install-dir = v-out-dir.
    end.

  end. /*do i-key*/
end.
CASE t-scales.scales-type:
  when 'DIGI-SM' then do:
    RUN verify-ini-entry in this-procedure (
                          input 'digi-sm-file-mask'
                          ,input 'scales'
                          ,input  substitute("отсутствует настройка маски файла для весов типа &1&2"+
                                            "-параметр &3, секция &4 ini-файла,&2по умолчанию подставляем smimp*.dat"
                                          , t-scales.scales-type
                                          , {&new-line}
                                          , 'digi-sm-file-mask'
                                          , 'scales'
                                          )
                          ,input yes
                          ,output v-file-mask) no-error.
    if v-file-mask = '':U
    or v-file-mask = ?
    then do:
      v-file-mask = 'smimp*.dat':U.
    end.
    assign
    v-file-mask-1 = (if index({&question-mark}, v-file-mask) > index('*':U, v-file-mask)
                    or index({&question-mark}, v-file-mask) = 0
                  then entry(1, v-file-mask, '*')
                  else entry(1, v-file-mask, {&question-mark})
                    )
    v-file-mask-2 = (if index({&question-mark}, v-file-mask) > index('*':U, v-file-mask)
                    or index({&question-mark}, v-file-mask) = 0
                      then (if num-entries(v-file-mask, '*') > 1
                            then entry(2, v-file-mask, '*')
                            else '':U)
                      else  (if num-entries(v-file-mask, {&question-mark}) > 1
                              then entry(2, v-file-mask, {&question-mark})
                              else '':U)
                      )
    .
    assign
    v-file-name = v-file-mask-1 + entry(4, t-scales.address, '.') + v-file-mask-2
    .
  end.
  when 'TIGER-SPCT2':U
  or
  when 'TIGER-SPCT1':U
  then do:
    RUN verify-ini-entry in this-procedure (
                           input (if t-scales.scales-type = "TIGER-SPCT2"
                                  then 'tiger-spct2-file-mask'
                                  else 'tiger-spct1-file-mask')
                          ,input 'scales'
                          ,input  substitute("отсутствует настройка маски файла для весов типа &1&2"+
                                            "-параметр &3, секция &4 ini-файла,&2по умолчанию подставляем trf*.out"
                                          , t-scales.scales-type
                                          , {&new-line}
                                          , (if t-scales.scales-type = "TIGER-SPCT2"
                                             then 'tiger-spct2-file-mask'
                                             else 'tiger-spct1-file-mask')
                                          , 'scales'
                                          )
                          ,input yes
                          ,output v-file-mask) no-error.
    if v-file-mask = '':U
    or v-file-mask = ?
    then do:
      v-file-mask = 'trf*.out':U.
    end.
    assign
    v-file-mask-1 = (if index({&question-mark}, v-file-mask) > index('*':U, v-file-mask)
                    or index({&question-mark}, v-file-mask) = 0
                  then entry(1, v-file-mask, '*')
                  else entry(1, v-file-mask, {&question-mark})
                    )
    v-file-mask-2 = (if index({&question-mark}, v-file-mask) > index('*':U, v-file-mask)
                    or index({&question-mark}, v-file-mask) = 0
                      then (if num-entries(v-file-mask, '*') > 1
                            then entry(2, v-file-mask, '*')
                            else '':U)
                      else  (if num-entries(v-file-mask, {&question-mark}) > 1
                              then entry(2, v-file-mask, {&question-mark})
                              else '':U)
                      )
    .
    assign
    v-file-name = v-file-mask-1 + string(t-scales.scales-num) + v-file-mask-2
    .
  end.
  otherwise do:
    assign
    v-file-name = "plu" + string( g#report-num ) + "." + string(t-scales.scales-num, "999").
  end.
  
END CASE.
if t-scales.scales-type = "SHTRIH-M" then do:
  define variable v-dec-delim as character no-undo .
  define variable v-tho-delim as character no-undo .
  define variable v-sdate as character no-undo initial "/":U.
  define variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .

  run gbl/getlocal.p ( output v-dec-delim
                      , output v-tho-delim
                      , output v-sdate
                      , output v-shortdate ) no-error .
end.

if SendOption = "RESEND":U then do:
  if t-scales.scales-type ="DIGI-SM" then do:
    message
    substitute("Опция ПОВТОРНОЙ отправки для данного типа весов реализована внутри сервиса загрузки весов")
    view-as alert-box warning.
    sendoption = ''.
    return.
  end.
  if t-scales.scales-type ="TIGER-SPCT2"
  or t-scales.scales-type ="TIGER-SPCT1"
  then do:
    message
    substitute("Опция ПОВТОРНОЙ отправки для данного типа весов не может быть реализована")
    view-as alert-box warning.
    sendoption = ''.
    return.
  end.
  if t-scales.scales-type = 'DIGI_AW-4600_FX':U then do:
    scale-prog = SEARCH("exe/curl.exe").
    if scale-prog = ? then do:
      message
      substitute("Не найден файл программы работы с весами &1", "exe/curl.exe")
      view-as alert-box error .
      sendoption = ''.
      return.
    end.
  end.
  if search( out-dir + v-file-name  ) = ? then do:
    message
    "В данной сессии работы с БД Вы еще не отсылали товары на весы " skip
    {&num-name} skip
    "ИЛИ файл данных для весов, соответствующий данной сессии уже УДАЛЕН!"
    view-as alert-box ERROR.
    SendOption = "".
    return .
  end.
  run gbl/return_.p .
  RUN b-msend-proc in this-procedure (
                    buffer t-scales
                   ,input scale-prog
                   ,input v-file-name
                   ,input {&update}
                   ,input "ПОВТОРНО отправляются товары на весы "
                   ,output res
                   ,output err-scl-num-list
                   ,output err-codes-list
                   ) no-error.
  if error-status:error or res > 0
  then return error substitute("Ошибка при повторной передаче на весы &1 и/или подчиненные весы&2&3&2&4&2&5"
                                , {&num-name}
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                , (if not error-status:error and res > 0
                                   then substitute("!!!Программа передачи данных на весы &1 вернула ошибку(-и) с кодом(-ми) &2"
                                                   ,err-scl-num-list
                                                   ,err-codes-list
                                                   )
                                   else '':U)
                                ).
END. /*SendOption = "RESEND":U */
ELSE DO:
  if NOT can-find( first buf_scales-gds where
                         buf_scales-gds.db-num = t-scales.db-num
                    AND buf_scales-gds.scales-num = t-scales.scales-num ) then do:
    /*проверим вдруг они сломаны*/
    SendOption = "".
    return error substitute("НЕТ товаров на весах с номером &1", t-scales.scales-num).
  end.

  FOR EACH gds-list :
    delete gds-list .
  END .

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Пересылка на весы №&1 &2.....&3Подготовка данных..."
                         , t-scales.scales-num
                         , t-scales.scales-name
                         , {&new-line}
                         )).
  case t-scales.scales-type:
    when "CAS_CL5000J"
    or
    when "CAS_CL5000"
    then do:
      v-stream = "WINDOWS-1251".
    end.
    when "CAS_LP-15v1.6" then do:
         if {&scale-prog-16} = "exe/CAScentre.exe" and /* только апдэйты */
         (SendOption = "changed"
         or SendOption = "ALL"
         or SendOption = "CURRENT"
         or SendOption = "SELECTIVE")
         then do:
          v-stream = "WINDOWS-1251".
        end.
    end.
    otherwise do:
    end.
  end case.

  _zz:
  DO
  ON STOP UNDO, return error
  ON END-KEY UNDO, return error
  ON ERROR UNDO, LEAVE:
    CASE SendOption :
      when "changed":U then do:
        assign
        jj = 0
        v-mode = {&update}
        .
        CASE ObjectOption:
          WHEN {&current} then do:
            obj-list = yes.
          end.
          when {&all} then do:
            obj-list = no.
          end.
        END CASE.
        case v-stream:
          when "WINdows-1251" then do:
            if t-scales.scales-type = "CAS_LP-15v1.6" then do:
                /* Для CSV всегда нужна эта шапка. Для нового 5000j - тоже, поэтому их сюда добавить. */
                output to value( out-dir + v-file-name ). 
                put "номер отдела;номер товара;тип товара;первая строка названия товара;вторая строка названия товара;строка, которая печатается под логотипом;групповой код;код товара;фиксированная цена товара, в копейках;цена товара, в копейках;вес тары, в граммах;дата упаковки, в днях;время упаковки, в часах;срок годности, в днях;срок годности, в часах;номер состава продукта прикрепленного к товару;текст состава продукта;номер этикетки для печати;номер штрих-кода для печати;дата создания продукта, в днях;номер текста рекламного сообщения;номер логотипа для печати на этикетки;номер единицы измерения количественного товара;кол-во для штучных и счетных товаров;номер страны-производителя;номер второго штриховой код для печати на этикетки;фиксированный вес продукта;"
                    skip. 
                output close.
                output stream PrnLibStream to value( out-dir + v-file-name ) append.
            end.
            else do:
                output stream PrnLibStream to value( out-dir + v-file-name ).
            end.
          end.
          otherwise do:
            output stream PrnLibStream to value( out-dir + v-file-name )
            convert target "ibm866".
          end.
        end case.
        FOR EACH buf_scales-gds WHERE
        buf_scales-gds.db-num = t-scales.db-num AND
        buf_scales-gds.scales-num = t-scales.scales-num AND
        buf_scales-gds.to-send = TRUE AND
        (obj-list = no
                or (buf_scales-gds.obj-type  = p-obj-type
                   AND
                   buf_scales-gds.obj-code  = p-obj-code)),
          FIRST buf_bar-code WHERE
                buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
          FIRST buf_goods WHERE
                buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
          FIRST buf_gds-obj-attr WHERE
                buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
                buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                No-LOCK,
          FIRST buf_prod-bc WHERE
                buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK
          on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo, return error substitute( "&1. stop", vss-workfile )
          on endkey undo, return error substitute( "&1. endkey", vss-workfile )
          :
         jj = jj + 1.
          if ( jj modulo 10 = 0 ) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , jj
                                                            , t-scales.scales-num)).
          end.
          if buf_scales-gds.to-del = yes then NEXT.
          { str/get-pr.i calc buf_scales-gds.obj-type buf_scales-gds.obj-code buf_goods.gds-code ? "return error." }
          if gp-price-sale = ? then do:
            next .
          end.
          define variable l-in-ov as logical no-undo .
          { gbl/gdsobjat.i
            buf_scales-gds.obj-type
            buf_scales-gds.obj-code
            buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            '"in-ov=request"'
            l-in-ov
            no-error
            }
          if error-status:error then do:
            SendOption = "".
            undo, return error substitute("&1 &2 &3&4Ошибка получения признака товара на объекте&4код товара &5&4&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        , {&new-line}
                                        ,buf_goods.gds-code
                                        , error-status:get-message(1)
                                        , return-value ).
          end.
          find first buf_shop no-lock where
                    buf_shop.obj-code = buf_scales-gds.obj-code.
          if buf_shop.in-ov and l-in-ov then do:
           next .
          end.
          PUT stream PrnLibStream unformatted
          main-record-string  ( buffer buf_goods
                              ,input {&update}
                              ,input t-scales.db-num
                              ,input t-scales.scales-type
                              ,input buf_scales-gds.scales-num
                              ,input buf_scales-gds.plu-code
                              ,input buf_scales-gds.plu-type
                              ,input buf_prod-bc.b-str
                              ,input gp-price-sale
                              ,input buf_scales-gds.deadline
                              ,input buf_scales-gds.deaddate
                              ,input buf_scales-gds.deadflag
                              ,input buf_scales-gds.wt-cart
                              ,input var-tara-string
                              ,input v-dec-delim
                              )
          {&ingridients}
          skip .
          assign
          buf_scales-gds.to-send = FALSE no-error .
          run create-obj-record in this-procedure (buffer buf_goods
                                                    , buf_scales-gds.obj-type
                                                    , buf_scales-gds.obj-code).
        END.
        /*добавим удаленные*/
        IF can-find(first buf_scales-gds where
                          buf_scales-gds.db-num = t-scales.db-num AND
                          buf_scales-gds.scales-num = t-scales.scales-num AND
                          buf_scales-gds.to-del = yes) then do:
          run add-del-gds in this-procedure (input-output jj
                                            ,input v-dec-delim
                                            ,buffer t-scales) .
        end.
        output stream PrnLibStream close.
        if jj = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Нет измененных товаров на весах &1", {&num-name})
                                                    ).
          SendOption = "".
          return .
        end.
        run check-write-scales-status in this-procedure (input t-scales.scales-num, input t-scales.db-num, input recid(t-scales)).
      end. /*when "changed":U then do:*/
      when "purge-all" then do:
        case v-stream:
          when "WINdows-1251" then do:
            output stream PrnLibStream to value( out-dir + v-file-name ) .

          end.
          otherwise do:
            output stream PrnLibStream to value( out-dir + v-file-name )
            convert target "ibm866".
          end.
        end case.
        assign
        jj = 0
        v-mode = {&deletion}
        .
        case t-scales.scales-type :
          when "DIGI-SM" then do :
            FOR EACH buf_scales-gds WHERE
                          buf_scales-gds.scales-num = t-scales.scales-num
                      AND buf_scales-gds.db-num = t-scales.db-num
                      EXCLUSIVE-LOCK,
              FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK ,
              FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
              FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK,
              FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK :

              jj = jj + 1.
              if ( jj modulo 10 = 0 ) then do:
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                                , jj
                                                                , t-scales.scales-num)).
              end.

              PUT stream PrnLibStream unformatted
               main-record-string  ( buffer buf_goods
                                ,input "purge-all"
                                ,input t-scales.db-num
                                ,input t-scales.scales-type
                                ,input t-scales.scales-num
                                ,input buf_scales-gds.plu-code /*plu-code*/
                                ,input buf_scales-gds.whole-send-news /*plu-type*/
                                ,input buf_prod-bc.b-str /*b-str*/
                                ,input 0.0 /*p-price-sale*/
                                ,input 0 /*deadline*/
                                ,input ? /*deaddate*/
                                ,input 0 /*deadflag*/
                                ,input 0.0 /*buf_scales-gds.wt-cart*/
                                ,input '':U /*-tara-string*/
                                ,input v-dec-delim
                                )
              {&ingridients-del}
              skip .
              delete buf_scales-gds no-error.
              if error-status:error then do:
                return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
              end.
            END.
          end.
          otherwise do :
        DO jj = 1 TO /* scales.max-plu */  qnty-buf :
          if ( jj modulo 10 = 0 ) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , jj
                                                            , t-scales.scales-num)).
          end.
          /*для TIGER-SPCT2 только один раз достаточно*/
          if ((t-scales.scales-type <> "TIGER-SPCT2"
              and
              t-scales.scales-type <> "TIGER-SPCT1")
          or jj = 1 )
          and t-scales.scales-type <> "CAS_CL5000J"
          and t-scales.scales-type <> "CAS_CL5000"
          /*для CAS_CL5000J просто команда*/
          then do:
                        FOR EACH buf_scales-gds WHERE
                          buf_scales-gds.scales-num = t-scales.scales-num
                      AND buf_scales-gds.db-num = t-scales.db-num
                      EXCLUSIVE-LOCK,
              FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK ,
              FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
              FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK,
              FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK :

              jj = jj + 1.
              if ( jj modulo 10 = 0 ) then do:
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                                , jj
                                                                , t-scales.scales-num)).
              end.
            PUT stream PrnLibStream unformatted
            main-record-string  ( buffer buf_goods
                                ,input "purge-all"
                                ,input t-scales.db-num
                                ,input t-scales.scales-type
                                ,input t-scales.scales-num
                                ,input jj /*plu-code*/
                                ,input ? /*plu-type*/
                                ,input buf_prod-bc.b-str /*b-str*/
                                ,input 0.0 /*p-price-sale*/
                                ,input 0 /*deadline*/
                                ,input ? /*deaddate*/
                                ,input 0 /*deadflag*/
                                ,input 0.0 /*buf_scales-gds.wt-cart*/
                                ,input '':U /*-tara-string*/
                                ,input v-dec-delim
                                )
            {&ingridients-del}
            skip .
          end.
          end.
          FIND FIRST buf_scales-gds WHERE
                      buf_scales-gds.scales-num = t-scales.scales-num
                  AND buf_scales-gds.db-num = t-scales.db-num
                  AND buf_scales-gds.PLU-code = jj EXCLUSIVE NO-ERROR .
          if available buf_scales-gds then do:
            delete buf_scales-gds no-error.
            if error-status:error then do:
              return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
            end.
          end.
        END.
          end.
        end case.
        output stream PrnLibStream close.
      end. /*when purge-all*/
      when "purge-selective" then do:
        gds-amount = num-entries( send-rid-list ) .
        case v-stream:
          when "WINdows-1251" then do:
                output stream PrnLibStream to value( out-dir + v-file-name ).

          end.
          otherwise do:
            output stream PrnLibStream to value( out-dir + v-file-name )
            convert target "ibm866".
          end.
        end case.
        assign
        v-mode = (if t-scales.scales-type = "CAS_CL5000J"
                  or t-scales.scales-type = "CAS_CL5000"
                  then {&update}
                  else {&deletion}).
        case t-scales.scales-type :
          when "DIGI-SM" then do :
            DO jj = 1 TO gds-amount :
              if ( jj modulo 10 = 0 ) then do:
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                                , jj
                                                                , t-scales.scales-num)).
              end.
              FIND FIRST buf_scales-gds WHERE
                          recid( buf_scales-gds ) = integer( entry( jj, send-rid-list ) ).
              FIND FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK.
              FIND FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK .
              FIND FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK.
              FIND FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK.
              PUT stream PrnLibStream unformatted
                 main-record-string  ( buffer buf_goods
                              ,input "purge"
                              ,input t-scales.db-num
                              ,input t-scales.scales-type
                              ,input buf_scales-gds.scales-num
                              ,input buf_scales-gds.plu-code
                              ,input buf_scales-gds.plu-type
                              ,input buf_prod-bc.b-str /*b-str*/
                              ,input 0.0 /*p-price-sale*/
                              ,input 0 /*deadline*/
                              ,input ? /*deaddate*/
                              ,input 0 /*deadflag*/
                              ,input 0.0 /*buf_scales-gds.wt-cart*/
                              ,input '':U /*-tara-string*/
                              ,input v-dec-delim
                              )
              {&ingridients-del}
              skip .
              delete buf_scales-gds no-error .
              if error-status:error then do:
                return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
              end.
            end.
          end.
          otherwise do :
        DO jj = 1 TO gds-amount :
          if ( jj modulo 10 = 0 ) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , jj
                                                            , t-scales.scales-num)).
          end.
          FIND FIRST buf_scales-gds WHERE
                      recid( buf_scales-gds ) = integer( entry( jj, send-rid-list ) ) .
              FIND FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK.
              FIND FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK .
              FIND FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK.
              FIND FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK.
          PUT stream PrnLibStream unformatted
          
         main-record-string  ( buffer buf_goods
                              ,input "purge"
                              ,input t-scales.db-num
                              ,input t-scales.scales-type
                              ,input buf_scales-gds.scales-num
                              ,input buf_scales-gds.plu-code
                              ,input buf_scales-gds.plu-type
/*                              ,input '':U /*b-str*/*/
                              ,input buf_prod-bc.b-str    
                              ,input 0.0 /*p-price-sale*/
                              ,input 0 /*deadline*/
                              ,input ? /*deaddate*/
                              ,input 0 /*deadflag*/
                              ,input 0.0 /*buf_scales-gds.wt-cart*/
                              ,input '':U /*-tara-string*/
                              ,input v-dec-delim
                              )
          {&ingridients-del}
          skip .
          delete buf_scales-gds no-error .
          if error-status:error then do:
            return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
          end.
        end.
          end.
        end case.
        output stream PrnLibStream close.
      end. /*when purge-selective*/
      when "ALL":U then do:
        v-mode = {&update}.
        CASE ObjectOption:
          WHEN {&current} then do:
              obj-list = yes.
            end.
            when {&all} then do:
              obj-list = no.
            end.
          END CASE.
          case v-stream:
            when "WINdows-1251" then do:
              if t-scales.scales-type = "CAS_LP-15v1.6" then do:
                  /* Для CSV всегда нужна эта шапка. Для нового 5000j - тоже, поэтому их сюда добавить. */
                  output to value( out-dir + v-file-name ). 
                  put "номер отдела;номер товара;тип товара;первая строка названия товара;вторая строка названия товара;строка, которая печатается под логотипом;групповой код;код товара;фиксированная цена товара, в копейках;цена товара, в копейках;вес тары, в граммах;дата упаковки, в днях;время упаковки, в часах;срок годности, в днях;срок годности, в часах;номер состава продукта прикрепленного к товару;текст состава продукта;номер этикетки для печати;номер штрих-кода для печати;дата создания продукта, в днях;номер текста рекламного сообщения;номер логотипа для печати на этикетки;номер единицы измерения количественного товара;кол-во для штучных и счетных товаров;номер страны-производителя;номер второго штриховой код для печати на этикетки;фиксированный вес продукта;"
                      skip. 
                  output close.
                  output stream PrnLibStream to value( out-dir + v-file-name ) append.
              end.
              else do:
                  output stream PrnLibStream to value( out-dir + v-file-name ).
              end.
            end.
            otherwise do:
              output stream PrnLibStream to value( out-dir + v-file-name )
              convert target "ibm866".
            end.
          end case.
          jj = 0.
          FOR EACH buf_scales-gds WHERE
                    buf_scales-gds.db-num = t-scales.db-num AND
                    buf_scales-gds.scales-num = t-scales.scales-num AND
                (obj-list = no
                or (buf_scales-gds.obj-type  = p-obj-type
                   AND
                   buf_scales-gds.obj-code  = p-obj-code)),
              FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
              FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
              FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK,
              FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK
              on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
              on stop   undo, return error substitute( "&1. stop", vss-workfile )
              on endkey undo, return error substitute( "&1. endkey", vss-workfile )
              :



            jj = jj + 1.
            if ( jj modulo 10 = 0 ) then do:
              run show-counter in p-log-handle .
              run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                              , jj
                                                              , t-scales.scales-num)).
            end.
            if buf_scales-gds.to-del = yes then NEXT.
            { str/get-pr.i calc buf_scales-gds.obj-type buf_scales-gds.obj-code buf_goods.gds-code ? "return error."}
            if gp-price-sale = ? then NEXT .
            PUT stream PrnLibStream unformatted
            main-record-string  ( buffer buf_goods
                                ,input {&update}
                                ,input t-scales.db-num
                                ,input t-scales.scales-type
                                ,input buf_scales-gds.scales-num
                                ,input buf_scales-gds.PLU-code
                                ,input buf_scales-gds.plu-type
                                ,input buf_prod-bc.b-str
                                ,input gp-price-sale
                                ,input buf_scales-gds.deadline
                                ,input buf_scales-gds.deaddate
                                ,input buf_scales-gds.deadflag
                                ,input buf_scales-gds.wt-cart
                                ,input var-tara-string
                                ,input v-dec-delim
                                )
            {&ingridients}
            skip .
            assign
            buf_scales-gds.to-send = FALSE no-error .
            run create-obj-record in this-procedure (buffer buf_goods
                                                  , buf_scales-gds.obj-type
                                                  , buf_scales-gds.obj-code).
          END.
            /*добавим удаленные*/
          IF can-find(first buf_scales-gds where
                            buf_scales-gds.db-num = t-scales.db-num AND
                            buf_scales-gds.scales-num = t-scales.scales-num AND
                            buf_scales-gds.to-del = yes) then do:
            run add-del-gds in this-procedure ( input-output jj
                                               ,input v-dec-delim
                                               ,buffer t-scales) .
          end.
          output stream PrnLibStream close.
          run check-write-scales-status in this-procedure (input t-scales.scales-num, input t-scales.db-num, input recid(t-scales)).
      end. /*when "ALL":U then do:*/
      when "SELECTIVE":U
      or
      when "CURRENT" then do:
        goods-lst = "" .
        assign
        goods-lst = send-rid-list
      v-mode = {&update}
        .
        if SendOption = "CURRENT" then do:
          assign
          goods-lst = send-rid-list
          SendOption = "selective":U
          .
        end.
        if goods-lst <> "" then do:
          gds-amount = num-entries( goods-lst ) .
          run show-counter in p-log-handle .
          run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , jj
                                                            , t-scales.scales-num)).
          case v-stream:
            when "WINdows-1251" then do:
              if t-scales.scales-type = "CAS_LP-15v1.6" then do:
                  /* Для CSV всегда нужна эта шапка. Для нового 5000j - тоже, поэтому их сюда добавить.*/
                  output to value( out-dir + v-file-name ). 
                  put "номер отдела;номер товара;тип товара;первая строка названия товара;вторая строка названия товара;строка, которая печатается под логотипом;групповой код;код товара;фиксированная цена товара, в копейках;цена товара, в копейках;вес тары, в граммах;дата упаковки, в днях;время упаковки, в часах;срок годности, в днях;срок годности, в часах;номер состава продукта прикрепленного к товару;текст состава продукта;номер этикетки для печати;номер штрих-кода для печати;дата создания продукта, в днях;номер текста рекламного сообщения;номер логотипа для печати на этикетки;номер единицы измерения количественного товара;кол-во для штучных и счетных товаров;номер страны-производителя;номер второго штриховой код для печати на этикетки;фиксированный вес продукта;"
                      skip. 
                  output close.
                  output stream PrnLibStream to value( out-dir + v-file-name ) append.
              end.
              else do:
                  output stream PrnLibStream to value( out-dir + v-file-name ).
              end.
            end.
            otherwise do:
              output stream PrnLibStream to value( out-dir + v-file-name )
              convert target "ibm866".
            end.
          end case.
          DO jj = 1 TO gds-amount :
            FIND FIRST buf_scales-gds WHERE
                      recid( buf_scales-gds ) = integer( entry( jj, goods-lst ) ) .
            FIND FIRST buf_bar-code WHERE
                      buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK .
            FIND FIRST buf_goods WHERE
                      buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
            FIND FIRST buf_gds-obj-attr WHERE
                        buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                        buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
                        buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                        buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                        No-LOCK.
            FIND FIRST buf_prod-bc WHERE
                        buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK.
            if ( jj modulo 10 = 0 ) then do:
              run show-counter in p-log-handle .
              run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                              , jj
                                                              , t-scales.scales-num)).
            end.
            if buf_scales-gds.to-del = yes then NEXT.
            { str/get-pr.i calc buf_scales-gds.obj-type buf_scales-gds.obj-code buf_goods.gds-code ? "return error."}
            if gp-price-sale = ? then NEXT .
            PUT stream PrnLibStream unformatted
            main-record-string  ( buffer buf_goods
                                ,input {&update}
                                ,input t-scales.db-num
                                ,input t-scales.scales-type
                                ,input buf_scales-gds.scales-num
                                ,input buf_scales-gds.PLU-code
                                ,input buf_scales-gds.plu-type
                                ,input buf_prod-bc.b-str
                                ,input gp-price-sale
                                ,input buf_scales-gds.deadline
                                ,input buf_scales-gds.deaddate
                                ,input buf_scales-gds.deadflag
                                ,input buf_scales-gds.wt-cart
                                ,input var-tara-string
                                ,input v-dec-delim)
            {&ingridients}
            skip .
            assign
            buf_scales-gds.to-send = FALSE no-error .
            if error-status:error then do:
              return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
            end.
            run create-obj-record in this-procedure (buffer buf_goods
                                                  , buf_scales-gds.obj-type
                                                  , buf_scales-gds.obj-code).
        END. /*DO jj = 1 TO gds-amount :*/
          /*добавим удаленные*/
          IF can-find(first buf_scales-gds where
                            buf_scales-gds.db-num = t-scales.db-num AND
                            buf_scales-gds.scales-num = t-scales.scales-num AND
                            buf_scales-gds.to-del = yes) then do:
               run add-del-gds in this-procedure ( input-output jj
                                                  ,input v-dec-delim
                                                  ,buffer t-scales) .
        end.  /*IF can-find(first buf_scales-gds where*/
            output stream PrnLibStream close.
         run check-write-scales-status in this-procedure (input t-scales.scales-num, input t-scales.db-num, input recid(t-scales)).
        end. /*if goods-lst <> "" then do:*/
        else do:
          output stream PrnLibStream close.
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не найдено товаров, выбранных для отсылки на весах &1", {&num-name})).
            SendOption = "".
            return.
          end.
        end. /* when "SELECTIVE":U
                or
                when "CURRENT" then do:
            */
     END CASE. /*CASE SendOption :*/
    CASE t-scales.scales-type:
      when 'DIGI-SM':U then do:
      end.
      when 'TIGER-SPCT2':U then do:
      end.
      when 'TIGER-SPCT1':U then do:
      end.
      when 'DIGI_AW-4600_FX':U then do:
        scale-prog = SEARCH("exe/curl.exe").
        if scale-prog = ? then do:
          undo _zz, return error substitute("Не найден файл программы работы с весами &1", "exe/curl.exe").
        end.
      end.
      otherwise do:
       scale-prog = SEARCH(scale-prog).
       if scale-prog = ? then do:
         undo _zz, return error substitute("Не найден файл программы работы с весами &1", {&num-name-type}).
       end.
     end.
    end.
    if SendOption <> "selective":U then do:
      run gbl/return_.p .
      RUN b-msend-proc in this-procedure (
                       buffer t-scales
                      ,input scale-prog
                      ,input v-file-name
                      ,input v-mode
                      ,input (if sendoption begins "purge"
                              then "Очищаются весы "
                              else "Отправляются товары на весы ")
                      ,output res
                      ,output err-scl-num-list
                      ,output err-codes-list
                      ) no-error.
       if error-status:error or res > 0 then do:
         undo _zz, return error substitute("Ошибка при пересылке данных на весы &1 и/или подчиненные весы&2&3&2&4&2&5"
                                         , {&num-name}
                                         , {&new-line}
                                         , error-status:get-message(1)
                                         , return-value
                                        , (if not error-status:error and res > 0
                                          then substitute("!!!Программа передачи данных на весы &1 вернула ошибку(-и) с кодом(-ми) &2"
                                                          ,err-scl-num-list
                                                          ,err-codes-list
                                                          )
                                          else '':U)
                                         ).
      end.
    end. /*<> selective*/
    else do:
      if goods-lst <> "" then do:
        run gbl/return_.p .
        RUN b-msend-proc in this-procedure (
                         buffer t-scales
                        ,input scale-prog
                        ,input v-file-name
                        ,input v-mode
                        ,input "Отправляются товары на весы "
                        ,output res
                        ,output err-scl-num-list
                        ,output err-codes-list
                        ) no-error.
        if error-status:error or res > 0 then do:
          undo _zz, return error substitute("Ошибка при пересылке данных на весы &1 и/или подчиненные весы&2&3&2&4&2&5"
                                          , {&num-name}
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , return-value
                                          , (if not error-status:error and res > 0
                                            then substitute("!!!Программа передачи данных на весы &1 вернула ошибку(-и) с кодом(-ми) &2"
                                                            ,err-scl-num-list
                                                            ,err-codes-list
                                                            )
                                            else '':U)
                                          ).
        end. /*es*/
     end. /*if goods-lst <> ""*/
    end. /*selective*/
    if sendoption begins "purge" then do:
      FIND b-scales WHERE recid( b-scales ) = recid( t-scales ) EXCLUSIVE.
      CASE sendOption:
        when "purge-ALL":U then do:
          assign
          b-scales.max-plu = 0
          b-scales.tot-gds = 0
          b-scales.to-send = FALSE
          .
        end.
        when "purge-selective":U then do:
          if NOT can-find( FIRST buf_scales-gds WHERE
                                  buf_scales-gds.scales-num = t-scales.scales-num AND
                                  buf_scales-gds.db-num = t-scales.db-num AND
                                  buf_scales-gds.to-send = TRUE ) then do:
              b-scales.to-send = FALSE.
          end.
          FIND LAST buf_scales-gds NO-LOCK WHERE
                    buf_scales-gds.scales-num = t-scales.scales-num
                and buf_scales-gds.db-num = t-scales.db-num
                    use-index pi no-error.
          if avail buf_scales-gds then
          assign
          b-scales.max-plu = buf_scales-gds.plu-code
          b-scales.tot-gds = b-scales.tot-gds - gds-amount
          .
          else
          assign
          b-scales.max-plu = 0
          b-scales.tot-gds = 0
          .
        end.
      END CASE.
    end. /*if begins pruge*/
  END. /*of transaction*/
  IF NOT Error-status:error
  and res = 0
  and not (sendoption begins "purge")
  then do:
    for each buf_gdsolist
    break
    by buf_gdsolist.obj-type
    by buf_gdsolist.obj-code:
      { cmp/gds-list.i gds-list assign " " buf_gdsolist }
      assign
      gds-list.qnty = - 1.
      if last-of(buf_gdsolist.obj-code) then do:
        run write-counter in p-log-handle ('':U).
        run set-title in p-log-handle (
              input substitute("Отправка весовых товаров на кассы &1&2", buf_gdsolist.obj-type, buf_GDSOLIST.OBJ-CODE)
                                      ).
        run str/send-gds.p (
                        input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input (string(buf_gdsolist.obj-code) + {&delim-par} + "yes":U)
                      ) no-error .
        if error-status:error then
        return error substitute( "ошибка при отправке товаров на кассу по магазину &1&2&3&2&4"
                                , abs(buf_gdsolist.obj-code)
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                ).
      end. /*if last-of(buf_gdsolist.obj-code) then do:*/
    end. /*for each buf_gdsolist*/
  end. /*IF NOT Error-status:error
        and res = 0
        and not (sendoption begins "purge")
        then do: */
  if sendoption begins "purge" then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Очистка завершена."
                          )).
  end.
END. /*if not RESEND*/
END PROCEDURE.

PROCEDURE add-del-gds:
DEFINE INPUT-OUTPUT PARAMETER ii as integer no-undo. /*текущий счетчик*/
define input parameter p-dec-delim as character no-undo .
DEFINE PARAMETER buffer loc-scales for ub.scales. /*весы*/
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_goods for ub.goods.
define buffer buf_gds-obj-attr for ub.gds-obj-attr .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.


do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

&scop ingridients-del (if loc-scales.scales-type = "CAS_lp-16x" ~
                       or loc-scales.scales-type = "DIGI-SM"   ~
                       or loc-scales.scales-type = "CAS_CL5000j"   ~
                       or loc-scales.scales-type = "CAS_CL5000"   ~
               then get-struct( input 0    ~
                              , input 0     ~
                              , input '':U ~
                              , input loc-scales.scales-type ~
                              , input loc-scales.db-num ~
                              , input loc-scales.scales-num ~
                              )    ~
               else '':U)
  CASE loc-scales.scales-type :
    when "DIGI-SM" then do :
      FOR EACH buf_scales-gds WHERE
              buf_scales-gds.scales-num = loc-scales.scales-num AND
              buf_scales-gds.db-num = loc-scales.db-num AND
              buf_scales-gds.to-del = yes,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              No-LOCK,
        FIRST buf_prod-bc WHERE
              buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK
              :
        ii = ii + 1.
        if ( ii modulo 10 = 0) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , ii
                                                            , loc-scales.scales-num)).
        end.
        PUT stream PrnLibStream unformatted
           main-record-string  ( buffer buf_goods
                        ,input {&deletion}
                        ,input loc-scales.db-num
                        ,input loc-scales.scales-type
                        ,input buf_scales-gds.scales-num
                        ,input buf_scales-gds.plu-code
                        ,input buf_scales-gds.plu-type
                        ,input buf_prod-bc.b-str /*b-str*/
                        ,input 0.0 /*p-price-sale*/
                        ,input 0 /*deadline*/
                        ,input ? /*deaddate*/
                        ,input 0 /*deadflag*/
                        ,input 0.0 /*buf_scales-gds.wt-cart*/
                        ,input '':U /*-tara-string*/
                        ,input p-dec-delim
                        )
        {&ingridients-del}
        skip .
        delete buf_scales-gds no-error .
        if error-status:error then do:
          return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
        end.
        FIND FIRST b-scales WHERE
                    recid( b-scales ) = recid( loc-scales ) .
        assign
        b-scales.to-send = TRUE
        b-scales.tot-gds  = b-scales.tot-gds - 1
        .
      end. /*doe*/
    end.
    otherwise do :
  FOR EACH buf_scales-gds WHERE
           buf_scales-gds.scales-num = loc-scales.scales-num AND
           buf_scales-gds.db-num = loc-scales.db-num AND
           buf_scales-gds.to-del = yes:
                 FIND FIRST buf_bar-code WHERE
                      buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK .
            FIND FIRST buf_goods WHERE
                      buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
            FIND FIRST buf_gds-obj-attr WHERE
                        buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                        buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
                        buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                        buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                        No-LOCK.
            FIND FIRST buf_prod-bc WHERE
                        buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK.
    ii = ii + 1.
    if ( ii modulo 10 = 0) then do:
        run show-counter in p-log-handle .
        run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                        , ii
                                                        , loc-scales.scales-num)).
    end.
    PUT stream PrnLibStream unformatted
    main-record-string  ( buffer buf_goods
                        ,input {&deletion}
                        ,input loc-scales.db-num
                        ,input loc-scales.scales-type
                        ,input buf_scales-gds.scales-num
                        ,input buf_scales-gds.plu-code
                        ,input buf_scales-gds.plu-type
                        ,input buf_prod-bc.b-str /*b-str*/
                        ,input 0.0 /*p-price-sale*/
                        ,input 0 /*deadline*/
                        ,input ? /*deaddate*/
                        ,input 0 /*deadflag*/
                        ,input 0.0 /*buf_scales-gds.wt-cart*/
                        ,input '':U /*-tara-string*/
                        ,input p-dec-delim
                        )
    {&ingridients-del}
    skip .
    delete buf_scales-gds no-error .
    if error-status:error then do:
      return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
    end.
    FIND FIRST b-scales WHERE
                recid( b-scales ) = recid( loc-scales ) .
    assign
    b-scales.to-send = TRUE
    b-scales.tot-gds  = b-scales.tot-gds - 1
    .
  end. /*doe*/
    end.
  end case.
 END.
END.



PROCEDURE b-msend-proc:
DEFINE PARAMETER BUFFER p-scales for ub.scales.
DEFINE INPUT PARAMETER p-scale-prog as char no-undo.
define input parameter p-file-name as character no-undo .
define input parameter p-mode as character no-undo .
DEFINE INPUT PARAMETER p-message as char no-undo.
DEFINE OUTPUT PARAMETER p-res as integer no-undo.
define output parameter p-err-scl-num-list as character no-undo .
define output parameter p-err-codes-list as character no-undo .
define variable g#report-num as integer no-undo .
define variable v-cmd-line as character no-undo .
define variable r_e as character no-undo .
define variable com_ip as character no-undo .
define variable timeout_port as character no-undo .
define variable v-par as character no-undo.

run get-report-num  in parParentProc(output g#report-num).

DEFINE variable l-res as integer no-undo.
define variable chr-res as character no-undo .
DEFINE BUFFER slave_scales for ub.scales.
if p-scales.scales-type begins "BOLET"
then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1 &2 (№ &3)"
                        , p-message
                        , p-scales.scales-name
                        , p-scales.scales-num)
                                           ).
  run gbl/syn.p ( input p-scale-prog
            ,input (string(p-scales.scales-num)  +
                   out-dir + p-file-name
                   )
            ,input '':U
            ,output l-res) no-error.
  assign
  p-res = p-res + ABS(l-res ) + (IF error-status:error then 1 else 0)
  p-err-scl-num-list = p-err-scl-num-list + (if abs(l-res) <> 0 then string(p-scales.scales-num) else '':U) + {&comma-char}
  p-err-codes-list   =  p-err-codes-list  + (if abs(l-res) <> 0 then string(l-res) else '':U) + {&comma-char}
  .
  FOR EACH slave_scales WHERE
        slave_scales.master = p-scales.scales-num
    AND slave_scales.db-num = p-scales.db-num
        :
    if slave_scales.sts =  integer({&current-status-int})  then do:
      run write-log-and-file in p-log-handle (
                                              input 1
                                            , input log-file-name
                                            , input 1
                                            , input substitute("&1 - Подчиненные весы &2 (№ &3)"
                                                              , p-message
                                                              , slave_scales.scales-name
                                                              , slave_scales.scales-num)
                                                                                ).
      run gbl/syn.p ( input p-scale-prog
                ,input (string(slave_scales.scales-num)  +
                        out-dir + p-file-name)
                ,input '':U
                ,output l-res) no-error.
      assign
      p-res = p-res + ABS(l-res ) + (IF error-status:error then 1 else 0)
      p-err-scl-num-list = p-err-scl-num-list + (if abs(l-res) <> 0 then string(slave_scales.scales-num) else '':U) + {&comma-char}
      p-err-codes-list   =  p-err-codes-list  + (if abs(l-res) <> 0 then string(l-res) else '':U) + {&comma-char}
      .
    end.
  END.
end.
else do:
  run write-log-and-file in p-log-handle (
                                          input 1
                                        , input log-file-name
                                        , input 1
                                        , input  substitute("&1 &2 (№ &3)"
                                                            ,p-message
                                                            ,p-scales.scales-name
                                                            ,p-scales.scales-num)
                                                                            ).
  CASE p-scales.scales-type:
    when 'DIGI-SM' then do:
    os-copy value(out-dir + p-file-name)
            value(digi-out-dir + p-file-name).
    assign
    p-res = p-res + ABS(os-error) + (IF os-error > 0 then 1 else 0)
    p-err-scl-num-list = p-err-scl-num-list + (if abs(os-error) <> 0 then string(p-scales.scales-num) else '':U) + {&comma-char}
    p-err-codes-list   =  p-err-codes-list  + (if abs(os-error) <> 0 then string(os-error) else '':U) + {&comma-char}
    .

    FOR EACH slave_scales WHERE slave_scales.master = p-scales.scales-num:
      run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input  substitute("&1 Подчиненные весы &2 (№ &3)"
                                                                  ,p-message
                                                                  ,slave_scales.scales-name
                                                                  ,slave_scales.scales-num)
                                                                                  ).
      os-copy value(out-dir + p-file-name)
              value(digi-out-dir + replace(p-file-name
                    ,entry(4, p-scales.address, '.')
                    ,entry(4, slave_scales.address, '.'))) .
      if os-error <> 0 then do:
        assign
        p-res = p-res + ABS(os-error) + (IF os-error > 0 then 1 else 0)
        p-err-scl-num-list = p-err-scl-num-list + (if abs(os-error) <> 0 then string(slave_scales.scales-num) else '':U) + {&comma-char}
        p-err-codes-list   =  p-err-codes-list  + (if abs(os-error) <> 0 then string(os-error) else '':U) + {&comma-char}
        .
      end.
    END.
  end.
  when 'TIGER-SPCT2'
  or
  when 'TIGER-SPCT1'
  then do:
      os-copy value(out-dir + p-file-name)
              value((if p-scales.scales-type = "TIGER-SPCT2"
                     then tiger-spct2-out-dir
                     else tiger-spct1-out-dir)
                     + p-file-name).
      assign
      p-res = p-res + ABS(os-error) + (IF os-error > 0 then 1 else 0)
      p-err-scl-num-list = p-err-scl-num-list + (if abs(os-error) <> 0 then string(p-scales.scales-num) else '':U) + {&comma-char}
      p-err-codes-list   =  p-err-codes-list  + (if abs(os-error) <> 0 then string(os-error) else '':U) + {&comma-char}
      .
      /*здесь надао дернуть*/

      FOR EACH slave_scales WHERE
              slave_scales.db-num = p-scales.db-num
           and slave_scales.master = p-scales.scales-num:
        run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input  substitute("&1 Подчиненные весы &2 (№ &3)"
                                                                    ,p-message
                                                                    ,slave_scales.scales-name
                                                                    ,slave_scales.scales-num)
                                                                                    ).
        os-copy value(out-dir + p-file-name)
                value(digi-out-dir + replace(p-file-name
                      ,string(p-scales.scales-num)
                      ,string(slave_scales.scales-num))) .
        if os-error <> 0 then do:
          assign
          p-res = p-res + ABS(os-error) + (IF os-error > 0 then 1 else 0)
          p-err-scl-num-list = p-err-scl-num-list + (if abs(os-error) <> 0 then string(slave_scales.scales-num) else '':U) + {&comma-char}
          p-err-codes-list   =  p-err-codes-list  + (if abs(os-error) <> 0 then string(os-error) else '':U) + {&comma-char}
          .
        end.
      END.
      define variable v-current-dir as character no-undo .
      DEFINE VARIABLE SetCurrentDirectoryAResult AS INTEGER NO-UNDO.
      file-info:file-name = ".".
      v-current-dir = file-info:full-pathname.
      define variable v-install-dir as character no-undo .
      file-info:file-name = (if p-scales.scales-type = "TIGER-SPCT2"
                              then tiger-spct2-install-dir
                              else tiger-spct1-install-dir).
      v-install-dir = file-info:full-pathname.
      v-install-dir = (if index(v-install-dir, {&space-char}) > 0
                       then substitute('"&1"', v-install-dir)
                       else v-install-dir)
                       .
      define variable v-file-name as character no-undo .
      file-info:file-name =  substitute("&1&2"
                                        ,  (if p-scales.scales-type = "TIGER-SPCT2"
                                            then tiger-spct2-install-dir
                                            else tiger-spct1-install-dir)
                                        , (if p-scales.scales-type = "TIGER-SPCT2"
                                          then (if p-mode = {&update}
                                              then "tigeru-spct2.exe":U
                                              else "tigerd-spct2.exe")
                                          else (if p-mode = {&update}
                                          then "tigeru-spct1.exe":U
                                          else "tigerd-spct1.exe")
                                          )
                                        ).
      v-file-name = file-info:full-pathname.
      v-file-name = (if index(v-file-name, {&space-char}) > 0
                       then substitute('"&1"', v-file-name)
                       else v-file-name)
                       .
      tiger:
      do
      on error  undo tiger, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo tiger, return error substitute( "&1. stop", vss-workfile )
      on endkey undo tiger, return error substitute( "&1. endkey", vss-workfile )
      :
       run gbl/synd.p ( input v-install-dir
                      ,input v-file-name
                      ,input substitute("ibs&1.ini", p-scales.scales-num)
                      ,input '':U
                      ,output l-res
                                                                  ) no-error .
      end.
      if l-res > 0 then do:
        run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input  substitute("&1Ошибка при передаче на весы &2 (№ &3) и подчиненные&1&4&1&5"
                                                                    ,{&new-line}
                                                                    ,p-scales.scales-name
                                                                    ,p-scales.scales-num
                                                                    ,error-status:get-message(1)
                                                                    ,return-value)
                                                                                    ).

      end.
      p-res = p-res + l-res.
    end.
    otherwise do:
      case p-scales.scales-type:
        when "SHTRIH-M" then do:
          assign
          r_e = (if p-scales.address begins "COM" then "R" else "E")
          com_ip = replace(entry(1, p-scales.address, ":"), "COM", "")
          timeout_port = entry(2, p-scales.address, ":")
          .
          v-cmd-line = substitute('&1 &2 &3 &4 "&5&6"'
                                  ,p-scale-prog
                                  ,r_e
                                  ,com_ip
                                  ,timeout_port
                                  ,out-dir
                                  ,p-file-name).
            run gbl/syn6.p
              (input v-cmd-line
              ,input out-dir + "log.txt"
              ,input "Ждите! Идет передача на весы..."
              ,output chr-res
              ) no-error .
            if error-status:error
            or chr-res > '':u then do:
              l-res = 1.
            end.
        end.
        when "CAS_LP-15v1.6" then do:
            /* Тут нужна обработка: Если запись и новый экзэшник, то всё нормально,
                а если удаление, то берем из препроцессоров стандартный exe и удаляем */
            if {&scale-prog-16} = "exe/CAScentre.exe" then do:
                if p-mode = {&update} then do:
                    com_ip = entry(1, p-scales.address, ":").
                    timeout_port = entry(2, p-scales.address, ":").
                    v-cmd-line = com_ip + " " + timeout_port + " 1 0 " + out-dir + p-file-name.
                end.
                else do:
                    v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,p-scales.address
                                  ,out-dir
                                  ,p-file-name).
                    p-scale-prog = ENTRY(LOOKUP("CAS_LP-15v1.6", {&scales-type}), {&scales-pr}).
                    p-scale-prog = search(p-scale-prog).
                end.
                run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
                
            end.
            else do:
                v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,p-scales.address
                                  ,out-dir
                                  ,p-file-name).
                run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
            end.
        end.
        when "DIGI_AW-4600_FX":U then do:
          os-copy value(out-dir + p-file-name)
                  value(out-dir + "plu0d001.csv").
         /*
         curl ftp://name:passwd@machine.domain:port/full/path/to/file
         curl -u name:passwd ftp://machine.domain:port/full/path/to/file
         curl -T uploadfile -u user:passwd ftp://ftp.upload.com/
         curl -T uploadfile -u user:passwd ftp://ftp.upload.com/myfile

         curl -T uploadfile ftp://name:passwd@machine.domain:port

         */
          v-cmd-line = substitute(' -T "&1&2" ftp://anonymous:anonymous@&3'
                                  ,out-dir
                                  ,"plu0d001.csv"
                                  ,p-scales.address
                                  ).

          run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.

        end.
        otherwise do:
          case p-scales.scales-type:
            when "CAS_CL5000J"
            then do:
              if p-mode <> {&update} then do:
                p-scale-prog = replace(p-scale-prog, "cl5000js", "cl5000jd").
              end.
            end.
            when "CAS_CL5000"
            then do:
              if p-mode <> {&update} then do:
                p-scale-prog = replace(p-scale-prog, "cl5000s", "cl5000d").
              end.
            end.

          end case.
          v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,p-scales.address
                                  ,out-dir
                                  ,p-file-name).
          run gbl/syn.p ( input p-scale-prog
                        ,input v-cmd-line
                          ,input '':u
                          ,output l-res) no-error.
        end.
      end case.
      assign
      p-res = p-res + ABS(l-res ) + (IF error-status:error then 1 else 0)
      p-err-scl-num-list = p-err-scl-num-list + (if abs(l-res) <> 0 then string(p-scales.scales-num) else '':U) + {&comma-char}
      p-err-codes-list   =  p-err-codes-list  + (if abs(l-res) <> 0 then string(l-res) else '':U) + {&comma-char}
      .
      FOR EACH slave_scales WHERE
              slave_scales.master = p-scales.scales-num
          AND slave_scales.db-num = p-scales.db-num
          and slave_scales.sts <> integer({&deleted-status-int}):
        run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input  substitute("&1 Подчиненные весы &2 (№ &3)"
                                                                    ,p-message
                                                                    ,slave_scales.scales-name
                                                                    ,slave_scales.scales-num)
                                                                                    ).
        case slave_scales.scales-type:
          when "SHTRIH-M" then do:
            assign
            r_e = (if slave_scales.address begins "COM" then "R" else "E")
            com_ip = replace(entry(1, slave_scales.address, ":"), "COM", "")
            timeout_port = entry(2, slave_scales.address, ":")
            .
            v-cmd-line = substitute('&1 &2 &3 &4 "&5&6"'
                                    ,p-scale-prog
                                    ,r_e
                                    ,com_ip
                                    ,timeout_port
                                    ,out-dir
                                    ,p-file-name).
            run gbl/syn6.p
              (input v-cmd-line
              ,input out-dir + "log.txt"
              ,input "Ждите! Идет передача на весы..."
              ,output chr-res
              ) no-error .
            if error-status:error
            or chr-res > '':u then do:
              l-res = 1.
            end.
          end.
          when "DIGI_AW-4600_FX":U then do:
            v-cmd-line = substitute(' -T "&1&2" ftp://anonymous:anonymous@&3'
                                    ,out-dir
                                    ,"plu0d001.csv"
                                    ,slave_scales.address
                                    ).

            run gbl/syn.p ( input p-scale-prog
                      ,input v-cmd-line
                      ,input '':u
                      ,output l-res) no-error.

          end.
        when "CAS_LP-15v1.6" then do:
            /* Тут нужна обработка: Если запись и новый экзэшник, то всё нормально,
                а если удаление, то берем из препроцессоров стандартный exe и удаляем */
            if {&scale-prog-16} = "exe/CAScentre.exe" then do:
                if p-mode = {&update} then do:
                    com_ip = entry(1, slave_scales.address, ":").
                    timeout_port = entry(2, slave_scales.address, ":").
                    v-cmd-line = com_ip + " " + timeout_port + " 1 0 " + out-dir + p-file-name.
                end.
                else do:
                    v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,slave_scales.address
                                  ,out-dir
                                  ,p-file-name).
                    p-scale-prog = ENTRY(LOOKUP("CAS_LP-15v1.6", {&scales-type}), {&scales-pr}).
                    p-scale-prog = search(p-scale-prog).
                end.
                run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
                
            end.
            else do:
                v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,slave_scales.address
                                  ,out-dir
                                  ,p-file-name).
                run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
            end.
        end.
          otherwise do:
            v-cmd-line = substitute(" -d &1 < &2&3"
                                    ,slave_scales.address
                                    ,out-dir
                                    ,p-file-name).
            run gbl/syn.p ( input p-scale-prog
                            ,input v-cmd-line
                            ,input '':u
                            ,output l-res) no-error.
          end.
        end case.
        assign
        p-res = p-res + ABS(l-res ) + (IF error-status:error then 1 else 0)
        p-err-scl-num-list = p-err-scl-num-list + (if abs(l-res) <> 0 then string(slave_scales.scales-num) else '':U) + {&comma-char}
        p-err-codes-list   =  p-err-codes-list  + (if abs(l-res) <> 0 then string(l-res) else '':U) + {&comma-char}
        .
      END.
    end. /*if p-scales.scales-type <> 'DIGI-SM' then do:*/
  END CASE.
  if p-scales.scales-type = "DIGI_AW-4600_FX" then do:
    os-delete value(out-dir + "plu0d001.csv").
  end.
end.
END PROCEDURE.

PROCEDURE create-name-str:
define parameter buffer loc-goods for ub.goods.
define output parameter loc-name-buf1 as character no-undo .
define variable ff as integer no-undo .
define variable v-name as character no-undo .
define variable v-log as logical no-undo .
  loc-name-buf1 = "" .
  v-name = if loc-goods.label-name = "":U
           then  loc-goods.gds-name
           else loc-goods.label-name
           .
  DO ff = 1 TO num-entries( v-name, '"' ) :
      loc-name-buf1 = loc-name-buf1 + entry( ff, v-name, '"' ) .
  END .
END PROCEDURE.


PROCEDURE create-name-str-2:
define parameter buffer loc-goods for ub.goods.
define input parameter p-length as integer no-undo .
define output parameter loc-name-buf1 as character no-undo .
define output parameter loc-name-buf2 as character no-undo .
DEFINE VARIABLE loc-name-buf as character no-undo .
define variable ff as integer no-undo .
define variable v-name as character no-undo .
define variable v-log as logical no-undo .
  loc-name-buf = "" .
  loc-name-buf1 = "" .
  loc-name-buf2 = "" .
  v-name = if loc-goods.label-name = "":U
           then  loc-goods.gds-name
           else loc-goods.label-name
           .
  if p-length <= 0 then do:   /* Для CAS5000 длина одной строки может быть 40 символов, но с достаточно мелким шштрифтом, поэтому взависимости от длины названия будем делить его на разный размер  */
    if length(v-name) >= 50 then p-length = length(v-name) / 2.
    else p-length = 30.
  end.             
  DO ff = 1 TO num-entries( v-name, '"' ) :
      loc-name-buf = loc-name-buf + entry( ff, v-name, '"' ) .
  END .
  DO ff = 1 TO num-entries( loc-name-buf, ' ' ) :
      if length(loc-name-buf1) + length (entry( ff, loc-name-buf, ' ' ) ) <= p-length
      and not v-log
      then do:
        loc-name-buf1 = loc-name-buf1 + " " + entry( ff, loc-name-buf, ' ' ) .
      end.
      else  do:
       if ff = 1 then do:
          assign
          loc-name-buf1 = {&space-char} + substring(loc-name-buf, 1, p-length)
          v-log = yes
          .
        end.
        else do:
          assign
          loc-name-buf2 = loc-name-buf2 + " " + entry( ff, loc-name-buf, ' ' )
          v-log = yes
          .
        end.
      end.
  END .
  /*  оставляем на будущее
  if loc-goods.alpha1 <> "XX":U and loc-goods.alpha1 <> "":U then  do:
    find first country No-LOCK WHERE
                country.alpha1 = loc-goods.alpha1 NO-ERROR.
    if avail country then do:
      assign
      loc-name-buf2 = substr(loc-name-buf2, 1, 25 - MAX(length(country.short-name) + 1, 1)
                          ) no-error.
      loc-name-buf2 = loc-name-buf2 + {&space-char} + country.short-name.
    end.
  END.
  */
  if loc-name-buf1  = ""
  then do:
    if loc-name-buf2 = ""
    then
    loc-name-buf1 = {&space-char} + substring(replace(loc-goods.gds-name, '"', '':U), 1, p-length) .
    else do:
      assign
      loc-name-buf1 = loc-name-buf2
      loc-name-buf2 = '':U.
    end.
  end.
END PROCEDURE.

procedure create-obj-record :
define parameter buffer buf_goods for ub.goods.
define input parameter p-obj-type like ub.scales-gds.obj-type no-undo .
define input parameter p-obj-code like ub.scales-gds.obj-code no-undo .
define buffer buf_gdsolist for gdsolist.

  do
  on error undo, return error
  :

    find first buf_gdsolist where
              buf_gdsolist.gds-code = buf_goods.gds-code
          AND buf_gdsolist.obj-type = p-obj-type
          and buf_gdsolist.obj-code = p-obj-code  no-error .
    if not avail buf_gdsolist then do:
      create buf_gdsolist.
      buffer-copy buf_goods to buf_gdsolist
      assign
      buf_gdsolist.to-del = no
      buf_gdsolist.obj-type = p-obj-type
      buf_gdsolist.obj-code = p-obj-CODE
      .
    end.
  end.

end procedure. /* create-obj-record */

procedure check-write-scales-status :
define input parameter p-scales-num like ub.scales.scales-num no-undo .
define input parameter p-db-num     like ub.scales.db-num no-undo .
define input parameter p-recid-scales as recid no-undo .

define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_scales for ub.scales.

do
on error undo, return error
:
  if NOT can-find( FIRST buf_scales-gds WHERE
                          buf_scales-gds.scales-num = p-scales-num AND
                          buf_scales-gds.db-num = p-db-num AND
                          buf_scales-gds.to-send = TRUE ) AND
      NOT can-find( FIRST buf_scales-gds WHERE
                          buf_scales-gds.scales-num = p-scales-num AND
                          buf_scales-gds.db-num = p-db-num AND
                          buf_scales-gds.to-del = TRUE ) then do:
    FIND FIRST buf_scales WHERE
                recid( buf_scales ) = p-recid-scales.
    assign
    buf_scales.to-send = FALSE
    .
  end. /*if NOT can-find( FIRST buf_scales-gds WHERE*/

end.

end procedure. /* check-write-scales-status */

/* $Workfile$ e n d */
