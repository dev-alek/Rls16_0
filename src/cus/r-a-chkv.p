block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-a-chkv.p $
$Archive: cus/r-a-chkv.p $

Отчет Aннуляция чеков и Возврат товара

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 04/26/05
*/

/*define input  parameter parparentproc as handle no-undo . */
define input  parameter p-par as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-a-chkv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-a-chkv.p $":U .
define variable vss-description as character no-undo init "Aннуляция чеков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
  /*my-handle = parparentproc. */
{ rep/rep-bt.i }
{ trg/factord.i }

define variable v-base-code as integer   no-undo .
define variable v-base-type as character no-undo .
v-base-code = base-code .
v-base-type = base-type .

define variable parhost-code as integer   no-undo .
parhost-code = v-cntxt-host-code-obj.


define temp-table tt-temp no-undo
field pay-desk    as integer /* № кассы */
field psn-name    as char /*раб кассир */
field fact-date   as date
field fact-time   as char /* время операции */
field src-code    as char /* код товара */
field d-card      as char /* дисконтная карта */
field sum-rubl    as decimal
field obj-code    as int   /* магазин */
field obj-type    as char
field sale-code    as char   /* Продавец*/
field sale-name    as char
field vid          as char
index pi
  obj-code
  obj-type
  fact-date
  fact-time
.

define stream  OutStream  .
define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x (60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define buffer This_Object for  ub.clients .

define variable num-ln as integer   no-undo .
define variable vv-sum   as decimal   no-undo .
define variable vv-count as decimal   no-undo .

define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable Lines_Counter as   int  init 0  no-undo.
define variable Tmp_Counter   as   int  init 0  no-undo.

define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .
define variable vv7 as character no-undo .
{ rep/r-sym.i }

define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .


define variable v-shap as character no-undo .
if p-par = "{&rcpt-annu}"   then  v-shap = "Сумма аннуляции" .
if p-par = "{&rcpt-return}" then v-shap = "Сумма возврата" .

DEFINE FRAME plan-menu
    HEADER
    string ( "Лист " + string ( PAGE-NUMBER (OutStream) , ">>>>9") ) AT 80 format "X (13)" SKIP
    UndLine format "X (80)" AT 1
    with width {&DOS_CW} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.

  if session:set-wait-state ("compiler") then.
    { cmp/open-out.i STREAM OutStream " " {&LS_PS_A4} }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill ("-", 230)
    UndLine = fill ("_", 230)
    LineBuf = fill ("_", 240)
  .

define variable v-is-base as logical no-undo .
{ gbl/rbisbase.i    v-is-base  }
if v-is-base = true then do:
end.
else do:
end.

/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .

FORM with frame plan-menu .



 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value (v-file-name)   .
    v-ind = v-ind + 1.


  find ub.clients      where ub.clients.obj-type     = {&cmp}            and ub.clients.obj-code      = parhost-code no-lock .
  run PrintTitul in this-procedure .
  run make-tt.
  /* по строкам -------------------------------------------------------------------------------------------- */
  for each obj-list :
      run print-obj.
      for each tt-temp where tt-temp.obj-type = obj-list.obj-type and tt-temp.obj-code = obj-list.obj-code :
          run print-line .
      end.
      run print-obj-itog.
  end.
  /*----------------------------------------------------------*/
  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure  (input 3) .
  run PrintPodval in this-procedure .
  run paramls-write in this-procedure
     (input "file"
    ,input string (v-ind)
    ,input v-file-name
    ) .
     page stream OutStream .

HIDE STREAM OutStream FRAME plan-menu.
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .
Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
         (input "charcol"
        ,input ""
        ,input "2,3,4,5,7"
        ) .

  run end-proc .
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  DisabledOptions = 8 .

  run gbl/prnfilen.w
     (  input  ""
     , input  DisabledOptions
     , input  string (session :temp-directory) + {&DF_Name} + string ( g#report-num )
     , input  7
     , output v-user-action
     , output v-printed
    )
    .

/* *************************************************************************************************** */
procedure print-line :
do on error undo, return error return-value :


  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter ( OutStream ) + 2 > page-size ( OutStream ) then do:
     run p-line.
     page stream OutStream.
     PUT STREAM OutStream UNFORMATTED
         string ( "Лист " + string ( PAGE-NUMBER (OutStream) , ">>>>9") ) AT 100 format "X (13)" SKIP .
     run print-1.
     end.

  if line-counter ( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter ( OutStream )
    num-ln = num-ln + 1
  .

  if line-counter ( OutStream ) + j > page-size ( OutStream ) then  PAGE STREAM OutStream.


PUT STREAM OutStream UNFORMATTED
    sym1                format "X (1)" space (0)
    string (tt-temp.pay-desk)      format "X (7)"
    sym2                format "X (1)" space (0)
    string (tt-temp.psn-name )     format "X (22)"
    sym3                format "X (1)" space (0)
   string (tt-temp.fact-date,"99/99/99") + " " + tt-temp.fact-time   format "X (22)"
   sym4                format "X (1)" space (0)
    string (tt-temp.src-code  )    format "X (15)"
    sym5                format "X (1)" space (0)
    string (tt-temp.d-card     )   format "X (18)"
    sym6                format "X (1)" space (0)
    string (tt-temp.sum-rubl    )  format "X (15)"
    .
    if p-par = "{&rcpt-return}" then do:
       PUT STREAM OutStream UNFORMATTED
       sym10                format "X (1)" space (0)
       string (tt-temp.vid    )  format "X (57)"
      .
    end.

    PUT STREAM OutStream UNFORMATTED
    sym7                format "X (1)" space (0)
    string (tt-temp.sale-code)     format "X (10)"
    sym8                format "X (1)" space (0)
    string (tt-temp.sale-name )    format "X (20)"
    sym9                format "X (1)" space (0)
    skip
.
    num#col# = 1.
    num#str# = num#str# + 1.

   run macr_excel_char (  tt-temp.pay-desk     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   run macr_excel_char (  tt-temp.psn-name     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   run macr_excel_char (  string (tt-temp.fact-date,"99/99/99") + " " + tt-temp.fact-time   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   run macr_excel_char (   tt-temp.src-code    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   run macr_excel_char (   tt-temp.d-card      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   run macr_excel_dec  (   tt-temp.sum-rubl    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   if p-par = "{&rcpt-return}" then do:
      run macr_excel_char (   tt-temp.VID      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   end.
   run macr_excel_char (   string (tt-temp.sale-code)    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   run macr_excel_char (   tt-temp.sale-name   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
   vv-sum   = vv-sum   + tt-temp.sum-rubl .

end.
end procedure. /* print-line */



procedure print-all-itog :
  /* Итоговые суммы */
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
PUT STREAM OutStream UNFORMATTED
space (1)
   ReportNAme skip
   "по фирме "  ub.clients.obj-name skip
   "за период "  x-date-start " по " x-date-end  skip
   "Дата составления " + cur-time-date ()  skip
    .

  define variable i as integer no-undo .
  define variable v-nn as integer   no-undo .
  v-nn = num-entries (reportheader,chr (10)) .
  repeat i = 1 to v-nn :
    put stream outstream unformatted  entry (i,reportheader,chr (10))  at 1 format "x (90)" skip.
  end.

    num#str# = 1.
    num#col# = 1.
    run macr_excel_char ( Reportname , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( "по фирме " + CAPS ( ub.clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( "За период " + string (x-date-start) + " по " +  string (x-date-end)  , num#str# , num#col# ) .
    num#str# = num#str# + 1.

    run macr_excel_char ( ReportHeader , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ("Дата составления " + cur-time-date ()   , num#str# , num#col#   ) .

/* шапка */

    num#str# = num#str# + 1.
    run macr_excel_char ("№ кассы"  , num#str# , num#col#   ) .    run macr_cell_size  ( 5 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char ("ФИО кассира"  , num#str# , num#col#   ) .  run macr_cell_size  ( 20 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char ("Дата и время операции"  , num#str# , num#col#   ) . run macr_cell_size  ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char ("Код товара"  , num#str# , num#col#   ) . run macr_cell_size  ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char ("№ Дисконтной карты"  , num#str# , num#col#   ) . run macr_cell_size  ( 20 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char (v-shap  , num#str# , num#col#   ) . run macr_cell_size  ( 15 , ? , num#str# , num#col# , ?, ? ) .

    if p-par = "{&rcpt-return}" then do:
      num#col# = num#col# + 1.
      run macr_excel_char (  "Вид оплаты"      , num#str# , num#col#   ) . run macr_cell_size  ( 10 , ? , num#str# , num#col# , ?, ? ) .
    end.
    num#col# = num#col# + 1.
    run macr_excel_char ("№ продавца"  , num#str# , num#col#   ) . run macr_cell_size  ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = num#col# + 1.
    run macr_excel_char ("ФИО продавца"  , num#str# , num#col#   ) . run macr_cell_size  ( 35 , ? , num#str# , num#col# , ?, ? ) .

  run print-1 .


    run macr_cell_format
     ( 10    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      1 , /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      num#col# ) .      /* p-col-2    */

     put  stream macr_excel unformatted
       substitute ('select ("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER ( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT (3 , , 4 , 4 ,)'  + {&new-line}
       .
    put  stream macr_excel unformatted
       substitute ('select ("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  3 ) + {&new-line}  +
       'BORDER ( 2, , , , , , , , , , ) '  + {&new-line} .

    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .
/*    run p-line . */

    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size ( OutStream ) then return .
  if line-counter ( OutStream ) + p-line-number > page-size ( OutStream ) then do:

    run p-line .
    page stream OutStream .
    end.
end procedure. /* on-same-page */

procedure print-1 :
/* шапка текстового файла  */

  do
  on error undo, return error return-value
  :
    run p-line .
    PUT STREAM OutStream UNFORMATTED  ":№ кассы"  AT 1          format "X (8)" .
    PUT STREAM OutStream UNFORMATTED  ":ФИО кассира"            format "X (23)" .
    PUT STREAM OutStream UNFORMATTED  ":Дата и время операции"  format "X (23)" .
    PUT STREAM OutStream UNFORMATTED  ":Код товара"             format "X (16)" .
    PUT STREAM OutStream UNFORMATTED  ":№ Дисконтной карты"     format "X (19)" .
    PUT STREAM OutStream UNFORMATTED  ":" + v-shap              format "X (16)" .
    if p-par = "{&rcpt-return}" then do:
       PUT STREAM OutStream UNFORMATTED  ":Вид оплаты"          format "X (59)" .
    end.
    PUT STREAM OutStream UNFORMATTED  ":№ продавца"             format "X (11)" .
    PUT STREAM OutStream UNFORMATTED  ":ФИО продавца        :"  format "X (22)" .
    PUT STREAM OutStream UNFORMATTED  skip .
    run p-line .

  end.

end procedure. /* print-1 */

procedure p-line :

  do
  on error undo, return error return-value
  :
    PUT STREAM OutStream UNFORMATTED  fill ("-",8)  AT 1  format "X (8)".
    PUT STREAM OutStream UNFORMATTED  fill ("-",23)        format "X (23)".
    PUT STREAM OutStream UNFORMATTED  fill ("-",23)        format "X (23)".
    PUT STREAM OutStream UNFORMATTED  fill ("-",16)        format "X (16)".
    PUT STREAM OutStream UNFORMATTED  fill ("-",19)        format "X (19)".
    PUT STREAM OutStream UNFORMATTED  fill ("-",16)        format "X (16)".
    if p-par = "{&rcpt-return}" then do:
       PUT STREAM OutStream UNFORMATTED  fill ("-",60)        format "X (59)".
    end.
    PUT STREAM OutStream UNFORMATTED  fill ("-",11)        format "X (11)".
    PUT STREAM OutStream UNFORMATTED  fill ("-",22)        format "X (22)".
    PUT STREAM OutStream UNFORMATTED  skip .

  end.

end procedure. /* p-line */

procedure print-obj :

  do
  on error undo, return error return-value
  :
  PUT STREAM OutStream UNFORMATTED  Obj-list.obj-name  at 1    format "X (26)" skip.
    num#str# = num#str# + 1 .
    num#col# = 1.
    run macr_excel_char ( Obj-list.obj-name  , num#str# , num#col#   ) .
    run macr_cell_size  ( 26 , ? , num#str# , num#col# , ?, ? ) .
  end.

end procedure. /* print-obj */

procedure make-tt :

  do
  on error undo, return error return-value
  :

define buffer buf_chk-doc for ub.chk-doc  .
define buffer buf_chk-gds for ub.chk-gds  .
define buffer buf_psn-clients for ub.clients  .
define buffer buf_sale-clients for ub.clients  .
define buffer buf_chk-pay for ub.chk-pay  .
define variable v-sum as decimal   no-undo .
define variable jj as integer   no-undo init 0.
define variable v-vid as character no-undo .
define variable vvv as integer   no-undo .
define variable v-par as character no-undo .
v-par = trim (p-par,"':u").
v-par = LEFT-TRIM (v-par,"'").

for each obj-list :
  for each buf_chk-doc no-lock where
      buf_chk-doc.obj-type = obj-list.obj-type and
      buf_chk-doc.obj-code = obj-list.obj-code and
      buf_chk-doc.chk-date <= x-date-end and
      buf_chk-doc.chk-date >= x-date-start
      and
      buf_chk-doc.chk-type = int (v-par)

  :

find first buf_psn-clients no-lock  where
           buf_psn-clients.obj-code = buf_chk-doc.cashier-psn-code  and
           buf_psn-clients.obj-type = {&prs} no-error .

find first buf_sale-clients no-lock  where
           buf_sale-clients.obj-code = buf_chk-doc.salesman-psn-code  and
           buf_sale-clients.obj-type = {&prs} no-error .


v-vid = "" .

for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code break
     by  buf_chk-pay.pay-code
     by  buf_chk-pay.curr-code
:
 if first-of (buf_chk-pay.curr-code) then do:
    find first ub.cash-pay no-lock where
       ub.cash-pay.cdpay-code =   buf_chk-pay.pay-code and
       ub.cash-pay.curr-code  =   buf_chk-pay.curr-code  no-error .
       if available ub.cash-pay then
          v-vid = v-vid +  ub.cash-pay.obj-name + /* string (ub.cash-pay.cdpay-code) + "$" + string (ub.cash-pay.curr-code) + */ ","  .
 end.
end.

v-vid =  trim (v-vid,",") .

        for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code :
        if p-par = "{&rcpt-annu}"  then
           v-sum =  (buf_chk-gds.src-price * buf_chk-gds.src-qnty) -  (buf_chk-gds.src-discnt * buf_chk-gds.src-qnty) .
        else
           v-sum =  (buf_chk-gds.price-base * buf_chk-gds.doc-qnty) -  (buf_chk-gds.discnt * buf_chk-gds.doc-qnty) .

            jj = jj + 1.
           { rep/repfrm.i disp JJ obj-list.obj-name }
          create tt-temp.
          assign
              tt-temp.pay-desk  = buf_chk-doc.pay-desk
              tt-temp.psn-name  = if available  buf_psn-clients then buf_psn-clients.obj-name else ""
              tt-temp.fact-date = buf_chk-doc.chk-date
              tt-temp.fact-time = string  ( buf_chk-doc.chk-time , "hh:mm" )
              tt-temp.src-code  = buf_chk-gds.src-code
              tt-temp.d-card    = if  buf_chk-doc.d-card = ? then  buf_chk-doc.src-d-card else  buf_chk-doc.d-card
              tt-temp.sum-rubl  = v-sum
              tt-temp.obj-code  = buf_chk-doc.obj-code
              tt-temp.obj-type  = buf_chk-doc.obj-type
              tt-temp.sale-code = if buf_chk-doc.salesman-psn-code <> ? then string (buf_chk-doc.salesman-psn-code) else ""
              tt-temp.sale-name = if available buf_sale-clients then buf_sale-clients.obj-name else ""
              tt-temp.vid       = v-vid
          .
        end.
     end.
  end.
end.
end procedure. /* make-tt */

procedure print-obj-itog :

  do
  on error undo, return error return-value
  :
  run p-line .
  PUT STREAM OutStream UNFORMATTED  "Итого по " + Obj-list.obj-name + " : "  + string (vv-sum) + " " + v-base-type  at 1    format "X (100)" skip.
    num#str# = num#str# + 1 .
    num#col# = 1.
    run macr_excel_char ( "Итого по " + Obj-list.obj-name + " : "  + string (vv-sum) + " " +  v-base-type ,  num#str# , num#col#   ) .
    run macr_cell_size  ( 26 , ? , num#str# , num#col# , ?, ? ) .
    vv-sum   = 0 .
    vv-count = 0 .
   run p-line .

  end.

end procedure. /* print-obj-itog */

{ rep/r-libmcr.i macr_excel         }