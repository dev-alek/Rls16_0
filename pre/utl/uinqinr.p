block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_parts   for ub.parts.
on write of ub.trn-doc override do:
end.
do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
  if not available bf_trn-doc then do:
    message "Документ: " pardoc-code " не найден." view-as alert-box.
    return error.
  end.
  if bf_trn-doc.ext-doc-type = 'ev':U and
     bf_trn-doc.cr-db-num    = 0                  and
     bf_trn-doc.status_      <> 'факт':U           and
     bf_trn-doc.status_      <> 'запрос':U        then do:
     find first bf_parts where bf_parts.out-code = bf_trn-doc.doc-code no-error.
     if available bf_parts then do:
       message "К документу " pardoc-code " есть привязанные партии." skip
               "Данный документ не может быть обработан данной утилитой." view-as alert-box.
       return error.
     end.
     else do:
       assign
         bf_trn-doc.status_ = 'запрос':U
         bf_trn-doc.flag_   = yes.
     end.
 end.
 else do:
   message "Этот документ не может быть обработан данной утилитой." view-as alert-box.
   return error.
 end.
end.
