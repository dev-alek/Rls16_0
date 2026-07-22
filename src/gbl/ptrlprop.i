/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить всю секцию с настройками по топливу в переменные

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def"  &then
{ gbl/thbj-def.i  }

define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial {&calc-petrol-weight} .
define variable ptrlprop-expptrl       as character no-undo initial {&calc-petrol-volume} .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .

procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .

    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input {&attr-petrol}
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .

    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when {&attr-petrol_denstclc} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character} then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when {&attr-petrol_expptrl} then do:
          if lookup( thbjattr_thbj-attr.property-value-character, {&calc-petrol-list} ) > 0
            and thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character}
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when {&attr-petrol_inpptrl} then do:
          if lookup( thbjattr_thbj-attr.property-value-character, {&calc-petrol-list} ) > 0
            and thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character}
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when {&attr-petrol_autopump} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_rvsnmter} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_avtinvpm} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_invclipt} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when {&attr-petrol_olddens} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_algrvspt} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when {&attr-petrol_temp-for-pomi} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when {&attr-petrol_algoincome} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when {&attr-petrol_mand-choice-autocar} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_block-nozzle} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_timeout-block-nozzle} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.        
        when {&attr-petrol_Delta-mass-horiz} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character} then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when {&attr-petrol_Delta-mass-vert} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character} then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when {&attr-petrol_calc-free-vol} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_calc-free-vol-sug} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_trn-reas-sug} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
	      when {&attr-petrol_rvd-own-nb} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when {&attr-petrol_qr-scan-time} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when {&attr-petrol_autopump-skip-time} then do:
          if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.

      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure. /* get-ptrl-prop */

&endif


&if "{1}" = "run"  &then
run get-ptrl-prop in this-procedure
  ( input {2}
  , input {3}
  ) .
&endif

/* $Workfile$ e n d */