block-level on error undo, throw.
/*

$Revision: 5f39998a998b, 782, rls $
$Author: EShklyar $
$Date: Wed Sep 14 12:28:21 2016 +0300 $
$Workfile: egais-gds-synch.p $
$Archive: utl/egais-gds-synch.p $

Утилита заполнения инфо по егаис товарам из раенне полученных накладных

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

define variable extGdsObj        as class ExtGds         no-undo.
define variable extGdsValueObj   as class ExtGdsValue    no-undo.
define variable extGdsValueWBObj as class ExtGdsValue    no-undo.
define variable parserWBObj      as class ParserXMLDocWB no-undo.

define variable v-objCode         as integer   no-undo.
define variable ii                as integer   no-undo.
define variable v-objType         as character no-undo.
define variable v-gds-code        as integer   no-undo.
define variable v-alc-code        as character no-undo.
define variable hDoc              as handle    no-undo.
define variable bh-egais-goods    as handle    no-undo.
define variable qh-egais-goods    as handle    no-undo.

define stream out.

output stream out to gds-fix.txt.

{ gbl/waitfram.i }

do:
  
  run waitfram-show in this-procedure
  (input substitute("Идет проверка и исправление доп. информации по товарам                на основе накладных")
  ) .
  
  extGdsObj = new ExtGds (true).
  
  parserWBObj = new ParserXMLDocWB (extGdsObj:ExtSystem).
  
  extGdsObj:GetHndlTable(0, "", input-output bh-egais-goods).
  create query qh-egais-goods.
  qh-egais-goods:set-buffers (bh-egais-goods).
  
  for each buf_clob-bind where buf_clob-bind.resource-type = {&lob-egais-wb}:
    
    find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
    run createhDoc(recid (buf_clob-data), "utl-egais-gds-synch.xml", output hDoc).
    
    parserWBObj:ParseRec(hDoc, ?, input-output table tt-wb-header, input-output table tt-wb-gds-EG, input-output table tt-wb-info-client).

    for each tt-wb-gds-EG:
      qh-egais-goods:query-prepare ("for each tt-egaisgds-hndls where ColorNum <> ? and alcCode = '" + tt-wb-gds-EG.alc-code + "'").
      qh-egais-goods:query-open.
      extGdsValueWBObj = extGdsObj:GetInfoObj(tt-wb-gds-EG.prod-list + chr (4) + tt-wb-gds-EG.importer-list + chr (4) + tt-wb-gds-EG.gds-name).
      if extGdsValueWBObj:INNImpor = "" and extGdsValueWBObj:INNProd = ""
      then do:
        next.
      end.
      do while qh-egais-goods:get-next ():
        v-gds-code = bh-egais-goods:buffer-field ("gdsCode"):buffer-value.
        v-alc-code = bh-egais-goods:buffer-field ("alcCode"):buffer-value.
        extGdsObj:OpenQueryExtGds(v-gds-code, v-alc-code).
        extGdsValueObj = extGdsObj:GetExtGdsValue().
        extGdsObj:CopyEgaisInfo (extGdsValueWBObj, extGdsValueObj).
        extGdsObj:SaveEGAISInfo (extGdsValueObj).
        bh-egais-goods:buffer-field ("ColorNum"):buffer-value = ?.
        ii = ii + 1.
        export stream out v-gds-code v-alc-code.
      end.
      qh-egais-goods:query-close.
      delete object extGdsValueWBObj.
    end.
    
    qh-egais-goods:query-prepare ("for each tt-egaisgds-hndls where ColorNum <> ?").
    qh-egais-goods:query-open.
  
    if not qh-egais-goods:get-first
    then do:
      qh-egais-goods:query-close.
      leave.
    end.

    qh-egais-goods:query-close.
    
  end.
  
  message "Завершено. Исправлено - " ii " См. лог - " search ('gds-fix.txt')  view-as alert-box.
  
  run waitfram-hide in this-procedure .
  
end.


procedure createhDoc:

  define input parameter inRecCD as recid no-undo. 
  define input parameter inFileName as char no-undo. 
  define output parameter outhDoc as handle no-undo.

  define buffer buf_cd for ub.clob-data.
    
  find first buf_cd where recid (buf_cd) = inRecCD no-lock.
    
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


