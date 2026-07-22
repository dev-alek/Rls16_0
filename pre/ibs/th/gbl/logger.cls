using Progress.Lang.*.
using ibs.th.gbl.logger.putout.
block-level on error undo, throw.
class ibs.th.gbl.logger:
   define private variable out as class putout no-undo.
  constructor public logger ( inOut as class putout ):
    super ().
  end constructor.
  method public void EventHndlr(inMsg as char):
    return.
  end method.
end class.
