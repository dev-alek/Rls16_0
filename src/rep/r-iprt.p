block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-iprt.p $
$Archive: rep/r-iprt.p $

История одного признака

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 09/08/03 12:55

*/
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-iprt.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-iprt.p $":U .
def var vss-description as character no-undo init "История одного признака".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i      }
{ cmp/r-pril.i  NEW  }
{ gbl/cur-time.i     }
{ rep/repfrm.i def   }
{ rep/f-fdec.i       }
{ gbl/paramls.i      }
{ rep/rep-bt.i       }
define input parameter x-par as character no-undo .
define variable p-gds-code like goods.gds-code no-undo .
define variable p-b-code      like bar-code.b-code no-undo .
define variable p-node-code   like bar-code.b-code no-undo .

define buffer buf_goods for goods .
define buffer buf_bar-code for bar-code .
define buffer buf_gds-prt  for gds-prt .


define variable max-col as integer no-undo .
max-col = 32.
define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define variable kol-obj as integer no-undo .

define stream  instream  .
define stream  outstream  .

make-excel-com = false .
make-excel     = true  .

define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x ( 60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define variable var-3 as integer no-undo .

FUNCTION excel-qnty-null RETURNS char  ( INPUT p-dec as decimal ).
if p-dec = 0 then Return  ( "").
   else RETURN ( format-excel-text ( excel-format-dec-to-char ( Round ( p-dec,3)))) .
END FUNCTION.


do on error undo, return error substitute ( "&1 &2 &3", return-value, error-status:get-message ( 1), error-status:get-message ( 2)):
find first obj-list no-error .
     if not available obj-list then  return error "Не выбран объект".

if num-entries (  x-par,";" ) = 2 then do:
define variable v-str1 as character no-undo .
v-str1 = entry ( 2, ( entry ( 1,x-par,";")),"=").
if entry ( 1, ( entry ( 1,x-par,";")),"=") = "gds-code" then
    assign
        p-gds-code = integer  ( v-str1).
        v-str1 = ""
    .

v-str1 = entry ( 2, ( entry ( 2,x-par,";")),"=").
if entry ( 1, ( entry ( 2,x-par,";")),"=") = "b-code" then
    assign
        p-b-code = integer  ( v-str1).
        v-str1 = ""
    .
end.
else do:
 message vss-workfile vss-revision vss-description skip
         "Не правильно заданы входные параметры "
         num-entries (  x-par,";" ) skip
         x-par
         view-as alert-box error
         .

 return error "Не правильно заданы входные параметры ".
 end.

/*
message    p-gds-code skip
           p-b-code.
*/

define temp-table temp-history no-undo
field doc-code as character
field doc-type as character
field ext-doc-type as character
field fact-date as date
field fact-qnty as decimal
field sale-price as decimal
field fact-order as decimal
field obj-type as character
field obj-code as integer
index pi fact-order doc-code
.

run make-tt.
run print-tt.

end.


procedure make-tt :
 do
 on error undo, return error return-value
 :
find first buf_goods where buf_goods.gds-code = p-gds-code no-lock no-error .
if not available buf_goods then return error .

find first buf_bar-code where buf_bar-code.b-code = p-b-code no-lock no-error .

if not available buf_bar-code then return error .
p-node-code = buf_bar-code.node-code .

find first buf_gds-prt where buf_gds-prt.node-code =  buf_bar-code.node-code no-lock no-error .
if not available buf_gds-prt then return error .
if not buf_gds-prt.is-term  then do:
   message "Это не терминальный признак !" .
   return error .
   end.

 for each price-list where price-list.b-code = p-b-code   no-lock ,
    first price-doc  where price-doc.doc-num = price-list.doc-num and
          price-doc.status_ = {&act-overvalue} and
          price-doc.fact-date >= x-date-start and
          price-doc.fact-date <= x-date-end   and
          price-doc.obj-type   = obj-list.obj-type   and
          price-doc.obj-code   = obj-list.obj-code
          no-lock :
            create temp-history .
            assign
              temp-history.doc-code   =  price-list.doc-num
              temp-history.doc-type   =  {&h-ov}
              temp-history.ext-doc-type   =  {&TDEDT_Overturn}
              temp-history.fact-date  =  price-doc.fact-date
              temp-history.fact-qnty  =  price-list.doc-qnty
              temp-history.sale-price =  price-list.price-sale
              temp-history.fact-order =  price-list.fact-order
              temp-history.obj-type   = price-doc.obj-type
              temp-history.obj-code   = price-doc.obj-code


            .
  end.

 for each gds-dtl where gds-dtl.prt-code  = p-node-code   and
                        gds-dtl.artic     = buf_goods.artic and
                        gds-dtl.prod-type = buf_goods.prod-type  and
                        gds-dtl.prod-code = buf_goods.prod-code
 no-lock ,
    first trn-doc  where trn-doc.doc-code = gds-dtl.doc-code and
          trn-doc.status_ = {&fact} and
          trn-doc.fact-date >= x-date-start and
          trn-doc.fact-date <= x-date-end  and
          trn-doc.obj-type   = obj-list.obj-type   and
          trn-doc.obj-code   = obj-list.obj-code   no-lock :

            create temp-history .
            assign
              temp-history.doc-code   =  gds-dtl.doc-code
              temp-history.doc-type   =  trn-doc.doc-type
              temp-history.ext-doc-type = trn-doc.ext-doc-type
              temp-history.fact-date  =  trn-doc.fact-date
              temp-history.fact-qnty  =  gds-dtl.fact-qnty
              temp-history.sale-price =  gds-dtl.price-rubl
              temp-history.fact-order =  trn-doc.fact-order
              temp-history.obj-type   = trn-doc.obj-type
              temp-history.obj-code   = trn-doc.obj-code
            .
 end.

 end. /* do */
end procedure. /* make-tt */


procedure print-tt :
 do
 on error undo, return error return-value
 :

p-file-name =  string (  session:temp-directory + {&df_name} + string (  g#report-num ) + ".txt" ) .
output stream outstream to value (  string (  session:temp-directory + {&df_name} + string (  g#report-num ) ) )      .

v-ind = 1    .
num#str# = 1 .
num#col# = 1 .

/* создаем временный файл  */
run gbl/_tmpfile.p (  "wb", ".txt", output v-file-name) .
output stream  Macr_Excel to value ( v-file-name) .
v-ind = v-ind + 1 .
num#str# = 0 .

{ rep/repfrm.i on 50  }
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }

/* ШАПКА */
Num#str# = 0 .
Num#col# = 1 .
num#str# = num#str# + 1 . run macr_excel_char_with_format (  "Обороты признака : " + buf_gds-prt.f-name , num#str# , num#col#  ) .
num#str# = num#str# + 1 . run macr_excel_char_with_format (
           " с "  +  string ( x-date-start, "99/99/9999" ) + " по " +  string ( x-date-end , "99/99/9999" ) , num#str# , num#col#  ) .
num#str# = num#str# + 1 . run macr_excel_char_with_format (  " Товар : " +  buf_goods.gds-name , num#str# , num#col#  ) .
num#str# = num#str# + 1 . run macr_excel_char_with_format (  " Объект : " +  obj-list.obj-type + " " + string ( obj-list.obj-code) , num#str# , num#col#) .


 run macr_cell_format
   (  12    ,         /* p-size   */
    true  ,         /* p-bold   */
    false ,         /* p-italic */
    ?     ,         /* p-color  */
    1 ,             /* p-row    */
    1 ,             /* p-col    */
    num#str# ,      /* p-row-2  */
    1        ) .    /* p-col-2  */


    run make-str-1.
    Output stream Macr_Excel  close .
    /*Запишем в файл параметров 1*/
    run paramls-write in this-procedure
       ( input "file"
      ,input "История"
      ,input v-file-name
      ) .

 Output stream Macr_Excel  close .
 Output stream OutStream   close .
  { rep/repfrm.i off}
  run paramls-write in this-procedure
         ( input "charcol"
        ,input ""
        ,input "1,2,3,4"
        ) .

 run end-proc .
 run rep/runexcel.p ( string (  session:temp-directory) + {&DF_Name} + string (  g#report-num ) + ".txt").
 end. /* do */
end procedure. /* print-tt */

{ rep/r-libmcr.i macr_excel         }

procedure make-str-1 :
 do
 on error undo, return error return-value
 :
define variable p-name as character no-undo .
/* по строкам */

/* столбики */
num#col# =  0.
num#str# = num#str# + 1 .
num#col# = num#col# + 1 .

p-name = "Документ" .
run macr_excel_char_with_format (  p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Тип" .
run macr_excel_char_with_format (  p-name , num#str# , num#col#  ).
/*
num#col# = num#col# + 1 .
p-name = "Расш.тип" .
run macr_excel_char_with_format (  p-name , num#str# , num#col#  ).
  */
num#col# = num#col# + 1 .
p-name = "Дата факт" .
run macr_excel_char_with_format (  p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Количество" .
run macr_excel_char_with_format (  p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Цена документа" .
run macr_excel_char_with_format (  p-name , num#str# , num#col#  ).

run macr_cell_format  (
    10    , /*p-size-font */
    true  , /*p-bold      */
    false , /*p-italic    */
    34    , /*p-color-bg  */
    5     , /*p-row       */
    1     , /*p-col       */
    5     , /*p-row-2     */
    6 )     /*p-col-2     */
.

for each temp-history :
    num#col# = 1 .
    num#str# = num#str# + 1 .
    run macr_excel_char_with_format (  temp-history.doc-code,      num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format (  temp-history.doc-type ,     num#str# , num#col#  ). num#col# = num#col# + 1 .
    /* run macr_excel_char_with_format (  temp-history.ext-doc-type , num#str# , num#col#  ). num#col# = num#col# + 1 . */
    run macr_excel_char_with_format (  string ( temp-history.fact-date, "99/99/9999" )  ,  num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec (  temp-history.fact-qnty   , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec (  temp-history.sale-price  , num#str# , num#col#  ). num#col# = num#col# + 1 .
    /*
    run macr_excel_char_with_format (  temp-history.obj-type , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format (  temp-history.obj-code , num#str# , num#col#  ). num#col# = num#col# + 1 .
    */
end.


 end. /* do */
end procedure. /* make-str */