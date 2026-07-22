using Progress.Lang.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.skt.ControlledClients.flagsdocline inherits flags:
  define property isEditManualFullQnty as logical no-undo
    get:
      return getFlag(1).
    end.
    set (arg as log):
       setFlag(1, arg).
    end.
  define property isNotEditManualQnty as logical no-undo
    get:
      return getFlag(2).
    end.
    set (arg as log):
      setFlag(2, arg).
    end.
    define property isMarkOn as logical no-undo
    get:
      return getFlag(3).
    end.
    set (arg as log):
       setFlag(3, arg).
    end.
    define property isVarietalVolumeOn as logical no-undo
    get:
      return getFlag(4).
    end.
    set (arg as log):
       setFlag(4, arg).
    end.
end class.
