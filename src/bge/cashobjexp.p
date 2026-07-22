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
define temp-table tt-code no-undo serialize-name "code" like ub.code.
run waitfram-show ("Ждите...") .
find first sys-ctrl no-lock.
define variable v-sys-key as character no-undo.
{ gbl/currsysk.i
    v-sys-key
    no-error
  }
for each b-clients where b-clients.obj-type eq {&cmp} no-lock:
   for first ub.sysconf no-lock where ub.sysconf.host-code = b-clients.obj-code:
      create tt-code.
      assign
         tt-code.parent    = "CashObj"
         tt-code.code      = v-sys-key
         tt-code.CodeName  = b-clients.obj-name
         tt-code.export_   = true
      .
   end.
end.
if available tt-code
then do:
   define variable mparent1 as character no-undo.
   mparent1 = substitute ("CashObj&1&2",{&delim-par},v-sys-key).
   for each b-clients where b-clients.obj-type = {&shop} no-lock:
      create tt-code.
      assign
         tt-code.parent   = mparent1
         tt-code.code     = string(b-clients.obj-code)
         tt-code.CodeName = b-clients.obj-name
         tt-code.export_  = true
      . 
      define variable mparent2 as character no-undo.
      mparent2 = substitute ("&2&1&3",{&delim-par},mparent1,tt-code.code).
      for each b-cash-desk where b-cash-desk.db-num   = b-clients.db-num
                         and     b-cash-desk.obj-code = b-clients.obj-code 
                         and not b-cash-desk.is-del
      no-lock:      
         create tt-code.
         assign
            tt-code.parent   = mparent2
            tt-code.code     = string(b-cash-desk.cash-num)
            tt-code.export_  = true
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
    default-extension "pdf"
    .

if ll_commit <> yes then return.
m_os-dir = trim(m_os-dir).
if index(m_os-dir," ") > 0
then do:
  return error "Файл и деректория не могут содержать пробел" .
end.
define variable exlim as class ibs.th.bge.xmlimpexp no-undo.
exlim = new ibs.th.bge.xmlimpexp ().
m_os-dir = replace(m_os-dir,".xls",".").
exlim:updatetableforxml(temp-table tt-code:handle).
exlim:xmldom-save      ( m_os-dir ).
delete object exlim.
run waitfram-hide .
define variable mfile           as character no-undo.
define variable mfileNew        as character no-undo.
define variable v-md5-signature as character no-undo.
define stream sOut.
mfile = SearchFile(m_os-dir).
if mfile eq ?
then
   return error "что-то пошло совсем не так".
else do:
   mfileNew = mFile.
   entry(num-entries(mFile,"."),mFile,".")= "xml".
   entry(num-entries(mfileNew,"."),mfileNew,".")= "md5".
   run gbl/md5.p(mfile,output v-md5-signature).
        
   output stream sOut to value(mfileNew).
   put stream sOut unformatted string({utl/chekmd5.i v-md5-signature })  skip.
   output stream sOut close.
         
   mfileNew = SearchFile(mfileNew).
   if mfileNew eq ?
   then
      message "Выгрузка сохранена в файл " mfile
         view-as alert-box.
   else
      message "Выгружены файлы " skip mfile skip mfileNew
         view-as alert-box.   
end.      
      
      