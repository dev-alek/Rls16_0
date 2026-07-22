/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для макроса EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 09/03/02 6:23

{1}  - имя потока в который выводится отчет для macro-excel .

FORMAT.FONT(name_text, size_num, bold, italic, underline, strike, color, outline, shadow)

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{1}" = "" &then
{ cmp/r-page1.i  }
{ rep/f-fdec.i   }
define stream  macr_excel .
&endif
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + {&new-line}  .



 end. /* do */
end procedure. /* macr_exel_char */

procedure macr_excel_char_with_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + {&new-line} .
    put stream macr_excel unformatted 'format.number("@")' + {&new-line} .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + {&new-line}  .



 end. /* do */
end procedure. /* macr_exel_char */

procedure macr_excel_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val    as character no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-format as character no-undo .

 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + {&new-line} .
    put stream macr_excel unformatted substitute('format.number("&1")', p-format) + {&new-line} .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + {&new-line}  .
 end. /* do */
end procedure. /* macr_excel_cell_format */

procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row as integer no-undo .  /* сумма */
 define input parameter  p-col as integer no-undo .
 define input parameter  p-row1 as integer no-undo . /* суммировать с */
 define input parameter  p-col1 as integer no-undo .
 define input parameter  p-row2 as integer no-undo . /* по */
 define input parameter  p-col2 as integer no-undo .

    put stream macr_excel unformatted
          substitute('formula("=sum(r&3c&4:r&5c&6)","r&1c&2")', p-row , p-col , p-row1 , p-col1 ,p-row2 , p-col2 ) + {&new-line}  .



 end. /* do */
end procedure. /* macr_exel_char */


procedure macr_excel_dec :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
  if p-val = ? then p-val =  "" .
   put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val )  + {&new-line} .

 end. /* do */
end procedure. /* macr_exel_char */


procedure macr_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) + {&new-line} .

  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color ) + {&new-line}  .
  end.
  put  stream macr_excel unformatted


       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) + {&new-line} .
 end. /* do */
end procedure. /* macr_pattern */


procedure macr_cell_size :
 do
 on error undo, return error return-value
 :
 define input parameter  p-w   as integer   no-undo . /* ширина*/
 define input parameter  p-l   as integer   no-undo . /* длина */
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  if p-w = ? then    p-w = 0 .
  if p-l = ? then    p-l = 0 .

 define variable s-w as character no-undo .
 define variable s-l as character no-undo .

 if p-w = 0 then s-w = "" .
            else s-w = string(p-w)  .
 if p-l = 0 then s-l = "" .
            else s-l = string(p-l)  .

put  stream macr_excel unformatted
     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted
     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted
     'FORMAT.TEXT(2,2,0,,,,,)'  skip.

 end. /* do */

end procedure. /* macr_pattern */

procedure proc-print-header :
 do
 on error undo, return error return-value
 :
/* Шапка */
   find first sheetf .
     sheetf.excel-row-heder =  num-entries( c-str ,{&new-line}) + 1.
     sheetf.excel-row-title =  num-entries( sheetf.excel-column-lable , {&new-line} ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .

     p-var = num-entries( entry (c-c, sheetf.excel-column-lable, {&new-line}) , {&comma-char} ) .

     do c-i = 1 to p-var :
        str--1 = entry( c-i, entry (c-c,sheetf.excel-column-lable, {&new-line}) , {&comma-char}) .
        str--2 = integer(entry( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char_with_format ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.

    c-i = 0.
    end.

    run macr_cell_format (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        35       , /*p-color-bg  */
        var-1 + 1, /*p-row       */
        1        , /*p-col       */
        num#str# , /*p-row-2     */
        num#col# ) /*p-col-2     */
        .

/* Надо найти склеивание колонок */

  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + {&new-line}  +
       /* 'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} + */
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .


 end. /* do */
end procedure. /* proc-print-header */

procedure end-proc :
 do
 on error undo, return error return-value
 :

  v-file-name = ( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".t-t").

  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.

 end. /* do */
end procedure. /* end-proc */


/* $Workfile$ e n d */