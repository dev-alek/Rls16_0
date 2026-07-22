block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: bf04b0e5cfa2, 2256, rls $":U.
define variable vss-author      as character no-undo initial "$Author: druban $":U.
define variable vss-date        as character no-undo initial "$Date: Wed Dec 25 15:24:01 2019 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: updclrvs.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: utl/updclrvs.p $":U.
define variable vss-description as character no-undo initial "Утилита запуска редактирования закрытых сверок":U.
def input parameter parproc as handle.
def variable par-doc-code as char.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
DEFINE FRAME frame1
  par-doc-code format "x(15)"
  with view-as dialog-box
  title "Введите номер сверки."
.
update par-doc-code with frame frame1.
  def var rvs-rec as recid.
  find first ub.rvs-doc exclusive-lock where ub.rvs-doc.rvs-code = par-doc-code no-error .
  if not available (ub.rvs-doc) then do:
    message "Не найдена сверка с номером: " + par-doc-code
    view-as alert-box.
  end.
  else do:
  if ub.rvs-doc.status_ <> "факт" then do :
      message "Данная сверка не закрыта на факт!" view-as alert-box .
      return .
  end.
  rvs-rec = recid(ub.rvs-doc).
  run utl/rvs-doc_upd.w
    ( input        parproc
     ,input        'ИЗМЕНЕНИЕ'
     ,input        ub.rvs-doc.rvs-type
     ,input        no
     ,input-output rvs-rec
    ) no-error.
      run str/callnews.p
         (input 'rvs-doc':U
         ,input (buffer ub.rvs-doc:handle)
         ) no-error .
      if error-status :error then do:
        message "Невозможно маршрутизировать rvs-doc для отправки в новости" view-as alert-box.
      end.
   release ub.rvs-doc.
message 'Если Вы корректировли сменную сверку, то не забудьте, пожалуйста, перепечатать сменный отчет!' view-as alert-box warning.
end.
