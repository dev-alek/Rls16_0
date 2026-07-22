using Progress.Lang.*.
block-level on error undo, throw.
interface ibs.th.bge.1crn.subjects.iexpsubject:
  define property Msg as character no-undo
    get.
  define property InitSecTag as character no-undo
    get.
  define property sendTableName  as character  no-undo
    get.
  define property sendOldRowid as rowid  no-undo
    get.
    set.
  define property sendNewRowid as rowid  no-undo
    get.
    set.
  method public void CrContentToSW (sw as handle).
end interface.
