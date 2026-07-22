block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prclose.p $
$Archive: utl/prclose.p $

Утилита Закрытие всех новых переоценок по всем неудаленным объектам.

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 12/14/01 10:43

*/
define input  parameter parParentProc as handle  no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prclose.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/prclose.p $":U .
define variable vss-description as character no-undo init " Закрытие всех новых переоценок по всем неудаленным объектам.   ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/lib-log.i }


define variable p-log-handle as handle  no-undo .
{ gbl/get-lgh.i  p-log-handle }

define buffer buf_db        for ub.db .
define buffer buf_clients   for ub.clients .
define buffer buf_sys-ctrl  for ub.sys-ctrl .
define buffer buf-price-doc for ub.price-doc.
define buffer buf-shift-obj for ub.shift-obj.

MESSAGE
  "Вы уверены, что хотите начать работу утилиты ?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE " Закрытие всех новых переоценок" UPDATE answer AS LOG.
IF answer <> YES THEN RETURN.

/* обработать все неудаленные объекты */
find first buf_sys-ctrl no-lock no-error .
  for each buf_db no-lock where buf_db.db-num = buf_sys-ctrl.db-num  ,
   each buf_clients no-lock  where buf_clients.db-num = buf_db.db-num
                               and buf_clients.stts = 0 ,
   each buf-price-doc no-lock where  buf-price-doc.obj-code = buf_clients.obj-code
                                 and buf-price-doc.obj-type = buf_clients.obj-type
                                 and buf-price-doc.status_ =  {&g___new}
                                    on error undo, return error  :
        if can-find (first buf-shift-obj   where     buf-shift-obj.obj-code = buf_clients.obj-code
                                                and buf-shift-obj.obj-type = buf_clients.obj-type no-lock )
        Then message "На объекте " buf_clients.obj-type buf_clients.obj-code  " есть смены . Автоматически закрыть до состояния АКТ нельзя, закройте документ переоценки № "
                     buf-price-doc.doc-num  " в ручную!" .
        Else
          run str/pr-stat.p (  input parParentProc
                             , input p-log-handle
                             , input "close-act"
                             , input buf-price-doc.doc-num
                             , input ?
                             , input true
                             , input true ) no-error .
  end.
 Message "Процесс закрытия переоценок по базе данных № " buf_sys-ctrl.db-num " завершен !" view-as alert-box information .

/* $Workfile: prclose.p $ e n d */