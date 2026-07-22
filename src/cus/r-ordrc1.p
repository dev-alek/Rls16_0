block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ordrc1.p $
$Archive: cus/r-ordrc1.p $

Отчет о выполнении РЦ заказов на товары

Автор: Чернова Светлана Александровна
Дата создания: 04/20/06
Author: Svetlana Chernova
Creation date: 04/20/06

*/

define input  parameter p-tog-obj   as logical   no-undo .
define input  parameter p-classify  as character no-undo .
define input  parameter p-sorttype  as character no-undo .
define input  parameter p-tog-prc   as logical   no-undo .
define input  parameter p-prc       as decimal   no-undo .
define input  parameter p-OrdDate   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ordrc1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-ordrc1.p $":U .
define variable vss-description as character no-undo init "Отчет о выполнении РЦ заказов на товары".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i  new }
{ rep/rep-bt.i }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
{ ref/grplibfn.i }

define temp-table temp-g no-undo
field gds-code   as integer
field obj-code   as integer
field obj-type   as character
field qnty       as decimal
field fact-qnty  as decimal
.

define temp-table temp-main no-undo
  field gds-code             as integer
  field artic                as character
  field gds-name             as character
  field unit-base            as character
  field initial-qnty         as decimal
  field order-qnty           as decimal
  field qnty                 as decimal
  field prc_qnty_order-qnty  as decimal
  field fact-qnty            as decimal
  field prc_fact-qnty_qnty   as decimal
  field account-order        as integer
  field mean-order           as decimal
  field acc-day-order        as char
  field acc-day-trn          as integer
  field obj-type             as character
  field obj-code             as integer
  field grp-code             as integer
  field prod-codetype        as character
  field date1                as date
  field date2                as date
  field strday               as character
index pi
 gds-code
 obj-type
 obj-code
.

define temp-table temp-grp no-undo
  field grp-code     as integer
  field grp-name     as char
  field obj-type             as character
  field obj-code             as integer
  field initial-qnty         as decimal
  field order-qnty           as decimal
  field qnty                 as decimal
  field prc_qnty_order-qnty  as decimal
  field fact-qnty            as decimal
  field prc_fact-qnty_qnty   as decimal
  field account-order        as integer
  field mean-order           as decimal
  field acc-day-order        as char
  field acc-day-trn          as integer
  field date1                as date
  field date2                as date
  field strday               as character

index pi
 grp-code
 obj-type
 obj-code
.
define temp-table temp-prod no-undo
  field prod-codetype        as char
  field grp-name             as char
  field obj-type             as character
  field obj-code             as integer
  field initial-qnty         as decimal
  field order-qnty           as decimal
  field qnty                 as decimal
  field prc_qnty_order-qnty  as decimal
  field fact-qnty            as decimal
  field prc_fact-qnty_qnty   as decimal
  field account-order        as integer
  field mean-order           as decimal
  field acc-day-order        as char
  field acc-day-trn          as integer
  field date1                as date
  field date2                as date
  field strday               as character

index pi
 prod-codetype
 obj-type
 obj-code
.

define temp-table temp-obj no-undo
  field obj-type         like ub.clients.obj-type
  field obj-code         like ub.clients.obj-code
  field obj-name         like ub.clients.obj-name
  field initial-qnty         as decimal
  field order-qnty           as decimal
  field qnty                 as decimal
  field prc_qnty_order-qnty  as decimal
  field fact-qnty            as decimal
  field prc_fact-qnty_qnty   as decimal
  field account-order        as integer
  field mean-order           as decimal
  field acc-day-order        as char
  field acc-day-trn          as integer
  field date1                as date
  field date2                as date
  field strday               as character
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
  field mean-order           as decimal
  field acc-day-order        as char
  field acc-day-trn          as integer
  field date1                as date
  field date2                as date
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

v-ind = 0    .
 run paramls-clear in this-procedure .

 run paramls-write in this-procedure
    (input 'rowsgroup-enable':u
    ,input '':u
    ,input 'yes':u
    ) .


/* создаем временный файл */


output stream Macr_Excel close .

num#str# = 0 .
run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name ) .
output stream macr_excel to value ( v-file-name )   .
v-ind = v-ind + 1 .
{ cmp/open-out.i stream OutStream " " {&CS_PS} }

empty temp-table temp-main .
empty temp-table temp-obj.

run make-tt-prc in this-procedure .
run make-tt     in this-procedure .

define variable v-row as integer   no-undo .
define variable v-row2 as integer   no-undo .
define variable number-group as character no-undo .
define variable i-numb as integer   no-undo .

  run PrintTitul in this-procedure .
  for each temp-obj:
    run PrintObj in this-procedure  ( output v-row2 ) .
        run PrintDet in this-procedure .
    run PrintObji in this-procedure ( input v-row2 ).
  end.
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
        ,input "2,3,4,10,12"
        ) .


  run end-proc  in this-procedure .
  p-file-name =  string( session:temp-directory + {&df_name} + string( g#report-num ) + ".txt" ) .
  run rep/runexcel.p ( p-file-name ).


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure print-line :
num#str# = num#str# + 1.
num#col# = 1.
run re-calc in this-procedure (
    input  temp-main.order-qnty
  , input  temp-main.qnty
  , input  temp-main.fact-qnty
  , input  temp-main.account-order
  , input  temp-main.date1
  , input  temp-main.date2
  , input  temp-main.str
  , output temp-main.prc_fact-qnty_qnty
  , output temp-main.prc_qnty_order-qnty
  , output temp-main.mean-order
  , output temp-main.acc-day-order
  , output temp-main.acc-day-trn
  ).

run macr_excel_char in this-procedure ( temp-main.gds-code            , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-main.artic               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-main.gds-name            , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-main.unit-base           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.initial-qnty        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.order-qnty          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.prc_qnty_order-qnty , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.fact-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.prc_fact-qnty_qnty  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.account-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.mean-order          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-main.acc-day-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-main.acc-day-trn         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
/*
run macr_excel_char in this-procedure ("d"+ string(  temp-main.date1 )      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ("d"+ string(  temp-main.date2 )      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
*/
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
          14 ) .       /* p-col-2    */


run macr_excel_char in this-procedure ( "Итого  " , num#str# , num#col#   ) .
assign num#col# = 5 .

run re-calc in this-procedure (
     input temp-i.order-qnty
    ,input temp-i.qnty
    ,input temp-i.fact-qnty
    ,input temp-i.account-order
    ,input temp-i.date1
    ,input temp-i.date2
    ,input temp-i.str
    ,output temp-i.prc_fact-qnty_qnty
    ,output temp-i.prc_qnty_order-qnty
    ,output temp-i.mean-order
    ,output temp-i.acc-day-order
    ,output temp-i.acc-day-trn         ).

run macr_excel_dec in this-procedure ( temp-i.initial-qnty        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.order-qnty          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.prc_qnty_order-qnty , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.fact-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.prc_fact-qnty_qnty  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.account-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.mean-order          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-i.acc-day-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-i.acc-day-trn         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
/*
run macr_excel_char in this-procedure ("d"+ string(  temp-i.date1 )      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ("d"+ string(  temp-i.date2 )      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
*/

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
&scop var-print-n v-nn= num-entries( ~{&var-str-n} , "~{&new-line}"  )    .   do l-ii = 1 to v-nn :  ~
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
&scop var-str-n  reportheader
{&var-print-n }

    num#str# = num#str# + 1.

    run macr_excel_char("Дата составления " + cur-time-date()   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.

    run pshap in this-procedure .

    num#str# = num#str# + 1.

    num#col# = 1.
    run macr_excel_char in this-procedure ( "Код товара"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char in this-procedure ( "Артикул"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char in this-procedure ( "Наименование"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char in this-procedure ( "Ед. изм."   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 4 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char in this-procedure ( "Рассчитано по заказу"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char in this-procedure ( "Заказано"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 7.
    run macr_excel_char in this-procedure ( "Разрешено к отпуску"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8.
    run macr_excel_char in this-procedure ( "Разрешено к отпуску / Заказано,%"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 9.
    run macr_excel_char in this-procedure ( "Поставлено"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 10.
    run macr_excel_char in this-procedure ( "Поставлено / Разрешено к отпуску,%"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 11.
    run macr_excel_char in this-procedure ( "Кол-во заказа за период"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 12.
    run macr_excel_char in this-procedure ( "Средний заказ (разрешено к отпуску)"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 12 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 13.
    run macr_excel_char in this-procedure ( "Средний период между заказами в днях"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 14.
    run macr_excel_char in this-procedure ( "Средний период между заказом и поставкой"   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  ( 15 , ? , num#str# , num#col# , ?, ? ) .

    run macr_cell_format in this-procedure
    ( 10    ,         /* p-size     */
      true  ,         /* p-bold     */
      false  ,        /* p-italic   */
      ?    ,          /* p-color-bg */
      num#str# ,      /* p-row      */
      1 ,             /* p-col      */
      num#str# ,      /* p-row-2    */
      14 ) .          /* p-col-2    */

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

define variable first-line as logical   no-undo .
define variable v-gds as logical no-undo .

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
  if p-OrdDate = "doc-date" then do :
  for each buf_ord-doc no-lock where
           buf_ord-doc.cons-code = ""  and
           buf_ord-doc.doc-type  = {&o-r} and
           buf_ord-doc.cli-type  = v-cntxt-obj-type and
           buf_ord-doc.cli-code  = v-cntxt-obj-code and
           buf_ord-doc.obj-type  = obj-list.obj-type and
           buf_ord-doc.obj-code  = obj-list.obj-code and
/*            buf_ord-doc.status_   = {&fact}    and*/
            buf_ord-doc.doc-date >= x-date-start and
            buf_ord-doc.doc-date <= x-date-end break by buf_ord-doc.doc-date
            :
            run make-tt-1 in this-procedure
            ( input buf_ord-doc.doc-code,
              input buf_ord-doc.obj-type,
              input buf_ord-doc.obj-code,
              input buf_ord-doc.doc-date,
              input first-line,
              input v-gds ) .
    end.
  end.
  if p-OrdDate = "ship-date" then do :
    for each buf_ord-doc no-lock where
            buf_ord-doc.cons-code = ""  and
            buf_ord-doc.doc-type  = {&o-r} and
            buf_ord-doc.cli-type  = v-cntxt-obj-type and
            buf_ord-doc.cli-code  = v-cntxt-obj-code and
            buf_ord-doc.obj-type  = obj-list.obj-type and
            buf_ord-doc.obj-code  = obj-list.obj-code and
/*            buf_ord-doc.status_   = {&fact}    and*/
            buf_ord-doc.ship-date >= x-date-start and
            buf_ord-doc.ship-date <= x-date-end
            :
            run make-tt-1 in this-procedure
            ( input buf_ord-doc.doc-code,
              input buf_ord-doc.obj-type,
              input buf_ord-doc.obj-code,
              input buf_ord-doc.ship-date,
              input first-line,
              input v-gds ) .
    end.
  end.
  end.
 end.
end procedure. /* make-tt */

procedure make-tt-1 :
define input parameter v-ord-doc-code like ub.ord-doc.doc-code .
define input parameter v-ord-obj-type like ub.ord-doc.obj-type .
define input parameter v-ord-obj-code like ub.ord-doc.obj-code .
define input parameter v-ord-date     like ub.ord-doc.doc-date .
define input parameter first-line as logical no-undo .
define input parameter v-gds        as logical no-undo .


define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv  .
define buffer buf_ord-line     for ub.ord-line  .
define buffer buf_trn-doc      for ub.trn-doc  .
define buffer buf_doc-line     for ub.doc-line  .
define buffer buf_clients      for ub.clients  .
define buffer buf1_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_goods        for ub.goods  .

define variable v-recid as recid no-undo .
define variable v-code as integer   no-undo .
define variable v-type as character no-undo .
define variable v-trn-code as character no-undo .
define variable v-trn-type as character no-undo .

do
on error undo, return error return-value
:

v-code = if p-tog-obj then v-ord-obj-code else 0    .
v-type = if p-tog-obj then v-ord-obj-type else ""  .

      for each buf_ord-line no-lock where
          buf_ord-line.doc-code = v-ord-doc-code
               :
                v-recid = 0.
          for each buf1_ord-doc-rcv no-lock where buf1_ord-doc-rcv.doc-code = v-ord-doc-code ,
                    each ub.ord-chain no-lock where
                         ub.ord-chain.doc-code = buf1_ord-doc-rcv.rcv-code and
                         ub.ord-chain.doc-type = 'rcv'                     and
                         ub.ord-chain.rel-doc-type = 'trn' ,
                    first buf_trn-doc no-lock
                where  buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code and
                ( buf_trn-doc.doc-type = {&expense} or buf_trn-doc.doc-type = {&return} )
                  :
                   v-trn-code = buf_trn-doc.doc-code.
              v-trn-type = buf_trn-doc.doc-type.
                   v-recid = recid(buf1_ord-doc-rcv).
                end.

                find first buf_ord-doc-rcv no-lock where recid(buf_ord-doc-rcv) = v-recid no-error .
                find first buf_goods no-lock where buf_goods.gds-code = buf_ord-line.gds-code no-error .

                if v-gds = true  then do:
                    find first gds-list where gds-list.gds-code = buf_ord-line.gds-code no-error .
                    if not available gds-list then next.
                end.
                if p-tog-prc = true  then do:
                    find first temp-g where temp-g.gds-code = buf_ord-line.gds-code no-error .
                    if not available temp-g then next.
                end.

                find first buf_doc-line no-lock where
                           buf_doc-line.doc-code  = v-trn-code             and
                           buf_doc-line.artic     = buf_ord-line.artic     and
                           buf_doc-line.prod-type = buf_ord-line.prod-type and
                           buf_doc-line.prod-code = buf_ord-line.prod-code
                           no-error .

                find first temp-main where
                           temp-main.gds-code = buf_ord-line.gds-code and
                           temp-main.obj-code = v-code  and
                           temp-main.obj-type = v-type
                           no-error .
                if not available temp-main then do:
                  create temp-main.
                  assign
                    temp-main.gds-code      = buf_ord-line.gds-code
                    temp-main.obj-code      = v-code
                    temp-main.obj-type      = v-type
                    temp-main.artic         = buf_goods.artic
                    temp-main.gds-name      = buf_goods.gds-name
                    temp-main.unit-base     = buf_goods.unit-base
                    temp-main.grp-code      = buf_goods.grp-code
                    temp-main.prod-codetype = buf_goods.prod-type + string (buf_goods.prod-code)
                  .
              temp-main.date1 = v-ord-date .
              temp-main.date2 = v-ord-date .

                end.
                find first buf_trn-doc no-lock where
                           buf_trn-doc.doc-code = buf_doc-line.doc-code
                           no-error .
                define variable v-trn-date as date no-undo .
                v-trn-date = date("").
                if available buf_trn-doc then v-trn-date = buf_trn-doc.doc-date.
                assign
                  temp-main.initial-qnty  = temp-main.initial-qnty  +  buf_ord-line.initial-qnty
                  temp-main.order-qnty    = temp-main.order-qnty    +  buf_ord-line.order-qnty
                  temp-main.qnty          = temp-main.qnty          +  buf_ord-line.qnty
                  temp-main.account-order = temp-main.account-order + 1
            temp-main.strday        = temp-main.strday + string(v-ord-date - v-trn-date) + ","
                .
            if v-trn-type = {&expense} then do :
              temp-main.fact-qnty     = temp-main.fact-qnty     +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
            end.
            if v-trn-type = {&return} then do :
              temp-main.fact-qnty     = temp-main.fact-qnty     -  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
            end.
            if temp-main.date1 > v-ord-date then temp-main.date1 = v-ord-date .
            if temp-main.date2 < v-ord-date then temp-main.date2 = v-ord-date .

                find current temp-i.
                if first-line  = true then do:
              temp-i.date1 = v-ord-date .
              temp-i.date2 = v-ord-date .
                   first-line  = false .
                end.
                assign
                  temp-i.initial-qnty     = temp-i.initial-qnty  +  buf_ord-line.initial-qnty
                  temp-i.order-qnty       = temp-i.order-qnty    +  buf_ord-line.order-qnty
                  temp-i.qnty             = temp-i.qnty          +  buf_ord-line.qnty
                  temp-i.account-order    = temp-i.account-order + 1
            temp-i.strday           = temp-i.strday + string(v-ord-date - v-trn-date) + ","
                .
            if v-trn-type = {&expense} then do :
              temp-i.fact-qnty        = temp-i.fact-qnty     +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
            end.
            if v-trn-type = {&return} then do :
              temp-i.fact-qnty        = temp-i.fact-qnty     -  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
            end.

          if temp-i.date1 > v-ord-date then temp-i.date1 = v-ord-date .
          if temp-i.date2 < v-ord-date then temp-i.date2 = v-ord-date .

                find first temp-obj where
                           temp-obj.obj-code = v-code  and
                           temp-obj.obj-type = v-type
                           no-error .
                if not available temp-obj then do:
                   create temp-obj.
                   assign
                    temp-obj.obj-code = v-code
                    temp-obj.obj-type = v-type
                   .
              temp-obj.date1 = v-ord-date .
              temp-obj.date2 = v-ord-date .

                end.
                assign
                  temp-obj.initial-qnty     = temp-obj.initial-qnty  +  buf_ord-line.initial-qnty
                  temp-obj.order-qnty       = temp-obj.order-qnty    +  buf_ord-line.order-qnty
                  temp-obj.qnty             = temp-obj.qnty          +  buf_ord-line.qnty
                  temp-obj.account-order    = temp-obj.account-order + 1
            temp-obj.strday           = temp-obj.strday + string(v-ord-date - v-trn-date) + ","
                .
            if v-trn-type = {&expense} then do :
              temp-obj.fact-qnty        = temp-obj.fact-qnty     +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
            end.
            if v-trn-type = {&return} then do :
              temp-obj.fact-qnty        = temp-obj.fact-qnty     -  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
            end.

          if temp-obj.date1 > v-ord-date then temp-obj.date1 = v-ord-date .
          if temp-obj.date2 < v-ord-date then temp-obj.date2 = v-ord-date .
               if p-classify = "grp-goods"  then do:
                  find first temp-grp where
                             temp-grp.grp-code  = buf_goods.grp-code and
                             temp-grp.obj-code = v-code  and
                             temp-grp.obj-type = v-type
                             no-error .
                  if not available temp-grp then do:
                      create temp-grp.
                      assign
                        temp-grp.obj-code  = v-code
                        temp-grp.obj-type  = v-type
                        temp-grp.grp-code  = buf_goods.grp-code
                        temp-grp.grp-name  = buf_goods.grp-name
                      .
                temp-grp.date1 = v-ord-date .
                temp-grp.date2 = v-ord-date .

                  end.
                  assign
                    temp-grp.initial-qnty     = temp-grp.initial-qnty  +  buf_ord-line.initial-qnty
                    temp-grp.order-qnty       = temp-grp.order-qnty    +  buf_ord-line.order-qnty
                    temp-grp.qnty             = temp-grp.qnty          +  buf_ord-line.qnty
                    temp-grp.account-order    = temp-grp.account-order + 1
              temp-grp.strday           = temp-grp.strday + string(v-ord-date - v-trn-date) + ","
                  .
              if v-trn-type = {&expense} then do :
                temp-grp.fact-qnty        = temp-grp.fact-qnty     +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
              end.
              if v-trn-type = {&return} then do :
                temp-grp.fact-qnty        = temp-grp.fact-qnty     -  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
              end.

            if temp-grp.date1 > v-ord-date then temp-grp.date1 = v-ord-date.
            if temp-grp.date2 < v-ord-date then temp-grp.date2 = v-ord-date.
               end.
               if p-classify = "prod"  then do:
                  find first temp-prod where
                             temp-prod.prod-codetype  = buf_goods.prod-type + string (buf_goods.prod-code) and
                             temp-prod.obj-code  = v-code  and
                             temp-prod.obj-type  = v-type
                             no-error .
                  if not available temp-prod then do:
                  find first buf_clients no-lock where
                            buf_clients.obj-code = buf_goods.prod-code and
                            buf_clients.obj-type = buf_goods.prod-type no-error .
                      create temp-prod.
                      assign
                        temp-prod.prod-codetype  = buf_goods.prod-type + string (buf_goods.prod-code)
                        temp-prod.grp-name  = buf_clients.obj-name
                        temp-prod.obj-code  = v-code
                        temp-prod.obj-type  = v-type
                        .
                  temp-prod.date1 = v-ord-date .
                  temp-prod.date2 = v-ord-date .

                  end.
                  assign
                    temp-prod.initial-qnty     = temp-prod.initial-qnty  +  buf_ord-line.initial-qnty
                    temp-prod.order-qnty       = temp-prod.order-qnty    +  buf_ord-line.order-qnty
                    temp-prod.qnty             = temp-prod.qnty          +  buf_ord-line.qnty
                    temp-prod.account-order    = temp-prod.account-order + 1
                   .
              if v-trn-type = {&expense} then do :
                temp-prod.fact-qnty        = temp-prod.fact-qnty     +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
               end.
              if v-trn-type = {&return} then do :
                temp-prod.fact-qnty        = temp-prod.fact-qnty     -  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
      end.
              if temp-prod.date1 > v-ord-date then temp-prod.date1 = v-ord-date .
              if temp-prod.date2 < v-ord-date then temp-prod.date2 = v-ord-date .
  end.
  end.
  end.
end procedure. /* make-tt-1 */

procedure print-grp-name :
define output parameter p-row as integer   no-undo .
  do
  on error undo, return error return-value
  :
num#str# = num#str# + 1.
num#col# = 1.
define variable v-full-name as character no-undo .
run grplib-get-full-name in this-procedure  ( input temp-grp.grp-code , output v-full-name ) .

run macr_excel_char in this-procedure (  v-full-name    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .


    run macr_cell_format in this-procedure
        ( 12       ,     /* p-size     */
          true     ,     /* p-bold     */
          false    ,     /* p-italic   */
          48       ,     /* p-color-bg */
          num#str# ,     /* p-row      */
          1        ,     /* p-col      */
          num#str# ,     /* p-row-2    */
          14       ) .   /* p-col-2    */
   p-row =  num#str# .

  end.

end procedure. /* print-grp-name */


procedure print-grp-itogo :
define input  parameter p-row as integer   no-undo .
  do
  on error undo, return error return-value
  :
/* группировка по товарам */
  run paramls-write in this-procedure
    (input "rowsgroup"
    ,input string(v-ind) + ',':u + number-group
    ,input substitute('&1:&2' ,  p-row, num#str# )
    ) .



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
          14 ) .       /* p-col-2    */


define variable v-full-name as character no-undo .
run grplib-get-full-name in this-procedure  ( input temp-grp.grp-code , output v-full-name ) .

run macr_excel_char in this-procedure (  v-full-name    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( "Итого по ГРУППЕ"   , num#str# , num#col#   ) .
run re-calc in this-procedure (
     input temp-grp.order-qnty
    ,input temp-grp.qnty
    ,input temp-grp.fact-qnty
    ,input temp-grp.account-order
    ,input temp-grp.date1
    ,input temp-grp.date2
    ,input temp-grp.str
    ,output temp-grp.prc_fact-qnty_qnty
    ,output temp-grp.prc_qnty_order-qnty
    ,output temp-grp.mean-order
    ,output temp-grp.acc-day-order
    ,output temp-grp.acc-day-trn         ).

assign num#col# = 5 .
run macr_excel_dec in this-procedure ( temp-grp.initial-qnty        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-grp.order-qnty          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-grp.qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-grp.prc_qnty_order-qnty , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-grp.fact-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-grp.prc_fact-qnty_qnty  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-grp.account-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-grp.mean-order          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-grp.acc-day-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-grp.acc-day-trn         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

  end.

end procedure. /* print-grp-itogo */

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

procedure print-prod-name :
define output parameter p-row as integer   no-undo .
  do
  on error undo, return error return-value
  :
num#str# = num#str# + 1.
num#col# = 1.

run macr_excel_char in this-procedure ( temp-prod.grp-name , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( ""     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .


    run macr_cell_format in this-procedure
        ( 12       ,     /* p-size     */
          true     ,     /* p-bold     */
          false    ,     /* p-italic   */
          48       ,     /* p-color-bg */
          num#str# ,     /* p-row      */
          1        ,     /* p-col      */
          num#str# ,     /* p-row-2    */
          14       ) .   /* p-col-2    */
   p-row =  num#str# .

  end.

end procedure. /* print-grp-name */


procedure print-prod-itogo :
define input  parameter p-row as integer   no-undo .
  do
  on error undo, return error return-value
  :
/* группировка по товарам */
  run paramls-write in this-procedure
    (input "rowsgroup"
    ,input string(v-ind) + ',':u + number-group
    ,input substitute('&1:&2' ,  p-row, num#str# )
    ) .



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
          14 ) .       /* p-col-2    */


run macr_excel_char in this-procedure ( temp-prod.grp-name   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( "Итого "   , num#str# , num#col#   ) .
run re-calc in this-procedure (
     input temp-prod.order-qnty
    ,input temp-prod.qnty
    ,input temp-prod.fact-qnty
    ,input temp-prod.account-order
    ,input temp-prod.date1
    ,input temp-prod.date2
    ,input temp-prod.str
    ,output temp-prod.prc_fact-qnty_qnty
    ,output temp-prod.prc_qnty_order-qnty
    ,output temp-prod.mean-order
    ,output temp-prod.acc-day-order
    ,output temp-prod.acc-day-trn         ).

assign num#col# = 5 .
run macr_excel_dec in this-procedure ( temp-prod.initial-qnty        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-prod.order-qnty          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-prod.qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-prod.prc_qnty_order-qnty , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-prod.fact-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-prod.prc_fact-qnty_qnty  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-prod.account-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-prod.mean-order          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-prod.acc-day-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-prod.acc-day-trn         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

  end.

end procedure. /* print-grp-itogo */



procedure PrintDet :

  do
  on error undo, return error return-value
  :
  /* по группе */
  case p-classify :
  when "no-classify" then do:
        case p-sorttype :
            when "sort-code" then do:
                  for each temp-main no-lock where
                      temp-main.obj-type = temp-obj.obj-type  and
                      temp-main.obj-code = temp-obj.obj-code
                      break by temp-main.gds-code
                      :
                      run print-line in this-procedure .
                  end.
            end.
            when "sort-artic" then do:
                  for each temp-main no-lock where
                      temp-main.obj-type = temp-obj.obj-type  and
                      temp-main.obj-code = temp-obj.obj-code
                      break by temp-main.artic
                      :
                      run print-line in this-procedure .
                  end.
            end.
            when "sort-name" then do:
                  for each temp-main no-lock where
                      temp-main.obj-type = temp-obj.obj-type  and
                      temp-main.obj-code = temp-obj.obj-code
                      break by temp-main.gds-name
                      :

                      run print-line in this-procedure .
                  end.
            end.
        end case.
  end.
  when "prod" then do:
      /* по произв */
      for each temp-prod where
               temp-prod.obj-type = temp-obj.obj-type  and
               temp-prod.obj-code = temp-obj.obj-code
               :
         if not (can-find (first temp-main where
                                temp-main.prod-codetype = temp-prod.prod-codetype and
                                temp-main.obj-type = temp-obj.obj-type  and
                                temp-main.obj-code = temp-obj.obj-code  )) then next.
          i-numb = i-numb + 1 .
          number-group = string ( i-numb , "99999" ) .
            run print-prod-name in this-procedure ( output v-row ) .
            case p-sorttype :
                when "sort-code" then do:
                      for each temp-main where
                               temp-main.prod-codetype = temp-prod.prod-codetype and
                               temp-main.obj-type = temp-obj.obj-type  and
                               temp-main.obj-code = temp-obj.obj-code
                               no-lock break by temp-main.gds-code
                               :
                          run print-line in this-procedure .
                      end.
                end.
                when "sort-artic" then do:
                      for each temp-main where
                          temp-main.prod-codetype = temp-prod.prod-codetype and
                          temp-main.obj-type = temp-obj.obj-type  and
                          temp-main.obj-code = temp-obj.obj-code
                          no-lock break by temp-main.artic
                          :
                          run print-line in this-procedure .
                      end.
                end.
                when "sort-name" then do:
                      for each temp-main where
                        temp-main.prod-codetype = temp-prod.prod-codetype and
                        temp-main.obj-type = temp-obj.obj-type  and
                        temp-main.obj-code = temp-obj.obj-code
                        no-lock break by temp-main.gds-name
                        :
                          run print-line in this-procedure .
                      end.
                end.
            end case.
            run print-prod-itogo in this-procedure ( input v-row ) .
      end.
  end.
  when "grp-goods" then do:
        for each temp-grp where
                 temp-grp.obj-type = temp-obj.obj-type  and
                 temp-grp.obj-code = temp-obj.obj-code :

         if not (can-find ( first temp-main where
                          temp-main.grp-code = temp-grp.grp-code and
                          temp-main.obj-type = temp-obj.obj-type and
                          temp-main.obj-code = temp-obj.obj-code)
                          ) then next.

            i-numb = i-numb + 1 .
            number-group = string ( i-numb , "99999" ) .
              run print-grp-name in this-procedure ( output v-row ) .
              case p-sorttype :
                  when "sort-code" then do:
                        for each temp-main where
                                 temp-main.grp-code = temp-grp.grp-code and
                                 temp-main.obj-type = temp-obj.obj-type and
                                 temp-main.obj-code = temp-obj.obj-code
                                 no-lock break by temp-main.gds-code :
                            run print-line in this-procedure .
                        end.
                  end.
                  when "sort-artic" then do:
                        for each temp-main where
                                 temp-main.grp-code = temp-grp.grp-code and
                                 temp-main.obj-type = temp-obj.obj-type and
                                 temp-main.obj-code = temp-obj.obj-code
                                 no-lock break by temp-main.artic :
                            run print-line in this-procedure .
                        end.
                  end.
                  when "sort-name" then do:
                        for each temp-main where
                                 temp-main.grp-code = temp-grp.grp-code  and
                                 temp-main.obj-type = temp-obj.obj-type  and
                                 temp-main.obj-code = temp-obj.obj-code
                                 no-lock break by temp-main.gds-name :
                            run print-line in this-procedure .
                        end.
                  end.
              end case.
              run print-grp-itogo in this-procedure ( input v-row ) .
        end.
  end.
  end case.
  end.

end procedure. /* PrintDet */

procedure PrintObj :
define output parameter p-row as integer   no-undo .
define buffer buf_clients for ub.clients  .
  do
  on error undo, return error return-value
  :
if p-tog-obj = false then return .

i-numb = i-numb + 1 .
number-group = string ( i-numb , "99999" ) .



num#str# = num#str# + 1 .
num#col# = 1 .
find first buf_clients no-lock where
           buf_clients.obj-code = temp-obj.obj-code and
           buf_clients.obj-type = temp-obj.obj-type no-error .

run macr_excel_char in this-procedure ( buf_clients.obj-name , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_cell_format in this-procedure
        ( 12       ,     /* p-size     */
          true     ,     /* p-bold     */
          false    ,     /* p-italic   */
          36        ,     /* p-color-bg */
          num#str# ,     /* p-row      */
          1        ,     /* p-col      */
          num#str# ,     /* p-row-2    */
          14       ) .   /* p-col-2    */
   p-row =  num#str# .

  end.

end procedure. /* PrintObj */


procedure PrintObji :
define input  parameter p-row as integer   no-undo .
define buffer buf_clients for ub.clients  .
  do
  on error undo, return error return-value
  :
if p-tog-obj = false then return .

if p-classify = "no-classify" then do:
    run paramls-write in this-procedure
      (input "rowsgroup"
      ,input string(v-ind) + ',':u + number-group
      ,input substitute('&1:&2' ,  p-row, num#str# )
      ) .
end.
find first buf_clients no-lock where
           buf_clients.obj-code = temp-obj.obj-code and
           buf_clients.obj-type = temp-obj.obj-type no-error .

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
          14 ) .       /* p-col-2    */


run macr_excel_char in this-procedure ( "Итого по объекту " , num#str# , num#col#   ) .
 assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( buf_clients.obj-name , num#str# , num#col#   ) .
run re-calc in this-procedure (
     input  temp-obj.order-qnty
    ,input  temp-obj.qnty
    ,input  temp-obj.fact-qnty
    ,input  temp-obj.account-order
    ,input  temp-obj.date1
    ,input  temp-obj.date2
    ,input  temp-obj.str
    ,output temp-obj.prc_fact-qnty_qnty
    ,output temp-obj.prc_qnty_order-qnty
    ,output temp-obj.mean-order
    ,output temp-obj.acc-day-order
    ,output temp-obj.acc-day-trn         ).

assign num#col# = 5 .
run macr_excel_dec in this-procedure ( temp-obj.initial-qnty        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-obj.order-qnty          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-obj.qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-obj.prc_qnty_order-qnty , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-obj.fact-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-obj.prc_fact-qnty_qnty  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-obj.account-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-obj.mean-order          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-obj.acc-day-order       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-obj.acc-day-trn         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
end.

end procedure. /* print-grp-itogo */


procedure re-calc :
define input  parameter p-order-qnty             as decimal   no-undo .
define input  parameter p-qnty                   as decimal   no-undo .
define input  parameter p-fact-qnty              as decimal   no-undo .
define input  parameter p-account-order          as decimal   no-undo .
define input  parameter p-date1                  as date      no-undo .
define input  parameter p-date2                  as date      no-undo .
define input  parameter p-str                    as character no-undo .

define output parameter p-prc_fact-qnty_qnty     as decimal   no-undo .
define output parameter p-prc_qnty_order-qnty    as decimal   no-undo .
define output parameter p-mean-order             as decimal   no-undo .
define output parameter p-acc-day-order          as character no-undo .
define output parameter p-acc-day-trn            as decimal   no-undo .

  do
  on error undo, return error return-value
  :
assign
  p-prc_fact-qnty_qnty  = (if p-qnty = 0 then 0 else  p-fact-qnty /  p-qnty) * 100
  p-prc_qnty_order-qnty = (if p-order-qnty = 0 then 0 else p-qnty / p-order-qnty) * 100
  p-mean-order          =  if p-account-order  = 0 then 0 else p-qnty / p-account-order
.

  if p-account-order <= 1
      then p-acc-day-order  = "---".
      else p-acc-day-order  = string ( ( p-date2 - p-date1  ) / ( p-account-order - 1 )  , "->>>>>>>>9.<<<<" )  .
      if p-acc-day-order = ? then p-acc-day-order  = "---".

define variable v-kol as integer   no-undo .
define variable v-sum as decimal   no-undo .
p-str = trim(p-str,",") .
v-sum = 0.
define variable v-nnn as integer   no-undo .
v-nnn = num-entries ( p-str ) .

repeat v-kol = 1 to v-nnn :
   v-sum = v-sum + integer ( entry ( v-kol , p-str ))  .
end.
  p-acc-day-trn    = round( v-sum / v-kol  , 4 ) .

  end.

end procedure. /* re-calc */

{ rep/r-libmcr.i macr_excel }

/*
    if p-tog-prc = true  then do:
      if p-prc < ( if buf_ord-line.qnty = 0 then 0 else  (
            ( if not available buf_doc-line then 0 else  buf_doc-line.fact-qnty) /  buf_ord-line.qnty) * 100 )
            then next.
    end.
*/

procedure make-tt-prc :
define buffer buf_ord-doc      for ub.ord-doc  .

define variable v-gds as logical no-undo .

  do
  on error undo, return error return-value
  :

empty temp-table temp-g.
if p-tog-prc = false then return .

v-gds = false .
find first gds-list no-error .
if available gds-list then v-gds = true  .
  for each obj-list :
    if p-OrdDate = "doc-date" then do :
      for each buf_ord-doc no-lock where
              buf_ord-doc.cons-code = ""  and
              buf_ord-doc.doc-type  = {&o-r} and
              buf_ord-doc.cli-type  = v-cntxt-obj-type and
              buf_ord-doc.cli-code  = v-cntxt-obj-code and
              buf_ord-doc.obj-type  = obj-list.obj-type and
              buf_ord-doc.obj-code  = obj-list.obj-code and
/*              buf_ord-doc.status_   = {&fact}    and*/
              buf_ord-doc.doc-date >= x-date-start and
              buf_ord-doc.doc-date <= x-date-end
              :
              run make-tt-prc-1 in this-procedure
                ( input buf_ord-doc.doc-code,
                  input buf_ord-doc.obj-type,
                  input buf_ord-doc.obj-code,
                  input v-gds ) .
      end.
    end.
    if p-OrdDate = "ship-date" then do :
  for each buf_ord-doc no-lock where
           buf_ord-doc.cons-code = ""  and
           buf_ord-doc.doc-type  = {&o-r} and
           buf_ord-doc.cli-type  = v-cntxt-obj-type and
           buf_ord-doc.cli-code  = v-cntxt-obj-code and
           buf_ord-doc.obj-type  = obj-list.obj-type and
           buf_ord-doc.obj-code  = obj-list.obj-code and
/*              buf_ord-doc.status_   = {&fact}    and*/
              buf_ord-doc.ship-date >= x-date-start and
              buf_ord-doc.ship-date <= x-date-end
              :
              run make-tt-prc-1 in this-procedure
                ( input buf_ord-doc.doc-code,
                  input buf_ord-doc.obj-type,
                  input buf_ord-doc.obj-code,
                  input v-gds ) .
      end.
    end.
  end.
  for each temp-g :
      if p-prc <= ( if temp-g.qnty = 0 then 0 else  (( temp-g.fact-qnty) /  temp-g.qnty ) * 100 )  then delete temp-g.
  end.
  end.
end procedure. /* make-tt-prc */

procedure make-tt-prc-1 :
define input parameter v-ord-doc-code like ub.ord-doc.doc-code .
define input parameter v-ord-obj-type like ub.ord-doc.obj-type .
define input parameter v-ord-obj-code like ub.ord-doc.obj-code .
define input parameter v-gds        as logical no-undo .

define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv  .
define buffer buf_ord-line     for ub.ord-line  .
define buffer buf_trn-doc      for ub.trn-doc  .
define buffer buf_doc-line     for ub.doc-line  .
define buffer buf_clients      for ub.clients  .
define buffer buf1_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_goods        for ub.goods  .

define variable v-recid as recid no-undo .
define variable v-code as integer   no-undo .
define variable v-type as character no-undo .
define variable V-TRN-CODE as character no-undo .
define variable V-TRN-TYPE as character no-undo .

do
on error undo, return error return-value
:

v-code = if p-tog-obj then v-ord-obj-code else 0    .
v-type = if p-tog-obj then v-ord-obj-type else ""  .

      for each buf_ord-line no-lock where
          buf_ord-line.doc-code = v-ord-doc-code
               :
                v-recid = 0.
          for each buf1_ord-doc-rcv no-lock where buf1_ord-doc-rcv.doc-code = v-ord-doc-code ,
                    each ub.ord-chain no-lock where
                         ub.ord-chain.doc-code = buf1_ord-doc-rcv.rcv-code and
                         ub.ord-chain.doc-type = 'rcv'                     and
                         ub.ord-chain.rel-doc-type = 'trn' ,
                 first buf_trn-doc no-lock
                  where  buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code and
                    ( buf_trn-doc.doc-type = {&expense} or buf_trn-doc.doc-type = {&return} )
                   :
                   v-recid = recid(buf1_ord-doc-rcv).
                   V-TRN-CODE = buf_trn-doc.doc-code .
              V-TRN-TYPE = buf_trn-doc.doc-type .
                end.
                find first buf_ord-doc-rcv no-lock where recid(buf_ord-doc-rcv) = v-recid no-error .
                find first buf_goods no-lock where buf_goods.gds-code = buf_ord-line.gds-code no-error .

                if v-gds = true  then do:
                    find first gds-list where gds-list.gds-code = buf_ord-line.gds-code no-error .
                    if not available gds-list then next.
                end.

                find first buf_doc-line no-lock where
                           buf_doc-line.doc-code = v-trn-code and
                           buf_doc-line.artic    = buf_ord-line.artic       and
                           buf_doc-line.prod-type = buf_ord-line.prod-type  and
                           buf_doc-line.prod-code = buf_ord-line.prod-code
                           no-error .
                find first temp-g where
                           temp-g.gds-code = buf_ord-line.gds-code and
                           temp-g.obj-code = v-code  and
                           temp-g.obj-type = v-type
                           no-error .
                if not available temp-g then do:
                  create temp-g.
                  assign
                    temp-g.gds-code      = buf_ord-line.gds-code
                    temp-g.obj-code      = v-code
                    temp-g.obj-type      = v-type
                  .
                end.
                assign
                  temp-g.qnty          = temp-g.qnty          +  buf_ord-line.qnty
                .
              if V-TRN-TYPE = {&expense} then do :
                temp-g.fact-qnty     = temp-g.fact-qnty     +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
      end.
              if V-TRN-TYPE = {&return} then do :
                temp-g.fact-qnty     = temp-g.fact-qnty     +  if available buf_doc-line then  buf_doc-line.fact-qnty else 0 .
  end.

  end.
  end.
end procedure. /* make-tt */