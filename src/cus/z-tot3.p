block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: z-tot3.p $
$Archive: cus/z-tot3.p $

Вывод поставки в EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 04/09/03 4:10

*/
define input parameter parParentProc  as widget-handle no-undo .
define input parameter p-rcv-doc as character no-undo .
define input parameter p-ord-doc as character no-undo .



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-tot3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/z-tot3.p $":U .
define variable vss-description as character no-undo init " Вывод поставки в EXCEL ".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i new  }
{ cmp/r-pril.i  NEW  }
{ gbl/cur-time.i     }
{ rep/repfrm.i def   }
{ rep/f-fdec.i       }
{ gbl/paramls.i      }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable g#log as logical   no-undo .

define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }



define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.

define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .

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
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define variable var-3 as integer no-undo .


define variable is-l as integer no-undo .

FUNCTION excel-qnty-null RETURNS char (INPUT p-dec as decimal ).
if p-dec = 0 then Return ("").
   else RETURN(format-excel-text(excel-format-dec-to-char(Round(p-dec,3)))) .
END FUNCTION.



main-block :
do on error undo main-block, return error
:

p-file-name =  string( session:temp-directory + {&df_name} + string( g#report-num ) + ".txt" ) .
output stream outstream to value( string( session:temp-directory + {&df_name} + string( g#report-num ) ) )      .
output stream outstream2 to value(p-file-name).

/* создаем временный файл */
run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
output stream macr_excel to value(v-file-name)   .


v-ind = 1    .
num#str# = 1 .
num#col# = 1 .

{ rep/repfrm.i on 50 }
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }

find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = p-rcv-doc and
                                         buf_ord-doc-rcv.doc-code = p-ord-doc no-error .
if error-status :error then return error .

/*ШАПКА*/
reportname =  "Поставка " + p-rcv-doc +
               " от " +
               string( buf_ord-doc-rcv.doc-date,"99/99/9999")
              .
reportheader =   cur-time-print() .
      run macr_excel_char_with_format in this-procedure ( reportname , num#str# , num#col#  ).
      run macr_cell_format in this-procedure
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */


define variable p-name as character no-undo .
define buffer post-clients for ub.clients.
define buffer sh-clients for ub.clients.
find first sh-clients no-lock where
           sh-clients.obj-type =   buf_ord-doc-rcv.obj-type and
           sh-clients.obj-code =   buf_ord-doc-rcv.obj-code no-error  .
           if error-status :error then next.
find first post-clients no-lock where
           post-clients.obj-type =   buf_ord-doc-rcv.cli-type and
           post-clients.obj-code =   buf_ord-doc-rcv.cli-code no-error  .
           if error-status :error then next.

num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Покупатель: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# =  2 .
run macr_excel_char_with_format in this-procedure ( sh-clients.obj-name , num#str# , num#col#  ).


num#str# = num#str# + 1 .
num#col# =  1 .
p-name = "Поставщик: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# =  2 .
run macr_excel_char_with_format in this-procedure ( post-clients.obj-name , num#str# , num#col#  ).


num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Дата печати: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = 2 .
run macr_excel_char_with_format in this-procedure ( string( today ,"99/99/9999") , num#str# , num#col#  ).

num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Планируемая дата поставки: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = 2 .
run macr_excel_char_with_format in this-procedure ( string( buf_ord-doc-rcv.ship-date,"99/99/9999") , num#str# , num#col#  ).
num#col# = 3 .
run macr_excel_char_with_format in this-procedure ( string( buf_ord-doc-rcv.ship-time,"hh:mm") , num#str# , num#col#  ).


      run macr_cell_format in this-procedure
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            1 ,  /*p-row    */
            1 ,  /*p-col    */
            num#str#  ,         /*p-row-2  */
            num#col#          ) . /*p-col-2 */


/* столбики */
num#col# =  0.
num#str# = num#str# + 1 .
num#col# = num#col# + 1 .
p-name = "Артикул" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Тип производител " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Код производител " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Название товара" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Название производителя" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Ед. изм." .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Ед. изм. поставщика" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Количество в ед. изм. поставщика" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Количество" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Цена в базовой валюте" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Цена в валюте поставщика" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Цена в {&abbr_rub}." .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Налог с продаж" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "НДС" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Сумма в базовой валюте" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Сумма в валюте поставщика" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Сумма в {&abbr_rub}." .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Сумма Налог с продаж" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Сумма НДС" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = num#col# + 1 .
p-name = "Название группы товаров" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

    run macr_cell_format in this-procedure (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        35       , /*p-color-bg  */
        num#str# , /*p-row       */
        1        , /*p-col       */
        num#str# , /*p-row-2     */
        num#col# ) /*p-col-2     */
        .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str#  , 1 , num#str# ,  num#col# ) + {&new-line}  +
        'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .


num#col# =  0.

/* по строкам */
for each  buf_ord-line-rcv no-lock where  buf_ord-line-rcv.rcv-code = buf_ord-doc-rcv.rcv-code and
                                  buf_ord-line-rcv.doc-code = buf_ord-doc-rcv.doc-code break by buf_ord-line-rcv.line-num  :
find first ub.goods no-lock where
      ub.goods.artic     = buf_ord-line-rcv.artic     and
      ub.goods.prod-type = buf_ord-line-rcv.prod-type and
      ub.goods.prod-code = buf_ord-line-rcv.prod-code no-error .
      if error-status :error then next.
find first ub.clients no-lock where
      ub.goods.prod-type = ub.clients.obj-type and
      ub.goods.prod-code = ub.clients.obj-code no-error .

num#col# = 1 .
num#str# = num#str# + 1 .
run macr_excel_char_with_format in this-procedure ( buf_ord-line-rcv.artic , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ( buf_ord-line-rcv.prod-type , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ( buf_ord-line-rcv.prod-code , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ( ub.goods.gds-name , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ( ub.clients.obj-name , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ( ub.goods.unit-base  , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ( buf_ord-line-rcv.unit-cli   , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure              ( buf_ord-line-rcv.cli-qnty   , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.qnty       , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.price-base , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.price-cli  , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.price-rubl , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.SLT-pc     , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.VAT-pc     , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.sum-base   , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.sum-cli    , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.sum-rubl   , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.sum-SLT    , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( buf_ord-line-rcv.sum-VAT    , num#str# , num#col#  ). num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ( ub.goods.grp-name , num#str# , num#col#  ). num#col# = num#col# + 1 .

end.
/* run new-tmp-page . */


run cur-time in this-procedure ( output v-today, output v-time ).
    num#str# = num#str# + 1.
    num#col# =  1.
run macr_excel_char in this-procedure (  " Печать закончена : " + string(v-time,"HH:MM:SS"), num#str# , num#col#     )   .



  Output stream OutStream   close .
  Output stream Macr_Excel  close .
  { rep/repfrm.i off}
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,4,5,6,7,20"
        ) .

 run end-proc in this-procedure  .
 run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
 end.  /* main */

/*-----------------------------------------------------------------------------------------------------------------------*/



procedure new-tmp-page :
 do
 on error undo, return error return-value
 :

    if   num#str#  >= 63000 then do:

        Output stream Macr_Excel  close .
        /*Запишем в файл параметров */
        run paramls-write in this-procedure
          (input "file"
          ,input string(v-ind)
          ,input v-file-name
          ) .
        /* создаем временный файл */
        run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
        output stream  Macr_Excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
        run proc-print-header in this-procedure . /* снова шапку */
    end.

 end. /* do */
end procedure. /* new-tmp-page */

{ rep/r-libmcr.i macr_excel         }
/* $Workfile: z-tot3.p $ e n d */