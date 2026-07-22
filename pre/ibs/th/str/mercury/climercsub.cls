using Progress.Lang.*.
using ibs.th.str.clients.*.
using ibs.th.str.gds.*.
using ibs.th.gbl.storage.*.
block-level on error undo, throw.
class ibs.th.str.mercury.climercsub implements ithsub:
  define property GUID_ as integer no-undo
    get.
    set.
end class.
