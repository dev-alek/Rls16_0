/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для хранения параметров обмена с ТЭККА МАРИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/25/06
Author: Bakhtadze Natalya
Creation date: 01/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/alienini.i }

define {1} temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer  /*количество записей для передачи*/
field max-records   as integer  /*количество записей всего*/
field min-plu       as integer  /*min plu текущей посылки*/
field max-plu       as integer  /*max plu текущей посылки*/
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character /* № ЭККА "5712000000"*/
field port-num      as character /*"COM1"*/
field way           as character      /* "local" или "ftp" или "номер телефона"*/
field is-script     as logical       /* "если через script - shared"*/
field pswd          as character     /* "00000000"*/
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.

define {1} temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character /*IBS или TEKKA*/
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.

define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.

&glob income-objects '48,49,50,51':U
&glob income-objects-current '48,49':U
&glob income-objects-prev '50,51':U
&glob rsrv-line-objects '45,52':U
&glob rsrv-line-objects-current '45':U
&glob rsrv-line-objects-prev '52':U
&glob spool-objects '26,27,28,29,30,31,32,33,16,17,42,43':U
&glob spool-petrol '26,27,28,29,30,31,32,33':U
&glob spool-goods-doc '16,17':U
&glob spool-goods '42,43':U
&glob spool-objects-current '26,27,28,29,16,42':U
&glob spool-petrol-current '26,27,28,29':U
&glob spool-goods-current '42':U
&glob spool-goods-doc-current '16':U
&glob spool-objects-prev '30,31,32,33,17,43':U
&glob spool-petrol-prev '30,31,32,33':U
&glob spool-goods-prev '43':U
&glob spool-goods-doc-prev '17':U
&glob petrol-page-len 1489
&glob petrol-z-count-field 5
&glob petrol-doc-num-field 9
&glob petrol-date-field 8
&glob pay-type-2   0
&glob goods-page-len 2978
&glob goods-doc-page-len 2340
&glob goods-doc-z-count-field 1
&glob goods-doc-date-field (6 + ~{&pay-type-2~})
&glob goods-doc-doc-num-field (7 + ~{&pay-type-2~})
&glob goods-doc-num-field 3


&glob tekka-no-error-char "Ошибок нет."
&glob tekka-no-error-int-chr ''
&glob closed-shift-info 15
&glob tekka-date-field 1
&glob tekka-time-field 2
&glob tekka-num-recs-first-field 8
&glob tekka-num-recs-num-fields 4


&glob closed-shift-first-field 3
&glob closed-shift-fields-num  4
&glob secondary-objects '42,43':U
&glob object-groups '16-42,17-43,':U



&glob tekka-rvs-line-pump-obj '41'
&glob tekka-rvs-line-obj '45,52'
&glob tekka-rvs-line-current-obj '45'
&glob tekka-rvs-line-prev-obj '52'
&glob tekka-income-obj '48,49,50,51'
&glob tekka-income-current-obj '48,49'
&glob tekka-income-prev-obj '50,51'

&glob tekka-obj-clients       1
&glob tekka-obj-debet-card    2
&glob tekka-obj-credit-card   3
&glob tekka-obj-pay-card      4
&glob tekka-obj-goods-grp1    6
&glob tekka-obj-goods-grp2    7
&glob tekka-obj-goods-ean     8
&glob tekka-obj-goods-price   9
&glob tekka-obj-goods-prop    10
&glob tekka-obj-goods-code    12
&glob tekka-obj-petrol-price  13
&glob tekka-obj-goods-name-part1 20
&glob tekka-obj-goods-name-part2 21
&glob tekka-obj-discount-config 24
&glob tekka-obj-dis-rules 25
&glob tekka-obj-taxation       57





&scop custom-type-list   'Sx,B,BF,BN,UI,UL,FL,SL,VL':U
/*в какие типы будем преобразовывать*/
&scop progress-type-list 'C,I,I,I,D,D,D,D,D':U

/*

 Типы данных Datastru.ini и их представление

Код Длина Описание для BIN                            Длина в TXT,  Описание для TXT
ти- в BIN,                                            симво-лов
па  байт
--  -
Sx x      Произвольное количество байтов, содержащее  X             Количество байтов поля в txt
          екстовую информацию (наименования и т.д.)                 равно количеству байтов поля в bin
                                                                    (прямое копирование данных из bin в txt - тек-стовая информация).

B  1      Один байт со значением 0-255               3              3 символа "000" - "255" представление
                                                                    десятичными цифрами значения одного байта из bin

BF 1      Один байт со значением 0-255               8              8 символов "0" или "1" - представление двоичными цифрами значения байта из bin

BN 1      Один байт со значением 0-255               От 1-й до 8-ми Каждая группа со-держит 3 символа
                                                    групп по 3      "000" - "255" пред-ставление десятич-ными цифрами значе-ния одной группы бит байта из bin
                                                    символа

UI 2      2-х байтное представление числа ("слово"), 5              5 символов "00000" - "65535" представ-ление десятичными цифрами
          когда первым следует младший байт,                        значения 2-х байтов из BIN.
          затем старший.
          Значения 0-65535

UL 4      4-х байтное представление числа           9              9 символов "000000000" - "999999999" пред-ставление десятич-ными
          (два "слова"), когда первым следует                      цифрами значе-ния 4-х байтов из BIN.
          младший байт младшего слова,
          затем старший байт млад-шего слова,
          затем младший байт старшего слова,
          затем старший байт старшего слова,
          Значения 0-999999999

FL 4      4-х байтное представление числа           10             10 символов "0000000000" - "4294967295" пред-ставление
          (два "слова"), когда первым следует                      десятич-ными цифрами значе-ния 4-х байтов из BIN.
          младший байт младшего слова,
          затем старший байт млад-шего слова,
          затем младший байт старшего слова,
          затем старший байт старшего слова,
          Значения 0-4294967295

SL 5      5-ти байтное представление чис-ла        10              10 символов "0000000000" - "9999999999" пред-ставление
          (один байт и два "слова"). При этом                      десятич-ными цифрами значе-ния 5-ти байтов из BIN.
          абсолютное значение определяется как
          ( ( (значе-ние_первого_байта) * 10000 +
          значение_первого_слова ) * 10000 ) +
          значе-ние_второго_слова.
          Последова-тельность байтов внутри
          каждого слова соответствует
          представле-нию UI

VL 6     6-ти байтное представление чис-ла
        (три "слова").
        При этом аб-солютное значение определяется   12           12 символов "000000000000" - "999999999999" представление
        как ( ( (значе-ние_первого_слова) * 10000 +                деся-тичными цифрами значения 6-ти бай-тов из BIN.
        значение_второго_слова ) * 10000 ) +
        значе-ние_третьего_слова.
        Последова-тельность байтов внутри каждого
        слова соответствует представле-нию UI

*/

FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), {&spool-petrol-prev}) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  {&spool-goods-prev}) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  {&spool-goods-doc-prev}) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.

FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, {&spool-petrol-prev})))
                  or (p-journal-num = integer(entry(1, {&spool-petrol-current})))
                  or (p-journal-num =  integer(entry(1, {&spool-goods-doc-prev})))
                  or (p-journal-num = integer(entry(1, {&spool-goods-doc-current})))
.
return v-is-first-journal.
END FUNCTION.

FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), {&spool-petrol}) > 0.
return v-is-petrol-journal.
END FUNCTION.


FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), {&spool-petrol}) > 0
                    then {&petrol-page-len}
                    else {&goods-doc-page-len}).
return v-max-record-num.
END FUNCTION.

FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), {&spool-petrol}) > 0
                    then {&petrol-page-len} * num-entries({&spool-petrol-prev})
                    else {&goods-doc-page-len} * num-entries({&spool-goods-doc-prev})).
return v-max-record-num.
END FUNCTION.


FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .

if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, {&spool-petrol-prev}))) * {&petrol-page-len} + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, {&spool-petrol-current})) ) * {&petrol-page-len} + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), {&spool-goods-doc}) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, {&spool-goods-doc-prev}))) * {&goods-doc-page-len} + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, {&spool-goods-doc-current})) ) * {&goods-doc-page-len} + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, {&spool-goods-prev}))) * {&goods-page-len} + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, {&spool-goods-current})) ) * {&goods-page-len} + p-rec-no
      .
    end.

  end.
end.
return v-num-recs.
END FUNCTION.

FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .


if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / {&petrol-page-len}, 0)
  .
  if p-is-current and num-entries({&spool-petrol-current}) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, {&spool-petrol-current}))
  p-rec-no = p-num-recs modulo {&petrol-page-len}
  .
  if not p-is-current and num-entries({&spool-petrol-prev}) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, {&spool-petrol-prev}))
  p-rec-no = p-num-recs modulo {&petrol-page-len}
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / {&goods-doc-page-len}, 0)
  v-obj-num2 = trunc(p-num-recs2 / {&goods-page-len}, 0)
  .
  if p-is-current and num-entries({&spool-goods-doc-current}) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, {&spool-goods-doc-current}))
  p-rec-no = p-num-recs modulo {&goods-doc-page-len}
  .
  if not p-is-current and num-entries({&spool-goods-doc-prev}) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, {&spool-goods-doc-prev}))
  p-rec-no = p-num-recs modulo {&goods-doc-page-len}
  .
  if p-is-current and num-entries({&spool-goods-current}) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, {&spool-goods-current}))
  p-rec-no2 = p-num-recs2 modulo {&goods-page-len}
  .
  if not p-is-current and num-entries({&spool-goods-prev}) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, {&spool-goods-prev}))
  p-rec-no2 = p-num-recs2 modulo {&goods-page-len}
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100. /*если уже был прочитан последний чек - то 100 означает что нечего больше читать*/
return v-obj-num.
END FUNCTION.

FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), {&spool-petrol-prev}) > 0 then return integer(entry(1, {&spool-goods-doc-prev})).
if lookup (string(p-obj-num), {&spool-goods-doc-prev}) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, {&spool-petrol-current})).
   if not p-is-ptrl then
   return integer(entry(1, {&spool-goods-doc-current})).
end.
if lookup (string(p-obj-num), {&spool-petrol-current}) > 0 then return integer(entry(1, {&spool-goods-doc-current})).
if lookup (string(p-obj-num), {&spool-goods-doc-current}) > 0 then return 100.
return 0.
END FUNCTION.

FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), {&spool-petrol-prev}) > 0 then return integer(entry(1, {&spool-petrol-current})).
if lookup (string(p-obj-num), {&spool-goods-doc-prev}) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, {&spool-petrol-current})).
  if not p-is-ptrl then
  return integer(entry(1, {&spool-goods-doc-current})).
end.
if lookup (string(p-obj-num), {&spool-petrol-current}) > 0 then return integer(entry(1, {&spool-goods-doc-current})).
if lookup (string(p-obj-num), {&spool-goods-doc-current}) > 0 then return 100.
return 0.
END FUNCTION.


&if "{2}" <> "" &then

PROCEDURE maria-put:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-shift-fields as integer no-undo .
define input parameter p-binary as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-plu as integer no-undo .
define input parameter p-value as character no-undo .

define variable v-file-name as character no-undo .
define variable v-create as logical no-undo .

define buffer buf_temp-tekka-tsk for temp-tekka-tsk.



v-file-name =  p-out + p-fname + '.' + string(p-obj-num,  '999') .
output stream {2}
to value(v-file-name) append .
Put  stream {2} unformatted
p-plu
{&delim-key}
p-value
skip.
output stream {2}
close.
if not p-by-record then do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name no-error .
  if not available buf_temp-tekka-tsk then do:
    v-create = yes.
  end.
end.
else do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name
        and buf_temp-tekka-tsk.max-plu = (p-plu - 1) use-index gpi no-error .
  if not available buf_temp-tekka-tsk
  then do:
    find first buf_temp-tekka-tsk where
              buf_temp-tekka-tsk.filename  = v-file-name
          and buf_temp-tekka-tsk.min-plu = (p-plu + 1) use-index lpi no-error .
    if not available buf_temp-tekka-tsk
    then do:
      v-create = yes.
    end.
  end. /**/
end. /*p-by-recordds = yes*/
if v-create then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.range    = p-plu
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U /*потом напишем*/
  buf_temp-tekka-tsk.num-records = 0
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = num-entries(p-value, {&delim-par} )
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.shift-fields = p-shift-fields
  buf_temp-tekka-tsk.binary = p-binary
  buf_temp-tekka-tsk.send-get = 'send'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'remote'
                        then entry(2, entry(2, BUF_CASH-DESK.addr-path, {&delim-par}), '+')
                        else (if entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'shared'
                              then 'local'
                              else entry(1, BUF_CASH-DESK.addr-path, {&delim-par}))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-plu
  buf_temp-tekka-tsk.max-plu     = p-plu
  .
end.
assign
buf_temp-tekka-tsk.num-records = buf_temp-tekka-tsk.num-records + 1
buf_temp-tekka-tsk.min-plu     = minimum(buf_temp-tekka-tsk.min-plu, p-plu)
buf_temp-tekka-tsk.max-plu     = maximum(buf_temp-tekka-tsk.max-plu, p-plu)
.
END PROCEDURE.


PROCEDURE maria-get:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-num-fields as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-min-plu as integer no-undo .
define input parameter p-max-plu as integer no-undo .
define input parameter p-other as character no-undo .
define input parameter p-order-num as integer no-undo .

define variable v-file-name as character no-undo .
define variable v-secondary-obj-num as character no-undo .

define buffer buf_temp-tekka-tsk for temp-tekka-tsk.


if p-by-record then do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '.' + string(p-obj-num,  '999') .
end.
else do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '_html.' + string(p-obj-num,  '999').
end.

find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.filename  = v-file-name no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U /*потом напишем*/
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = p-num-fields
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.send-get = 'get'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, {&delim-par}), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, {&delim-par}))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-min-plu
  buf_temp-tekka-tsk.max-plu     = p-max-plu
  buf_temp-tekka-tsk.num-records = (if p-min-plu <> ?
                                    and p-max-plu <> ?
                                    then p-max-plu - p-min-plu + 1
                                    else 0) /*0 означает максимум*/
  buf_temp-tekka-tsk.other-info = p-other
  buf_temp-tekka-tsk.order-num = p-order-num
  .
  if index({&object-groups}, string(buf_temp-tekka-tsk.obj-num) + '-') > 0 then do:
    assign
    v-secondary-obj-num =  substring({&object-groups}, index({&object-groups}, string(buf_temp-tekka-tsk.obj-num) + '-'))
    v-secondary-obj-num = entry(2, v-secondary-obj-num, '-':U)
    v-secondary-obj-num = entry(1, v-secondary-obj-num)
    no-error
    .
    buf_temp-tekka-tsk.secondary = integer(v-secondary-obj-num).
  end.
end.
END PROCEDURE.

PROCEDURE maria-task:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-fname as character no-undo .
define input parameter p-obj-num-list as character no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.task-num  = p-fname no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = ''
  buf_temp-tekka-tsk.range = 1
  buf_temp-tekka-tsk.obj-num = 0
  buf_temp-tekka-tsk.obj-name = p-obj-num-list
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = no
  buf_temp-tekka-tsk.send-get = 'task'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, {&delim-par}), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, {&delim-par}))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, {&delim-par}) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, {&delim-par})
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.other-info = p-parameters
  buf_temp-tekka-tsk.order-num = 0
  .
end.
END PROCEDURE.



&endif


procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
/*место где лежат причиндалы addin и структура*/
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.

  do
  on error undo, return error
  :
     /*считаем нашу текущую струтуру из .d файла в формате dump*/
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
     /*сичтаем из datastru.ini*/
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, {&back-slash-char}) + {&back-slash-char} + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, {&back-slash-char}) + {&back-slash-char} + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, {&back-slash-char}) + {&back-slash-char} + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .

          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.

          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, {&back-slash-char}) + {&back-slash-char} + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .

            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, {&custom-type-list})
                                                        , {&progress-type-list})
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.

            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, {&back-slash-char}) + {&back-slash-char} + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     /*сверим с той что в datastru*/
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).

       end.
     end.
  end.

end procedure. /* tekkatsk-verify-schema */

FUNCTION set-Sx returns character (input p-string as character):
/*"hahaha" -----> "hahaha" */
return p-string.
END FUNCTION.

FUNCTION get-Sx returns character (input p-string  as character):
/*"hahaha" -----> "hahaha" */
return p-string.
END FUNCTION.

FUNCTION set-B returns character (input p-string  as character):
/*"77" -----> "M" */
return chr(integer(p-string)).
END FUNCTION.

FUNCTION get-B returns character (input p-string  as character):
/*"M" -----> "77" */
return string(asc(p-string)).
END FUNCTION.

FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
/*"01010101" ------> "U"*/
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.

FUNCTION get-BF returns character (input p-string  as character):
/*"U" ------> "01010101" */
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.

FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
/*например при p-bin-group  = "1,3,4" "000005011" ------ > "U" */
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.

FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
/* например при p-bin-group  = "1,3,4" "U" ------> "000005011" */

define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.

/* $Workfile$ e n d */