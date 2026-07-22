using Progress.Lang.*.
block-level on error undo, throw.
interface ibs.th.gbl.collection.isubjects:
  define property iCounter as integer no-undo
    get.
  define property SubjectObjCurr as Progress.Lang.Object no-undo
    get.
  method public void Add (subObj as Progress.Lang.Object).
  method public void Delete (iNum as int).
  method public integer Get (iNum as int).
end interface.
