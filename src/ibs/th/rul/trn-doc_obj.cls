/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trn-doc_obj.cls $
$Archive: ibs/th/rul/trn-doc_obj.cls $

Класс  Накладна

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/28/07
Author: Bakhtadze Natalya
Creation date: 01/28/07

*/

block-level on error undo, throw.
class Ibs.Th.Rul.trn-doc_obj:
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: trn-doc_obj.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_gc as handle no-undo.
  define protected variable v_ph as handle no-undo. /*p-parent-handle*/
  define protected variable v_pp as widget-handle no-undo. /*p-parent-proc*/
  define protected variable v_lh as widget-handle no-undo. /*p-log-handle*/
  define protected variable v_cnt as widget-handle no-undo. /*p-cont-handle*/
  define protected variable v_qh as handle no-undo.
  { rul/library-cls.i class-part }
  define public variable v_bh as handle no-undo.
  define public variable v_bdh as handle no-undo.
  define public variable v_bbh as handle no-undo.
  define public variable v_bgh as handle no-undo.
  define protected buffer buf_trn-doc_obj for ub.trn-doc.
  define protected temp-table t-trn-doc_obj no-undo like ub.trn-doc.
  define protected buffer buft_trn-doc_obj for t-trn-doc_obj.
  define public variable v_tbh as handle no-undo.
  define private variable v-h-action as integer no-undo .
  define public variable temp as integer no-undo.
  define public property lock as integer
  get.
  set.
  define public property wait as integer
  get.
  set.
  define protected variable release-flag as logical no-undo .
  define private variable v-error-flag as logical no-undo .
  define protected variable find_no-error as logical no-undo .
  define public variable doc-code as character no-undo .
  define public variable d-card# as character no-undo .
  define public variable cli-type as character no-undo .
  define public variable cli-code as integer no-undo .
  define public variable tot-calc as decimal no-undo .
  define public variable tot-doc as decimal no-undo .
  define public variable discnt-rubl as decimal no-undo .
  define public variable tot-rubl as decimal no-undo .
  define public variable obj-type as character no-undo .
  define public variable obj-code as integer no-undo .
  define public variable base-rate as decimal no-undo .
  define public variable base-scale as decimal no-undo .
  define public variable doc-date as date no-undo .
  define public variable doc-time# as integer no-undo .
  define public variable discnt-pc as decimal no-undo .
  define public variable print-rubl as logical no-undo .
  define protected variable v-curr-r-b as character no-undo .
  { ibs/th/rul/crdrcall.i deftt }
  CONSTRUCTOR PUBLIC trn-doc_obj(
                               input parparentproc as widget-handle
                              ,input p-parent-handle as handle
                              ,input p-log-handle as handle
                              ,input p-gc-handle as handle
                              ,input p-cont-handle as handle
                              ,input p-lock as integer
                              ,input p-wait as integer
                              ,input p-temp as integer
                              ,input p-codex-id as integer
                              ,input p-ruleset-id as integer
                            ):
   { ibs/th/rul/cr-cls.i trn-doc_obj  ~{&table_trn-doc~} }
    assign
    doc-code = '':U
    .
    { gbl/curr-r-b.i v-curr-r-b }
  end constructor.
  destructor public trn-doc_obj():
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    find_trn-doc_obj ( input '':U).
  end destructor.
  method public logical find_trn-doc_obj ( input p-doc-code as character
                                         ,input-output p-cycle-id as integer
                                         ):
  define variable glog as logical no-undo .
    p-cycle-id = p-cycle-id + 1.
    if p-cycle-id > 1 then do:
      return yes.
    end.
    glog = find_trn-doc_obj ( input p-doc-code) no-error.
    return glog.
  end.
  method public logical find_trn-doc_obj ( p-doc-code as character
                                         ):
   define variable glog as logical no-undo .
   trn-doc_objrelease_().
   clear_().
    if p-doc-code <> '':U then do:
      assign
      glog =  v_bh:find-first( substitute('where doc-code = "&1" '
                                          , p-doc-code
                                          ), lock, wait) no-error .
      if not glog then do:
        if find_no-error then do:
          return no.
        end.
        if lock = No-LOCK then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          return error substitute("Не найдена накладная &1"
                                 , p-doc-code
                                 ).
        end.
        if wait = NO-WAIT
        and v_bh:locked then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("накладная &1 занята"
                                   , p-doc-code
                                   ).
          end.
        end.
      end.
      if p-doc-code <> doc-code then do:
        assign
        glog =  v_bdh:find-first( substitute('where doc-code = "&1"'
                                            , p-doc-code
                                            ), lock, wait) no-error .
        if not glog then do:
          return error substitute("Не найдена накладная &1", p-doc-code).
        end.
      end.
      assign
      doc-code             = buf_trn-doc_obj.doc-code
      d-card#              = buf_trn-doc_obj.d-card
      cli-type             = buf_trn-doc_obj.cli-type
      cli-code             = buf_trn-doc_obj.cli-code
      tot-calc             = buf_trn-doc_obj.tot-calc
      discnt-rubl          = buf_trn-doc_obj.discnt-rubl
      tot-rubl             = buf_trn-doc_obj.tot-rubl
      tot-doc              = buf_trn-doc_obj.tot-doc
      print-rubl           = buf_trn-doc_obj.print-rubl
      obj-type             = buf_trn-doc_obj.obj-type
      obj-code             = buf_trn-doc_obj.obj-code
      base-rate            = buf_trn-doc_obj.base-rate
      base-scale           = buf_trn-doc_obj.base-scale
      discnt-pc            = buf_trn-doc_obj.discnt-pc
      .
      glog = v_tbh:buffer-create( ).
      glog = v_tbh:buffer-copy( v_bh).
    end.
    return yes.
  end method.
  { ibs/th/rul/crdrcall.i return-value-methods }
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    if v_tbh:available then
    glog = v_tbh:buffer-delete() no-error .
    assign
    doc-code = ''
    .
  end method.
  method public void trn-doc_objrelease_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_trn-doc_obj ( ):
    return v_bh.
  end method.
  method public override character ToString( ):
    return substitute("Накладная &1"
                      , doc-code
                      ).
  end method.
end class.
