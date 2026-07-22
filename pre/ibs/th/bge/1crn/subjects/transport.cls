using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.transport_section from propath.
using ibs.th.bge.1crn.subjects.transport_section_calibration-table from propath.
using ibs.th.bge.1crn.subjects.transport from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.transport inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define property code_       as character    no-undo get.
      private set.
   define property del-l       as integer      no-undo get.
      private set.
   define property del-f       as integer      no-undo get.
      private set.
   define property ac-type     as integer      no-undo get.
      private set.
   define property mark        as character    no-undo get.
      private set.
   define property reg-num     as character    no-undo get.
      private set.
   define property tr-owner    as character    no-undo get.
      private set.
   define property is-ac       as integer      no-undo get.
      private set.
   define property name_       as character    no-undo get.
      private set.
   define property ess         as integer      no-undo get.
      private set.
   define property neck-type   as integer      no-undo get.
      private set.
   define property me-vlm      as decimal      no-undo get.
      private set.
   define property ac-tk       as decimal      no-undo get.
      private set.
   define property valve       as integer      no-undo get.
      private set.
   define property con-sleeve  as decimal      no-undo get.
      private set.
   define property sections    as subjects     no-undo get.
      private set.
   define property calibration-table    as subjects     no-undo get.
      private set.
   define override property InitTag as character no-undo init "transport"
      get.
   constructor public transport ():
      InitListTag = "sections,calibration-table".
   end constructor.
   method override protected void SetPropProtected (inTag as char, inValue as char):
      case inTag:
         when "code" then
            do:
               assign
                  code_ = inValue .
            end.
         when "del-l" then
            do:
               assign
                  del-l = integer(inValue) .
            end.
         when "del-f" then
            do:
               assign
                  del-f = integer(inValue) .
            end.
         when "ac-type" then
            do:
               assign
                  ac-type = integer(inValue) .
            end.
         when "mark" then
            do:
               assign
                  mark = inValue.
            end.
         when "reg-num" then
            do:
               assign
                  reg-num = replace(inValue, " ", "").
            end.
         when "tr-owner" then
            do:
               assign
                  tr-owner = inValue.
            end.
         when "is-ac" then
            do:
               assign
                  is-ac = integer(inValue) .
            end.
         when "name" then
            do:
               assign
                  name_ = inValue.
            end.
         when "ess" then
            do:
               assign
                  ess = integer(inValue).
            end.
         when "neck-type" then
            do:
               assign
                  neck-type = integer(inValue) .
            end.
         when "me-vlm" then
            do:
               assign
                  me-vlm = decimal(inValue) .
            end.
         when "ac-tk" then
            do:
               assign
                  ac-tk = decimal(inValue) .
            end.
         when "valve" then
            do:
               assign
                  valve = integer(inValue) .
            end.
         when "con-sleeve" then
            do:
               assign
                  con-sleeve = decimal(inValue) .
            end.
      end case.
   end.
   method override protected void SetPropProtected(SubsObj as subjects):
      case SubsObj:InitTag:
         when "sections" then
            do:
               sections = SubsObj.
            end.
         when "calibration-table" then
            do:
               calibration-table = SubsObj.
            end.
      end case.
   end.
   method override protected void CheckData ():
      def var v-str as char no-undo.
      assign
         v-str = v-str + ",ac-type"
         when ac-type = ?
         v-str = v-str + ",neck-type"
         when neck-type = ? and ess = 0
         v-str = v-str + ",me-vlm"
         when me-vlm = ? and ess = 0
         v-str = v-str + ",ac-tk"
         when ac-tk = ? and ess = 0
         .
      v-str = trim (v-str, ",").
      if v-str > ''
         then
         undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
   end.
   method override protected void ClearSub():
      assign
         code_     = ?
         del-l     = ?
         del-f     = ?
         ac-type   = ?
         mark      = ?
         reg-num   = ?
         tr-owner  = ?
         is-ac     = ?
         name_     = ?
         neck-type = ?
         me-vlm    = ?
         ac-tk     = ?
         ess       = ?
         valve     = ?
         con-sleeve = ?
         .
      delete object sections no-error .
      delete object calibration-table no-error .
   end.
end class.
