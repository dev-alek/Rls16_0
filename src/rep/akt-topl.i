/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

общий инклуд для отчетов по топливу

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

*/

&if "{1}" = "init-attr" &then
    assign
        v-autoent-obj-code = ""
        v-autoent-obj-type = ""
        v-car-num          = ""
        v-car-vol          = ""
        v-item-pour        = ""
        v-tank-density     = ""
        v-tank-temp        = ""
        v-tank-vol         = ""
        v-tank-water       = ""
        v-tank-weight      = ""
        v-time-pour        = ""
        v-time-income      = ""
        v-time-start       = ""
        v-time-end         = ""
        v-type-inp-vat     = ""
        v-fio              = ""
    .
&endif
&if "{1}" = "when" &then
          when "{2}"
          then do:
            assign
               v-{2} = trim(buf_doc-line-attr.attr-value)
            .
          end.
&endif

&if "{1}" = "when-doc-attr" &then
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
&endif

&if "{1}" = "dec" &then
  assign
    v-{2}-dec = decimal(v-{2}) no-error.
    if error-status :error
    then message
      vss-workfile + ". Ошибка преобразования параметра " + "{2}" + " в число"
      view-as alert-box error
    .
  .
&endif

&if "{1}" = "real-time" &then
    &if     "{2}" = "before" &then
      assign
        {2}_real-time = ( if v-time-start <> "":U then integer( v-time-start ) else ? )
      .
    &elseif "{2}" = "after"  &then
      assign
        {2}_real-time = ( if v-time-end <> "":U then integer( v-time-end ) else ? )
      .
    &endif

    find first buf_rvs-doc_{2} no-lock          /* {2} слива */
        where buf_rvs-doc_{2}.out-code = buf_trn-doc.doc-code
          and buf_rvs-doc_{2}.rvs-type = {&rvs-{2}-doc}
    no-error.
    assign
        v-have-rvs-{2} = ( available buf_rvs-doc_{2} )
    .

    if {2}_real-time = ? then do: /* если attr отсутствует, то читаем из сверки */
      if v-have-rvs-{2} = yes /* Только если есть сверки. Если нет - все количества после = 0 */
      then do:
          for each buf_rvs-line_{2} no-lock
            where buf_rvs-line_{2}.rvs-code = buf_rvs-doc_{2}.rvs-code
              and buf_rvs-line_{2}.obj-type = buf_trn-doc.obj-type
              and buf_rvs-line_{2}.obj-code = buf_trn-doc.obj-code
              and buf_rvs-line_{2}.gds-code = buf_goods.gds-code
          :
              if {2}_real-time = ? or
                &if     "{2}" = "before" &then
                {2}_real-time < buf_rvs-line_{2}.real-time
                &elseif "{2}" = "after"  &then
                {2}_real-time > buf_rvs-line_{2}.real-time
                &endif
              then do:
                  assign
                    {2}_real-time = buf_rvs-line_{2}.real-time
                  .
              end.
          end. /* for each buf_rvs-line_{2} */
      end. /* если есть сверки */
    end.
&endif

&if "{1}" = "rvs-line" &then
    if doc-line_1st-run = yes
    then do:
      assign
        v-delta-mass = buf_doc-line.doc-qnty * buf_doc-line.doc-density
      .
      if lookup( varstfactpl, "auto-tank,inv" ) > 0 then do:
        assign
          v-delta-mass = v-delta-mass - v-tank-weight-dec.
          doc-line_1st-run = no
        .
      end.
    end.
    if v-have-rvs-{2} = yes /* Только если есть сверки. Если нет - все количества после = 0 */
    then do:
        for each buf_rvs-line_{2} no-lock
           where buf_rvs-line_{2}.rvs-code = buf_rvs-doc_{2}.rvs-code
             and buf_rvs-line_{2}.obj-type = buf_trn-doc.obj-type
             and buf_rvs-line_{2}.obj-code = buf_trn-doc.obj-code
             and buf_rvs-line_{2}.gds-code = buf_goods.gds-code
        :
        assign
          {2}_qnty        = {2}_qnty        + buf_rvs-line_{2}.state-measure-qnty
          {2}_temperature = {2}_temperature + buf_rvs-line_{2}.state-temperature
                                            * buf_rvs-line_{2}.state-measure-qnty
          {2}_cli-qnty    = {2}_cli-qnty    + buf_rvs-line_{2}.state-measure-cli-qnty
        .
        if lookup( varstfactpl, "auto-tank,inv" ) = 0 then do:
            assign
              v-delta-mass = v-delta-mass
            &if     "{2}" = "before" &then
                +
            &elseif "{2}" = "after"  &then
                -
            &endif
                buf_rvs-line_{2}.state-measure-cli-qnty
              doc-line_1st-run = no
            .
        end.
&endif

&if "{1}" = "rvs-line-end" &then
        end. /* for each buf_rvs-line_{2} */
        assign
          {2}_temperature = {2}_temperature / {2}_qnty
          {2}_density     = {2}_cli-qnty    / {2}_qnty
        .
    end. /* if v-have-rvs-{2} = yes */
&endif

&if "{1}" = "print-field" &then
    if v-have-rvs-{7} = yes
    then do:
        if {2} <> ?
            then put stream out-stream
                {2}
                                            format "{3}"    at right-field( {4} - {5}, {6})
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( {4} - {5}, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at {4}
    .
&endif

/* $Workfile$   E n d */