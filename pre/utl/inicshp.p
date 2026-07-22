block-level on error undo, throw.
DEFINE var install as logical no-undo init no.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: inicshp.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/inicshp.p $":u .
define variable vss-description as character no-undo init "Инициализация поля gds-obj.cash-parts" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable i as integer no-undo.
define variable k as integer no-undo.
define variable choice as integer no-undo.
def frame b
i label "Обработано товаров"
with side-labels title "Заполнение поля ПРОДАЖА ПО ПАРТИЯМ для серийных товаров" view-as dialog-box.
    view frame b.
    i = 0.
for each ub.units No-LOCK WHERE lookup('сер':U, ub.units.type) > 0:
    for each ub.goods No-LOCK ON STOP UNDO, NEXT
                            ON ERROR UNDO, NEXT:
        if ub.goods.unit-base = ub.units.unit-name then do:
            FOR EACH ub.gds-obj where ub.gds-obj.artic = ub.goods.artic AND
                                                      ub.gds-obj.prod-type = ub.goods.prod-type AND
                                                      ub.gds-obj.prod-code = ub.goods.prod-code:
                i = i + 1.
                ASSIGN
                ub.gds-obj.cash-parts = yes
                k = k + 1.
            END.
            disp i with frame b.
            process events.
        end.
    end.
end.
if i = k then
message "Заполнение поля ПРОДАЖА ПО ПАРТИЯМ для серийных товаров закончено успешно."
view-as alert-box.
else
message "Из " i " товаров на объекте, выбранных для изменения удалось изменить" k " !" view-as
alert-box WARNING.
