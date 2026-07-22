block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exp-kan2.p $
$Archive: cus/exp-kan2.p $

Экспорт текущих остатков по признакам для Кан_Ру (Поляки)

Автор: Румянцев Юрий Александрович
Дата создания: 09/29/05
Author: Yuri Rumyantsev
Creation date: 09/29/05

Формат
SHOP ID; DATE;INDEX-COLOR-SIZE; QUANTITY
R001;2003-02-13;31.001-AB-101-0034;1
где:
SHOP ID - номер объекта, товарные остатки которого экспортируются с префиксом R,
              если объект имеет тип "магазин" и c префиксом W - для склада;
DATE - дата создания отчета в формате ГГГГ-ММ-ДД;
INDEX-COLOR-SIZE - артикул товара- цвет- размер;
QUANTITY - количество.
Товары с нулевыми остатками не выгружаются.

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-kan2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/exp-kan2.p $":U .
define variable vss-description as character no-undo init "Экспорт текущих остатков по признакам".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cus/exp-kan-mapobj.i }

define stream txt.
define variable file-name as char no-undo.

define variable obj as char no-undo.
define variable simv as char no-undo.
define variable prt-name as char no-undo.
define variable glog as logical no-undo .


glog = no.
message "Экспорт остатков в файл." skip (2)
        "Продолжать ?"
       view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.


system-dialog get-file file-name
  TITLE "Выберите файл для экспорта"
  filters " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "         "*.*"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "txt".


if not glog then return.

if trim(file-name) = "" then do:
     message "Не задан файл для экспорта". pause.
     return.
end.


output stream txt to value (file-name) no-echo.

put stream txt  unformatted
    "SHOP ID;DATE;INDEX-COLOR-SIZE;QUANTITY"
skip.



FIND FIRST sys-ctrl No-LOCK.
FIND FIRST db no-LOCK where
           db.db-num = sys-ctrl.db-num.
for each clients where
    clients.db-num = db.db-num no-lock:

    if clients.obj-type = "маг" then  obj = "R".
    else  obj = "W".



    for each prt-obj no-lock where
                     prt-obj.obj-type  = clients.obj-type
               and prt-obj.obj-code  = clients.obj-code
               and prt-obj.is-term    = yes
               and prt-obj.fact-qnty  <> 0
              use-index pi :

              display
                  prt-obj.obj-type
                  prt-obj.obj-code
                  prt-obj.artic
                with frame ff view-as dialog-box
              title ": Остатки по товарам ".
              pause 0.

              find first mapobj no-lock where mapobj.obj-type = prt-obj.obj-type
                                               and mapobj.obj-code = prt-obj.obj-code no-error.
              if available mapobj then obj = mapobj.kan-code.
              else obj = obj + string(prt-obj.obj-code, "99").

              find gds-prt where gds-prt.node-code = prt-obj.prt-code no-lock no-error.
              if not avail gds-prt then next.


              prt-name = gds-prt.f-name.
              simv  = "-".
              if  r-index(prt-name, "/") > 0 then overlay ( prt-name, r-index(prt-name, "/"), 1) = simv.
              else next.
              put stream txt  unformatted
                  trim(string(obj)) + ";" +
                  trim(string(year(today), "9999")) + "-" +
                  trim(string(month(today), "99")) + "-" +
                  trim(string(DAY(today), "99")) + ";" +
                  trim(string(prt-obj.artic)) + "-" +
                  trim(string(prt-name)) + ";" +
                  trim(string(prt-obj.fact-qnty))
              skip.

    end.  /* for each prt-obj no-lock where  */

end.   /*  for each clients where  */


output close.
message "Экспорт в файл закончен.".