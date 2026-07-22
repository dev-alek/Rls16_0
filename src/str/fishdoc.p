block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fishdoc.p $
$Archive: str/fishdoc.p $

Просмотр документа из финансового блока

Автор: Чернова Светлана Александровна
Дата создания: 09/15/05
Author: Svetlana Chernova
Creation date: 09/15/05

Creation date: 01/12/04 3:04

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter par-host-code as integer no-undo .
define input parameter par-obj-type as character no-undo .
define input parameter par-obj-code as integer no-undo .
define input parameter trn-doc-code as character no-undo .
define input parameter v-gds-code as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fishdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fishdoc.p $":U .
define variable vss-description as character no-undo init " Просмотр документа из финансового блока   ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


define variable v-mode as integer no-undo .


define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_goods for ub.goods .

do
on error undo, return error return-value
:
  find first buf_trn-doc no-lock where buf_trn-doc.doc-code = trn-doc-code no-error .

  if available buf_trn-doc then do:
      define variable glog as logical no-undo .

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
            par-host-code
            par-obj-type
            par-obj-code
            0
            0
            0
            true
            glog
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
            par-host-code
            par-obj-type
            par-obj-code
            0
            0
            0
            true
            glog
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
            par-host-code
            par-obj-type
            par-obj-code
            0
            0
            0
            true
            glog
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
            par-host-code
            par-obj-type
            par-obj-code
            0
            0
            0
            true
            glog
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
            par-host-code
            par-obj-type
            par-obj-code
            0
            0
            0
            true
            glog
          }
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвеснтный тип документа" skip
            "Тип документа" buf_trn-doc.doc-type skip
            "Код документа" buf_trn-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .


          IF glog <> YES OR ERROR-STATUS:ERROR THEN DO:
            RETURN error.
          END.

  if v-gds-code <> ? then v-mode = 1.
                    else v-mode = 0.
  if v-mode = 0 then do:
      run str/showdoc.p
        (input parparentproc
        ,input trn-doc-code
        ,input ""
        ,input ""
        ,input 0
        ,input true
        ) no-error  .
        if error-status :error then
        message
            "Вернулась из процедуры showdoc.p "
            error-status :get-message(1)
            view-as alert-box error .
  end.
  else do:
  find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
        if available buf_goods then do:
            run str/showdoc.p
              (input parparentproc
              ,input trn-doc-code
              ,input buf_goods.artic
              ,input buf_goods.prod-type
              ,input buf_goods.prod-code
              ,input true
              ) no-error  .
              if error-status :error then
                  message
                      "   Вернулась из процедуры showdoc.p "
                      error-status :get-message(1)
                      view-as alert-box error .

        end.
  end.
  end.

  else do:  /* по удаленным  */
    find first buf_c-trn-doc no-lock where buf_c-trn-doc.doc-code = trn-doc-code no-error .
    if available buf_c-trn-doc then do:
      run str/c-doc.w ( input parparentproc, input buf_c-trn-doc.doc-code, input buf_c-trn-doc.chip-num ).
    end.
  end.

end.