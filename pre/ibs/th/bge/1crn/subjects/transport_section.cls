using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.transport_section from propath.
using ibs.th.bge.1crn.subjects.transport_section_calibration-table from propath.
using ibs.th.bge.1crn.subjects.transport from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.transport_section inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define property sec-num         as integer    no-undo get.
      private set.
   define property capacity        as decimal    no-undo get.
      private set.
   define property min-of-lvl      as decimal    no-undo get.
      private set.
   define property max-of-lvl      as decimal    no-undo get.
      private set.
   define property diameter        as decimal    no-undo get.
      private set.
   define property length_         as decimal    no-undo get.
      private set.
   define property width_          as decimal    no-undo get.
      private set.
   define property circumference   as decimal    no-undo get.
      private set.
   define property wall            as decimal    no-undo get.
      private set.
   define property pipe-vlm        as decimal    no-undo get.
      private set.
   define override property InitTag as character no-undo init "section"
      get.
   method override protected void SetPropProtected (inTag as char, inValue as char):
      case inTag:
         when "sec-num" then
            do:
               assign
                  sec-num = integer(inValue) .
            end.
         when "capacity" then
            do:
               assign
                  capacity = decimal(inValue) .
            end.
         when "min-of-lvl" then
            do:
               assign
                  min-of-lvl = decimal(inValue) .
            end.
         when "max-of-lvl" then
            do:
               assign
                  max-of-lvl = decimal(inValue).
            end.
         when "diameter" then
            do:
               assign
                  diameter = decimal(inValue).
            end.
         when "length" then
            do:
               assign
                  length_ = decimal(inValue).
            end.
         when "width" then
            do:
               assign
                  width_ = decimal(inValue).
            end.
         when "circumference" then
            do:
               assign
                  circumference = decimal(inValue).
            end.
         when "wall" then
            do:
               assign
                  wall = decimal(inValue).
            end.
         when "pipe-vlm" then
            do:
               assign
                  pipe-vlm = decimal(inValue).
            end.
      end case.
   end.
   method override protected void CheckData ():
      def var v-str as char no-undo.
      assign
         v-str = v-str + "sec-num"
         when sec-num = ?.
      if v-str > ''
         then
         undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
   end.
   method override protected void ClearSub():
      assign
         sec-num       = ?
         capacity      = ?
         min-of-lvl    = ?
         max-of-lvl    = ?
         diameter      = ?
         length_       = ?
         width_        = ?
         circumference = ?
         wall          = ?
         pipe-vlm      = ?
         .
   end.
end class.
