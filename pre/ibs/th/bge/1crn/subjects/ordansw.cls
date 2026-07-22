using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.ordansw inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property order-item as integer no-undo init ?
    get.
    private set.
  define property order-item-ext as character no-undo
    get.
    private set.
  define property sts as integer no-undo
    get.
    private set.
  define property mess as character no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "ordansw"
    get.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "order-item" then do:
        assign order-item = int(inValue) no-error.
      end.
      when "order-item-external" then do:
        assign order-item-ext = inValue.
      end.
      when "status" then do:
        assign sts = int(inValue) no-error.
      end.
      when "message" then do:
        assign mess = inValue .
      end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = "order-item" when order-item = ?
      v-str = v-str + ",order-item-external" when order-item-ext = ? and sts = 6
      v-str = v-str + ",status" when sts = ?
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределенное значение", v-str)).
    if not can-do("0,1,2,3,4,5,6",string(sts))
    then
      undo, throw new Progress.Lang.AppError( substitute ("“ег answer может принимать значени€ &1", "0,1,2,3,4,5,6")).
  end.
  method override protected void ClearSub():
    assign
      order-item     = ?
      order-item-ext = ?
      sts            = ?
      mess           = ?
    .
  end.
end class.
