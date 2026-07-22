block-level on error undo, throw.
/*

$Revision: e47eaee10c88, 211, rls $
$Author: SShalanin $
$Date: Tue Jun 30 11:11:56 2015 +0400 $
$Workfile: z-tott.p $
$Archive: cus/z-tott.p $

Вывод заказа в EXCEL и отправка по e-mail

Автор: Шаланин Сергей 
Дата создания: 02/03/2015
Author: Shalanin Sergey
Creation date: 02/03/2015


Creation date: 07/02/03 4:47

*/
define input  parameter parParentProc  as widget-handle no-undo .
define input  parameter p-ord-doc      as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-file-excel as char no-undo.
define variable vss-revision    as character no-undo init "$Revision: e47eaee10c88, 211, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 30 11:11:56 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-tott.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/z-tott.p $":U .
define variable vss-description as character no-undo init "Вывод заказа в EXCEL и отправка на e-mail".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }
{ cmp/r-pril.i  new }
{ gbl/cur-time.i    }
{ rep/repfrm.i def  }
{ rep/f-fdec.i      }
{ gbl/paramls.i     }
{ cus/df-zakaz.i    }
{ gbl/dtm.i         }
{ cmp/library.i     }
{ gbl/clntattr.i    }

{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable g#log as logical   no-undo .
define variable p-subject-text as character no-undo.
define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i p-obj-type p-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }


find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

run get-report-num in parParentProc ( output g#report-num ).


define buffer buf_ord-doc  for ord-doc.
define buffer buf_ord-line for ord-line.
define buffer buf_cli-gds for cli-gds.

define variable v-grop-max-stock as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-obj-AssMin as logical   no-undo .
define variable v-obj-igt     as character no-undo .

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

define variable  p-cli-type like ord-doc.cli-type no-undo .
define variable  p-cli-code like ord-doc.cli-code no-undo .
define variable  p-doc-type as character no-undo .
define variable  p-doc-date as date no-undo .
define variable  p-ship-date like ord-doc.ship-date no-undo .
define variable  p-ship-time like ord-doc.ship-time no-undo .
define variable  p-host-code like ord-doc.host-code no-undo .

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

find first buf_ord-doc no-lock where  buf_ord-doc.doc-code = p-ord-doc no-error .
if error-status :error then do:
  assign
    p-cli-type  = loc-cli-type
    p-cli-code  = loc-cli-code
    p-doc-type  = loc-doc-type
    p-doc-date  = doc-date
    p-ship-date = loc-date-ship
    p-host-code = v-cntxt-host-code-obj
    /* p-ship-time =  ( integer (entry(1,string(loc-time-ship,"hh:mm"),":"))   * 3600 ) +
                   ( integer (entry(2,string(loc-time-ship,"hh:mm"),":"))   * 60 ) */
    .

end.
else do:
  assign
    p-cli-type = buf_ord-doc.cli-type
    p-cli-code = buf_ord-doc.cli-code
    p-doc-type = buf_ord-doc.doc-type
    p-doc-date = buf_ord-doc.doc-date
    p-ship-date = loc-date-ship
    p-ship-time = buf_ord-doc.ship-time
    p-host-code = buf_ord-doc.host-code
    .
    if p-cli-type = ? or p-cli-code = ? then do:
        assign
        p-cli-type  =  loc-cli-type
        p-cli-code  =  loc-cli-code
        .
    end.
end.

    /*define variable v-rez as logical   no-undo .*/

    /*run ver-edi in this-procedure ( buffer buf_ord-doc*/
    /*                                ,output v-rez*/
    /*).*/
    /*if v-rez = false then return .*/





    /* создаем временный файл */
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .

    v-ind = 1    .
    num#str# = 1 .
    num#col# = 1 .

{ rep/repfrm.i on 50 }
{ gbl/curobjdt.i p-obj-type p-obj-code to-day }
    define variable p-name as character no-undo .
    define buffer post-clients for clients.
    define buffer sh-clients   for clients.
    define buffer buf_firm     for firm.
    define buffer buf_shop     for shop.
    define buffer buf_store    for store.
    define variable p_v         as integer.
    define variable p_body_name as character.
    
    
    find first sh-clients no-lock where
        sh-clients.obj-type =   p-obj-type and
        sh-clients.obj-code =   p-obj-code no-error  .
    if error-status :error then next.
    
    

    find first post-clients no-lock where
        post-clients.obj-type =   p-cli-type and
        post-clients.obj-code =   p-cli-code no-error  .
    if error-status :error then next.
   
    find first buf_firm no-lock where
        buf_firm.firm-code = p-cli-code no-error.
    if error-status :error then next.

    
    
    /*ШАПКА*/
    reportname =  ( if p-doc-type = {&o-f} then "Заявка " else  "Заказ " )
        + p-ord-doc +
        " от " +
        string( p-doc-date,"99/99/9999")
        .
 
    
    if sh-clients.obj-type = {&stock} then 
    do:     
        find first buf_store no-lock where 
            buf_store.obj-code = sh-clients.obj-code no-error.
        p_body_name = (reportname + " " + buf_store.addres1).
    end.
    
    if sh-clients.obj-type = {&shop} then 
    do:
        find first buf_shop no-lock where
            buf_shop.obj-code = sh-clients.obj-code no-error.
        p_body_name = (reportname + " " + buf_shop.addres1).
    end.
    
    num#col# = 0 .
    num#str# = 0 .
    num#col# = 1 .
    num#str# = num#str# + 1 .

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
        
        
        
    p-subject-text = (reportname + " " + v-cntxt-host-name-obj ).




    run make-str-1 in this-procedure .
    Output stream Macr_Excel  close .
    /*Запишем в файл параметров 1*/

    run paramls-write in this-procedure
        (input "file"
        ,input "Результат"
        ,input v-file-name
        ) .
    run mf in this-procedure .
    run end-proc in this-procedure  .
    run rep/mcr-exl.p  ( v-file-name, output p-file-excel). 
 
  
    if buf_firm.e-mail = '' then do: message substitute("В карточке клиента не указан адрес электронной почты, нельзя отправить сообщение!")
    view-as alert-box error.
    return error.
    end.
    else do:
    run gbl/sendmail.p (  buf_firm.e-mail , p-subject-text , p_body_name , p-file-excel) no-error.
     end.

end.  /* main */
 
 { rep/r-libmcr.i macr_excel         }
 
procedure make-str-1 :
    do
        on error undo, return error return-value
        :
/* по строкам */


num#col# = 0 .
 num#str# = 0 .
 num#col# = 1 .
 num#str# = num#str# + 1 .

 run macr_excel_char_with_format in this-procedure ( reportname , num#str# , num#col#  ).
 run macr_cell_format in this-procedure
          ( 12    ,       /* p-size   */
            true  ,       /* p-bold   */
            false ,       /* p-italic */
            ?     ,       /* p-color  */
            num#str# ,    /* p-row    */
            num#col# ,    /* p-col    */
            ? ,           /* p-row-2  */
            ?         ) . /* p-col-2  */

reportheader =   cur-time-print() .


num#col# = num#col# + 1 .
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
p-name = "Планируемая дата доставки: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = 2 .
run macr_excel_char_with_format in this-procedure ( string( p-ship-date,"99/99/9999") , num#str# , num#col#  ).
num#col# = 3 .
run macr_excel_char_with_format in this-procedure ( string( p-ship-time,"hh:mm") , num#str# , num#col#  ).


/* столбики */
 run macr_cell_format in this-procedure  (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        36      , /*p-color-bg  */
        6        , /*p-row       */
        1        , /*p-col       */
        6        , /*p-row-2     */
       ( if p-doc-type <> {&o-f} then 24    else 17 )
         )       /*p-col-2     */
        .

num#col# =  0 .
num#str# = num#str# + 1 .
num#col# = num#col# + 1 .            
            
            
p-name = "Артикул" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
put  stream macr_excel unformatted  'COLUMN.WIDTH(17,,,,)'  skip.

num#col# = num#col# + 1 .
p-name = "Тип производителя " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
put  stream macr_excel unformatted  'COLUMN.WIDTH(13,,,,)'  skip.
num#col# = num#col# + 1 .
p-name = "Код производителя " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
put  stream macr_excel unformatted  'COLUMN.WIDTH(13,,,,)'  skip.
num#col# = num#col# + 1 .
p-name = "Название товара" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
put  stream macr_excel unformatted  'COLUMN.WIDTH(50,,,,)'  skip.

num#col# = num#col# + 1 .
p-name = "Артикул поставщика" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
put  stream macr_excel unformatted  'COLUMN.WIDTH(13,,,,)'  skip.

num#col# = num#col# + 1 .
p-name = "Цена в валюте поставщика на баз.ед.изм." .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
put  stream macr_excel unformatted  'COLUMN.WIDTH(13,,,,)'  skip.
num#col# = num#col# + 1 .
p-name = "Количество в баз.ед.изм" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
put  stream macr_excel unformatted  'COLUMN.WIDTH(13,,,,)'  skip.




put  stream macr_excel unformatted  'COLUMN.WIDTH(15,,,,)'  skip.

  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , 6  , 1 , num#str# ,  num#col# ) + {&new-line}  +
        'BORDER( 2 , 2 , 2 , 2 , 8 , ) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .

num#col# =  0.

for each  buf_ord-line no-lock where  buf_ord-line.doc-code = p-ord-doc break by buf_ord-line.line-num  :
    find first goods no-lock where
          goods.artic     = buf_ord-line.artic     and
          goods.prod-type = buf_ord-line.prod-type and
          goods.prod-code = buf_ord-line.prod-code no-error .
          if error-status :error then next.
    find first clients no-lock where
          goods.prod-type = clients.obj-type and
          goods.prod-code = clients.obj-code no-error .
          if error-status :error then next.
    num#col# = 1 .
    num#str# = num#str# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.artic , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.prod-type , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.prod-code , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( goods.gds-name , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( (if buf_ord-line.cli-art <> ? then buf_ord-line.cli-art  else "") , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure ( determined ( buf_ord-line.price-cli / buf_ord-line.cli-base-rate) , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure ( buf_ord-line.qnty       , num#str# , num#col#  ). num#col# = num#col# + 1 .

end.


 end. /* do */
end procedure. /* make-str */

procedure mf :
 do
 on error undo, return error return-value
 :
    /* создаем временный файл  */
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream  Macr_Excel to value(v-file-name) .
    v-ind = v-ind + 1 .
    num#str# = 0 .


 end. /* do */
end procedure. /* mf */

procedure ver-edi :
define parameter buffer buf_ord-doc for ub.ord-doc.
define output parameter p-res as logical no-undo .
/*почему-то запрещен*/
p-res = (buf_ord-doc.whole-send-news <> integer({&doc-dm-edi})).
if not p-res then do:
message "Экспорт заказа запрещен!"
  view-as alert-box warning .
end.
end procedure.