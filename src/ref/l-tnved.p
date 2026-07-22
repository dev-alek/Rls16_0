block-level on error undo, throw.
/*

$Revision: e374adcb297c, 1109, rls $
$Author: PGridchina $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: l-tnved.p $
$Archive: ref/l-tnved.p $

Загрузка справочника ТНВЭД

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

define input parameter f-name as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: e374adcb297c, 1109, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: l-tnved.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/l-tnved.p $":U .
define variable vss-description as character no-undo init "Загрузка справочника ТНВЭД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/t-tnved.i  }
{ gbl/waitfram.i }

do
on error undo, return error return-value
:
  define variable varTemp as character no-undo.
  define variable glog as logical no-undo .
  if f-name = '' or f-name = ? then f-name = "cmp/tnved4.txt".
  if f-name = ""
  or search(f-name) = ?
  then do:
    if f-name <> ""
    then do:
      message
      substitute("Не найден файл &1 справочника ТНВЭД СНГ.&2" +
                 "Проверьте значение параметра &3 секции &4 ini-файла"
                 , f-name
                 ,{&new-line}
                 ,"rep-tnved"
                 ,"custom")
      view-as alert-box information .
    end.

    system-dialog get-file f-name
      title "Выберите файл cо справочником ТНВЭД СНГ"
      filters "Файлы групп товаров *.txt" "*.txt",
                "Все файлы  *.*" "*.*"
      initial-dir "."
      return-to-start-dir
      must-exist
      update glog
      default-extension "txt".
    if not glog then do:
      return.
    end.
  end.

  run waitfram-show in this-procedure
    (input "Загрузка справочника ТНВЕД"
    ) .

  input from value (search(f-name)).
  g-i:
  do
  transaction on error undo, return
  :
    repeat
    :
      import unformatted varTemp no-error .
      if error-status :error
      then do:
        message "Ошибка при загрузке справочника ТНВЭД СНГ.".
        undo g-i, return.
      end.
      if lookup(substring(vartemp, 1, 1), "0,1,2,3,4,5,6,7,8,9") = 0
      then do:
        next. /* --->>>--- */
      end.
      create tt-tnved .
      assign
        tt-tnved.tnved  = trim(entry(1, vartemp, chr(9)))
                        + trim(entry(2, vartemp, chr(9)))
                        + trim(entry(3, vartemp, chr(9)))
        tt-tnved.f-name = trim(trim(entry(4, vartemp, chr(9))), "~"")
      .
    end.
  end.
  input close.

  /* Удалим пустые строки */
  for each tt-tnved
    where trim(tt-tnved.tnved)  = ""
      and trim(tt-tnved.f-name) = ""
  :
    delete tt-tnved .
  end.

  run waitfram-hide in this-procedure .
end.
