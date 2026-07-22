using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.ptrl.par.ptrlpropproc:
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
        , input 'petrol':U
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
          when 'denstclc':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
              assign
                objOptPtrl:ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          when 'expptrl':U then do:
            if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
              and thbjattr_thbj-attr.prop-value-type = 'character':U
            then do:
              assign
                objOptPtrl:ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          when 'inpptrl':U then do:
            if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
              and thbjattr_thbj-attr.prop-value-type = 'character':U
            then do:
              assign
                objOptPtrl:ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          when 'autopump':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
              assign
                objOptPtrl:ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when 'rvsnmter':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
              assign
                objOptPtrl:ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when 'avtinvpm':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
              assign
                objOptPtrl:ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when 'invclipt':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
              assign
                objOptPtrl:ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
              .
            end.
          end.
          when 'olddens':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
              assign
                objOptPtrl:ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when 'algrvspt':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
              assign
                objOptPtrl:ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
              .
            end.
          end.
          when 'temp-for-pomi':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
              assign
                objOptPtrl:ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
              .
            end.
          end.
          when 'algoincome':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
              assign
                objOptPtrl:ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
              .
            end.
          end.
          when 'mand-choice-autocar':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
              assign
                objOptPtrl:ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
              .
            end.
          end.
          when 'Delta-mass-horiz':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
              assign
                objOptPtrl:ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
          when 'Delta-mass-vert':U then do:
            if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
              assign
                objOptPtrl:ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
              .
            end.
          end.
        end case.
        delete thbjattr_thbj-attr .
      end.
      return objOptPtrl.
  end method.
end class.
