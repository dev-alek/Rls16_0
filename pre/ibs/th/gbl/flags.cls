using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.flags:
  define property FlagsToInt as integer
    get.
    private set.
  method public void setFlagsToInt(arg as int):
    FlagsToInt = arg.
    return.
  end method.
  method public void unSetAllFlags():
    FlagsToInt = 0.
    return.
  end method.
  method protected logical getFlag(numFlag as int ):
     return logical (get-bits (FlagsToInt, numFlag, 1)).
  end.
  method protected void setFlag(numFlag as int,arg as logical):
       put-bits (FlagsToInt, numFlag, 1) = int(arg).
  end.
end class.
