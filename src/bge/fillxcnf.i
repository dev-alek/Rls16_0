/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение временных таблицы данными о пакетах для ВС, работающих с подтверждениями

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/23/08
Author: Bakhtadze Natalya
Creation date: 02/23/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }

procedure fillxcnf :
define input  parameter p-esys-id as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-crdb-num as integer   no-undo .
define input  parameter p-pack-num as integer   no-undo .
define parameter buffer buf_temp-esys-pck-sent for THpck-sent.
define parameter buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define parameter buffer curr_temp-esys-pck-sent for THcurr-pack.
define output parameter rec-cnt as integer   no-undo .
define output parameter v-prev-crc as character no-undo .

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable glog as logical   no-undo .


define buffer prev_esys-pck-sent for ub.esys-pck-sent.
define buffer last_esys-route for ub.esys-route.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_db for ub.db.
define buffer buf_sys-ctrl for ub.sys-ctrl.



do
on error undo, return error return-value
:

  find first buf_db where buf_db.db-num = g#db-num no-lock.
  find prev_esys-pck-sent no-lock
    where prev_esys-pck-sent.esys-id  = p-esys-id
      and prev_esys-pck-sent.db-num   = p-db-num
      and prev_esys-pck-sent.esps-cr-db-num = p-cr-db-num
      and prev_esys-pck-sent.esps-pack-num = p-pack-num - 1
    no-error
  .
  if available prev_esys-pck-sent then do:
    assign
      v-prev-crc = prev_esys-pck-sent.esps-crc-pack
    .
  end.
  else do:
    assign
      v-prev-crc = "":U
    .
  end.
  find first buf_sys-ctrl no-lock.
  /*это к header*/
  create t-pck-conf.
  assign
  t-pck-conf.sys-key    = buf_sys-ctrl.sys-key
  t-pck-conf.esys-id    = p-esys-id
  t-pck-conf.db-num     = p-db-num
  t-pck-conf.current-db-num = g#db-num
  t-pck-conf.pack-num   = p-pack-num
  t-pck-conf.total-recs = ?
  t-pck-conf.rcvd-recs  = 0
  t-pck-conf.src_db-key = buf_db.db-key
  /*t-pck-conf.ver-num    = buf_upgrade.version-num*/
  t-pck-conf.prev-crc   = v-prev-crc
  .
  find last last_esys-route no-lock
     where last_esys-route.esys-id   = p-esys-id
       and last_esys-route.db-num    = p-db-num
       and last_esys-route.esr-cr-db-num = p-cr-db-num
       and last_esys-route.esr-last-pack = p-pack-num
     use-index pi
     no-error .
  /*
  if available last_esys-route
  then do:
    assign
      t-pck-conf.actual-date     = last_esys-route.esr-CreDate
      t-pck-conf.actual-time-int = last_esys-route.esr-CreTimeInt
    .
  end.
  else do:
    assign
      t-pck-conf.actual-date     = buf_esys-pck-sent.esps-CreDate
      t-pck-conf.actual-time-int = buf_esys-pck-sent.esps-CreTimeInt
    .
  end.
  */
  /*отправленные и неподтвержденные пакеты*/
  for each buf_esys-pck-sent no-lock
    where buf_esys-pck-sent.esys-id  = p-esys-id
      and buf_esys-pck-sent.db-num   = p-db-num
      and buf_esys-pck-sent.esps-rcvd     = no
      and buf_esys-pck-sent.esps-pack-num < p-pack-num
  on error  undo, return error substitute( "&1 (for each buf_esys-pck-sent). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each buf_esys-pck-sent). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each buf_esys-pck-sent). endkey", vss-workfile )
  :
    assign
    rec-cnt = rec-cnt + 1
    .
    create buf_temp-esys-pck-sent.
    glog = buffer buf_temp-esys-pck-sent:handle:buffer-copy(buffer buf_esys-pck-sent:handle
                                                ,""
                                                ,{&thpck-sent_esys-pck-sent_fields}
                                                ).
  end. /* for each buf1_esys-pck-sent ... */

  /*полученные неподтвержденные пакеты*/
  /*добавляем esys-pck-rcvd */

  for each buf_esys-pck-rcvd no-lock
    where buf_esys-pck-rcvd.esys-id    = p-esys-id
      and buf_esys-pck-rcvd.db-num     = p-db-num
      and buf_esys-pck-rcvd.espr-rcvd       = no  /* еще не получено подтверждение на подтверждение */
      and buf_esys-pck-rcvd.espr-total-recs = buf_esys-pck-rcvd.espr-rcvd-recs  /* пакет разобран полностью */
  on error  undo, return error substitute( "&1 (for each buf_esys-pck-rcvd). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each buf_esys-pck-rcvd). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each buf_esys-pck-rcvd). endkey", vss-workfile )
  :
    /*заполняем временную таблицу*/
    create buf_temp-esys-pck-rcvd.
    glog = buffer buf_temp-esys-pck-rcvd:handle:buffer-copy(buffer buf_esys-pck-rcvd:handle
                                                ,"":U
                                                ,{&thpck-rcvd_esys-pck-rcvd_fields}
                                                ).

    assign
    rec-cnt = rec-cnt + 1
    .
  end. /* for each buf_esys-pck-rcvd ... */

  do
  on error  undo, return error substitute( "&1 (do transaction). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (do transaction). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (do transaction). endkey", vss-workfile )
  :
    find first buf_esys-pck-sent exclusive-lock
      where buf_esys-pck-sent.esys-id   = p-esys-id
        and buf_esys-pck-sent.db-num   = p-db-num
        and buf_esys-pck-sent.esps-cr-db-num   = p-cr-db-num
        and buf_esys-pck-sent.esps-pack-num = p-pack-num
    .
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
      rec-cnt = rec-cnt + 1 + 1 /*всеь пакет один роут - одна запись*/
      buf_esys-pck-sent.esps-total-recs     = rec-cnt
      buf_esys-pck-sent.esps-CreNum         = buf_esys-pck-sent.esps-CreNum + 1
      buf_esys-pck-sent.esps-SendTxtDate    = v-today
      buf_esys-pck-sent.esps-SendTxtTimeInt = v-time
      buf_esys-pck-sent.esps-SendTxtTime    = string( v-time, "HH:MM:SS" )
      .
    create curr_temp-esys-pck-sent.
    glog = buffer curr_temp-esys-pck-sent:handle:buffer-copy(buffer buf_esys-pck-sent:handle
                                                ,""
                                                ,{&thpck-sent_esys-pck-sent_fields}
                                                ).

  end.
end.

end procedure. /* fillxcnf */



/* $Workfile$ e n d */