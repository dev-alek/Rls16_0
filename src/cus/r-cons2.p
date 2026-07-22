block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-cons2.p $
$Archive: cus/r-cons2.p $

Совокупная заявка по товарам развернутая EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 09/13/05
Author: Svetlana Chernova
Creation date: 09/13/05

04/17/02 1:07

*/

define input parameter parParentProc  as widget-handle no-undo.
define input parameter c-rc as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cons2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-cons2.p $":U .
define variable vss-description as character no-undo init " Совокупная заявка по товарам развернута  EXCEL   ".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i new  }
{ cmp/r-pril.i  NEW  }
{ gbl/cur-time.i     }
{ rep/repfrm.i def   }
{ rep/f-fdec.i       }
{ gbl/paramls.i      }
{ gbl/getcntxt.i def }


define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc  ( output g#report-num ).
{ gbl/getcntxt.i get }
define variable v-cntxt-host-name-obj as character no-undo .
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }

define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define buffer bf_ord-cons for ub.ord-cons .
define buffer bf_ord-cons-gds for ub.ord-gds-cons .
define buffer bf_ord-doc for ub.ord-doc .
define buffer loc_ord-doc for ub.ord-doc.
define buffer loc_ord-line for ub.ord-line.
define buffer b-goods for ub.goods.
define buffer b_clients for ub.clients.
define buffer loc_ord-doc-rcv for ub.ord-doc-rcv.
define buffer loc_ord-line-rcv for ub.ord-line-rcv.
define buffer z_ord-doc for ub.ord-doc.
define buffer z_ord-line for ub.ord-line.

define variable l-ord-code as character no-undo .
define variable l-rcv-code as character no-undo .

define variable l-qnty-of   like ub.place.max-qnty no-undo .
define variable l-time-of   as integer no-undo .
define variable g-qnty-fp   like ub.place.max-qnty no-undo .
define variable l-qnty-fp   like ub.place.max-qnty no-undo .
define variable l-qnty-rcv  like ub.place.max-qnty no-undo .
define variable l-time-fp   as integer no-undo .
define variable l-time-rcv  as integer no-undo .
define variable l-cli-code  as character no-undo .
define variable l-cli-name  as character no-undo .
define variable ii      as integer no-undo .
define variable l-nn    as integer no-undo .
define variable kk      as integer no-undo .
define variable max-str as integer no-undo .
define variable old-l-ord-code as character no-undo .

define variable  s-qnty-of      as decimal no-undo .
define variable  s-qnty-fp      as decimal no-undo .
define variable  s-qnty-rcv     as decimal no-undo .

define temp-table temp-tt no-undo
field obj-type    like ub.clients.obj-type
field obj-name    like ub.clients.obj-name

field gds-code    like ub.goods.gds-code
field qnty-of     like ub.ord-line.qnty               /*Заявленное количество"                       */
field time-of     as char                          /*Предполагаемое время завоза"                 */

field ord-code    as character                      /*ЗАКАЗЫ                                       */
field qnty-fp     like ub.ord-line.qnty             /*Заказанное у поставщика кол-во"              */
field cli-cod     as character                      /*Код поставщика"                              */
field cli-name    as character                      /*Наименование поставщика "                    */

field rcv-code    as character                      /*ПОСТАВКА                                     */
field time-rcv    as char                           /*Согласованное время завоза  (поставок)"       */
field qnty-rcv    like ub.ord-line.qnty             /*Количество в поставке"                       */
field nnn as integer                                /*#                                            */
INDEX pi IS UNIQUE PRIMARY
  obj-type
  nnn
  gds-code
  ord-code
  rcv-code
      .

define temp-table temp-tt-host no-undo  like temp-tt .

define stream  instream  .
define stream  outstream  .
define stream  outstream2  .

make-excel-com = false .
make-excel     = true  .

define stream  macr_excel .



define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x (60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define variable var-3 as integer no-undo .


define variable is-l as integer no-undo .

&scop for-each-gds-cons for each ~
 bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,~
    first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic                         ~
                      and bf_ord-cons-gds.prod-type = ub.goods.prod-type             ~
                      and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :

FUNCTION excel-qnty-null RETURNS char  (INPUT p-dec as decimal ).
if p-dec = 0 then Return  ("").
   else RETURN (format-excel-text (excel-format-dec-to-char (Round (p-dec,3)))) .
END FUNCTION.



main-block :
do on error undo main-block, return error
:

find first  bf_ord-cons where recid (bf_ord-cons) = c-rc no-lock no-error .
for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code :
 ii = ii + 1.
 if ii > 31 then leave.
end.

if ii > 31 then do:
    message "Отчет не может быть выполнен на такое количество товаров !  "
    skip
    "Воспользуйтесь отчетом 'Совокупная заявка по товарам ' "
    view-as alert-box error.
    return error.
end.

    p-file-name =  string ( session:temp-directory +
                                  {&df_name} + string ( g#report-num ) + ".txt" ) .

    output stream outstream to value ( string ( session:temp-directory +
                                  {&df_name} + string ( g#report-num ) ) )      .
    output stream outstream2 to value (p-file-name).

/* создаем временный файл */
run gbl/_tmpfile.p  ( "wb", ".txt", output v-file-name) .
output stream macr_excel to value (v-file-name)   .
v-ind = 1    .
num#str# = 1 .
num#col# = 1 .



{ rep/repfrm.i on 50 }
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }

Make-Excel = true .

/*ШАПКА*/
reportname =  "Совокупная заявка по товарам по фирме № " +
              bf_ord-cons.cons-code + " от " +
              string (bf_ord-cons.doc-date,"99/99/9999") +
              " (развернутый формат)"
              .
reportheader =   cur-time-print () .
      run macr_excel_char_with_format  ( reportname , num#str# , num#col#  ).
      run macr_cell_format
           ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */

define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable v-nn as integer   no-undo .
&scop var-print-n  v-nn = num-entries ( ~{&var-str-n} , "~{&new-line}"  )  .   do l-ii = 1 to v-nn  :  ~
      l-len = length  (entry ( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer ( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format  (                                                          ~
              substring (entry ( l-ii , ~{&var-str-n}  , "~{&new-line}") ,  ( ( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
      end.                                                                                                       ~
  end.
/*
&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str3
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }
*/
&scop var-str-n  reportheader
{&var-print-n }


Sheetf.Excel-Column-Lable = "Код объекта ,Наименование объекта  ,".
Sheetf.Sizes = "8,20,".

/*Первая строка*/
{&for-each-gds-cons}
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + " Арт " + ub.goods.artic + "," + string (ub.goods.gds-name) + ",,,,,,," .
     Sheetf.Sizes = Sheetf.Sizes + Fill ("12,", 3) .
     Sheetf.Sizes = Sheetf.Sizes +  ("8,") .
     Sheetf.Sizes = Sheetf.Sizes +  ("20,") .
     Sheetf.Sizes = Sheetf.Sizes +  ("8,") .
     Sheetf.Sizes = Sheetf.Sizes +  ("12,") .
     Sheetf.Sizes = Sheetf.Sizes +  ("21,") .
End.

     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable  + {&new-line} +  ",".


/*Вторая строка*/
{&for-each-gds-cons}
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable
    + ",Заявленное количество"
    + ",Предполагаемое время завоза"
    + ",Заказанное у поставщика кол-во от фирмы в целом"
    + ",Код поставщика"
    + ",Наименование поставщика "
    + ",Согласованное время завоза  (поставок)"
    + ",Количество в поставке"
    + ",№ поставки"
      .
End.
sheetf.make-correct =  "".
run proc-print-header-my .
run make-tt .
run make-tt-in .
/*
for each temp-tt :
message
 "obj-type           " string (temp-tt.obj-type)  skip
 "obj-name           " string (temp-tt.obj-name)  skip
           skip
 "gds-code           " string (temp-tt.gds-code)  skip
 "qnty-of            " string (temp-tt.qnty-of )  skip
 "time-of            " string (temp-tt.time-of )  skip
           skip
 "ord-code           " string (temp-tt.ord-code)  skip
 "qnty-fp            " string (temp-tt.qnty-fp )  skip
 "cli-cod            " string (temp-tt.cli-cod )  skip
 "cli-name           " string (temp-tt.cli-name)  skip
           skip
 "rcv-code           " string (temp-tt.rcv-code)  skip
 "time-rcv           " string (temp-tt.time-rcv)  skip
 "qnty-rcv           " string (temp-tt.qnty-rcv)  skip
 "nnn                " string (temp-tt.nnn     )  skip
 .
end.
  */
 num#str# = num#str# + 1.
/* по объектам заявок */
for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code and
                                    bf_ord-doc.doc-type = {&o-f}      ,
     first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                     and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                break by ub.clients.obj-type by ub.clients.obj-code :

     if last-of (ub.clients.obj-code) then do:
       num#str# = num#str# + 1.    /* конец строки */
       old-l-ord-code = "".
       run max-col  (input ub.clients.obj-code, input  ub.clients.obj-type ,output  max-str) .
       do kk = 1 to max-str :
            if kk = 1 then do:
                num#col# = 1.
                run macr_excel_char_with_format  (  (ub.clients.obj-type + " " + string (ub.clients.obj-code))  , num#str# , num#col# ) .
                num#col# = num#col# + 1 .
                run macr_excel_char_with_format  (  (ub.clients.obj-name)  , num#str# , num#col#)            .
            end.
            else do:
                num#col# = 2.
            end.

         {&for-each-gds-cons}
            find first   temp-tt where temp-tt.obj-type = ub.clients.obj-type + " " + string (ub.clients.obj-code) and
                                    temp-tt.gds-code = ub.goods.gds-code and
                                    temp-tt.nnn = kk no-error .
                    is-l = 0.
                    if avail temp-tt then do:
                      num#col# = num#col# + 1.  if temp-tt.qnty-of  > 0 then do:                  run macr_excel_dec  (temp-tt.qnty-of, num#str# , num#col#  )   .  end.   else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-of  > 0 then do:                  run macr_excel_char (temp-tt.time-of, num#str# , num#col#  )     .  end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_dec  (temp-tt.qnty-fp, num#str# , num#col#    )   .  end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                                                if temp-tt.ord-code = "in":U then  do: is-l = is-l + 1. run macr_excel_char  ("внутр.перем.", num#str# , num#col#    )   .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_char (temp-tt.cli-cod, num#str# , num#col#  )      . end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_char_with_format (temp-tt.cli-name, num#str# , num#col#  )  . end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_char (temp-tt.time-rcv, num#str# , num#col#  )     . end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_dec  (temp-tt.qnty-rcv, num#str# , num#col#  )    . end.  else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1.
                                                   if temp-tt.ord-code = "in":U then
                                                      run macr_excel_char (temp-tt.rcv-code  , num#str# , num#col#  ).
                                                   else
                                                      run macr_excel_char (temp-tt.rcv-code + " заказ№ " + temp-tt.ord-code , num#str# , num#col#  ).
                                                   end.
                                                   else do: run macr_excel_char ( " ", num#str# , num#col#  )     .
                                                   end.
                    end.
                    else do:
                      num#col# = num#col# + 8.
                    end.
         end.  /* проход по всем товарам */
           /* if is-l > 0 then*/
            num#str# = num#str# + 1.    /* конец строки */
       end.
     end.
end.

/*-----------------------------------------------------------------------------------------------------------------------*/
if is-l = 0 then num#str# = num#str# + 1.

num#col# =  1.
run macr_excel_char ( "Итого по объектам" , num#str# , num#col# ) .
num#col# = 2.

 {&for-each-gds-cons}
    assign
        s-qnty-of     = 0
        s-qnty-fp     = 0
        s-qnty-rcv    = 0
        .
      for each   temp-tt where temp-tt.gds-code = ub.goods.gds-code :
      assign
        s-qnty-of     = s-qnty-of     + temp-tt.qnty-of
        s-qnty-fp     = g-qnty-fp
        s-qnty-rcv    = s-qnty-rcv    + temp-tt.qnty-rcv
        .
      end.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-of , num#str# , num#col#  )    .
          num#col# = num#col# + 1.
          num#col# = num#col# + 1. /* run macr_excel_dec  ( s-qnty-fp , num#str# , num#col#  )  */  .
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-rcv, num#str# , num#col#  )    .
          num#col# = num#col# + 1.
  .

 end.  /* проход по всем товарам */
  /* bold */
  run macr_cell_format
       ( 10    ,      /* p-size     */
        true  ,      /* p-bold     */
        false ,      /* p-italic   */
        ?     ,      /* p-color-bg */
        num#str# ,   /* p-row      */
        1        ,   /* p-col      */
        num#str# ,   /* p-row-2    */
        num#col#     /* p-col-2    */
        ) .

/* Разбивка по фирме */
run make-tt-host .
/* по заказам ФП */
     for each ub.clients  where ub.clients.obj-code =  v-cntxt-host-code-obj
                        and  ub.clients.obj-type =  {&cmp} no-lock
                    break by ub.clients.obj-type by ub.clients.obj-code :

     if last-of (ub.clients.obj-code) then do:
       old-l-ord-code = "".
       run max-col-host  (input ub.clients.obj-code, input  ub.clients.obj-type ,output  max-str) .
       do kk = 1 to max-str :
            if kk = 1 then do:
                num#str# = num#str# + 1.
                num#col# = 1.
                run macr_excel_char_with_format  (  (ub.clients.obj-type + " " + string (ub.clients.obj-code))  , num#str# , num#col# ) .
                num#col# = num#col# + 1 .
                run macr_excel_char_with_format  (  (ub.clients.obj-name)  , num#str# , num#col#)            .
            end.
            else do:
                num#col# = 2.
            end.

         {&for-each-gds-cons}
            find first   temp-tt-host where temp-tt-host.obj-type = ub.clients.obj-type + " " + string (ub.clients.obj-code) and
                                    temp-tt-host.gds-code = ub.goods.gds-code and
                                    temp-tt-host.nnn = kk no-error .
                    if avail temp-tt-host then do:
                     num#col# = num#col# + 1. /* run macr_excel_dec  (temp-tt-host.qnty-of  , num#str# , num#col#  )   .*/
                     num#col# = num#col# + 1.  run macr_excel_char (temp-tt-host.time-of, num#str# , num#col#  )     .
                     num#col# = num#col# + 1.  run macr_excel_dec  (temp-tt-host.qnty-fp, num#str# , num#col#    )   .
                     num#col# = num#col# + 1.  run macr_excel_char (temp-tt-host.cli-cod, num#str# , num#col#  )      .
                     num#col# = num#col# + 1.  run macr_excel_char_with_format (temp-tt-host.cli-name, num#str# , num#col#  )     .
                     num#col# = num#col# + 1.  run macr_excel_char (temp-tt-host.time-rcv, num#str# , num#col#  )     .
                     num#col# = num#col# + 1.  run macr_excel_dec  (temp-tt-host.qnty-rcv, num#str# , num#col#  )    .
                     num#col# = num#col# + 1.  run macr_excel_char (temp-tt-host.rcv-code, num#str# , num#col#  )    .
                    end.
                    else do:
                      num#col# = num#col# + 8.
                    end.
         end.  /* проход по всем товарам */
            num#str# = num#str# + 1.
          /* конец строки */
       end.
     end.
end.
/*-----------------------------------------------------------------------------------------------------------------------*/
num#col# =  1.
run macr_excel_char ( "Итого по заказам ФП по фирме" , num#str# , num#col# ) .
num#col# = 2.

 {&for-each-gds-cons}
    assign
        s-qnty-of     = 0
        s-qnty-fp     = 0
        s-qnty-rcv    = 0
        .
      for each   temp-tt-host where temp-tt-host.gds-code = ub.goods.gds-code :
      assign
        s-qnty-of     = temp-tt-host.qnty-of
        s-qnty-fp     = s-qnty-fp     + temp-tt-host.qnty-fp
        s-qnty-rcv    = s-qnty-rcv    + temp-tt-host.qnty-rcv
        .
      end.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-of , num#str# , num#col#  )    .
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-fp , num#str# , num#col#  )    .
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-rcv, num#str# , num#col#  )    .
          num#col# = num#col# + 1.
  .

 end.  /* проход по всем товарам */
  /* bold */
  run macr_cell_format
       ( 10    ,      /* p-size     */
        true  ,      /* p-bold     */
        false ,      /* p-italic   */
        ?     ,      /* p-color-bg */
        num#str# ,   /* p-row      */
        1        ,   /* p-col      */
        num#str# ,   /* p-row-2    */
        num#col#     /* p-col-2    */
        ) .


run cur-time in this-procedure  ( output v-today, output v-time ).
    num#str# = num#str# + 1.
    num#col# =  1.
run macr_excel_char (  " Печать закончена : " + string (v-time,"HH:MM:SS"), num#str# , num#col#     )   .

  Output stream OutStream   close .
  Output stream Macr_Excel  close .
  { rep/repfrm.i off}
    run paramls-write in this-procedure
       (input "file"
      ,input string (v-ind)
      ,input v-file-name
      ) .

    run paramls-write in this-procedure
         (input "charcol"
        ,input ""
        ,input "1,2"
        ) .

  run end-proc .
  run rep/runexcel.p  (string ( session:temp-directory) + {&DF_Name} + string ( g#report-num ) + ".txt").
 end.  /* main */

/*-----------------------------------------------------------------------------------------------------------------------*/

procedure make-tt :
define variable tt-line  as logical no-undo .
define variable ttt-line as logical no-undo .


for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code
                                and bf_ord-doc.doc-type = {&o-f}  ,
  first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                  and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                  break by ub.clients.obj-type by ub.clients.obj-code:
  if first-of (ub.clients.obj-code) then do:
     ii = 0 .
      /* товары ------------------------------------------------------------------------------------------------*/
    for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,
      first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic
            and bf_ord-cons-gds.prod-type = ub.goods.prod-type
            and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            assign
              l-nn = 0
              l-qnty-of = 0
              l-time-of = 0
            .
       /* заявки -------------------------------------------------------------------------------------*/
        for each  z_ord-doc no-lock  where z_ord-doc.cons-code = bf_ord-cons.cons-code
                                            and z_ord-doc.doc-type = {&o-f}
                                            and ub.clients.obj-code =  z_ord-doc.obj-code
                                            and ub.clients.obj-type =  z_ord-doc.obj-type
                                           ,
                each z_ord-line no-lock where z_ord-doc.doc-code   = z_ord-line.doc-code and
                                                z_ord-line.artic     = bf_ord-cons-gds.artic      and
                                                z_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                                z_ord-line.prod-code = bf_ord-cons-gds.prod-code :
                  l-qnty-of = l-qnty-of + z_ord-line.qnty.
                  l-time-of =  z_ord-doc.ship-time.
        end.
        /* заказ ---------------------------------------------------------------------------------------*/
        assign
        l-cli-code  = ""
        l-cli-name  = ""
        l-ord-code  = ""
        ttt-line = false
        l-qnty-fp = 0
        g-qnty-fp = 0
        .
        for each loc_ord-doc no-lock  where loc_ord-doc.cons-code =  bf_ord-cons.cons-code
                                        and loc_ord-doc.doc-type = {&f-p}
                                  ,
        first b_clients  where b_clients.obj-code =  loc_ord-doc.cli-code
                          and  b_clients.obj-type =  loc_ord-doc.cli-type no-lock ,
        each loc_ord-line no-lock where loc_ord-doc.doc-code   = loc_ord-line.doc-code and
                                        loc_ord-line.artic     = bf_ord-cons-gds.artic      and
                                        loc_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                        loc_ord-line.prod-code = bf_ord-cons-gds.prod-code
                      break by  loc_ord-doc.doc-code   :

            l-qnty-fp = l-qnty-fp + loc_ord-line.qnty.
            g-qnty-fp = g-qnty-fp + loc_ord-line.qnty.
            if first-of  ( loc_ord-doc.doc-code ) then do:
            l-cli-code  =  b_clients.obj-type + " "  + string ( b_clients.obj-code).
            l-cli-name  =  b_clients.obj-name.
            l-ord-code  = loc_ord-line.doc-code.

            /* Поставка ----------------------------------------------------------------------*/
                tt-line = false  .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code
                                                    and loc_ord-doc-rcv.obj-code   = ub.clients.obj-code
                                                    and loc_ord-doc-rcv.obj-type   = ub.clients.obj-type   ,

                      each loc_ord-line-rcv no-lock where loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :

                            l-rcv-code  = loc_ord-line-rcv.rcv-code.
                            l-time-rcv  = loc_ord-doc-rcv.ship-time.
                            l-qnty-rcv =  loc_ord-line-rcv.qnty.
                        run create-tt-line .
                        assign
                          tt-line = true
                          l-rcv-code = ""
                          l-time-rcv = 0
                          l-qnty-rcv = 0
                        .

                end.
              if tt-line = false then run create-tt-line .
            end.  /*1 заказа*/
          ttt-line = true .
          if last-of  ( loc_ord-doc.doc-code ) then l-qnty-fp = 0.
        end. /* заказы */
          if ttt-line = false then  run create-tt-line .
    end. /* товары */
  end.  /* объекты */
end.   /*заявки */
end procedure .

procedure make-tt-in :
define variable tt-line  as logical no-undo .
define variable ttt-line as logical no-undo .

define buffer l_clients for ub.clients .

for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code
                                and bf_ord-doc.doc-type = {&o-f}  ,
  first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                  and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                  break by ub.clients.obj-type by ub.clients.obj-code:
  if first-of (ub.clients.obj-code) then do:
     ii = 0 .
      /* товары ------------------------------------------------------------------------------------------------*/
    for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,
      first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic
            and bf_ord-cons-gds.prod-type = ub.goods.prod-type
            and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            assign
              l-nn = 0
              l-qnty-of = 0
              l-time-of = 0
            .
        /* заказ ---------------------------------------------------------------------------------------*/
        assign
        l-cli-code  = ""
        l-cli-name  = ""
        l-ord-code  = ""
        ttt-line = false
        l-qnty-fp = 0
        g-qnty-fp = 0
        .

            /* Поставка ----------------------------------------------------------------------*/
                tt-line = false  .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-type   = "in":U
                                                    and loc_ord-doc-rcv.obj-code   = ub.clients.obj-code
                                                    and loc_ord-doc-rcv.obj-type   = ub.clients.obj-type   ,

                      each loc_ord-line-rcv no-lock where
                            loc_ord-doc-rcv.doc-code   = loc_ord-line-rcv.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :

                            find first l_clients  where l_clients.obj-code =  loc_ord-doc-rcv.cli-code
                                                   and  l_clients.obj-type =  loc_ord-doc-rcv.cli-type no-lock no-error .

                            l-ord-code = "in":U .
                            l-rcv-code = loc_ord-line-rcv.rcv-code .
                            l-time-rcv = loc_ord-doc-rcv.ship-time.
                            l-qnty-rcv = loc_ord-line-rcv.qnty.
                            l-cli-code = l_clients.obj-type + " " + string (l_clients.obj-code).
                            l-cli-name = l_clients.obj-name.
                            l-nn = l-nn + 1.
                            run create-tt-line .
                        assign
                          tt-line = true
                          l-rcv-code = ""
                          l-time-rcv = 0
                          l-qnty-rcv = 0
                        .

                end.
            /* Поставка ----------------------------------------------------------------------*/
                tt-line = false  .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code  =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-type   = "in":U
                                                    and loc_ord-doc-rcv.cli-code   = ub.clients.obj-code
                                                    and loc_ord-doc-rcv.cli-type   = ub.clients.obj-type ,

                      each loc_ord-line-rcv no-lock where
                            loc_ord-doc-rcv.doc-code   = loc_ord-line-rcv.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :

                            find first l_clients  where l_clients.obj-code =  loc_ord-doc-rcv.obj-code
                                                   and  l_clients.obj-type =  loc_ord-doc-rcv.obj-type no-lock no-error .
                            l-ord-code = "in":U .
                            l-rcv-code = loc_ord-line-rcv.rcv-code .
                            l-time-rcv = loc_ord-doc-rcv.ship-time.
                            l-qnty-rcv =  ( - 1 ) * loc_ord-line-rcv.qnty.
                            l-cli-code = l_clients.obj-type + " " + string (l_clients.obj-code).
                            l-cli-name = l_clients.obj-name.
                            l-nn = l-nn + 1.
                        run create-tt-line .
                        assign
                          tt-line = true
                          l-rcv-code = ""
                          l-time-rcv = 0
                          l-qnty-rcv = 0
                        .

                end.

    end. /* товары */
  end.  /* объекты */
end.   /*заявки */
end procedure .

procedure create-tt-line :
ii = ii + 1.
{ rep/repfrm.i disp ii  reportname ub.clients.obj-name ub.goods.gds-name}
 l-nn = l-nn + 1 .

create temp-tt .
assign
 temp-tt.nnn         = l-nn         /* N строки */
 temp-tt.obj-type    = ub.clients.obj-type + " " + string (ub.clients.obj-code)
 temp-tt.obj-name    = ub.clients.obj-name
 temp-tt.gds-code    = ub.goods.gds-code
 .
 If l-nn = 1 then Do:
      assign
          temp-tt.qnty-of     = l-qnty-of                                 /*Заявленное количество"*/
          temp-tt.time-of     =  (if l-time-of  = 0 then " " else string (l-time-of,"HH:MM"))
          .
       end.
 else
      assign
          temp-tt.qnty-of     = 0
          temp-tt.time-of     = " "
          .
/* if old-l-ord-code <> l-ord-code then do: */
    assign
        temp-tt.qnty-fp     = l-qnty-fp        /* Заказанное у поставщика кол-во"              */
        temp-tt.cli-cod     = l-cli-code
        temp-tt.cli-name    = l-cli-name       /* Наименование поставщика "                    */
        .

 assign
    temp-tt.ord-code    = l-ord-code       /* ЗАКАЗЫ                                       */
    old-l-ord-code      = l-ord-code
    temp-tt.rcv-code    = l-rcv-code       /* ПОСТАВКА                                     */
    temp-tt.time-rcv    =  (if l-time-rcv  = 0 then  " " else string (l-time-rcv,"HH:MM"))
    temp-tt.qnty-rcv    = l-qnty-rcv       /* Количество в поставке"                       */
.

end procedure .


procedure max-col :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define output parameter p-max as integer no-undo .
     p-max = 0 .
     for each temp-tt where temp-tt.obj-type = p-obj-type  + " " + string (p-obj-code)
       break by temp-tt.nnn DESCENDING :
       p-max = temp-tt.nnn.
       leave.
     end.
end procedure .

procedure max-col-host :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define output parameter p-max as integer no-undo .
     p-max = 0 .
     for each temp-tt-host where temp-tt-host.obj-type = p-obj-type  + " " + string (p-obj-code)
       break by temp-tt-host.nnn DESCENDING :
       p-max = temp-tt-host.nnn.
       leave.
     end.
end procedure .



procedure new-tmp-page :
 do
 on error undo, return error return-value
 :

    if   num#str#  >= 63000 then do:

        Output stream Macr_Excel  close .
        /*Запишем в файл параметров */
        run paramls-write in this-procedure
           (input "file"
          ,input string (v-ind)
          ,input v-file-name
          ) .
        /* создаем временный файл */
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  Macr_Excel to value (v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
        run proc-print-header-my in this-procedure . /* снова шапку */
    end.

 end. /* do */
end procedure. /* new-tmp-page */

procedure proc-print-header-my :
 do
 on error undo, return error return-value
 :
/* Шапка */
   find first sheetf .
     sheetf.excel-row-heder =  num-entries ( c-str ,{&new-line}) + 1.
     sheetf.excel-row-title =  num-entries ( sheetf.excel-column-lable , {&new-line} ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .

     p-var = num-entries ( entry  (c-c, sheetf.excel-column-lable, {&new-line}) , {&comma-char} ) .

     do c-i = 1 to p-var :
        str--1 = entry ( c-i, entry  (c-c,sheetf.excel-column-lable, {&new-line}) , {&comma-char}) .
        str--2 = integer (entry ( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size  ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.

    c-i = 0.
    end.

    run macr_cell_format  (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        35       , /*p-color-bg  */
        var-1 + 1, /*p-row       */
        1        , /*p-col       */
        num#str# , /*p-row-2     */
        num#col# ) /*p-col-2     */
        .

     define variable t-var as integer no-undo .
     t-var = 2 .
     do c-i = 1 to p-var :
        str--1 = entry ( c-i, entry  (1 , sheetf.excel-column-lable, {&new-line}) , {&comma-char}) no-error   .
        if  str--1   begins " Арт "  then do:
            t-var = t-var + 1.
            if    ( t-var modulo 2 )  <> 0 then do:
              /* выделить темнозеленым нечетные товары */
                put  stream macr_excel unformatted
                      substitute ('select ("r&1c&2:r&3c&4 ")' ,   num#str# - 1 , c-i , num#str# - 1, c-i + 7 ) + {&new-line}  +
                      substitute ('patterns (1,,&1,true)', 50 ) + {&new-line}  .
            end.
        end.
     end.



  put  stream macr_excel unformatted
       substitute ('select ("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + {&new-line}  +
        'BORDER ( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
        'ALIGNMENT (3 , , 4 , 4 ,)'                  + {&new-line}
       .

/* Обьединяем 5 колонок для наимименования */
  var-3 = 4 .
  do while var-3 < p-var  :
        put  stream macr_excel unformatted
             substitute ('select ("r&1c&2:r&3c&4 ")' ,   var-1 + 1,  var-3 , var-1 + 1 , var-3 + 5 ) + {&new-line}  +
             'ALIGNMENT (7 , , 4 , 4 ,)'              + {&new-line}
        .
        var-3 = var-3 + 5 .
   end.


 end. /* do */
end procedure. /* proc-print-header-my */

procedure make-tt-host :

ii = 0 .
l-nn = 0 .
/* товары ------------------------------------------------------------------------------------------------*/
  for   each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,
      first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic
            and bf_ord-cons-gds.prod-type = ub.goods.prod-type
            and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            assign
              l-nn = 0
              l-qnty-of = 0
              l-time-of = 0
            .
       /* заявки -------------------------------------------------------------------------------------*/
        for each  z_ord-doc no-lock  where z_ord-doc.cons-code = bf_ord-cons.cons-code
                                            and z_ord-doc.doc-type = {&o-f}
                                           ,
                each z_ord-line no-lock where z_ord-doc.doc-code   = z_ord-line.doc-code and
                                                z_ord-line.artic     = bf_ord-cons-gds.artic      and
                                                z_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                                z_ord-line.prod-code = bf_ord-cons-gds.prod-code :
                  l-qnty-of = l-qnty-of + z_ord-line.qnty.
        end.
        /* заказ ---------------------------------------------------------------------------------------*/
        assign
        l-cli-code  = ""
        l-cli-name  = ""
        l-ord-code  = ""
        l-qnty-fp = 0
        g-qnty-fp = 0
        .
        for each loc_ord-doc no-lock  where loc_ord-doc.cons-code =  bf_ord-cons.cons-code
                                        and loc_ord-doc.doc-type = {&f-p}
                                  ,
                    first b_clients  where b_clients.obj-code =  loc_ord-doc.cli-code
                                      and  b_clients.obj-type =  loc_ord-doc.cli-type no-lock ,
                    each loc_ord-line no-lock where loc_ord-doc.doc-code   = loc_ord-line.doc-code and
                                        loc_ord-line.artic     = bf_ord-cons-gds.artic      and
                                        loc_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                        loc_ord-line.prod-code = bf_ord-cons-gds.prod-code
                      break by  b_clients.obj-type by  b_clients.obj-code  :

            l-qnty-fp = l-qnty-fp + loc_ord-line.qnty.
            if first-of  ( b_clients.obj-code ) then do:
            l-cli-code  =  b_clients.obj-type + " "  + string ( b_clients.obj-code).
            l-cli-name  =  b_clients.obj-name.
            l-qnty-rcv = 0 .

            /* Поставка ----------------------------------------------------------------------*/
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code
                                                    and loc_ord-doc-rcv.cli-code   = b_clients.obj-code
                                                    and loc_ord-doc-rcv.cli-type   = b_clients.obj-type   ,

                      each loc_ord-line-rcv no-lock where loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :
                            l-qnty-rcv = l-qnty-rcv  +  loc_ord-line-rcv.qnty.

                end.
            run create-tt-line-host .
            assign
              l-rcv-code = ""
              l-time-rcv = 0
              l-qnty-rcv = 0
              l-qnty-fp = 0
            .

            end.  /*1 заказа*/
        end. /* заказы */
    end. /* товары */
end procedure .


procedure create-tt-line-host :

ii = ii + 1.
{ rep/repfrm.i disp ii  reportname ub.clients.obj-name ub.goods.gds-name}
 l-nn = l-nn + 1 .

create temp-tt-host .
assign
    temp-tt-host.nnn         = l-nn             /* N строки */
    temp-tt-host.obj-type    = {&cmp} + " " + string ( v-cntxt-host-code-obj )
    temp-tt-host.obj-name    = v-cntxt-host-name-obj
    temp-tt-host.gds-code    = ub.goods.gds-code
    temp-tt-host.qnty-of     = l-qnty-of        /* Заявленное количество"*/
    temp-tt-host.qnty-fp     = l-qnty-fp        /* Заказанное у поставщика кол-во"              */
    temp-tt-host.cli-cod     = l-cli-code
    temp-tt-host.cli-name    = l-cli-name       /* Наименование поставщика "                    */
    temp-tt-host.ord-code    = l-ord-code       /* ЗАКАЗЫ                                       */
    temp-tt-host.rcv-code    = l-rcv-code       /* ПОСТАВКА                                     */
    temp-tt-host.qnty-rcv    = l-qnty-rcv       /* Количество в поставке"                       */
    .

end procedure .
{ rep/r-libmcr.i macr_excel         }
/* $Workfile: r-cons2.p $ e n d */