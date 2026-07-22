block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cshprtob.p $
$Archive: str/cshprtob.p $

Изменение атрибута gds-obj.cash-parts по списку

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cshprtob.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cshprtob.p $":U .
define variable vss-description as character no-undo init "Изменение атрибута gds-obj.cash-parts по списку".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ str/lib-trn.i }
{ cmp/gds-list.i gds-list def "new shared" }
&undefine gds-list_i_def
{ cmp/gds-list.i del-list def "new shared" }
{ gbl/waitfram.i }

define variable ii as integer no-undo.
define variable kk as integer no-undo.
define variable glog as logical no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable v-doc-prt as logical no-undo .
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces as logical no-undo .
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_gds-prt for ub.gds-prt .
define buffer buf_units for ub.units.
define buffer buf_goods for ub.goods.
define buffer buf_gds-obj for ub.gds-obj.


glog = no.

run waitfram-show in this-procedure ( input "ЖДИТЕ.  Заполняется список..." ).

define variable conf-par   as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type   as char no-undo.                  /* тип параметра конфигурации */
run gbl/conf-rd.p ("is-prt", 0, "", 0, "", "", "", yes, output conf-par, output par-type) no-error.
fill-list:
do
on stop undo fill-list, return no-apply
on error undo fill-list, return no-apply:
  CASE p-obj-type:
    when {&stock} then do:
      find first buf_store no-lock where
          buf_store.obj-code = p-obj-code.
      assign
      v-doc-prt = (conf-par = "yes") and buf_store.doc-prt
      .
    end.
    when {&shop} then do:
      find first buf_shop no-lock where
               buf_shop.obj-code = p-obj-code.
      assign
      v-doc-prt = (conf-par = "yes") and buf_shop.doc-prt
      .
    end.
  END CASE.
  FOR EACH buf_gds-obj where
          buf_gds-obj.obj-type = p-obj-type
      AND buf_gds-obj.obj-code = p-obj-code
      AND buf_gds-obj.cash-parts = yes,
      FIRST buf_goods where
            buf_goods.artic     = buf_gds-obj.artic
        AND buf_goods.prod-type = buf_gds-obj.prod-type
        AND buf_goods.prod-code = buf_gds-obj.prod-code no-lock
      on stop undo fill-list, return no-apply
      on error undo fill-list, return no-apply:
    { cmp/gds-list.i gds-list assign " " buf_goods}
    { cmp/gds-list.i del-list assign " " buf_goods }
    assign
    gds-list.to-del = yes
    del-list.to-del = yes
    .  /* пометка - потенциально лишняя запись */

  END.
end.
run waitfram-hide in this-procedure .
run str/gds-list.w ( input parparentproc
                   , input p-host-code
                   , input p-obj-type
                   , input p-obj-code).
glog = no.
message "Установить признак продажи по партиям" skip
"текущем объекте для всех товаров списка?"
view-as alert-box QUESTION buttons YES-NO
update glog.
if NOT glog then return.

run waitfram-show in this-procedure ( input ("ЖДИТЕ.  Устанавливается признак продажи по партиям на текущем объекте по списку товаров..")).
_del-list:
FOR EACH del-list :
  if NOT can-find(first gds-list where
                      gds-list.artic = del-list.artic
                  AND gds-list.prod-type = del-list.prod-type
                  AND gds-list.prod-code = del-list.prod-code ) then do:
    ii = ii + 1.
    if ii modulo 100 = 0 then do:
      run waitfram-show in this-procedure ("ЖДИТЕ.  Обработано строк списка : " + string (ii)).
    end.
    { gbl/chk-actg.i
      g#db-num
      g#userid
      {&action-head-code-main}
      'actn_reference_cash-parts':U
      {&cntxt-object}
      p-host-code
      p-obj-type
      p-obj-code
      0
      del-list.grp-code
      0
      false
      glog
    }
    if glog then do :
      { gbl/gdsobjat.i
      p-obj-type
      p-obj-code
      del-list.artic
      del-list.prod-type
      del-list.prod-code
      '"cash-parts=false"'
      glog
      no-error
      }
      if error-status:error then do:
        delete del-list.
        undo, next _del-list.
      end.
      kk = kk + 1.
    end.
  end.
  delete del-list.
END.

_assign-list:
FOR EACH gds-list where
        gds-list.to-del = no no-lock
on stop undo _assign-list, return no-apply
on error undo _assign-list, return no-apply:
  ii = ii + 1.
  if ii modulo 100 = 0 then
  run waitfram-show in this-procedure ("ЖДИТЕ.  Обработано строк списка : " + string (ii)).
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_reference_cash-parts':U
    {&cntxt-object}
    p-host-code
    p-obj-type
    p-obj-code
    0
    gds-list.grp-code
    0
    false
    glog
  }
  if glog then do :
    FIND FIRST buf_gds-prt No-LOCK WHERE
              buf_gds-prt.upper-code = gds-list.prt-root No-ERROR.
    FIND FIRST buf_units NO-LOCK WHERE
            buf_units.unit-name = gds-list.unit-base NO-ERROR.
    IF NOT AVAIL buf_gds-prt
    OR (NOT buf_gds-prt.node-name = {&empty-scale} AND v-doc-prt)
    OR  NOT AVAIL buf_units OR lookup({&weight}, buf_units.type) > 0
    or gds-list.gds-type = {&gds-office} then do:
      NEXT _assign-list.
    end.
  { str/is-petrl.i
      gds-list.artic
      gds-list.prod-type
      gds-list.prod-code
      v-is-petrolium
      v-is-pieces
    }
    if v-is-petrolium and
    not v-is-pieces then do:
      NEXT _assign-list.
    end.
    { gbl/gdsobjat.i
    p-obj-type
    p-obj-code
    gds-list.artic
    gds-list.prod-type
    gds-list.prod-code
    '"cash-parts=true"'
    glog
    no-error
    }
    if error-status:error then do:
      delete gds-list.
      undo, next _assign-list.
    end.
    run str/gdsbccr.p (
                        input  p-obj-type
                        ,input  p-obj-code
                        ,input gds-list.artic
                        ,input gds-list.prod-type
                        ,input gds-list.prod-code) no-error.
    if error-status:error then do:
      message
      error-status:get-message(1) view-as alert-box.
      delete gds-list.
      undo, next _assign-list.
    end.
    delete gds-list.
    kk = kk + 1.
  end.
END.
if ii = kk then do:
  message
  "Признак продажи по партиям на текущем объекте" skip
  "                 по списку товаров установлен"
  view-as alert-box.
end.
else do:
  message
  substitute("Из &1 строк списка признак продажи по партиям на текущем объекте&2" +
             "                     удалось установить по &3 товарам"
            , ii
            , {&new-line}
            , kk)
  view-as alert-box.
end.
run waitfram-hide in this-procedure .