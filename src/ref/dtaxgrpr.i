/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура показа налогов для группы товаров - толкач

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE proc-b-tax:
define input parameter parparentproc    as handle           no-undo.
define input parameter p-host-code      as character        no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define parameter buffer loc-gds-grp for ub.gds-grp.
define input parameter loc-mode as character no-undo .
DEFINE VARIABLE locfor-title as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer b_tt-tax for tt-tax.
if NOT can-find(first tt-tax No-LOCK ) then do:
  bell.
  return error.
end.

FOR EACH output-tax:
  DELETE output-tax.
END.

locfor-title =  "Ставки налогов и их значения: " +
                (if loc-mode = {&add-def}
                 then frame {&frame-name}:title
                 else ( "группа " + string(loc-gds-grp.node-name))
                 ).
run ref/taxgtree.w (
               input table tt-tax,
               output table output-tax,
               input parparentproc,
               input loc-mode,
               input "GDS-GRP":U,
               input ?,
               input (if loc-mode = {&add-def}
                      then ? else
                      loc-gds-grp.node-code),
               input p-host-code,
               input p-obj-type,
               input p-obj-code,
               input locfor-title) no-error .
if error-status:error then return error.
DO on error UNDO, return error:
  FOR EACH tt-tax break by tt-tax.tax-code:
    if first-of(tt-tax.tax-code) then do:
      if tt-tax.individual then next.
      for each output-tax where
              output-tax.tax-code = tt-tax.tax-code:
        if output-tax.tax-rate-gds-rc <> ? then do:
          find first b_tt-tax where
                     b_tt-tax.tax-rate-gds-rc = output-tax.tax-rate-gds-rc .
          buffer-copy
          output-tax to b_tt-tax.
        end.
        run cur-time in this-procedure(output v-today, output v-time).
        if output-tax.tax-rate-gds-rc = ? and output-tax.fact-date > v-today then do:
          create b_tt-tax.
          buffer-copy
          output-tax to b_tt-tax.
        end.
      end. /*for each output-tax*/
    end. /*if first-of */
  END. /*for each tt-tax*/
END.
END PROCEDURE.

/* $Workfile$ e n d */