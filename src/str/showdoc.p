block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: showdoc.p $
$Archive: str/showdoc.p $

Показать складской документ или документ переоценки

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/23/00

Параметры:

parparentproc   обязательный параметр - указатель на главное окно системы
p-doc-code      обязательный параметр - номер документа

p-artic p-prod-type p-prod-code
  если задан p-artic - то встать на определенную строчку документа


p-doc-type:
  p-doc-type = ?     - складской документ или документ переоценки
  p-doc-type = true  - показать складской документ
  p-doc-type = false - показать документ переоценки

*/

define input  parameter parparentproc as handle    no-undo .
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-artic       as character no-undo .
define input  parameter p-prod-type   as character no-undo .
define input  parameter p-prod-code   as integer   no-undo .
define input  parameter p-doc-type    as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: showdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/showdoc.p $":U .
define variable vss-description as character no-undo init "Показать складской документ или документ переоценки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable v-line-rec as integer   no-undo .

do
on error undo, return error return-value
:

  { gbl/getcntxt.i get }

  define variable old-type     as character no-undo .
  define variable old-stat     as character no-undo .
  define variable old-flag     as logical   no-undo .
  define variable old-internal as logical   no-undo .

  define variable l-document-exist as logical no-undo .

  assign
    l-document-exist = false
  .

  case p-doc-type :
    when ?
    then do:
      run show-trn-doc
        (output l-document-exist
        ).
      if l-document-exist = false
      then do:
        run show-price-doc
          (output l-document-exist
          ).
      end.
      if not l-document-exist
      then do:
        message
          "Документ" p-doc-code "не найден"
          view-as alert-box .
      end.
    end.
    when true
    then do:
      run show-trn-doc in this-procedure
        (output l-document-exist /* p-document-exist */
        ).
      if not l-document-exist
      then do:
        message
          "Складской документ" p-doc-code "не найден"
          view-as alert-box .
      end.
    end.
    when false
    then do:
      run show-price-doc in this-procedure
        (output l-document-exist /* p-document-exist */
        ).
      if not l-document-exist
      then do:
        message
          "Акт переоценки" p-doc-code "не найден"
          view-as alert-box .
      end.
    end.
  end.
end.

procedure show-trn-doc :
  define output parameter p-document-exist as logical no-undo .

  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .

  do
  on error undo, return error return-value
  :
    assign
      p-document-exist = false
    .

    find buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error.
    if available buf_trn-doc
    then do:
      assign
        p-document-exist = true
      .

      define variable v-ok as logical   no-undo .
      case buf_trn-doc.doc-type
      :
        when {&income}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income_lookup':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            v-ok
          }
        end.
        when {&expense}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense_lookup':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            v-ok
          }
        end.
        when {&write-off}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_write-off_lookup':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            v-ok
          }
        end.
        when {&inventory}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_inventory_lookup':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            v-ok
          }
        end.
        when {&return}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_return_lookup':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            v-ok
          }
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" skip
            "Тип документа" trn-doc.doc-type skip
            "Код документа" trn-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .

      if v-ok <> true
      then do:
        return . /* --->>>--- */
      end.
      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_sale_lookup':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          v-ok
        }
        if v-ok <> true
        then do:
          return . /* --->>>--- */
        end.
      end.

      assign
        v-line-rec = ?
      .
      if p-artic > ''
      then do:
        find buf_doc-line no-lock
          where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            and buf_doc-line.artic     = p-artic
            and buf_doc-line.prod-type = p-prod-type
            and buf_doc-line.prod-code = p-prod-code
          no-error .
        if available buf_doc-line
        then do:
          assign
            v-line-rec = recid (buf_doc-line)
          .
        end.
        else do:
          message
            "В документе" p-doc-code skip
            "не найден товар" p-artic p-prod-type p-prod-code skip
            view-as alert-box .
        end.
      end.
      run str/trn-lkp.p
        (input parparentproc
        ,input recid(buf_trn-doc)
        ,input recid(buf_doc-line)
        ).
    end.
  end.

end procedure. /* show-trn-doc */



procedure show-price-doc :

  define output parameter p-document-exist as logical no-undo .

  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_price-list for ub.price-list .

  do
  on error undo, return error return-value
  :
    assign
      p-document-exist = false
    .
    find buf_price-doc
      where buf_price-doc.doc-num = p-doc-code
      no-error.
    if available buf_price-doc
    then do:
      assign
        p-document-exist = true
      .

      define variable v-ok as logical   no-undo .
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_overvalue_lookup':U
        {&cntxt-object}
        buf_price-doc.host-code
        buf_price-doc.obj-type
        buf_price-doc.obj-code
        0
        0
        0
        true
        v-ok
      }
      if v-ok <> true
      then do:
        return . /* --->>>--- */
      end.

      assign
        v-line-rec = ?
      .
      if p-artic > ''
      then do:
        find first buf_price-list no-lock
          where buf_price-list.doc-num   = buf_price-doc.doc-num
            and buf_price-list.artic     = p-artic
            and buf_price-list.prod-type = p-prod-type
            and buf_price-list.prod-code = p-prod-code
          no-error .
        if available buf_price-list
        then do:
          assign
            v-line-rec = recid(buf_price-list)
          .
        end.
        else do:
          message
            "В акте переоценки" p-doc-code skip
            "не найден товар" p-artic p-prod-type p-prod-code skip
            view-as alert-box .
        end.
      end.
      run str/pr-lkp.p
        (input parparentproc
        ,input recid(buf_price-doc)
        ).
    end.
  end.

end procedure. /* show-price-doc */