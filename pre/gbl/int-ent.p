block-level on error undo, throw.
define output parameter l-order-normal as logical no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: int-ent.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/int-ent.p $":U .
def var vss-description as character no-undo init "Определяет порядок, в котором перечислены процедуры в internal-entries".
def var v-first-proc as character no-undo .
assign
  v-first-proc = entry(1, this-procedure :internal-entries)
.
if v-first-proc = "test1":u then do:
  assign
    l-order-normal = true
  .
  return .
end.
if v-first-proc = "test3":u then do:
  assign
    l-order-normal = false
  .
  return .
end.
message
  vss-workfile vss-revision vss-description skip
  "v-first-proc" v-first-proc skip
  "internal-entries" this-procedure :internal-entries skip
  view-as alert-box error .
undo, return error .
procedure test1 :
end procedure.
procedure test2 :
end procedure.
procedure test3 :
end procedure.
