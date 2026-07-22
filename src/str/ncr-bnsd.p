block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ncr-bnsd.p $
$Archive: str/ncr-bnsd.p $

Удаление бонусов 91 с кассы NCR по одному баркоду
Вызывается в триггере на удаление записи dis-gds-rule-attr

Автор: Мазуров Виталий Александрович
Дата создания: 25/05/11
Author: Mazurov Vitaliy
Creation date: 25/05/11

*/

define input parameter p-parameter     as character no-undo .

/*
p-parameter включает
def input param p-recid      as recid no-undo.  recid dis-gds-rule
def input param p-out        as char  no-undo.  путь для файла
def input param p-attr-code  as char no-undo.   dis-gds-rule-attr
def input param p-attr-value as char no-undo.   dis-gds-rule-attr
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ncr-bnsd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/ncr-bnsd.p $":U .
define variable vss-description as character no-undo init "Удаление бонусов 91 с кассы NCR".

{ cmp/vssrevis.i }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i }

def stream IBMStream.

def var v-found as log no-undo .
def var v-upd   as char no-undo .
def var v-ver   as char no-undo .
def var v-char-delim-1  as char initial ',' no-undo .
def var v-char-delim-2  as char initial ';' no-undo .
def var v-char-1        as char no-undo .
def var v-char-2        as char no-undo .
def var v-char-21       as char no-undo .
def var v-char-3        as char no-undo .
def var v-char-4        as char no-undo .
def var v-char-41       as char no-undo .
def var v-char-42       as char no-undo .
def var v-char-5        as char no-undo .
def var v-char-6        as char no-undo .
def var v-char-61       as char no-undo .
def var v-char-62       as char no-undo .
def var v-char-8        as char no-undo .
def var v-char-9        as char no-undo .

def var v-char-7        as char no-undo .
def var v-char-71       as char no-undo .
def var v-char-72       as char no-undo .
def var v-cassa         as char no-undo .
def var v-is-weight     as log  no-undo init false .
def var v-ean13         as char no-undo .
def var v-tmpchar       as char no-undo .
def var fname           as char no-undo .

def buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr .
def buffer buf_dis-gds-rule      for ub.dis-gds-rule .
def buffer buf_dis-rule          for dis-rule .
def buffer buf_dis-time-rule     for dis-time-rule .
def buffer buf_prod-bc           for prod-bc .
def buffer buf_bar-code          for bar-code .
def buffer buf_units             for ub.units .
def buffer buf_goods             for ub.goods.

def var p-recid      as recid no-undo.
def var p-out        as char  no-undo.
def var p-attr-code  as char  no-undo.
def var p-attr-value as char  no-undo.

assign
p-recid      = int(entry(1, p-parameter, {&delim-par}))
p-out        =     entry(2, p-parameter, {&delim-par})
p-attr-code  =     entry(3, p-parameter, {&delim-par})
p-attr-value =     entry(4, p-parameter, {&delim-par})
no-error
.
if error-status:error then do:
    return error substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
end.

assign
  fname = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 )
  v-ver = "2.02.00"
  v-char-1 = "0,0,0,,,,,0,1,0,0,1,;,0,0,1,0,0,"
  v-char-2 = "0,0,0,0,0,0,"
  v-char-21 = "0,0,0,"
  v-char-3 = "0,0,0,"
  v-char-4 =
  ",;,,;,;,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
  v-char-41 =
  ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
  v-char-42 =
  ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,1,0,21,0,0,"
  v-char-5 =
  "0,0,1,1,0,4,1,"

  v-char-6 =
  ",;,;,;,;,;,0;+                                       ;"
  v-char-61 =
  ",;,;,;,;,;,1;+                                       ;"
  v-char-62 =
  ",;,;,;,;,;,1;Message                                 ;"

  v-char-7 =
  "006;00;000;               ;          ;,0,0"
  v-char-71 =
  "006;04;000;               ;          ;,0,0"
  v-char-72 =
  "021;00;000;               ;          ;Выдать марок$FinalPointsBalance$ шт.,0,0,4,0,1,0,1,0,22,0,0,0,0,0,1,1,0,4,1,"
  v-char-8 =
  ";,;,;,;,;,;,1;" + fill(" ",40) + ";022;06;000;"
  v-char-9 =
  "               ;          ;________________________MAPOK=$FinalPointsBalance$,0,0"
.

find first buf_dis-gds-rule no-lock where recid(buf_dis-gds-rule) = p-recid no-error .
if not avail buf_dis-gds-rule then return error error-status:get-message(1).

find first buf_dis-rule no-lock
where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num
  and buf_dis-rule.sts = integer({&current-status-int}) /*пересылаются на кассы только действующие правила*/
no-error .
if not avail buf_dis-rule then return error error-status:get-message(1).

find first buf_dis-time-rule no-lock where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error .
if not avail buf_dis-time-rule then return error error-status:get-message(1).

if search (p-out + "gmrecmnt.ctl") = ? then do:
    output stream ibmstream to value( p-out + "gmrecmnt.ctl":U) .
    put unformatted skip.
    output stream ibmstream close.
end.

output stream IBMStream to value(p-out + fname + ".dat") convert target "utf-8" .

/*признак весового товара*/
assign
  v-char-2 = "0,0,0,0,0,0,"
  v-is-weight = false
.
find buf_goods where buf_goods.gds-code = buf_dis-gds-rule.gds-code no-lock no-error.
if avail buf_goods then do:
    find buf_units where buf_units.unit-name = buf_goods.unit-base no-lock no-error.
    if avail buf_units then do:
        if lookup ({&weight}, buf_units.type) > 0 then do:
            /*v-char-2 - если товар весовой, то ставим признак весового товара*/
            assign
              v-char-2    = "0,0,0,2,0,0,"
              v-is-weight = true
            .
        end.
    end.
end.

assign
  v-upd = "D"
  v-ean13 = entry(1, p-attr-value,",")
.
/*5-ти значный весовой баркод переводим в EAN13 #2142*/
if v-is-weight and length(v-ean13) = 5 then do:
    &if defined(ncrsc-pfx) = 0 &then def var ncrsc-pfx as char no-undo init "23":U . &endif    /*настройка кассы NCR - префикс весового кода*/
    &if defined(ncrsc-frmt) = 0 &then def var ncrsc-frmt as char no-undo init "EAN13" . &endif /*вспомог перемен*/
    assign v-tmpchar = "" .
    { str/bc-gnrti.i ncrsc  "decimal(string(integer( v-ean13 ), '99999':U) + '00000':U)"  v-tmpchar }
    if not v-tmpchar = "":U then assign v-ean13 = v-tmpchar .
end.

put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
 p-attr-code v-char-delim-1
 "3,MAPKA,"
 entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
 "0" v-char-delim-1
 entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
 "0" v-char-delim-1
 v-char-1
 v-char-2
 trim(string(buf_dis-rule.doc-qnty,'>>>>9')) v-char-delim-1
 v-char-3
 v-ean13 v-char-delim-2
 v-char-4
 trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
 v-char-5
 v-ean13 v-char-delim-2

 v-char-6 v-char-7 skip.

output stream IBMStream close .

OS-append
    value( p-out + fname + '.dat':U )
    value( p-out + fname + ".pmt":U).
if search(p-out + 'debug.flg') = ? then do:
    OS-delete value( p-out + fname + '.dat':U ).
end.
if search (p-out + "pmt.ctl") = ? then do:
    output stream ibmstream to value( p-out +  "pmt.ctl":U) append .
    put unformatted skip.
    output stream ibmstream close.
end.