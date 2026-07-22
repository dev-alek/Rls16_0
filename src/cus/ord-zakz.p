block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-zakz.p $
$Archive: cus/ord-zakz.p $

Изменить, добавить , скопировать , просмотреть заказ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 08/12/05

*/

define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-action       as character no-undo .
define input  parameter p-type         as character no-undo .
define output parameter p-doc-rec      as recid no-undo .
define input-output parameter  br-handle    as handle   no-undo .
define input-output parameter  bf-handle    as handle   no-undo .
define input-output parameter  next-prev    as logical  no-undo .

define shared buffer shar-buf_ord-doc for ub.ord-doc  .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-zakz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-zakz.p $":U .
define variable vss-description as character no-undo init "Изменить, добавить , скопировать , просмотреть заказ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .

define variable doc-mode    as character no-undo .
define variable line-mode   as character no-undo .
define variable line-rec    as recid no-undo . /* - */
define variable gds-rec     as recid no-undo . /* - */
define variable prt-rec     as recid no-undo . /* - */
define variable g#log      as logical   no-undo .


{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#host-code   = v-cntxt-host-code-obj
.


define new shared variable rep-rec   as recid no-undo .
define new shared variable list-mode as character no-undo .
define new shared variable doc-rec   as recid no-undo .

define buffer buf_clients for ub.clients  .

define variable ri-list       as character no-undo .
define variable rr            as recid no-undo .
define variable v-par-prt     as logical no-undo .
define variable g-log         as logical no-undo .

list-mode     = {&client-cmp_balance-cmp} .
if p-action <> {&lookup} then do:
  { gbl/objat.i store-type store-code "'doc-prt=request'" v-par-prt }
end.

  assign
    rep-rec = ?
    doc-rec = ?
  .

  if available shar-buf_ord-doc then do:
    find first buf_clients no-lock where
        buf_clients.obj-code = shar-buf_ord-doc.cli-code  and
        buf_clients.obj-type = shar-buf_ord-doc.cli-type
    no-error.
    if available buf_clients then  rep-rec = recid ( buf_clients ) .
    doc-rec = recid ( shar-buf_ord-doc ).
  end.

  /* вызовем формы по типам заказа */

  case p-action :
      when {&update} then do:
          case shar-buf_ord-doc.doc-type :
          when  {&o-o}
          then do:
            case p-action
            :
              when {&add-def}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_o-o_add-def':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              when {&deletion}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_o-o_deletion':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              when {&update}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_o-o_update':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип действия" skip
                  "p-action" p-action skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            if not g-log then  return .
            rr =  recid(shar-buf_ord-doc).
            run cus/ord-oou.w (
                input parParentProc ,
                input p-action ,
                input-output rr  ,
                input-output br-handle ,
                input-output next-prev )
                no-error .
          end.
          when  {&o-r}
          then do:
            case p-action
            :
              when {&add-def}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_o-r_add-def':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              when {&deletion}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_o-r_deletion':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              when {&update}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_o-r_update':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип действия" skip
                  "p-action" p-action skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            if not g-log then  return .
            rr =  recid(shar-buf_ord-doc).
            run cus/ord-oru.w
              ( parParentProc ,
                input-output rr  ,
                p-action ,
                input-output br-handle ,
                input-output next-prev
                ) no-error .
          end.
          otherwise do:
             run cus/cli-zakz.w ( ParParentProc, "chg":U ,p-type) no-error.
          end.
          end case.
      end.

      when  {&add-def} then do:
          assign
            rep-rec = 0
            doc-rec = 0
          .
           run cus/cli-zakz.w ( ParParentProc , "add":U , p-type) no-error.
      end.

      when  "copy":u  then do:
          run cus/cli-zakz.w ( ParParentProc , p-action , p-type) no-error.
      end.


      when  {&lookup}  then do:
            case shar-buf_ord-doc.doc-type :

            when {&o-o}   then do:
            rr = recid(shar-buf_ord-doc) .
            run cus/ord-oou.w (
                input parParentProc ,
                input {&lookup} ,
                input-output rr  ,
                input-output br-handle ,
                input-output next-prev )
                no-error .
            end.
            when {&o-r}   then do:
            rr = recid(shar-buf_ord-doc) .
            run cus/ord-oru.w (
                input parParentProc ,
                input-output rr  ,
                input {&lookup} ,
                input-output br-handle ,
                input-output next-prev )
                no-error .
            end.

            otherwise do:
                run cus/lkp-zakz.w
                  ( input parparentproc ,
                    input-output br-handle ,
                    input-output bf-handle ,
                    input-output next-prev
                    ) no-error .
            end.
            end case.
            if error-status :error then message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .

      end.
  end case.

  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка " p-action
    view-as alert-box error
  .

  P-DOC-REC = doc-rec .