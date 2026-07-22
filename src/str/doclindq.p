block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: doclindq.p $
$Archive: str/doclindq.p $

Редактирование документарного количества в расходной накладной

Автор: Чернова Светлана Александровна
Дата создания: 06/25/09
Author: Svetlana Chernova
Creation date: 06/25/09


*/

define input  parameter parparentproc as widget-handle no-undo.
define parameter buffer t-doc for ub.trn-doc .
define parameter buffer buf_doc-line for ub.doc-line .
define input  parameter p-doc-qnty   as decimal   no-undo .

define output parameter p-edit-ok     as logical   no-undo .
define output parameter p-err-message as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doclindq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/doclindq.p $":U .
define variable vss-description as character no-undo init "Редактирование документарного количества в расходной накладной".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }

define variable is-petrolium as logical no-undo .
define variable is-pieces    as logical no-undo .
define variable line-rec     as recid   no-undo .
define variable v-hold-doc as logical   no-undo .

define buffer buf_gds-dtl for ub.gds-dtl  .
define buffer buf_goods for ub.goods  .


do
on error undo, return error return-value
:
  update_block:
  do transaction
  on error undo update_block, return error
  :
    if not available t-doc
    then do:
      undo, return error "Не задан документ" .
    end.
    { gbl/hold-doc.i t-doc.doc-code v-hold-doc }
    if not available buf_doc-line
    then do:
      undo, return error "Не задана строка документа" .
    end.

    define variable v-gds-code as integer   no-undo .

    { gbl/gds-code.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      v-gds-code
    }

    find first buf_goods no-lock where
               buf_goods.gds-code  = v-gds-code .

      find first buf_gds-dtl no-lock where
                 buf_gds-dtl.artic     = buf_doc-line.artic          and
                 buf_gds-dtl.prod-type = buf_doc-line.prod-type  and
                 buf_gds-dtl.prod-code = buf_doc-line.prod-code  and
                 buf_gds-dtl.doc-code  = buf_doc-line.doc-code   no-error .
    if not available buf_gds-dtl then do:
      undo update_block, return error substitute("Нет строки признака &2 для документа &1" , buf_doc-line.doc-code, buf_goods.gds-name ) .
    end.



    if p-doc-qnty <> buf_doc-line.doc-qnty
    then do:
      if  p-doc-qnty = ?
      and t-doc.flag_ = true
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "Не указано количество"
        .
        undo update_block, return .
      end.
     if p-doc-qnty = 0 then do:
     /* Удаляем */
        run str/out-add.p
          ( parparentproc,
            recid(t-doc),
            recid(buf_doc-line),
            recid(buf_gds-dtl),
            recid(buf_goods),
            "delete",
            ? )  no-error.
          if error-status :error
          then do:
            undo update_block, return error substitute("Ошибка >> &1 &2", return-value , error-status :get-message(1)  ).
          end.
     end.

     else do:

      define variable v-goods-serial as logical   no-undo .
      { gbl/gdscdat.i
        v-gds-code
        "'serial=request':u"
        v-goods-serial
        no-error
      }
      if error-status :error
      then do:
        undo update_block, return error "Ошибка при определении свойства товара 'serial=request':u" .
      end.

      if v-goods-serial = true
      then do:
      /*  */
      end.

    run str/out-add.p
      ( parparentproc,
        recid(t-doc),
        recid(buf_doc-line),
        recid(buf_gds-dtl),
        recid(buf_goods),
        "ch-doc-qnty",
        p-doc-qnty )  no-error.
      if error-status :error
      then do:
        undo update_block, return error substitute("Ошибка >> &1 &2", return-value , error-status :get-message(1)  ).
      end.
      .
    end.
  end.
  end.

  assign
    p-edit-ok     = true
    p-err-message = ''
  .
end.