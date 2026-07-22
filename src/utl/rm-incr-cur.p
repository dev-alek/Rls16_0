block-level on error undo, throw.
{ cmp/str-glbl.i }

for each clients-attr where clients-attr.attr-code = {&attr-bge-incr-cur}:
    delete clients-attr.
end.

message "Все старые атрибуты очищены"
view-as alert-box.
