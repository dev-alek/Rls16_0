using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.trn-prt inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property gd-line-num as character no-undo
    get.
    private set.
  define property prt-id as character no-undo
    get.
    private set.
  define property in-doc-id as character no-undo
    get.
    private set.
  define property edoc-id as character no-undo
    get.
    private set.
  define property vad-guid as character no-undo
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
  define property gds-code as integer no-undo
    get.
    private set.
  define property qnty as decimal no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "prt"
    get.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "gd-line-num" then do:
        assign gd-line-num = inValue.
      end.
      when "prt-id" then do:
        assign prt-id = inValue.
      end.
      when "in-doc-id" then do:
        assign in-doc-id = inValue.
      end.
      when "edoc-id" then do:
        assign edoc-id = inValue.
      end.
      when "vad-guid" then do:
        assign vad-guid = inValue.
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
      when "qnty" then do:
        assign qnty = decimal (inValue) .
      end.
      when "gds-code" then do:
        assign gds-code = integer (inValue) .
      end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = v-str + ",qnty-ttn" when qnty-fact = ?
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      gd-line-num  = ?
      prt-id    = ?
      in-doc-id = ?
      edoc-id   = ?
      qnty      = ?
      vad-guid  = ?
      qnty-ttn  = ?
      qnty-fact = ?
      sum       = ?
      sum-nds   = ?
      nds-code  = ?
      gds-code  = ?
    .
  end.
end class.
