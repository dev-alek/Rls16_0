block-level on error undo, throw.
/*

$Revision: 0ec5d11e52eb, 2015, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:05:06 2019 +0300 $
$Workfile: r-plcsht.p $
$Archive: rep/r-plcsht.p $

Показания уровнемера за смену

Автор: Белоусов Илья Александрович
Дата создания: 09/12/07
Author: Ilia Belousov
Creation date: 09/12/07

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: 0ec5d11e52eb, 2015, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:05:06 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-plcsht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-plcsht.p $":U .
define variable vss-description as character no-undo init "Показания уровнемера за смену".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/showinf.i    }
{ cmp/r-page1.i    }
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ gbl/cur-time.i   }
{ gbl/prn-lib.i    }
{ cmp/r-pril.i new }
{ gbl/lineattr.i   }
define variable g#report-num  as integer      no-undo .
{ gbl/paramls.i    }
{ rep/r-plc-xl.i   }


define temp-table tt-doc no-undo
  field rvs-code           like ub.rvs-line.rvs-code
  FIELD obj-type           like ub.rvs-line.obj-type
  FIELD obj-code           like ub.rvs-line.obj-code
  field pl-code            like ub.rvs-line.pl-code
  field gds-code           like ub.rvs-line.gds-code
  FIELD shift-date         like ub.rvs-doc.shift-date
  FIELD shift-num          like ub.rvs-doc.shift-num
  FIELD status_            like ub.rvs-doc.status_
  FIELD fact-order         like ub.rvs-doc.fact-order
  field loc1               like ub.place.loc1
  field state-measure-qnty like ub.rvs-line.state-measure-qnty
  field state-temperature  like ub.rvs-line.state-temperature
  field state-dencity      like ub.rvs-line.state-density
  field average-dencity    as decimal format ">9.9999"
  FIELD fact-date          like ub.rvs-doc.fact-date
  FIELD fact-time          as character
  field gds-name           like ub.goods.gds-name
  field rvs-type           like ub.rvs-doc.rvs-type
  field rvs-type-outside   like ub.rvs-doc.rvs-type
  field state-level-total  like ub.rvs-line.state-level-total
  field attr_              as character

index by-line as primary unique
      rvs-code
      obj-type
      obj-code
      pl-code
      gds-code
index by-type
      rvs-type
      loc1
      gds-code
index by-date
      rvs-type
      fact-date
      fact-time
      loc1
      gds-name
index by-pl
      pl-code
      gds-code
.

  output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
  output close.

define variable v-counter    as integer  FORMAT ">>9"    no-undo.
define variable v-fact-order-start        as decimal              no-undo .
define variable v-fact-order-end          as decimal              no-undo .

DEFINE VARIABLE sym1  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym2  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym3  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym4  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym5  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym6  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym7  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym8  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym9  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym10 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym11 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym12 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
define variable v-line    as character    no-undo.

define variable v-date-begin       as character          no-undo.
define variable v-date-end         as character          no-undo.
define variable v-shift-staff      as character    no-undo.
define variable v-shift-staff-prev as character    no-undo.
define variable v-date-rvs-shift   as character     no-undo.
define variable v-time-rvs-shift   as character     no-undo.


DEFINE STREAM out-stream.

  define frame f-first
    sym1                      no-label format "X(1)"       space(0)
    tt-doc.loc1               no-label format "X(8)"       space(0)
    sym2                      no-label format "X(1)"       space(0)
    tt-doc.state-measure-qnty no-label format "->>,>>9.99" space(0)
    sym3                      no-label format "X(1)"       space(0)
    tt-doc.state-level-total  no-label format "->>>9.99"   space(0)
    sym4                      no-label format "X(1)"       space(0)
    tt-doc.state-temperature  no-label format "->>9.99"    space(0)
    sym5                      no-label format "X(1)"       space(0)
    tt-doc.state-dencity      no-label format ">9.9999"    space(0)
    sym6                      no-label format "X(1)"       space(0)
    tt-doc.average-dencity    no-label format ">9.9999"    space(0)
    sym7                      no-label format "X(1)"       space(0)
  header
    "+--------+----------+--------+-------+-------+-------+" skip
    "|    №   |  объем   | высота | темпе | Плот- | Плот- |" skip
    "| резер- |   (л)    | взлива | рату- | ность | ность |" skip
    "| вуара  |          |  (см)  | ра    |       | сред- |" skip
    "|        |          |        |  (С)  |       | няя   |" skip
  with width 54 down stream-io no-labels no-box.

  define frame f-second
    sym1                      no-label format "X(1)"       space(0)
    v-counter                 no-label format ">>9"        space(0)
    sym2                      no-label format "X(1)"       space(0)
    tt-doc.fact-date          no-label format "99/99/99"   space(0)
    sym3                      no-label format "X(1)"       space(0)
    tt-doc.fact-time          no-label format "X(8)"       space(0)
    sym4                      no-label format "X(1)"       space(0)
    tt-doc.loc1               no-label format "x(8)"       space(0)
    sym5                      no-label format "X(1)"       space(0)
    tt-doc.gds-name           no-label format "x(10)"      space(0)
    sym6                      no-label format "X(1)"       space(0)
    tt-doc.rvs-type-outside   no-label format "x(10)"      space(0)
    sym7                      no-label format "X(1)"       space(0)
    tt-doc.state-measure-qnty no-label format "->>,>>9.99" space(0)
    sym8                      no-label format "X(1)"       space(0)
    tt-doc.state-level-total  no-label format "->>9.99"    space(0)
    sym9                      no-label format "X(1)"       space(0)
    tt-doc.state-temperature  no-label format "->9.99"     space(0)
    sym10                     no-label format "X(1)"       space(0)
    tt-doc.state-dencity      no-label format "9.9999"     space(0)
    sym11                     no-label format "X(1)"       space(0)
    tt-doc.attr_              no-label format "x(150)"     space(0)
    sym12                     no-label format "X(1)"       space(0)
  header
    "+---+--------+--------+--------+----------+----------+----------+-------+------+------+------------------------------------------------------------------------------------------------------------------------------------------------------+" SKIP
    "|   |        |        |   №    |          | расшиф-  |          | Высота| Тем- | Плот-|     Данные ТТН Компания - перевозчик, № а/м,                                                                                                         |" SKIP
    "|   |        |        | резер- |   вид    | ровка    |   Объем  | взлива| пера-| ность|       ФИО водителя, плотность, температура,                                                                                                          |" SKIP
    "| № | Дата   | Время  | вуара  | топлива  | показа-  |    (л)   |  (см) | тура |      |              масса, объем (по ТТН)                                                                                                                   |" SKIP
    "|   |        |        |        |          | ний      |          |       |  (С) |      |                                                                                                                                                      |" SKIP

  with width 240 down stream-io no-labels no-box.





/*==========================================================================*/
procedure prev-shift :
define input parameter p-obj-type   like  ub.rvs-doc.obj-type no-undo .
define input parameter p-obj-code   like  ub.rvs-doc.obj-code no-undo .
define input parameter p-shift-date like  ub.rvs-doc.shift-date no-undo .
define input parameter p-shift-num  like  ub.rvs-doc.shift-num no-undo .
define output parameter p-fact-order like ub.rvs-doc.fact-order init ? no-undo .

define buffer prev_shift-obj  for ub.shift-obj .
define buffer prev_rvs-doc    for ub.rvs-doc .
define buffer buf_shift-staff for ub.shift-staff.

do
on error undo, return error
:
   find last  prev_shift-obj
        where prev_shift-obj.obj-type = p-obj-type
          and prev_shift-obj.obj-code = p-obj-code
          and prev_shift-obj.status_  = {&sht-closed}
          and ( prev_shift-obj.shift-date < p-shift-date
                or
               ( prev_shift-obj.shift-date = p-shift-date
                 and
                 prev_shift-obj.shift-num  < p-shift-num
               )
              )
   use-index stts
   no-lock
   no-error.
   if available prev_shift-obj then do:
      /* Персонал предыдущей смены */
      FOR each  buf_shift-staff
         where buf_shift-staff.obj-type    = prev_shift-obj.obj-type
            and buf_shift-staff.obj-code   = prev_shift-obj.obj-code
            and buf_shift-staff.shift-date = prev_shift-obj.shift-date
            and buf_shift-staff.shift-num  = prev_shift-obj.shift-num
            and buf_shift-staff.psn-num   >= 0
            no-lock
            :
         assign
            v-shift-staff-prev = v-shift-staff-prev + ", " + buf_shift-staff.name
         .
      end.
      assign
         v-shift-staff-prev = TRIM(v-shift-staff-prev, ",")
      .

      find first prev_rvs-doc
         where prev_rvs-doc.obj-type    = prev_shift-obj.obj-type
            and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
            and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
            and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
            and prev_rvs-doc.status_    = {&fact}
            and prev_rvs-doc.rvs-type   = {&rvs-shift}
         no-lock
         no-error.
      if available prev_rvs-doc then do:
         assign
            p-fact-order = prev_rvs-doc.fact-order
         .
      end.
   end.
end.
end procedure. /* prev-shift */



/*==========================================================================*/
procedure fill-doc :

define buffer buf_rvs-line    for ub.rvs-line .
define buffer buf_rvs-doc     for ub.rvs-doc  .
define buffer buf_place       for ub.place .
define buffer buf_goods       for ub.goods .
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_doc-line    for ub.doc-line.
define buffer buf_clients     for ub.clients.
define buffer buf_tt-doc      for tt-doc.
define buffer buf_shift-staff for ub.shift-staff.
define buffer buf_shift-obj   for ub.shift-obj.

define variable v-coordl    as character    no-undo .
define variable v-attr      as character    no-undo .
define variable v-pl-code   as integer      no-undo.
define variable v-fact-order-begin like ub.rvs-doc.fact-order init ? no-undo .
define variable v-fact-order-end   like ub.rvs-doc.fact-order init ? no-undo .
define variable v-density-av    as decimal      no-undo.

DEFINE VARIABLE v-type         AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-autoent-code AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-autoent-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-car-num      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fio          AS CHARACTER NO-UNDO.
define variable v-autoent-name as character no-undo.
DEFINE VARIABLE v-exist AS LOGICAL   NO-UNDO.
define variable v-loc    as character    no-undo.

do
on error undo, return error
:
   /* только текущий объект */
   find first obj-list
        no-lock
        no-error
        .
   if not available obj-list then do:
      message
         "Не определен объект для формирования отчета"
      view-as alert-box information .
      return error.
   end.

   /* проверяем сверку закрытия смены */
   find first buf_rvs-doc
         where  buf_rvs-doc.obj-type   = obj-list.obj-type
            and buf_rvs-doc.obj-code   = obj-list.obj-code
            and buf_rvs-doc.shift-date = X-date-Start
            and buf_rvs-doc.shift-num  = X-shift-Alone
            and buf_rvs-doc.status_    = {&fact}
            and   buf_rvs-doc.rvs-type   = {&rvs-shift}
         no-lock
         no-error
         .
   IF available buf_rvs-doc then do:
      assign
         v-fact-order-end = buf_rvs-doc.fact-order
         v-date-rvs-shift = STRING(buf_rvs-doc.fact-date, "99/99/99")
         v-time-rvs-shift = STRING(buf_rvs-doc.fact-time, "HH:MM:SS")
      .
   end.
   ELSE do:
      assign
         v-date-rvs-shift = "Не закрыта"
      .
   end.

   /* даты смены */
   find first buf_shift-obj
        where buf_shift-obj.obj-type   = obj-list.obj-type
          and buf_shift-obj.obj-code   = obj-list.obj-code
          and buf_shift-obj.shift-date = X-date-Start
          and buf_shift-obj.shift-num  = X-shift-Alone
   no-lock
   no-error
   .
   IF NOT AVAILABLE buf_shift-obj then do:
      MESSAGE SUBSTITUTE("Неправильно выбрана смена: &1, &2, &3, &4",
               X-shift-Alone
               , X-date-Start
               , obj-list.obj-type
               , obj-list.obj-code
               )
      view-as alert-box error         .
      return error.
   end.
   Assign
      v-date-begin = IF buf_shift-obj.open-date = ?  then "Не открыта" else STRING(buf_shift-obj.open-date,  "99/99/99")
      v-date-end   = IF buf_shift-obj.close-date = ? then "Не закрыта" else STRING(buf_shift-obj.close-date, "99/99/99")
   .

   /* Персонал текущей смены */
   FOR each  buf_shift-staff
       where buf_shift-staff.obj-type   = obj-list.obj-type
         and buf_shift-staff.obj-code   = obj-list.obj-code
         and buf_shift-staff.shift-date = X-date-Start
         and buf_shift-staff.shift-num  = X-shift-Alone
         and buf_shift-staff.psn-num       >= 0
       no-lock
       :
       assign
         v-shift-staff = v-shift-staff + ", " + buf_shift-staff.name
       .
   end.
   assign
      v-shift-staff = TRIM(v-shift-staff, ",")
   .

   /* ищем предыдущую смену */
   run prev-shift in this-procedure ( input  obj-list.obj-type
                                    , input  obj-list.obj-code
                                    , input  X-date-Start
                                    , input  X-shift-Alone
                                    , output v-fact-order-begin
                                    ) .


   /* текущая смена не закрыта */
   IF v-fact-order-end = ?
   then do:
      /* единственная смена на объекте ВООБЩЕ */
      IF v-fact-order-begin = ?
      then do:
         for each  buf_rvs-doc
            where buf_rvs-doc.obj-type     = obj-list.obj-type
               and buf_rvs-doc.obj-code     = obj-list.obj-code
               AND buf_rvs-doc.status_      = {&fact}
            no-lock
            :
            { rep/r-plcsht.i }
            end. /* each buf_rvs-line.*/
         end. /* each buf_rvs-doc */
      end. /* -- */
      else do:
         for each  buf_rvs-doc
            where buf_rvs-doc.obj-type     = obj-list.obj-type
               and buf_rvs-doc.obj-code     = obj-list.obj-code
               AND buf_rvs-doc.status_      = {&fact}
               AND buf_rvs-doc.fact-order  >  v-fact-order-begin
            no-lock
            :
            { rep/r-plcsht.i }
            end. /* each buf_rvs-line.*/
         end. /* each buf_rvs-doc */
      end. /* +- */
   end.
   /* текущая смена закрыта */
   else do:
      /* первая смена на объекте ВООБЩЕ */
      IF v-fact-order-begin = ?
      then do:
         for each  buf_rvs-doc
            where buf_rvs-doc.obj-type     = obj-list.obj-type
               and buf_rvs-doc.obj-code     = obj-list.obj-code
               AND buf_rvs-doc.status_      = {&fact}
               AND buf_rvs-doc.fact-order  <= v-fact-order-end
            no-lock
            :
            { rep/r-plcsht.i }
            end. /* each buf_rvs-line.*/
         end. /* each buf_rvs-doc */
      end. /* -+ */
      else do:
         for each  buf_rvs-doc
            where buf_rvs-doc.obj-type     = obj-list.obj-type
               and buf_rvs-doc.obj-code     = obj-list.obj-code
               AND buf_rvs-doc.status_      = {&fact}
               AND buf_rvs-doc.fact-order  >  v-fact-order-begin
               AND buf_rvs-doc.fact-order  <= v-fact-order-end
            no-lock
            :
            { rep/r-plcsht.i }
            end. /* each buf_rvs-line.*/
         end. /* each buf_rvs-doc */
      end. /* ++ */
   end.

   assign
      v-counter = 0
   .
   for each tt-doc
/*       where  tt-doc.rvs-type   <> {&rvs-shift} */
       break
       by tt-doc.pl-code
       by tt-doc.gds-code
   :
      assign
         v-counter    = v-counter + 1
         v-density-av = v-density-av + tt-doc.state-dencity
      .
      IF LAST-OF(tt-doc.gds-code) then do:
         find first buf_tt-doc
            where buf_tt-doc.rvs-type = {&rvs-shift}
               and buf_tt-doc.pl-code  = tt-doc.pl-code
               and buf_tt-doc.gds-code = tt-doc.gds-code
            no-lock
            no-error.
         IF AVAILABLE buf_tt-doc then do:
            assign
               buf_tt-doc.average-dencity = v-density-av / v-counter
               v-density-av = 0
               v-counter    = 0
            .
         end.
         else do:
            assign
               v-density-av = 0
               v-counter    = 0
            .
         end.
      end. /* last-of */
   end.
end. /* do on error */
end procedure. /* fill-doc */



/*==========================================================================*/
procedure print-body :

do
on error undo, return error
:
   assign
      v-counter = 0
   .
   for each tt-doc
       where  tt-doc.rvs-type   = {&rvs-shift}
       use-index by-type
   :
      v-counter = v-counter + 1.
      display stream out-stream
         tt-doc.loc1
         tt-doc.state-measure-qnty
         tt-doc.state-level-total
         tt-doc.state-temperature
         tt-doc.state-dencity
         tt-doc.average-dencity
         sym1  sym2  sym3  sym4  sym5  sym6  sym7
      with frame f-first.
      down stream out-stream 1 with frame f-first
      .
      run r-plc-xl-sheet1-write-line-data in this-procedure (
           input tt-doc.loc1
         , input tt-doc.state-measure-qnty
         , input tt-doc.state-level-total
         , input tt-doc.state-temperature
         , input tt-doc.state-dencity
         , input tt-doc.average-dencity
      ) .

   end.
   IF v-counter = 0 then do:
      display stream out-stream
         "не закр." @ tt-doc.loc1
         sym1  sym2  sym3  sym4  sym5  sym6  sym7
      with frame f-first.
      down stream out-stream 1 with frame f-first
      .
   end.

   put stream out-stream unformatted fill( "-" , 54 ) skip.

   assign
      v-counter = 0
   .
   for each tt-doc
       where  tt-doc.rvs-type   <> {&rvs-shift}
       use-index by-date
   :
      v-counter = v-counter + 1.
      display stream out-stream
              v-counter
         tt-doc.fact-date
         tt-doc.fact-time
         tt-doc.loc1
         tt-doc.gds-name
         tt-doc.rvs-type-outside
         tt-doc.state-measure-qnty
         tt-doc.state-level-total
         tt-doc.state-temperature
         tt-doc.state-dencity
         tt-doc.attr_
         sym1  sym2  sym3  sym4  sym5  sym6
         sym7  sym8  sym9  sym10 sym11 sym12
      with frame f-second.
      down stream out-stream 1 with frame f-second
      .
      run r-plc-xl-sheet2-write-line-data in this-procedure (
           input      v-counter
         , input tt-doc.fact-date
         , input tt-doc.fact-time
         , input tt-doc.loc1
         , input tt-doc.gds-name
         , input tt-doc.rvs-type-outside
         , input tt-doc.state-measure-qnty
         , input tt-doc.state-level-total
         , input tt-doc.state-temperature
         , input tt-doc.state-dencity
         , input tt-doc.attr_
      ).
   end.
   IF v-counter <> 0 then do:
      put stream out-stream unformatted fill( "-" , 238 ) skip.
   end.

end.
end procedure. /* print-body */



/*==========================================================================*/
procedure print-header :

do
on error undo, return error
:
   put stream out-stream
      "ПОКАЗАНИЯ УРОВНЕМЕРА ЗА СМЕНУ" at 25 skip(1)

      "АЗС № " obj-list.obj-type obj-list.obj-code skip
      "Сменный отчет № " X-date-Start X-shift-Alone SKIP
      "Операторы (текущая смена): " v-shift-staff FORMAT "x(100)" skip
      "Операторы (предыдущая смена): " v-shift-staff-prev FORMAT "x(100)" SKIP
      "Дата с " v-date-begin " по " v-date-end FORMAT "x(70)" skip
      "Дата - время передачи смены: "  v-date-rvs-shift FORMAT "x(10)" " " v-time-rvs-shift SKIP(1)
   .
   run r-plc-xl-write-cell-data in this-procedure ( input {&r-plc-xl-objname},    input Substitute("&1&2", obj-list.obj-type, obj-list.obj-code) ).
   run r-plc-xl-write-cell-data in this-procedure ( input {&r-plc-xl-rep_num},    input Substitute("&1&2", X-date-Start, X-shift-Alone) ).
   run r-plc-xl-write-cell-data in this-procedure ( input {&r-plc-xl-staff},      input v-shift-staff ).
   run r-plc-xl-write-cell-data in this-procedure ( input {&r-plc-xl-staff_prev}, input v-shift-staff-prev ).
   run r-plc-xl-write-cell-data in this-procedure ( input {&r-plc-xl-date_begin}, input v-date-begin ).
   run r-plc-xl-write-cell-data in this-procedure ( input {&r-plc-xl-date_end},   input v-date-end ).
   run r-plc-xl-write-cell-data in this-procedure ( input {&r-plc-xl-f_date},     input v-date-rvs-shift ).
   run r-plc-xl-write-cell-data in this-procedure ( input {&r-plc-xl-f_time},     input v-time-rvs-shift ).

end.
end procedure. /* print-header */



procedure get-doc-line-attr :
define input parameter p-doc-code               as character        no-undo.
define input parameter p-gds-code               as integer          no-undo.
define input parameter p-attr-code              as character        no-undo.
define output parameter p-attr-value-character  as character        no-undo.
define output parameter p-attr-exists           as logical          no-undo.

    define buffer buf_doc-line-attr for ub.doc-line-attr.
do
on error undo, return error
:
    find first buf_doc-line-attr no-lock
         where buf_doc-line-attr.doc-code    = p-doc-code
           and buf_doc-line-attr.gds-code    = p-gds-code
           and buf_doc-line-attr.attr-code   = p-attr-code
    no-error.
    if available buf_doc-line-attr
    then do:
        assign
            p-attr-value-character = buf_doc-line-attr.attr-value
            p-attr-exists          = yes
        .
    end.
    else do:
        assign
            p-attr-exists          = no
        .
    end.
end.
end procedure. /* get-doc-line-attr */



/*********************************************************************************
   MAIN BLOCK

**********************************************************************************/
do
   on error  undo , return error return-value
   on endkey undo , return error return-value
   on stop   undo , return error return-value
   :

   { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
   { rep/repfrm.i on 100 } /* Показать окно информации о текущем процессе */

   /* выборка документов */
   run fill-doc in this-procedure .

   { gbl/working.i }
   /* открываем поток текстового вывода */
   run get-report-num in my-handle (output g#report-num).
   { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
   RUN r-plc-xl-init IN THIS-PROCEDURE.

   /*  печатаем шапку */
   RUN print-header IN THIS-PROCEDURE .

   /* печать отчета*/
   run print-body in this-procedure .

   /* закрываем потоки */
   output stream out-stream close.
   RUN r-plc-xl-close IN THIS-PROCEDURE .
   { rep/repfrm.i off }

   /* передаем управление пользователю */
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
   os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
   .
   define variable v-user-action   as character no-undo .
   define variable v-printed       as logical   no-undo .
   run gbl/prnfilen.w
         ( input  ""
         , input  8
         , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
         , input  ReportFontNum
         , output v-user-action
         , output v-printed
         ) .
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

   empty temp-table tt-doc.
   { gbl/stopwork.i }

END. /* DO ON ERROR */
/*********************************************************************************
   END OF MAIN BLOCK

**********************************************************************************/