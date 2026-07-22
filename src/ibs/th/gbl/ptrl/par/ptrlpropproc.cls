 
 /*------------------------------------------------------------------------
    File        : prlpropproc
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : asmorozov
    Created     : Mon Oct 01 17:32:10 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.gbl.ptrl.par.ptrlpropproc: 
  
  { cmp/str-glbl.i class}
  
  define static temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
  
  define static private property ObjType as character no-undo
    get.
    set.
  
  define static private property ObjCode as integer no-undo
    get.
    set.
  
  
  method static class ibs.th.gbl.ptrl.par.ptrlprop GetPropPtrl (p-obj-type as character, p-obj-code as integer):
      
    ObjType = p-obj-type.
    ObjCode = p-obj-code.
    return get-ptrl-prop ().
  
  end.


  method static private ibs.th.gbl.ptrl.par.ptrlprop get-ptrl-prop ():
  
      define variable par-type          as character no-undo.
      define variable v-value-character as character no-undo .
      define variable v-value-date      as date      no-undo .
      define variable v-value-decimal   as decimal   no-undo .
      define variable v-value-integer   as integer   no-undo .
      define variable v-value-logical   as logical   no-undo .
      define variable objOptPtrl        as class ibs.th.gbl.ptrl.par.ptrlprop no-undo .
  
      for each thbjattr_thbj-attr
      :
        delete thbjattr_thbj-attr .
      end.
      run adm/shattri.p
        ( input "get":U
        , input ibs.th.gbl.ptrl.par.ptrlpropproc:ObjType
        , input ibs.th.gbl.ptrl.par.ptrlpropproc:ObjCode
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
  
      objOptPtrl = new ibs.th.gbl.ptrl.par.ptrlprop ().
  
      for each thbjattr_thbj-attr
      on error undo, return error return-value
      :
        case thbjattr_thbj-attr.prop-code :
          when {&attr-petrol_denstclc} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character} then do:
              assign
                objOptPtrl:ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          when {&attr-petrol_expptrl} then do:
            if lookup( thbjattr_thbj-attr.property-value-character, {&calc-petrol-list} ) > 0
              and thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character}
            then do:
              assign
                objOptPtrl:ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          when {&attr-petrol_inpptrl} then do:
            if lookup( thbjattr_thbj-attr.property-value-character, {&calc-petrol-list} ) > 0
              and thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character}
            then do:
              assign
                objOptPtrl:ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          when {&attr-petrol_autopump} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
              assign
                objOptPtrl:ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when {&attr-petrol_rvsnmter} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
              assign
                objOptPtrl:ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when {&attr-petrol_avtinvpm} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
              assign
                objOptPtrl:ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when {&attr-petrol_invclipt} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
              assign
                objOptPtrl:ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
              .
            end.
          end.
          when {&attr-petrol_olddens} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
              assign
                objOptPtrl:ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when {&attr-petrol_algrvspt} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
              assign
                objOptPtrl:ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
              .
            end.
          end.
          when {&attr-petrol_temp-for-pomi} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
              assign
                objOptPtrl:ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
              .
            end.
          end.
          when {&attr-petrol_algoincome} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-integer} then do:
              assign
                objOptPtrl:ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
              .
            end.
          end.
          when {&attr-petrol_mand-choice-autocar} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-logical} then do:
              assign
                objOptPtrl:ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when {&attr-petrol_Delta-mass-horiz} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character} then do:
              assign
                objOptPtrl:ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          when {&attr-petrol_Delta-mass-vert} then do:
            if thbjattr_thbj-attr.prop-value-type = {&ABL-datatype-character} then do:
              assign
                objOptPtrl:ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          
        end case.
        delete thbjattr_thbj-attr .
      end.
      return objOptPtrl.
  
  end method. /* get-ptrl-prop */

end class.