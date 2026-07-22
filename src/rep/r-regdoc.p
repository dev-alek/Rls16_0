block-level on error undo, throw.
/*

$Revision: bc54e1f2bf34, 3466, rls $
$Author: EShklyar $
$Date: 2023/10/16 15:13:34 $
$Workfile: r-regdoc.p $
$Archive: rep/r-regdoc.p $

Реестр документов расширенный

Автор: Комаров Иван Сергеевич
Дата создания: 12/28/09
Author: Ivan Komarov
Creation date: 12/28/09

*/

{ rep/reg-par.i }
{ gbl/twowin.i  }

define input parameter x-store-code like ub.clients.obj-code no-undo.      /* текущий объект    */
define input parameter x-store-type like ub.clients.obj-type no-undo.      /* текущий объект    */
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.    /* валюта текущей фирмы */
define input parameter x-base-code  like ub.currency.curr-code no-undo.    /* валюта текущей фирмы */
define input parameter VAT-PC       as logical no-undo.                    /* НДС детально      */
define input parameter radio-serv   as integer no-undo.                    /* Услуги-товары     */
define input parameter NullPer      as logical no-undo.                    /* Нулевые переоценки */
define input parameter CalcRest     as logical no-undo.                    /* Расчет остатков   */
define input parameter table        for    temp_twowin_itemsSelected_col.  /* выбранные столбцы */
define input parameter table        for    g#post-f.                       /* поставщики        */
define input parameter rz-objecte   as logical no-undo.                    /* раздельно по объектам */
define input parameter p-sel-gds    as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: bc54e1f2bf34, 3466, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:34 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-regdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-regdoc.p $":U .
define variable vss-description as character no-undo init "Реестр документов расширенный".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ gbl/waitfram.i }
{ rep/fmtcli.i   }
{ ref/grplibfn.i }
{ str/trdcalib.i }
{ str/clcprtsl.i }
{ trg/factord.i  }
{ trg/partslib.i }

define variable g#report-num as integer   no-undo .

define variable v-col01    as logical      no-undo init "yes".
define variable v-col02    as logical      no-undo init "yes".
define variable v-col03    as logical      no-undo init "no".
define variable v-col04    as logical      no-undo init "no".
define variable v-col05    as logical      no-undo init "no".
define variable v-col06    as logical      no-undo init "no".
define variable v-col07    as logical      no-undo init "yes".
define variable v-col08    as logical      no-undo init "no".
define variable v-col09    as logical      no-undo init "no".
define variable v-col10    as logical      no-undo init "no".
define variable v-col11    as logical      no-undo init "no".
define variable v-col12    as logical      no-undo init "no".
define variable v-col13    as logical      no-undo init "no".
define variable v-col14    as logical      no-undo init "no".
define variable v-col15    as logical      no-undo init "no".
define variable v-col16    as logical      no-undo init "no".
define variable v-col17    as logical      no-undo init "no".
define variable v-col18    as logical      no-undo init "no".
define variable v-col19    as logical      no-undo init "no".
define variable v-col20    as logical      no-undo init "no".
define variable v-col21    as logical      no-undo init "no".
define variable v-col22    as logical      no-undo init "no".
define variable v-col23    as logical      no-undo init "no".

define variable ObjName    as character    no-undo .
define variable i          as integer      no-undo .
define variable ValType    as integer      no-undo .
define variable tPrintRubl as logical      no-undo .

define variable v-fact-order-start like ub.stk-tot.Fact-order no-undo.
define variable v-fact-order-end   like ub.stk-tot.Fact-order no-undo.

define variable v-full-type          as character    no-undo.
define variable v-code-attr          as character    no-undo.
define variable v-code-attr-post     as character    no-undo.
define variable v-date-post          as character    no-undo.
define variable v-reas-name          as character    no-undo.
define variable v-sf-doc-code        as character    no-undo.
define variable v-sf-doc-date        as character    no-undo.
define variable v-attr-type          as character    no-undo.
define variable v-clients            as character    no-undo.
define variable v-qnty               as decimal      no-undo.
define variable discnt-sum           as decimal      no-undo.
define variable v-host-code-1        like ub.clients.host-code no-undo .
define variable v-host-code-2        like ub.clients.host-code no-undo .

define variable v-log    as logical   no-undo.
define variable v-col-1  as integer   no-undo .
define variable v-col-2  as integer   no-undo .
define variable v-col-3  as integer   no-undo .
define variable v-col-4  as integer   no-undo .
define variable l-ii     as integer   no-undo .
define variable l-jj     as integer   no-undo .
define variable l-len    as integer   no-undo .
define variable l-m      as integer   no-undo .
define variable var-1    as integer   no-undo .
define variable var-2    as integer   no-undo .
define variable v-ind    as integer   no-undo .
define variable C-c      as integer   no-undo .
define variable C-str    as character no-undo .
define variable str--1   as character format "x(60)" no-undo.
define variable str--2   as integer   no-undo .
define variable C-i      as integer   no-undo .
define variable p-var    as integer   no-undo .
define variable num#col# as integer   no-undo .
define variable v-file-name     as character no-undo .
define variable v-file-name-1   as character no-undo .
define variable v-file-name-ind as integer   no-undo .

define variable v-user-action     as character no-undo .
define variable v-printed         as logical   no-undo .
define variable disabledoptions   as integer   no-undo .
define variable v-orient-page     as character no-undo .

define variable v-dop-par    as character  no-undo.
define variable v-gds-sel    as character  no-undo.
define variable v-str-excel  as character  no-undo.
define variable v-str-excel1 as character  no-undo.

define variable pobj-type             like ub.shift-obj.obj-type   no-undo .
define variable pobj-code             like ub.shift-obj.obj-code   no-undo .
define variable pshift-date           like ub.shift-obj.shift-date no-undo .
define variable pshift-num            like ub.shift-obj.shift-num  no-undo .
DEFINE variable pshift-date1          like shift-obj.shift-date    no-undo .
DEFINE variable pshift-num1           like shift-obj.shift-num     no-undo .
define variable p-previous-shift-date as   date                    no-undo .

define temp-table tt-all no-undo
   field col01-doc-date              as date
   field col02-num                   as character
   field col03-code-attr-post        as character
   field col04-code-attr             as character
   field col05-sf-doc-date           as date
   field col06-sf-doc-code           as character
   field col07-clients               as character
   field col08-VAT-PC                as decimal
   field col09-qnty                  as decimal
   field col10-SumWithNDS-coast      as decimal
   field col11-VAT-Sum-coast         as decimal
   field col12-SumWithoutNDS-coast   as decimal
   field col13-SumWithNDS            as decimal
   field col14-VAT-Sum               as decimal
   field col15-SumWithoutNDS         as decimal
   field col16-SumWithNDS-sp         as decimal
   field col17-VAT-Sum-sp            as decimal
   field col18-SumWithoutNDS-sp      as decimal
   field col19-discnt-sum            as decimal
   field col20-SumWithNDS-disp       as decimal
   field col21-SumWithoutNDS-disp    as decimal
   field col22-reason                as character
   field col23-date-post             as date
/*   field col23-ov-sum                as decimal */
   field doc-type                    AS character
   field obj-type                    AS character
   field obj-code                    as integer

   INDEX pi IS primary unique
         obj-type
         obj-code
         doc-type
         col02-num
         col08-VAT-PC
   index type
         doc-type
         obj-type
         col02-num
         col08-VAT-PC
.

define temp-table tt-itog no-undo
   field obj-type          as character
   field obj-code          as integer
   field obj-name          as character
   field SumWithNDS-cost   as decimal
   field SumWithNDS-sale   as decimal
   field SumWithNDS-crsa   as decimal
   field VAT-cost          as decimal
   field VAT-sale          as decimal
   field VAT-crsa          as decimal
   field col09-qnty        as decimal
   field vat-pc            as character
   field begin             as logical
   INDEX pi IS primary unique
         begin
         obj-type
         obj-code
         vat-pc
.
define temp-table tt-gds LIKE gds-list .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1))
:

   define stream  OutStream  .
   define stream macr_excel .
/*   define stream  St-1  .*/
/*   output stream st-1 to parts-1.txt .*/

   define variable parparentproc  as handle  no-undo .

   assign parparentproc = my-handle .
    assign
        pshift-date  = x-date-start 
        pshift-num   = x-shift-start 
        pshift-date1 = x-date-end 
        pshift-num1  = x-shift-end 
        . 

  /* !!! смены */
  run day-begin-fact-order in this-procedure ( input x-date-start      , output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

   /* выбираем валюту */
   CASE x-SET_val_TYPE :
      WHEN {&v-rubl} then do:
         assign
            tPrintRubl = YES
         .
      end.
      WHEN {&v-base} then do:
         assign
            tPrintRubl = NO
         .
      end.
   end CASE.

   assign
      i             = 0
      ValType       = if (x-SET_PAY_TYPE = 1) then 0  else x-SET_val_TYPE
   .
   /*print*/
   end.

 run report-execute .
/*--------------------------------- */
 { rep/f-fdec.i }
{ rep/f-flav.i }
/*--------------------------------- */
 procedure report-execute .

   run waitfram-show in this-procedure ( "Выбор колонок...":U ) .
   run col-select in this-procedure.

   run get-report-num in my-handle ( output g#report-num ).

   /* товары или услуги */
   if radio-serv = 1
   then do :
      run create-goods in this-procedure.
   end.
   else do:
      run create-favour in this-procedure.
   end.
   { cmp/open-out.i stream OutStream  " " ReportPageHeight }

  assign
    make-excel      = yes
   /* v-file-name     = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"*/
    v-file-name-ind = 1
  .

   run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .

   output stream macr_excel to value(v-file-name).

   run waitfram-show in this-procedure ( "Заголовок...":U ) .
   run print-header  in this-procedure.
   run display-title in this-procedure.

   run put-stick     in this-procedure.

   run columntitle   in this-procedure .

   run waitfram-show in this-procedure ( "Расчет":U ) .
   run create-report in this-procedure .

   run put-stick     in this-procedure.

   run waitfram-show in this-procedure ( "Подвал":U ) .
  /* run print-footer in this-procedure.  */

   run waitfram-hide in this-procedure .

   HIDE STREAM OutStream FRAME docsRep .
   output stream OutStream close.
   Output stream Macr_Excel  close .

  run paramls-write  in this-procedure
  (input  "file"
  ,input  string(v-file-name-ind)
  ,input  v-file-name
  ) .

  run end-proc in this-procedure .

  run gbl/prnfilen.w
         ( input  ""
         , input  8
         , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
         , input  ReportFontNum
         , output v-user-action
         , output v-printed
         ) .
  os-delete value( string(session :temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

end procedure.
/*==========================================================================*/
procedure col-select :
do
on error undo, return error
:
   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&N-doc-post}
        no-lock
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col03 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&d-doc-post}
        no-lock
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col23 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&N-doc-print}
        no-lock
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col04 = yes.

   find first temp_twowin_itemsSelected_col
        no-lock
        where temp_twowin_itemsSelected_col.itmExtKey = {&d-sf}
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col05 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&N-sf}
        no-lock
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col06 = yes.

   if VAT-PC = yes then v-col08 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&qnty}
        no-lock
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col09 = yes.

   find first temp_twowin_itemsSelected_col
        no-lock
        where temp_twowin_itemsSelected_col.itmExtKey = {&sum-vat}
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Cost = true then v-col10 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&vat}
        no-lock
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Cost = true then v-col11 = yes.

   find first temp_twowin_itemsSelected_col
        no-lock
        where temp_twowin_itemsSelected_col.itmExtKey = {&sum-no-vat}
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Cost = true then v-col12 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&sum-vat}
        no-lock
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Sale = true then v-col13 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&vat}
        no-lock
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Sale = true then v-col14 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&sum-no-vat}
        no-lock
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Sale = true then v-col15 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&sum-vat}
        no-lock
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Crsa = true then v-col16 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&vat}
        no-lock
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Crsa = true then v-col17 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&sum-no-vat}
        no-lock
        no-error
        .
   if  available temp_twowin_itemsSelected_col
   and Show-Crsa = true then v-col18 = yes.

   find first temp_twowin_itemsSelected_col
        where temp_twowin_itemsSelected_col.itmExtKey = {&sum-discount}
        no-lock
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col19 = yes.

   /*
   find first temp_twowin_itemsSelected_col
        no-lock
        where temp_twowin_itemsSelected_col.itmExtKey = {&sum-auto-mrgn}
        no-error
        .
   if available temp_twowin_itemsSelected_col
   then do:
      v-col23 = yes.
   end.
   */

   find first temp_twowin_itemsSelected_col
        no-lock
        where temp_twowin_itemsSelected_col.itmExtKey = {&mark-up}
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col20 = yes.

   find first temp_twowin_itemsSelected_col
        no-lock
        where temp_twowin_itemsSelected_col.itmExtKey = {&mark-up-noNDS}
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col21 = yes.

   find first temp_twowin_itemsSelected_col
        no-lock
        where temp_twowin_itemsSelected_col.itmExtKey = {&reason}
        no-error
        .
   if available temp_twowin_itemsSelected_col then v-col22 = yes.

end. /* do on error */
end procedure. /* col-select */

/*----------------------------*/
procedure ColumnTitle :
do on error undo, return error return-value
:
   define variable v-column  as character    no-undo .
   define variable v-size    as character    no-undo .

   run col-select in this-procedure.

    assign
      num#col# = 0
   .
   if v-col01 = yes
   then do:
      PUT stream OutStream "|"  "Дата"                     format "X(10)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Дата"    + {&comma-char}
         v-size = v-size + "10" + {&comma-char}
      .
   end.
   if v-col02 = yes  then do: PUT stream OutStream "|"  "Номер"                    format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Номер"    + {&comma-char}
         v-size = v-size + "15" + {&comma-char}
      .
   end.
   if v-col03 = yes  then do: PUT stream OutStream "|"  "Номер док-та "            format "X(20)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Номер док-та поставщика"    + {&comma-char}
         v-size = v-size + "18" + {&comma-char}
      .
   end.
   if v-col23 = yes then do: PUT stream OutStream  "|"  "Дата документа"           format "X(10)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Дата документа поставщика"    + {&comma-char}
         v-size = v-size + "12" + {&comma-char}
      .
   end.
   if v-col04 = yes  then do: PUT stream OutStream "|"  "Номер док-та "            format "X(20)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Номер док-та для печати"    + {&comma-char}
         v-size = v-size + "20" + {&comma-char}
      .
   end.
   if v-col05 = yes  then do: PUT stream OutStream "|"  "Счет-факт."               format "X(10)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Счет-факт. дата"    + {&comma-char}
         v-size = v-size + "10" + {&comma-char}
      .
   end.
   if v-col06 = yes  then do: PUT stream OutStream "|"  "Счет-факт."               format "X(10)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Счет-факт. номер"    + {&comma-char}
         v-size = v-size + "10" + {&comma-char}
      .
   end.
   if v-col07 = yes  then do: PUT stream OutStream "|"  "Контрагент"               format "X(50)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Контрагент"    + {&comma-char}
         v-size = v-size + "50" + {&comma-char}
      .
   end.
   if v-col08 = yes  then do: PUT stream OutStream "|"  "Ставка"                   format "X(6)"   .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Ставка НДС"    + {&comma-char}
         v-size = v-size + "7" + {&comma-char}
      .
   end.
   if v-col09 = yes  then do: PUT stream OutStream "|"  "Количество"               format "X(10)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Количество"    + {&comma-char}
         v-size = v-size + "11" + {&comma-char}
      .
   end.
   if v-col10 = yes then do: PUT stream OutStream  "|"  "Сумма с НДС"              format "X(18)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма с НДС в уч. ценах"    + {&comma-char}
         v-size = v-size + "15" + {&comma-char}
      .
   end.
   if v-col11 = yes then do: PUT stream OutStream  "|"  "Сумма НДС"                format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма НДС в уч. ценах"    + {&comma-char}
         v-size = v-size + "12" + {&comma-char}
      .
   end.
   if v-col12 = yes then do: PUT stream OutStream  "|"  "Сумма без НДС"            format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма без НДС в уч. ценах"    + {&comma-char}
         v-size = v-size + "13" + {&comma-char}
      .
   end.
   if v-col13 = yes then do: PUT stream OutStream  "|"  "Сумма с НДС"              format "X(18)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма с НДС в ценах док-та"    + {&comma-char}
         v-size = v-size + "15" + {&comma-char}
      .
   end.
   if v-col14 = yes then do: PUT stream OutStream  "|"  "Сумма НДС"                format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма НДС в ценах док-та"    + {&comma-char}
         v-size = v-size + "12" + {&comma-char}
      .
   end.
   if v-col15 = yes then do: PUT stream OutStream  "|"  "Сумма без НДС"            format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма без НДС в ценах док-та"    + {&comma-char}
         v-size = v-size + "13" + {&comma-char}
      .
   end.
   if v-col16 = yes then do: PUT stream OutStream  "|"  "Сумма с НДС"              format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма с НДС в прод. ценах"    + {&comma-char}
         v-size = v-size + "12" + {&comma-char}
      .
   end.
   if v-col17 = yes then do: PUT stream OutStream  "|"  "Сумма НДС"                format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма НДС в прод. ценах"    + {&comma-char}
         v-size = v-size + "12" + {&comma-char}
      .
   end.
   if v-col18 = yes then do: PUT stream OutStream  "|"  "Сумма без НДС"            format "X(15)"  .
         assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма без НДС в прод. ценах"    + {&comma-char}
         v-size = v-size + "13" + {&comma-char}
      .
   end.
   if v-col19 = yes then do: PUT stream OutStream  "|"  "Сумма скидки"             format "X(10)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Сумма скидки"    + {&comma-char}
         v-size = v-size + "10" + {&comma-char}
      .
   end.
   if v-col20 = yes then do: PUT stream OutStream  "|"  "Наценка"                  format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Наценка с НДС"    + {&comma-char}
         v-size = v-size + "13" + {&comma-char}
      .
   end.
   if v-col21 = yes then do : PUT stream OutStream  "|"  "Наценка"                  format "X(15)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Наценка без НДС"    + {&comma-char}
         v-size = v-size + "15" + {&comma-char}
      .
   end.
   if v-col22 = yes then do: PUT stream OutStream  "|"  "Основание"                format "X(30)"  .
      assign
         num#col# = num#col# + 1
         v-column = v-column + "Основание"          + {&comma-char}
         v-size = v-size + "11" + {&comma-char}
      .
   end.

   PUT stream OutStream "|"   skip .

   assign num#col# = 0 .

   if v-col01 = yes then do :
      PUT stream OutStream  "|"  ""                       format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col02 = yes then do :
      PUT stream OutStream  "|"  ""                       format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col03 = yes then do :
      PUT stream OutStream  "|"  "поставщика"             format "X(20)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col23 = yes then do:
      PUT stream OutStream  "|"  "поставщика"             format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col04 = yes then do :
      PUT stream OutStream  "|"  "для печати"             format "X(20)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col05 = yes then do :
      PUT stream OutStream  "|"  "дата"                   format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col06 = yes then do :
      PUT stream OutStream  "|"  "номер"                  format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col07 = yes then do :
      PUT stream OutStream  "|"  ""                       format "X(50)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col08 = yes then do :
      PUT stream OutStream  "|"  " НДС"                    format "X(6)"   .
      assign num#col# = num#col# + 1 .
   end.
   if v-col09 = yes then do :
      PUT stream OutStream  "|"  ""                        format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col10 = yes then do :
      PUT stream OutStream  "|"  "в уч. ценах"             format "X(18)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col11 = yes then do :
      PUT stream OutStream  "|"  "в уч. ценах"             format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col12 = yes then do :
      PUT stream OutStream  "|"  "в уч. ценах"             format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col13 = yes then do :
      PUT stream OutStream  "|"  "В ценах док-та"          format "X(18)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col14 = yes then do :
      PUT stream OutStream  "|"  "в ценах док-та"          format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col15 = yes then do :
      PUT stream OutStream  "|"  "в ценах док-та"          format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col16 = yes then do :
      PUT stream OutStream  "|"  "в прод. ценах"           format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col17 = yes then do :
      PUT stream OutStream  "|"  "в прод. ценах"           format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col18 = yes then do :
      PUT stream OutStream  "|"  "в прод. ценах"           format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col19 = yes then do :
      PUT stream OutStream  "|"  ""                        format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col20 = yes then do :
      PUT stream OutStream  "|"  "с НДС"                   format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col21 = yes then do :
      PUT stream OutStream  "|"  "без НДС"                 format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col22 = yes then do :
      PUT stream OutStream  "|"  ""                        format "X(30)"  .
      assign num#col# = num#col# + 1 .
   end.
   PUT stream OutStream "|"   skip .
   RUN put-stick in this-procedure.
   assign
      v-size   = TRIM(v-size, {&comma-char})
      sheetf.Excel-Column-Lable  = v-column
      sheetf.sizes               = v-size
   .
end.
assign sheetf.Excel-Column-Lable  = substring(v-column, 1, (length(v-column) - 1)) .

run proc-print-header in this-procedure .
end procedure. /* ColumnTitle */

/*==========================================================================*/
procedure put-stick :
do
on error undo, return error
:

   if v-col01 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(11)"  .
   if v-col02 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col03 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(21)"  .
   if v-col23 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(11)"  .
   if v-col04 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(21)"  .
   if v-col05 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(11)"  .
   if v-col06 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(11)"  .
   if v-col07 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(51)"  .
   if v-col08 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(7)"  .
   if v-col09 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(11)"  .
   if v-col10 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(19)"  .
   if v-col11 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col12 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col13 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(19)"  .
   if v-col14 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col15 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col16 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col17 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col18 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col19 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(11)"  .
   if v-col20 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col21 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(16)"  .
   if v-col22 = yes then PUT stream OutStream  fill( "-" , 50 )             format "X(31)"  .
   PUT stream OutStream skip.

end. /* do on error */
end procedure. /* put-stick */

/*==========================================================================*/
procedure create-report :
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_clients     for ub.clients .
define buffer buf_price-doc   for ub.price-doc .

do
on error undo, return error
:

   /* подсчет остатков на начало */
   if CalcRest
   then do:
      run waitfram-show in this-procedure ( "Расчет остатков на начало периода":U ) .
      run ostatok IN THIS-PROCEDURE (INPUT v-fact-order-start, TRUE).
   end.

   /* подсчет остатков на конец */
   if CalcRest
   then do:
      run waitfram-show in this-procedure ( "Расчет остатков на конец периода":U ) .
      run ostatok IN THIS-PROCEDURE (INPUT v-fact-order-end, FALSE).
   end.

   run waitfram-show in this-procedure ( "Расчет отчета":U ) .
   /* нет разбивки по объектам */
   if NOT rz-objecte
   then do :
      /* выбранные типы документов */
      for each  tdedt
         where tdedt.id <> {&TDEDT_Overturn}
         no-lock
         :
         /* все поставщики */
         if NOT CAN-find( first g#post-f )
         then do :

            for EACH obj-list:
                if x-TOG-Shift then 
                do:
                    run factshift (obj-list.obj-code, obj-list.obj-type) no-error.
                    if error-status:error then next .

                end.        
               
              for EACH  buf_trn-doc
               where buf_trn-doc.obj-type     = obj-list.obj-type
                 and buf_trn-doc.obj-code     = obj-list.obj-code
                 and buf_trn-doc.ext-doc-type = tdedt.id
                 and buf_trn-doc.fact-order  >= v-fact-order-start
                 and buf_trn-doc.fact-order  <= v-fact-order-end
               :
                  find first buf_clients
                       where buf_clients.obj-type = buf_trn-doc.cli-type
                         and buf_clients.obj-code = buf_trn-doc.cli-code
                       NO-LOCK
                       NO-ERROR
                       .
                  RUN calc-doc in this-procedure ( INPUT buf_trn-doc.ext-doc-type
                                                 , INPUT buf_trn-doc.doc-code
                                                 , INPUT buf_trn-doc.obj-type
                                                 , INPUT buf_trn-doc.obj-code
                                                 , INPUT buf_trn-doc.fact-date
                                                 , INPUT if AVAILABLE buf_clients then buf_clients.obj-name else "":U
                                                 , INPUT buf_trn-doc.fact-order
                                                 , INPUT buf_trn-doc.host-code
                                                 , INPUT buf_trn-doc.reason-code
                                                 , INPUT buf_trn-doc.base-rate
                                                 , INPUT buf_trn-doc.base-scale
                                                 ) .
            end.
            end.
         end. /* все поставщики */
         /* выбраны поставщики */
         else do :
            for EACH obj-list:
                if x-TOG-Shift then 
                do:
                    run factshift (obj-list.obj-code, obj-list.obj-type) no-error.
                    if error-status:error then next .

                end.  
                for EACH g#post-f
                    ,
               EACH  buf_trn-doc
               where buf_trn-doc.obj-type     = obj-list.obj-type
                 and buf_trn-doc.obj-code     = obj-list.obj-code
                 and buf_trn-doc.ext-doc-type = tdedt.id
                 and buf_trn-doc.cli-type     = g#post-f.obj-type
                 and buf_trn-doc.cli-code     = g#post-f.obj-code
                 and buf_trn-doc.fact-order  >= v-fact-order-start
                 and buf_trn-doc.fact-order  <= v-fact-order-end
               :

                  find first buf_clients
                       where buf_clients.obj-type = buf_trn-doc.cli-type
                         and buf_clients.obj-code = buf_trn-doc.cli-code
                       NO-LOCK
                       NO-ERROR
                       .
                  RUN calc-doc in this-procedure ( INPUT buf_trn-doc.ext-doc-type
                                                 , INPUT buf_trn-doc.doc-code
                                                 , INPUT buf_trn-doc.obj-type
                                                 , INPUT buf_trn-doc.obj-code
                                                 , INPUT buf_trn-doc.fact-date
                                                 , INPUT if AVAILABLE buf_clients then buf_clients.obj-name else "":U
                                                 , INPUT buf_trn-doc.fact-order
                                                 , INPUT buf_trn-doc.host-code
                                                 , INPUT buf_trn-doc.reason-code
                                                 , INPUT buf_trn-doc.base-rate
                                                 , INPUT buf_trn-doc.base-scale
                                                 ) .

            end.
            end.
         end. /* выбраны поставщики */
      end. /* each tdedt */

      for each  tdedt
          where tdedt.id = {&TDEDT_Overturn}
         no-lock
         :

         if NOT CAN-find( first g#post-f )
         then do :
            for EACH obj-list:
                if x-TOG-Shift then 
                do:
                    run factshift (obj-list.obj-code, obj-list.obj-type) no-error.
                    if error-status:error then next .

                end.                  
               
               for EACH  buf_price-doc
               where buf_price-doc.obj-type     = obj-list.obj-type
                 and buf_price-doc.obj-code     = obj-list.obj-code
                 and buf_price-doc.fact-order  >= v-fact-order-start
                 and buf_price-doc.fact-order  <= v-fact-order-end
               :
                  RUN calc-doc in this-procedure ( INPUT {&TDEDT_Overturn}
                                                 , INPUT buf_price-doc.doc-num
                                                 , INPUT buf_price-doc.obj-type
                                                 , INPUT buf_price-doc.obj-code
                                                 , INPUT buf_price-doc.fact-date
                                                 , INPUT "":U
                                                 , INPUT buf_price-doc.fact-order
                                                 , INPUT buf_price-doc.host-code
                                                 , INPUT 0
                                                 , INPUT 0
                                                 , INPUT 0
                                                 ) .
            end.
            end.
         end. /* все поставщики */
         /* выбраны поставщики
         else do:

            for EACH obj-list
               ,
               EACH g#post-f
               ,
               EACH  buf_price-doc
               where buf_price-doc.obj-type     = obj-list.obj-type
                 and buf_price-doc.obj-code     = obj-list.obj-code
                 and buf_price-doc.fact-order  >= v-fact-order-start
                 and buf_price-doc.fact-order  <= v-fact-order-end
               :

                  RUN calc-doc in this-procedure ( INPUT {&TDEDT_Overturn}
                                                 , INPUT buf_price-doc.doc-num
                                                 , INPUT buf_price-doc.obj-type
                                                 , INPUT buf_price-doc.obj-code
                                                 , INPUT buf_price-doc.fact-date
                                                 , INPUT "":U
                                                 , INPUT buf_price-doc.fact-order
                                                 , INPUT buf_price-doc.host-code
                                                 , INPUT 0
                                                 , INPUT 0
                                                 , INPUT 0
                                                 ) .

            end.
         end.  выбраны поставщики */
      end. /* each tdedt.id = {&TDEDT_Overturn} */

   end. /* нет разбивки по объектам */
   /* разбивка по объектам */
   else do :
      for EACH obj-list
         :
          if x-TOG-Shift then 
          do:
              run factshift (obj-list.obj-code, obj-list.obj-type) no-error.
              if error-status:error then next .

          end.  
         /* выбранные типы документов */
         for each tdedt
         where tdedt.id <> {&TDEDT_Overturn}
            no-lock
            :
            /* все поставщики */
            if NOT CAN-find( first g#post-f )
            then do:
               for EACH  buf_trn-doc
                  where buf_trn-doc.obj-type     = obj-list.obj-type
                  and buf_trn-doc.obj-code     = obj-list.obj-code
                  and buf_trn-doc.ext-doc-type = tdedt.id
                  and buf_trn-doc.fact-order  >= v-fact-order-start
                  and buf_trn-doc.fact-order  <= v-fact-order-end
                  :

                  find first buf_clients
                       where buf_clients.obj-type = buf_trn-doc.cli-type
                         and buf_clients.obj-code = buf_trn-doc.cli-code
                       NO-LOCK
                       NO-ERROR
                       .
                  RUN calc-doc in this-procedure ( INPUT buf_trn-doc.ext-doc-type
                                                 , INPUT buf_trn-doc.doc-code
                                                 , INPUT buf_trn-doc.obj-type
                                                 , INPUT buf_trn-doc.obj-code
                                                 , INPUT buf_trn-doc.fact-date
                                                 , INPUT if AVAILABLE buf_clients then buf_clients.obj-name else "":U
                                                 , INPUT buf_trn-doc.fact-order
                                                 , INPUT buf_trn-doc.host-code
                                                 , INPUT buf_trn-doc.reason-code
                                                 , INPUT buf_trn-doc.base-rate
                                                 , INPUT buf_trn-doc.base-scale
                                                 ) .
               end.
            end. /* все поставщики */
            /* выбраны поставщики */
            else do:
               for EACH g#post-f
                  ,
                  EACH  buf_trn-doc
                  where buf_trn-doc.obj-type     = obj-list.obj-type
                    and buf_trn-doc.obj-code     = obj-list.obj-code
                    and buf_trn-doc.ext-doc-type = tdedt.id
                    and buf_trn-doc.cli-type     = g#post-f.obj-type
                    and buf_trn-doc.cli-code     = g#post-f.obj-code
                    and buf_trn-doc.fact-order  >= v-fact-order-start
                    and buf_trn-doc.fact-order  <= v-fact-order-end
                  :

                  find first buf_clients
                       where buf_clients.obj-type = buf_trn-doc.cli-type
                         and buf_clients.obj-code = buf_trn-doc.cli-code
                       NO-LOCK
                       NO-ERROR
                       .

                  RUN calc-doc in this-procedure ( INPUT buf_trn-doc.ext-doc-type
                                                 , INPUT buf_trn-doc.doc-code
                                                 , INPUT buf_trn-doc.obj-type
                                                 , INPUT buf_trn-doc.obj-code
                                                 , INPUT buf_trn-doc.fact-date
                                                 , INPUT if AVAILABLE buf_clients then buf_clients.obj-name else "":U
                                                 , INPUT buf_trn-doc.fact-order
                                                 , INPUT buf_trn-doc.host-code
                                                 , INPUT buf_trn-doc.reason-code
                                                 , INPUT buf_trn-doc.base-rate
                                                 , INPUT buf_trn-doc.base-scale
                                                 ) .
               end.
            end. /* выбраны поставщики */
         end. /* each tdedt */

         /* переоценки */
         for each tdedt
         where tdedt.id = {&TDEDT_Overturn}
            no-lock
            :
            /* все поставщики */
            if NOT CAN-find( first g#post-f )
            then do:
               for EACH  buf_price-doc
                  where buf_price-doc.obj-type     = obj-list.obj-type
                  and buf_price-doc.obj-code     = obj-list.obj-code
                  and buf_price-doc.fact-order  >= v-fact-order-start
                  and buf_price-doc.fact-order  <= v-fact-order-end
                  :

                  RUN calc-doc in this-procedure ( INPUT {&TDEDT_Overturn}
                                                 , INPUT buf_price-doc.doc-num
                                                 , INPUT buf_price-doc.obj-type
                                                 , INPUT buf_price-doc.obj-code
                                                 , INPUT buf_price-doc.fact-date
                                                 , INPUT "":U
                                                 , INPUT buf_price-doc.fact-order
                                                 , INPUT buf_price-doc.host-code
                                                 , INPUT 0
                                                 , INPUT 0
                                                 , INPUT 0
                                                 ) .
               end.
            end. /* все поставщики */
            /* выбраны поставщики */
            else do:
               for EACH g#post-f
                  ,
                  EACH  buf_price-doc
                  where buf_price-doc.obj-type     = obj-list.obj-type
                    and buf_price-doc.obj-code     = obj-list.obj-code
                    and buf_price-doc.fact-order  >= v-fact-order-start
                    and buf_price-doc.fact-order  <= v-fact-order-end
                  :


                  RUN calc-doc in this-procedure ( INPUT {&TDEDT_Overturn}
                                                 , INPUT buf_price-doc.doc-num
                                                 , INPUT buf_price-doc.obj-type
                                                 , INPUT buf_price-doc.obj-code
                                                 , INPUT buf_price-doc.fact-date
                                                 , INPUT "":U
                                                 , INPUT buf_price-doc.fact-order
                                                 , INPUT buf_price-doc.host-code
                                                 , INPUT 0
                                                 , INPUT 0
                                                 , INPUT 0
                                                 ) .
               end.
            end. /* выбраны поставщики */
         end. /* each tdedt */
         /* оборот по группе на объекте */
      end. /* each obj-list */
   end. /* разбивка по объектам */


define buffer buf_tt-itog for tt-itog .
   for each buf_tt-itog
       where buf_tt-itog.begin = false
       no-lock :
       find first tt-itog
          where tt-itog.begin = true
          and   tt-itog.obj-code = buf_tt-itog.obj-code
          and   tt-itog.obj-type = buf_tt-itog.obj-type
          no-error.

          if not available tt-itog then do :
              create tt-itog .
              assign
                tt-itog.begin = true
                tt-itog.obj-type = buf_tt-itog.obj-type
                tt-itog.obj-code = buf_tt-itog.obj-code
                tt-itog.VAT-pc = ""
                tt-itog.VAT-cost = 0
                tt-itog.VAT-crsa = 0
                tt-itog.col09-qnty = 0
                tt-itog.sumWithNDS-cost = 0
                tt-itog.sumWithNDS-crsa = 0
              .
              if buf_tt-itog.obj-name ne ""
              then do :
                  assign tt-itog.obj-name = "Остаток на начало" + substring(buf_tt-itog.obj-name, 17, length(buf_tt-itog.obj-name)) .
              end .
          end.
   end.

   if CalcRest
   then do :
/*      RUN put-head-line (INPUT "Остатки на начало") .*/
      for EACH  tt-itog
          where tt-itog.begin = TRUE
            and tt-itog.obj-type = "zzz":U
            and tt-itog.obj-code = 0
         :
         run put-total-line IN THIS-PROCEDURE ( buffer tt-itog, INPUT TRUE).
      end.
   end.

   if rz-objecte
   then do :
      for each tt-all
         where tt-all.obj-type <> "zzz"
         break by tt-all.obj-type
               by tt-all.obj-code
               by tt-all.doc-type
               by tt-all.col02-num
               by tt-all.col08-VAT-PC
         :

         if (first-OF( tt-all.obj-code )
         OR  first-OF( tt-all.obj-type ))
/*         and tt-all.obj-code <> 0*/
/*         and tt-all.obj-type <> "":U*/
         then do :
             find first buf_clients
                  where buf_clients.obj-type  = tt-all.obj-type
                     and buf_clients.obj-code = tt-all.obj-code
                  NO-LOCK
                  NO-ERROR
                  .
             RUN put-stick in this-procedure.
             RUN put-head-line (INPUT buf_clients.obj-name) .
             for EACH   tt-itog
                  where tt-itog.begin    = TRUE
                    and tt-itog.obj-type = tt-all.obj-type
                    and tt-itog.obj-code = tt-all.obj-code
                  :
               run put-total-line IN THIS-PROCEDURE ( buffer tt-itog, INPUT TRUE).
             end.
         end.

         if first-OF( tt-all.doc-type )
         then do :
             RUN put-stick in this-procedure.
             if  tt-all.doc-type <> "":U
             and tt-all.doc-type <> "zzz":U   then
                 RUN put-head-line (INPUT ENTRY( lookup( tt-all.doc-type, {&TDEDT_List}), {&TDEDT_List-full})) .
         end.

         if  first-OF( tt-all.col08-VAT-PC )
         and tt-all.col08-VAT-PC <> -1
         then do :

         end.
         if  tt-all.doc-type = {&TDEDT_Overturn}
         and tt-all.col16-SumWithNDS-sp      = 0
         and NOT NullPer
         then do :
         end.
         else do :
            run put-line in this-procedure.
         end.

         if (LAST-OF( tt-all.obj-code )
         OR  LAST-OF( tt-all.obj-type ))
         then do:
             for EACH tt-itog
                  where tt-itog.begin    = FALSE
                    and tt-itog.obj-type = tt-all.obj-type
                    and tt-itog.obj-code = tt-all.obj-code
                 :
               run put-total-line IN THIS-PROCEDURE ( buffer tt-itog, INPUT FALSE).
             end.

             RUN put-stick in this-procedure.
         end.
      end.
      /* оборот без разбивки по объектам */
      for each tt-all
         where tt-all.obj-type = "zzz"
         /*
         break by tt-all.doc-type
               BY tt-all.obj-type
               by tt-all.col02-num
               by tt-all.col08-VAT-PC
         */
         :
         /*
         if first-OF( tt-all.doc-type )
         then do:
            RUN put-head-line (INPUT ENTRY( lookup( tt-all.doc-type, {&TDEDT_List}), {&TDEDT_List-full})) .
         end.


         if first-OF( tt-all.col08-VAT-PC )
         and tt-all.col08-VAT-PC <> -1
         then do:

         end.
         */
         run put-line in this-procedure.
      end.
   end.
   else do :
      for each tt-all
/*         where tt-all.obj-type <> "zzz"*/
         use-index type
         break by tt-all.doc-type
               by tt-all.obj-type
               by tt-all.col02-num
               by tt-all.col08-VAT-PC
         :

         if first-OF( tt-all.doc-type )
         then do :
             RUN put-stick in this-procedure.
             if  tt-all.doc-type <> "":U
             and tt-all.doc-type <> "zzz":U   then
                 RUN put-head-line (INPUT ENTRY( lookup( tt-all.doc-type, {&TDEDT_List}), {&TDEDT_List-full})) .
         end.

         if  tt-all.doc-type = {&TDEDT_Overturn}
         and tt-all.col16-SumWithNDS-sp = 0
         and NOT NullPer
         then do :
         end.
         else do :
            run put-line in this-procedure.
         end.

      end.
   end.

   if CalcRest
   then do:
/*      RUN put-head-line (INPUT "Остатки на конец") .*/
      for EACH  tt-itog
         where  tt-itog.begin = FALSE
            and tt-itog.obj-type = "zzz":U
            and tt-itog.obj-code = 0
         :
         run put-total-line IN THIS-PROCEDURE ( buffer tt-itog, INPUT FALSE).
      end.
   end.

end. /* do on error */
end procedure. /* create-report */

/*==========================================================================*/
procedure calc-doc :
define input parameter p-doc-type   as character   no-undo.
define input parameter p-doc-code   as character   no-undo.
define input parameter p-obj-type   as character   no-undo.
define input parameter p-obj-code   as integer     no-undo.
define input parameter p-doc-date   as date        no-undo.
define input parameter p-cli-name   as character   no-undo. /* ??? */
define input parameter p-fact-order as decimal     no-undo.
define input parameter p-host-code  as integer     no-undo.
define input parameter p-reas-code  as integer     no-undo.
define input parameter p-base-rate  as decimal     no-undo.
define input parameter p-base-scale as integer     no-undo.


define buffer buf_tt-clcparts for tt-clcparts .
define buffer buf_parts       for ub.parts .
define buffer buf_goods       for ub.goods .
define buffer buf_gds-dtl     for ub.gds-dtl .
define buffer buf_sysconf     for ub.sysconf .
define buffer buf_trn-reason  for ub.trn-reason .
define buffer buf_price-list  for ub.price-list .

define variable varb-code              like ub.bar-code.b-code       no-undo .
define variable vardoc-num             like ub.price-doc.doc-num     no-undo .
define variable varcur-base            like ub.gds-dtl.price-base    no-undo .
define variable varcur-road-tax        like ub.doc-line.road-tax     no-undo .
define variable varcur-excise          like ub.doc-line.excise       no-undo .
define variable varcur-vat-pc          like ub.doc-line.vat-pc       no-undo .
define variable varcur-cons-vat-pc     like ub.doc-line.cons-vat-pc  no-undo .
define variable varcur-slt-pc          like ub.doc-line.slt-pc       no-undo .
define variable varcur-fact-qnty       like ub.gds-dtl.fact-qnty     no-undo .
define variable varprice-sale          like ub.price-list.price-sale no-undo .
define variable varroad-tax            like ub.price-list.road-tax   no-undo .
define variable varexcise              like ub.price-list.excise     no-undo .
define variable varlastcur-base        like ub.gds-dtl.price-base    no-undo .
define variable varlastcur-road-tax    like ub.gds-dtl.price-base    no-undo .
define variable varlastcur-excise      like ub.gds-dtl.price-base    no-undo .

do
on error undo, return error
:

    assign
      v-code-attr-post = "":U
      v-date-post      = "":U
      v-code-attr      = "":U
      v-sf-doc-code    = "":U
      v-sf-doc-date    = "":U
      v-reas-name      = "":U
   .

   if  v-col03
/*   and p-doc-type = {&income}*/
   then do :
      run gbl/trdcat-v.p   ( input p-doc-code
                           , input {&trdcattr-nids} /* номер приходной накладной поставщика */
                           , output v-code-attr-post
                           , output v-attr-type
                           ) NO-ERROR .
   end.

   if  v-col23 /*   and p-doc-type = {&income}*/ then do :
      run gbl/trdcat-v.p   ( input p-doc-code
                           , input {&trdcattr-dids} /* номер приходной накладной поставщика */
                           , output v-date-post
                           , output v-attr-type
                           ) NO-ERROR .
   end.
   if  v-col22 then do :
      run gbl/trdcat-v.p   ( input p-doc-code
                           , input {&trdcattr-nosn} /*Документ-основание. Наименование*/
                           , output v-reas-name
                           , output v-attr-type
                           ) NO-ERROR .
      if v-reas-name = "":U
      OR v-reas-name = ?
      then do :
         find first buf_trn-reason
            where buf_trn-reason.reason-code = p-reas-code
            no-lock
            no-error
            .
         if available buf_trn-reason then do:
            assign
               v-reas-name = buf_trn-reason.reason-name
            .
         end.
      end.
   end.

   if v-col04
   /*   if  p-doc-type =  {&expense}*/
   /*   or  p-doc-type =  {&return}*/
   then do :
      /*номер документа для печати*/
      { str/tdat-val.i
         p-doc-code
         {&trdcattr-print-num}
         v-code-attr
         v-attr-type
         NO-ERROR
      }
   end.

   if v-col06
   then do :
      /*Номер счет-фактуры*/
      { str/tdat-val.i
         p-doc-code
         {&trdcattr-nsf}
         v-sf-doc-code
         v-attr-type
         NO-ERROR
      }
   end.

   if v-col05
   then do :
      /*Дата счет-фактуры*/
      { str/tdat-val.i
         p-doc-code
         {&trdcattr-dsf}
         v-sf-doc-date
         v-attr-type
         NO-ERROR
      }
   end.

   if p-doc-type <> {&TDEDT_Overturn}
   then
   for each buf_parts
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
      no-lock
      ,
      first tt-gds
      where tt-gds.artic     = buf_parts.artic
        and tt-gds.prod-type = buf_parts.prod-type
        and tt-gds.prod-code = buf_parts.prod-code
      /*
      ,
      first buf_goods
      where buf_goods.artic     = buf_parts.artic
        and buf_goods.prod-type = buf_parts.prod-type
        and buf_goods.prod-code = buf_parts.prod-code
        no-lock
        */
      :
      for each buf_tt-clcparts
      on error undo, return error return-value
      :
         delete buf_tt-clcparts .
      end.

      create buf_tt-clcparts .
      buffer-copy buf_parts to buf_tt-clcparts .

      /* найдем значения налогов для товара на момент закрытия документа */
      { gbl/gdsbcode.i
        tt-gds.gds-code
        ?
        varb-code
      }
      /*по умолчанию налоги берутся из последней переоценки */
      { gbl/bcprcex.i
        p-obj-type
        p-obj-code
        varb-code
        0
        p-fact-order
        vardoc-num
        varprice-sale
        varroad-tax
        varexcise
        varcur-vat-pc
        varcur-slt-pc
      }
      if varprice-sale = ?
      then do :
         assign
         varcur-vat-pc = 0
         varcur-slt-pc = 0
         .
      end.
      assign
         varlastcur-base     = 0
         varlastcur-road-tax = 0
         varlastcur-excise   = 0
         varcur-base         = 0
         varcur-road-tax     = 0
         varcur-excise       = 0
         varcur-fact-qnty    = 0
      .

      /*Найдем текущую продажную цену и текущие налоги*/
      for  each buf_gds-dtl no-lock
          where buf_gds-dtl.doc-code  = p-doc-code
            and buf_gds-dtl.artic     = buf_parts.artic
            and buf_gds-dtl.prod-type = buf_parts.prod-type
            and buf_gds-dtl.prod-code = buf_parts.prod-code
      on error undo, return error return-value
      :
         { gbl/gdsbcode.i
           tt-gds.gds-code
           buf_gds-dtl.prt-code
           varb-code
           no-error
         }
         { gbl/bcodeprc.i
           p-obj-type
           p-obj-code
           varb-code
           0
           p-fact-order
           vardoc-num
           varprice-sale
           varroad-tax
           varexcise
         }
         if varprice-sale = ?
         then do :
            assign
                varprice-sale = 0
                varroad-tax   = 0
                varexcise     = 0
            .
         end.
         assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * buf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * buf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * buf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty +                 buf_gds-dtl.fact-qnty
         .
      end.

      if varcur-fact-qnty = 0 then do :
         assign
            varcur-base      = varlastcur-base
            varcur-road-tax  = varlastcur-road-tax
            varcur-excise    = varlastcur-excise
         .
      end.
      else do :
         assign
            varcur-base      = varcur-base      / varcur-fact-qnty
            varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
            varcur-excise    = varcur-excise    / varcur-fact-qnty
         .
      end.
      find first buf_sysconf
           where buf_sysconf.host-code = p-host-code
           no-lock
           .
      assign varcur-cons-vat-pc = buf_sysconf.cons-vat-pc .
      if varcur-cons-vat-pc = ? then do :
         assign varcur-cons-vat-pc = 0 .
      end.
      FIND FIRST doc-line WHERE doc-line.doc-code  = buf_parts.out-code 
                            AND doc-line.artic     = buf_parts.artic 
                            AND doc-line.prod-type = buf_parts.prod-type
                            AND doc-line.prod-code = buf_parts.prod-code
                            NO-LOCK NO-ERROR.
      run clcprtsl_calc-ttable in this-procedure
         ( input TRUE  /* paris-doc         */
         , input TRUE  /* paris-cur         */
         , input 0     /* parroad-tax       */
         , input 0     /* parexcise         */
         , input IF (AVAIL doc-line) THEN doc-line.VAT-pc ELSE ?     /* parvat-pc */
         , input 0     /* parcons-vat-pc    */
         , input 0     /* parslt-pc         */
         , input p-base-rate     /* parbase-rate      */
         , input p-base-scale     /* parbase-scale     */
         , input ( if tPrintRubl = yes then "rubl":U else "base":U )  /* parr-b */
         , input varcur-base            /* parcur-base       */
         , input varcur-road-tax        /* parcur-road-tax   */
         , input varcur-excise          /* parcur-excise     */
         , input varcur-vat-pc          /* parcur-vat-pc     */
         , input varcur-cons-vat-pc     /* parcurcons-vat-pc */
         , input varcur-slt-pc           /* parcurslt-pc      */
         ) no-error .

      run create-lines in this-procedure  ( input p-doc-type
                                          , input p-doc-code
                                          , input p-obj-type
                                          , input p-obj-code
                                          , input ROUND(buf_parts.VAT-pc, 0)
                                          , input p-doc-date
                                          , input p-cli-name
                                          , input buf_parts.fact-qnty
                                          , input buf_parts.road-tax-rubl
                                          ) .
   end.
   else
   for each buf_price-list
      where buf_price-list.doc-num    = p-doc-code
        and buf_price-list.main-price = yes
      no-lock
      ,
      first tt-gds
      where tt-gds.artic     = buf_price-list.artic
        and tt-gds.prod-type = buf_price-list.prod-type
        and tt-gds.prod-code = buf_price-list.prod-code
      /*
      ,
      each buf_goods
      where buf_goods.artic     = buf_price-list.artic
        and buf_goods.prod-type = buf_price-list.prod-type
        and buf_goods.prod-code = buf_price-list.prod-code
        no-lock
      */
      :
         def var v-price-list-doc-num            like ub.price-list.doc-num     no-undo.
         def var v-price-list-price-sale         like ub.price-list.price-sale  no-undo.
         def var v-price-list-price-sale_old     like ub.price-list.price-sale  no-undo.
         def var v-price-list-road-tax           like ub.price-list.road-tax    no-undo.
         def var v-price-list-excise             like ub.price-list.excise      no-undo.
            { gbl/bcodeprc.i
                buf_price-list.obj-type
                buf_price-list.obj-code
                buf_price-list.b-code
                0
                buf_price-list.fact-order
                v-price-list-doc-num
                v-price-list-price-sale
                v-price-list-road-tax
                v-price-list-excise
            }

            if v-price-list-price-sale = ?
            then do :
               assign
                  v-price-list-price-sale = 0
               .
            end.

      run create-lines in this-procedure  ( input p-doc-type
                                          , input p-doc-code
                                          , input p-obj-type
                                          , input p-obj-code
                                          , input ROUND(buf_price-list.VAT-pc, 0)
                                          , input p-doc-date
                                          , input p-cli-name
                                          , input buf_price-list.doc-qnty
                                          , input ( buf_price-list.price-sale - v-price-list-price-sale )
                                          ) .
   end.
end. /* do on error */
end procedure. /* calc-doc */

/*==========================================================================*/
procedure create-lines :
define input parameter p-doc-type as character  no-undo.
define input parameter p-doc-code as character  no-undo.
define input parameter p-obj-type as character  no-undo.
define input parameter p-obj-code as integer    no-undo.
define input parameter p-vat-pc   as decimal    no-undo.
define input parameter p-doc-date as date       no-undo.
define input parameter p-cli-name as character  no-undo. /* ??? */
define input parameter p-qnty     as decimal    no-undo.
define input parameter p-price    as decimal    no-undo.

define variable v-ind1    as integer  no-undo.
define variable v-ind2    as integer  no-undo.
define variable v-ind3    as integer  no-undo.

define buffer buf_clients      for ub.clients.
define buffer buf_ot-tot       for ub.ot-tot .

do
on error undo, return error
:

   /* оборот по документу */
   find first tt-all
      where tt-all.obj-type      = p-obj-type
        and tt-all.obj-code      = p-obj-code
        and tt-all.col02-num     = p-doc-code
        and tt-all.doc-type      = p-doc-type
        and tt-all.col08-VAT-PC  = -1         /* без разбивки по НДС */
      NO-ERROR.
   if NOT AVAILABLE tt-all
   then do :
      CREATE tt-all.
      assign
         tt-all.obj-type             = p-obj-type
         tt-all.obj-code             = p-obj-code
         tt-all.col02-num            = p-doc-code
         tt-all.doc-type             = p-doc-type
         tt-all.col08-VAT-PC         = -1
         tt-all.col01-doc-date       = p-doc-date
         tt-all.col03-code-attr-post = v-code-attr-post
         tt-all.col22-reason         = v-reas-name
         tt-all.col04-code-attr      = v-code-attr
         tt-all.col06-sf-doc-code    = v-sf-doc-code
         tt-all.col07-clients        = p-cli-name
      .
       tt-all.col05-sf-doc-date    = date(v-sf-doc-date) no-error.
         
       tt-all.col23-date-post      = date(v-date-post) no-error.
        
   end.
   RUN update-line (buffer tt-all , INPUT p-doc-type, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).

   /* оборот по документу, разбивка по НДС */
   if VAT-PC
   then do :
      find first tt-all
         where tt-all.obj-type     = p-obj-type
         and tt-all.obj-code       = p-obj-code
         and tt-all.col02-num      = p-doc-code
         and tt-all.doc-type       = p-doc-type
         and tt-all.col08-VAT-PC   = p-VAT-pc
         NO-ERROR.
      if NOT AVAILABLE tt-all
      then do :
         CREATE tt-all.
         assign
            tt-all.obj-type             = p-obj-type
            tt-all.obj-code             = p-obj-code
            tt-all.col02-num            = p-doc-code
            tt-all.doc-type             = p-doc-type
            tt-all.col08-VAT-PC         = p-VAT-pc
            tt-all.col01-doc-date       = p-doc-date
            tt-all.col03-code-attr-post = v-code-attr-post
            tt-all.col04-code-attr      = v-code-attr
            tt-all.col06-sf-doc-code    = v-sf-doc-code
            tt-all.col07-clients        = /*"В том числе с НДС "*/ "":U
         .
          tt-all.col05-sf-doc-date    = date(v-sf-doc-date ) no-error.
            
          tt-all.col23-date-post      = date(v-date-post) no-error.
           
      end.
      RUN update-line ( BUFFER tt-all , INPUT p-doc-type, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).
   end.

   /* оборот по типу документов */
   find first tt-all
      where tt-all.obj-type = "zzz":U
        and tt-all.obj-code = 0
        and tt-all.col02-num = "zzz":U
        and tt-all.doc-type = p-doc-type
        and tt-all.col08-VAT-PC   = -1
      NO-ERROR.
   if NOT AVAILABLE tt-all
   then do :
      CREATE tt-all.
      assign
         tt-all.obj-type = "zzz":U
         tt-all.obj-code = 0
         tt-all.col02-num = "zzz":U
         tt-all.doc-type = p-doc-type
         tt-all.col08-VAT-PC   = -1
         tt-all.col07-clients        = SUBSTITUTE("Итого &1", ENTRY( lookup( tt-all.doc-type, {&TDEDT_List}), {&TDEDT_List-full}))
      .
   end.
   RUN update-line ( BUFFER tt-all , INPUT p-doc-type, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).

   /* оборот по типу документов, разбивка по объектам */
   if rz-objecte
   then do :
      find first tt-all
         where  tt-all.obj-type = p-obj-type
            and tt-all.obj-code = p-obj-code
            and tt-all.col02-num = "zzz":U
            and tt-all.doc-type = p-doc-type
            and tt-all.col08-VAT-PC   = -1
         NO-ERROR.
      if NOT AVAILABLE tt-all
      then do:
         find first buf_clients
              where buf_clients.obj-type  = p-obj-type
                and buf_clients.obj-code = p-obj-code
            NO-LOCK
            NO-ERROR
            .
         CREATE tt-all.
         assign
            tt-all.obj-type = p-obj-type
            tt-all.obj-code = p-obj-code
            tt-all.col02-num = "zzz":U
            tt-all.doc-type = p-doc-type
            tt-all.col08-VAT-PC   = -1
            tt-all.col07-clients        = SUBSTITUTE("Итого &1 на объекте &2", ENTRY( lookup( tt-all.doc-type, {&TDEDT_List}), {&TDEDT_List-full}), buf_clients.obj-name)
         .
      end.
      RUN update-line ( BUFFER tt-all , INPUT p-doc-type, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).

      /* оборот по типу документов, разбивка по объектам, разбивка по НДС */
      if VAT-PC
      then do:
         find first tt-all
            where  tt-all.obj-type = p-obj-type
               and tt-all.obj-code = p-obj-code
               and tt-all.col02-num = "zzz":U
               and tt-all.doc-type = p-doc-type
               and tt-all.col08-VAT-PC   = p-vat-pc
            NO-ERROR.
         if NOT AVAILABLE tt-all
         then do:
            CREATE tt-all.
            assign
               tt-all.obj-type = p-obj-type
               tt-all.obj-code = p-obj-code
               tt-all.col02-num = "zzz":U
               tt-all.doc-type = p-doc-type
               tt-all.col08-VAT-PC   = p-vat-pc
               tt-all.col07-clients        = /*"В том числе с НДС "*/ "":U
            .
         end.
         RUN update-line ( BUFFER tt-all , INPUT p-doc-type, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).
      end.
   end.

   /* оборот по типу документов, разбивка по НДС */
   if VAT-PC
   then do:
      find first tt-all
         where  tt-all.obj-type = "zzz":U
            and tt-all.obj-code = 0
            and tt-all.col02-num = "zzz":U
            and tt-all.doc-type = p-doc-type
            and tt-all.col08-VAT-PC   = p-vat-pc
         NO-ERROR.
      if NOT AVAILABLE tt-all
      then do:
         CREATE tt-all.
         assign
            tt-all.obj-type = "zzz":U
            tt-all.obj-code = 0
            tt-all.col02-num = "zzz":U
            tt-all.doc-type = p-doc-type
            tt-all.col08-VAT-PC   = p-vat-pc
            tt-all.col07-clients        = /*"В том числе с НДС "*/ "":U
         .
      end.
      RUN update-line ( BUFFER tt-all , INPUT p-doc-type, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).
   end.

   /* оборот по всем типам */
   find first tt-all
      where tt-all.obj-type = "zzz":U
        and tt-all.obj-code = 0
        and tt-all.col02-num = "zzz":U
        and tt-all.doc-type = "zzz":U
        and tt-all.col08-VAT-PC   = -1
      NO-ERROR.
   if NOT AVAILABLE tt-all
   then do:
      CREATE tt-all.
      assign
         tt-all.obj-type = "zzz":U
         tt-all.obj-code = 0
         tt-all.col02-num = "zzz":U
         tt-all.doc-type = "zzz":U
         tt-all.col08-VAT-PC   = -1
         tt-all.col07-clients        = SUBSTITUTE("Итого оборот:")
      .
   end.
   RUN update-line ( BUFFER tt-all , INPUT if p-doc-type = {&TDEDT_Overturn} then p-doc-type else "zzz":U, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).

   /* оборот по всем типам, разбивка по объектам */
   if rz-objecte
   then do :
      find first tt-all
         where  tt-all.obj-type = p-obj-type
            and tt-all.obj-code = p-obj-code
            and tt-all.col02-num = "zzz":U
            and tt-all.doc-type = "zzz":U
            and tt-all.col08-VAT-PC   = -1
         NO-ERROR.
      if NOT AVAILABLE tt-all
      then do:
         find first buf_clients
              where buf_clients.obj-type  = p-obj-type
                and buf_clients.obj-code = p-obj-code
            NO-LOCK
            NO-ERROR
            .
         CREATE tt-all.
         assign
            tt-all.obj-type = p-obj-type
            tt-all.obj-code = p-obj-code
            tt-all.col02-num = "zzz":U
            tt-all.doc-type = "zzz":U
            tt-all.col08-VAT-PC   = -1
            tt-all.col07-clients        = SUBSTITUTE("Итого оборот на объекте &1", buf_clients.obj-name)
         .
      end.
      RUN update-line ( BUFFER tt-all , INPUT if p-doc-type = {&TDEDT_Overturn} then p-doc-type else  "zzz":U, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).

      /* оборот по всем типам, разбивка по объектам, разбивка по НДС */
      if VAT-PC
      then do :
         find first tt-all
            where  tt-all.obj-type = p-obj-type
               and tt-all.obj-code = p-obj-code
               and tt-all.col02-num = "zzz":U
               and tt-all.doc-type = "zzz":U
               and tt-all.col08-VAT-PC   = p-vat-pc
            NO-ERROR.
         if NOT AVAILABLE tt-all
         then do:
            CREATE tt-all.
            assign
               tt-all.obj-type = p-obj-type
               tt-all.obj-code = p-obj-code
               tt-all.col02-num = "zzz":U
               tt-all.doc-type = "zzz":U
               tt-all.col08-VAT-PC   = p-vat-pc
               tt-all.col07-clients        = /*"В том числе с НДС "*/ "":U
            .
         end.
         RUN update-line ( BUFFER tt-all , INPUT if p-doc-type = {&TDEDT_Overturn} then p-doc-type else  "zzz":U, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).
      end.
   end.
   /* оборот по всем типам, разбивка по НДС */
   if VAT-PC
   then do :
      find first tt-all
         where  tt-all.obj-type = "zzz":U
            and tt-all.obj-code = 0
            and tt-all.col02-num = "zzz":U
            and tt-all.doc-type = "zzz":U
            and tt-all.col08-VAT-PC   = p-vat-pc
         NO-ERROR.
      if NOT AVAILABLE tt-all
      then do:
         CREATE tt-all.
         assign
            tt-all.obj-type         = "zzz":U
            tt-all.obj-code         = 0
            tt-all.col02-num        = "zzz":U
            tt-all.doc-type         = "zzz":U
            tt-all.col08-VAT-PC     = p-vat-pc
            tt-all.col07-clients    = /*"В том числе с НДС "*/ "":U
         .
      end.
      RUN update-line ( BUFFER tt-all , INPUT if p-doc-type = {&TDEDT_Overturn} then p-doc-type else  "zzz":U, INPUT p-qnty , INPUT p-price, INPUT p-doc-code).
   end.
end. /* do on error */
end procedure. /* create-lines */

/*==========================================================================*/
procedure update-line :
DEFINE PARAMETER BUFFER buf_tt-all for tt-all.
define input parameter p-doc-type as character  no-undo.
define input parameter p-qnty     as decimal    no-undo.
define input parameter p-price    as decimal    no-undo.
define input parameter p-doc-code as character  no-undo.

do
on error undo, return error
:
   define buffer buf_tt-allsum-line    for tt-allsum-line .
   find first buf_tt-allsum-line
      where buf_tt-allsum-line.sum-type = {&sum-general-sign}
      no-error .

   if available buf_tt-allsum-line
   then do:
      if p-doc-type <> {&TDEDT_Overturn}
      then do:
         assign
            buf_tt-all.col09-qnty                = buf_tt-all.col09-qnty             + buf_tt-allsum-line.fact-qnty
            /* ??? Show-Cost  чекбокс по учетным ценам    */
            buf_tt-all.col10-SumWithNDS-coast    = buf_tt-all.col10-SumWithNDS-coast + if tPrintRubl then buf_tt-allsum-line.sum-dsc-rubl-acc else buf_tt-allsum-line.sum-dsc-base-acc
            buf_tt-all.col11-VAT-Sum-coast       = buf_tt-all.col11-VAT-Sum-coast    + if tPrintRubl then buf_tt-allsum-line.vat-rubl-acc     else buf_tt-allsum-line.vat-base-acc
            /* ??? считать */
            buf_tt-all.col12-SumWithoutNDS-coast = buf_tt-all.col10-SumWithNDS-coast - buf_tt-all.col11-VAT-Sum-coast

            /* ??? Show-Sale   чекбокс по цена документов */
            buf_tt-all.col13-SumWithNDS          = buf_tt-all.col13-SumWithNDS       + if tPrintRubl then buf_tt-allsum-line.sum-dsc-rubl-doc else buf_tt-allsum-line.sum-dsc-base-doc
            buf_tt-all.col14-VAT-Sum             = buf_tt-all.col14-VAT-Sum          + if tPrintRubl then buf_tt-allsum-line.vat-rubl-doc     else buf_tt-allsum-line.vat-base-doc
            /* ??? считать */
            buf_tt-all.col15-SumWithoutNDS       = buf_tt-all.col13-SumWithNDS       - buf_tt-all.col14-VAT-Sum

            /* ??? Show-Crsa чекбокс по продажныи ценам   */
            buf_tt-all.col16-SumWithNDS-sp       = buf_tt-all.col16-SumWithNDS-sp    + if tPrintRubl then buf_tt-allsum-line.sum-dsc-rubl-cur else buf_tt-allsum-line.sum-dsc-base-cur
            buf_tt-all.col17-VAT-Sum-sp          = buf_tt-all.col17-VAT-Sum-sp       + if tPrintRubl then buf_tt-allsum-line.vat-rubl-cur     else buf_tt-allsum-line.vat-base-cur
            /* ??? считать */
            buf_tt-all.col18-SumWithoutNDS-sp    = buf_tt-all.col16-SumWithNDS-sp    - buf_tt-all.col17-VAT-Sum-sp

            /*
            buf_tt-all.col19-discnt-sum          = buf_tt-all.col19-discnt-sum       + if tPrintRubl then buf_tt-all.dsc-rubl-doc else buf_tt-all.dsc-base-doc
            */
            /* ??? считать */
            buf_tt-all.col20-SumWithNDS-disp     = buf_tt-all.col16-SumWithNDS-sp    - buf_tt-all.col12-SumWithoutNDS-coast
            /* ??? считать */
            buf_tt-all.col21-SumWithoutNDS-disp  = buf_tt-all.col15-SumWithoutNDS    - buf_tt-all.col12-SumWithoutNDS-coast
            /* ??? считать */
   /*         buf_tt-all.col23-ov-sum              = buf_tt-all.col16-SumWithNDS-sp    - (buf_tt-all.col13-SumWithNDS + buf_tt-all.col19-discnt-sum)*/
         .
      end.
      else do:
         assign
            /* ??? Show-Cost  чекбокс по учетным ценам
            buf_tt-all.col09-qnty                = 0
            buf_tt-all.col10-SumWithNDS-coast    = buf_tt-all.col10-SumWithNDS-coast + if tPrintRubl then buf_tt-allsum-line.sum-dsc-rubl-acc else buf_tt-allsum-line.sum-dsc-base-acc
            buf_tt-all.col11-VAT-Sum-coast       = buf_tt-all.col11-VAT-Sum-coast    + if tPrintRubl then buf_tt-allsum-line.vat-rubl-acc     else buf_tt-allsum-line.vat-base-acc
            buf_tt-all.col12-SumWithoutNDS-coast = buf_tt-all.col10-SumWithNDS-coast - buf_tt-all.col11-VAT-Sum-coast
            */

            /* ??? Show-Sale   чекбокс по цена документов
            buf_tt-all.col13-SumWithNDS          = buf_tt-all.col13-SumWithNDS       + if tPrintRubl then buf_tt-allsum-line.sum-dsc-rubl-doc else buf_tt-allsum-line.sum-dsc-base-doc
            buf_tt-all.col14-VAT-Sum             = buf_tt-all.col14-VAT-Sum          + if tPrintRubl then buf_tt-allsum-line.vat-rubl-doc     else buf_tt-allsum-line.vat-base-doc
            buf_tt-all.col15-SumWithoutNDS       = buf_tt-all.col13-SumWithNDS       - buf_tt-all.col14-VAT-Sum
            */

            /* ??? Show-Crsa чекбокс по продажныи ценам   */
            buf_tt-all.col16-SumWithNDS-sp       = buf_tt-all.col16-SumWithNDS-sp      + p-qnty * p-price
/*            buf_tt-all.col17-VAT-Sum-sp          = buf_tt-all.col17-VAT-Sum-sp       + if tPrintRubl then buf_tt-allsum-line.vat-rubl-cur     else buf_tt-allsum-line.vat-base-cur*/
/*            buf_tt-all.col18-SumWithoutNDS-sp    = buf_tt-all.col16-SumWithNDS-sp    - buf_tt-all.col17-VAT-Sum-sp*/

         .
      end.
/*         export stream st-1 delimiter "~t"*/
/*            p-doc-code*/
/*            p-doc-type*/
/*            buf_tt-allsum-line.fact-qnty*/
/*            buf_tt-allsum-line.sum-dsc-rubl-acc*/
/*            buf_tt-allsum-line.sum-dsc-rubl-cur*/
/*            buf_tt-all.col09-qnty*/
/*            buf_tt-all.col10-SumWithNDS-coast*/
/*            buf_tt-all.col16-SumWithNDS-sp*/
/*         .*/

      /*
      if buf_tt-allsum-line.vat-rubl-cur = ? OR buf_tt-allsum-line.vat-base-cur = ?
          then MESSAGE buf_tt-all.col02-num VIEW-AS ALERT-BOX.
      */
   end.

end. /* do on error */
end procedure. /* update-line */

/*==========================================================================*/
procedure print-header :
  define buffer buf_clients   for ub.clients.

do
on error undo, return error return-value
:
   find first obj-list no-error .
   if not available obj-list
   then do:
      message
         "Не указан объект для формирования отчета!"
      view-as alert-box error.
      undo, return error.
   end.
   { gbl/hostcode.i
     x-store-type
     x-store-code
     v-host-code-1
     }

   for each obj-list :
      { gbl/hostcode.i
        obj-list.obj-type
        obj-list.obj-code
        v-host-code-2
        }
      if v-host-code-1 <> v-host-code-2 then do:
         message
         "Отчет формируется по объектам одной фирмы!"
         view-as alert-box error.
         undo, return error.
      end.
   end.

   find first  buf_clients
        where  buf_clients.obj-type = {&cmp}
        and    buf_clients.obj-code = v-host-code-1
        no-lock
        no-error
        .
   if not available buf_clients
   then do :
      message
         "Не найдена фирма с кодом " v-host-code-1 skip
         "Отчет не может быть сформирован"
      view-as alert-box error.
      return error.
   end.

   run fmtcli-get-client in this-procedure ( input  buf_clients.obj-type , input buf_clients.obj-code ).

   PUT stream OutStream unformatted string(v-fmtcli-name) format "x(50)" skip .

   assign
    num#str# = 1
    num#col# = 1
    v-ind = 1
   .
 end.
 end procedure. /* print-header */

/*==========================================================================*/
procedure put-line :
define variable v-out as character no-undo.

do
on error undo, return error
:
   assign
      num#col# = 0
      num#str# = num#str# + 1
   .
   if v-col01 = yes then do :
      assign num#col# = num#col# + 1 .
      if tt-all.col01-doc-date = ?
      then v-out = "":U.
      else v-out = string(tt-all.col01-doc-date            , "99/99/9999").
      PUT stream OutStream  "|"  v-out       format "X(10)"  .
      run macr_excel_char_with_format in this-procedure (input v-out, input num#str#, input 1 ) .
      run format-itog in this-procedure.
   end.
   if v-col02 = yes then do :
      assign num#col# = num#col# + 1 .
      if tt-all.col02-num = "zzz"
      then v-out = "":U.
      else v-out = string(tt-all.col02-num                 ).
      PUT stream OutStream  "|"  v-out                     format "X(15)"  .
      run macr_excel_char_with_format in this-procedure (input v-out, input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col03 = yes then do: PUT stream OutStream  "|"  string(tt-all.col03-code-attr-post      )                     format "X(20)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_char_with_format in this-procedure (input string(tt-all.col03-code-attr-post), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col23 = yes then do: PUT stream OutStream  "|"  tt-all.col23-date-post                  format "99/99/9999"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_char_with_format in this-procedure (input string(tt-all.col23-date-post), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col04 = yes then do: PUT stream OutStream  "|"  string(tt-all.col04-code-attr           )                     format "X(20)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_char_with_format in this-procedure (input string(tt-all.col04-code-attr), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col05 = yes then do: PUT stream OutStream  "|"  string(tt-all.col05-sf-doc-date  ,"99/99/9999"       )                     format "X(10)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_char_with_format in this-procedure (input string(tt-all.col05-sf-doc-date,"99/99/9999"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col06 = yes then do: PUT stream OutStream  "|"  string(tt-all.col06-sf-doc-code         )                     format "X(10)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_char_with_format in this-procedure (input string(tt-all.col06-sf-doc-code), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col07 = yes then do: PUT stream OutStream  "|"  string(tt-all.col07-clients             )                     format "X(50)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_char_with_format in this-procedure (input string(tt-all.col07-clients), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col08 = yes then do :
      assign num#col# = num#col# + 1 .
      if tt-all.col08-VAT-PC = - 1
      then v-out = "":U.
      else v-out = string(tt-all.col08-VAT-PC, ">>>9"              ).
      PUT stream OutStream  "|"  v-out                     format "X(6)"   .
      run macr_excel_char_with_format in this-procedure (input v-out, input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col09 = yes then do: PUT stream OutStream  "|"  string(tt-all.col09-qnty                )                     format "X(10)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col09-qnty), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col10 = yes then do: PUT stream OutStream  "|"  string(tt-all.col10-SumWithNDS-coast    , "->>>>>>>>>>>>>9.99")    format "X(18)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col10-SumWithNDS-coast    , "->>>>>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col11 = yes then do: PUT stream OutStream  "|"  string(tt-all.col11-VAT-Sum-coast       , "->>>>>>>>>>9.99")    format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col11-VAT-Sum-coast       , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col12 = yes then do: PUT stream OutStream  "|"  string(tt-all.col12-SumWithoutNDS-coast , "->>>>>>>>>>9.99")   format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col12-SumWithoutNDS-coast , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col13 = yes then do: PUT stream OutStream  "|"  string(tt-all.col13-SumWithNDS          , "->>>>>>>>>>>>>9.99")    format "X(18)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col13-SumWithNDS          , "->>>>>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col14 = yes then do: PUT stream OutStream  "|"  string(tt-all.col14-VAT-Sum             , "->>>>>>>>>>9.99")    format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col14-VAT-Sum             , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col15 = yes then do: PUT stream OutStream  "|"  string(tt-all.col15-SumWithoutNDS       , "->>>>>>>>>>9.99")   format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input  string(tt-all.col15-SumWithoutNDS       , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col16 = yes then do: PUT stream OutStream  "|"  string(tt-all.col16-SumWithNDS-sp       , "->>>>>>>>>>9.99")    format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col16-SumWithNDS-sp       , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col17 = yes then do: PUT stream OutStream  "|"  string(tt-all.col17-VAT-Sum-sp          , "->>>>>>>>>>9.99")    format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col17-VAT-Sum-sp          , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col18 = yes then do: PUT stream OutStream  "|"  string(tt-all.col18-SumWithoutNDS-sp    , "->>>>>>>>>>9.99")   format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col18-SumWithoutNDS-sp    , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col19 = yes then do: PUT stream OutStream  "|"  string(tt-all.col19-discnt-sum          , "->>>>>9.99")      format "X(10)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col19-discnt-sum          , "->>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col20 = yes then do: PUT stream OutStream  "|"  string(tt-all.col20-SumWithNDS-disp     , "->>>>>>>>>>9.99")      format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col20-SumWithNDS-disp     , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col21 = yes then do: PUT stream OutStream  "|"  string(tt-all.col21-SumWithoutNDS-disp  , "->>>>>>>>>>9.99")      format "X(15)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_dec in this-procedure (input string(tt-all.col21-SumWithoutNDS-disp  , "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   if v-col22 = yes then do: PUT stream OutStream  "|"  tt-all.col22-reason                                   format "X(30)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_char_with_format in this-procedure (input string(tt-all.col22-reason), input num#str#, input num#col# ) .
      run format-itog in this-procedure.
   end.
   PUT stream OutStream  "|"  .
   PUT stream OutStream skip.
end. /* do on error */
end procedure. /* put-line */

/*==========================================================================*/
procedure put-head-line :
define input parameter p-name as character no-undo.

do
on error undo, return error
:
   assign
    num#str# = num#str# + 1
    num#col# = 0
   .
   if v-col01 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col02 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col03 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(20)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col23 = yes then do:
      PUT stream OutStream  "|"  "":U    format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col04 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(20)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col05 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col06 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col07 = yes then do :
      PUT stream OutStream  "|"  p-name  format "X(50)"  .
      assign num#col# = num#col# + 1 .
      run macr_excel_char_with_format in this-procedure (input p-name, input num#str#, input num#col# ) .
      run print-bold in this-procedure .
   end.
   if v-col08 = yes then PUT stream OutStream  "|"  "":U    format "X(6)"   .
   if v-col09 = yes then PUT stream OutStream  "|"  "":U    format "X(10)"  .
   if v-col10 = yes then PUT stream OutStream  "|"  "":U    format "X(18)"  .
   if v-col11 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col12 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col13 = yes then PUT stream OutStream  "|"  "":U    format "X(18)"  .
   if v-col14 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col15 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col16 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col17 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col18 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col19 = yes then PUT stream OutStream  "|"  "":U    format "X(10)"  .
   if v-col20 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col21 = yes then PUT stream OutStream  "|"  "":U    format "X(15)"  .
   if v-col22 = yes then PUT stream OutStream  "|"  "":U    format "X(30)"  .
   PUT stream OutStream  "|"  .

   PUT stream OutStream skip.
end. /* do on error */
end procedure. /* put-head-line */


/*==========================================================================*/
procedure put-total-line :
DEFINE PARAMETER BUFFER bf_tt-itog for tt-itog.
define input parameter p-begin as logical          no-undo.

do
on error undo, return error
:
   num#str# = num#str# + 1 .
   num#col# = /*0*/ 1 .
   if v-col01 = yes then do :
      PUT stream OutStream  "|"  "":U                         format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col02 = yes then do :
      PUT stream OutStream  "|"  "":U                         format "X(15)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col03 = yes then do :
      PUT stream OutStream  "|"  "":U                         format "X(20)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col23 = yes then do :
      PUT stream OutStream  "|"  "":U                         format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col04 = yes then do :
      PUT stream OutStream  "|"  "":U                         format "X(20)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col05 = yes then do :
      PUT stream OutStream  "|"  "":U                         format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col06 = yes then do :
      PUT stream OutStream  "|"  "":U                         format "X(10)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col07 = yes then do :
      PUT stream OutStream  "|"  if bf_tt-itog.vat-pc <> "":U then  /*"В том числе с НДС "*/ "":U
                                                                                 else if bf_tt-itog.obj-type = "zzz":U then if p-begin then  "Остаток на начало периода"
                                                                                                                                       else  "Остаток на конец периода"
                                                                                                                       else bf_tt-itog.obj-name
                                                                                       format "X(50)"  .
      if bf_tt-itog.vat-pc = "":U then do :
          if tt-itog.obj-type = "zzz":U then do :
              if p-begin then do :
                  run macr_excel_char_with_format in this-procedure (input "Остаток на начало периода", input num#str#, input num#col# ) .
              end.
              else do :
                  run macr_excel_char_with_format in this-procedure (input "Остаток на конец периода", input num#str#, input num#col# ) .
              end.
          end.
          else do :
                  run macr_excel_char_with_format in this-procedure (input bf_tt-itog.obj-name, input num#str#, input num#col# ) .
          end.
      end.
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col08 = yes then do :
      PUT stream OutStream  "|"  string(bf_tt-itog.vat-pc)                         format "X(6)"  .
      run macr_excel_dec in this-procedure (input (bf_tt-itog.vat-pc), input num#str#, input num#col# ) .
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col09 = yes then do :
      PUT stream OutStream  "|"  string(bf_tt-itog.col09-qnty)                                    format "X(10)"  .
      run macr_excel_dec in this-procedure (input (bf_tt-itog.col09-qnty), input num#str#, input num#col# ) .
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col10 = yes then do :
      PUT stream OutStream  "|"  string(bf_tt-itog.SumWithNDS-cost, "->>>>>>>>>>>>>9.99")       format "X(18)"  .
      run macr_excel_dec in this-procedure (input string(bf_tt-itog.SumWithNDS-cost, "->>>>>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col11 = yes then do :
      PUT stream OutStream  "|"  string(bf_tt-itog.VAT-cost, "->>>>>>>>>>9.99")          format "X(15)"  .
      run macr_excel_dec in this-procedure (input string(bf_tt-itog.VAT-cost, "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col12 = yes then do :
      PUT stream OutStream  "|"  string((bf_tt-itog.SumWithNDS-cost - bf_tt-itog.VAT-cost), "->>>>>>>>>>9.99")    format "X(15)"  .
      run macr_excel_dec in this-procedure (input string((bf_tt-itog.SumWithNDS-cost - bf_tt-itog.VAT-cost), "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col13 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(12)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col14 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(12)"  .
      assign num#col# = num#col# + 1 .
   end.
   if v-col15 = yes then do :
      PUT stream OutStream  "|"  "":U    format "X(13)"  .
      assign num#col# = num#col# + 1 .
   end.
/*   if v-col13 = yes then PUT stream OutStream  "|"  string(bf_tt-itog.SumWithNDS-sale, "->>>>>>>9.99")              format "X(12)"  .*/
/*   if v-col14 = yes then PUT stream OutStream  "|"  string(bf_tt-itog.VAT-sale, "->>>>>>>9.99")                 format "X(12)"  .*/
/*   if v-col15 = yes then PUT stream OutStream  "|"  string((bf_tt-itog.SumWithNDS-sale - bf_tt-itog.VAT-sale), "->>>>>>>>9.99")           format "X(13)"  .*/
   if v-col16 = yes then do :
      PUT stream OutStream  "|"  string(bf_tt-itog.SumWithNDS-crsa, "->>>>>>>>>>9.99")          format "X(15)"  .
      run macr_excel_dec in this-procedure (input string(bf_tt-itog.SumWithNDS-crsa, "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col17 = yes then do :
      PUT stream OutStream  "|"  string(bf_tt-itog.VAT-crsa, "->>>>>>>>>>9.99")            format "X(15)"  .
      run macr_excel_dec in this-procedure (input string(bf_tt-itog.VAT-crsa, "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col18 = yes then do :
      PUT stream OutStream  "|"  string((bf_tt-itog.SumWithNDS-crsa - bf_tt-itog.VAT-crsa), "->>>>>>>>>>9.99")       format "X(15)"  .
      run macr_excel_dec in this-procedure (input string((bf_tt-itog.SumWithNDS-crsa - bf_tt-itog.VAT-crsa), "->>>>>>>>>>9.99"), input num#str#, input num#col# ) .
      run print-bold in this-procedure .
      assign num#col# = num#col# + 1 .
   end.
   if v-col19 = yes then PUT stream OutStream  "|"  "":U                format "X(10)"  .
   if v-col20 = yes then PUT stream OutStream  "|"  "":U                format "X(15)"  .
   if v-col21 = yes then PUT stream OutStream  "|"  "":U                format "X(15)"  .
   if v-col22 = yes then PUT stream OutStream  "|"  "":U                format "X(30)"  .
/*   if v-col23 = yes then PUT stream OutStream  "|"  "":U                format "X(10)"  .*/

   PUT stream OutStream  "|"  .
   PUT stream OutStream skip.
end. /* do on error */
end procedure. /* put-total-line */

/*==========================================================================*/
procedure print-footer :

do
on error undo, return error
:

/*  {&PutExcel}  "ИТОГО"  {&tabulation} {&tabulation} {&tabulation} excel-sum (99998) {&tabulation}  excel-sum (99999) {&tabulation}  excel-sum (-99999) .*/

end. /* do on error */
end procedure. /* print-footer */

/* ==================================================================================================================== */
procedure create-goods :  /* оставляем только товары */
do
on error undo, return error return-value
:
   define buffer buf_goods    for ub.goods .
   define buffer buf_cli-gds  for ub.cli-gds .

   define variable v-curr-grp-name as character            no-undo .
   define variable v-host-code     like clients.host-code  no-undo .

   empty temp-table tt-gds.
   case p-sel-gds :
   /* все товары */
   when {&g-all} then do:
      for EACH  buf_goods
         where  buf_goods.gds-type = {&gds-goods}
         NO-LOCK
         :
         CREATE tt-gds.
         BUFFER-COPY buf_goods TO tt-gds.
      end.
   end.
   when {&g-grp} then do: /* товары по группам  */
      for each tmp#grp no-lock
         :
         run grplib-get-full-name in this-procedure ( input tmp#grp.node-code
                                                   , output v-curr-grp-name
                                                   ) .
         for each buf_goods
               where buf_goods.grp-name begins v-curr-grp-name
                 and buf_goods.gds-type = {&gds-goods}
               no-lock
         :
            find first tt-gds no-lock
               where tt-gds.artic     = buf_goods.artic
                 and tt-gds.prod-type = buf_goods.prod-type
                 and tt-gds.prod-code = buf_goods.prod-code
               no-error .
            if not available tt-gds then do:
               create tt-gds.
               buffer-copy buf_goods to tt-gds.
            end.
         end.
      end.
   end.
   when {&g-prod} then do: /* товары по производителю */
      for each  buf_goods
          where buf_goods.gds-type = {&gds-goods}
          no-lock
         ,
         each buf_cli-gds
            where buf_cli-gds.prod-type = buf_goods.prod-type
              and buf_cli-gds.prod-code = buf_goods.prod-code
              and buf_cli-gds.artic     = buf_goods.artic
            no-lock
            ,
         first g#cli
            where g#cli.obj-type = buf_cli-gds.cli-type
              and g#cli.obj-code = buf_cli-gds.cli-code
         :
            find first tt-gds no-lock
               where tt-gds.prod-type = buf_goods.prod-type
                 and tt-gds.prod-code = buf_goods.prod-code
                 and tt-gds.artic     = buf_goods.artic
            no-error.

            if not available tt-gds then do:
               create tt-gds.
               buffer-copy buf_goods to tt-gds no-error.
            end.
      end.
   end.
   when {&g-grp-prod} then do: /* группа и производитель */
      for each tmp#grp no-lock
         :
         run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
         for each  buf_goods no-lock
             where buf_goods.grp-name begins v-curr-grp-name
               and buf_goods.gds-type = {&gds-goods}
            :
            if NOT CAN-find ( first g#cli
                              where g#cli.obj-type = buf_goods.prod-type
                                and g#cli.obj-code = buf_goods.prod-code
                           )
            then NEXT .

            find first tt-gds no-lock
               where tt-gds.artic     = buf_goods.artic
                 and tt-gds.prod-type = buf_goods.prod-type
                 and tt-gds.prod-code = buf_goods.prod-code
               no-error .
            if not available tt-gds then do:
               create tt-gds.
               buffer-copy buf_goods to tt-gds no-error.
            end.
         end.
      end.
   end.
   OTHERWISE do:
      for each gds-list
         where gds-list.gds-type = {&gds-goods}
         :
         create tt-gds.
         buffer-copy gds-list to tt-gds.
      end.
   end.
   end case.
end.
end procedure. /* create-goods */

/*==========================================================================*/
procedure create-favour :  /* оставляем только услуги */
do
on error undo, return error return-value
:
   define buffer buf_goods    for ub.goods .
   define buffer buf_cli-gds  for ub.cli-gds .

   define variable v-curr-grp-name as character            no-undo .
   define variable v-host-code     like clients.host-code  no-undo .

   empty temp-table tt-gds.
   case p-sel-gds :
   /* все товары */
   when {&g-all} then do:
         for EACH  buf_goods
            where  buf_goods.gds-type = {&gds-office}
            NO-LOCK
            :
            CREATE tt-gds.
            BUFFER-COPY buf_goods TO tt-gds.
         end.
   end.
   when {&g-grp} then do: /* товары по группам  */
      for each tmp#grp no-lock
      :
      run grplib-get-full-name in this-procedure ( input tmp#grp.node-code
                                                   , output v-curr-grp-name
                                                   ) .
      for each buf_goods
            where buf_goods.grp-name begins v-curr-grp-name
              and buf_goods.gds-type = {&gds-office}
            no-lock
      :
         find first tt-gds no-lock
            where tt-gds.artic     = buf_goods.artic
              and tt-gds.prod-type = buf_goods.prod-type
              and tt-gds.prod-code = buf_goods.prod-code
            no-error .
         if not available tt-gds then do :
            create tt-gds.
            buffer-copy buf_goods to tt-gds.
         end.
      end.
      end.
   end.
   when {&g-prod} then do : /* товары по производителю */
      for each  buf_goods
            where
            buf_goods.gds-type = {&gds-office}
            no-lock
         ,
         each buf_cli-gds no-lock
            where buf_cli-gds.prod-type = buf_goods.prod-type
              and buf_cli-gds.prod-code = buf_goods.prod-code
              and buf_cli-gds.artic     = buf_goods.artic ,
         first g#cli
            where g#cli.obj-type = buf_cli-gds.cli-type
              and g#cli.obj-code = buf_cli-gds.cli-code
      :
         find first tt-gds no-lock
            where tt-gds.prod-type = buf_goods.prod-type
              and tt-gds.prod-code = buf_goods.prod-code
              and tt-gds.artic     = buf_goods.artic
         no-error.
         if not available tt-gds then do :
            create tt-gds.
            buffer-copy buf_goods to tt-gds no-error.
         end.
      end.
   end.
   when {&g-grp-prod} then do : /* группа и производитель */
      for each tmp#grp no-lock
      :
      run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .

      for each  buf_goods no-lock
          where buf_goods.grp-name begins v-curr-grp-name
            and buf_goods.gds-type = {&gds-office}
         :
         if NOT CAN-find ( first g#cli
                           where g#cli.obj-type = buf_goods.prod-type
                             and g#cli.obj-code = buf_goods.prod-code
                           )
         then NEXT .

         find first tt-gds no-lock
            where tt-gds.artic     = buf_goods.artic
              and tt-gds.prod-type = buf_goods.prod-type
              and tt-gds.prod-code = buf_goods.prod-code
            no-error .
         if not available tt-gds then do :
            create tt-gds.
            buffer-copy buf_goods to tt-gds no-error.
         end.
      end.
      end.

   end.
   OTHERWISE do :
      for each gds-list
         where gds-list.gds-type = {&gds-office}
         :
         create tt-gds.
         buffer-copy gds-list to tt-gds.
      end.
   end.
   end case.
end.
end procedure. /* create-favour */

/*==========================================================================*/
procedure ostatok :
define input parameter p-fact-order as decimal no-undo.
define input parameter p-begin      as logical no-undo.

define buffer buf_tt-clcparts for tt-clcparts .
define buffer buf_parts       for ub.parts .
define buffer buf_goods       for ub.goods .
define buffer buf_gds-dtl     for ub.gds-dtl .
define buffer buf_sysconf     for ub.sysconf .
define buffer buf_tt-itog     for tt-itog .
define buffer buf_gds-obj     for ub.gds-obj .
define buffer buf_trn-doc     for ub.trn-doc .

define variable varb-code              like ub.bar-code.b-code       no-undo .
define variable vardoc-num             like ub.price-doc.doc-num     no-undo .
define variable varcur-base            like ub.gds-dtl.price-base    no-undo .
define variable varcur-road-tax        like ub.doc-line.road-tax     no-undo .
define variable varcur-excise          like ub.doc-line.excise       no-undo .
define variable varcur-vat-pc          like ub.doc-line.vat-pc       no-undo .
define variable varcur-cons-vat-pc     like ub.doc-line.cons-vat-pc  no-undo .
define variable varcur-slt-pc          like ub.doc-line.slt-pc       no-undo .
define variable varcur-fact-qnty       like ub.gds-dtl.fact-qnty     no-undo .
define variable varprice-sale          like ub.price-list.price-sale no-undo .
define variable varroad-tax            like ub.price-list.road-tax   no-undo .
define variable varexcise              like ub.price-list.excise     no-undo .
define variable varlastcur-base        like ub.gds-dtl.price-base    no-undo .
define variable varlastcur-road-tax    like ub.gds-dtl.price-base    no-undo .
define variable varlastcur-excise      like ub.gds-dtl.price-base    no-undo .

define variable v-base-rate  as decimal  no-undo.
define variable v-base-scale as integer  no-undo.
define variable v-host-code  as integer  no-undo.

do
on error undo, return error
:

   for EACH obj-list:
       if x-TOG-Shift then 
       do:
           run factshift (obj-list.obj-code, obj-list.obj-type) no-error.
           if error-status:error then next .

       end.  
       for EACH tt-gds
       :
         { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
         /* ищем свободные партии по товару на объекте на начальную дату */
         run partslib-init-temp-parts-by-factord ( input obj-list.obj-type
                                                 , input obj-list.obj-code
                                                 , input tt-gds.artic
                                                 , input tt-gds.prod-type
                                                 , input tt-gds.prod-code
                                                 , input p-fact-order
                                                 , FALSE
                                                 ) .
         for EACH temp-parts where temp-parts.obj-type  = obj-list.obj-type
                               and temp-parts.obj-code  = obj-list.obj-code
                               and temp-parts.artic     = tt-gds.artic
                               and temp-parts.prod-type = tt-gds.prod-type
                               and temp-parts.prod-code = tt-gds.prod-code
                              NO-LOCK
                              :
            for each buf_tt-clcparts
            on error undo, return error return-value
            :
               delete buf_tt-clcparts .
            end.
            find first buf_trn-doc
                 where buf_trn-doc.doc-code =  temp-parts.in-code
                 no-lock
                 NO-ERROR
                 .
            if AVAILABLE buf_trn-doc
            then do :
               assign
                  v-base-rate  = buf_trn-doc.base-rate
                  v-base-scale = buf_trn-doc.base-scale
               .
            end .
            else do :
               assign
                  v-base-rate  = 0
                  v-base-scale = 0
               .
            end.
            create buf_tt-clcparts .
            buffer-copy temp-parts to buf_tt-clcparts .

            /* найдем значения налогов для товара на момент закрытия документа */
            { gbl/gdsbcode.i
               tt-gds.gds-code
               ?
               varb-code
            }
            /* по умолчанию налоги берутся из последней переоценки */
            { gbl/bcprcex.i
              obj-list.obj-type
              obj-list.obj-code
              varb-code
              0
              p-fact-order
              vardoc-num
              varprice-sale
              varroad-tax
              varexcise
              varcur-vat-pc
              varcur-slt-pc
            }
            if varprice-sale = ?
            then do :
               assign
               varcur-vat-pc = 0
               varcur-slt-pc = 0
               .
            end.
            /* Найдем текущую продажную цену и текущие налоги */
            for each buf_gds-dtl no-lock
               where buf_gds-dtl.doc-code  = temp-parts.in-code
                 and buf_gds-dtl.artic     = temp-parts.artic
                 and buf_gds-dtl.prod-type = temp-parts.prod-type
                 and buf_gds-dtl.prod-code = temp-parts.prod-code
            on error undo, return error return-value
            :
               { gbl/gdsbcode.i
                  tt-gds.gds-code
                  buf_gds-dtl.prt-code
                  varb-code
                  no-error
               }
               { gbl/bcodeprc.i
                  obj-list.obj-type
                  obj-list.obj-code
                  varb-code
                  0
                  p-fact-order
                  vardoc-num
                  varprice-sale
                  varroad-tax
                  varexcise
               }
               if varprice-sale = ?
               then do :
               assign
                  varprice-sale = 0
                  varroad-tax   = 0
                  varexcise     = 0
               .
               end.
               assign
                  varlastcur-base     = varprice-sale
                  varlastcur-road-tax = varroad-tax
                  varlastcur-excise   = varexcise
                  varcur-base         = varcur-base      + varprice-sale * buf_gds-dtl.fact-qnty
                  varcur-road-tax     = varcur-road-tax  + varroad-tax   * buf_gds-dtl.fact-qnty
                  varcur-excise       = varcur-excise    + varexcise     * buf_gds-dtl.fact-qnty
                  varcur-fact-qnty    = varcur-fact-qnty +                 buf_gds-dtl.fact-qnty
               .
            end. /* each buf_gds-dtl */
            if varcur-fact-qnty = 0 then do :
               assign
                  varcur-base      = varlastcur-base
                  varcur-road-tax  = varlastcur-road-tax
                  varcur-excise    = varlastcur-excise
               .
            end.
            else do :
               assign
                  varcur-base      = varcur-base      / varcur-fact-qnty
                  varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
                  varcur-excise    = varcur-excise    / varcur-fact-qnty
               .
            end.
            find first buf_sysconf
                where buf_sysconf.host-code = v-host-code
                no-lock.
            assign varcur-cons-vat-pc = buf_sysconf.cons-vat-pc .
            if varcur-cons-vat-pc = ? then do :
               assign varcur-cons-vat-pc = 0 .
            end.

            run clcprtsl_calc-ttable in this-procedure
               ( input TRUE  /* paris-doc         */
               , input TRUE  /* paris-cur         */
               , input 0     /* parroad-tax       */
               , input 0     /* parexcise         */
               , input varcur-vat-pc     /* parvat-pc         */
               , input varcur-cons-vat-pc     /* parcons-vat-pc    */
               , input 0     /* parslt-pc         */
               , input v-base-rate      /* parbase-rate      */
               , input v-base-scale     /* parbase-scale     */
               , input ( if tPrintRubl = yes then "rubl":U else "base":U )     /* parr-b            */
               , input varprice-sale          /* parcur-base       */
               , input varcur-road-tax        /* parcur-road-tax   */
               , input varcur-excise          /* parcur-excise     */
               , input varcur-vat-pc          /* parcur-vat-pc     */
               , input varcur-cons-vat-pc     /* parcurcons-vat-pc */
               , input varcur-slt-pc           /* parcurslt-pc      */
               ) no-error .
            RUN create-ost-lines ( INPUT temp-parts.obj-type
                                 , INPUT temp-parts.obj-code
                                 , INPUT ROUND(temp-parts.vat-pc, 0)
                                 , INPUT p-begin
/*                                 , input temp-parts.fact-qnty * varprice-sale*/
/*                                 , input temp-parts.fact-qnty * varprice-sale * varcur-vat-pc / 100*/
                                 ) .
      end. /* each temp-parts */
      end.
   end. /* each obj-list, tt-gds */
   /*
   run put-stick in this-procedure.

   for EACH buf_tt-itog
   :
      run put-total-line IN THIS-PROCEDURE ( buffer buf_tt-itog, INPUT p-begin).
      DELETE buf_tt-itog.
   end.
   */
end. /* do on error */
end procedure. /* ostatok */

/*==========================================================================*/
procedure create-ost-lines :
define input parameter p-obj-type as character        no-undo .
define input parameter p-obj-code as integer          no-undo .
define input parameter p-vat-pc   as character        no-undo .
define input parameter p-begin    as logical          no-undo .
/*define input parameter p-qqq as decimal          no-undo.*/
/*define input parameter p-qqq-vat as decimal          no-undo.*/

define buffer buf_tt-itog     for tt-itog .
define buffer buf_clients     for ub.clients .

do
on error undo, return error
:
   /* остатки по объектам */
   if rz-objecte
   then do :
      find first buf_tt-itog
           where buf_tt-itog.obj-type = p-obj-type
             and buf_tt-itog.obj-code = p-obj-code
             and buf_tt-itog.vat-pc   = "":U
             and buf_tt-itog.begin    = p-begin
           NO-ERROR
           .
      if NOT AVAILABLE buf_tt-itog
      then do :
            find  first buf_clients
                  where buf_clients.obj-type = p-obj-type
                    and buf_clients.obj-code = p-obj-code
                  NO-LOCK
                  NO-ERROR
                  .
            CREATE buf_tt-itog.
            assign
               buf_tt-itog.obj-type = p-obj-type
               buf_tt-itog.obj-code = p-obj-code
               buf_tt-itog.vat-pc   = "":U
               buf_tt-itog.obj-name = if AVAILABLE buf_clients then SUBSTITUTE("Оcтаток на &1 &2", if p-begin then "начало" else "конец", buf_clients.obj-name)
                                                               else SUBSTITUTE("Оcтаток на &1 &2 &3", if p-begin then "начало" else "конец", p-obj-type, p-obj-code)
               buf_tt-itog.begin    = p-begin
            .
      end.
      RUN update-ost-line ( BUFFER buf_tt-itog /*, INPUT p-qqq, INPUT p-qqq-vat*/ ).

      /* общий остаток разбивка по НДС */
      if VAT-PC
      then do :
         find first buf_tt-itog
              where buf_tt-itog.obj-type = p-obj-type
                and buf_tt-itog.obj-code = p-obj-code
                and buf_tt-itog.vat-pc   = p-vat-pc
                and buf_tt-itog.begin    = p-begin
               NO-ERROR
               .
         if NOT AVAILABLE buf_tt-itog
         then do :
               find  first buf_clients
                     where buf_clients.obj-type = p-obj-type
                       and buf_clients.obj-code = p-obj-code
                     NO-LOCK
                     NO-ERROR
                     .
               CREATE buf_tt-itog.
               assign
                  buf_tt-itog.obj-type = p-obj-type
                  buf_tt-itog.obj-code = p-obj-code
                  buf_tt-itog.vat-pc   = p-vat-pc
                  buf_tt-itog.obj-name = if AVAILABLE buf_clients then SUBSTITUTE("Оcтаток на &1 &2", if p-begin then "начало" else "конец", buf_clients.obj-name)
                                                                  else SUBSTITUTE("Оcтаток на &1 &2 &3", if p-begin then "начало" else "конец", p-obj-type, p-obj-code)
                  buf_tt-itog.begin    = p-begin
               .
         end.
         RUN update-ost-line ( BUFFER buf_tt-itog /*, INPUT p-qqq, INPUT p-qqq-vat*/  ).
      end.
   end.

   /* общий остаток */
   find first buf_tt-itog
        where buf_tt-itog.obj-type = "zzz":U
          and buf_tt-itog.obj-code = 0
          and buf_tt-itog.vat-pc   = "":U
          and buf_tt-itog.begin    = p-begin
        NO-ERROR
        .
   if NOT AVAILABLE buf_tt-itog
   then do:
      CREATE buf_tt-itog.
      assign
         buf_tt-itog.obj-type = "zzz":U
         buf_tt-itog.obj-code = 0
         buf_tt-itog.vat-pc   = "":U
         buf_tt-itog.begin    = p-begin
      .
   end.
   RUN update-ost-line ( BUFFER buf_tt-itog /*, INPUT p-qqq, INPUT p-qqq-vat */ ).
   /* общий остаток разбивка по НДС */
   if VAT-PC
   then do:
      find first buf_tt-itog
           where buf_tt-itog.obj-type = "zzz":U
             and buf_tt-itog.obj-code = 0
             and buf_tt-itog.vat-pc   = p-vat-pc
             and buf_tt-itog.begin    = p-begin
         NO-ERROR
         .
      if NOT AVAILABLE buf_tt-itog
      then do:
         CREATE buf_tt-itog.
         assign
            buf_tt-itog.obj-type = "zzz":U
            buf_tt-itog.obj-code = 0
            buf_tt-itog.vat-pc   = p-vat-pc
            buf_tt-itog.begin    = p-begin
         .
      end.
      RUN update-ost-line ( BUFFER buf_tt-itog /*, INPUT p-qqq, INPUT p-qqq-vat */ ).
   end.
end. /* do on error */
end procedure. /* create-ost-lines */

/*==========================================================================*/
procedure update-ost-line :
DEFINE PARAMETER BUFFER bf_tt-itog for tt-itog.
/*define input parameter p-qq as decimal          no-undo.*/
/*define input parameter p-qq-vat as decimal          no-undo.*/

define buffer buf_tt-allsum-line    for tt-allsum-line .

do
on error undo, return error
:
   find first buf_tt-allsum-line
      where buf_tt-allsum-line.sum-type = {&sum-general}
      no-error .
   if available buf_tt-allsum-line
   then do:
      assign
         bf_tt-itog.col09-qnty      = bf_tt-itog.col09-qnty       + buf_tt-allsum-line.fact-qnty

         bf_tt-itog.SumWithNDS-cost = bf_tt-itog.SumWithNDS-cost  + if tPrintRubl then buf_tt-allsum-line.sum-dsc-rubl-acc else buf_tt-allsum-line.sum-dsc-base-acc
         bf_tt-itog.VAT-cost        = bf_tt-itog.VAT-cost         + if tPrintRubl then buf_tt-allsum-line.vat-rubl-acc     else buf_tt-allsum-line.vat-base-acc

         bf_tt-itog.SumWithNDS-sale = bf_tt-itog.SumWithNDS-sale  + if tPrintRubl then buf_tt-allsum-line.sum-dsc-rubl-doc else buf_tt-allsum-line.sum-dsc-base-doc
         bf_tt-itog.VAT-sale        = bf_tt-itog.VAT-sale         + if tPrintRubl then buf_tt-allsum-line.vat-rubl-doc     else buf_tt-allsum-line.vat-base-doc

         bf_tt-itog.SumWithNDS-crsa = bf_tt-itog.SumWithNDS-crsa  + (if tPrintRubl then buf_tt-allsum-line.sum-dsc-rubl-cur else buf_tt-allsum-line.sum-dsc-base-cur) /* p-qq */
         bf_tt-itog.VAT-crsa        = bf_tt-itog.VAT-crsa         + (if tPrintRubl then buf_tt-allsum-line.vat-rubl-cur     else buf_tt-allsum-line.vat-base-cur) /* p-qq-vat */
      .
   end.
end. /* do on error */
end procedure. /* update-ost-line */

/*==========================================================================*/
 procedure format-itog :
 if tt-all.col07-clients begins "Итого" then do :
    run print-bold in this-procedure .
 end .
 end procedure.
/*==========================================================================*/
 procedure print-bold :
       run macr_cell_format in this-procedure
        (input 10           /* p-size   */
        ,input true         /* p-bold   */
        ,input false        /* p-italic */
        ,input ?            /* p-color  */
        ,input num#str#     /* p-row    */
        ,input num#col#     /* p-col    */
        ,input ?            /* p-row-2  */
        ,input ?            /* p-col-2  */
        ) .
 end procedure.
/*==========================================================================*/

procedure factshift:
define input parameter p-obj-code as integer no-undo .
define input parameter p-obj-type as character no-undo .  
define buffer end_shift-obj      for ub.shift-obj .
define buffer previous-shift-obj for ub.shift-obj.
define variable fo      as decimal no-undo init 0.
define variable prev-fo as decimal no-undo init 0.
define variable moving  as logical no-undo init yes.

assign
pobj-code = p-obj-code .
pobj-type = p-obj-type .

   find first end_shift-obj share-lock
      where end_shift-obj.obj-type   = pobj-type
      and end_shift-obj.obj-code   = pobj-code
      and end_shift-obj.shift-date = pshift-date1
      and end_shift-obj.shift-num  = pshift-num1
      no-error.
   if not available end_shift-obj then 
   do:
      find last end_shift-obj share-lock
         where end_shift-obj.obj-type   = pobj-type
         and end_shift-obj.obj-code   = pobj-code
         and end_shift-obj.shift-date = pshift-date1
         no-error.
      if not available (end_shift-obj) then 
      do: 
         find last end_shift-obj share-lock
            where end_shift-obj.obj-type   = pobj-type
            and end_shift-obj.obj-code   = pobj-code
            and end_shift-obj.shift-date < pshift-date1
            no-error.
         if not available (end_shift-obj) then 
         do:          
/*            message                                                                                                                                 */
/*               vss-workfile vss-revision vss-description skip                                                                                       */
/*               substitute("Не найдена смена с порядковым номером &1 от &2 для объекта &3 &4", pshift-num1, pshift-date1, pobj-type, pobj-code ) skip*/
/*               view-as alert-box error .                                                                                                            */
            return error.
         end.
      end.
   end.
   assign
      fo = end_shift-obj.fact-order
      .


   find last previous-shift-obj share-lock
      where previous-shift-obj.obj-type = pobj-type
      and previous-shift-obj.obj-code = pobj-code
      and (( previous-shift-obj.shift-date = pshift-date
      and previous-shift-obj.shift-num < pshift-num
      )
      or previous-shift-obj.shift-date < pshift-date
      )
      use-index pi no-error.
   if available previous-shift-obj then 
   do:

      if  previous-shift-obj.shift-date < p-previous-shift-date then 
      do:
         run day-begin-fact-order in this-procedure (
            input  p-previous-shift-date
            ,output prev-fo).
      end.
      else 
      do:
         assign
            prev-fo = previous-shift-obj.fact-order
            .
      end.
   end.

v-fact-order-start = prev-fo.

if fo > 0 then
v-fact-order-end = fo .
else v-fact-order-end = 99999999999999.

    
end procedure .    
procedure display-title :
assign
  num#str# = 1
  num#col# = 1
.
put stream outstream  reportname  at 20 format "x(170)" skip
                      trim(str1)  at 20 format "x(75)" .
run macr_excel_char_with_format in this-procedure
                (input  reportname
                ,input  num#str#
                ,input  num#col#
                ) .
run macr_cell_format in this-procedure
  (input 18           /* p-size   */
  ,input true         /* p-bold   */
  ,input false        /* p-italic */
  ,input ?            /* p-color  */
  ,input num#str#     /* p-row    */
  ,input num#col#     /* p-col    */
  ,input ?            /* p-row-2  */
  ,input ?            /* p-col-2  */
  ) .
assign num#str# = num#str# + 1.

run macr_excel_char_with_format in this-procedure
                (input  str1
                ,input  num#str#
                ,input  num#col#
                ) .
assign num#str# = num#str# + 1.


repeat i = 1 to num-entries(str2,chr(10)) :
  put stream outstream entry(i,str2,chr(10))  at 1 format "x(170)" skip .
  run macr_excel_char_with_format in this-procedure
                  (input  entry(i,str2,chr(10))
                  ,input  num#str#
                  ,input  num#col#
                  ) .
  assign num#str# = num#str# + 1.
end.

put stream outstream trim(str3)  at 1 format "x(75)" skip.
run macr_excel_char_with_format in this-procedure
                (input  str3
                ,input  num#str#
                ,input  num#col#
                ) .
assign num#str# = num#str# + 1.

repeat i = 1 to num-entries(str4,chr(10)) :
  put stream outstream entry(i,str4,chr(10))  at 1 format "x(170)" skip .
  run macr_excel_char_with_format in this-procedure
                    (input  entry(i,str4,chr(10))
                    ,input  num#str#
                    ,input  num#col#
                    ) .
  assign num#str# = num#str# + 1.
end.


repeat i = 1 to num-entries(reportheader,chr(10)) :
  put stream outstream entry(i,reportheader,chr(10))  at 1 format "x(170)" skip .
  run macr_excel_char_with_format in this-procedure
                  (input  entry(i,reportheader,chr(10))
                  ,input  num#str#
                  ,input  num#col#
                  ) .
  assign num#str# = num#str# + 1.
end.

end procedure.

 { rep/r-libmcr.i macr_excel         }