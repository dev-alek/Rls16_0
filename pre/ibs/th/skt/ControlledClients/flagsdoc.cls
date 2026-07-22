using Progress.Lang.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.skt.ControlledClients.flagsdoc inherits flags:
  define property isDocMarkOn as logical no-undo
    get:
      return getflag (1).
    end.
    set (arg as log):
       setFlag (1,arg).
    end.
end class.
