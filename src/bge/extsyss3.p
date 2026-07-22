block-level on error undo, throw.
/*

$Revision: bfb4ae97be9f, 14, test $
$Author: ASMorozov $
$Date: Wed Mar 05 12:48:25 2014 +0300 $
$Workfile: extsyss3.p $
$Archive: bge/extsyss3.p $

Удаление специальной ВС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/24/08
Author: Bakhtadze Natalya
Creation date: 02/24/08

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: bfb4ae97be9f, 14, test $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Mar 05 12:48:25 2014 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extsyss3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/extsyss3.p $":U .
define variable vss-description as character no-undo init "Удаление специальной ВС".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ bge/extsyssl.i }


define variable v-mess as character no-undo .
define variable v-ok as logical   no-undo .

define buffer buf_ext-system  for ub.ext-system.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_esys-route for ub.esys-route.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num <> 0
  and not g#news
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Данная процедуры не может вызываться в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_ext-system exclusive-lock where
        recid(buf_ext-system) = p-rec .
  if not (buf_ext-system.esys-type > integer({&openxml-type-ordinal})) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Данная программа предназначена для удаления ТОЛЬКО СПЕЦИАЛЬНЫХ ВС"
    view-as alert-box error .
    undo, return error '':U.
  end.
  run extsyssl in this-procedure ( buffer buf_Ext-system
                                  ,output v-ok ) NO-ERROR.
  if not v-ok then do:
    v-mess = substitute("Данная внешняя система используется&1Удаление невозможно:&2&3"
                        , {&new-line}
                        , {&new-line}
                        ,  return-value
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  for each ub.rule-call-param no-lock where 
        ub.rule-call-param.param-2-data-type = "ext-system"
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    v-ok = no.
    v-mess = v-mess + substitute ("профайл №&1 правило №&2&3", ub.rule-call-param.profile_id, ub.rule-call-param.rule_id, {&new-line}).
  end.
  if not v-ok then do:
    v-mess = substitute("Данная внешняя система используется в настройках машины правил.&1Удаление невозможно:&2&3"
                        , {&new-line}
                        , {&new-line}
                        , v-mess
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  run waitfram-show in this-procedure ( input "Ждите... Идет удаление пакетов и данных маршрутизации").
  for each buf_esys-pck-sent where
        buf_esys-pck-sent.esys-id = buf_ext-system.esys-id
   and  buf_esys-pck-sent.db-num = buf_ext-system.db-num
   on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
   on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
   on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
   :

    delete buf_esys-pck-sent .
  end.
  for each buf_esys-pck-rcvd where
        buf_esys-pck-rcvd.esys-id = buf_ext-system.esys-id
     and  buf_esys-pck-rcvd.db-num = buf_ext-system.db-num
   on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
   on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
   on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
   :
    delete buf_esys-pck-rcvd .
  end.
  for each buf_esys-pck-keys where
        buf_esys-pck-keys.esys-id = buf_ext-system.esys-id
     and  buf_esys-pck-keys.db-num = buf_ext-system.db-num
   on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
   on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
   on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
   :
    delete buf_esys-pck-keys  .
  end.
  for each buf_esys-route where
        buf_esys-route.esys-id = buf_ext-system.esys-id
     and  buf_esys-route.db-num = buf_ext-system.db-num
   on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
   on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
   on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
   :
    delete buf_esys-route  .
  end.
  run waitfram-hide in this-procedure .
  delete buf_ext-system.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Специальная внешняя система: код &1"
                         , buf_ext-system.esys-id
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.