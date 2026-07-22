block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Информация по имеющимся отложенным заданиям отсылки на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/01/03
Author: Bakhtadze Natalya
Creation date: 07/01/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-interface as logical no-undo.
define input parameter p-run as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация по имеющимся отложенным заданиям отсылки на кассу".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }

define variable v-notes as character no-undo .
define variable v-gds-note as character no-undo .
define variable v-dcard-note as character no-undo .
define variable v-seller-note as character no-undo .
define variable v-cashier-note as character no-undo .
define variable v-fgrp-note as character no-undo .
define variable v-gds as logical no-undo .
define variable v-dcard as logical no-undo .
define variable v-seller as logical no-undo .
define variable v-cashier as logical no-undo .
define variable v-choice as integer no-undo .
define variable v-fgrp as logical no-undo .
define variable v-gds-date as date no-undo init {&end-of-age}.
define variable v-gds-time as integer no-undo  init 86399.


define buffer buf_BatchProcess for ub.batchProcess .
define buffer buf_user-login for ub.user-login .
{ gbl/getcntxt.i get }

find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-gds}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
    find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.

  assign
  v-gds-note = "Самое старое задание на пересылку товара на кассу" + {&new-line} +
               "от" + {&space-char} +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + {&space-char} +
               buf_BatchProcess.BP_SysTime  + {&new-line} +
               "Пользователь" + {&space-char} +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id = " + buf_BatchProcess.User_ID)
  v-gds-date = buf_BatchProcess.BP_SysDate
  v-gds-time = buf_BatchProcess.BP_SysTimeInt
  v-gds = yes
  .
end.
else do:
  assign
  v-gds-note = "Нет отложенных заданий на пересылку товара на кассу"
  .
end.

find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-goa}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
  if buf_BatchProcess.BP_SysDate < v-gds-date
  OR (buf_BatchProcess.BP_SysDate = v-gds-date
  AND buf_BatchProcess.BP_SysTimeInt < v-gds-time) then do:
      find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
    assign
    v-gds-note = "Самое старое задание на пересылку товара на кассу" + {&new-line} +
                "от" + {&space-char} +
                string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + {&space-char} +
                buf_BatchProcess.BP_SysTime  + {&new-line} +
                "Пользователь" + {&space-char} +
                (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id = " + buf_BatchProcess.User_ID)
    .
  end.
  assign
  v-gds = yes
  .
end.

find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-dcard}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
        find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-dcard-note = "Самое старое задание на пересылку информации о клиенте (карте) на кассу" + {&new-line} +
               "от" + {&space-char} +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + {&space-char} +
               buf_BatchProcess.BP_SysTime  + {&new-line} +
               "Пользователь" + {&space-char} +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id = " + buf_BatchProcess.User_ID)
  v-dcard = yes
               .
end.
else do:
  assign
  v-dcard-note = "Нет отложенных заданий на пересылку клиентов (карт) на кассу"
  .
end.

find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-seller}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
        find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-seller-note = "Самое старое задание на пересылку информации о продавце на кассу" + {&new-line} +
               "от" + {&space-char} +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + {&space-char} +
               buf_BatchProcess.BP_SysTime  + {&new-line} +
               "Пользователь" + {&space-char} +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id = " + buf_BatchProcess.User_ID)
               .
  v-seller = yes
               .
end.
else do:
  assign
  v-seller-note = "Нет отложенных заданий на пересылку продавцов на кассу"
  .
end.

find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-cashier}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
        find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-cashier-note = "Самое старое задание на пересылку информации о кассире на кассу" + {&new-line} +
               "от" + {&space-char} +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + {&space-char} +
               buf_BatchProcess.BP_SysTime  + {&new-line} +
               "Пользователь" + {&space-char} +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id =" + buf_BatchProcess.User_ID)
  v-cashier = yes
               .
end.
else do:
  assign
  v-cashier-note = "Нет отложенных заданий на пересылку продавцов на кассу"
  .
end.

find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-fgrp}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
        find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-fgrp-note = "Самое старое задание на пересылку информации о группе блюд на кассу" + {&new-line} +
               "от" + {&space-char} +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + {&space-char} +
               buf_BatchProcess.BP_SysTime  + {&new-line} +
               "Пользователь" + {&space-char} +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id =" + buf_BatchProcess.User_ID)
  v-fgrp = yes
               .
end.
else do:
  assign
  v-fgrp-note = "Нет отложенных заданий на пересылку групп блюд на кассу"
  .
end.


assign
v-notes = v-gds-note
v-notes = (if v-notes = "":U then "":U else (v-notes + {&new-line} + {&new-line})) + v-dcard-note
v-notes = (if v-notes = "":U then "":U else (v-notes + {&new-line} + {&new-line})) + v-seller-note
v-notes = (if v-notes = "":U then "":U else (v-notes + {&new-line} + {&new-line})) + v-cashier-note
v-notes = (if v-notes = "":U then "":U else (v-notes + {&new-line} + {&new-line})) + v-fgrp-note
.

if p-interface then
run gbl/showtext.p (
                 input "Отложенные задания пересылки на кассу"
                ,input 80
                ,input 15
                ,input v-notes
                ).
if not p-run then return.

run str/cd-askw.w (
               input parparentproc
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code
              ,input-output v-gds
              ,input-output v-dcard
              ,input-output v-seller
              ,input-output v-cashier
              ,input-output v-fgrp
              ,input v-gds-note
              ,input v-dcard-note
              ,input v-seller-note
              ,input v-cashier-note
              ,input v-fgrp-note
              ) no-error .

if error-status:error
or return-value = "error":U
or not (v-gds or v-dcard or v-seller or v-cashier)
then return.
/*return.*/

run str/diallog.w (   parparentproc
              , this-procedure
              , 'str/sendalcd.p':U
              , (string(v-gds) + {&delim-par} +
                 string(v-dcard) + {&delim-par} +
                 string(v-seller) + {&delim-par} +
                 string(v-cashier) + {&delim-par}  +
                 string(v-fgrp) + {&delim-par}
                   )
              , no /*p-auto-go*/
              , 'Прервать':U
              , 'Отправка информации на кассу') no-error .