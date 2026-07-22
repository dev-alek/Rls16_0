block-level on error undo, throw.
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

{ bge/cashpartt.i }
{ utl/search.i }
define buffer code for ub.code.
{ cmp/str-glbl.i}
{ gbl/waitfram.i }

run waitfram-show ("Ждите...") .
for each code where Code.parent begins "cash-param"
                and num-entries(Code.parent,{&delim-par}) eq 4
no-lock:
   create tt-cash-param.
   assign
      tt-cash-param.device   = int(entry(2,Code.parent,{&delim-par}))
      tt-cash-param.source   = int(entry(3,Code.parent,{&delim-par}))
      tt-cash-param.section  =     entry(4,Code.parent,{&delim-par})
      tt-cash-param.fparam   = Code.code
      tt-cash-param.fname    = Code.CodeName
      tt-cash-param.fvalue   = Code.CodeValue
      tt-cash-param.fstatus  = Code.status_ + 1
   .
end.
define variable m_os-dir   as char no-undo init "":U.
define variable ll_commit as log    no-undo init no.

SYSTEM-DIALOG GET-FILE m_os-dir
    TITLE "Сохранить как"
    FILTERS
      " Файл HTML(*.xls) " "*.xls",
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
  message "Файл и деректория не могут содержать пробел" 
      view-as alert-box.
  return.
end.
define variable exlim as class ibs.th.bge.execlimpexp no-undo.
exlim = new ibs.th.bge.execlimpexp ().
m_os-dir = replace(m_os-dir,".xls",".").
exlim:expToExcel(temp-table tt-cash-param:handle, m_os-dir + "html").
delete object exlim.
run waitfram-hide .
define variable mfile as character no-undo.
mfile = SearchFile(m_os-dir + "xls").
if mfile eq ?
then
   mfile = SearchFile( m_os-dir + "xlsx").
if mfile eq ?
then do:
   mfile = SearchFile(m_os-dir + "html").
   if mfile eq ?
   then
      message "что-то пошло совсем не так"
      view-as alert-box.
   else
      message "Сформирован промежуточный результат " mfile
      view-as alert-box.
end.
else
   message "Выгрузка сохранена в файл " mfile
      view-as alert-box.   
      
      
      