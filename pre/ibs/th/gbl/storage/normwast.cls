using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.ref.*.
block-level on error undo, throw.
class ibs.th.gbl.storage.normwast:
  define temp-table tt-docperiod no-undo
    field dateBeg as date
    field dateEnd as date
    field fact-qnty-kg as decimal
    index pi dateBeg
  .
  method public void RegDoc (d as date, chg-fact-qnty-kg as decimal):
    def buffer bf_tt-docp for tt-docperiod.
   find first tt-docperiod where tt-docperiod.dateBeg = d + 1 use-index pi no-error.
    if available (tt-docperiod)
    then do:
      tt-docperiod.fact-qnty-kg = tt-docperiod.fact-qnty-kg + chg-fact-qnty-kg.
      return.
    end.
    find first tt-docperiod where tt-docperiod.dateBeg = d use-index pi no-error.
    if available (tt-docperiod)
    then do:
      tt-docperiod.dateBeg = tt-docperiod.dateBeg + 1.
      tt-docperiod.fact-qnty-kg = tt-docperiod.fact-qnty-kg + chg-fact-qnty-kg.
      return.
    end.
    find first tt-docperiod where tt-docperiod.dateEnd = d use-index pi no-error.
    if available (tt-docperiod)
    then do:
      tt-docperiod.dateBeg = tt-docperiod.dateEnd - 1.
      tt-docperiod.fact-qnty-kg = tt-docperiod.fact-qnty-kg + chg-fact-qnty-kg.
      return.
    end.
    find last bf_tt-docp where bf_tt-docp.dateBeg < d and bf_tt-docp.dateEnd > d use-index pi no-error.
    if not available (bf_tt-docp)
    then do:
      message "Документ не зарегистрирован. Дата - " d view-as alert-box.
      return.
    end.
    create tt-docperiod.
    tt-docperiod.dateBeg = d + 1.
    tt-docperiod.dateEnd = bf_tt-docp.dateEnd.
    bf_tt-docp.dateEnd = d.
    tt-docperiod.fact-qnty-kg = bf_tt-docp.fact-qnty-kg + chg-fact-qnty-kg.
    finally:
      release tt-docperiod.
      output to 123 append.
      put "-------" skip.
      for each tt-docperiod:
        export tt-docperiod.
      end.
      output close.
    end.
  end.
  method public void RegDocPeriod (d1 as date, d2 as date, fact-qnty-kg as decimal):
    empty temp-table tt-docperiod.
    create tt-docperiod.
    tt-docperiod.dateBeg = d1.
    tt-docperiod.dateEnd = d2.
    tt-docperiod.fact-qnty-kg = fact-qnty-kg.
  end.
  method public void CalcWastNorm (objNormWastSub as class normwastsub):
    output to decommissioned.txt append.
    put now skip.
    put "-------" skip.
    export "Товар - " objNormWastSub:ParGdsOAttr:GdsCode ". Место хранения - " objNormWastSub:ParGdsOAttr:PlCode.
    for each tt-docperiod use-index pi:
      CaclQDaysSeason (objNormWastSub, tt-docperiod.dateBeg, tt-docperiod.dateEnd, tt-docperiod.fact-qnty-kg).
      export tt-docperiod.
    end.
    put "-------" skip.
    output close.
  end.
  method private void CaclQDaysSeason(objNormWastSub as class normwastsub, d1 as date, d2 as date, fact-qnty-kg as decimal):
    def var yy1 as int  no-undo.
    def var yy2 as int  no-undo.
    def var daySummer   as int no-undo.
    def var monthSummer as int no-undo.
    def var dayWinter   as int no-undo.
    def var monthWinter as int no-undo.
    def var ii  as int  no-undo.
    yy1 = year (d1).
    yy2 = year (d2).
    daySummer = day (objNormWastSub:BeginSummer).
    monthSummer = month (objNormWastSub:BeginSummer).
    dayWinter = day (objNormWastSub:BeginSummer).
    monthWinter = month (objNormWastSub:BeginWinter).
    if yy1 - yy2 > 0
    then do:
      CaclQDaysSeasonByYear
        (
          d1, date (12, 31, yy1),
          date (monthSummer, daySummer, yy1), date (monthWinter, dayWinter, yy2)
          , objNormWastSub
          , fact-qnty-kg
        ).
      CaclQDaysSeasonByYear
        (
          date (01, 01, yy1), d2,
          date (monthSummer, daySummer, yy1), date (monthWinter, dayWinter, yy2)
          , objNormWastSub
          , fact-qnty-kg
        ).
      do ii = yy1 + 1 to yy2 - 1:
        CaclQDaysSeasonByYear
          (
            date (01, 01, yy1), date (12, 31, yy1),
            date (monthSummer, daySummer, yy1), date (monthWinter, dayWinter, yy2)
          , objNormWastSub
          , fact-qnty-kg
          ).
      end.
    end.
    else do:
      CaclQDaysSeasonByYear
        (
          d1, d2,
          date (monthSummer, daySummer, yy1), date (monthWinter, dayWinter, yy2)
          , objNormWastSub
          , fact-qnty-kg
        ).
    end.
  end.
  method private void CaclQDaysSeasonByYear
    ( d1 as date, d2 as date , p1 as date, p2 as date, objNormWastSub as class normwastsub, fact-qnty-kg as decimal)
  :
    def var sqdays      as int init 0 no-undo.
    def var wqdays      as int init 0 no-undo.
    def var wqdays1 as int no-undo.
    def var wqdays2 as int no-undo.
    sqdays = (min (p2,d2) - max (p1,d1)) + 1.
    if sqdays < 0
    then do:
      wqdays = (d2 - d1) .
      sqdays = 0.
    end.
    else do:
      wqdays1 = d2 - p2.
      wqdays2 = p1 - d1.
      wqdays = max (0,wqdays1) + max (0,wqdays2) .
    end.
    export "Qnty kg " fact-qnty-kg "Qnty Day Summer " sqdays "EUH Norm Summer " objNormWastSub:NormalWastageSummer " EUH Summer " ((fact-qnty-kg * objNormWastSub:NormalWastageSummer) * sqdays / 30000).
    export "Qnty kg " fact-qnty-kg "Qnty Day Winter " wqdays "EUH Norm Winter " objNormWastSub:NormalWastageWinter "EUH Winter " ((fact-qnty-kg * objNormWastSub:NormalWastageWinter) * wqdays / 30000).
    assign
      objNormWastSub:NormWastS = objNormWastSub:NormWastS + (fact-qnty-kg * objNormWastSub:NormalWastageSummer) * sqdays / 30000
      objNormWastSub:NormWastW = objNormWastSub:NormWastW + (fact-qnty-kg * objNormWastSub:NormalWastageWinter) * wqdays / 30000
    .
  end.
end class.
