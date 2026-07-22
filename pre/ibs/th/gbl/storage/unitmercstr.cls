using Progress.Lang.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.gbl.storage.unitmercstr:
  define buffer buf_units for ub.units.
  define buffer buf_units-attr for ub.units-attr.
  define buffer buf_goods-attr for ub.goods-attr.
  method private void exception( arg as handle, inunitmercObj as class unitsub, t-h as handle ):
    inunitmercObj:setMsg(arg:get-message (1)).
    inunitmercObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    message "Œ¯Ë·Í‡ - "  inunitmercObj:Msg view-as alert-box.
    return.
  end method.
  method public void writeDB( input unitsObj as class unitsubs, input inGdsCode as integer ):
    find first buf_goods-attr where buf_goods-attr.gds-code = inGdsCode
                                and buf_goods-attr.attr-code = 'MercUnits':U no-error .
    if not available (buf_goods-attr)
    then do:
      create buf_goods-attr.
      assign
        buf_goods-attr.gds-code = inGdsCode
        buf_goods-attr.attr-code = 'MercUnits':U
      .
    end.
    setDataStorage(input unitsObj, buffer buf_goods-attr).
    release buf_goods-attr.
    return.
  end method.
  method public void deleteDB( input inGdsCode as integer  ):
    find first buf_goods-attr where buf_goods-attr.gds-code = inGdsCode
                                and buf_goods-attr.attr-code = 'MercUnits':U no-error .
    if not available (buf_goods-attr)
    then do:
      return.
    end.
    delete buf_goods-attr.
    return.
  end method.
  method public class unitsubs getunitmercs (input inGdsCode as integer ):
    define variable ii as integer no-undo .
    define variable unitsObj as class unitsubs no-undo .
    unitsObj = new unitsubs ().
    for first buf_goods-attr where buf_goods-attr.gds-code = inGdsCode
                               and buf_goods-attr.attr-code = 'MercUnits':U:
      do ii = 1 to num-entries(buf_goods-attr.attr-value, chr(4)) :
        unitsObj:AddItem(getDataStorage (entry(ii, buf_goods-attr.attr-value, chr(4)))).
      end.
    end.
    return unitsObj.
  end method.
  method private void setDataStorage (input unitsObj as class unitsubs, buffer inbf_goods-attr for ub.goods-attr ):
    define variable ii as integer no-undo .
    inbf_goods-attr.attr-value = "" .
    do ii = 1 to unitsObj:GetItem(ii) :
      inbf_goods-attr.attr-value = inbf_goods-attr.attr-value
                                 + (if inbf_goods-attr.attr-value = "" then "" else chr(4))
                                 + unitsObj:UnitObjCurr:UnitName + chr(3) + string(unitsObj:UnitObjCurr:UnitCoef) .
    end .
    release inbf_goods-attr.
  end.
  method private class unitsub getDataStorage ( input inAttrValue as character ):
    define variable unitObj  as class unitsub no-undo .
    unitObj = new unitsub ().
    find first buf_units no-lock where buf_units.unit-name = entry(1, inAttrValue, chr(3)) .
    find first buf_units-attr no-lock where buf_units-attr.unit-name = entry(1, inAttrValue, chr(3))
                                       and buf_units-attr.attr-code = "MercGuid" no-error.
    assign
      unitObj:UnitName          = buf_units.unit-name
      unitObj:UnitFullName      = buf_units.long-name
      unitObj:UnitGuid          = if available buf_units-attr then buf_units-attr.attr-value else ""
      unitObj:UnitCoef          = decimal(entry(2, inAttrValue, chr(3)))
    .
    return unitObj.
  end.
end class.
