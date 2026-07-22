block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: delmfdoc.p $
$Archive: str/delmfdoc.p $

удаление цепочки межфирменного перемещени от Внешнего расхода

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/18/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delmfdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/delmfdoc.p $":U .
define variable vss-description as character no-undo init "удаление цепочки межфирменного перемещени от Внешнего расхода".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define input parameter parparentproc  as widget-handle                no-undo.
define input parameter varchip-num-main as integer   no-undo.
define input parameter varchip-num      as integer   no-undo.
define input parameter v-user-action    as character no-undo.
define input parameter v-printed        as logical   no-undo.


define shared buffer t-doc for trn-doc .

define buffer del_trn-doc for trn-doc.
if t-doc.status_ <> {&fact} then return .
if t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh} then return .

  define variable vardoc-hold as logical no-undo.
  { gbl/hold-doc.i
    t-doc.doc-code
    vardoc-hold
  }

if vardoc-hold <> true  then return .
define buffer bf_clients   for clients .
define buffer bf-c_clients for clients.
define buffer bf-pri_trn-doc for trn-doc.
define buffer bf-vzv_trn-doc for trn-doc.
define buffer bf-vzp_trn-doc for trn-doc.
  find first bf_clients where bf_clients.obj-type = t-doc.obj-type and
                              bf_clients.obj-code = t-doc.obj-code no-lock.


/* Цепочка начинается с Внешнего расхода */
do TRANSACTION :

  find first bf-pri_trn-doc exclusive-lock where bf-pri_trn-doc.out-code  = t-doc.doc-code     and
                                                 bf-pri_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}  no-error .
                                  if not available bf-pri_trn-doc then do:
                                          message substitute("На документе МФ РН &1 по объекту &2 &3 базы данных &4 , нет МФ ПН . Нельзя удалять МФ документ .",
                                                                  t-doc.doc-code,
                                                                  t-doc.obj-type,
                                                                  t-doc.obj-code,
                                                                  bf_clients.db-num
                                                                  ) view-as alert-box error.
                                          return error.
                                  end.

  find first bf-c_clients where bf-c_clients.obj-type = bf-pri_trn-doc.obj-type and
                                bf-c_clients.obj-code = bf-pri_trn-doc.obj-code no-lock no-error .
                                if bf_clients.db-num <> bf-c_clients.db-num then do:
                                  message substitute("В документе МФ РН &1 по объекту &2 &3 базы данных &4 , а МФ ПН на объекте &5 &6 базы данных &7. Нельзя удалять МФ документы относящиеся к разным базам данных.",
                                                          t-doc.doc-code,
                                                          t-doc.obj-type,
                                                          t-doc.obj-code,
                                                          bf_clients.db-num,
                                                          bf-pri_trn-doc.obj-type,
                                                          bf-pri_trn-doc.obj-code,
                                                          bf-c_clients.db-num
                                                          ) view-as alert-box error.
                                  return error.
                                end.
/* ПН */
if bf-pri_trn-doc.status_ = {&fact} then do:
    run ver-vzp in this-procedure  no-error .
          if error-status :error then do:
            message substitute("По МФ ПН документу № &1 по объекту &2 &3 , есть Возвраты поставщику. Удалите сначала их.",
                                    bf-pri_trn-doc.doc-code,
                                    bf-pri_trn-doc.obj-type,
                                    bf-pri_trn-doc.obj-code
                                    ) view-as alert-box error.
            return error.
          end.

    find first bf-vzv_trn-doc where bf-vzv_trn-doc.out-code = bf-pri_trn-doc.doc-code and
                                      bf-vzv_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}  exclusive-lock no-error.

    if available bf-vzv_trn-doc then do:  /* Возврат внешний */

        if bf-vzv_trn-doc.status_ = {&fact} then do:
            find first bf-c_clients where bf-c_clients.obj-type = bf-vzv_trn-doc.obj-type and
                                          bf-c_clients.obj-code = bf-vzv_trn-doc.obj-code no-lock.
                                          if bf_clients.db-num <> bf-c_clients.db-num then do:
                                            message substitute("В документе МФ РН &1 по объекту &2 &3 базы данных &4 , а МФ ВН на объекте &5 &6 базы данных &7. Нельзя удалять МФ документы относящиеся к разным базам данных.",
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
            run str/del-doc.p
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
                "Ошибка при удалении документа возврата." skip
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
            message "Имеется открытый документ МФ возврата покупателя по данному МФ расходу." skip
                    "Номер документа: " bf-vzv_trn-doc.doc-code skip
            view-as alert-box error.
            return error.
        end.
    end. /* end - возврат покупателя*/

    run str/del-doc.p
      ( input parparentproc,
        input  bf-pri_trn-doc.doc-code,
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
        "Ошибка при удалении документа прихода." skip
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
    message "Имеется открытый документ МФ ПН по данному МФ расходу." skip
            "Номер документа: " bf-pri_trn-doc.doc-code skip
    view-as alert-box error.
    return error.
 end.
 /* end ПН */

  /* удаление РН*/
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

procedure ver-vzp :

  do
  on error undo, return error return-value
  :
define buffer buf_parts for parts .
define buffer buf_doc-line for doc-line.
define buffer buf_vz_trn-doc for trn-doc.
define variable v-doc-hold as logical no-undo.

for each buf_doc-line no-lock where buf_doc-line.doc-code = bf-pri_trn-doc.doc-code :
    for each buf_parts no-lock where
        buf_parts.artic      = buf_doc-line.artic  and
        buf_parts.prod-type  = buf_doc-line.prod-type and
        buf_parts.prod-code  = buf_doc-line.prod-code and
        buf_parts.in-code    = buf_doc-line.doc-code  :
        find first buf_vz_trn-doc no-lock where buf_vz_trn-doc.doc-code = buf_parts.out-code no-error .
        if available buf_vz_trn-doc and
           buf_vz_trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh_VP}
           then do:
            { gbl/hold-doc.i
              t-doc.doc-code
              v-doc-hold
            }
            if v-doc-hold = true  then do:
               message
               "Есть МФ возврат поставщику № "  + buf_vz_trn-doc.doc-code  skip
               "на объекте :"
                buf_vz_trn-doc.obj-type  buf_vz_trn-doc.obj-code
                view-as alert-box error .
               return error .
            end.
        end.
    end.
end.

end.
end procedure. /* ver-vzp */