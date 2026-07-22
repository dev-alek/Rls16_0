/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать весовых товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE ProcPricePrint{1}.
define input parameter par-print-option as character no-undo .
define parameter buffer locked_scales for ub.scales.
define variable print-mode as char init "bar"   no-undo . /* may be : plu, bar, price, name */

define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.

define variable Line   as char              no-undo.
define variable bar_code as char              no-undo.
define variable obj-attr as char              no-undo.
define variable price as char no-undo .
define variable g#report-num as integer no-undo .
define variable v-type as character no-undo .
DEFINE BUFFER buf_gds-obj-attr FOR ub.gds-obj-attr.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_prod-bc{1} FOR ub.prod-bc{1}.
&if "{1}" = "-db" &then
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
&endif
DEFINE BUFFER buf_scales-gds FOR ub.scales-gds.
define buffer buf_bar-code for ub.bar-code.

DEFINE FRAME List-PLU
sym1 column-label ":" format "x(1)"
buf_scales-gds.PLU-code column-label "PLU" format ">>>9"
v-type COLUMN-LABEL "Тип" format "x(3)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)" space(2)
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width {&A4_CW} down use-text stream-io no-box.

DEFINE FRAME List-BAR
sym1 column-label ":" format "x(1)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)"
buf_scales-gds.PLU-code column-label "PLU" format ">>>9" space(2)
v-type COLUMN-LABEL "Тип" format "x(3)"
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width {&A4_CW} down use-text stream-io no-box.

DEFINE FRAME List-NAME
sym1 column-label ":" format "x(1)"
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)" space(2)
buf_scales-gds.PLU-code column-label "PLU" format ">>>9"
v-type COLUMN-LABEL "Тип" format "x(3)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width {&A4_CW} down use-text stream-io no-box.

Line = fill( "-" , 103 ) .
run ref/scprmode.w ( output print-mode ) .
if print-mode = "отказ" then
    return error .

run waitfram-show in this-procedure ( input "ЖДИТЕ.  Список подготавливается к печати...").
run get-report-num  in parParentProc(output g#report-num).
CASE par-print-option:
  when "scalesman" then do:
    output stream PrnLibStream to value( string( session:temp-directory +
                                        {&DF_Name} + string( g#report-num ) ) )
                                        page-size 24 .
  end.
  when "normal" then dO:
    output stream PrnLibStream to value( string( session:temp-directory +
                                        {&DF_Name} + string( g#report-num ) ) )
                                        page-size {&CS_PS} .
  end.
end CASE.
FORM HEADER
    Line format "x(103)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 10 SKIP
    with FRAME CliBottomFrame width 103 PAGE-BOTTOM use-text stream-io NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream
substitute( "СПИСОК  КОДОВ  на весах N &1 (БД &2) / &3"
           ,locked_scales.scales-num
           ,locked_scales.db-num
           ,locked_scales.scales-name ) format "x(103)" SKIP.
CASE print-mode :
  when "plu" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по коду на весах )" SKIP.
    FORM with frame List-PLU .
    FOR EACH buf_scales-gds WHERE
           buf_scales-gds.db-num = locked_scales.db-num AND
           buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
&if "{1}" = "-db" &then
      BY buf_scales-gds.PLU-code :
        find FIRST buf_prod-bc{1} no-lock WHERE
              buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
          and buf_prod-bc{1}.db-num = locked_scales.db-num  no-error.
       if not available buf_prod-bc{1} then do:
         find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
              and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
         if not available buf_prod-bc then next.
       end.
&else
        , FIRST buf_prod-bc{1} no-lock WHERE
              buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
        BY buf_scales-gds.PLU-code :
&endif
        { ref/scales-p.i List-PLU {1} }
    END.
  end.
  when "bar" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по весовому коду )" SKIP.
    FORM with frame List-BAR .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
&if "{1}" = "-db" &then
        BY buf_gds-obj-attr.attr-value :
       find  FIRST buf_prod-bc{1} no-lock WHERE
              buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
          and buf_prod-bc{1}.db-num = locked_scales.db-num no-error.
       if not available buf_prod-bc{1} then do:
         find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
              and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
         if not available buf_prod-bc then next.
       end.
&else
      , FIRST buf_prod-bc{1} no-lock WHERE
              buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
         BY buf_prod-bc{1}.b-str :
&endif

        { ref/scales-p.i List-BAR {1} }
    END.
  end.
  when "name" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по названию )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
&if "{1}" = "-db" &then
        BY buf_goods.gds-name :
        find FIRST buf_prod-bc{1} no-lock WHERE
        buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
              and buf_prod-bc{1}.db-num = locked_scales.db-num no-error.
       if not available buf_prod-bc{1} then do:
         find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
              and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
         if not available buf_prod-bc then next.
       end.
&else
       , FIRST buf_prod-bc{1} no-lock WHERE
        buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
        BY buf_goods.gds-name :

&endif

        { ref/scales-p.i List-NAME {1} }
    END.
  end.
  when "group" then do:
    PUT stream PrnLibStream space(4) "( С разбивкой по группам, упорядочен по артикулу )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
&if "{1}" = "-db" &then
        BREAK
        BY buf_goods.grp-code
        BY buf_goods.artic:
        find FIRST buf_prod-bc{1} no-lock WHERE
              buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
                            and buf_prod-bc{1}.db-num = locked_scales.db-num no-error.
       if not available buf_prod-bc{1} then do:
         find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
              and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
         if not available buf_prod-bc then next.
       end.
&else
        ,FIRST buf_prod-bc{1} no-lock WHERE
              buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
        BREAK
        BY buf_goods.grp-code
        BY buf_goods.artic:
&endif
      IF FIRST-OF(buf_goods.grp-code) then do:
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
        DISPLAY stream PrnLibStream
        sym1 " " @ buf_scales-gds.PLU-code
        "Группа " @ buf_goods.artic
        " "  @ bar_code
        CAPS(buf_goods.grp-name)  @ buf_goods.gds-name
        " " @ price
        sym5
        " " @ obj-attr
        sym6 with frame List-NAME .
        DOWN stream PrnLibStream 1 with frame  List-NAME .
        UNDERLINE stream PrnLibStream
        sym1
        buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
      end.
      { ref/scales-p.i List-NAME {1} }
    END.
  end.
  when "group-name" then do:
    PUT stream PrnLibStream space(4) "( С разбивкой по группам, упорядочен по названию )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
          buf_scales-gds.db-num = locked_scales.db-num AND
          buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
    FIRST buf_bar-code WHERE
          buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
    FIRST buf_goods WHERE buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
    FIRST buf_gds-obj-attr WHERE
          buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
          buf_gds-obj-attr.attr-code = {&attr-scales-code-o} AND
          buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
          buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
          NO-LOCK
&if "{1}" = "-db" &then
    BREAK
    BY buf_goods.grp-code
    BY buf_goods.gds-name:
    find FIRST buf_prod-bc{1} no-lock WHERE
          buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
              and buf_prod-bc{1}.db-num = locked_scales.db-num no-error.
      if not available buf_prod-bc{1} then do:
        find first buf_prod-bc no-lock where
                buf_prod-bc.b-code = buf_bar-code.b-code
            and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
        if not available buf_prod-bc then next.
      end.
&else
    , FIRST buf_prod-bc{1} no-lock WHERE
          buf_prod-bc{1}.b-str = buf_gds-obj-attr.attr-value
    BREAK
    BY buf_goods.grp-code
    BY buf_goods.gds-name:
&endif
      IF FIRST-OF(buf_goods.grp-code) then do:
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
        DISPLAY stream PrnLibStream
        sym1 " " @ buf_scales-gds.PLU-code
        "Группа " @ buf_goods.artic
        " "  @ bar_code
        CAPS(buf_goods.grp-name)  @ buf_goods.gds-name
        " " @ price
        sym5
        " " @ obj-attr
        sym6 with frame List-NAME .
        DOWN stream PrnLibStream 1 with frame  List-NAME .
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
      end.
      { ref/scales-p.i List-NAME {1} }
    END.
  end.
END CASE .
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "x(103)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .

END PROCEDURE.

/* $Workfile$ e n d */