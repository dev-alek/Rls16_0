using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.sobj.sParamForm:
   define public variable init-date-start  as date no-undo .
   define public variable init-date-end    as date no-undo .
   define public variable init-date-alone  as date no-undo .
   define public variable init-shift-alone as integer  no-undo .
   define public variable init-shift-start as integer no-undo .
   define public variable init-shift-end   as integer   no-undo .
   define public variable init-set_pay_type as integer   no-undo .
   define public variable init-set_val_type as integer   no-undo .
   define public variable ref_date-start    as character   no-undo .
   define public variable ref_date-end      as character   no-undo .
   define public variable ref_date-alone    as character   no-undo .
   define public variable  Name-Sale-price   as character no-undo .
   define public variable  Format-Folder     as logical no-undo .
   define public variable  Verify-Arc-ot      as logical  no-undo init false.
   define public variable  Verify-Arc-stk     as logical  no-undo init false.
   define public variable  Verify-Arc-supp    as logical  no-undo init false.
   define public variable  Verify-Arc-hold    as logical  no-undo init false.
   define public variable  Verify-Arc-aht     as logical  no-undo init false.
   define public variable  Verify-send-check  as logical  no-undo init false.
   define public variable  Verify-Arc-fin     as logical  no-undo init false.
   define public variable  Verify-Arc-strong  as logical  no-undo init false.
   define public variable params-only      as logical   no-undo .
   define public variable temp-str                    as char no-undo.
   define public variable temp-param-date             as integer  no-undo.
   define public variable temp-param-date-type-period as character no-undo.
   define public variable temp-param-goods            as character.
   define public variable temp-param-obj              as character.
   define public variable temp-param-obj-type         as character.
   define public variable temp-param-Pay              as character.
   define public variable temp-param-Pay-hide         as character.
   define public variable temp-param-alon             as logical.
   define public variable temp-param-customer         as character no-undo .
   define public variable temp-param-customer-type    as character no-undo .
   define public variable temp-param-schet            as character no-undo .
   define public variable  temp-param-schet-hide      as character no-undo .
   define public variable  temp-param-schet-init      as character no-undo .
   define public variable  temp-param-schet-mode      as character no-undo .
   define public variable all-object                  as logical   no-undo.
   define public variable my-request                  as logical  init false no-undo.
   define public variable var-report-r-b as character no-undo .
   define public variable v-r-b as character no-undo .
   define public variable gdsgrp_recids      as character no-undo.
   constructor public sParamForm (  ):
      super ().
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$".
run curr-r-b in ibs.th.gbl.gbl-hndllib:g#library
  (output var-report-r-b
  )  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$".
run curr-r-b in ibs.th.gbl.gbl-hndllib:g#library
  (output v-r-b
  )  .
   end constructor.
   destructor public sParamForm ( ):
   end destructor.
end class.
