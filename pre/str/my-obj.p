block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter  parobj-type like ub.clients.obj-type no-undo.
define input parameter  parobj-code like ub.clients.obj-code no-undo.
define input parameter  pardb-num   like ub.db.db-num        no-undo.
define output parameter parmy-obj   as   logical             no-undo.
define variable vardb-num like ub.clients.db-num no-undo.
define variable varactive as   logical           no-undo.
define buffer bf_store   for ub.store.
define buffer bf_clients for ub.clients.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock.
assign
  vardb-num = bf_clients.db-num.
case parobj-type :
  when 'маг':U then do:
    assign varactive = yes.
  end.
  when 'скл':U then do:
    find first bf_store where bf_store.obj-code = parobj-code no-lock no-error.
    if not available bf_store then do:
      return error substitute ("Ошибка при поиске склада с номером &1.", parobj-code).
    end.
    assign varactive = bf_store.active.
  end.
  otherwise do:
    return error substitute ("Неверный тип объекта &1.", parobj-type).
  end.
end case.
if vardb-num = pardb-num then do:
  assign
    parmy-obj = varactive
  .
end.
else do:
  assign
    parmy-obj = not varactive
  .
end.
