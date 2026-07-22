block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ordrc2.p $
$Archive: cus/r-ordrc2.p $

Отчет о выполнении РЦ заказов на товары

Автор: Чернова Светлана Александровна
Дата создания: 04/20/06
Author: Svetlana Chernova
Creation date: 04/20/06

*/

define input  parameter p-fact  as logical   no-undo .
define input  parameter p-new   as logical   no-undo .
define input  parameter p-per   as logical   no-undo .
define input  parameter p-req   as logical   no-undo .
define input  parameter p-ship  as logical   no-undo .
define input  parameter p-mode  as character no-undo .
define input  parameter p-OrdDate   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ordrc2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-ordrc2.p $":U .
define variable vss-description as character no-undo init "Отчет о выполнении РЦ заказов на товары".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i  new }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
{ ref/grplibfn.i }
{ rep/rep-bt.i }

define temp-table temp-main no-undo
  field cli-codetype         as character
  field cli-name             as character
  field date-order           as date format "99/99/9999"
  field date-fact            as date format "99/99/9999"
  field n-order              as character
  field status-order         as character
  field date-fact-ras        as character
  field n-trn-ras            as character
  field date-fact-pri        as character
  field n-trn-pri            as character
  field initial-qnty         as decimal
  field order-qnty           as decimal
  field qnty                 as decimal
  field prc_qnty_order-qnty  as decimal
  field fact-qnty            as decimal
  field prc_fact-qnty_qnty   as decimal
index pi
 date-order
 n-order
 index pi2
 n-order
.
/* Итого */
define temp-table temp-i no-undo
  field initial-qnty         as decimal
  field order-qnty           as decimal
  field qnty                 as decimal
  field prc_qnty_order-qnty  as decimal
  field fact-qnty            as decimal
  field prc_fact-qnty_qnty   as decimal
  field account-order        as integer
  field acc-day-trn          as integer
  field strday               as character
.

define stream  OutStream  .
define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c         as integer no-undo .
define variable C-str       as character no-undo .
define variable str--1      as character Format "x(60)" no-undo.
define variable str--2      as integer no-undo .
define variable C-i         as integer no-undo .
define variable p-var       as integer no-undo .
define variable var-1       as integer no-undo .
define variable var-2       as integer no-undo .
define variable v-list-st as character no-undo .
define variable v-size-ras as integer no-undo initial 14.
define variable v-size-pri as integer no-undo initial 14.

if p-fact = true then do:
  v-list-st = v-list-st  + {&fact} + ",".
end.
if p-new = true then do:
  v-list-st = v-list-st +  {&g___new} + ",".
end.

if p-per   = true then do:
  v-list-st = v-list-st +  {&ord-per} + ",".
end.
if p-req   = true then do:
  v-list-st = v-list-st +  {&ord-req} + ",".
end.
if p-ship   = true then do:
  v-list-st = v-list-st +  {&ord-ship} + "," .
end.

v-list-st  = trim( v-list-st,"," ) .

if num-entries (v-list-st) < 1 then do:
    message "Не выбран ни один статус !!!" view-as alert-box error .
    return .
end.


v-ind = 0    .
 run paramls-clear in this-procedure .
/* создаем временный файл */

output stream Macr_Excel close .

num#str# = 0 .
run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name ) .
output stream macr_excel to value ( v-file-name )   .
v-ind = v-ind + 1 .
{ cmp/open-out.i stream OutStream " " {&CS_PS} }

empty temp-table temp-main .

run make-tt     in this-procedure .

define variable v-row as integer   no-undo .
define variable v-row2 as integer   no-undo .

  run PrintTitul in this-procedure .
  run PrintDet in this-procedure .
  run print-all-itog in this-procedure .
  run PrintPodval in this-procedure .
  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind)
    ,input v-file-name
    ) .
output stream OutStream  close .
Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3,4,5,6,7,8,9"
        ) .

  run end-proc  in this-procedure .
  p-file-name =  string( session:temp-directory + {&df_name} + string( g#report-num ) + ".txt" ) .
  run rep/runexcel.p ( p-file-name ).


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure print-line :
define variable vacc-day-trn as decimal   no-undo .
num#str# = num#str# + 1.
num#col# = 1.
run re-calc in this-procedure (
    input  temp-main.order-qnty
  , input  temp-main.qnty
  , input  temp-main.fact-qnty
  , input  ""
  , output temp-main.prc_fact-qnty_qnty
  , output temp-main.prc_qnty_order-qnty
  , output vacc-day-trn
  ).

run macr_excel_char in this-procedure (  temp-main.cli-codetype      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  temp-main.cli-name          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  string(temp-main.date-order , "99/99/9999") , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  string(temp-main.date-fact , "99/99/9999") , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  temp-main.n-order           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  temp-main.status-order      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  temp-main.date-fact-ras     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  temp-main.n-trn-ras         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  temp-main.date-fact-pri     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure (  temp-main.n-trn-pri         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.initial-qnty        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.order-qnty          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.prc_qnty_order-qnty , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.fact-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.prc_fact-qnty_qnty  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

end procedure. /* print-line */

procedure print-all-itog :
num#str# = num#str# + 1.
num#col# = 1.
    run macr_cell_format in this-procedure
        ( ?     ,      /* p-size     */
          true   ,     /* p-bold     */
          false  ,     /* p-italic   */
          ?      ,     /* p-color-bg */
          num#str# ,   /* p-row      */
          1      ,     /* p-col      */
          num#str# ,   /* p-row-2    */
          20 ) .       /* p-col-2    */


run macr_excel_char in this-procedure ( "Итого  " , num#str# , num#col#   ) .
assign num#col# = 11 .

run re-calc in this-procedure (
     input temp-i.order-qnty
    ,input temp-i.qnty
    ,input temp-i.fact-qnty
    ,input temp-i.str
    ,output temp-i.prc_fact-qnty_qnty
    ,output temp-i.prc_qnty_order-qnty
    ,output temp-i.acc-day-trn         ).

run macr_excel_dec in this-procedure ( temp-i.initial-qnty        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.order-qnty          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.prc_qnty_order-qnty , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.fact-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.prc_fact-qnty_qnty  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

num#str# =  7 .
num#col# = 1.
run macr_excel_char in this-procedure ( "Кол-во заказов за период"   , num#str# , num#col#   ) .
num#str# =  8 .
run macr_excel_dec in this-procedure ( temp-i.account-order       , num#str# , num#col#   ) .
num#str# =  9 .
run macr_excel_char in this-procedure ( "Средний период между созданием заказом и накладной(факт) "   , num#str# , num#col#   ) .
num#str# =  10 .
run macr_excel_dec in this-procedure ( temp-i.acc-day-trn         , num#str# , num#col#   ) .

    run macr_cell_format in this-procedure
    ( 10    ,         /* p-size     */
      true  ,         /* p-bold     */
      false  ,        /* p-italic   */
      ?    ,          /* p-color-bg */
      7 ,      /* p-row      */
      1 ,             /* p-col      */
      num#str# ,      /* p-row-2    */
      1 ) .          /* p-col-2    */



end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
    num#str# = num#str# + 1.
    num#col# = 2.
    cc = num#str# .
    run macr_excel_char in this-procedure ( ReportName  , num#str# , num#col#   ) .
    run macr_cell_format in this-procedure
        ( 12     ,     /* p-size     */
          true   ,     /* p-bold     */
          false  ,     /* p-italic   */
          ?      ,     /* p-color-bg */
          cc     ,     /* p-row      */
          2      ,     /* p-col      */
          num#str# ,   /* p-row-2    */
          2 ) .        /* p-col-2    */
    num#col# = 1.
    num#str# = num#str# + 1.

define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable v-nn as integer   no-undo .
&scop var-print-n  v-nn = num-entries( ~{&var-str-n} , "~{&new-line}"  )  .   do l-ii = 1 to v-nn  :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format(                                                          ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
      end.                                                                                                       ~
  end.

&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }

&scop var-str-n  reportheader
{&var-print-n }

    num#str# = num#str# + 1.

    run macr_excel_char("Дата составления " + cur-time-date()   , num#str# , num#col#   ) .
    num#str# = 10.

    run pshap in this-procedure .

    num#str# = num#str# + 1.
    num#col# = 1.
    run macr_excel_char in this-procedure ( "Код"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char in this-procedure ( "Наименование Контрагента "   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char in this-procedure ( if p-OrdDate = "doc-date" then "Дата заказа " else "Заказ на дату" , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 11 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char in this-procedure ( "Дата заказа факт"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 11 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char in this-procedure ( "№ заказа"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 14 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char in this-procedure ( "Статус"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 10 , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 7.
    run macr_excel_char in this-procedure ( "Дата факт РН"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 11 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8.
    run macr_excel_char in this-procedure ( "№ РН"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( v-size-ras , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 9.
    run macr_excel_char in this-procedure ( "Дата факт ПН"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 11 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 10.
    run macr_excel_char in this-procedure ( "№ ПН"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( v-size-pri , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 11.
    run macr_excel_char in this-procedure ( "Рассчитано по заказу"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 12.
    run macr_excel_char in this-procedure ( "Заказано"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 13.
    run macr_excel_char in this-procedure ( "Разрешено к отпуску"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 14.
    run macr_excel_char in this-procedure ( "Разрешено к отпуску / Заказано,%"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 15.
    run macr_excel_char in this-procedure ( "Поставлено"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 16.
    run macr_excel_char in this-procedure ( "Поставлено / Разрешено к отпуску,%"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .

    run macr_cell_format in this-procedure
    ( 10    ,         /* p-size     */
      true  ,         /* p-bold     */
      false  ,        /* p-italic   */
      ?    ,          /* p-color-bg */
      num#str# ,      /* p-row      */
      1 ,             /* p-col      */
      num#str# ,      /* p-row-2    */
      16 ) .          /* p-col-2    */

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
      /*outline, left, right, top, bottom, shade, outline_color, left_color, right_color, top_color, bottom_color*/

    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure make-tt :
define buffer buf_ord-doc      for ub.ord-doc  .

define variable v-gds as logical no-undo .
define variable first-line as logical   no-undo .



  do
  on error undo, return error return-value
  :

create temp-i.
assign
temp-i.initial-qnty     = 0
temp-i.order-qnty       = 0
temp-i.qnty             = 0
temp-i.fact-qnty        = 0
temp-i.account-order    = 0
.
first-line  = true.
v-gds = false .
find first gds-list no-error .
if available gds-list then v-gds = true  .
  for each obj-list :
  if p-mode <> "RC":U then do:
      if p-OrdDate = "doc-date" then do :
        for each buf_ord-doc no-lock where
                buf_ord-doc.doc-type  = {&o-r} and
                buf_ord-doc.obj-type  = obj-list.obj-type and
                buf_ord-doc.obj-code  = obj-list.obj-code and
                lookup ( buf_ord-doc.status_ , v-list-st) > 0  and
                buf_ord-doc.doc-date >= x-date-start and
                buf_ord-doc.doc-date <= x-date-end
                    :
            run make-tt-1 in this-procedure
            ( input buf_ord-doc.doc-code,
              input buf_ord-doc.obj-type,
              input buf_ord-doc.obj-code,
              input buf_ord-doc.ship-date,
              input buf_ord-doc.doc-date,
              input buf_ord-doc.fact-date ,
              input buf_ord-doc.status_,
              input buf_ord-doc.flag_,
              input first-line,
              input v-gds ) .

                      end.
                      end.
      if p-OrdDate = "ship-date" then do :
        for each buf_ord-doc no-lock where
                buf_ord-doc.doc-type  = {&o-r} and
                buf_ord-doc.obj-type  = obj-list.obj-type and
                buf_ord-doc.obj-code  = obj-list.obj-code and
                lookup ( buf_ord-doc.status_ , v-list-st) > 0  and
                buf_ord-doc.ship-date >= x-date-start and
                buf_ord-doc.ship-date <= x-date-end
                        :
            run make-tt-1 in this-procedure
            ( input buf_ord-doc.doc-code,
              input buf_ord-doc.obj-type,
              input buf_ord-doc.obj-code,
              input buf_ord-doc.ship-date,
              input buf_ord-doc.doc-date,
              input buf_ord-doc.fact-date ,
              input buf_ord-doc.status_,
              input buf_ord-doc.flag_,
              input first-line,
              input v-gds ) .

            end.
        end.
  end.
  else do:
      if p-OrdDate = "doc-date" then do :
        for each buf_ord-doc no-lock where
                buf_ord-doc.doc-type  = {&o-r} and
                buf_ord-doc.cli-type  = obj-list.obj-type and
                buf_ord-doc.cli-code  = obj-list.obj-code and
                lookup ( buf_ord-doc.status_ , v-list-st) > 0  and
                buf_ord-doc.doc-date >= x-date-start and
                buf_ord-doc.doc-date <= x-date-end
                :
            run make-tt-1 in this-procedure
            ( input buf_ord-doc.doc-code,
              input buf_ord-doc.cli-type,
              input buf_ord-doc.cli-code,
              input buf_ord-doc.ship-date,
              input buf_ord-doc.doc-date,
              input buf_ord-doc.fact-date ,
              input buf_ord-doc.status_,
              input buf_ord-doc.flag_,
              input first-line,
              input v-gds ) .
        end.
      end.
      if p-OrdDate = "ship-date" then do :
        for each buf_ord-doc use-index ByCli no-lock where
                buf_ord-doc.host-code = v-cntxt-host-code-obj  and
                buf_ord-doc.doc-type  = {&o-r} and
                buf_ord-doc.cli-type  = obj-list.obj-type and
                buf_ord-doc.cli-code  = obj-list.obj-code and
                lookup ( buf_ord-doc.status_ , v-list-st) > 0  and
                buf_ord-doc.ship-date >= x-date-start and
                buf_ord-doc.ship-date <= x-date-end
                :
            run make-tt-1 in this-procedure
              ( input buf_ord-doc.doc-code,
                input buf_ord-doc.cli-type,
                input buf_ord-doc.cli-code,
                input buf_ord-doc.ship-date,
                input buf_ord-doc.doc-date,
                input buf_ord-doc.fact-date ,
                input buf_ord-doc.status_,
                input buf_ord-doc.flag_,
                input first-line,
                input v-gds ) .
        end.
      end.
  end.

  end. /* for each obj-list */
  end. /* do */
end procedure. /* make-tt */

procedure make-tt-1 :
define input parameter v-ord-doc-code  like ub.ord-doc.doc-code .
define input parameter v-ord-obj-type  like ub.ord-doc.obj-type .
define input parameter v-ord-obj-code  like ub.ord-doc.obj-code .
define input parameter v-ord-ship-date like ub.ord-doc.ship-date .
define input parameter v-ord-doc-date like ub.ord-doc.doc-date .
define input parameter v-ord-fact-date like ub.ord-doc.fact-date .
define input parameter v-ord-status    like ub.ord-doc.status_ .
define input parameter v-ord-flag      like ub.ord-doc.flag_ .

define input parameter first-line as logical no-undo .
define input parameter v-gds        as logical no-undo .

define buffer buf_ord-doc-rcv   for ub.ord-doc-rcv  .
define buffer buf_ord-line      for ub.ord-line  .
define buffer buf_trn-doc       for ub.trn-doc  .
define buffer buf_doc-line      for ub.doc-line  .
define buffer bufr_trn-doc      for ub.trn-doc  .
define buffer bufr_doc-line     for ub.doc-line  .
define buffer buf1_ord-doc-rcv  for ub.ord-doc-rcv  .
define buffer buf2_ord-doc-rcv  for ub.ord-doc-rcv  .
define buffer buf_goods         for ub.goods  .
define buffer buf_clients       for ub.clients  .

define variable v-recid     as recid no-undo .
define variable v-trn-date  as date no-undo .   /* ПН */
define variable v-trn-n     as character no-undo .
define variable v-size-p    as integer no-undo initial 14.
define variable v-trn-dater as date no-undo .  /* РН */
define variable v-trn-nr    as character no-undo .
define variable v-size-r    as integer no-undo initial 14.

do
on error undo, return error return-value
:
  find first buf_clients no-lock where
            buf_clients.obj-type = v-ord-obj-type and
            buf_clients.obj-code = v-ord-obj-code no-error .
            for each buf_ord-line no-lock where
          buf_ord-line.doc-code = v-ord-doc-code
                    :
                      v-recid = 0.
            v-trn-dater = ?.
            v-trn-nr = "" .
            v-trn-date = ?.
            v-trn-n = "" .
            v-size-r = 0.
            v-size-p = 0.
                      if v-gds = true  then do:
                          find first gds-list where gds-list.gds-code = buf_ord-line.gds-code no-error .
                          if not available gds-list then next.
                      end.

                      find first temp-main where
                                temp-main.n-order  = buf_ord-line.doc-code
                                no-error .
                      if not available temp-main then do:
                        create temp-main.
                        assign
                          temp-main.n-order       = buf_ord-line.doc-code
                temp-main.date-order    = if p-OrdDate = "doc-date" then v-ord-doc-date else v-ord-ship-date
                temp-main.date-fact     = v-ord-fact-date
                          temp-main.cli-codetype  = buf_clients.obj-type + string (buf_clients.obj-code)
                          temp-main.cli-name      = buf_clients.obj-name
                temp-main.status-order  = v-ord-status + string(v-ord-flag,"+/-")
                      .
/*                if temp-main.date-order = ? then temp-main.date-order = "" .*/
/*                if temp-main.date-fact = ? then temp-main.date-fact = "" .*/
                      end.

            /* найдем накладную */
            for each buf1_ord-doc-rcv no-lock where buf1_ord-doc-rcv.doc-code = v-ord-doc-code ,
                          each ub.ord-chain no-lock where
                              ub.ord-chain.doc-code = buf1_ord-doc-rcv.rcv-code and
                              ub.ord-chain.doc-type = 'rcv'                     and
                              ub.ord-chain.rel-doc-type = 'trn' ,
            first buf_trn-doc no-lock
              where  buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code
                        :
              v-recid = recid(buf1_ord-doc-rcv).
              find first buf_ord-doc-rcv no-lock where recid(buf_ord-doc-rcv) = v-recid no-error .
              find first buf_doc-line no-lock where
                        buf_doc-line.doc-code  = buf_trn-doc.doc-code   and
                        buf_doc-line.artic     = buf_ord-line.artic     and
                        buf_doc-line.prod-type = buf_ord-line.prod-type and
                        buf_doc-line.prod-code = buf_ord-line.prod-code
                        no-error .
              find first temp-main where
                          temp-main.n-order  = buf_ord-line.doc-code
                          no-error .
              if available temp-main then do :
                if buf_trn-doc.doc-type = {&income} then do :
                  if v-trn-date = ? then do :
                    v-trn-date = buf_trn-doc.fact-date.
                  end.
                  else do :
                    if v-trn-date < buf_trn-doc.fact-date then do :
                      v-trn-date = buf_trn-doc.fact-date.
                    end.
                  end.
                  v-trn-n    = buf_trn-doc.doc-code.
                  if lookup(v-trn-n,temp-main.n-trn-pri) = 0 then do :
                    temp-main.n-trn-pri = temp-main.n-trn-pri + if temp-main.n-trn-pri = '' then v-trn-n else ',' + v-trn-n.
                  end.
                  v-size-p = length(trim(temp-main.n-trn-pri)).
                  if v-size-p > v-size-pri then v-size-pri = v-size-p.
                end.

                if buf_trn-doc.doc-type = {&expense} then do :
                  if  v-trn-dater = ? then do :
                    v-trn-dater = buf_trn-doc.fact-date.
                  end.
                  else do :
                    if v-trn-dater < buf_trn-doc.fact-date then do :
                      v-trn-dater = buf_trn-doc.fact-date.
                    end.
                  end.
                  v-trn-nr    = buf_trn-doc.doc-code.
                  temp-main.fact-qnty      = temp-main.fact-qnty +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
                  if lookup(v-trn-nr,temp-main.n-trn-ras) = 0 then do :
                    temp-main.n-trn-ras = temp-main.n-trn-ras + if temp-main.n-trn-ras = '' then v-trn-nr else ',' + v-trn-nr.
                  end.
                  v-size-r = length(trim(temp-main.n-trn-ras)).
                  if v-size-r > v-size-ras then v-size-ras = v-size-r.
                      end.

                if buf_trn-doc.doc-type = {&return} then do :
                  temp-main.fact-qnty = temp-main.fact-qnty -  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
                end.
              end.

              find current temp-i.
              if buf_trn-doc.doc-type = {&expense} then do :
                temp-i.fact-qnty        = temp-i.fact-qnty     +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
              end.
              if buf_trn-doc.doc-type = {&return} then do :
                temp-i.fact-qnty        = temp-i.fact-qnty     -  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
              end.
            end. /* for each buf1_ord-doc-rcv */
            find first temp-main where
                        temp-main.n-order  = buf_ord-line.doc-code
                        no-error .
            if available temp-main then do :
                      assign
                          temp-main.date-fact-ras  = string( v-trn-dater , "99/99/9999")
                          temp-main.date-fact-pri  = string( v-trn-date , "99/99/9999")
                          temp-main.initial-qnty   = temp-main.initial-qnty  +  buf_ord-line.initial-qnty
                          temp-main.order-qnty     = temp-main.order-qnty    +  buf_ord-line.order-qnty
                          temp-main.qnty           = temp-main.qnty          +  buf_ord-line.qnty
                          .
                        if temp-main.date-fact-ras  = ? then temp-main.date-fact-ras  = "" .
                        if temp-main.date-fact-pri  = ? then temp-main.date-fact-pri  = "" .
                      find current temp-i.
                      assign
                        temp-i.initial-qnty     = temp-i.initial-qnty  +  buf_ord-line.initial-qnty
                        temp-i.order-qnty       = temp-i.order-qnty    +  buf_ord-line.order-qnty
                        temp-i.qnty             = temp-i.qnty          +  buf_ord-line.qnty
                        .
            end.
  end. /* for each buf_ord-line */
            assign
              temp-i.account-order    = temp-i.account-order + 1.
    if v-ord-fact-date <> ? then do:
      temp-i.strday           = temp-i.strday + string(v-ord-fact-date - v-ord-doc-date) + "," .
              end.
            .
        end.
end procedure.  /* make-tt-1 */


procedure pshap :

  do
  on error undo, return error return-value
  :

  end.

end procedure. /* pshap */

procedure PrintPodval :

  do
  on error undo, return error return-value
  :

  end.

end procedure. /* PrintPodval */

procedure PrintDet :

  do
  on error undo, return error return-value
  :
  /* по группе */
      for each temp-main no-lock where  break by temp-main.date-order :
          run print-line in this-procedure .
      end.
  end.

end procedure. /* PrintDet */


procedure re-calc :
define input  parameter p-order-qnty             as decimal   no-undo .
define input  parameter p-qnty                   as decimal   no-undo .
define input  parameter p-fact-qnty              as decimal   no-undo .
define input  parameter p-str                    as character no-undo .
define output parameter p-prc_fact-qnty_qnty     as decimal   no-undo .
define output parameter p-prc_qnty_order-qnty    as decimal   no-undo .
define output parameter p-acc-day-trn            as decimal   no-undo .

  do
  on error undo, return error return-value
  :
assign
  p-prc_fact-qnty_qnty  = (if p-qnty = 0 then 0 else  p-fact-qnty /  p-qnty) * 100
  p-prc_qnty_order-qnty = (if p-order-qnty = 0 then 0 else p-qnty / p-order-qnty) * 100
.
define variable v-kol as integer   no-undo .
define variable v-sum as decimal   no-undo .
p-str = trim(p-str,",") .
v-sum = 0.
define variable v-nnn as integer   no-undo .
v-nnn = num-entries ( p-str ) .
repeat v-kol = 1 to  v-nnn :
   v-sum = v-sum + integer ( entry ( v-kol , p-str ))  .
end.
  p-acc-day-trn    = round( v-sum / v-kol  , 4 ) .

  end.

end procedure. /* re-calc */

{ rep/r-libmcr.i macr_excel }