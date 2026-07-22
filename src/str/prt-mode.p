block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prt-mode.p $
$Archive: str/prt-mode.p $

Значение сортировки по умолчанию для интерфейса редактирования признаков

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/09/04


*/

define input  parameter p-doc-code           as character no-undo .
define input  parameter p-gds-code           as integer   no-undo .
define input  parameter p-update-doc         as logical   no-undo .
define output parameter p-sort-mode          as integer   no-undo .
define output parameter p-filter-mode        as integer   no-undo .
define output parameter p-can-create-gds-dtl as logical   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: prt-mode.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/prt-mode.p $":U .
define variable vss-description as character no-undo initial "Значение сортировки по умолчанию для интерфейса редактирования признаков".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-doc-code,p-gds-code,p-update-doc)" }
{ cmp/trg-def.i  }

define variable v-root-node    as integer   no-undo .
define variable v-empty-scale  as logical   no-undo .
define variable v-to-doc-prt   as logical   no-undo .
define variable v-from-doc-prt as logical   no-undo .

define buffer buf_trn-doc for ub.trn-doc .

do
on error undo, return error return-value
:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-update-doc = true
  then do:
    assign
      p-can-create-gds-dtl = true
    .
  end.
  else do:
    /* для документов внутреннего перемещения */
    /* и документов межфирменного перемещения */
    /* возможно создание записей в режиме редактирования факт количеств */
    /* если на объекте с которого мы перемещаем признаки выключены */
    /* а на объекте, куда мы перемещаем признаки включены */
    /* у товара имеется шкала */
    { gbl/gdsrtnod.i
      p-gds-code
      v-root-node
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении корневого признака товара" skip
        "Код товара" p-gds-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/prtat.i
      v-root-node
      "'empty-scale=request':u"
      v-empty-scale
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута признака" skip
        "Код товара" p-gds-code skip
        "Признак" v-root-node skip
        "Запрашивался атрибут" "empty-scale=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-empty-scale <> true
    then do:
      if  buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
      or  buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
      or  ( ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
              or
              buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
            )
            and
            ( ( buf_trn-doc.hold-doc-code-child  <> '':u
                and
                buf_trn-doc.hold-doc-code-child  <> 'no-hold':u
              )
              or
              ( buf_trn-doc.hold-doc-code-parent <> '':u
                and
                buf_trn-doc.hold-doc-code-parent <> 'no-hold':u
              )
            )
          )
      then do:
        /* определяем, учитываются ли признаки на объекте */
        /* куда происходит перемещение */
        { gbl/objat.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          "'doc-prt=request':u"
          v-to-doc-prt
          no-error
        }
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Документ" buf_trn-doc.doc-code skip
            "Объект на который производится перемещения" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
            "Атрибут" 'doc-prt=request':u skip
            error-status:get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        /* определяем, учитываются ли признаки на объекте */
        /* откуда происходит перемещение */
        { gbl/objat.i
          buf_trn-doc.cli-type
          buf_trn-doc.cli-code
          "'doc-prt=request':u"
          v-from-doc-prt
          no-error
        }
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Документ" buf_trn-doc.doc-code skip
            "Объект с которого производится перемещение" buf_trn-doc.cli-type buf_trn-doc.cli-code skip
            "Атрибут" 'doc-prt=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        if  v-to-doc-prt   = true
        and v-from-doc-prt <> true
        then do:
          assign
            p-can-create-gds-dtl = true
          .
        end.
        else do:
          assign
            p-can-create-gds-dtl = false
          .
        end.
      end.
      else do:
        assign
          p-can-create-gds-dtl = false
        .
      end.
    end.
    else do:
      assign
        p-can-create-gds-dtl = false
      .
    end.
  end.

  /* сортируем по признакам */
  /* если можно создавать признаки - то показываем все признаки в наличии на объекте */
  /* если признаки нельзя создавать - то показываем все признаки документа */
  if p-can-create-gds-dtl = true
  then do:
    assign
      p-sort-mode   = 2
      p-filter-mode = 3
    .
  end.
  else do:
    assign
      p-sort-mode   = 2
      p-filter-mode = 4
    .
  end.
end.