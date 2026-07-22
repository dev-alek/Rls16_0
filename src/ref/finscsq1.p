block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finscsq1.p $
$Archive: ref/finscsq1.p $

Список выписок  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/finscsqd.i }

  CASE p-mode :
    WHEN {&all}        THEN DO:
      { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind    = "  "
          &by         = "  " }
    END.
    WHEN {&company} THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1', p-curr-host-code ) "
          &use-ind    = " use-index idoc-date "
          &by         = "  " }
    END.
    WHEN "currency":U THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code = p-curr-host-code AND X_fin-statement.curr-code = p-curr-code  "
          &dyn_where-cond = " substitute('X_fin-statement.host-code = &1 AND X_fin-statement.curr-code = &2  ', p-curr-host-code, p-curr-code)"
          &use-ind    = " use-index idoc-date  "
          &by         = "  " }
    END.
    WHEN "code-bank":U THEN DO:
          { gbl/fltopend.i
              &where-cond = " X_fin-statement.host-code  = p-curr-host-code and X_fin-statement.code-bank = p-code-bank "
              &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1 and X_fin-statement.code-bank = &2 ', p-curr-host-code, p-code-bank)"
              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
    END.
    WHEN "code-schet":U THEN DO:
          { gbl/fltopend.i
              &where-cond = " X_fin-statement.host-code  = p-curr-host-code and X_fin-statement.code-bank = p-code-bank ~
                                                                      and X_fin-statement.code-schet = p-code-schet "
              &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1 and X_fin-statement.code-bank = &2 ~
                                                                      and X_fin-statement.code-schet = &3 ', p-curr-host-code, p-code-bank, p-code-schet)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
    END.
END CASE.


  end. /*doe*/

end procedure. /* proc-main */