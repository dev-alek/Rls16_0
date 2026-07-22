block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
for each clients-attr where clients-attr.attr-code = 'bge-incr-cur':U:
    delete clients-attr.
end.
message "Все старые атрибуты очищены"
view-as alert-box.
