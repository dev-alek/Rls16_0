block-level on error undo, throw.
define input parameter parparentproc as   handle              no-undo.
define input parameter parrvs-code   like ub.rvs-doc.rvs-code no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable rvs-rec as recid no-undo.
define buffer bf_rvs-doc for ub.rvs-doc.
do on error undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ) :
  find first bf_rvs-doc no-lock where
             bf_rvs-doc.rvs-code = parrvs-code no-error.
  if not available bf_rvs-doc then do:
    return error substitute( 'Не найдена сверка с номером "&1".', bf_rvs-doc.rvs-code ).
  end.
  run str/rvs-doc.w ( input        parparentproc
                , input        'ПРОСМОТР':U
                , input        bf_rvs-doc.rvs-type
                , input        yes
                , input-output rvs-rec ).
end.
