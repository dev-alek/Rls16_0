/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица для хранения dis-card-property

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/30/08
Author: Bakhtadze Natalya
Creation date: 05/30/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

DEFINE TEMP-TABLE temp-dis-card-property NO-UNDO LIKE ub.dis-card-property
field rw-option as character
field prop-label as character
field node-label as character
field data-type as character
field range as integer
INDEX attrc is
UNIQUE PRIMARY
prop-label
node-label
dt-code
host-code
obj-type
obj-code
INDEX attrcl is UNIQUE
dt-code
node-code
host-code
obj-type
obj-code
.

&endif

&if "{1}" = "init-proc" &then

procedure init-temp-dcp :
define input parameter p-mode as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-sum-id as character no-undo .
define input parameter p-dt-code as integer no-undo .

define variable v-data-type as character no-undo .          /* тип */
define variable v-format as character no-undo .        /* формат */
define variable v-label as character no-undo .         /* лабел  */
define variable v-property-value-character as character no-undo .         /* значение dis-card-propertyта */
define variable v-rw-option as character no-undo .   /* пользователь может изменять в броусе */
define variable v-range as integer no-undo .           /*  область действия */
define variable v-node-code-label as character no-undo .
define variable v-entry as character no-undo .
define variable ii as integer no-undo .
define variable v-entry2 as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_Dis-card-property for ub.dis-card-property.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  For each temp-dis-card-property where
          temp-dis-card-property.d-card = p-d-card
      and (p-dtm-code = 0 or temp-dis-card-property.dtm-code = p-dtm-code)
      and (p-dt-code = 0 or temp-dis-card-property.dt-code = p-dt-code):
    delete temp-dis-card-property.
  end.
  For each buf_dis-card-property no-lock where
          buf_dis-card-property.d-card = p-d-card
      and (p-dtm-code = 0 or buf_dis-card-property.dtm-code = p-dtm-code)
      and (p-dt-code = 0 or buf_dis-card-property.dt-code = p-dt-code)
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    find first buf_prop-head no-lock where
              buf_prop-head.dtm-code = buf_dis-card-property.dtm-code no-error .
    run discprop-node-code (
                       input buf_dis-card-property.dtm-code
                      ,input buf_dis-card-property.node-code
                      ,output v-data-type
                      ,output v-format
                      ,output v-label
                      ,output v-range
                      ,output v-rw-option
                       ).

    create temp-dis-card-property.
    assign
    temp-dis-card-property.d-card     = buf_dis-card-property.d-card
    temp-dis-card-property.dt-code    = buf_dis-card-property.dt-code
    temp-dis-card-property.sum-id     = buf_dis-card-property.sum-id
    temp-dis-card-property.dtm-code   = buf_dis-card-property.dtm-code
    temp-dis-card-property.data-type  = v-data-type
    temp-dis-card-property.range      = v-range
    temp-dis-card-property.node-label = v-label
    temp-dis-card-property.prop-label = (if available buf_prop-head
                                         then buf_prop-head.prop-label
                                         else '':U)
    temp-dis-card-property.property-value-character = buf_dis-card-property.property-value-character
    temp-dis-card-property.property-value-date = buf_dis-card-property.property-value-date
    temp-dis-card-property.property-value-decimal = buf_dis-card-property.property-value-decimal
    temp-dis-card-property.property-value-integer = buf_dis-card-property.property-value-integer
    temp-dis-card-property.rw-option = v-rw-option
    temp-dis-card-property.node-code = buf_dis-card-property.node-code
    temp-dis-card-property.host-code = buf_dis-card-property.host-code
    temp-dis-card-property.obj-type = buf_dis-card-property.obj-type
    temp-dis-card-property.obj-code = buf_dis-card-property.obj-code
    .
  end. /*For each buf_dis-card-property no-lock where*/
end. /*main-block*/
end procedure. /* init-temp-dcp */
&endif

&if "{1}" = "lock-proc" &then

procedure lock-dcp :
define input parameter p-d-card as character no-undo .
define parameter buffer locked_dis-card-property for ub.dis-card-property.

  do
  on error undo, return error
  on stop undo, return error
  on end-key undo, return error
  :
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card = p-d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error no-wait.
      if not available locked_dis-card-property
      and not locked locked_dis-card-property then do:
        create locked_dis-card-property.
        assign
        locked_dis-card-property.host-code = 0
        locked_dis-card-property.obj-type =  '':U
        locked_dis-card-property.obj-code = 0
        locked_dis-card-property.d-card = p-d-card
        locked_dis-card-property.dtm-code = 0
        locked_dis-card-property.dt-code = 0
        locked_dis-card-property.node-code = 0
        .
      end.
      if locked locked_dis-card-property then do:
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card = p-d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error .
      end.

  end.

end procedure. /* lock-dcp */

&endif
/* $Workfile$ e n d */