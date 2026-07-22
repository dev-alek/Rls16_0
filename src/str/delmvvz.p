block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: delmvvz.p $
$Archive: str/delmvvz.p $

удаление цепочки межфирменного перемещени от Возврата поставщика

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/18/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delmvvz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/delmvvz.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define input parameter parparentproc  as widget-handle                no-undo.
define input parameter varchip-num-main as integer   no-undo.
define input parameter varchip-num      as integer   no-undo.
define input parameter v-user-action    as character no-undo.
define input parameter v-printed        as logical   no-undo.


define shared buffer t-doc for ub.trn-doc .

define buffer del_trn-doc for ub.trn-doc.
if t-doc.status_ <> {&fact} then return .
if t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} then return .

  define variable vardoc-hold as logical no-undo.
  { gbl/hold-doc.i
    t-doc.doc-code
    vardoc-hold
  }

if vardoc-hold <> true  then return .
define buffer bf_clients   for ub.clients .
define buffer bf2_clients   for ub.clients .
define buffer bf-c_clients for ub.clients.
define buffer bf-vzv_trn-doc for ub.trn-doc.
define buffer bf-vzp_trn-doc for ub.trn-doc.
  find first bf_clients where bf_clients.obj-type = t-doc.obj-type and
                              bf_clients.obj-code = t-doc.obj-code no-lock.
  find first bf2_clients where bf2_clients.obj-type = t-doc.hold-obj-type and
                              bf2_clients.obj-code  = t-doc.hold-obj-code no-lock.

  find first  bf-vzv_trn-doc where bf-vzv_trn-doc.hold-doc-code-parent = t-doc.doc-code and
                                   bf-vzv_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}  no-lock no-error .
       if not available bf-vzv_trn-doc then do:
            message substitute("На документе МФ Возврат поставщика &1 по объекту &2 &3 базы данных &4 , нет МФ Возврата покупателю . БД покупателя : &5 &6 Нельзя удалять МФ документ разных БД ",
                                    t-doc.doc-code,
                                    t-doc.obj-type,
                                    t-doc.obj-code,
                                    bf_clients.db-num,
                                    bf2_clients.db-num ,
                                    {&new-line}
                                    ) view-as alert-box error.
             return .
      end.


/* Цепочка начинается с Возврата поставщ */
do TRANSACTION :

    find first bf-vzv_trn-doc where bf-vzv_trn-doc.hold-doc-code-parent = t-doc.doc-code and
                                    bf-vzv_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}  exclusive-lock no-error.

    if available bf-vzv_trn-doc then do:  /* Возврат внешний */

        if bf-vzv_trn-doc.status_ = {&fact} then do:
            find first bf-c_clients where bf-c_clients.obj-type = bf-vzv_trn-doc.obj-type and
                                          bf-c_clients.obj-code = bf-vzv_trn-doc.obj-code no-lock.
                                          if bf_clients.db-num <> bf-c_clients.db-num then do:
                                            message substitute("В документе МФ возврата поставщику &1 по объекту &2 &3 базы данных &4 , а МФ возврат покупателя на объекте &5 &6 базы данных &7. Нельзя удалять МФ документы относящиеся к разным базам данных.",
                                                                    t-doc.doc-code,
                                                                    t-doc.obj-type,
                                                                    t-doc.obj-code,
                                                                    bf_clients.db-num,
                                                                    bf-vzv_trn-doc.obj-type,
                                                                    bf-vzv_trn-doc.obj-code,
                                                                    bf-c_clients.db-num
                                                                    ) view-as alert-box error.
                                            return error.
                                          end.
            run str/del-doc.p        /* удаление возврата внешнего 2 */
              ( input parparentproc,
                input bf-vzv_trn-doc.doc-code,
                input g#db-num,
                input "del-doc.err",
                input ?,
                input ?,
                input g#userid,
                input 0,
                input  varchip-num-main,
                output varchip-num )
              no-error.
            if error-status:error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа возврата внешнего." skip
                return-value skip
                trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                view-as alert-box error.
              if search ("del-doc.err") <> ? then do:
                run gbl/prnfilen.w
                  (input  "Ошибки при удалении документа"
                  ,input  0
                  ,input  "del-doc.err"
                  ,input  7
                  ,output v-user-action
                  ,output v-printed
                  ).
              end.
              return error.
            end.
        end.
        else do:
            message "Имеется открытый документ МФ возврата поставщику по данному МФ внешнему возврату." skip
                    "Номер документа: " bf-vzv_trn-doc.doc-code skip
            view-as alert-box error.
            return error.
        end.
    end. /* end - возврат поставщику*/


  /*  удаление возврата поставшику 1*/
  run str/del-doc.p
    ( input parparentproc,
      input  t-doc.doc-code,
      input  g#db-num,
      input  "del-doc.err",
      input  ?,
      input  ?,
      input  g#userid,
      input  0,
      input  varchip-num-main,
      output varchip-num )
  no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении документа." skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
      view-as alert-box error.
    if search ("del-doc.err") <> ? then do:
      run gbl/prnfilen.w
        (input  "Ошибки при удалении документа"
        ,input  0
        ,input  "del-doc.err"
        ,input  7
        ,output v-user-action
        ,output v-printed
        ).
    end.
    return error.
  end.
end. /* tranzaction */