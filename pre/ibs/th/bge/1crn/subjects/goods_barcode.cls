using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.goods_barcode inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define property bcode         as character    no-undo get. private set.
    define property unit-code     as character    no-undo get. private set.
    define property coeff         as decimal      no-undo get. private set.
    define property barcode-type  as integer      no-undo get. private set.
    define override  property InitTag as character no-undo init "barcode"
      get.
    method override protected void SetPropProtected( input inTag as character, input inValue as character ):
      case inTag:
          when "bcode" then
            do:
              assign
                bcode = inValue no-error.
            end.
          when "unit-code" then
            do:
              assign
                unit-code = inValue no-error.
            end.
          when "coeff" then
            do:
              assign
                coeff = decimal(inValue) no-error.
            end.
          when "barcode-type" then
            do:
              assign
                barcode-type = integer(inValue) no-error.
            end.
      end case.
    end method.
    method override protected void CheckData(  ):
      def var v-str as char no-undo.
      assign
        v-str = "bcode" when bcode = ?
        v-str = v-str + ",unit-code" when unit-code = ?
        v-str = v-str + ",coeff" when coeff = ?
      .
      v-str = trim (v-str, ",").
      if v-str > ''
      then
        undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
    end method.
    method override protected void ClearSub(  ):
      assign
        bcode = ?
        unit-code = ?
        coeff = ?
        barcode-type = ?
      .
    end method.
end class.
