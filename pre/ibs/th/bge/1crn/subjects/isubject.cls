using Progress.Lang.*.
block-level on error undo, throw.
interface ibs.th.bge.1crn.subjects.isubject:
  define public property InitTag as character no-undo
    get.
  method public void SetProp (inTag as char, inValue as char).
  method public void SetProp (inTag as char, inValue as longchar).
end interface.
