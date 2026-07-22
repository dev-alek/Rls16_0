block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finscsq2.p $
$Archive: ref/finscsq2.p $

Список выписок  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/05
Author: Bakhtadze Natalya
Creation date: 08/09/05

*/

{ ref/finscsqd.i }

  CASE p-mode :
    WHEN 'type' THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                    AND X_fin-statement.fins-doc-type  = p-fins-doc-type  ~
          "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                    AND X_fin-statement.fins-doc-type  = &2&3&2 ', p-curr-host-code, ~{&double-quote~}, p-fins-doc-type )"
          &use-ind    = " use-index itype "
          &by         = "  " }
    END.
    WHEN 'type-stat' THEN DO:
        { gbl/fltopend.i
            &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                      AND X_fin-statement.fins-doc-type  = p-fins-doc-type  ~
                      AND X_fin-statement.status_  = p-status_ ~
            "
            &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                      AND X_fin-statement.fins-doc-type  = &2&3&2  ~
                      AND X_fin-statement.status_  = &2&4&2', p-curr-host-code, ~{&double-quote~}, p-fins-doc-type, p-status_ )"

            &use-ind    = " use-index itype-stat "
            &by         = "  " }
    END.
    WHEN 'type-stat-date' THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                    AND X_fin-statement.fins-doc-type  = p-fins-doc-type  ~
                    AND X_fin-statement.status_  = p-status_ ~
      AND (X_fin-statement.doc-date  >= p-start-date  AND ~
      X_fin-statement.doc-date  <= p-end-date)  ~
          "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                    AND X_fin-statement.fins-doc-type  = &2&3&2  ~
                    AND X_fin-statement.status_  = &2&4&2 ~
      AND (X_fin-statement.doc-date  >= &5  AND ~
      X_fin-statement.doc-date  <= &6) ', p-curr-host-code, ~{&double-quote~}, p-fins-doc-type, p-status_, p-start-date, p-end-date) "

          &use-ind    = " use-index itype-stat "
          &by         = "  " }
    END.
    WHEN 'type-date' THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_fin-statement.host-code  = p-curr-host-code  ~
                    AND X_fin-statement.fins-doc-type  = p-fins-doc-type  ~
      AND (X_fin-statement.doc-date  >= p-start-date  AND ~
      X_fin-statement.doc-date  <= p-end-date)  ~
          "
          &dyn_where-cond = " substitute('X_fin-statement.host-code  = &1  ~
                    AND X_fin-statement.fins-doc-type  = &2&3&2  ~
      AND (X_fin-statement.doc-date  >= &4  AND ~
      X_fin-statement.doc-date  <= &5)', p-curr-host-code, ~{&double-quote~}, p-fins-doc-type, p-start-date, p-end-date)"

          &use-ind    = " use-index itype "
          &by         = "  " }
    END.
END CASE.


  end. /*doe*/

end procedure. /* proc-main */