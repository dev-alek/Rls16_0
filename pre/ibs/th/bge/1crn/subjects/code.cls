using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.code abstract inherits ibs.th.bge.1crn.subjects.asubject:
  define property del-l as integer no-undo
    get.
    protected set.
  define property del-f as integer no-undo
    get.
    protected set.
  define property code_ as character no-undo
    get.
    protected set.
  define property old_code_ as character no-undo
    get.
    protected set.
  define property parent_ as character no-undo
    get.
    protected set.
  define property old_parent_ as character no-undo
    get.
    protected set.
  define property misc1 as character no-undo
    get.
    protected set.
  define property misc2 as character no-undo
    get.
    protected set.
  define property misc3 as character no-undo
    get.
    protected set.
  define property misc4 as character no-undo
    get.
    protected set.
  define property misc5 as character no-undo
    get.
    protected set.
  define property misc6 as character no-undo
    get.
    protected set.
  define property misc7 as character no-undo
    get.
    protected set.
  define property misc8 as character no-undo
    get.
    protected set.
  define property misc9 as character no-undo
    get.
    protected set.
  define property misc10 as character no-undo
    get.
    protected set.
  define property codeValue as character no-undo
    get.
    protected set.
  define property codeName as character no-undo
    get.
    protected  set.
  define property status_ as integer no-undo init 0
    get.
    protected  set.
   method private date date-mth (inValue as character):
    inValue = entry (1, inValue, "T").
    return date (integer (entry (2, Invalue, "-")), integer (entry (3, Invalue, "-")), integer (entry (1, Invalue, "-")) ).
  end.
          method override protected void SetPropProtected (inTag as char, inValue as char):
     case inTag:
      when "del-l" then do:
        assign del-l = if inValue >= "" then integer (inValue) else 0.
        if del-l > 0
        then
            status_ = 1.
      end.
      when "del-f" then do:
        assign del-f = if inValue >= "" then integer (inValue) else 0.
      end.
     end case.
  end.
   method override protected void ClearSub():
    assign
      code_         = ?
      old_code_     = ?
      parent_       = ?
      old_parent_   = ?
      del-l         = ?
      del-f         = ?
      CodeName      = ?
      CodeValue     = ?
      misc1         = ?
      misc2         = ?
      misc3         = ?
      misc4         = ?
      misc5         = ?
      misc6         = ?
      misc7         = ?
      misc8         = ?
      misc9         = ?
      misc10        = ?
    .
  end.
end class.
