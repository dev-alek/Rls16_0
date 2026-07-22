block-level on error undo, throw.
/*

$Revision: 2a79bf27b012, 291, rls $
$Author: ASMorozov $
$Date: Tue Dec 01 19:11:26 2015 +0300 $
$Workfile: z-tot6.p $
$Archive: cus/z-tot6.p $

Печать потребности товаров

Автор: Комаров Иван Сергеевич
Дата создания: 07/23/10
Author: Ivan Komarov
Creation date: 07/23/10

Автор1: Чернова Светлана Александровна
Дата создания1: 03/17/04

*/
define variable vss-revision    as character no-undo init "$Revision: 2a79bf27b012, 291, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:26 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-tot6.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/z-tot6.p $":U .
define variable vss-description as character no-undo init "Печать потребности товаров".

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i      }
{ cus/df-zakaz.i     }
{ cmp/r-pril.i   NEW }
{ gbl/cur-time.i     }
{ rep/repfrm.i   def }
{ rep/f-fdec.i       }
{ gbl/paramls.i      }
{ cus/df-ex-za.i     }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/usr-flt.i      }
{ cus/ord-outp.i def }

define input parameter parParentProc as widget-handle no-undo .
define input parameter TABLE FOR export-ras .
define input parameter TABLE FOR tmp#zakaz-prn .
define input parameter g#type as character no-undo .

{ gbl/getcntxt.i get }
{ str/getctxtp.i get }

define temp-table tt-table no-undo
    FIELD id AS INTEGER
    FIELD new-id AS INTEGER
    INDEX p1 IS PRIMARY id
    .
function new-n returns integer
 ( input num as integer ) :
 find first tt-table where
            tt-table.id = num no-error .
if error-status :error then return num.
else return tt-table.new-id .

end function.


define variable base-type    as character no-undo .
define variable base-code    as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl   as logical   no-undo .
define variable g#log        as logical   no-undo .

define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency .
define buffer bufo_clients     for ub.clients  .

{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }

find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

run get-report-num in parParentProc ( output g#report-num ).

define variable t-ret as logical no-undo .
define variable salecode like ub.sysconf.sale-code no-undo .
define variable saletype like ub.sysconf.sale-type no-undo .
t-ret =  session:SET-WAIT-STATE("GENERAL") .

Find first ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock no-error.
assign
  salecode = ub.sysconf.sale-code
  saletype = ub.sysconf.sale-type
.

define variable p-ord-doc as character no-undo .
define buffer   buf_cli-gds  for ub.cli-gds.
define variable max-col as integer no-undo .
define variable dr-col as integer no-undo .

assign
  make-excel-com = false
  make-excel     = true
  max-col  = 34
  dr-col   = 26 /* от сюда начинается колонки по поставщикам */
.

define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define variable kol-obj as integer   no-undo .
/* Нужные колонки для засоски*/
define variable col-gds-code     as integer   no-undo .
define variable col-typecode-obj as integer   no-undo .
define variable col-zakz-qnty    as integer   no-undo .
define variable col-price        as integer   no-undo .
define variable col-cli-type     as integer   no-undo .
define variable col-cli-code     as integer   no-undo .
define variable col-cli-art      as integer   no-undo .
define variable col-choice       as integer   no-undo .
/*Колонки для печати*/
define variable print-col-1      as logical   no-undo .
define variable print-col-2      as logical   no-undo .
define variable print-col-3      as logical   no-undo .
define variable print-col-4      as logical   no-undo .
define variable print-col-5      as logical   no-undo .
define variable print-col-6      as logical   no-undo .
define variable print-col-7      as logical   no-undo .
define variable print-col-8      as logical   no-undo .
define variable print-col-9      as logical   no-undo .
define variable print-col-10     as logical   no-undo .
define variable print-col-11     as logical   no-undo .
define variable print-col-12     as logical   no-undo .
define variable print-col-13     as logical   no-undo .
define variable print-col-14     as logical   no-undo .
define variable print-col-15     as logical   no-undo .
define variable print-col-16     as logical   no-undo .
define variable print-col-17     as logical   no-undo .
define variable print-col-18     as logical   no-undo .
define variable print-col-19     as logical   no-undo .
define variable print-col-20     as logical   no-undo .
define variable print-col-21     as logical   no-undo .
define variable print-col-22     as logical   no-undo .
define variable print-col-23     as logical   no-undo .
define variable print-col-24     as logical   no-undo .
define variable print-col-25     as logical   no-undo .
define variable print-col-26     as logical   no-undo .
define variable print-col-27     as logical   no-undo .
define variable print-col-28     as logical   no-undo .
define variable print-col-29     as logical   no-undo .
define variable print-col-30     as logical   no-undo .
define variable print-col-31     as logical   no-undo .
define variable print-col-32     as logical   no-undo .
define variable print-col-33     as logical   no-undo .
define variable print-col-34     as logical   no-undo .
define variable v-stroka         as integer   no-undo .
define variable v-first-column   as integer   no-undo .

define stream  instream   .
define stream  outstream  .
define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable C-c         as integer   no-undo .
define variable C-str       as character no-undo .
define variable str--1      as character Format "x(60)" no-undo.
define variable str--2      as integer   no-undo .
define variable C-i         as integer   no-undo .
define variable p-var       as integer   no-undo .
define variable num#col#    as integer   no-undo .
define variable var-1       as integer   no-undo .
define variable var-2       as integer   no-undo .
define variable var-3       as integer   no-undo .

define variable  p-obj-type  like ub.ord-doc.obj-type  no-undo .
define variable  p-obj-code  like ub.ord-doc.obj-code  no-undo .
define variable  p-cli-type  like ub.ord-doc.cli-type  no-undo .
define variable  p-cli-code  like ub.ord-doc.cli-code  no-undo .
define variable  p-ship-date like ub.ord-doc.ship-date no-undo .
define variable  p-ship-time like ub.ord-doc.ship-time no-undo .
define variable  p-host-code like ub.ord-doc.host-code no-undo .
define variable  p-doc-type  as character              no-undo .
define variable  p-doc-date  as date                   no-undo .

define variable is-l          as integer   no-undo .
define variable i             as integer   no-undo .
define variable R-algoritm    as integer   no-undo .
define variable R-min-rest    as integer   no-undo .
define variable date-p-1      as date      no-undo .
define variable date-p-2      as date      no-undo .
define variable R-algoritm2   as integer   no-undo .
define variable R-min-rest3   as logical   no-undo .
define variable p-code        like ub.tmp-sale.tmp-code no-undo .
define variable t-rv          as logical   no-undo .
define variable t-rvz         as logical   no-undo .
define variable t-rvc         as logical   no-undo .
define variable t-rvzc        as logical   no-undo .
define variable t-sp          as logical   no-undo .
define variable t-sppv        as logical   no-undo .
define variable t-sppv-2      as logical   no-undo .
define variable t-sppv-3      as logical   no-undo .
define variable t-sppv-4      as logical   no-undo .
define variable t-way         as logical   no-undo .
define variable t-rcv         as logical   no-undo .
define variable t-clos        as logical   no-undo .
define variable p-neg-sale    as logical   no-undo .
define variable t-gar         as logical   no-undo .
define variable t-min-zapas   as logical   no-undo .
define variable p-val         as character no-undo .
define variable p-val-col     as character no-undo .
define variable p-val-rad     as logical   no-undo .
define variable p-val-gds-obj as logical   no-undo initial yes.
define variable p-det-post    as logical   no-undo .
define variable p-only-am     as logical   no-undo .
define variable v-ok          as logical   no-undo .
define variable v-mess        as character no-undo .
define variable tog-det-prizn as logical   no-undo .

define variable SelectObject as character no-undo .

function excel-qnty-null returns char (input p-dec as decimal ).
if p-dec = 0 then return ("").
   else return (format-excel-text(excel-format-dec-to-char(round(p-dec,3)))) .
end function.

main-block :
do on error undo main-block, return error
:

run init-screen in this-procedure .

{ cmp/open-out.i stream OutStream  " " ReportPageHeight }
assign
  v-ind = 1
  num#str# = 1
  num#col# = 1
.

{ rep/repfrm.i on 50 }
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }
assign
  loc-store-type = v-cntxt-obj-type
  loc-store-code = v-cntxt-obj-code
  p-obj-type  = loc-store-type
  p-obj-code  = loc-store-code
  p-cli-type  = loc-cli-type
  p-cli-code  = loc-cli-code
  p-doc-type  = loc-doc-type
  p-doc-date  = doc-date
  p-ship-date = loc-date-ship
  p-host-code = v-cntxt-host-code-obj
.

define variable p-name as character no-undo .
  run mf in this-procedure .
  run make-str-2 in this-procedure .
  /* Запишем в файл параметров */
  run paramls-write in this-procedure
      ( input "file"
      , input "Страница Параметры расчета"
      , input v-file-name
      ) .
    Output stream Macr_Excel  close .

    run mf in this-procedure .

    run make-str-1 in this-procedure .
    /* Запишем в файл параметров 1*/
    run paramls-write in this-procedure
      ( input "file"
      , input "РЕЗУЛЬТАТ"
      , input v-file-name
      ) .

    Output stream Macr_Excel  close .
    Output stream OutStream   close .

   { rep/repfrm.i off }

    /*Запишем в файл параметров */

    run paramls-write in this-procedure
    ( input "charcol"
    , input ""
    , input substitute("&1,&2,&3,&4,&5,&6,&7,&8",
      new-n(2) ,
      new-n(4) ,
      new-n(5) ,
      new-n(6) ,
      new-n(7) ,
      new-n(8) ,
      new-n(9) ,
      new-n(26)
      )
    ) .  /*"2,4,5,6,7,8,9,26" - эти столбцы должны быть текстовыми для названий, артикулов и т.д.*/

 run end-proc in this-procedure .
 run rep/runexcel.p ( string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").

 end.  /* main */

/*-----------------------------------------------------------------------------------------------------------------------*/
{ rep/r-libmcr.i macr_excel         }

procedure make-str-1 :
 do
 on error undo, return error return-value
 :
define variable loc-sum-min1 as character no-undo .
define variable loc-sum-min2 as character no-undo .
define variable loc-sum-min3 as character no-undo .
define variable t-type       as character no-undo .

define variable lp-in-qnty     as decimal no-undo .
define variable lp-out-qnty    as decimal no-undo .
define variable lp-out-sum     as decimal no-undo .
define variable lp-Temp-rash   as decimal no-undo .
define variable lp-min-stock   as decimal no-undo .
define variable lp-qnty-sale   as decimal no-undo .
define variable lp-zero-day    as decimal no-undo .
define variable lp-in-out-qnty as decimal no-undo .
define variable lp-supp-qnty   as decimal no-undo .
define variable lp-qnty-kassa  as decimal no-undo .
define variable lp-qnty-stk    as decimal no-undo .
define variable lp-qnty-prih   as decimal no-undo .
define variable lp-qnty-rash   as decimal no-undo .

/*ШАПКА*/
 reportname =  "Расчет потребности товаров"    .
 run mf in this-procedure .
 num#str#  = 1 .
if NOT p-val-rad then do :
    num#col# = new-n(v-first-column) .
    run macr_excel_char_with_format in this-procedure ( reportname , num#str# , num#col#  ).
    run macr_cell_format in this-procedure
      ( 12    ,       /* p-size */
        true  ,       /* p-bold   */
        false ,       /* p-italic */
        ?     ,       /* p-color  */
        num#str# ,    /* p-row    */
        num#col# ,    /* p-col    */
        ? ,           /* p-row-2  */
        ?         ) . /* p-col-2 */

    reportheader =   cur-time-print() .
    num#str# = num#str# + 1 .

    p-name = "Дата печати: " + string( today ,"99/99/9999") .
    run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
    num#str# = num#str# + 1 .
    p-name = "Планируемая дата доставки: " + string( p-ship-date,"99/99/9999") +
             ". Период продаж с: "         + string( date-sale-1,"99/99/9999") +
                           " по "          + string( date-sale-2,"99/99/9999") .
    run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
end.
else do :
    num#col# = 1 .
    run macr_excel_char_with_format in this-procedure ( reportname , num#str# , num#col#  ).
    run macr_cell_format in this-procedure
      ( 12    ,       /* p-size */
        true  ,       /* p-bold   */
        false ,       /* p-italic */
        ?     ,       /* p-color  */
        num#str# ,    /* p-row    */
        num#col# ,    /* p-col    */
        ? ,           /* p-row-2  */
        ?         ) . /* p-col-2 */

    reportheader =   cur-time-print() .
    num#str# = num#str# + 1 .
    num#col# = 1 .
    p-name = "Дата печати: " .
    run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
    num#col# = 4 .
    run macr_excel_char_with_format in this-procedure ( string( today ,"99/99/9999") , num#str# , num#col#  ).

    num#str# = num#str# + 1 .
    num#col# = 1 .
    p-name = "Планируемая дата доставки: " .
    run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
    num#col# = 4 .
    run macr_excel_char_with_format in this-procedure ( string( p-ship-date,"99/99/9999") , num#str# , num#col#  ).
    num#col# = 5 .
    p-name = "Период продаж с: " .
    run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
    num#col# = 7 .
    run macr_excel_char_with_format in this-procedure ( string( date-sale-1,"99/99/9999") , num#str# , num#col#  ).
    num#col# = 8.
    p-name = "по " .
    run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
    num#col# = 9 .
    run macr_excel_char_with_format in this-procedure ( string( date-sale-2,"99/99/9999") , num#str# , num#col#  ).
end.
/* столбики */
 run macr_cell_format in this-procedure  (
    10       , /*p-size-font */
    true     , /*p-bold      */
    false    , /*p-italic    */
    34       , /*p-color-bg  */
    4        , /*p-row       */
    1        , /*p-col       */
    4        , /*p-row-2     */
    dr-col - 1 )  /*p-col-2     */
    .

 run macr_cell_format  in this-procedure (
    10       , /*p-size-font */
    true     , /*p-bold      */
    false    , /*p-italic    */
    40       , /*p-color-bg  */
    4        , /*p-row       */
    dr-col   , /*p-col       */
    4        , /*p-row-2     */
    max-col )  /*p-col-2     */
    .

num#col# =  0 .
num#str# = num#str# + 1 .
num#col# = num#col# + 1 .
define variable p-fi as character no-undo .
define variable name-tt as character no-undo .

if loc-doc-type = {&f-p} then do:
    p-fi  = " по фирме " .
end.
else do:
   p-fi  = " по объекту " .
end.

case R-algoritm :
  when 2 then do:
      name-tt =  "Темп продаж из списка" .
  end.
  when 4 then do:
      name-tt =  "Максимальная продажа" .
  end.
  otherwise do:
      name-tt =  "Темп продаж с " + String(date-1) + " по " + String(date-2) .
  end.
end case.


num#col# = new-n(1).  run macr_excel_char_with_format in this-procedure ("Код товара"             , num#str# , num#col#  ) .
if not print-col-1 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(2).  run macr_excel_char_with_format in this-procedure ("Артикул"                , num#str# , num#col#  ) .
if not print-col-2 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(3).  run macr_excel_char_with_format in this-procedure ("Название товара"        , num#str# , num#col#  ) .
put  stream macr_excel unformatted  (if print-col-3 then 'COLUMN.WIDTH(30,,,,)' else 'COLUMN.WIDTH(0,,,,)')  skip.
num#col# = new-n(4).  run macr_excel_char_with_format in this-procedure ("Группа"                 , num#str# , num#col#  ) .
put  stream macr_excel unformatted  (if print-col-4 then 'COLUMN.WIDTH(30,,,,)' else 'COLUMN.WIDTH(0,,,,)')  skip.
num#col# = new-n(5).  run macr_excel_char_with_format in this-procedure ("Ед. изм."               , num#str# , num#col#  ) .
put  stream macr_excel unformatted  (if print-col-5 then 'COLUMN.WIDTH(4,,,,)'  else 'COLUMN.WIDTH(0,,,,)')  skip.
num#col# = new-n(6).  run macr_excel_char_with_format in this-procedure ("Код производителя "     , num#str# , num#col#  ).
if not print-col-6 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(7).  run macr_excel_char_with_format in this-procedure ("Название производителя ", num#str# , num#col#  ).
put  stream macr_excel unformatted  (if print-col-7 then 'COLUMN.WIDTH(30,,,,)'  else 'COLUMN.WIDTH(0,,,,)')  skip.
num#col# = new-n(8).  run macr_excel_char_with_format in this-procedure ("Артикул контрагента"    , num#str# , num#col#  ) .
if not print-col-8 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(9).  run macr_excel_char_with_format in this-procedure ("Ед.изм. контрагента"    , num#str# , num#col#  ) .
put  stream macr_excel unformatted  (if print-col-9 then 'COLUMN.WIDTH(5,,,,)'  else 'COLUMN.WIDTH(0,,,,)')  skip.
num#col# = new-n(10).   run macr_excel_char_with_format in this-procedure ("Срок хранения"        , num#str# , num#col#  ) .
if not print-col-10 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(11).  run macr_excel_char_with_format in this-procedure ("Коэффициент пересчета ед.изм." , num#str# , num#col#  ) .
if not print-col-11 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(12).  run macr_excel_char_with_format in this-procedure ("Количество в упаковке" , num#str# , num#col#  ) .
if not print-col-12 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(13).  run macr_excel_char_with_format in this-procedure ( name-tt                , num#str# , num#col#  ) .
if not print-col-13 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(14).  run macr_excel_char_with_format in this-procedure ( if R-algoritm = 2 then "Расход (не рассчитывается)" else "Расход с " + String(date-1) + " по " + String(date-2) , num#str# , num#col#  ) .
if not print-col-14 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(15).  run macr_excel_char_with_format in this-procedure ("Дней без продаж и остатков" , num#str# , num#col#  ) .
if not print-col-15 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(16).  run macr_excel_char_with_format in this-procedure ("Дней в продаже "       , num#str# , num#col#  ).
if not print-col-16 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(17).  run macr_excel_char_with_format in this-procedure ("Остаток на " + String(to-day) , num#str# , num#col#  ) .
if not print-col-17 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(18).  run macr_excel_char_with_format in this-procedure ("Приход "               , num#str# , num#col#  ) .
if not print-col-18 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(32).  run macr_excel_char_with_format in this-procedure ("Название объекта"      , num#str# , num#col#  ) .
if not print-col-32 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
put  stream macr_excel unformatted  (if print-col-32 then 'COLUMN.WIDTH(20,,,,)'  else 'COLUMN.WIDTH(0,,,,)')  skip.
num#col# = new-n(33).  run macr_excel_char_with_format in this-procedure ("Расчет кол-во "        , num#str# , num#col#  ) .
if not print-col-33 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
put  stream macr_excel unformatted  (if print-col-33 then 'COLUMN.WIDTH(7,,,,)'  else 'COLUMN.WIDTH(0,,,,)')  skip.
num#col# = new-n(34).  run macr_excel_char_with_format in this-procedure ("Штрихкод производителя", num#str# , num#col#  ) .
if not print-col-34 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
put  stream macr_excel unformatted  (if print-col-34 then 'COLUMN.WIDTH(20,,,,)'  else 'COLUMN.WIDTH(0,,,,)')  skip.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
if R-min-rest = 1 then do:
    num#col# = new-n(19). run macr_excel_char_with_format in this-procedure ( "Минимальный остаток" , num#str# , num#col# ).
    if not print-col-19 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
    num#col# = new-n(20). run macr_excel_char_with_format in this-procedure ( "Уровень постоянного присутствия", num#str# , num#col# ).
    if not print-col-20 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
    num#col# = new-n(21). run macr_excel_char_with_format in this-procedure ( "Минимальный заказ" , num#str# , num#col# ).
    if not print-col-21 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
end.
else do:
    num#col# = new-n(19). run macr_excel_char_with_format in this-procedure ( "Минимальный остаток на фирме" , num#str# , num#col# ).
    if not print-col-19 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
    num#col# = new-n(20). run macr_excel_char_with_format in this-procedure ( "Уровень постоянного присутствия на фирме", num#str# , num#col# ).
    if not print-col-20 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
    num#col# = new-n(21). run macr_excel_char_with_format in this-procedure ( "Минимальный заказ на фирме" , num#str# , num#col# ).
    if not print-col-21 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
end.
num#col# = new-n(22). run macr_excel_char_with_format in this-procedure ("Код объекта ", num#str# , num#col#  ).
if not print-col-22 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(23). run macr_excel_char_with_format in this-procedure ("Разрешены отриц.остатки ", num#str# , num#col#  ).
if not print-col-23 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(24). run macr_excel_char_with_format in this-procedure ("В пути ", num#str# , num#col#  ).
if not print-col-24 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
num#col# = new-n(25). run macr_excel_char_with_format in this-procedure ("ЗАКАЗ кол-во", num#str# , num#col#  ) .
if not print-col-25 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
/* синий */
put  stream macr_excel unformatted
     substitute('patterns(1,,&1,true)', 42 ) + {&new-line}  .

run head-post in this-procedure .


/* бордюрик */
put  stream macr_excel unformatted
     substitute('select("r&1c&2:r&3c&4 ")' , num#str#   , 1 , num#str# ,  max-col ) + {&new-line}  +
     'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
     'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}     .

    put  stream macr_excel unformatted 'Split(,4)' + {&new-line}     .
    put  stream macr_excel unformatted 'FREEZE.PANES(true,,true)'+ {&new-line}     .

num#col# =  0.

/* по строкам */

define variable l-all-day    as integer no-undo .
define variable iii          as integer no-undo .

define variable s-in-qnty    as decimal no-undo .
define variable s-out-qnty   as decimal no-undo .
define variable s-out-sum    as decimal no-undo .
define variable s-supp-qnty  as decimal no-undo .
define variable ss-in-qnty   as decimal no-undo .
define variable ss-out-qnty  as decimal no-undo .
define variable ss-out-sum   as decimal no-undo .
define variable ss-supp-qnty as decimal no-undo .

define variable s-qnty             as decimal no-undo .
define variable s-sum-rubl         as decimal no-undo .
define variable s-qnty-rashkassa   as decimal no-undo .
define variable s-zero-day         as decimal no-undo .
define variable s-qnty-stk         as decimal no-undo .
define variable s-qnty-prih        as decimal no-undo .
define variable s-qnty-rash        as decimal no-undo .
define variable s-qnty-kassa       as decimal no-undo .
define variable s-min-stock        as decimal no-undo .
define variable s-service-order    as decimal no-undo .
define variable s-min-order        as decimal no-undo .
define variable s-gds-way-all      as decimal no-undo .
define variable s-l-all-day        as decimal no-undo .
define variable ss-qnty            as decimal no-undo .
define variable ss-sum-rubl        as decimal no-undo .
define variable ss-qnty-rashkassa  as decimal no-undo .
define variable ss-zero-day        as decimal no-undo .
define variable ss-qnty-stk        as decimal no-undo .
define variable ss-qnty-prih       as decimal no-undo .
define variable ss-qnty-rash       as decimal no-undo .
define variable ss-qnty-kassa      as decimal no-undo .
define variable ss-min-stock       as decimal no-undo .
define variable ss-service-order   as decimal no-undo .
define variable ss-min-order       as decimal no-undo .
define variable ss-gds-way-all     as decimal no-undo .
define variable ss-l-all-day       as decimal no-undo .

define variable v-b-str            as character no-undo .
define variable v-ok               as logical no-undo .
define variable v-mess             as character no-undo .
define variable v-erase            as logical   no-undo .

define variable prt-name           as character no-undo.

define buffer buf_prod-bc    for ub.prod-bc  .
define buffer buf_bar-code   for ub.bar-code .

if p-only-am then do:
  /*проверка АссМатр и ИЖТ*/
  for each export-ras :
    { gbl/goassizt.i
      G#type
      export-ras.gds-code
      export-ras.obj-type
      export-ras.obj-code
      false
      v-ok
      v-mess
      no-error
    }
    if not v-ok then do:
      run creat-tt (export-ras.gds-code , v-mess ) .
      v-erase = true.
      delete export-ras .
    end.
  end.
end.

if v-erase = true then do:
    run view-exept-gds ( substitute("Не все товары попали в заказ !&1Просмотреть товары, не вошедшие в заказ ?", {&new-line})) .
end.

if p-val-gds-obj then do:
    for each  export-ras ,
        first ub.goods no-lock where
                   ub.goods.artic     = export-ras.artic     and
                   ub.goods.prod-type = export-ras.prod-type and
                   ub.goods.prod-code = export-ras.prod-code
                break
                  by ( if x-tog-grp   then ub.goods.grp-name else "" )
                  by ( if x-tog-artic then export-ras.artic  else ub.goods.gds-name )
                  by export-ras.gds-code
                  :

        find first ub.clients no-lock where
              ub.clients.obj-type = ub.goods.prod-type and
              ub.clients.obj-code = ub.goods.prod-code
              no-error .
              if error-status :error then next.

        assign
          num#col# = 1
          num#str# = num#str# + 1
        .
        /* === */
        if first-of(export-ras.gds-code) then do:
          assign
              s-in-qnty    = 0
              s-out-qnty   = 0
              s-out-sum    = 0
              s-supp-qnty  = 0
              s-qnty          = 0
              s-sum-rubl      = 0
              s-qnty-rashkassa= 0
              s-zero-day      = 0
              s-qnty-stk      = 0
              s-qnty-prih     = 0
              s-qnty-rash     = 0
              s-qnty-kassa    = 0
              s-min-stock     = 0
              s-service-order = 0
              s-min-order     = 0
              s-gds-way-all   = 0
              s-l-all-day     = 0
            .
            num#col# = new-n(1).  run macr_excel_char_with_format in this-procedure ( export-ras.gds-code , num#str# , num#col#  ).
            num#col# = new-n(2).  run macr_excel_char_with_format in this-procedure ( export-ras.artic    , num#str# , num#col#  ).
            num#col# = new-n(3).  run macr_excel_char_with_format in this-procedure ( ub.goods.gds-name   , num#str# , num#col#  ).
            num#col# = new-n(4).  run macr_excel_char_with_format in this-procedure ( ub.goods.grp-name   , num#str# , num#col#  ).
            num#col# = new-n(5).  run macr_excel_char_with_format in this-procedure ( ub.goods.unit-base  , num#str# , num#col#  ).
            num#col# = new-n(6).  run macr_excel_char_with_format in this-procedure ( export-ras.prod-type + " " + string(export-ras.prod-code) , num#str# , num#col#  ).
            num#col# = new-n(7).  run macr_excel_char_with_format in this-procedure ( ub.clients.obj-name , num#str# , num#col#  ).
            num#col# = new-n(8).  run macr_excel_char_with_format in this-procedure ( export-ras.cli-art  , num#str# , num#col#  ).
            num#col# = new-n(9).  run macr_excel_char_with_format in this-procedure ( export-ras.unit-cli , num#str# , num#col#  ).
            num#col# = new-n(10). run macr_excel_dec in this-procedure (  ub.goods.deadline               , num#str# , num#col#  ).
            num#col# = new-n(11). run macr_excel_dec in this-procedure (  export-ras.cli-base-rate        , num#str# , num#col#  ).
            num#col# = new-n(12). run macr_excel_dec in this-procedure (  ub.goods.qnty-cart              , num#str# , num#col#  ).
        end.

        num#col# = new-n(13). run macr_excel_dec in this-procedure (  export-ras.Temp-rash  , num#str# , num#col#  ).
        num#col# = new-n(14). run macr_excel_dec in this-procedure (  (export-ras.qnty-rash + export-ras.qnty-kassa) , num#str# , num#col#  ).
        num#col# = new-n(15). run macr_excel_dec in this-procedure (  export-ras.zero-day   , num#str# , num#col#  ).

        l-all-day =  export-ras.all-day  .   if l-all-day = ? then l-all-day = 0 .

        find first bufo_clients no-lock
             where bufo_clients.obj-type = export-ras.obj-type
               and bufo_clients.obj-code = export-ras.obj-code
            no-error .

        num#col# = new-n(16). run macr_excel_dec in this-procedure ( l-all-day , num#str# , num#col# ).
        num#col# = new-n(17). run macr_excel_dec in this-procedure ( export-ras.qnty-stk , num#str# , num#col# ).
        num#col# = new-n(18). run macr_excel_dec in this-procedure ( export-ras.qnty-prih , num#str# , num#col# ).
        num#col# = new-n(19). run macr_excel_dec in this-procedure ( export-ras.min-stock , num#str# , num#col# ).
        num#col# = new-n(20). run macr_excel_dec in this-procedure ( export-ras.service-order , num#str# , num#col# ).
        num#col# = new-n(21). run macr_excel_dec in this-procedure ( export-ras.min-order , num#str# , num#col# ).
        num#col# = new-n(22). run macr_excel_char_with_format in this-procedure ( export-ras.obj-type + " " + string(export-ras.obj-code) , num#str# , num#col#  ).
        num#col# = new-n(32). run macr_excel_char_with_format in this-procedure ( bufo_clients.obj-name , num#str# , num#col# ).
        num#col# = new-n(23). run macr_excel_char_with_format in this-procedure ( export-ras.negative-rest , num#str# , num#col# ).
        num#col# = new-n(24). run macr_excel_dec in this-procedure ( export-ras.gds-way-all , num#str# , num#col# ).
        num#col# = new-n(25). run macr_excel_dec in this-procedure ( export-ras.qnty , num#str# , num#col# ).
        num#col# = new-n(33). run macr_excel_dec in this-procedure ( export-ras.order-qnty , num#str# , num#col# ).
        assign v-b-str = "".
        for each buf_bar-code no-lock
        where buf_bar-code.gds-code = export-ras.gds-code
        :
          for each buf_prod-bc no-lock
            where buf_prod-bc.b-code = buf_bar-code.b-code
              :
              if available buf_prod-bc then do:
                if v-b-str = "" then do:
                    assign v-b-str = buf_prod-bc.b-str .
                end.
                else do:
                    assign v-b-str = v-b-str + "," + buf_prod-bc.b-str .
                end.
              end.
          end.
        end.
        num#col# = new-n(34). run macr_excel_char_with_format in this-procedure ( v-b-str , num#str# , num#col#  ).


        assign
        s-qnty            =  s-qnty            +  export-ras.qnty
        s-sum-rubl        =  s-sum-rubl        +  export-ras.sum-rubl
        s-qnty-rashkassa  =  s-qnty-rashkassa  + (export-ras.qnty-rash + export-ras.qnty-kassa)
        s-zero-day        =  s-zero-day        +  export-ras.zero-day
        s-qnty-stk        =  s-qnty-stk        +  export-ras.qnty-stk
        s-qnty-prih       =  s-qnty-prih       +  export-ras.qnty-prih
        s-qnty-rash       =  s-qnty-rash       +  export-ras.qnty-rash
        s-qnty-kassa      =  s-qnty-kassa      +  export-ras.qnty-kassa
        s-min-stock       = (if R-min-rest = 2 then 0 else s-min-stock     ) + export-ras.min-stock
        s-service-order   = (if R-min-rest = 2 then 0 else s-service-order ) + export-ras.service-order
        s-min-order       = (if R-min-rest = 2 then 0 else s-min-order     ) + export-ras.min-order
        s-gds-way-all     =  s-gds-way-all     + export-ras.gds-way-all
        s-l-all-day       =  s-l-all-day       + l-all-day
        ss-qnty           =  ss-qnty           + export-ras.qnty
        ss-sum-rubl       =  ss-sum-rubl       + export-ras.sum-rubl
        ss-qnty-rashkassa =  ss-qnty-rashkassa + (export-ras.qnty-rash + export-ras.qnty-kassa)
        ss-zero-day       =  ss-zero-day       + export-ras.zero-day
        ss-qnty-stk       =  ss-qnty-stk       + export-ras.qnty-stk
        ss-qnty-prih      =  ss-qnty-prih      + export-ras.qnty-prih
        ss-qnty-rash      =  ss-qnty-rash      + export-ras.qnty-rash
        ss-qnty-kassa     =  ss-qnty-kassa     + export-ras.qnty-kassa
        ss-min-stock      =  ss-min-stock      + export-ras.min-stock
        ss-service-order  =  ss-service-order  + export-ras.service-order
        ss-min-order      =  ss-min-order      + export-ras.min-order
        ss-gds-way-all    =  ss-gds-way-all    + export-ras.gds-way-all
        ss-l-all-day      =  ss-l-all-day      + l-all-day
        .
        assign
          v-stroka = num#str#   /*номер последней строки по которую суммировать*/
        .
        if g#type = {&o-f} then run spis-post in this-procedure .
        /*  Детализация по признакам    */
        for each tmp#zakaz-prn where tmp#zakaz-prn.artic     = export-ras.artic     and
                                     tmp#zakaz-prn.prod-type = export-ras.prod-type and
                                     tmp#zakaz-prn.prod-code = export-ras.prod-code and
                                     tmp#zakaz-prn.obj-type  = export-ras.obj-type  and
                                     tmp#zakaz-prn.obj-code  = export-ras.obj-code  no-lock
        :
            num#str# = num#str# + 1 .
            find first gds-prt where gds-prt.node-code = tmp#zakaz-prn.prt-code .
            num#col# = new-n(1).  run macr_excel_char_with_format in this-procedure ( export-ras.gds-code , num#str# , num#col#  ).
            /*num#col# = new-n(2).  run macr_excel_char_with_format in this-procedure ( export-ras.artic    , num#str# , num#col#  ).*/
            num#col# = new-n(3).  run macr_excel_char_with_format in this-procedure ( "__" + ub.goods.gds-name + " " + gds-prt.f-name  , num#str# , num#col#  ).
            num#col# = new-n(4).  run macr_excel_char_with_format in this-procedure ( ub.goods.grp-name   , num#str# , num#col#  ).
            num#col# = new-n(5).  run macr_excel_char_with_format in this-procedure ( ub.goods.unit-base  , num#str# , num#col#  ).
            num#col# = new-n(6).  run macr_excel_char_with_format in this-procedure ( tmp#zakaz-prn.prod-type + " " + string(tmp#zakaz-prn.prod-code) , num#str# , num#col#  ).
            num#col# = new-n(7).  run macr_excel_char_with_format in this-procedure ( ub.clients.obj-name , num#str# , num#col#  ).
            num#col# = new-n(8).  run macr_excel_char_with_format in this-procedure ( export-ras.cli-art  , num#str# , num#col#  ).
            num#col# = new-n(9).  run macr_excel_char_with_format in this-procedure ( export-ras.unit-cli , num#str# , num#col#  ).
            num#col# = new-n(10). run macr_excel_dec in this-procedure (  ub.goods.deadline               , num#str# , num#col#  ).
            num#col# = new-n(11). run macr_excel_dec in this-procedure (  export-ras.cli-base-rate        , num#str# , num#col#  ).
            num#col# = new-n(12). run macr_excel_dec in this-procedure (  ub.goods.qnty-cart              , num#str# , num#col#  ).
            num#col# = new-n(14). run macr_excel_dec in this-procedure (  tmp#zakaz-prn.qnty-sale , num#str# , num#col#  ).

            find first bufo_clients no-lock
                where bufo_clients.obj-type = export-ras.obj-type
                  and bufo_clients.obj-code = export-ras.obj-code
                no-error .

            num#col# = new-n(22). run macr_excel_char_with_format in this-procedure ( export-ras.obj-type + " " + string(export-ras.obj-code) , num#str# , num#col#  ).
            num#col# = new-n(32). run macr_excel_char_with_format in this-procedure ( bufo_clients.obj-name , num#str# , num#col# ).
            num#col# = new-n(23). run macr_excel_char_with_format in this-procedure ( export-ras.negative-rest , num#str# , num#col# ).
            num#col# = new-n(25). run macr_excel_dec in this-procedure ( tmp#zakaz-prn.qnty-ord , num#str# , num#col# ).
            /*if kol-obj = 1 then do :
              num#col# = new-n(26). run macr_excel_char in this-procedure ( v-cntxt-host-name-obj  , num#str# , num#col#  ).
              num#col# = new-n(29). run macr_excel_dec  in this-procedure ( v-cntxt-host-code-obj  , num#str# , num#col#  ).
              num#col# = new-n(28). run macr_excel_char in this-procedure ({&cmp}                  , num#str# , num#col#  ).
            end.*/
        end.  /*  for each tmp#zakaz-prn   */
        find first tmp#zakaz-prn where tmp#zakaz-prn.artic     = export-ras.artic     and
                                       tmp#zakaz-prn.prod-type = export-ras.prod-type and
                                       tmp#zakaz-prn.prod-code = export-ras.prod-code and
                                       tmp#zakaz-prn.obj-type  = export-ras.obj-type  and
                                       tmp#zakaz-prn.obj-code  = export-ras.obj-code  no-lock no-error .
        if available tmp#zakaz-prn and tog-det-prizn then num#str# = num#str# + 1 .
        if g#type <> {&f-p} or kol-obj = 1 then
        run spis-post in this-procedure .
        if last-of(export-ras.gds-code) and g#type = {&f-p} and kol-obj > 1  then do:
                num#str# = num#str# + 1 .
                num#col# = new-n(1).  run macr_excel_dec  in this-procedure (export-ras.gds-code , num#str# , num#col# ).
                num#col# = new-n(2).  run macr_excel_char in this-procedure ( " Итого по товару" , num#str# , num#col# ).
                num#col# = new-n(14). run macr_excel_dec  in this-procedure (s-qnty-rashkassa    , num#str# , num#col# ).
                num#col# = new-n(17). run macr_excel_dec  in this-procedure (s-qnty-stk          , num#str# , num#col# ).
                num#col# = new-n(18). run macr_excel_dec  in this-procedure (s-qnty-prih         , num#str# , num#col# ).
                num#col# = new-n(24). run macr_excel_dec  in this-procedure (s-gds-way-all       , num#str# , num#col# ).
                num#col# = new-n(25). run macr_excel_dec  in this-procedure (s-qnty              , num#str# , num#col# ).
                run macr_cell_format in this-procedure
                          ( 10    ,     /* p-size */
                            true  ,     /*p-bold   */
                            false ,     /*p-italic */
                            ?     ,     /*p-color  */
                            num#str# ,  /*p-row    */
                            1 ,         /*p-col    */
                            ? ,         /*p-row-2  */
                            max-col     ) . /*p-col-2 */
                run spis-post in this-procedure .
        end.
    end.
end. /*if p-val-gds-obj*/
else do:
    for each  export-ras ,
        first ub.goods no-lock where
              ub.goods.artic     = export-ras.artic     and
              ub.goods.prod-type = export-ras.prod-type and
              ub.goods.prod-code = export-ras.prod-code
        break
          by export-ras.obj-code
          by ( if x-tog-grp   then ub.goods.grp-name else "" )
          by ( if x-tog-artic then export-ras.artic  else ub.goods.gds-name )
          :

        find first ub.clients no-lock where
              ub.clients.obj-type = ub.goods.prod-type and
              ub.clients.obj-code = ub.goods.prod-code
              no-error .
              if error-status :error then next.
        find first bufo_clients no-lock where
                  bufo_clients.obj-type = export-ras.obj-type and
                  bufo_clients.obj-code = export-ras.obj-code
                  no-error .

        assign
          num#col# = 1
          num#str# = num#str# + 1
        .
        /* === */
        if first-of(export-ras.obj-code) then do:
          num#col# = v-first-column. run macr_excel_char in this-procedure ( substitute(" По объекту: &1", bufo_clients.obj-name), num#str# , num#col# ).
          run macr_cell_format in this-procedure
                    ( 10    ,         /* p-size */
                      true  ,         /*p-bold  */
                      false ,         /*p-italic*/
                      ?     ,         /*p-color */
                      num#str# ,      /*p-row   */
                      1     ,         /*p-col   */
                      ?     ,         /*p-row-2 */
                      max-col     ) . /*p-col-2 */
          num#str# = num#str# + 1 .
          assign
              s-in-qnty       = 0
              s-out-qnty      = 0
              s-out-sum       = 0
              s-supp-qnty     = 0
              s-qnty          = 0
              s-sum-rubl      = 0
              s-qnty-rashkassa= 0
              s-zero-day      = 0
              s-qnty-stk      = 0
              s-qnty-prih     = 0
              s-qnty-rash     = 0
              s-qnty-kassa    = 0
              s-min-stock     = 0
              s-service-order = 0
              s-min-order     = 0
              s-gds-way-all   = 0
              s-l-all-day     = 0
            .
        end.
        num#col# = new-n(1).  run macr_excel_char_with_format in this-procedure ( export-ras.gds-code , num#str# , num#col#  ).
        num#col# = new-n(2).  run macr_excel_char_with_format in this-procedure ( export-ras.artic    , num#str# , num#col#  ).
        num#col# = new-n(3).  run macr_excel_char_with_format in this-procedure ( ub.goods.gds-name   , num#str# , num#col#  ).
        num#col# = new-n(4).  run macr_excel_char_with_format in this-procedure ( ub.goods.grp-name   , num#str# , num#col#  ).
        num#col# = new-n(5).  run macr_excel_char_with_format in this-procedure ( ub.goods.unit-base  , num#str# , num#col#  ).
        num#col# = new-n(6).  run macr_excel_char_with_format in this-procedure ( export-ras.prod-type + " " + string(export-ras.prod-code) , num#str# , num#col#  ).
        num#col# = new-n(7).  run macr_excel_char_with_format in this-procedure ( ub.clients.obj-name   , num#str# , num#col#  ).
        num#col# = new-n(8).  run macr_excel_char_with_format in this-procedure ( export-ras.cli-art    , num#str# , num#col#  ).
        num#col# = new-n(9).  run macr_excel_char_with_format in this-procedure ( export-ras.unit-cli   , num#str# , num#col#  ).
        num#col# = new-n(10). run macr_excel_dec in this-procedure (  ub.goods.deadline         , num#str# , num#col#  ).
        num#col# = new-n(11). run macr_excel_dec in this-procedure (  export-ras.cli-base-rate  , num#str# , num#col#  ).
        num#col# = new-n(12). run macr_excel_dec in this-procedure (  ub.goods.qnty-cart        , num#str# , num#col#  ).

        num#col# = new-n(13). run macr_excel_dec in this-procedure (  export-ras.Temp-rash  , num#str# , num#col#  ).
        num#col# = new-n(14). run macr_excel_dec in this-procedure (  (export-ras.qnty-rash + export-ras.qnty-kassa) , num#str# , num#col#  ).
        num#col# = new-n(15). run macr_excel_dec in this-procedure (  export-ras.zero-day   , num#str# , num#col#  ).

        l-all-day =  export-ras.all-day  .   if l-all-day = ? then l-all-day = 0 .

        num#col# = new-n(16). run macr_excel_dec in this-procedure ( l-all-day , num#str# , num#col# ).
        num#col# = new-n(17). run macr_excel_dec in this-procedure ( export-ras.qnty-stk , num#str# , num#col# ).
        num#col# = new-n(18). run macr_excel_dec in this-procedure ( export-ras.qnty-prih , num#str# , num#col# ).
        num#col# = new-n(19). run macr_excel_dec in this-procedure ( export-ras.min-stock , num#str# , num#col# ).
        num#col# = new-n(20). run macr_excel_dec in this-procedure ( export-ras.service-order , num#str# , num#col# ).
        num#col# = new-n(21). run macr_excel_dec in this-procedure ( export-ras.min-order , num#str# , num#col# ).
        num#col# = new-n(22). run macr_excel_char_with_format in this-procedure ( export-ras.obj-type + " " + string(export-ras.obj-code) , num#str# , num#col#  ).
        num#col# = new-n(32). run macr_excel_char_with_format in this-procedure ( bufo_clients.obj-name , num#str# , num#col# ).
        num#col# = new-n(23). run macr_excel_char_with_format in this-procedure ( export-ras.negative-rest , num#str# , num#col# ).
        num#col# = new-n(24). run macr_excel_dec in this-procedure ( export-ras.gds-way-all , num#str# , num#col# ).
        num#col# = new-n(25). run macr_excel_dec in this-procedure ( export-ras.qnty , num#str# , num#col# ).
        num#col# = new-n(33). run macr_excel_dec in this-procedure ( export-ras.order-qnty , num#str# , num#col# ).
        assign v-b-str = "".
        for each buf_bar-code no-lock
        where buf_bar-code.gds-code = export-ras.gds-code
        :
          for each buf_prod-bc no-lock
            where buf_prod-bc.b-code = buf_bar-code.b-code
              :
              if available buf_prod-bc then do:
                if v-b-str = "" then do:
                    assign v-b-str = buf_prod-bc.b-str .
                end.
                else do:
                    assign v-b-str = v-b-str + "," + buf_prod-bc.b-str .
                end.
              end.
          end.
        end.
        num#col# = new-n(34). run macr_excel_char_with_format in this-procedure ( v-b-str , num#str# , num#col#  ).

        if g#type = {&o-f} and p-det-post then run spis-post in this-procedure .

        /*  Детализация по признакам    */
        for each tmp#zakaz-prn where tmp#zakaz-prn.artic     = export-ras.artic     and
                                     tmp#zakaz-prn.prod-type = export-ras.prod-type and
                                     tmp#zakaz-prn.prod-code = export-ras.prod-code and
                                     tmp#zakaz-prn.obj-type  = export-ras.obj-type  and
                                     tmp#zakaz-prn.obj-code  = export-ras.obj-code  no-lock
        :
            num#str# = num#str# + 1 .
            find first gds-prt where gds-prt.node-code = tmp#zakaz-prn.prt-code .
            num#col# = new-n(1).  run macr_excel_char_with_format in this-procedure ( export-ras.gds-code , num#str# , num#col#  ).
            /*num#col# = new-n(2).  run macr_excel_char_with_format in this-procedure ( export-ras.artic    , num#str# , num#col#  ).*/
            num#col# = new-n(3).  run macr_excel_char_with_format in this-procedure ( "__" + ub.goods.gds-name + " " + gds-prt.f-name  , num#str# , num#col#  ).
            num#col# = new-n(4).  run macr_excel_char_with_format in this-procedure ( ub.goods.grp-name   , num#str# , num#col#  ).
            num#col# = new-n(5).  run macr_excel_char_with_format in this-procedure ( ub.goods.unit-base  , num#str# , num#col#  ).
            num#col# = new-n(6).  run macr_excel_char_with_format in this-procedure ( tmp#zakaz-prn.prod-type + " " + string(tmp#zakaz-prn.prod-code) , num#str# , num#col#  ).
            num#col# = new-n(7).  run macr_excel_char_with_format in this-procedure ( ub.clients.obj-name , num#str# , num#col#  ).
            num#col# = new-n(8).  run macr_excel_char_with_format in this-procedure ( export-ras.cli-art  , num#str# , num#col#  ).
            num#col# = new-n(9).  run macr_excel_char_with_format in this-procedure ( export-ras.unit-cli , num#str# , num#col#  ).
            num#col# = new-n(10). run macr_excel_dec in this-procedure (  ub.goods.deadline               , num#str# , num#col#  ).
            num#col# = new-n(11). run macr_excel_dec in this-procedure (  export-ras.cli-base-rate        , num#str# , num#col#  ).
            num#col# = new-n(12). run macr_excel_dec in this-procedure (  ub.goods.qnty-cart              , num#str# , num#col#  ).
            num#col# = new-n(14). run macr_excel_dec in this-procedure (  tmp#zakaz-prn.qnty-sale , num#str# , num#col#  ).

            find first bufo_clients no-lock
                where bufo_clients.obj-type = export-ras.obj-type
                  and bufo_clients.obj-code = export-ras.obj-code
                no-error .

            num#col# = new-n(22). run macr_excel_char_with_format in this-procedure ( export-ras.obj-type + " " + string(export-ras.obj-code) , num#str# , num#col#  ).
            num#col# = new-n(32). run macr_excel_char_with_format in this-procedure ( bufo_clients.obj-name , num#str# , num#col# ).
            num#col# = new-n(23). run macr_excel_char_with_format in this-procedure ( export-ras.negative-rest , num#str# , num#col# ).
            num#col# = new-n(25). run macr_excel_dec in this-procedure ( tmp#zakaz-prn.qnty-ord , num#str# , num#col# ).
            /*if p-det-post then do :
              num#col# = new-n(26). run macr_excel_char in this-procedure ( v-cntxt-host-name-obj  , num#str# , num#col#  ).
              num#col# = new-n(29). run macr_excel_dec  in this-procedure ( v-cntxt-host-code-obj  , num#str# , num#col#  ).
              num#col# = new-n(28). run macr_excel_char in this-procedure ({&cmp}                  , num#str# , num#col#  ).
            end.*/
        end.  /*  for each tmp#zakaz-prn   */
        find first tmp#zakaz-prn where tmp#zakaz-prn.artic     = export-ras.artic     and
                                       tmp#zakaz-prn.prod-type = export-ras.prod-type and
                                       tmp#zakaz-prn.prod-code = export-ras.prod-code and
                                       tmp#zakaz-prn.obj-type  = export-ras.obj-type  and
                                       tmp#zakaz-prn.obj-code  = export-ras.obj-code  no-lock no-error .
        if available tmp#zakaz-prn and p-det-post and tog-det-prizn then num#str# = num#str# + 1 .
        assign
        s-qnty                =  s-qnty        +  export-ras.qnty
        s-sum-rubl            =  s-sum-rubl    +  export-ras.sum-rubl
        s-qnty-rashkassa      =  s-qnty-rashkassa +   (export-ras.qnty-rash + export-ras.qnty-kassa)
        s-zero-day            =  s-zero-day    +  export-ras.zero-day
        s-qnty-stk            =  s-qnty-stk    +  export-ras.qnty-stk
        s-qnty-prih           =  s-qnty-prih   +  export-ras.qnty-prih
        s-qnty-rash           =  s-qnty-rash   +  export-ras.qnty-rash
        s-qnty-kassa          =  s-qnty-kassa  +  export-ras.qnty-kassa
        s-min-stock           = (if R-min-rest = 2 then 0 else s-min-stock     ) +  export-ras.min-stock
        s-service-order       = (if R-min-rest = 2 then 0 else s-service-order ) + export-ras.service-order
        s-min-order           = (if R-min-rest = 2 then 0 else s-min-order     ) + export-ras.min-order
        s-gds-way-all         =  s-gds-way-all   + export-ras.gds-way-all
        s-l-all-day           =  s-l-all-day     +  l-all-day
        ss-qnty                =  ss-qnty        +  export-ras.qnty
        ss-sum-rubl            =  ss-sum-rubl    +  export-ras.sum-rubl
        ss-qnty-rashkassa      =  ss-qnty-rashkassa +   (export-ras.qnty-rash + export-ras.qnty-kassa)
        ss-zero-day            =  ss-zero-day    +  export-ras.zero-day
        ss-qnty-stk            =  ss-qnty-stk    +  export-ras.qnty-stk
        ss-qnty-prih           =  ss-qnty-prih   +  export-ras.qnty-prih
        ss-qnty-rash           =  ss-qnty-rash   +  export-ras.qnty-rash
        ss-qnty-kassa          =  ss-qnty-kassa  +  export-ras.qnty-kassa
        ss-min-stock           =  ss-min-stock   +  export-ras.min-stock
        ss-service-order       =  ss-service-order + export-ras.service-order
        ss-min-order           =  ss-min-order     + export-ras.min-order
        ss-gds-way-all         =  ss-gds-way-all   + export-ras.gds-way-all
        ss-l-all-day           =  ss-l-all-day     + l-all-day
        .

        if p-det-post then run spis-post in this-procedure .
        if last-of(export-ras.obj-code) and g#type = {&f-p} and kol-obj > 1 then do:
                num#str# = num#str# + 1 .
                num#col# = v-first-column. run macr_excel_char in this-procedure ( substitute(" Итого по объекту &1", bufo_clients.obj-name), num#str# , num#col# ).
                num#col# = new-n(14). run macr_excel_dec in this-procedure (s-qnty-rashkassa , num#str# , num#col# ).
                num#col# = new-n(17). run macr_excel_dec in this-procedure (s-qnty-stk       , num#str# , num#col# ).
                num#col# = new-n(18). run macr_excel_dec in this-procedure (s-qnty-prih      , num#str# , num#col# ).
                num#col# = new-n(24). run macr_excel_dec in this-procedure (s-gds-way-all    , num#str# , num#col# ).
                num#col# = new-n(25). run macr_excel_dec in this-procedure (s-qnty           , num#str# , num#col# ).
                run macr_cell_format in this-procedure
                          ( 10    ,         /* p-size */
                            true  ,         /*p-bold  */
                            false ,         /*p-italic*/
                            ?     ,         /*p-color */
                            num#str# ,      /*p-row   */
                            1 ,             /*p-col   */
                            ? ,             /*p-row-2 */
                            max-col     ) . /*p-col-2 */
        end.
    end.
end. /*else do*/
assign
  num#str# = num#str# + 1
  num#col# = 1
  p-name = "END FILE":U
.
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).


end. /* do */
end procedure. /* make-str-1 */

procedure init-screen :
 do
 on error undo, return error return-value
 :
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "all-ord":U    no-error .
         if not available ubflt.usr-flt  then do:
            message error-status :get-message(1) .
         end.

assign p-val = ubflt.usr-flt.list_ .
define variable v-nn as integer   no-undo .
define variable v-ii as integer   no-undo .

assign v-nn = num-entries(p-val).
  do i = 1 to v-nn :
     case  entry(1,(entry(i,p-val)), "=" ) :
        when string( "R-min-rest" )        then R-min-rest  = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "R-algoritm" )        then R-algoritm  = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "R-algoritm2" )       then R-algoritm2 = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "tmp-sale.tmp-code" ) then do:
             find first ub.tmp-sale no-lock where ub.tmp-sale.tmp-code = entry(2,(entry(i,p-val)), "=" ) no-error.
             if available ub.tmp-sale then do:
             end.
             else do:
             end.
        end.

        when string( "SelectObject" ) then  do:
                SelectObject = string(entry(2,(entry(i,p-val)), "=" )) no-error .
             end.
        when string( "date-p-1"   ) then date-p-1    = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "date-p-2"   ) then date-p-2    = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "t-way"      ) then t-way       = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rcv"      ) then t-rcv       = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-clos"     ) then t-clos      = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rv"       ) then t-rv        = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rvz"      ) then t-rvz       = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rvc"      ) then t-rvc       = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rvzc"     ) then t-rvzc      = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sp"       ) then t-sp        = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv"     ) then t-sppv      = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv-2"   ) then t-sppv-2    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv-3"   ) then t-sppv-3    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv-4"   ) then t-sppv-4    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "p-neg-sale" ) then p-neg-sale  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-gar"      ) then t-gar       = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-min-zapas") then t-min-zapas = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "R-min-rest3") then R-min-rest3 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        /*when string( "tog-det-prizn") then  tog-det-prizn = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .*/

        otherwise do:
        end.
     end case.
  end.
assign
  date-1 = date-p-1
  date-2 = date-p-2
.

  kol-obj = num-entries( entry(2,ubflt.usr-flt.list_,"&" ) , ",") - 1 .
     if kol-obj  = ? then kol-obj  = 0 .

/*radio-set выбор формы печати: yes - для импорта\ no - произвольная*/
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "selrdallo":U    no-error .
         if available ubflt.usr-flt then do :
            DO v-ii = 1 TO NUM-ENTRIES( ubflt.usr-flt.list_, {&delim-par}):
              CASE v-ii:
                  WHEN 1 THEN DO:
                    p-val-rad     = logical(entry(v-ii, ubflt.usr-flt.list_, {&delim-par})) .
                  END.
                  WHEN 2 THEN DO:
                    p-val-gds-obj = logical(entry(v-ii, ubflt.usr-flt.list_, {&delim-par})) .
                  END.
                  WHEN 3 THEN DO:
                    p-det-post    = logical(entry(v-ii, ubflt.usr-flt.list_, {&delim-par})) .
                  END.
                  WHEN 4 THEN DO:
                    p-only-am     = logical(entry(v-ii, ubflt.usr-flt.list_, {&delim-par})) .
                  END.
                  WHEN 5 THEN DO:
                    tog-det-prizn = logical(entry(v-ii, ubflt.usr-flt.list_, {&delim-par})) .
                  END.
              end case.
            end.
         end.
         else do:
            assign
              p-val-rad = yes
              p-only-am = no
            .
         end.
         if p-val-rad = yes then do : /*если для импорта*/
            assign
                p-val-gds-obj = yes
            .
         end.
/*получение списка выбранных колонок*/
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "selcolallo":U    no-error .
         if available ubflt.usr-flt then do :
            assign p-val-col = ubflt.usr-flt.list_ .
         end.

if p-val-col <> "" then do: /*есть сохраненные настройки*/
  assign
    print-col-1  = if p-val-rad then yes else logical(entry( 1 , p-val-col, {&delim-par}))
    print-col-2  = if p-val-rad then yes else logical(entry( 2 , p-val-col, {&delim-par}))
    print-col-3  = if p-val-rad then yes else logical(entry( 3 , p-val-col, {&delim-par}))
    print-col-4  = if p-val-rad then yes else logical(entry( 4 , p-val-col, {&delim-par}))
    print-col-5  = if p-val-rad then yes else logical(entry( 5 , p-val-col, {&delim-par}))
    print-col-6  = if p-val-rad then yes else logical(entry( 6 , p-val-col, {&delim-par}))
    print-col-7  = if p-val-rad then yes else logical(entry( 7 , p-val-col, {&delim-par}))
    print-col-8  = if p-val-rad then yes else logical(entry( 8 , p-val-col, {&delim-par}))
    print-col-9  = if p-val-rad then yes else logical(entry( 9 , p-val-col, {&delim-par}))
    print-col-10 = if p-val-rad then yes else logical(entry( 10, p-val-col, {&delim-par}))
    print-col-11 = if p-val-rad then yes else logical(entry( 11, p-val-col, {&delim-par}))
    print-col-12 = if p-val-rad then yes else logical(entry( 12, p-val-col, {&delim-par}))
    print-col-13 = if p-val-rad then yes else logical(entry( 13, p-val-col, {&delim-par}))
    print-col-14 = if p-val-rad then yes else logical(entry( 14, p-val-col, {&delim-par}))
    print-col-15 = if p-val-rad then yes else logical(entry( 15, p-val-col, {&delim-par}))
    print-col-16 = if p-val-rad then yes else logical(entry( 16, p-val-col, {&delim-par}))
    print-col-17 = if p-val-rad then yes else logical(entry( 17, p-val-col, {&delim-par}))
    print-col-18 = if p-val-rad then yes else logical(entry( 18, p-val-col, {&delim-par}))
    print-col-19 = if p-val-rad then yes else logical(entry( 19, p-val-col, {&delim-par}))
    print-col-20 = if p-val-rad then yes else logical(entry( 20, p-val-col, {&delim-par}))
    print-col-21 = if p-val-rad then yes else logical(entry( 21, p-val-col, {&delim-par}))
    print-col-22 = if p-val-rad then yes else logical(entry( 22, p-val-col, {&delim-par}))
    print-col-23 = if p-val-rad then yes else logical(entry( 23, p-val-col, {&delim-par}))
    print-col-24 = if p-val-rad then yes else logical(entry( 24, p-val-col, {&delim-par}))
    print-col-25 = if p-val-rad then yes else logical(entry( 25, p-val-col, {&delim-par}))
    print-col-26 = if p-val-rad then yes else logical(entry( 26, p-val-col, {&delim-par}))
    print-col-27 = if p-val-rad then yes else logical(entry( 27, p-val-col, {&delim-par}))
    print-col-28 = if p-val-rad then yes else logical(entry( 28, p-val-col, {&delim-par}))
    print-col-29 = if p-val-rad then yes else logical(entry( 29, p-val-col, {&delim-par}))
    print-col-30 = if p-val-rad then yes else logical(entry( 30, p-val-col, {&delim-par}))
    print-col-31 = if p-val-rad then yes else logical(entry( 31, p-val-col, {&delim-par}))
    print-col-32 = if p-val-rad then yes else logical(entry( 32, p-val-col, {&delim-par}))
    print-col-33 = if p-val-rad then yes else logical(entry( 33, p-val-col, {&delim-par}))
    print-col-34 = if p-val-rad then yes else logical(entry( 34, p-val-col, {&delim-par}))
  no-error .
end.
else do: /*нет сохраненных выбранных для печати колонок*/
  if p-val-rad then do: /*в печати для импорта - все колонки*/
  assign
      print-col-1  = yes
      print-col-2  = yes
      print-col-3  = yes
      print-col-4  = yes
      print-col-5  = yes
      print-col-6  = yes
      print-col-7  = yes
      print-col-8  = yes
      print-col-9  = yes
      print-col-10 = yes
      print-col-11 = yes
      print-col-12 = yes
      print-col-13 = yes
      print-col-14 = yes
      print-col-15 = yes
      print-col-16 = yes
      print-col-17 = yes
      print-col-18 = yes
      print-col-19 = yes
      print-col-20 = yes
      print-col-21 = yes
      print-col-22 = yes
      print-col-23 = yes
      print-col-24 = yes
      print-col-25 = yes
      print-col-26 = yes
      print-col-27 = yes
      print-col-28 = yes
      print-col-29 = yes
      print-col-30 = yes
      print-col-31 = yes
      print-col-32 = yes
      print-col-33 = yes
      print-col-34 = yes
  .
  end.
  else do: /*печать в произвольной форме*/
    message
      "Не были выбраны колонки для печати!" skip
      "В созданном файле данные будут скрыты!" skip
    view-as alert-box information.
  end.
end.

/*получение списка колонок по порядку*/
run uf-get in this-procedure (
     input  {&uf-seqeallo}
    ,input  'adm'
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
define variable iv as integer   no-undo .
define variable i-kol as integer   no-undo .
define variable st as character no-undo .

if v-uf-List_ <> "" then do:
i-kol = num-entries (v-uf-List_, {&delim-par}) .
    repeat Iv = 1 to i-kol :
      st = entry(Iv,v-uf-List_, {&delim-par}).
      create tt-table.
      assign
        tt-table.id = integer(entry(1, st))
        tt-table.new-id = integer(entry(2, st))
      .
    end.
end.
else do:
    repeat Iv = 1 to 34 :
      create tt-table.
      assign
        tt-table.id = iv
        tt-table.new-id = iv
      .
    end.
end.
if p-val-col <> "" then do:
  repeat i = 1 to num-entries(p-val-col, {&delim-par}) :
     if entry( i , p-val-col, {&delim-par} ) = "yes" then do :
       assign v-first-column = i .
       leave.
     end.
  end.
end.
else do:
  assign v-first-column = 1 .
end.

 end. /* do */
end procedure. /* init-screen */


procedure mf :
 do
 on error undo, return error return-value
 :
    /* создаем временный файл  */
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream  Macr_Excel to value(v-file-name) .
    assign
      v-ind = v-ind + 1
      num#str# = 0
    .

 end. /* do */
end procedure. /* mf */



procedure make-str-2 :
 do
 on error undo, return error return-value
 :
assign
  num#str# = 1
  num#col# =  1
.
run macr_excel_char in this-procedure ( "Параметры расчета заказа", num#str# , num#col# ) .
 run macr_cell_format in this-procedure
          ( 12    ,     /* p-size */
            true  ,     /*p-bold  */
            false ,     /*p-italic*/
            15    ,     /*p-color */
            num#str# ,  /*p-row   */
            1 ,         /*p-col   */
            ? ,         /*p-row-2 */
            3       ) . /*p-col-2 */


define variable jjj     as integer   no-undo .
define variable pp-str  as character no-undo .
define variable pp-str2 as character no-undo .

define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable iii   as integer no-undo .
num#col# =  1.
define variable v-nn  as integer no-undo .
define variable v-nn2 as integer no-undo .
v-nn = num-entries ( e-method ,"{&new-line}")  .


    repeat iii = 1 to v-nn :
        pp-str = entry (iii, e-method , "{&new-line}").
        v-nn2 = num-entries ( pp-str ,";") .
          repeat jjj = 1 to v-nn2 :
            pp-str2 = entry (jjj, pp-str , ";").
            if pp-str2 <> "" and pp-str2 <> ? and  pp-str2 <> " " then do:
                    l-len = length (pp-str2  ) .
                    l-m = integer( l-len / 220 ) + 1 .
                    do l-jj = 1 to  l-m  :
                        num#str# = num#str# + 1 .
                        run macr_excel_char in this-procedure (
                            substring( pp-str2, (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .
                    end.
            end.
          end.
    end.


 end. /* do */
end procedure. /* make-str-2 */

procedure spis-post :

 do
 on error undo, return error return-value
 :
define variable ig        as integer no-undo .
define variable v-pr-rubl as decimal no-undo .

define buffer buf_doc-line   for ub.doc-line .

if G#type = {&o-f} then do:
  num#col# = new-n(25). run macr_excel_dec  in this-procedure ( export-ras.qnty        , num#str# , num#col#  ).
  num#col# = new-n(26). run macr_excel_char in this-procedure ( v-cntxt-host-name-obj  , num#str# , num#col#  ).
  num#col# = new-n(28). run macr_excel_char in this-procedure ({&cmp}                  , num#str# , num#col#  ).
  num#col# = new-n(29). run macr_excel_dec  in this-procedure ( v-cntxt-host-code-obj  , num#str# , num#col#  ).
  num#col# = new-n(31). run macr_excel_char in this-procedure ( "*"                    , num#str# , num#col#  ).
end.
else do:
 find first G#Customer no-error.
 if not available G#Customer then do: /* все */
    for each ub.cli-gds where ub.cli-gds.artic      = export-ras.artic      and
                             ub.cli-gds.prod-code   = export-ras.prod-code  and
                             ub.cli-gds.prod-type   = export-ras.prod-type  and
                             ub.cli-gds.host-code   = v-cntxt-host-code-obj and
                             ub.cli-gds.price-cli   > 0                     and
                           ( ub.cli-gds.cancel-date = ? or
                             ub.cli-gds.cancel-date > p-ship-date )
                            no-lock ,
        first ub.clients where  ub.clients.obj-type = ub.cli-gds.cli-type and
                                ub.clients.obj-code = ub.cli-gds.cli-code and
                              ( ub.clients.sup-gds  = true or
                                ub.clients.sup-cons = true)
                            no-lock
                            break by ub.cli-gds.price-cli :
                  find first buf_doc-line no-lock where
                             buf_doc-line.doc-code   = ub.cli-gds.in-code and
                             buf_doc-line.artic      = ub.cli-gds.artic and
                             buf_doc-line.prod-type  = ub.cli-gds.prod-type and
                             buf_doc-line.prod-code  = ub.cli-gds.prod-code no-error
                              .
                if available buf_doc-line then do:
                  assign
                    v-pr-rubl = buf_doc-line.price-rubl
                  .
                end.
                else do:
                  assign
                    v-pr-rubl = ub.cli-gds.price-cli / export-ras.cli-base-rate
                  .
                end.
                assign
                  Ig = Ig + 1
                  num#col# = new-n(25)
                .
                if NOT p-val-gds-obj then do:
                    run macr_excel_dec in this-procedure ( export-ras.qnty , num#str# , num#col#  ).
                end.
                else do:
                  if kol-obj > 1 then do :
                    run macr_excel_sum in this-procedure ( num#str# , num#col# , (v-stroka - kol-obj + 1 ) , num#col# , v-stroka , num#col#  ).
                  end.
                  else do:
                    run macr_excel_dec in this-procedure ( export-ras.qnty , num#str# , num#col#  ).
                  end.
                end.
                num#col# = new-n(26). run macr_excel_char in this-procedure (clients.obj-name +
                                if (cli-gds.cli-type = saletype And
                                    cli-gds.cli-code = salecode )  then "    ЭТО РЕАЛИЗАЦИЯ !!!" else ""     , num#str# , num#col#  ).
                num#col# = new-n(27). run macr_excel_dec  in this-procedure (v-pr-rubl                       , num#str# , num#col#  ).
                num#col# = new-n(28). run macr_excel_char in this-procedure (ub.cli-gds.cli-type             , num#str# , num#col#  ).
                num#col# = new-n(29). run macr_excel_dec  in this-procedure (ub.cli-gds.cli-code             , num#str# , num#col#  ).
                num#col# = new-n(30). run macr_excel_char_with_format in this-procedure (ub.cli-gds.cli-art  , num#str# , num#col#  ).
                num#col# = new-n(31). run macr_excel_char in this-procedure ((If ig = 1 Then  "*" Else "")   , num#str# , num#col#  ).
                num#str# = num#str# + 1 .
  end.
 end.
 else do: /* есть список выбранных поставщиков */
    for each G#Customer no-lock :
        for each ub.cli-gds where ub.cli-gds.artic     = export-ras.artic      and
                                ub.cli-gds.prod-code   = export-ras.prod-code  and
                                ub.cli-gds.prod-type   = export-ras.prod-type  and
                                ub.cli-gds.host-code   = v-cntxt-host-code-obj and
                                ub.cli-gds.cli-type    = G#Customer.obj-type   and
                                ub.cli-gds.cli-code    = G#Customer.obj-code   and
                                ub.cli-gds.price-cli   > 0                     and
                              ( ub.cli-gds.cancel-date = ? or
                                ub.cli-gds.cancel-date > p-ship-date )
                                no-lock ,
            first ub.clients where  ub.clients.obj-type = ub.cli-gds.cli-type and
                                    ub.clients.obj-code = ub.cli-gds.cli-code and
                                  ( ub.clients.sup-gds  = true or
                                    ub.clients.sup-cons = true)
                                no-lock
                                break by ub.cli-gds.price-cli :
                      find first buf_doc-line no-lock where
                                buf_doc-line.doc-code   = ub.cli-gds.in-code and
                                buf_doc-line.artic      = ub.cli-gds.artic and
                                buf_doc-line.prod-type  = ub.cli-gds.prod-type and
                                buf_doc-line.prod-code  = ub.cli-gds.prod-code no-error
                                  .
                    if available buf_doc-line then do:
                      assign
                        v-pr-rubl = buf_doc-line.price-rubl
                      .
                    end.
                    else do:
                      assign
                        v-pr-rubl = ub.cli-gds.price-cli / export-ras.cli-base-rate
                      .
                    end.
                    assign
                      Ig = Ig + 1
                      num#col# = new-n(25)
                    .
                    if NOT p-val-gds-obj then do:
                        run macr_excel_dec in this-procedure ( export-ras.qnty , num#str# , num#col#  ).
                    end.
                    else do:
                      if kol-obj > 1 then do :
                        run macr_excel_sum in this-procedure ( num#str# , num#col# , (v-stroka - kol-obj + 1 ) , num#col# , v-stroka , num#col#  ).
                      end.
                      else do:
                        run macr_excel_dec in this-procedure ( export-ras.qnty , num#str# , num#col#  ).
                      end.
                    end.
                    num#col# = new-n(26). run macr_excel_char in this-procedure (clients.obj-name +
                                    if (cli-gds.cli-type = saletype And
                                        cli-gds.cli-code = salecode )  then "    ЭТО РЕАЛИЗАЦИЯ !!!" else ""     , num#str# , num#col#  ).
                    num#col# = new-n(27). run macr_excel_dec  in this-procedure (v-pr-rubl                       , num#str# , num#col#  ).
                    num#col# = new-n(28). run macr_excel_char in this-procedure (ub.cli-gds.cli-type             , num#str# , num#col#  ).
                    num#col# = new-n(29). run macr_excel_dec  in this-procedure (ub.cli-gds.cli-code             , num#str# , num#col#  ).
                    num#col# = new-n(30). run macr_excel_char_with_format in this-procedure (ub.cli-gds.cli-art  , num#str# , num#col#  ).
                    num#col# = new-n(31). run macr_excel_char in this-procedure ((If ig = 1 Then  "*" Else "")   , num#str# , num#col#  ).
                    num#str# = num#str# + 1 .
      end.
    end.
 end.
end. /*else do */
end. /* do */
end procedure. /* spis-post */


procedure head-post :
 do
 on error undo, return error return-value
 :

/* по заявкам поставщиков не выбираем */
if G#type <> {&o-f} then do:
    num#col# = new-n(26). run macr_excel_char_with_format in this-procedure ("Поставщики"        , num#str# , num#col#  ).
    put  stream macr_excel unformatted  (if print-col-26 then 'COLUMN.WIDTH(30,,,,)' else 'COLUMN.WIDTH(0,,,,)')  skip.
    num#col# = new-n(27). run macr_excel_char_with_format in this-procedure ("Цены  поставщиков" , num#str# , num#col#  ).
    if not print-col-27 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
    num#col# = new-n(28). run macr_excel_char_with_format in this-procedure ("Тип"               , num#str# , num#col#  ).
    put  stream macr_excel unformatted  (if print-col-28 then 'COLUMN.WIDTH(4,,,,)' else 'COLUMN.WIDTH(0,,,,)')  skip.
    num#col# = new-n(29). run macr_excel_char_with_format in this-procedure ("Код"               , num#str# , num#col#  ).
    if not print-col-29 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
    num#col# = new-n(30). run macr_excel_char_with_format in this-procedure ("Артикул поставщика", num#str# , num#col#  ).
    if not print-col-30 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
    num#col# = new-n(31). run macr_excel_char_with_format in this-procedure ("Выбор поставщика"  , num#str# , num#col#  ).
    if not print-col-31 then put  stream macr_excel unformatted  'COLUMN.WIDTH(0,,,,)'  skip.
        /* красный с белым */
        put  stream macr_excel unformatted
            substitute('patterns(1,,&1,true)', 3 ) + {&new-line}  .
        put  stream macr_excel unformatted
            substitute('format.font(,,,,,,&1)' , 2 ) + {&new-line} .
end.

if G#type = {&o-f} then do:
    num#col# = new-n(26). run macr_excel_char_with_format in this-procedure ("Фирма" , num#str# , num#col#  ).
    put  stream macr_excel unformatted  (if print-col-26 then 'COLUMN.WIDTH(30,,,,)' else 'COLUMN.WIDTH(0,,,,)')  skip.
    num#col# = new-n(27). run macr_excel_char_with_format in this-procedure ("Тип"   , num#str# , num#col#  ).
    put  stream macr_excel unformatted  (if print-col-27 then 'COLUMN.WIDTH(4,,,,)' else 'COLUMN.WIDTH(0,,,,)')  skip.
    num#col# = new-n(29). run macr_excel_char_with_format in this-procedure ("Код"   , num#str# , num#col#  ).
    num#col# = new-n(31). run macr_excel_char_with_format in this-procedure ("Выбор строки (будем заказывать - * )"  , num#str# , num#col#  ).
end.
end. /* do */
end procedure. /* head-post */