block-level on error undo, throw.
/*

$Revision: b187afc25aab, 810, rls $
$Author: ASMorozov $
$Date: Mon Sep 26 12:45:42 2016 +0300 $
$Workfile: egais-initFormF1.p $
$Archive: utl/egais-initFormF1.p $

Утилита создание справок 1 на основе накладных

  Author: 
    Автор: Морозов Александр Сергеевич
    Дата создания: 11/08/16
    Author: Alexandr Morozov
    Creation date: 11/08/16

*/


using ibs.th.bge.egais.*.

{cmp/str-glbl.i}
{ibs/th/bge/egais/wb-egais.i}
{ gbl/thbjattr.i }

define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.

define variable extFormF1Obj        as class ExtFormF1         no-undo.
define variable parserWBObj      as class ParserXMLDocWB no-undo.

define variable v-objCode         as integer   no-undo.
define variable ii                as integer   no-undo.
define variable v-objType         as character no-undo.
define variable v-FormF1-code     as character no-undo.
define variable v-alc-code        as character no-undo.
define variable hDoc              as handle    no-undo.


define stream out.

output stream out to formF1.txt.

{ gbl/waitfram.i }

do:
  
  run waitfram-show in this-procedure
  (input substitute("Идет создание справок 1")
  ) .
  
  extFormF1Obj = new extFormF1 (true).
  
  parserWBObj = new ParserXMLDocWB (extFormF1Obj:ExtSystem).
  
  for each buf_clob-bind no-lock where buf_clob-bind.resource-type = {&lob-egais-wb}:
    
    find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
    run createhDoc(recid (buf_clob-data), "utl-egais-wb-temp.xml", output hDoc).
    if error-status:error
      then next.
    
    parserWBObj:ParseRec(hDoc, ?, input-output table tt-wb-header, input-output table tt-wb-gds-EG, input-output table tt-wb-info-client).
    
    find first tt-wb-header.
    
    for each tt-wb-gds-EG:
      
      if (tt-wb-gds-EG.importer-list <> "" and tt-wb-gds-EG.importer-list <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)) or entry (7, tt-wb-gds-EG.prod-list, chr(5)) = 'FO' 
      then do:
        do trans:
          if extFormF1Obj:CreateExtFormF1(tt-wb-gds-EG.refA, tt-wb-gds-EG.alc-code) 
          then do:
            put stream out unformatted substitute ("Создана запись: &1/&2 на основе накладной &3 от &4", tt-wb-gds-EG.refA, tt-wb-gds-EG.alc-code, tt-wb-header.num, tt-wb-header.wb-date) {&new-line}.
            ii = ii + 1.
          end.
        end.
      
      end.
    end.
    
  end.
  
  message "Завершено. Добавлено справок 1 - " ii " См. лог - " search ('formF1.txt')  view-as alert-box.
  
  run waitfram-hide in this-procedure .
  
end.


procedure createhDoc:

  define input parameter inRecCD as recid no-undo. 
  define input parameter inFileName as char no-undo. 
  define output parameter outhDoc as handle no-undo.

  define buffer buf_cd for ub.clob-data.
    
  find first buf_cd where recid (buf_cd) = inRecCD no-lock no-error.
  if not available (buf_cd) 
   then return error.
  
  copy-lob
    from  object buf_cd.cdata
    to  file inFileName
    no-convert
    no-error .
    
  create x-document outhDoc.
  outhDoc:encoding = 'utf-8'.
  outhDoc:load("file", search (inFileName), false).
    
  release buf_cd.

end.


