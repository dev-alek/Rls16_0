/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 февр. 2023 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 февр. 2023 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ utl/search.i }
define buffer code        for ub.code.
define buffer b-clients   for ub.clients.
define buffer b-cash-desk for ub.cash-desk.
define buffer sys-ctrl    for ub.sys-ctrl. 
{ cmp/str-glbl.i}
{ gbl/waitfram.i }
{ cmp/library.i }
run waitfram-show ("Ждите...") .
find first sys-ctrl no-lock.
define variable v-sys-key as character no-undo.
{ gbl/currsysk.i
    v-sys-key
    no-error
  }
define temp-table tt-region no-undo serialize-name "region"
    field code as char
    field name as char
    index code code.
define temp-table tt-objects no-undo serialize-name "objects"
    field code as character serialize-hidden 
    index code code.  
define temp-table tt-object no-undo serialize-name "object"
    field region-code as character serialize-hidden 
    field code as int
    field name as char
    index code region-code code.
define temp-table tt-cashs no-undo serialize-name "cashs"
    field region-code as character serialize-hidden 
    field code as int serialize-hidden
    index code region-code code.  
define temp-table tt-cash no-undo serialize-name "cash"
    field region-code as character serialize-hidden 
    field obj-code as int serialize-hidden
    field num as int
    index code region-code obj-code.
define dataset ds-region serialize-name "regions"
      
for tt-region
  , tt-objects
  , tt-object
  , tt-cashs
  , tt-cash
  data-relation objects     for tt-region, tt-objects    relation-fields (code, code) nested
  data-relation object      for tt-objects, tt-object     relation-fields (code, region-code) nested 
  data-relation cashs for tt-object, tt-cashs    relation-fields (region-code, region-code,code,code) nested
  data-relation cash  for tt-cashs, tt-cash    relation-fields (region-code, region-code,code,obj-code) nested
  .
  
for each b-clients where b-clients.obj-type eq {&cmp} no-lock:
   for first ub.sysconf no-lock where ub.sysconf.host-code = b-clients.obj-code:
      create tt-region.
      assign
         tt-region.code  = v-sys-key
         tt-region.name  = b-clients.obj-name
      .
      create tt-objects.
      tt-objects.code = v-sys-key.
   end.
end.
if available tt-region
then do:
   for each b-clients where b-clients.obj-type = {&shop} no-lock:
      define variable flag as logical no-undo.
      flag = no.
      for each b-cash-desk where b-cash-desk.db-num   = b-clients.db-num
                         and     b-cash-desk.obj-code = b-clients.obj-code 
                         and not b-cash-desk.is-del
      no-lock:
         flag = yes.
         create tt-cash.
         assign
            tt-cash.region-code   = v-sys-key
            tt-cash.obj-code      = b-clients.obj-code
            tt-cash.num          = b-cash-desk.cash-num
         .      
     end.
      if flag
      then do:
         create tt-object.
         assign
            tt-object.region-code   = v-sys-key
            tt-object.code          = b-clients.obj-code
            tt-object.Name          = b-clients.obj-name
         . 
      
         create tt-cashs.
         assign
            tt-cashs.region-code   = v-sys-key
            tt-cashs.code          = b-clients.obj-code
         .
      end.
   end.
end.
define variable m_os-dir   as char no-undo init "":U.
define variable ll_commit as log    no-undo init no.

m_os-dir = v-sys-key + ".xml".
SYSTEM-DIALOG GET-FILE m_os-dir
    TITLE "Сохранить как"
    FILTERS
      " Файл XML(*.xls) " "*.xls",
      " Все файлы (*.*) " "*.*"
    
    ask-overwrite
    save-as
    use-filename
    update ll_commit
    default-extension "xml"
    .

if ll_commit <> yes then return.
m_os-dir = trim(m_os-dir).
if index(m_os-dir," ") > 0
then do:
  return error "Файл и директория не могут содержать пробел" .
end.
define variable exlim as class ibs.th.bge.xmlimpexp no-undo.
exlim = new ibs.th.bge.xmlimpexp ().
m_os-dir = replace(m_os-dir,".xls",".").

dataset ds-region:handle:WRITE-XML("file",m_os-dir, true, "utf-8", ?, false, true ,false,false).
run waitfram-hide .

define variable mfile           as character no-undo.
mfile = SearchFile(m_os-dir).
if mfile eq ?
then
   return error "что-то пошло совсем не так".
else do:
   message "Выгрузка сохранена в файл " mfile
         view-as alert-box.
      
end.      
      
      