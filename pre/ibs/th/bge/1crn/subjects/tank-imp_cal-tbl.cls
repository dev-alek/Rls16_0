using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.tank-imp_cal-tbl from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.tank-imp_cal-tbl inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define property lvl_ as decimal no-undo get.
      private set.
   define property amnt as decimal no-undo get.
      private set.
   define property comp-err as decimal no-undo get.
      private set.
   define property deltaV as decimal no-undo get.
      private set.
   define override property InitTag as character no-undo init "cal-tbl-line"
      get.
   method override protected void SetPropProtected (inTag as char, inValue as char):
      case inTag:
         when "lvl" then
            do:
               assign
                  lvl_ = decimal(inValue) .
            end.
         when "amnt" then
            do:
               assign
                  amnt = decimal(inValue) .
            end.
         when "comp-err" then
            do:
               assign
                  comp-err = decimal(inValue) .
            end.
         when "deltaV" then
            do:
               assign
                  deltaV = decimal(inValue) .
            end.
      end case.
   end.
   method override protected void CheckData ():
      def var v-str as char no-undo.
      assign
         v-str = v-str + ",lvl"
         when lvl_ = ?
         v-str = v-str + ",amnt"
         when amnt = ?
         .
      v-str = trim (v-str, ",").
      if v-str > ''
         then
         undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
   end.
   method override protected void ClearSub():
      assign
         lvl_     = ?
         amnt     = ?
         comp-err = ?
         deltaV   = ?
      .
   end.
end class.
