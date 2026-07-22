using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.tank-imp_cal-tbl from propath.
using ibs.th.bge.1crn.subjects.tank-imp from propath.
USING ibs.th.bge.1crn.subjects.tank FROM PROPATH.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.tank-imp inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define property tank-code as character no-undo get.
      private set.
   define property tank-num as integer no-undo get.
      private set.
   define property del-l as integer no-undo get.
      private set.
   define property del-f as integer no-undo get.
      private set.
   define property name_ as character no-undo get.
      private set.
   define property gs-code as character no-undo get.
      private set.
   define property table-version as integer no-undo get.
      private set.
   define property tank-type as integer no-undo get.
      private set.
   define property pl-qnty as decimal no-undo get.
      private set.
   define property max-qnty as decimal no-undo get.
      private set.
   define property d-qnty as decimal no-undo get.
      private set.
   define property tank-d as integer no-undo get.
      private set.
   define property dc-height as integer no-undo get.
      private set.
   define property rel-er as decimal no-undo get.
      private set.
   define property dnsty as decimal no-undo get.
      private set.
   define property main-mi-code as character no-undo get.
      private set.
   define property position_ as integer no-undo get.
      private set.
   define property certifed as integer no-undo get.
      private set.
   define property pipe-er as decimal no-undo get.
      private set.
   define property tank-tk as decimal no-undo get.
      private set.
   define property rvd-dnsty as integer no-undo get.
      private set.
   define property dnst-mi-code as character no-undo get.
      private set.
   define property rvd-lvl as integer no-undo get.
      private set.
   define property lvl-mi-code as character no-undo get.
      private set.
   define property rvd-tmp as integer no-undo get.
      private set.
   define property tmp-mi-code as character no-undo get.
      private set.
   define property gd-code as character no-undo get.
      private set.
   define property izm-pr as integer no-undo get.
      private set.
   define property passport-num as character no-undo get.
      private set.
   define property passport-type as character no-undo get.
      private set.
   define property pontoon as integer no-undo get.
      private set.
   define property wght-pntn as decimal no-undo get.
      private set.
   define property srfcng-pntn as decimal no-undo get.
      private set.
   define property cal-tbl as subjects no-undo get.
      private set.
   define property belt-tbl as subjects no-undo get.
      private set.
   define override property InitTag as character no-undo init "tank"
      get.
   constructor public tank-imp ():
      InitListTag = "cal-tbl,belt-tbl".
   end constructor.
   method override protected void SetPropProtected (inTag as char, inValue as char):
      case inTag:
         when "tank-code" then
            do:
               assign
                  tank-code = inValue .
            end.
         when "tank-num" then
            do:
               assign
                  tank-num = integer(inValue).
            end.
         when "del-l" then
            do:
               assign
                  del-l = integer(inValue).
            end.
         when "del-f" then
            do:
               assign
                  del-f = integer(inValue).
            end.
         when "name" then
            do:
               assign
                  name_ = inValue .
            end.
         when "gs-code" then
            do:
               assign
                  gs-code = inValue.
            end.
         when "table-version" then
            do:
               assign
                  table-version = integer(inValue).
            end.
         when "tank-type" then
            do:
               assign
                  tank-type = integer(inValue).
            end.
         when "pl-qnty" then
            do:
               assign
                  pl-qnty = decimal(inValue).
            end.
         when "max-qnty" then
            do:
               assign
                  max-qnty = decimal(inValue).
            end.
         when "d-qnty" then
            do:
               assign
                  d-qnty = decimal(inValue).
            end.
         when "tank-d" then
            do:
               assign
                  tank-d = integer(inValue).
            end.
         when "dc-height" then
            do:
               assign
                  dc-height = integer(inValue).
            end.
         when "rel-er" then
            do:
               assign
                  rel-er = decimal(inValue).
            end.
         when "dnsty" then
            do:
               assign
                  dnsty = decimal(inValue).
            end.
         when "main-mi-code" then
            do:
               assign
                  main-mi-code = inValue.
            end.
         when "position" then
            do:
               assign
                  position_ = decimal(inValue).
            end.
         when "certified" then
            do:
               assign
                  certifed = integer(inValue).
            end.
         when "pipe-er" then
            do:
               assign
                  pipe-er = decimal(inValue).
            end.
         when "tank-tk" then
            do:
               assign
                  tank-tk = decimal(inValue).
            end.
         when "rvd-dnsty" then
            do:
               assign
                  rvd-dnsty = integer(inValue).
            end.
         when "dnst-mi-code" then
            do:
               assign
                  dnst-mi-code = inValue .
            end.
         when "rvd-lvl" then
            do:
               assign
                  rvd-lvl = integer(inValue).
            end.
         when "lvl-mi-code" then
            do:
               assign
                  lvl-mi-code = inValue.
            end.
         when "rvd-tmp" then
            do:
               assign
                  rvd-tmp = integer(inValue).
            end.
         when "tmp-mi-code" then
            do:
               assign
                  tmp-mi-code = inValue.
            end.
         when "gd-code" then
            do:
               assign
                  gd-code = inValue.
            end.
         when "izm-pr" then
            do:
               assign
                  izm-pr = integer(inValue).
            end.
         when "passport-num" then
            do:
               assign
                  passport-num = inValue.
            end.
         when "passport-type" then
            do:
               assign
                  passport-type = inValue.
            end.
         when "pontoon" then
            do:
               assign
                  pontoon = integer(inValue).
            end.
         when "wght-pntn" then
            do:
               assign
                  wght-pntn = decimal(inValue).
            end.
         when "srfcng-pntn" then
            do:
               assign
                  srfcng-pntn = decimal(inValue).
            end.
      end case.
   end.
   method override protected void SetPropProtected(SubsObj as subjects):
      case SubsObj:InitTag:
         when "cal-tbl" then
            do:
               cal-tbl = SubsObj.
            end.
         when "belt-tbl" then
            do:
               belt-tbl = SubsObj.
            end.
      end case.
   end.
   method override protected void CheckData ():
      def var v-str as char no-undo.
      assign
         v-str = "tank-code"
         when tank-code = ?
         v-str = v-str + ",gs-code"
         when gs-code = ?
         v-str = v-str + ",table-version"
         when table-version = ?
      .
      v-str = trim (v-str, ",").
      if v-str > ''
         then
         undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
   end.
   method override protected void ClearSub():
      assign
         tank-code     = ?
         tank-num      = ?
         del-l         = ?
         del-f         = ?
         name_         = ?
         gs-code       = ?
         table-version = ?
         tank-type     = ?
         pl-qnty       = ?
         max-qnty      = ?
         d-qnty        = ?
         tank-d        = ?
         dc-height     = ?
         rel-er        = ?
         dnsty         = ?
         main-mi-code  = ?
         position_     = ?
         certifed      = ?
         pipe-er       = ?
         tank-tk       = ?
         rvd-dnsty     = ?
         dnst-mi-code  = ?
         rvd-lvl       = ?
         lvl-mi-code   = ?
         rvd-tmp       = ?
         tmp-mi-code   = ?
         gd-code       = ?
         izm-pr        = ?
         passport-num  = ?
         passport-type = ?
         pontoon       = ?
         wght-pntn     = ?
         srfcng-pntn   = ?
         .
      delete object cal-tbl no-error .
      delete object belt-tbl no-error .
   end.
end class.
