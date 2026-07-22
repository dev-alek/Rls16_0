block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsq8.p $
$Archive: ref/findcsq8.p $

Список платежей  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/findcsqd.i }

  CASE p-mode :
    WHEN 'schet-fact-order-income-cashless' THEN DO:
       run day-begin-fact-order in p-call-handle (
                                                  input p-start-date
                                                 ,output v-start-order).
       run factord-end-day in p-call-handle (
                                                  input p-end-date
                                                 ,output v-end-order).
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.status_  = p-status_  ~
                        AND (X_fin-doc.fact-order  >= v-start-order  AND ~
                            X_fin-doc.fact-order  <= v-end-order)  ~
                        AND X_fin-doc.receiver-code-schet = p-receiver-code-schet "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1  ~
                        AND X_fin-doc.status_  = &2&3&2  ~
                        AND (X_fin-doc.fact-order  >= &4  AND ~
                            X_fin-doc.fact-order  <= &5)  ~
                        AND X_fin-doc.receiver-code-schet = &6 ', p-curr-host-code, ~{&double-quote~}, p-status_, v-start-order, v-end-order, p-receiver-code-schet)"

              &use-ind    = "  "
              &by         = "  " }


    END.
    WHEN 'schet-fact-order-expense-cashless' THEN DO:
       run day-begin-fact-order in p-call-handle (
                                                  input p-start-date
                                                 ,output v-start-order).
       run factord-end-day in p-call-handle (
                                                  input p-end-date
                                                 ,output v-end-order).
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.status_  = p-status_  ~
                        AND (X_fin-doc.fact-order  >= v-start-order  AND ~
                            X_fin-doc.fact-order  <= v-end-order)  ~
                        AND X_fin-doc.payer-code-schet = p-receiver-code-schet "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1  ~
                        AND X_fin-doc.status_  = &2&3&2  ~
                        AND (X_fin-doc.fact-order  >= &4  AND ~
                            X_fin-doc.fact-order  <= &5)  ~
                        AND X_fin-doc.payer-code-schet = &6 ', p-curr-host-code, ~{&double-quote~}, p-status_, v-start-order, v-end-order, p-receiver-code-schet)"

              &use-ind    = "  "
              &by         = "  " }
    END.
    WHEN 'ext-type-stat-date' THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.status_  = p-status_  ~
                        AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
              "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 ~
                        AND X_fin-doc.status_  = &2&3&2  ~
                        AND X_fin-doc.fin-ext-doc-type  = &2&4&2  ~
                        AND (X_fin-doc.doc-date  >= &5  AND ~
                            X_fin-doc.doc-date  <= &6) ', p-curr-host-code , ~{&double-quote~}, p-status_, p-fin-ext-doc-type, p-start-date, p-end-date)"

              &use-ind    = " use-index iext-type-status "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.status_  = p-status_  ~
              AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
                            AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.status_  = &2&3&2  ~
              AND X_fin-doc.fin-ext-doc-type  = &2&4&2  ~
                        AND (X_fin-doc.doc-date  >= &5  AND ~
                            X_fin-doc.doc-date  <= &6)  ~
                            AND X_fin-doc.cor-acc = &7 ', p-curr-host-code, ~{&double-quote~}, p-status_, p-fin-ext-doc-type, p-start-date, p-end-date, p-cor-acc)"

              &use-ind    = " use-index iext-type-status "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.status_  = p-status_  ~
              AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
                            AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.status_  = &2&3&2  ~
              AND X_fin-doc.fin-ext-doc-type  = &2&4&2  ~
                        AND (X_fin-doc.doc-date  >= &5  AND ~
                            X_fin-doc.doc-date  <= &6)  ~
                            AND X_fin-doc.cor-acc1 = &7', p-curr-host-code, ~{&double-quote~}, p-status_, p-fin-ext-doc-type, p-start-date, p-end-date, p-cor-acc1 )"

              &use-ind    = " use-index iext-type-status "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.status_  = p-status_  ~
              AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.status_  = &2&3&2 ~
              AND X_fin-doc.fin-ext-doc-type  = &2&4&2  ~
                        AND (X_fin-doc.doc-date  >= &5  AND ~
                            X_fin-doc.doc-date  <= &6)  ~
              AND X_fin-doc.an-uchet-code = &7 ', p-curr-host-code, ~{&double-quote~}, p-status_ , p-fin-ext-doc-type, p-start-date, p-end-date, p-an-uchet-code)"

              &use-ind    = " use-index iext-type-status "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.status_  = p-status_  ~
              AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.status_  = &2&3&2  ~
              AND X_fin-doc.fin-ext-doc-type  = &2&4&2  ~
                        AND (X_fin-doc.doc-date  >= &5  AND ~
                            X_fin-doc.doc-date  <= &6)  ~
              AND X_fin-doc.cel-nazn-code = &7 ', p-curr-host-code, ~{&double-quote~}, p-status_, p-fin-ext-doc-type, p-start-date, p-end-date, p-cel-nazn-code)"

              &use-ind    = " use-index iext-type-status "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN 'ext-type-date' THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
              "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1  ~
                        AND X_fin-doc.fin-ext-doc-type  = &2&3&2  ~
                        AND (X_fin-doc.doc-date  >= &4  AND ~
                            X_fin-doc.doc-date  <= &5)', p-curr-host-code, ~{&double-quote~}, p-fin-ext-doc-type, p-start-date, p-end-date ) "

              &use-ind    = " use-index iext-type "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
                            AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1~
              AND X_fin-doc.fin-ext-doc-type  = &2&3&2  ~
                        AND (X_fin-doc.doc-date  >= &4  AND ~
                            X_fin-doc.doc-date  <= &5)  ~
                            AND X_fin-doc.cor-acc = &6 ', p-curr-host-code, ~{&double-quote~}, p-fin-ext-doc-type, p-start-date, p-end-date, p-cor-acc )"

              &use-ind    = " use-index iext-type "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
                            AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-ext-doc-type  = &2&3&2  ~
                        AND (X_fin-doc.doc-date  >= &4  AND ~
                            X_fin-doc.doc-date  <= &5)  ~
                            AND X_fin-doc.cor-acc1 = &6 ', p-curr-host-code, ~{&double-quote~}, p-fin-ext-doc-type, p-start-date, p-end-date, p-cor-acc1)"

              &use-ind    = " use-index iext-type "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-ext-doc-type  = &2&3&2  ~
                        AND (X_fin-doc.doc-date  >= &4  AND ~
                            X_fin-doc.doc-date  <= &5)  ~
              AND X_fin-doc.an-uchet-code = &6 ', p-curr-host-code, ~{&double-quote~}, p-fin-ext-doc-type, p-start-date, p-end-date, p-an-uchet-code)"

              &use-ind    = " use-index iext-type "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-ext-doc-type  = p-fin-ext-doc-type  ~
                        AND (X_fin-doc.doc-date  >= p-start-date  AND ~
                            X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-ext-doc-type  = &2&3&2  ~
                        AND (X_fin-doc.doc-date  >= &4  AND ~
                            X_fin-doc.doc-date  <= &5)  ~
              AND X_fin-doc.cel-nazn-code = &6 ', p-curr-host-code, ~{&double-quote~}, p-fin-ext-doc-type, p-start-date, p-end-date, p-cel-nazn-code)"

              &use-ind    = " use-index iext-type "
              &by         = "  " }
        end.
      END CASE.
    END.
END CASE.


  end. /*doe*/

end procedure. /* proc-main */