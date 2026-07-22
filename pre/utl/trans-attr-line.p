block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
def var v-list-attr-code as character no-undo.
def var ii as integer no-undo.
def buffer buf_doc-line-attr for ub.doc-line-attr.
v-list-attr-code = "autoent-obj-type,ptbotype,item-pour,car-num,fio,time-income".
for each ub.doc-line-attr .
  do trans:
    if lookup (ub.doc-line-attr.attr-code, v-list-attr-code) = 0 then next.
    find first ub.trn-doc where ub.trn-doc.doc-code = ub.doc-line-attr.doc-code and ub.trn-doc.doc-type = 'при':U no-error.
    if not available ub.trn-doc then next.
    create ub.doc-attr .
    case ub.doc-line-attr.attr-code:
      when 'autoent-obj-type' then do:
        find first buf_doc-line-attr where buf_doc-line-attr.doc-code = ub.doc-line-attr.doc-code and buf_doc-line-attr.gds-code = ub.doc-line-attr.gds-code and buf_doc-line-attr.attr-code = 'autoent-obj-code' no-error.
        if not available buf_doc-line-attr then next.
        buffer-copy ub.doc-line-attr except ub.doc-line-attr.gds-code ub.doc-line-attr.attr-code ub.doc-line-attr.attr-value to ub.doc-attr
            assign
              ub.doc-attr.attr-code = 'autoent':U
              ub.doc-attr.attr-value = ub.doc-line-attr.attr-value + ";" + buf_doc-line-attr.attr-value.
            .
      end.
      when 'ptbotype' then do:
        find first buf_doc-line-attr where buf_doc-line-attr.doc-code = ub.doc-line-attr.doc-code and buf_doc-line-attr.gds-code = ub.doc-line-attr.gds-code and buf_doc-line-attr.attr-code = 'ptbocode' no-error.
        if not available buf_doc-line-attr then next.
        buffer-copy ub.doc-line-attr except ub.doc-line-attr.gds-code ub.doc-line-attr.attr-code ub.doc-line-attr.attr-value to ub.doc-attr
            assign
              ub.doc-attr.attr-code = 'ptbobj':U
              ub.doc-attr.attr-value = ub.doc-line-attr.attr-value + ";" + buf_doc-line-attr.attr-value.
            .
      end.
      when 'item-pour' then do:
        buffer-copy ub.doc-line-attr except ub.doc-line-attr.gds-code ub.doc-line-attr.attr-code to ub.doc-attr
            assign
              ub.doc-attr.attr-code = 'ptb-item-pour':U
            .
      end.
      when 'car-num' then do:
        buffer-copy ub.doc-line-attr except ub.doc-line-attr.gds-code ub.doc-line-attr.attr-code to ub.doc-attr
            assign
              ub.doc-attr.attr-code = 'car-num':U
            .
      end.
      when 'fio' then do:
        buffer-copy ub.doc-line-attr except ub.doc-line-attr.gds-code ub.doc-line-attr.attr-code to ub.doc-attr
            assign
              ub.doc-attr.attr-code = 'fio-driver':U
            .
      end.
      when 'time-income' then do:
        buffer-copy ub.doc-line-attr except ub.doc-line-attr.gds-code ub.doc-line-attr.attr-code to ub.doc-attr
            assign
              ub.doc-attr.attr-code = 'time-income':U
            .
      end.
    end case.
    if ub.doc-attr.attr-code = ? or ub.doc-attr.attr-code = "" then delete ub.doc-attr.
    else do:
      ii = ii + 1.
      for each buf_doc-line-attr where buf_doc-line-attr.doc-code = ub.doc-line-attr.doc-code
          and buf_doc-line-attr.attr-code = ub.doc-line-attr.attr-code
          and rowid (buf_doc-line-attr) <> rowid (ub.doc-line-attr):
        delete buf_doc-line-attr.
      end.
      delete ub.doc-line-attr.
    end.
  end.
end.
message "Перенесено атрибутов " ii view-as alert-box information.
