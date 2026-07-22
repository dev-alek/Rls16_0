/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: r-print-marks.p $
$Archive: rep/r-print-marks.p $

Печать датаматриксов по излишкам

Автор: Шкляр Елена
Дата создания: 10/06/06
Author: Elena Shklyar
Creation date: 10/06/06



*/
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.
define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-rec-invent  as recid         no-undo .


define variable vss-revision    as character no-undo initial "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
define variable vss-date        as character no-undo initial "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-print-marks.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-print-marks.p $":U .
define variable vss-description as character no-undo initial "Печать датаматриксов по излишкам":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-calc.i }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ str/is-sug.i }
{ str/placelib.i }

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#log         as logical no-undo .

{ gbl/paramls.i  }

define variable v-host-name as character no-undo .
define variable p-host-code as integer   no-undo .
define variable v-doc-num   as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .

define variable v-value-character   as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-param-type        as character no-undo .
define variable v-tth               as handle    no-undo .
define variable jj                  as integer   no-undo .
def    var      Marking             as class     mark no-undo .
{ gbl/objsrv.i }
Marking = ObjSrv:Env:Marking:Sts:Mark .

FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer)  FORWARD.
  
define temp-table tt-marks
  field mark       as character
  field mark-name  as character
  field mark-level as character
  field ii         as integer 
  field datamatrix as character
  field mrc        as character
  field unit       as character 
  index pi mark .


define buffer bf_trn-doc        for ub.trn-doc  .
define buffer bf_goods          for ub.goods    .
define buffer bf_object         for ub.clients  .
define buffer bf_doc-line       for ub.doc-line.
define buffer buf_marking       for ub.marking .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_parts         for ub.parts .
define buffer buf_marking-attr  for ub.marking-attr .


run WaitFram-Show in this-procedure
  ( input 'Идет формирование отчета, ждите...'
  ) .
run get-report-num  in p-parent-proc
  (
  output g#report-num
  ) .
run get-quest-print in p-parent-proc
  (
  output g#quest-print
  ) .
find first bf_trn-doc no-lock where
  recid( bf_trn-doc ) = p-rec-invent no-error .
if not available bf_trn-doc
  then 
do:
  run waitfram-hide in this-procedure .
  message substitute( 'Не найден документ с идентификатором &1.'
    , p-rec-invent
    )
    view-as alert-box error .
  undo, return error .
end.
if bf_trn-doc.doc-type     <> {&inventory} or
  bf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
  then 
do:
  run waitfram-hide in this-procedure .
  message
    'Данная форма только для печати инвентаризации.'
    view-as alert-box error .
  undo, return error .
end.

{gbl/base64.i}
define variable qr-code     as character no-undo.
define variable qr-code-out as character no-undo.
define variable v-arc       as character no-undo .
define variable v-cmd       as character no-undo .
    
jj = 0 .

for each bf_doc-line no-lock where bf_doc-line.doc-code = bf_trn-doc.doc-code:
  find first bf_goods no-lock where bf_goods.artic = bf_doc-line.artic and bf_goods.prod-code = bf_doc-line.prod-code and 
    bf_goods.prod-type = bf_doc-line.prod-type no-error .
  if available (bf_goods) then 
  do:
    for each buf_marking-lines no-lock where buf_marking-lines.gds-code = bf_goods.gds-code and buf_marking-lines.out-code = {&free-code},
    first buf_marking no-lock where buf_marking.sts = Marking:FreeZone:KeyIntDB:
        
      find first buf_marking-attr no-lock where buf_marking-attr.mark = buf_marking-lines.mark and buf_marking-attr.attr-code begins "inv-doc" no-error .
      if available (buf_marking-attr) then do:
        next .
      end.
      create tt-marks .
      assign
        tt-marks.ii         = jj + 1
        tt-marks.mark       = buf_marking-lines.mark
        .
        find first ub.marking-attr no-lock where ub.marking-attr.attr-code = "MRC" and ub.marking-attr.mark = buf_marking-lines.mark no-error .
        if available (ub.marking-attr) then tt-marks.mrc = ub.marking-attr.attr-value .
        if buf_marking.mark-parent <> "" then do:
          if tt-marks.mrc <> "" then do:
            tt-marks.datamatrix = buf_marking-lines.mark + "x3R:iv+8005" + string(tt-marks.mrc,"999999") + "93xVn+24010089720" .
          end.  
          else do:
            tt-marks.datamatrix = buf_marking-lines.mark + "x3R:iv+8005173000" + "93xVn+24010089720" .
          end.  
        end.  
        else tt-marks.datamatrix = buf_marking-lines.mark + "8?0DthAAB68eFj3" .
        if buf_marking.unit-ext <> "UNIT" then tt-marks.unit = bf_goods.unit-cli .
        else tt-marks.unit = bf_goods.unit-base .
        
        tt-marks.mark-name  = GdsName(buf_marking-lines.gds-code) .
  
      assign
        v-arc = search( "exe/qrgen.exe":U )
        .
      if v-arc = ? then 
      do:
        return error "Не найдена программа qrgen.exe" .
      end.   
      os-command silent value (v-arc + ' -size=128 -content="' + tt-marks.datamatrix + '"' + ' -filename="c:\temp\qr-code"' + string(tt-marks.ii)) .
      tt-marks.mark-level = "c:\temp\qr-code" + string(tt-marks.ii) + ".png" .
    
      jj = jj + 1 .
    end.  
  end. 
end.

/*печать*/
run get-report-num (output p-report-id).
    
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
put stream OutStr-html unformatted
  "<!DOCTYPE HTML>" skip
  ' <html>' skip
  '  <head>' skip
  '   <meta charset="utf-8">' skip
  '    <style type="text/css">' skip
                        
  '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
  '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
  '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
  '   </style>' skip
  '  </head>' skip
  .
put stream OutStr-html unformatted
  '<body>' skip
  '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
  '<thead>' skip
  .
put stream OutStr-html unformatted
  '<tr>' skip
  '<td style="width: 10px;"></td>' skip
  '<td style="width: 30px;"></td>' skip
  '<td style="width: 50px;"></td>' skip
  '<td style="width: 20px;"></td>' skip
  '<td style="width: 20px;"></td>' skip
  '<td style="width: 50px;"></td>' skip
  '</tr>'
  '<TR><TD colspan = "6" style="height: 14px;"></TD></TR>' skip
  '<TR><TD colspan = "6" style="text-align: center;">Печать датаматриксов по излишкам</TD></TR>' skip
  '<TR><TD colspan = "6" style="text-align: center;">№: ' + string(bf_trn-doc.doc-code) + '</TD></TR>' skip
  '</Thead>' skip
  '<tbody>' skip
  .  
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold;">№</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Наименование товара</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Датаматрикс</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold;">МРЦ</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Ед.изм.</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold;">QR код</TD>' skip
  '</TR>'skip       
  .
for each tt-marks no-lock by tt-marks.ii:
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(tt-marks.ii) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: left;">' + string(tt-marks.mark-name) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string (tt-marks.mark) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string (tt-marks.mrc) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string (tt-marks.unit) + '</TD>' skip
    .
  if search(tt-marks.mark-level) <> ? then 
  do:  
    put stream OutStr-html unformatted  
      '<TD text_wrap="true" style="text-align: center;"><img src="' + string(tt-marks.mark-level)+ '" width="130" height="130" alt=""/></TD>' skip
      .
  end.
  else 
  do:
    put stream OutStr-html unformatted  
      '<TD text_wrap="true" style="text-align: center;"></TD>' skip
      .

  end.  
  put stream OutStr-html unformatted        
    '</TR>'.  
end.

        
put stream OutStr-html unformatted
  '</tbody>' skip
  '</table>' skip
  '</body>' skip
  '</html>' skip
  .
output stream OutStr-html close.     
                                                                                                                
run prn-lib-reportviewer-report-name in this-procedure (
  input THIS-PROCEDURE
  ,input v-file-name-rep-htm
  ).
                



PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/
  define variable v-gds-name as character no-undo .
  define buffer buf_goods for ub.goods .
  
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if available (buf_goods) then v-gds-name = buf_goods.gds-name .
  RETURN v-gds-name.   /* Function return value. */

END FUNCTION.                                     