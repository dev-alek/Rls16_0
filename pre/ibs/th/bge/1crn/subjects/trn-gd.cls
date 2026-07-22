using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.trn-gd inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property line-num as character no-undo
    get.
    private set.
  define property gd-code as integer no-undo
    get.
    private set.
  define property unit-code as character no-undo
    get.
    private set.
  define property koef as decimal no-undo
    get.
    private set.
  define property qnty-ttn as decimal no-undo
    get.
    private set.
  define property qnty-fact as decimal no-undo
    get.
    private set.
  define property sum as decimal no-undo
    get.
    private set.
  define property sum-nds as decimal no-undo
    get.
    private set.
  define property nds-code as decimal no-undo
    get.
    private set.
  define property prts as subjects no-undo
    get.
    private set.
  define property marks as subjects no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "gd"
    get.
  constructor public trn-gd ():
    InitListTag = "prts,marks".
  end constructor.
  method override protected void SetPropProtected(input SubsObj as subjects):
    case SubsObj:InitTag:
      when "marks" then
        do:
          marks = SubsObj.
        end.
      when "prts" then
        do:
          prts = SubsObj.
        end.
    end case.
  end.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "line-num" then do:
        assign line-num = inValue.
      end.
      when "gd-code" then do:
        assign gd-code = integer (inValue).
      end.
      when "unit-code" then do:
        assign unit-code = inValue.
      end.
      when "koef" then do:
        assign koef = decimal (inValue) .
      end.
      when "qnty-ttn" then do:
        assign qnty-ttn = decimal (inValue) .
      end.
      when "qnty-fact" then do:
        assign qnty-fact = decimal (inValue).
      end.
      when "sum" then do:
        assign sum = decimal (inValue).
      end.
      when "sum-nds" then do:
        assign sum-nds = decimal (inValue).
      end.
      when "nds-code" then do:
        assign nds-code = decimal (inValue).
      end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = v-str + ",gd-code" when gd-code = ?
      v-str = v-str + ",unit-code" when unit-code = ?
      v-str = v-str + ",qnty-ttn" when qnty-fact = ?
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      line-num  = ?
      gd-code   = ?
      unit-code = ?
      koef      = ?
      qnty-ttn  = ?
      qnty-fact = ?
      sum       = ?
      sum-nds   = ?
      nds-code  = ?
    .
    delete object prts no-error.
    delete object marks no-error.
  end.
end class.
