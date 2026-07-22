block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-comp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-comp.p $":U .
define variable vss-description as character no-undo init "»нициализаци€ пол€ fbr-line.is-comp".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable ii as integer no-undo .
define variable glog as logical no-undo .
def frame b
ii label "ќбработано строк производства"
with side-labels view-as dialog-box.
glog = yes.
message "»нициализаци€ составных товаров / ингридиентов в производстве ?  ¬ы уверены ?"
                view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.
view frame b.
ii = 0.
for each ub.fbr-line:
  disp ii with frame b.
  ii = ii + 1.
  find ub.recipe where ub.recipe.recipe-code = ub.fbr-line.recipe-code no-lock no-error.
  if available ub.recipe then
    if ub.recipe.artic = ub.fbr-line.artic and
       ub.recipe.prod-type = ub.fbr-line.prod-type and
       ub.recipe.prod-code = ub.fbr-line.prod-code then
      ub.fbr-line.is-comp = yes.
    else
      ub.fbr-line.is-comp = no.
  else
    if ub.fbr-line.recipe-code = "" then
      if ub.fbr-line.trn-type = 'при':U then
        ub.fbr-line.is-comp = yes.
      else
        ub.fbr-line.is-comp = no.
    else do:
      find ub.fbr-doc where ub.fbr-doc.doc-code = ub.fbr-line.doc-code no-lock.
      case ub.fbr-doc.doc-type :
        when 'комплектаци€':U then
          ub.fbr-line.is-comp = (ub.fbr-line.trn-type = 'при':U).
        when "разукомплектаци€" then
          ub.fbr-line.is-comp = (ub.fbr-line.trn-type = 'спи':U).
        when 'разделка':U then
          ub.fbr-line.is-comp = (ub.fbr-line.trn-type = 'спи':U).
        when 'производство':U then do:
          message "Ќе найден рецепт с номером:" ub.fbr-line.recipe-code skip
                          "ƒокумент:" ub.fbr-line.doc-code skip
                          "—читаем, что приходные строки соответствуют составным товарам, строки списани€ - ингридиентам." skip
                          "Ёто будет неправильно, если в документе производства использован рецепт разделки."
                          view-as alert-box error.
          ub.fbr-line.is-comp = (ub.fbr-line.trn-type = 'при':U).
        end.
      end case.
    end.
  process events.
end.
message "»нициализаци€ закончена успешно.".
