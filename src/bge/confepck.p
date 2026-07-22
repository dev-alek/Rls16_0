block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: confepck.p $
$Archive: bge/confepck.p $

Ручное подвтерждение одного пакета ESYS

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/09
Author: Bakhtadze Natalya
Creation date: 07/31/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter log-file-name as character no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-esps-cr-db-num as integer no-undo .
define input parameter p-esps-pack-num as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: confepck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/confepck.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-route for ub.esys-route.

&scop display-message ~
     if p-silent then do: ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).             ~
     end.                                          ~
     else do:                                      ~
       message ~{&my-message~} view-as alert-box. ~
     end


find first buf_esys-pck-sent share-lock where
        buf_esys-pck-sent.esys-id = p-esys-id
    and buf_esys-pck-sent.db-num = p-db-num
    and buf_esys-pck-sent.esps-cr-db-num = p-esps-cr-db-num
    and buf_esys-pck-sent.esps-pack-num = p-esps-pack-num no-error.

if not available buf_esys-pck-sent then do:
  &scop my-message substitute("Не найден пакет для ВС &1 за номером &2", p-esys-id, p-esps-pack-num)
  {&display-message}.
end.
else do:
  if buf_esys-pck-sent.esps-rcvd = yes then do:
    &scop my-message substitute("Отправленный Пакет &1 для ВС УЖЕ подтвержден" ~
                                ,buf_esys-pck-sent.esps-pack-num  ~
                                ,buf_esys-pck-sent.esys-id)
    {&display-message}.
    return ''.
  end.
  for each buf_esys-route share-lock where
          buf_esys-route.esys-id = buf_esys-pck-sent.esys-id
      and buf_esys-route.db-num = buf_esys-pck-sent.db-num
      and buf_esys-route.esr-cr-db-num = buf_esys-pck-sent.esps-cr-db-num
      and buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :

    delete buf_esys-route.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  buf_esys-pck-sent.esps-rcvddate = v-today
  buf_esys-pck-sent.esps-rcvdtimeint = v-time
  buf_esys-pck-sent.esps-rcvdtime = string(v-time, "hh:mm:ss")
  buf_esys-pck-sent.esps-rcvd = yes
  .
  &scop my-message substitute("Отправленный Пакет &1 для ВС помечен как подтвержденный &3 &4" ~
                               ,buf_esys-pck-sent.esps-pack-num  ~
                               ,buf_esys-pck-sent.esys-id       ~
                               ,string(buf_esys-pck-sent.esps-rcvddate, "99/99/9999") ~
                               ,buf_esys-pck-sent.esps-rcvdtime)
  {&display-message}.
end.