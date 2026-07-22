/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для вывода в файл скидок NCR

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/05
Author: Bakhtadze Natalya
Creation date: 04/12/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" <> "proc-create" &then

define {1} temp-table cash-ncr-dis-kat no-undo
field cd-subject-code as character
field cd-subject-name as character
field dis-kat    like ub.dis-rule.dis-kat
field rule-num   like ub.dis-rule.rule-num
field time-rule-num like ub.dis-rule.time-rule-num
field crf as integer
field subject-code   as character
FIELD cd-disc-string    as character
field cd-other  as character
index pi is unique primary crf
index isubject cd-subject-code dis-kat
index idiskat dis-kat cd-subject-code cd-disc-string
.

define temp-table temp-dis-kat-file no-undo
field temp-file as character
field send-file as character
field to-send as logical
field dis-kat as integer
index pi is unique primary dis-kat
index isend to-send
.

define temp-table cash-ncr-save-param no-undo
field cd-line as character
field cd-other as character
field dis-kat as integer
index pi is unique primary dis-kat cd-line
.

 define variable v-found-good as log no-undo .
 define variable i-host-code as int no-undo .



&endif
&if "{1}" = "proc-create" &then
procedure create-ncr-kat-discnt :
/*обновление файлов s_plurbt.dat и group_xx.dat данными о категорийных скидках*/
define input parameter p-subject-code as character no-undo .
define input parameter p-cd-subject-code as character no-undo .
define input parameter p-subject-name as character no-undo .
define input parameter p-dis-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define input parameter p-tree as character no-undo .
define input parameter p-discnt as decimal no-undo .

define variable v-dis-rule-num as integer no-undo .
define variable v-tree as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-dis-kat as integer   no-undo .

define buffer buf_cash-dis-rule for cash-dis-rule.
define buffer buf_cash-dis-time-rule for cash-dis-time-rule.
define buffer slave_cash-dis-rule for cash-dis-rule.

  do
  on error undo, return error
  :
    v-discnt = p-discnt.
    if p-dis-rule-num > 0 then do:

      find first buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.rule-num = p-dis-rule-num no-error.
      if not available buf_cash-dis-rule
      or (buf_cash-dis-rule.templ-rl-root <> p-templ-rl-root
         and
         p-templ-rl-root <> ?)
      then do:
        return error .
      end.
      if p-templ-rl-root = ? then do:
        p-templ-rl-root = buf_cash-dis-rule.templ-rl-root.
      end.
      if buf_cash-dis-rule.uniq-field = ''
      or buf_cash-dis-rule.is-term
      then do:
        v-tree = no.
        v-dis-rule-num = buf_cash-dis-rule.upper-rule-num.
      end.
      if buf_cash-dis-rule.time-rule-num > 0 then do:
        find first buf_cash-dis-time-rule no-lock where
                buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
        if not available buf_cash-dis-time-rule then do:
          return error .
        end.
        release buf_cash-dis-time-rule.
      end.
        _buf-cash-dis-rule:
        for each buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.upper-rule-num = (if v-tree then p-dis-rule-num else v-dis-rule-num):
          if not v-tree then do:
            find first slave_cash-dis-rule no-lock where
                slave_cash-dis-rule.rule-num = v-dis-rule-num .

            assign v-dis-kat = slave_cash-dis-rule.dis-kat .

            if buf_cash-dis-rule.rule-num <> p-dis-rule-num then next _buf-cash-dis-rule.
          end.
          else
           do:
             assign v-dis-kat = buf_cash-dis-rule.dis-kat .
           end .
          if buf_cash-dis-rule.time-rule-num > 0 then do:
            find first buf_cash-dis-time-rule no-lock where
                      buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
            if not available buf_cash-dis-time-rule then next _buf-cash-dis-rule.
          end.
          FIND FIRST cash-ncr-dis-kat where
                  cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
          if not avail cash-ncr-dis-kat then do:
            create cash-ncr-dis-kat.
            error-status:error = false.
          end.
          cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
          cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
          &if "{2}" <> "no-gds" &then
          if buf_cash-dis-rule.value-type = integer({&discnt-v-pdf-fp}) then do:
            find first cash-gds-discnt where
                      cash-gds-discnt.b-code = integer(p-subject-code)
                  and  cash-gds-discnt.rule-num = buf_cash-dis-rule.rule-num
                  and cash-gds-discnt.obj-type = {&shop}
                  and cash-gds-discnt.obj-code = i-obj-code
                  no-error.
            if available cash-gds-discnt then do:
              assign
              v-discnt = cash-gds-discnt.discnt-value
              .
            end.
            else do:
              /*внутри увидим*/
              v-discnt = p-discnt.
            end.
          end.
          &endif
          assign
          cash-ncr-dis-kat.subject-code  =  p-subject-code
          cash-ncr-dis-kat.cd-subject-code  =  p-cd-subject-code
          cash-ncr-dis-kat.cd-subject-name  =  SUBSTRING(p-subject-name, 1, 20)
          cash-ncr-dis-kat.cd-subject-name  =  SUBSTRING(p-subject-name, 1, 20) +
                                             ( if length(p-subject-name) < 20 then fill( {&space-char} , 20 - length(p-subject-name) ) else '' )
          cash-ncr-dis-kat.dis-kat =  (if v-dis-kat < 0 then 0 else v-dis-kat)
          cash-ncr-dis-kat.rule-num = buf_cash-dis-rule.rule-num
          cash-ncr-dis-kat.time-rule-num = buf_cash-dis-rule.time-rule-num
          cash-ncr-dis-kat.cd-disc-string   = "****":U  +
                                          (if buf_cash-dis-rule.templ-rl-root = 89
                                           then '80'
                                           else (if buf_cash-dis-rule.discnt-value > 0
                                                 then '80':U
                                                 else '00':U)
                                           )
          .
          if p-tree = 'time-rule-num':U then do:
            if available buf_cash-dis-time-rule
            and buf_cash-dis-time-rule.value-type <> {&dtr-t-unknown}
            then do:
              assign
              cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
                                            (if buf_cash-dis-time-rule.value-type = {&dtr-t-date-period}
                                              then
                                              ("D":U + substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 9, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 4, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 1, 2) +
                                                      "-":U +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 9, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 4, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 1, 2)
                                              )
                                              else
                                              ("T00":U +
                                                        (if buf_cash-dis-time-rule.week-day-0  then "0" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-1  then "2" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-2  then "3" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-3  then "4" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-4  then "5" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-5  then "6" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-6  then "7" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-7  then "1" else "":U) +
                                                      {&slash-char} +
                                                      replace(string(buf_cash-dis-time-rule.time-from, "HH:MM"), ':':U, '':U) + "-":U +
                                                      replace(string(buf_cash-dis-time-rule.time-to, "HH:MM"), ':':U, '':U)
                                              )
                                            )
              .
            end.
            else do:
              assign
              cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string + "D000101-991231":U
              .
            end.
          end.
          if p-tree = 'tot-sum':U then do:
            assign
            cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
            '>' + replace(string(round(buf_cash-dis-rule.tot-sum, 2), '99999999999.99'), '.':u , '':U)
            .
          end.
          assign
          cash-ncr-dis-kat.cd-other =   fill({&space-char}, 10) +  "xx ":U +
                                        (if buf_cash-dis-rule.value-type = integer({&discnt-v-pdf-fp})
                                         or buf_cash-dis-rule.value-type = integer({&discnt-v-fp})
                                        then "=":U
                                        else "%":U) +
                                        replace(string(abs(if v-discnt <> ? then v-discnt else buf_cash-dis-rule.discnt-value),"9999999.9"), '.':U, '':U)
          .
        end.
    end. /*p-dis-rule-num > 0*/
    else do:
      FIND FIRST cash-ncr-dis-kat where
              cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
      if not avail cash-ncr-dis-kat then do:
      create cash-ncr-dis-kat.
      error-status:error = false.
      end.
      cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
      cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
      assign
      cash-ncr-dis-kat.subject-code  = p-subject-code
      cash-ncr-dis-kat.cd-subject-code  = p-cd-subject-code
      cash-ncr-dis-kat.cd-subject-name  = p-subject-name
      cash-ncr-dis-kat.dis-kat =  - 1
      cash-ncr-dis-kat.rule-num = 0
      cash-ncr-dis-kat.time-rule-num = 0
      .
    end.

  end.

end procedure. /* create-ncr-kat-discnt */

                                   /*  бонусы фишки марки на кассу  90,91,92  templ-rl-root     */
procedure output-ncr-bonus:

define input parameter i-host-code as integer no-undo .
define input parameter i-obj-code  as integer no-undo .
define input parameter out         as character no-undo .
define output parameter fname      as character no-undo .

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
def var v-today         as date no-undo .

def buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr.
def buffer buf_dis-gds-rule      for ub.dis-gds-rule .
def buffer chk_dis-gds-rule      for ub.dis-gds-rule .
def buffer buf_dis-thbj-rule     for ub.dis-thbj-rule .
def buffer buf_dis-rule          for ub.dis-rule .
def buffer buf_dis-time-rule     for ub.dis-time-rule .
def buffer buf_prod-bc           for ub.prod-bc .
def buffer buf_bar-code          for ub.bar-code .
def buffer buf_units             for ub.units .
def buffer buf_goods             for ub.goods .
def buffer buf_gds-obj           for ub.gds-obj .

assign
    fname = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 ).

assign
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

{ gbl/curobjdt.i {&shop} i-obj-code v-today }

 output stream IBMStream to value(out + fname + ".dat") convert target "utf-8"  .

 /*начало*/
 _buf_dis-gds-rule:
 for each buf_dis-gds-rule no-lock
 where buf_dis-gds-rule.templ-rl-root = 91      /* бонус на кол-во баркод */
   and buf_dis-gds-rule.pos-type = {&cd-type-ncr-as-r}
   &if "{2}" = "gds" &then
      and can-find(first cash-gds where cash-gds.gds-code = buf_dis-gds-rule.gds-code)
   &endif ,
   first buf_dis-rule no-lock
   where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num
     and buf_dis-rule.sts = integer({&current-status-int}), /*пересылаются на кассы только действующие правила*/
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
    and buf_dis-time-rule.date-to >= v-today  /*не выгружать просроченные скидки*/
      :
       /*проверим приоритетность правил*/
       if buf_dis-gds-rule.obj-type = "" and buf_dis-gds-rule.obj-code = 0 then do: /*глобальное, но есть фирменное или объектное*/
           find first chk_dis-gds-rule no-lock
           where chk_dis-gds-rule.gds-code = buf_dis-gds-rule.gds-code and
                 chk_dis-gds-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root and
                 chk_dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type and
              (( chk_dis-gds-rule.obj-type = {&cmp}  and chk_dis-gds-rule.obj-code = i-host-code ) or
               ( chk_dis-gds-rule.obj-type = {&shop} and chk_dis-gds-rule.obj-code = i-obj-code  )) no-error .
           if avail chk_dis-gds-rule then next _buf_dis-gds-rule .
       end.
       if buf_dis-gds-rule.obj-type = {&cmp} and buf_dis-gds-rule.obj-code = i-host-code then do: /*фирменное, но есть объектное*/
           find first chk_dis-gds-rule no-lock
           where chk_dis-gds-rule.gds-code = buf_dis-gds-rule.gds-code and
                 chk_dis-gds-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root and
                 chk_dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type and
                 chk_dis-gds-rule.obj-type = {&shop} and
                 chk_dis-gds-rule.obj-code = i-obj-code no-error .
           if avail chk_dis-gds-rule then next _buf_dis-gds-rule .
       end.

       /*проверяем есть ли у объекта такой товар*/
       find first buf_gds-obj no-lock
       where buf_gds-obj.gds-code = buf_dis-gds-rule.gds-code
         and buf_gds-obj.obj-type = {&shop}
         and buf_gds-obj.obj-code = i-obj-code
       no-error.
       if avail buf_gds-obj and
         (( buf_dis-gds-rule.obj-type = ""      and buf_dis-gds-rule.obj-code = 0) or
          ( buf_dis-gds-rule.obj-type = {&cmp}  and buf_dis-gds-rule.obj-code = i-host-code) or
          ( buf_dis-gds-rule.obj-type = {&shop} and buf_dis-gds-rule.obj-code = i-obj-code))
       then do:

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

          _bdr-attr:
    for each  buf_dis-gds-rule-attr WHERE
             buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
         AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
         AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
         AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
         AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
         and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                  :
           assign
     v-upd = entry(2,buf_dis-gds-rule-attr.attr-value,",")     /*  A-добавить  D- удалить     */
             v-ean13 = entry(1,buf_dis-gds-rule-attr.attr-value,",")
     .
           /*5-ти значный весовой баркод переводим в EAN13 #2142*/
           if v-is-weight and length(v-ean13) = 5 then do:
               &if defined(ncrsc-pfx) = 0 &then def var ncrsc-pfx as char no-undo init "23":U . &endif    /*настройка кассы NCR - префикс весового кода*/
               &if defined(ncrsc-frmt) = 0 &then def var ncrsc-frmt as char no-undo init "EAN13" . &endif /*вспомог перемен*/
               assign v-tmpchar = "" .
               { str/bc-gnrti.i ncrsc  "decimal(string(integer( v-ean13 ), '99999':U) + '00000':U)"  v-tmpchar }
               if not v-tmpchar = "":U then assign v-ean13 = v-tmpchar .
           end.

           /*заглушка для NCR чтобы не передавались на кассу основные баркоды (20) по просьбе Вороного*/
           if v-ean13 begins "20" and length(v-ean13) = 13 then next _bdr-attr .

     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-gds-rule-attr.attr-code v-char-delim-1
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
    end.

   end.
 end. /*for each buf_dis-gds-rule*/


 for each buf_dis-thbj-rule no-lock where buf_dis-thbj-rule.templ-rl-root = 90
                   and buf_dis-thbj-rule.pos-type = {&cd-type-ncr-as-r},
    first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
    and buf_dis-rule.sts = integer({&current-status-int}), /*пересылаются на кассы только действующие правила*/
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
        and buf_dis-time-rule.date-to >= v-today  /*не выгружать просроченные скидки*/
      :
   if (buf_dis-thbj-rule.obj-type = "" and
       buf_dis-thbj-rule.obj-code = 0) or
      (buf_dis-thbj-rule.obj-type = {&cmp} and
       buf_dis-thbj-rule.obj-code = i-host-code) or
      (buf_dis-thbj-rule.obj-type = {&shop} and
       buf_dis-thbj-rule.obj-code = i-obj-code)
   then
   do:
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-rule.key#_one v-char-delim-1
      "3,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-21
      "9,0,0,"
      trim(string(buf_dis-rule.tot-sum * 100,">>>>>>>>>9")) v-char-delim-1
      v-char-3
      v-char-41
      trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
      v-char-5
       v-char-delim-2

      v-char-61 v-char-71 skip.

   end.
 end.

 for each buf_dis-thbj-rule no-lock where buf_dis-thbj-rule.templ-rl-root = 92
                   and buf_dis-thbj-rule.pos-type = {&cd-type-ncr-as-r},
    first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
    and buf_dis-rule.sts = integer({&current-status-int}), /*пересылаются на кассы только действующие правила*/
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
        and buf_dis-time-rule.date-to >= v-today  /*не выгружать просроченные скидки*/
      :
   if (buf_dis-thbj-rule.obj-type = "" and
       buf_dis-thbj-rule.obj-code = 0) or
      (buf_dis-thbj-rule.obj-type = {&cmp} and
       buf_dis-thbj-rule.obj-code = i-host-code) or
      (buf_dis-thbj-rule.obj-type = {&shop} and
       buf_dis-thbj-rule.obj-code = i-obj-code)
   then
   do:
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-rule.key#_one v-char-delim-1
      "4,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-21
      "4,1,0,"
      "1" v-char-delim-1
      v-char-3
      v-char-42
      "0" v-char-delim-1
      v-char-5
       v-char-delim-2

      v-char-62 v-char-72 v-char-8 v-char-9 skip.

   end.
 end.
 output stream IBMStream close .
end procedure .


&endif

/* $Workfile$ e n d */