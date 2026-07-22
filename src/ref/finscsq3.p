block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finscsq3.p $
$Archive: ref/finscsq3.p $

Список выписок  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/05
Author: Bakhtadze Natalya
Creation date: 08/09/05

*/

{ ref/finscsqd.i }


  CASE p-mode :
    WHEN 'ext-type-stat-date' THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                    AND X_fin-statement.status_  = p-status_  ~
                    AND X_fin-statement.fins-ext-doc-type  = p-fins-ext-doc-type  ~
                    AND (X_fin-statement.doc-date  >= p-start-date  AND ~
                        X_fin-statement.doc-date  <= p-end-date)  ~
          "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                    AND X_fin-statement.status_  = &2&3&2 ~
                    AND X_fin-statement.fins-ext-doc-type  = &2&4&2  ~
                    AND (X_fin-statement.doc-date  >= &5  AND ~
                        X_fin-statement.doc-date  <= &6) ', p-curr-host-code, ~{&double-quote~}, p-status_ , p-fins-ext-doc-type, p-start-date, p-end-date) "

          &use-ind    = " use-index iext-type-status "
          &by         = "  " }
    END.
    WHEN 'ext-type-date' THEN DO:
    { gbl/fltopend.i
        &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                  AND X_fin-statement.fins-ext-doc-type  = p-fins-ext-doc-type  ~
                  AND (X_fin-statement.doc-date  >= p-start-date  AND ~
                      X_fin-statement.doc-date  <= p-end-date)  ~
        "
        &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                  AND X_fin-statement.fins-ext-doc-type  = &2&3&2  ~
                  AND (X_fin-statement.doc-date  >= &4  AND ~
                      X_fin-statement.doc-date  <= &5) ', p-curr-host-code, ~{&double-quote~}, p-fins-ext-doc-type, p-start-date, p-end-date) "

        &use-ind    = " use-index iext-type "
        &by         = "  " }
    END.
    WHEN 'ext-type' THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                    AND X_fin-statement.fins-ext-doc-type  = p-fins-ext-doc-type  ~
          "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                    AND X_fin-statement.fins-ext-doc-type  = &2&3&2', p-curr-host-code, ~{&double-quote~}, p-fins-ext-doc-type) "

          &use-ind    = " use-index iext-type "
          &by         = "  " }
    END.
    WHEN 'ext-type-stat' THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                    AND X_fin-statement.status_  = p-status_  ~
                    AND X_fin-statement.fins-ext-doc-type  = p-fins-ext-doc-type  ~
          "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                    AND X_fin-statement.status_  = &2&3&2  ~
                    AND X_fin-statement.fins-ext-doc-type  = &2&4&2 ', p-curr-host-code, ~{&double-quote~}, p-status_, p-fins-ext-doc-type) "

          &use-ind    = " use-index iext-type-status "
          &by         = "  " }
    END.
    WHEN 'ext-type-stat-start' THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                    AND X_fin-statement.status_  = p-status_  ~
                    AND X_fin-statement.fins-ext-doc-type  = p-fins-ext-doc-type  ~
          "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                    AND X_fin-statement.status_  = &2&3&2  ~
                    AND X_fin-statement.fins-ext-doc-type  = &2&4&2 ', p-curr-host-code, ~{&double-quote~}, p-status_, p-fins-ext-doc-type) "

          &use-ind    = "  "
          &by         = " by X_fin-statement.host-code by X_fin-statement.start-date descending " }
    END.
    WHEN 'ext-type-stat-end' THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                    AND X_fin-statement.status_  = p-status_  ~
                    AND X_fin-statement.fins-ext-doc-type  = p-fins-ext-doc-type  ~
          "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                    AND X_fin-statement.status_  = &2&3&2  ~
                    AND X_fin-statement.fins-ext-doc-type  = &2&4&2', p-curr-host-code, ~{&double-quote~}, p-status_, p-fins-ext-doc-type)"

          &use-ind    = "  "
          &by         = " by X_fin-statement.host-code by X_fin-statement.end-date descending " }
    END.

END CASE.


  end. /*doe*/

end procedure. /* proc-main */