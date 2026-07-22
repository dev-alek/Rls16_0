using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.gbl.*.
using ibs.th.bge.1crn.export.send1cerpsub.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.exp-CashParamHist inherits send1cerpsub implements iexpsubject:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Выгрузка кассовых параметров" get.
      define override public property InitSecTag as character no-undo init 'Current-params':U
   get.
   define override public property sendTableName  as character  no-undo init "Cash-param-hist"
   get.
   method override public void CheckParam(  ):
      return.
   end method.
   method private character fConvetDateTime
      (input iTStamp as dec):
     define variable vDateTime as datetime  no-undo.
     define variable vDate     as date      no-undo.
     define variable vDays     as int64     no-undo.
     define variable vSec      as integer   no-undo.
     define variable vTimeZone as character no-undo.
     vDays = truncate(int64(iTStamp) / 3600 / 24, 0).
     vDate = date("01/01/1970") + vDays.
     vSec = (int64(iTStamp) - vDays * 3600 * 24).
     if timezone >= 0
     then
        vTimeZone = "+" + string( timezone * 60,"HH:MM").
     else
        vTimeZone = "-" + string( timezone * -60,"HH:MM").
     return string(iso-date(datetime-tz(string(vDate,"99/99/9999") + " " + string(vSec, "HH:MM:SS" + vTimeZone) ))).
   end method.
   method override public void CrContentToSW( input insw as handle ):
      define buffer code for ub.code.
      for each Cash-param-hist
      no-lock:
         insw:start-element ("Current-param").
         insw:write-data-element (  "sign":U,                     string(Cash-param-hist.device            )).
         insw:write-data-element (  "source":U,                          Cash-param-hist.param_section     ).
         insw:write-data-element (  "section":U,                         Cash-param-hist.param_group       ).
         insw:write-data-element (  "name-current":U,                    Cash-param-hist.param_name        ).
         insw:write-data-element (  "value-current":U,                   Cash-param-hist.param_value       ).
         insw:write-data-element (  "source-value":U,                    Cash-param-hist.param_value_dop   ).
         insw:write-data-element (  "cd-num":U,                   string(Cash-param-hist.cash-num         )).
         insw:write-data-element (  "date-act-check":U, fConvetDateTime (Cash-param-hist.tstamp           )).
         insw:end-element("Current-param").
      end.
      return.
   end method.
end class.
