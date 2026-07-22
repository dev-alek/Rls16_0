/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с атрибутами акта

Автор: Уханов Дмитрий Юрьевич
Дата создания: 05/24/05
Author: Dmitry Ukhanov
Creation date: 05/24/05

*/

&if     "{1}" = "init-attr"   &then
  assign v-autoent-obj-code = "":U
         v-autoent-obj-type = "":U
         v-car-num          = "":U
         v-car-vol          = "":U
         v-item-pour        = "":U
         v-tank-density     = "":U
         v-tank-temp        = "":U
         v-tank-vol         = "":U
         v-tank-water       = "":U
         v-tank-weight      = "":U
         v-time-pour        = "":U
         v-time-income      = "":U
         v-type-inp-vat     = "":U
         v-fio              = "":U.
&elseif "{1}" = "when"        &then
  when "{2}" then do: assign v-{2} = trim( buf_doc-line-attr.attr-value ). end.

&elseif "{1}" = "when-doc-attr" &then
          &if "{2}" = "trdcattr-autoent"  &then
            when {&trdcattr-autoent} then do: 
              assign
                v-autoent-obj-type = entry (1, buf_doc-attr.attr-value, ";")
                v-autoent-obj-code = entry (2, buf_doc-attr.attr-value, ";")
              no-error.
            end.
          &elseif "{2}" = "trdcattr-fio-driver" &then
            when {&{2}} then do: assign v-fio = trim( buf_doc-attr.attr-value ). end.
          &elseif "{2}" = "trdcattr-ptb-item-pour" &then
            when {&{2}} then do: assign v-item-pour = trim( buf_doc-attr.attr-value ). end.
          &else
            when {&{2}} then do: assign v-{&bef-{2}} = trim( buf_doc-attr.attr-value ). end.
          &endif

&elseif "{1}" = "dec"         &then
  assign v-{2}-dec = decimal( v-{2} ) no-error.
  if error-status :error then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            'Ошибка преобразования параметра "{2}" в число.'
    view-as alert-box error.
  end.
&elseif "{1}" = "rvs-line"    &then
  find first buf_rvs-doc_{2} no-lock where
             buf_rvs-doc_{2}.out-code = buf_trn-doc.doc-code and
             buf_rvs-doc_{2}.rvs-type = {&rvs-{2}-doc}       no-error. /* {2} - до/после слива */
  assign v-have-rvs-{2} = ( available buf_rvs-doc_{2} ).
  if available buf_rvs-doc_{2} then do: /* Только если есть сверки. Если нет - все количества после = 0 */
    for each buf_rvs-line_{2} no-lock where
             buf_rvs-line_{2}.rvs-code = buf_rvs-doc_{2}.rvs-code and
             buf_rvs-line_{2}.obj-type = buf_trn-doc.obj-type     and
             buf_rvs-line_{2}.obj-code = buf_trn-doc.obj-code     and
             buf_rvs-line_{2}.gds-code = buf_goods.gds-code       :
      assign
        {2}_qnty        = {2}_qnty        + buf_rvs-line_{2}.state-measure-qnty
        {2}_temperature = {2}_temperature + buf_rvs-line_{2}.state-temperature
                                          * buf_rvs-line_{2}.state-measure-qnty
        {2}_cli-qnty    = {2}_cli-qnty    + buf_rvs-line_{2}.state-measure-cli-qnty
      .
&elseif "{1}" = "rvs-line-end" &then
    end. /* for each buf_rvs-line_{2} */
  end. /* if available buf_rvs-doc_{2} */
  assign
    {2}_temperature = {2}_temperature / {2}_qnty
    {2}_density     = {2}_cli-qnty    / {2}_qnty
  .
&elseif "{1}" = "print-field"  &then
  if v-have-rvs-{2} = yes then do:
      if buf_rvs-line_{2}.state-{3} <> ? then do:
    put stream out-stream buf_rvs-line_{2}.state-{3} format "{4}":U at right-field( {5} - {6}, {7} ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( {5} - {6}, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at {5}.
&endif

/* $Workfile$   E n d */

