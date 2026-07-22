/*

$Revision: ff8019e24d02, 2996, rls $
$Author: EShklyar $
$Date: Ср апр 06 16:23:43 2022 +0300 $
$Workfile: findocip.i $
$Archive: ref/findocip.i $

Процедуры интерфейса, общие для все типов платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/01/03
Author: Bakhtadze Natalya
Creation date: 12/01/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: findocip.i $ $Revision: ff8019e24d02, 2996, rls $".

{ gbl/cur-time.i }
{ gbl/thbj-def.i }
{ gbl/attr-lib.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

&if "{&action}" = "define" &then
define variable v-is-auto-obj as logical no-undo .
define variable v-start       as integer no-undo .
define variable v-first-start as logical no-undo init yes.
assign
  v-start = (if p-mode = {&add-def} then 2 else 1)
  .
&endif

&if "{&action}" = "define2" &then
procedure set-buffers :
  DEFINE input parameter X_clients-host-recid as recid no-undo .
  DEFINE input parameter X_firm-recid as recid no-undo .
  DEFINE input parameter X_sysconf-recid as recid no-undo .
  define input parameter X_fin-code-cor-acc-recid as recid no-undo .
  define input parameter X_fin-code-cor-acc1-recid as recid no-undo .
  define input parameter X_fin-code-an-uchet-recid as recid no-undo .
  define input parameter X_fin-code-cel-nazn-recid as recid no-undo .
  define input parameter X_currency-recid as recid no-undo .
  define input parameter X_contract-currency-recid as recid no-undo .
  DEFINE input parameter X_receiver-recid as recid no-undo .
  DEFINE input parameter X_payer-recid as recid no-undo .
  define input parameter X_curr_sysconf-recid as recid no-undo .
  define input parameter X_payer-fin-schet-recid as recid no-undo .
  define input parameter X_payer-fin-bank-recid as recid no-undo .
  define input parameter X_payer-firm-recid as recid no-undo .
  define input parameter X_payer-person-recid as recid no-undo .
  define input parameter X_receiver-fin-schet-recid as recid no-undo .
  define input parameter X_receiver-fin-bank-recid as recid no-undo .
  define input parameter X_receiver-firm-recid as recid no-undo .
  define input parameter X_receiver-person-recid as recid no-undo .
  define input parameter X_contract-recid as recid no-undo .
  define input parameter X_fin-ob-recid as recid no-undo .
  define input parameter X_clients-obj-recid as recid no-undo .
  define input parameter p-f-cor-acc1-descr as character no-undo .
  define input parameter p-f-cor-acc-descr as character no-undo .
  define input parameter p-f-an-uchet-descr as character no-undo .
  define input parameter p-f-cel-nazn-descr as character no-undo .


  do
    on error undo, return error
    :

    find first X_clients-host no-lock where                   recid(X_clients-host)          = X_clients-host-recid no-error  .
    find first X_firm no-lock where                           recid(X_firm)                  = X_firm-recid no-error .
    find first X_sysconf no-lock where                        recid(X_sysconf)               = X_sysconf-recid no-error .
    find first X_fin-code-cor-acc no-lock where               recid(X_fin-code-cor-acc)      = X_fin-code-cor-acc-recid no-error .
    find first X_fin-code-cor-acc1 no-lock where              recid(X_fin-code-cor-acc1)     = X_fin-code-cor-acc1-recid no-error .
    find first X_fin-code-an-uchet no-lock where              recid(X_fin-code-an-uchet)     = X_fin-code-an-uchet-recid no-error .
    find first X_fin-code-cel-nazn no-lock where              recid(X_fin-code-cel-nazn)     = X_fin-code-cel-nazn-recid no-error .
    find first X_currency no-lock where                       recid(X_currency)              = X_currency-recid no-error .
    find first X_contract-currency no-lock where              recid(X_contract-currency)     = X_contract-currency-recid no-error .
    find first X_receiver no-lock where                       recid(X_receiver)              = X_receiver-recid no-error .
    find first X_payer no-lock where                          recid(X_payer)                 = X_payer-recid no-error .
    find first X_curr_sysconf no-lock where                   recid(X_curr_sysconf)          = X_curr_sysconf-recid no-error .
    find first X_payer-fin-schet no-lock where                recid(X_payer-fin-schet)       = X_payer-fin-schet-recid no-error .
    find first X_payer-fin-bank no-lock where                 recid(X_payer-fin-bank)        = X_payer-fin-bank-recid no-error .
    find first X_payer-firm no-lock where                     recid(X_payer-firm)            = X_payer-firm-recid no-error .
    find first X_payer-person no-lock where                   recid(X_payer-person)          = X_payer-person-recid no-error .
    find first X_receiver-fin-schet no-lock where             recid(X_receiver-fin-schet)    = X_receiver-fin-schet-recid no-error .
    find first X_receiver-fin-bank no-lock where              recid(X_receiver-fin-bank)     = X_receiver-fin-bank-recid no-error .
    find first X_receiver-firm no-lock where                  recid(X_receiver-firm)         = X_receiver-firm-recid no-error .
    find first X_receiver-person no-lock where                recid(X_receiver-person)       = X_receiver-person-recid no-error .
    find first X_contract no-lock where                       recid(X_contract)              = X_contract-recid no-error .
    find first X_fin-ob no-lock where                         recid(X_fin-ob)                = X_fin-ob-recid no-error .
    find first X_clients-obj no-lock where                    recid(X_clients-obj)           = X_clients-obj-recid no-error .
    assign
      f-cor-acc1-descr = p-f-cor-acc1-descr
      f-cor-acc-descr  = p-f-cor-acc-descr
      f-an-uchet-descr = p-f-an-uchet-descr
      f-cel-nazn-descr = p-f-cel-nazn-descr
      .
  end.
end procedure. /* set-buffers */

&if "{&doc-type}" = "income-cash" or "{&doc-type}" = "expense-cash" &then
PROCEDURE proc-shift-name :
  define buffer bf_shift-obj for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num no-undo.
  define variable varshift-name like ub.shift-obj.shift-name no-undo.


  if input frame {&frame-name} tt-fin-doc.shift-name <> tt-fin-doc.shift-name then 
  do:
    if input frame {&frame-name} tt-fin-doc.shift-date <> ? then 
    do:

      for each  bf_shift-obj where
        bf_shift-obj.obj-type   = tt-fin-doc.obj-type
        and  bf_shift-obj.obj-code   = tt-fin-doc.obj-code
        and  bf_shift-obj.shift-date = input frame {&frame-name} tt-fin-doc.shift-date
        and  bf_shift-obj.shift-name = input frame {&frame-name} tt-fin-doc.shift-name
        no-lock on error undo, return error return-value :
        assign
          varfind-shift = varfind-shift + 1
          varshift-date = bf_shift-obj.shift-date
          varshift-num  = bf_shift-obj.shift-num.
        varshift-name = bf_shift-obj.shift-name.
      end.

      if varfind-shift = 0 or varfind-shift > 1 then 
      do:
        if varfind-shift = 0 then 
        do:
          message
            substitute("Не найдена смена: &1&2 Дата &3 Номер смены "
            ,tt-fin-doc.obj-type
            ,tt-fin-doc.obj-code
            ,input frame {&frame-name} tt-fin-doc.shift-date
            ,input frame {&frame-name} tt-fin-doc.shift-name )
            view-as alert-box error.
        end.
        else 
        do:
          message
            substitute("Найдено более одной смены с одним номером в сменном дне. Объект: &1&2 Дата &3 Номер смены &4 "
            ,tt-fin-doc.obj-type
            ,tt-fin-doc.obj-code
            ,input frame {&frame-name} tt-fin-doc.shift-date
            ,input frame {&frame-name} tt-fin-doc.shift-name )
            view-as alert-box error.
        end.
        display
          tt-fin-doc.shift-name with frame {&frame-name}.
        run proc-sht no-error.
        if error-status:error then 
        do: 
          return error. 
        end.
      end.
      else 
      do:
        assign frame {&frame-name}
          tt-fin-doc.shift-name.
        assign
          tt-fin-doc.shift-date = varshift-date
          tt-fin-doc.shift-num  = varshift-num.
        display
          tt-fin-doc.shift-date
          tt-fin-doc.shift-num
          tt-fin-doc.shift-name with frame {&frame-name}.
      end.
    end.
  end.
END PROCEDURE.

PROCEDURE proc-shift-num :
  define buffer bf_shift-obj for ub.shift-obj.
  if input frame {&frame-name} tt-fin-doc.shift-num <> tt-fin-doc.shift-num then 
  do:
    if input frame {&frame-name} tt-fin-doc.shift-date <> ? then 
    do:
      find first bf_shift-obj where
        bf_shift-obj.obj-type   = tt-fin-doc.obj-type
        and  bf_shift-obj.obj-code   = tt-fin-doc.obj-code
        and  bf_shift-obj.shift-date = input frame {&frame-name} tt-fin-doc.shift-date
        and  bf_shift-obj.shift-num  = input frame {&frame-name} tt-fin-doc.shift-num  no-lock no-error.
      if not available bf_shift-obj then 
      do:
        message
          substitute("Не найдена смена: &1&2 Дата &3 Порядок смены &4"
          ,tt-fin-doc.obj-type
          ,tt-fin-doc.obj-code
          ,input frame {&frame-name} tt-fin-doc.shift-date
          ,input frame {&frame-name} tt-fin-doc.shift-num)
          view-as alert-box error.
        display
          tt-fin-doc.shift-num with frame {&frame-name}.
        run proc-sht no-error.
        if error-status:error then 
        do:
          return error.
        end.
      end.
      else 
      do:
        assign
          tt-fin-doc.shift-date = bf_shift-obj.shift-date
          tt-fin-doc.shift-num  = bf_shift-obj.shift-num
          tt-fin-doc.shift-name = bf_shift-obj.shift-name.
        display
          tt-fin-doc.shift-date
          tt-fin-doc.shift-num
          tt-fin-doc.shift-name
          with frame {&frame-name}.
      end.
    end.
  end.
END PROCEDURE.


PROCEDURE proc-sht :
  define buffer bf_shift-obj for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign  
    varrid-list = "".
  run str/sht-all.w ( input parparentproc
    , input tt-fin-doc.obj-type
    , input tt-fin-doc.obj-code
    , input 'b-sel'
    , input 'obj'
    , input tt-fin-doc.obj-type
    , input tt-fin-doc.obj-code
    , input '':u
    , input-output varrid-list) no-error .
  if error-status:error or varrid-list = "":u then 
  do:
    return error.
  end.
  else 
  do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then 
    do:
      assign
        tt-fin-doc.shift-date = bf_shift-obj.shift-date
        tt-fin-doc.shift-num  = bf_shift-obj.shift-num
        tt-fin-doc.shift-name = bf_shift-obj.shift-name.
      display
        tt-fin-doc.shift-date
        tt-fin-doc.shift-num
        tt-fin-doc.shift-name with frame {&frame-name}.
      /*if tt-fin-doc.fact-date = ? then do: */
      assign
        tt-fin-doc.doc-date = tt-fin-doc.shift-date
        .
      display tt-fin-doc.doc-date with frame {&frame-name}.
    /*end.  */
    end.
  end.

END PROCEDURE.
&endif

&endif


&if "{&action}" = "define3" &then

procedure get-single-schet :
  define input parameter p-host-code like ub.sysconf.host-code no-undo .
  define input parameter p-cli-type like ub.fin-schet.cli-type no-undo .
  define input parameter p-cli-code like ub.fin-schet.cli-code no-undo .
  define input parameter p-curr-code like ub.fin-schet.curr-code no-undo .
  define output parameter p-recid-schet as recid no-undo .
  define output parameter p-recid-bank as recid no-undo .
  define variable ii as integer no-undo .
  define buffer buf_fin-schet for ub.fin-schet.
  define buffer buf_fin-bank  for ub.fin-bank.

  do
    on error undo, return error
    :
    for each buf_fin-schet no-lock where
      buf_fin-schet.host-code = p-host-code
      AND buf_fin-schet.cli-type = p-cli-type
      AND buf_fin-schet.cli-code = p-cli-code
      AND buf_fin-schet.curr-code = p-curr-code:
      if buf_fin-schet.status_ = {&current-status} then 
      do:
        find first buf_fin-bank no-lock where
          buf_fin-bank.host-code = p-host-code
          AND buf_fin-bank.code-bank = buf_fin-schet.code-bank no-error .
        if avail buf_fin-bank and buf_fin-bank.status_ = {&current-status} then 
        do:
          assign
            p-recid-schet = recid(buf_fin-schet)
            p-recid-bank  = recid(buf_fin-bank)
            .
          assign
            ii = ii + 1
            .
        end.
      end.
      if ii > 1 then 
      do:
        assign
          p-recid-schet = ?
          p-recid-bank  = ?
          .
      end.
    end. /*for each*/
  end.


end procedure. /* get-single-schet */

&endif

&if "{&action}" = "triggers" &then

&scop GET-DISPLAY-INN-SINGLE-SCHET ~
define variable v-recid-schet as recid no-undo . ~
define variable v-recid-bank as recid no-undo . ~
CASE X_~{&cli-side~}.obj-type: ~
  when ~{&prs~} then do:          ~
    find first X_~{&cli-side~}-person no-lock where ~
              X_~{&cli-side~}-person.psn-code = X_~{&cli-side~}.obj-code . ~
  end. ~
  when ~{&cmp~} then do: ~
    find first X_~{&cli-side~}-firm no-lock where ~
              X_~{&cli-side~}-firm.firm-code = X_~{&cli-side~}.obj-code . ~
  end. ~
END CASE. ~
  assign ~
  tt-fin-doc.~{&cli-side~}-type =  X_~{&cli-side~}.obj-type ~
  tt-fin-doc.~{&cli-side~}-code = X_~{&cli-side~}.obj-code ~
  tt-fin-doc.~{&cli-side~}-name = X_~{&cli-side~}.obj-name ~
  tt-fin-doc.~{&cli-side~}-inn = (if X_~{&cli-side~}.obj-type = ~{&prs~} ~
                            then X_~{&cli-side~}-person.inn ~
                            else X_~{&cli-side~}-firm.inn ~
                            ) ~
  tt-fin-doc.~{&cli-side~}-kpp = (if X_~{&cli-side~}.obj-type = ~{&prs~} ~
                            then X_~{&cli-side~}-person.kpp ~
                            else X_~{&cli-side~}-firm.kpp ~
                            ) ~
  . ~
  run get-single-schet in this-procedure ( ~
                                          input p-host-code ~
                                          ,input X_~{&cli-side~}.obj-type ~
                                          ,input X_~{&cli-side~}.obj-code ~
                                          ,input tt-fin-doc.curr-code ~
                                          ,output v-recid-schet ~
                                          ,output v-recid-bank). ~
  if v-recid-schet <> ? then do: ~
    find first X_~{&cli-side~}-fin-schet no-lock where ~
                recid(X_~{&cli-side~}-fin-schet) = v-recid-schet. ~
    find first X_~{&cli-side~}-fin-bank no-lock where ~
                recid(X_~{&cli-side~}-fin-bank) = v-recid-bank. ~
    assign ~
    tt-fin-doc.~{&cli-side~}-code-schet = X_~{&cli-side~}-fin-schet.code-schet ~
    tt-fin-doc.~{&cli-side~}-bank-name = X_~{&cli-side~}-fin-bank.bank-name   ~
    tt-fin-doc.~{&cli-side~}-bank-city = X_~{&cli-side~}-fin-bank.bank-city   ~
    tt-fin-doc.~{&cli-side~}-dop1       = X_~{&cli-side~}-fin-schet.dop1 ~
    tt-fin-doc.~{&cli-side~}-dop2       = X_~{&cli-side~}-fin-schet.dop2 ~
    tt-fin-doc.~{&cli-side~}-bik = X_~{&cli-side~}-fin-bank.bik ~
    tt-fin-doc.~{&cli-side~}-r-schet = X_~{&cli-side~}-fin-schet.r-schet ~
    tt-fin-doc.~{&cli-side~}-c-schet = X_~{&cli-side~}-fin-schet.c-schet ~
    . ~
  end. ~
  else do: ~
    RELEASE X_~{&cli-side~}-fin-schet. ~
    RELEASE X_~{&cli-side~}-fin-bank. ~
    assign ~
    tt-fin-doc.~{&cli-side~}-code-schet = 0 ~
    tt-fin-doc.~{&cli-side~}-bank-name = "":U ~
    tt-fin-doc.~{&cli-side~}-bank-city = "":U ~
    tt-fin-doc.~{&cli-side~}-dop1      = "":U ~
    tt-fin-doc.~{&cli-side~}-dop2      = "":U ~
    tt-fin-doc.~{&cli-side~}-bik = "":U ~
    tt-fin-doc.~{&cli-side~}-r-schet = "":U ~
    tt-fin-doc.~{&cli-side~}-c-schet = "":U ~
    . ~
  end. ~
display ~
tt-fin-doc.~{&cli-side~}-type ~
tt-fin-doc.~{&cli-side~}-code ~
tt-fin-doc.~{&cli-side~}-name ~
tt-fin-doc.~{&cli-side~}-inn ~
tt-fin-doc.~{&cli-side~}-kpp ~
tt-fin-doc.~{&cli-side~}-bank-name ~
tt-fin-doc.~{&cli-side~}-bank-city ~
tt-fin-doc.~{&cli-side~}-bik ~
tt-fin-doc.~{&cli-side~}-r-schet ~
tt-fin-doc.~{&cli-side~}-c-schet ~
with frame {&frame-name}. ~


&scop GET-DISPLAY-PASSPORT ~
CASE X_~{&cli-side~}.obj-type: ~
  when ~{&prs~} then do:          ~
    find first X_~{&cli-side~}-person no-lock where ~
              X_~{&cli-side~}-person.psn-code = X_~{&cli-side~}.obj-code . ~
  end. ~
  when ~{&cmp~} then do: ~
    find first X_~{&cli-side~}-firm no-lock where ~
              X_~{&cli-side~}-firm.firm-code = X_~{&cli-side~}.obj-code . ~
  end. ~
END CASE. ~
  assign ~
  tt-fin-doc.~{&cli-side~}-type =  X_~{&cli-side~}.obj-type ~
  tt-fin-doc.~{&cli-side~}-code = X_~{&cli-side~}.obj-code ~
  tt-fin-doc.~{&cli-side~}-name = X_~{&cli-side~}.obj-name ~
  tt-fin-doc.~{&cli-side~}-passport = (if X_~{&cli-side~}.obj-type = ~{&prs~} ~
                            then  (X_~{&cli-side~}-person.passp-ser  + ~{&space-char~}  + ~
                                   X_~{&cli-side~}-person.passp-num  + ~{&space-char~}  + ~
                                   X_~{&cli-side~}-person.given-by) ~
                            else  (X_~{&cli-side~}-firm.passp-ser  + ~{&space-char~}  + ~
                                   X_~{&cli-side~}-firm.passp-num  + ~{&space-char~}  + ~
                                   X_~{&cli-side~}-firm.given-by) ~
                            ) ~
  . ~
display ~
tt-fin-doc.~{&cli-side~}-type ~
tt-fin-doc.~{&cli-side~}-code ~
tt-fin-doc.~{&cli-side~}-name ~
tt-fin-doc.~{&cli-side~}-passport ~
with frame {&frame-name}. ~


&scop GET-DISPLAY-SIGN ~
CASE X_~{&cli-side~}.obj-type: ~
  when ~{&prs~} then do:          ~
    find first X_~{&cli-side~}-person no-lock where ~
              X_~{&cli-side~}-person.psn-code = X_~{&cli-side~}.obj-code . ~
  end. ~
  when ~{&cmp~} then do: ~
    find first X_~{&cli-side~}-firm no-lock where ~
              X_~{&cli-side~}-firm.firm-code = X_~{&cli-side~}.obj-code . ~
  end. ~
END CASE. ~
assign ~
tt-fin-doc.~{&cli-sign~}  = if X_~{&cli-side~}.obj-type = ~{&cmp~}  ~
                            then X_~{&cli-side~}-firm.director ~
                            else X_~{&cli-side~}.obj-name . ~
display ~
tt-fin-doc.~{&cli-sign~} ~
with frame {&frame-name}.


{ gbl/ed_date.i tt-fin-doc.doc-date }
&if "{&doc-type}" = "income-cash" &then
{ gbl/ed-uho.i  tt-fin-doc.including  1 }
&endif

&if "{&doc-type}" = "expense-cashless"  &then
{ gbl/ed-uho.i  tt-fin-doc.naznach-plat 1 }
&endif


ON CHOOSE OF B-obj IN FRAME Dialog-Frame
  DO:
    define variable v-obj-type like ub.fin-doc.obj-type no-undo .
    define variable v-obj-code like ub.fin-doc.obj-code no-undo .
    { gbl/stdbtn.i }
run str/chshobj.w ( tt-fin-doc.host-code
  , tt-fin-doc.obj-type
  , tt-fin-doc.obj-code
  , output v-obj-type
  , output v-obj-code
  ) no-error .
if error-status:error
  or (
  v-obj-type = tt-fin-doc.obj-type
  AND v-obj-code = tt-fin-doc.obj-code)
  or v-obj-code = 0
  or v-obj-type = "":U
  then  
do:
  return no-apply.
end.
find first X_clients-obj no-lock where
  X_clients-obj.obj-type = v-obj-type
  AND X_clients-obj.obj-code = v-obj-code .
assign
  tt-fin-doc.obj-type = X_clients-obj.obj-type
  tt-fin-doc.obj-code = X_clients-obj.obj-code
  .
display
  tt-fin-doc.obj-type
  tt-fin-doc.obj-code
  with frame {&frame-name}.
run check-obj in this-procedure (  input tt-fin-doc.obj-type
  ,input tt-fin-doc.obj-code
  )
  no-error.
END.

ON LEAVE OF tt-fin-doc.obj-code IN FRAME Dialog-Frame
  DO:
 { gbl/stdbtn.i }
if   input frame {&frame-name} tt-fin-doc.obj-code <> 0 then 
do:
  run check-obj in this-procedure (
    input frame {&frame-name} tt-fin-doc.obj-type
    ,input frame {&frame-name} tt-fin-doc.obj-code
    )

    no-error.
  if error-status:error then 
  do:
    return no-apply.
  end.
end.
END.


ON VALUE-CHANGED OF tt-fin-doc.obj-type IN FRAME Dialog-Frame
  DO:
    assign
      tt-fin-doc.obj-type.
    if   input frame {&frame-name} tt-fin-doc.obj-code <> 0 then 
    do:
      run check-obj in this-procedure (
        input frame {&frame-name} tt-fin-doc.obj-type
        ,input frame {&frame-name} tt-fin-doc.obj-code
        )
        no-error.
      if error-status:error then 
      do:
        return no-apply.
      end.
    end.
  END.

PROCEDURE check-obj :
  define input parameter p-check-obj-type as character no-undo .
  define input parameter p-check-obj-code as integer no-undo .
  define variable v-obj-db-num as integer no-undo init -1.
  define variable v-cash-book  as integer no-undo .
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where
    buf_clients.obj-code = p-check-obj-code
    and buf_clients.obj-type = p-check-obj-type no-error.
  if not available buf_clients then 
  do:
    if p-check-obj-code <> ?  then
      message "Неправильный код или тип объекта" .
    apply "entry" to tt-fin-doc.obj-code in frame {&frame-name}.
    return error.
  end.
  find first X_clients-obj no-lock where recid(X_clients-obj) = recid(buf_clients).
  assign
    tt-fin-doc.obj-type = buf_clients.obj-type
    tt-fin-doc.obj-code = buf_clients.obj-code
    .
  display
    tt-fin-doc.obj-type
    tt-fin-doc.obj-code
    with frame {&frame-name}.
  if not (tt-fin-doc.obj-type = '' and tt-fin-doc.obj-code = 0) then 
  do:
    { gbl/objdbnum.i tt-fin-doc.obj-type tt-fin-doc.obj-code v-obj-db-num }
    /*   { gbl/cashbook.i tt-fin-doc.obj-type tt-fin-doc.obj-code v-cash-book no-error }*/
    define variable l-shift-on as logical no-undo .
    { gbl/objat.i
    tt-fin-doc.obj-type
    tt-fin-doc.obj-code
    "'shift-on=request'"
    l-shift-on
  }
    assign
      tt-fin-doc.shift-flag = (if l-shift-on
                                  and lookup(tt-fin-doc.fin-ext-doc-type, {&fin-ext-doc-cash-types}) > 0
                                  and (tt-fin-doc.doc-author = {&manual} or tt-fin-doc.doc-author = {&auto})
/*                                  and v-cash-book = integer({&cash-book-object})*/
                                  and v-obj-db-num = v-cntxt-db-num
                                  then integer({&fin-flag-shift})
                                  else 0)
      .
    /*найдем как заполнить стурктурное подразделение*/
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    define variable mCashBook         as class     ibs.th.ref.cashbookstorage no-undo .
    define variable par-type          as character no-undo .
    define variable v-dpt-option      as character no-undo .
    define variable v-dpt-dflt-name   as character no-undo .
    define variable v-dpt-dflt-type   as character no-undo .
    define variable v-dpt-dflt-code   as integer   no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as INTEGER   no-undo .
    define variable v-value-logical   AS LOGICAL   no-undo .
    define variable v-tth             as handle    no-undo .
    define variable v-naznach-plat    as character no-undo .
    define variable v-enclosure       as character no-undo .
    define variable o-head-position   as character no-undo .
    define variable o-director        as character no-undo .
    define variable o-snr-accnt       as character no-undo .
    define variable o-cashier         as character no-undo .
    define variable v-head-position   as character no-undo .
    define variable v-director        as character no-undo .
    define variable v-snr-accnt       as character no-undo .
    define variable v-cashier         as character no-undo .
    define variable v-hist-code       as character no-undo .
    define variable v-hist-name       as character no-undo .
    
    define buffer buf_sysconf for ub.sysconf.
    define buffer buf_shop    for ub.shop .
    define buffer buf_store   for ub.store .  
    define buffer buf_firm    for ub.firm .
    
    assign
      v-tth = buffer thbjattr_thbj-attr:table-handle .

    mCashBook = new ibs.th.ref.cashbookstorage () .
        
    v-dpt-option    = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "Struct") .
    v-dpt-dflt-name = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "DptName") .
    v-dpt-dflt-type = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "DptType") .
    v-dpt-dflt-code = integer(mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "DptCode")) .
    o-head-position = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "ManagerPosition") .
    o-director      = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "ManagerFIO") .
    o-snr-accnt     = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BuhFIO") .
  
    delete object mCashBook no-error .

    case v-dpt-option:
      when "1" then 
        do:
          for first ub.db-attr no-lock where ub.db-attr.db-num = v-cntxt-db-num
          and ub.db-attr.attr-code = {&attr-hist-code}:
            v-hist-code = ub.db-attr.attr-value .
          end.  
          for first ub.db-attr no-lock where ub.db-attr.db-num = v-cntxt-db-num
          and ub.db-attr.attr-code = {&attr-hist-name}:
            v-hist-name = ub.db-attr.attr-value .
          end.  
          if v-hist-code = "" then v-dpt-dflt-code = X_clients-obj.obj-code .
          if v-hist-name = "" then v-dpt-dflt-name = X_clients-obj.obj-name . 
          v-dpt-dflt-type = X_clients-obj.obj-type  .
        end.
      when "0" then 
        do:
          assign
            v-dpt-dflt-name = ''
            v-dpt-dflt-type = ''
            v-dpt-dflt-code = 0
            .
        end.
      otherwise 
      do:
        /*уже заполнено в цикле*/
        assign
          v-dpt-dflt-name = v-dpt-dflt-name
          v-dpt-dflt-type = v-dpt-dflt-type
          v-dpt-dflt-code = v-dpt-dflt-code
          .
      end.
    end case.
    find first buf_sysconf no-error .
    case o-head-position:
      when '0':U then
        do:
          v-head-position = buf_sysconf.head-position.
        end.
      when '1':U then
        do:
          v-head-position = "Директор".
        end.
      when '2':U then
        do:
          v-head-position = "Управляющий".
        end.
      otherwise
      do :
        v-head-position = o-head-position.
      end.
    end case.
    find first buf_firm no-lock where
      buf_firm.firm-code = buf_sysconf.host-code.
    case o-director:
      when '1':U then 
        do:
          if p-obj-type = {&shop} then 
          do:
            find first buf_shop no-lock where
              buf_shop.obj-code = p-obj-code no-error .
            if available buf_shop then 
            do:
              v-director = buf_shop.director.
            end.
          end.
          if p-obj-type = {&stock} then 
          do:
            find first buf_store no-lock where
              buf_store.obj-code = p-obj-code no-error .
            if available buf_store then 
            do:
              v-director = buf_store.store-boss.
            end.
          end.
        end. /*when 'dir_obj' then do:*/
      when '0':U then 
        do:
          v-director = buf_firm.director.
        end.
      otherwise 
      do:
        v-director = o-director .
      end.  
    end case.
    
    case o-snr-accnt:
      when '1':U then 
        do:
          if p-obj-type = {&shop} then 
          do:
            find first buf_shop no-lock where
              buf_shop.obj-code = p-obj-code no-error .
            if available buf_shop then 
            do:
              v-snr-accnt = entry(1,buf_shop.acct,"|").
            end.
          end.
          if p-obj-type = {&stock} then 
          do:
            v-snr-accnt = ''.
          end.
        end.
      when '2':U then 
        do:
          v-snr-accnt = buf_sysconf.snr-accnt.
        end.
      otherwise 
      do:
        v-snr-accnt = o-snr-accnt .
      end.  
    end case.
    /* ищем следующюю смену и ее персонал */

&if "{&doc-type}" = "income-cash" or "{&doc-type}" = "expense-cash" &then
  if tt-fin-doc.shift-flag = integer({&fin-flag-shift}) then 
  do:
    define variable v-fin-doc-shift-date      as date      no-undo .
    define variable v-fin-doc-shift-num       as integer   no-undo .
    define variable v-fin-doc-shift-name      as character no-undo .
    define variable v-fin-doc-shift-date-char as character no-undo .
    define variable v-fin-doc-shift-num-char  as character no-undo .
    define variable varobj-shift-date         as date      no-undo .
    define variable varobj-shift-num          as integer   no-undo .
    define variable varobj-shift-name         as character no-undo .
    define variable v-can-back-shift          as logical   no-undo .

    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-doc_create-back-shift':U
    {&cntxt-object}
    tt-fin-doc.host-code
    tt-fin-doc.obj-type
    tt-fin-doc.obj-code
    0
    0
    0
    false
    v-can-back-shift
  }
    { gbl/curshift.i
    tt-fin-doc.obj-type
    tt-fin-doc.obj-code
    varobj-shift-date
    varobj-shift-num
    varobj-shift-name
    no-error
  }
    if error-status :error then 
    do:
      if not v-can-back-shift then 
      do:
        return error substitute("Не найдена текущая смена на &1&2", tt-fin-doc.obj-type, tt-fin-doc.obj-code).
      end.
      else 
      do:
        run proc-sht in this-procedure .
      end.
    end.
    else 
    do:
      assign
        tt-fin-doc.shift-date = varobj-shift-date
        tt-fin-doc.shift-num  = varobj-shift-num
        tt-fin-doc.shift-name = varobj-shift-name
        .
    end.
    define variable v-date as date    no-undo  .
    define variable v-time as integer no-undo .
    run cur-time in this-procedure(output v-date, output v-time).
    display
      tt-fin-doc.shift-date
      tt-fin-doc.shift-num
      tt-fin-doc.shift-name
      with frame {&frame-name} .
    enable
      r-sht 
      when (tt-fin-doc.shift-flag = integer({&fin-flag-shift}) and v-limit-access = 0 and v-can-back-shift)
      with frame {&frame-name}.
  end.
  else 
  do:
    hide
      tt-fin-doc.shift-date
      tt-fin-doc.shift-num
      tt-fin-doc.shift-name
      in frame {&frame-name} .
    disable
      r-sht
      with frame {&frame-name} .
  end.
&endif
 
  FIND FIRST ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type   = p-obj-type AND
    ub.shift-staff.obj-code   = p-obj-code AND
    ub.shift-staff.shift-date = tt-fin-doc.shift-date AND
    ub.shift-staff.shift-num  = tt-fin-doc.shift-num AND
    ub.shift-staff.staff-role = no and
    ub.shift-staff.psn-num    >= 0 No-ERROR.
  assign 
    v-cashier = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
  .
  if tt-fin-doc.fin-ext-doc-type = {&FDEDT_Expense_Cash} then 
  do:
    assign
      tt-fin-doc.payer-sign1 = v-director
      tt-fin-doc.payer-sign2 = v-snr-accnt
      tt-fin-doc.payer-sign3 = v-cashier
      .        
  end.
  if tt-fin-doc.fin-ext-doc-type = {&FDEDT_Income_Cash} then 
  do:
    assign
      tt-fin-doc.receiver-sign2 = v-snr-accnt
      tt-fin-doc.receiver-sign3 = v-cashier
      .        
  end.
  find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.CashBookId no-error .
  if available (ub.CashBook) then 
  do:
    case ub.CashBook.RuleOsnRko:
      when "0" then 
        tt-fin-doc.naznach-plat = "Выручка от реализации" .
      when "1" or 
      when "2" then 
        tt-fin-doc.naznach-plat = "" .
      otherwise 
      tt-fin-doc.naznach-plat = ub.CashBook.RuleOsnRko .
    end case .

    case ub.CashBook.RulePril:
      when '0' then 
        do:
          tt-fin-doc.enclosure = v-naznach-plat .
        end.  
      when '1' then 
        do:
          tt-fin-doc.enclosure = "" .
        end.  
      otherwise 
      tt-fin-doc.enclosure = ub.CashBook.RulePril .
    end case.  
    if ub.CashBook.CorrRko <> "" then 
    do:
      for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.CorrRko
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
      end.
    end.
    if tt-fin-doc.cor-acc = ? or tt-fin-doc.cor-acc = 0 then 
    do:
      for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = "57.01"
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
      end. 
    end.    
    if ub.CashBook.OsnAcct <> "" then 
    do:
      for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.OsnAcct
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc1-value = ub.fin-code-cor-acc.code-value .
      end.  
    end.
  end.
  
  assign
    tt-fin-doc.str-podr-name = if v-hist-name = "" then v-dpt-dflt-name else v-hist-name
    tt-fin-doc.str-podr-type = v-dpt-dflt-type
    tt-fin-doc.str-podr-code = v-dpt-dflt-code
    .
  
  display
    tt-fin-doc.str-podr-name
    tt-fin-doc.str-podr-type
    tt-fin-doc.str-podr-code
    tt-fin-doc.enclosure
    tt-fin-doc.naznach-plat
    tt-fin-doc.cor-acc
    tt-fin-doc.cor-acc1
    tt-fin-doc.cor-acc1-value
    tt-fin-doc.cor-acc-value
    &if  "{&doc-type}" = "expense-cash" &then
    tt-fin-doc.payer-sign1  
    tt-fin-doc.payer-sign1:label = "Рук. орг-ции"  +
       (if v-head-position <> ''                        
       then " - ":U + v-head-position                   
       else '')                                         
    tt-fin-doc.payer-sign2
    tt-fin-doc.payer-sign3
    &elseif "{&doc-type}" = "income-cash"
    &then
    tt-fin-doc.receiver-sign2
    tt-fin-doc.receiver-sign3
    &endif
    with frame {&frame-name} .
       
  end.
  else 
  do:
    assign
      tt-fin-doc.shift-flag = 0
      .
  end.


  
END PROCEDURE.



ON CHOOSE OF B-calc IN FRAME Dialog-Frame
  DO:
    /*message "закрыто на ремонт" view-as alert-box .
    return no-apply.*/
    run ref/findclci.w (
      INPUT          parParentProc
      ,input          "":U /*p-mode про запас*/
      ,INPUT          tt-fin-doc.doc-date
      ,INPUT          tt-fin-doc.curr-code
      ,INPUT          v-base-code
      ,INPUT          tt-fin-doc.contract-curr

      ,INPUT-OUTPUT   tt-fin-doc.sum-doc
      ,INPUT-OUTPUT   tt-fin-doc.exch-rate
      ,INPUT-OUTPUT   tt-fin-doc.exch-scale

      ,INPUT-OUTPUT   tt-fin-doc.sum-rubl

      ,INPUT-OUTPUT   tt-fin-doc.sum-base
      ,INPUT-OUTPUT   tt-fin-doc.base-rate
      ,INPUT-OUTPUT   tt-fin-doc.base-scale

      ,INPUT-OUTPUT   tt-fin-doc.sum-contr
      ,INPUT-OUTPUT   tt-fin-doc.contract-rate
      ,INPUT-OUTPUT   tt-fin-doc.contract-scale ) no-error.
    if error-status:error then return no-apply.
    assign
      f-rest-con-sum = tt-fin-doc.sum-contr - tt-fin-doc.con-sum-contr
      .
    display
      tt-fin-doc.sum-rubl          
      when v-rubf
      tt-fin-doc.sum-doc
      tt-fin-doc.exch-rate         
      when v-exchf
      tt-fin-doc.exch-scale        
      when v-exchf
      tt-fin-doc.sum-base          
      when v-basef
      tt-fin-doc.base-rate         
      when v-baseratef
      tt-fin-doc.base-scale        
      when v-baseratef
      tt-fin-doc.sum-contr         
      when v-contractf
      tt-fin-doc.contract-rate     
      when v-contractratef
      tt-fin-doc.contract-scale    
      when v-contractratef
      f-rest-con-sum
      with frame {&frame-name} .
  END.



&if "{&doc-type}" = "income-cashless" or "{&doc-type}" = "expense-cashless" &then
ON CHOOSE OF B-{&my-side}-schet IN FRAME Dialog-Frame
  DO:
    define variable v-rid-list as character no-undo.
    define variable ref-rec    as recid     no-undo.
    define variable v-status_  like ub.fin-schet.status_ no-undo init {&current-status}.
    define buffer buf_fin-schet for ub.fin-schet .
{ gbl/stdbtn.i }
if available X_{&my-side}-fin-schet then
  assign
    v-rid-list = string(recid(X_{&my-side}-fin-schet))
    v-status_  = X_{&my-side}-fin-schet.status_
    .
run ref/finschts.w (
  INPUT parParentProc
  ,p-curr-host-code
  ,input "b-sel,b-add":U
  ,input "company-host":U
  ,input {&cmp} /*p-cli-type*/
  ,input p-host-code /*p-cli-code*/
  ,input ? /*p-curr-code*/
  ,input tt-fin-doc.host-code
  ,input 0 /* p-code-bank */
  ,input-output v-status_
  ,input-output v-rid-list
  ) no-error.
if v-rid-list = "" then   
do:
  apply "entry" to b-{&my-side}-schet in frame {&frame-name}.
  return no-apply.
end.
ref-rec = integer( v-rid-list ).
FIND FIRST buf_fin-schet WHERE
  recid (buf_fin-schet) = ref-rec NO-LOCK  .
if buf_fin-schet.curr-code <> tt-fin-doc.curr-code then 
do:
  message
    "Валюта выбранного Вами счета" {&my-title} "не совпадает с валютой платежа"
    view-as alert-box error .
  return no-apply.
end.
if buf_fin-schet.status_ <> {&current-status} then 
do:
  message
    "Статус выбранного Вами счета" {&my-title} buf_fin-schet.status_ " - нельзя работать с таким счетом"
    view-as alert-box error .
  return no-apply.
end.
FIND FIRST X_{&my-side}-fin-schet WHERE
  recid (X_{&my-side}-fin-schet) = ref-rec NO-LOCK  .
find first X_{&my-side}-fin-bank no-lock where
  X_{&my-side}-fin-bank.host-code = tt-fin-doc.host-code
  AND X_{&my-side}-fin-bank.code-bank = X_{&my-side}-fin-schet.code-bank .
assign
  tt-fin-doc.{&my-side}-bank-name  = X_{&my-side}-fin-bank.bank-name
  tt-fin-doc.{&my-side}-bank-city  = X_{&my-side}-fin-bank.bank-city
  tt-fin-doc.{&my-side}-dop1       = X_{&my-side}-fin-schet.dop1
  tt-fin-doc.{&my-side}-dop2       = X_{&my-side}-fin-schet.dop2
  tt-fin-doc.{&my-side}-bik        = X_{&my-side}-fin-bank.bik
  tt-fin-doc.{&my-side}-c-schet    = X_{&my-side}-fin-schet.c-schet
  tt-fin-doc.{&my-side}-r-schet    = X_{&my-side}-fin-schet.r-schet
  tt-fin-doc.{&my-side}-code-schet = X_{&my-side}-fin-schet.code-schet
  .
display
  tt-fin-doc.{&my-side}-bank-name
  tt-fin-doc.{&my-side}-bank-city
  tt-fin-doc.{&my-side}-bik
  tt-fin-doc.{&my-side}-c-schet
  tt-fin-doc.{&my-side}-r-schet
  with frame {&frame-name}.
END.
&endif


ON CHOOSE OF B-{&cli-side} IN FRAME Dialog-Frame
  DO:
    define variable ref-list as character no-undo.
    define variable ref-rec  as recid     no-undo.
    define variable v-sum-vat-chr  as character no-undo .
    define variable v-each-vat-chr as character no-undo.
    define variable v-sum-vat      like ub.fin-doc-tax.sum-vat-line-doc no-undo .
        
    define buffer buf_clients for ub.clients.
{ gbl/stdbtn.i }
run ref/cli-all.w ( parParentProc
  ,"b-sel"
  , tt-fin-doc.{&cli-side}-type
  , ?
  , ?
  , (if available X_{&cli-side} then recid(X_{&cli-side}) else ?)
  , ?
  , "without-obj":U
  , output ref-list) .
if ref-list = "" then   
do:
  return no-apply.
end.
ref-rec = integer( ref-list ).
FIND FIRST buf_clients WHERE recid (buf_clients) = ref-rec NO-LOCK .
if NOT (buf_clients.obj-type = {&cmp}
  or
  buf_clients.obj-type = {&prs} ) then 
do:
  message
    "Выберите контрагента типа" {&cmp} "или" {&prs}
    view-as alert-box error .
  return no-apply.
end.
find first X_{&cli-side} no-lock where
  recid(X_{&cli-side}) = recid(buf_clients).
assign
  tt-fin-doc.{&cli-side}-type = buf_clients.obj-type
  tt-fin-doc.{&cli-side}-code = buf_clients.obj-code
  tt-fin-doc.{&cli-side}-name = buf_clients.obj-name
  .
display
  tt-fin-doc.{&cli-side}-type
  tt-fin-doc.{&cli-side}-code
  tt-fin-doc.{&cli-side}-name
  with frame {&frame-name}.

    &if "{&doc-type}" = "income-cashless" or "{&doc-type}" = "expense-cashless" &then
{&GET-DISPLAY-INN-SINGLE-SCHET}
    &endif
    &if "{&doc-type}" = "income-cashless" &then
{&GET-DISPLAY-sign}
    &endif
    &if "{&doc-type}" = "expense-cash" &then
{&GET-DISPLAY-PASSPORT}
    &endif
    &if "{&doc-type}" = "income-payoff" or "{&doc-type}" = "expense-payoff" &then
{&GET-DISPLAY-sign}
    &endif
/* проставить автоматом счета и основание */
find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.cashbookId no-error .
if ub.CashBook.cli-code = tt-fin-doc.{&cli-side}-code and ub.CashBook.cli-type = tt-fin-doc.{&cli-side}-type then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  tt-fin-doc.cor-acc-value  = ub.CashBook.corrPko 
  tt-fin-doc.naznach-plat   = ub.CashBook.RuleOsnPko
  .
  
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в том числе НДС" .
  paramVne = "" .
end.
else 
do:
  if getCliKassa(tt-fin-doc.{&cli-side}-type, tt-fin-doc.{&cli-side}-code, "Vnecli", tt-fin-doc.cashbookId) then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .  
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .  

find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в т.ч.: без налога (НДС)" .
  paramVne = "vne" .
end.
else do:
  if getCliKassa(tt-fin-doc.{&cli-side}-type, tt-fin-doc.{&cli-side}-code, "Avanscli", tt-fin-doc.cashbookId) then do:  
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .  
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .  

find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в т.ч. 22/122 (НДС)" .
  paramVne = "avans" .
end.
else do:
tt-fin-doc.naznach-plat = "".

tt-fin-doc.including = "@, в том числе НДС" .
paramVne = "" .
end.
end.
end.
run proc-create-default-tax in this-procedure .
run change-view in this-procedure(rs-view).
END.

&if "{&doc-type}" = "income-cashless" or "{&doc-type}" = "expense-cashless" &then
ON CHOOSE OF B-{&cli-side}-schet IN FRAME Dialog-Frame
  DO:
{ gbl/stdbtn.i }
define variable v-rid-list as character no-undo.
define variable ref-rec    as recid     no-undo.
define variable v-status_  like ub.fin-schet.status_ no-undo init {&current-status}.
define buffer buf_fin-schet for ub.fin-schet.
if not available X_{&cli-side} then 
do:
  message
    "Не выбран" {&cli-side-title0}
    view-as alert-box error .
  return no-apply.
end.
if available X_{&cli-side}-fin-schet then
  assign
    v-rid-list = string(recid(X_{&cli-side}-fin-schet))
    v-status_  = X_{&cli-side}-fin-schet.status_
    .
run ref/finschts.w (
  INPUT parParentProc
  ,p-curr-host-code
  ,input "b-sel,b-add":U
  ,input "cmp-host":U
  ,input X_{&cli-side}.obj-type
  ,input X_{&cli-side}.obj-code
  ,input ? /*p-curr-code*/
  ,input tt-fin-doc.host-code
  ,input 0 /* p-code-bank */
  ,input-output v-status_
  ,input-output v-rid-list
  ) no-error.
if v-rid-list = "" then   
do:
  apply "entry" to b-{&cli-side}-schet in frame {&frame-name}.
  return no-apply.
end.
ref-rec = integer( v-rid-list ).
FIND FIRST buf_fin-schet WHERE
  recid (buf_fin-schet) = ref-rec NO-LOCK  .
if tt-fin-doc.curr-code <> buf_fin-schet.curr-code then 
do:
  message
    "Валюта выбранного Вами счета" {&cli-side-title} "не совпадает с валютой платежа"
    view-as alert-box error .
  return no-apply.
end.
if buf_fin-schet.status_ <> {&current-status} then 
do:
  message
    "Статус выбранного Вами счета" {&cli-side-title} buf_fin-schet.status_ " - нельзя работать с таким счетом"
    view-as alert-box error .
  return no-apply.
end.
FIND FIRST X_{&cli-side}-fin-schet WHERE
  recid (X_{&cli-side}-fin-schet) = ref-rec NO-LOCK .
find first X_{&cli-side}-fin-bank no-lock where
  X_{&cli-side}-fin-bank.host-code = tt-fin-doc.host-code
  AND X_{&cli-side}-fin-bank.code-bank = X_{&cli-side}-fin-schet.code-bank .
assign
  tt-fin-doc.{&cli-side}-bank-name  = X_{&cli-side}-fin-bank.bank-name
  tt-fin-doc.{&cli-side}-bank-city  = X_{&cli-side}-fin-bank.bank-city
  tt-fin-doc.{&cli-side}-dop1       = X_{&cli-side}-fin-schet.dop1
  tt-fin-doc.{&cli-side}-dop2       = X_{&cli-side}-fin-schet.dop2
  tt-fin-doc.{&cli-side}-bik        = X_{&cli-side}-fin-bank.bik
  tt-fin-doc.{&cli-side}-c-schet    = X_{&cli-side}-fin-schet.c-schet
  tt-fin-doc.{&cli-side}-r-schet    = X_{&cli-side}-fin-schet.r-schet
  tt-fin-doc.{&cli-side}-code-schet = X_{&cli-side}-fin-schet.code-schet
  .
display
  tt-fin-doc.{&cli-side}-bank-name
  tt-fin-doc.{&cli-side}-bank-city
  tt-fin-doc.{&cli-side}-bik
  tt-fin-doc.{&cli-side}-c-schet
  tt-fin-doc.{&cli-side}-r-schet
  with frame {&frame-name}.
END.
&endif

ON LEAVE OF tt-fin-doc.{&cli-side}-code IN FRAME Dialog-Frame
  DO:
{ gbl/stdbtn.i }
if   input frame {&frame-name} tt-fin-doc.{&cli-side}-code <> 0 then 
do:
  run check-{&cli-side} in this-procedure no-error.
  if error-status:error then 
  do:
    return no-apply.
  end.
    &if "{&doc-type}" = "income-cashless" or "{&doc-type}" = "expense-cashless" &then
  {&GET-DISPLAY-INN-SINGLE-SCHET}
    &endif
    &if "{&doc-type}" = "income-cashless" &then
  {&GET-DISPLAY-sign}
    &endif
    &if "{&doc-type}" = "expense-cash" &then
  {&GET-DISPLAY-PASSPORT}
    &endif
    &if "{&doc-type}" = "income-payoff" or "{&doc-type}" = "expense-payoff" &then
  {&GET-DISPLAY-sign}
    &endif
end.
END.


ON VALUE-CHANGED OF tt-fin-doc.{&cli-side}-type IN FRAME Dialog-Frame
  DO:
    assign
      tt-fin-doc.{&cli-side}-type.
    if   input frame {&frame-name} tt-fin-doc.{&cli-side}-code <> 0 then 
    do:
      run check-{&cli-side} in this-procedure no-error.
      if error-status:error then 
      do:
        return no-apply.
      end.
    &if "{&doc-type}" = "income-cashless" or "{&doc-type}" = "expense-cashless" &then
      {&GET-DISPLAY-INN-SINGLE-SCHET}
    &endif
    &if "{&doc-type}" = "income-cashless" &then
      {&GET-DISPLAY-sign}
    &endif
    &if "{&doc-type}" = "expense-cash" &then
      {&GET-DISPLAY-PASSPORT}
    &endif
    &if "{&doc-type}" = "income-payoff" or "{&doc-type}" = "expense-payoff" &then
      {&GET-DISPLAY-sign}
    &endif
    end.
  END.

PROCEDURE check-{&cli-side} :
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where
    buf_clients.obj-code = input frame {&frame-name} tt-fin-doc.{&cli-side}-code
    and buf_clients.obj-type = input frame {&frame-name} tt-fin-doc.{&cli-side}-type no-error.
  if not available buf_clients then 
  do:
    if input frame {&frame-name} tt-fin-doc.{&cli-side}-code <> ?  then
      message "Неправильный код или тип " {&cli-side-title}.
    apply "entry" to tt-fin-doc.{&cli-side}-code in frame {&frame-name}.
    return error.
  end.
  find first X_{&cli-side} no-lock where recid(X_{&cli-side}) = recid(buf_clients).
  assign
    tt-fin-doc.{&cli-side}-type = buf_clients.obj-type
    tt-fin-doc.{&cli-side}-code = buf_clients.obj-code
    tt-fin-doc.{&cli-side}-name = buf_clients.obj-name
    .

/* проставить автоматом счета и основание */
find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.cashbookId no-error .
if ub.CashBook.cli-code = tt-fin-doc.{&cli-side}-code and ub.CashBook.cli-type = tt-fin-doc.{&cli-side}-type then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  tt-fin-doc.cor-acc-value  = ub.CashBook.corrPko 
  tt-fin-doc.naznach-plat   = ub.CashBook.RuleOsnPko
  .
  
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.

end.
else 
do:
if getCliKassa(tt-fin-doc.{&cli-side}-type, tt-fin-doc.{&cli-side}-code, "Vnecli", tt-fin-doc.cashbookId) then do:   
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .  
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .  

find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
  
end.
else do:
if getCliKassa(tt-fin-doc.{&cli-side}-type, tt-fin-doc.{&cli-side}-code, "Avanscli", tt-fin-doc.cashbookId) then do:   
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .  
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .  

find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
  
end.
else do:
tt-fin-doc.naznach-plat = "".
end.
end.
end.


  display
    tt-fin-doc.{&cli-side}-type
    tt-fin-doc.{&cli-side}-code
    tt-fin-doc.{&cli-side}-name
    with frame {&frame-name}.

END PROCEDURE.

on return of tt-fin-doc.payer-code in frame {&frame-name} 
  do:
    apply "leave" to tt-fin-doc.payer-code in frame {&frame-name}.
    return no-apply.
  end.

    
ON LEAVE OF tt-fin-doc.payer-code IN FRAME Dialog-Frame /* Код ан. уч. */
  DO:
define buffer buf_clients for ub.clients .
assign tt-fin-doc.payer-code .
if tt-fin-doc.payer-code = 0 then leave.
FIND FIRST buf_clients WHERE buf_clients.obj-code = tt-fin-doc.payer-code
and buf_clients.obj-type = tt-fin-doc.payer-type NO-LOCK .
if NOT available (buf_clients) then 
do:
  message
    "Выберите контрагента типа" {&cmp} "или" {&prs}
    view-as alert-box error .
  return no-apply.
end.
find first X_{&cli-side} no-lock where
  recid(X_{&cli-side}) = recid(buf_clients).
assign
  tt-fin-doc.{&cli-side}-type = buf_clients.obj-type
  tt-fin-doc.{&cli-side}-code = buf_clients.obj-code
  tt-fin-doc.{&cli-side}-name = buf_clients.obj-name
  .
display
  tt-fin-doc.{&cli-side}-type
  tt-fin-doc.{&cli-side}-code
  tt-fin-doc.{&cli-side}-name
  with frame {&frame-name}.

    &if "{&doc-type}" = "income-cashless" or "{&doc-type}" = "expense-cashless" &then
{&GET-DISPLAY-INN-SINGLE-SCHET}
    &endif
    &if "{&doc-type}" = "income-cashless" &then
{&GET-DISPLAY-sign}
    &endif
    &if "{&doc-type}" = "expense-cash" &then
{&GET-DISPLAY-PASSPORT}
    &endif
    &if "{&doc-type}" = "income-payoff" or "{&doc-type}" = "expense-payoff" &then
{&GET-DISPLAY-sign}
    &endif
/* проставить автоматом счета и основание */
find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.cashbookId no-error .
if ub.CashBook.cli-code = tt-fin-doc.{&cli-side}-code and ub.CashBook.cli-type = tt-fin-doc.{&cli-side}-type then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  tt-fin-doc.cor-acc-value  = ub.CashBook.corrPko 
  tt-fin-doc.naznach-plat   = ub.CashBook.RuleOsnPko
  .
  
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в том числе НДС" .
  paramVne = "" .
end.
else 
do:
  if getCliKassa(tt-fin-doc.{&cli-side}-type, tt-fin-doc.{&cli-side}-code, "Vnecli", tt-fin-doc.cashbookId) then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .  
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .  

find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в т.ч.: без налога (НДС)" .
  paramVne = "vne" .
end.
else do:
  if getCliKassa(tt-fin-doc.{&cli-side}-type, tt-fin-doc.{&cli-side}-code, "Avanscli", tt-fin-doc.cashbookId) then do:  
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .  
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = {&by_all}
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .  

find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc
  then 
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.

find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer({&current-status-int})  
  no-error .
if available X_fin-code-cor-acc1
  then 
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в т.ч. 22/122 (НДС)" .
  paramVne = "avans" .
end.
else do:
tt-fin-doc.naznach-plat = "".

tt-fin-doc.including = "@, в том числе НДС" .
paramVne = "" .
end.
end.
end.
run proc-create-default-tax in this-procedure .
run change-view in this-procedure(rs-view).
END.


ON LEAVE OF tt-fin-doc.an-uchet-value IN FRAME Dialog-Frame /* Код ан. уч. */
  DO:
{ gbl/stdbtn.i }
assign
  tt-fin-doc.an-uchet-value.
FIND X_fin-code-an-uchet WHERE
  X_fin-code-an-uchet.code-value  = tt-fin-doc.an-uchet-value
  AND     X_fin-code-an-uchet.host-code  = tt-fin-doc.host-code
  AND  X_fin-code-an-uchet.status_ = integer({&current-status-int})
  NO-LOCK NO-error.
if not available X_fin-code-an-uchet
  then 
do:
  assign
    tt-fin-doc.an-uchet-value = {&question-mark}
    f-an-uchet-descr          = "":U
    .
  display
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    with frame {&frame-name}.
  .
end.
else 
do:
  assign
    f-an-uchet-descr = X_fin-code-an-uchet.descr
    .
  display
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    with frame {&frame-name}.
  .
end.
END.

ON CHOOSE OF B-contract-view IN FRAME Dialog-Frame /* Договор */
  DO:
    define variable g-log as logical no-undo.
    define variable ri    as recid   no-undo .

  { gbl/stdbtn.i }
if not avail X_contract then return no-apply.
{ gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_lookup':U
    {&cntxt-firm}
    tt-fin-doc.host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }

if not g-log then  return .
ri = recid( X_contract ).
run str/sh-contr.p ( input parParentProc,  input ri) no-error.
if error-status:error then return no-apply.

END.

ON CHOOSE OF B-cashbook IN FRAME Dialog-Frame /* Кассовая книга */
  DO:
    define variable v-cb-brw as class ibs.th.ref.cashbookbrw no-undo .
  
    v-cb-brw = new ibs.th.ref.cashbookbrw ( {&SELECT}, parparentproc ).

    wait-for  v-cb-brw:ShowDialog() .
  
    if v-cb-brw:out-list-id > ""
      then 
    do :
      find first ub.cashbook no-lock where ub.cashbook.id = int64(v-cb-brw:out-list-id) .
      tt-fin-doc.cashbookId = ub.cashbook.id .
      f-cashbook = ub.CashBook.CashBookName .
      display
        f-cashbook
        with frame {&frame-name} .
      IF LOOKUP("update_prc-doc-code-mask", THIS-PROCEDURE:INTERNAL-ENTRIES) >  0 
        THEN 
        run update_prc-doc-code-mask (no). /* Возможно процедуры нет */
      run check-obj in this-procedure (   input tt-fin-doc.obj-type
        ,input tt-fin-doc.obj-code
        )
        no-error.
      /*      if ub.cashbook.id > 0*/
      /*        then               */
      /*      do :                 */
      
      find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = (if tt-fin-doc.fin-doc-type eq {&expense-cash} then ub.cashbook.corrRko else ub.cashbook.corrPko)
        and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
        and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
        no-error .
      if available X_fin-code-cor-acc
        then 
      do :
        assign
          tt-fin-doc.cor-acc-value = X_fin-code-cor-acc.code-value
          f-cor-acc-descr          = X_fin-code-cor-acc.descr
          tt-fin-doc.cor-acc       = X_fin-code-cor-acc.fin-code
          .
      end.
      else 
      do:
        if ub.cashbook.corrRko = "" then 
        do:
          for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = "57.01"
            and ub.fin-code-cor-acc.host-code = p-curr-host-code :
            tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
            tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
          end. 
        end.    
      end.  
      if ub.CashBook.OsnAcct <> "" then 
      do:
        find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = ub.CashBook.OsnAcct
          and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
          and X_fin-code-cor-acc.status_ = integer({&current-status-int})  
          no-error .
        if available X_fin-code-cor-acc
          then 
        do :
          assign
            tt-fin-doc.cor-acc1-value = X_fin-code-cor-acc.code-value
            f-cor-acc1-descr          = X_fin-code-cor-acc.descr
            tt-fin-doc.cor-acc1       = X_fin-code-cor-acc.fin-code
            .
        end.   
        else 
        do:
          assign
            tt-fin-doc.cor-acc1-value = ""
            f-cor-acc1-descr          = ""
            tt-fin-doc.cor-acc1       = ?
            .
        end.       
      end.
    /*      end.*/
    /*      else*/
    /*      do :*/
    /*        find first ub.sysconf no-lock where ub.sysconf.host-code = tt-fin-doc.host-code .                           */
    /*        case tt-fin-doc.fin-doc-type :                                                                              */
    /*          when {&income-cash}                                                                                       */
    /*          then                                                                                                      */
    /*            do :                                                                                                    */
    /*              if tt-fin-doc.contract-code = 0                                                                       */
    /*                then                                                                                                */
    /*              do:                                                                                                   */
    /*                find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.fin-code = ub.sysconf.cor-acc-in-cash*/
    /*                  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code                                           */
    /*                  and X_fin-code-cor-acc.status_ = integer({&current-status-int})                                   */
    /*                  no-error .                                                                                        */
    /*                if available X_fin-code-cor-acc                                                                     */
    /*                  then                                                                                              */
    /*                do :                                                                                                */
    /*                  assign                                                                                            */
    /*                    tt-fin-doc.cor-acc-value = X_fin-code-cor-acc.code-value                                        */
    /*                    f-cor-acc-descr          = X_fin-code-cor-acc.descr                                             */
    /*                    tt-fin-doc.cor-acc       = X_fin-code-cor-acc.fin-code                                          */
    /*                    .                                                                                               */
    /*                end.                                                                                                */
    /*                else                                                                                                */
    /*                do :                                                                                                */
    /*                  assign                                                                                            */
    /*                    tt-fin-doc.cor-acc-value = ""                                                                   */
    /*                    f-cor-acc-descr          = ""                                                                   */
    /*                    tt-fin-doc.cor-acc       = 0                                                                    */
    /*                    .                                                                                               */
    /*                end.                                                                                                */
    /*              end.                                                                                                  */
    /*              else                                                                                                  */
    /*              do :                                                                                                  */
    /*                assign                                                                                              */
    /*                  tt-fin-doc.cor-acc-value = ""                                                                     */
    /*                  f-cor-acc-descr          = ""                                                                     */
    /*                  tt-fin-doc.cor-acc       = 0                                                                      */
    /*                  .                                                                                                 */
    /*              end.                                                                                                  */
    /*            end.                                                                                                    */
    /*          when {&expense-cash}                                                                                        */
    /*          then                                                                                                        */
    /*            do :                                                                                                      */
    /*              if tt-fin-doc.contract-code = 0                                                                         */
    /*                then                                                                                                  */
    /*              do:                                                                                                     */
    /*                find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.fin-code = ub.sysconf.cor-acc1-out-cash*/
    /*                  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code                                             */
    /*                  and X_fin-code-cor-acc.status_ = integer({&current-status-int})                                     */
    /*                  no-error .                                                                                          */
    /*                if available X_fin-code-cor-acc                                                                       */
    /*                  then                                                                                                */
    /*                do :                                                                                                  */
    /*                  assign                                                                                              */
    /*                    tt-fin-doc.cor-acc-value = X_fin-code-cor-acc.code-value                                          */
    /*                    f-cor-acc-descr          = X_fin-code-cor-acc.descr                                               */
    /*                    tt-fin-doc.cor-acc       = X_fin-code-cor-acc.fin-code                                            */
    /*                    .                                                                                                 */
    /*                end.                                                                                                  */
    /*                else                                                                                                  */
    /*                do :                                                                                                  */
    /*                  assign                                                                                              */
    /*                    tt-fin-doc.cor-acc-value = ""                                                                     */
    /*                    f-cor-acc-descr          = ""                                                                     */
    /*                    tt-fin-doc.cor-acc       = 0                                                                      */
    /*                    .                                                                                                 */
    /*                end.                                                                                                  */
    /*              end.                                                                                                    */
    /*              else                                                                                                    */
    /*              do :                                                                                                    */
    /*                assign                                                                                                */
    /*                  tt-fin-doc.cor-acc-value = ""                                                                       */
    /*                  f-cor-acc-descr          = ""                                                                       */
    /*                  tt-fin-doc.cor-acc       = 0                                                                        */
    /*                  .                                                                                                   */
    /*              end.                                                                                                    */
    /*            end.                                                                                                      */
    /*        end case .                                                                                                    */
    /*      end .*/
    end.
    display
      tt-fin-doc.cor-acc-value                                                                     
      f-cor-acc-descr                                                                              
      tt-fin-doc.cor-acc      
      tt-fin-doc.cor-acc1-value                                                                     
      f-cor-acc1-descr                                                                              
      tt-fin-doc.cor-acc1
      with frame {&frame-name} .       
  END.

ON CHOOSE OF B-an-uchet IN FRAME Dialog-Frame /* Btn 1 */
  DO:
    define variable rid-list as character no-undo.
{ gbl/stdbtn.i }
rid-list = "":U .
run ref/fwcode-3.w (
  parParentProc
  ,"b-sel"
  ,{&company}
  ,input (if available X_fin-code-an-uchet then recid(X_fin-code-an-uchet) else ?)
  ,input p-curr-host-code
  ,output rid-list ).
if rid-list <> "":U then 
do:
  FIND FIRST X_fin-code-an-uchet WHERE
    recid( X_fin-code-an-uchet ) = integer(entry(1, rid-list)) NO-LOCK .
  if X_fin-code-an-uchet.status_ <> integer({&current-status-int}) then 
  do:
    message
      "Нельзя выбрать удаленный код аналитического учета"
      view-as alert-box error .
    return no-apply.
  end.
  assign
    tt-fin-doc.an-uchet-value = X_fin-code-an-uchet.code-value
    f-an-uchet-descr          = X_fin-code-an-uchet.descr
    tt-fin-doc.an-uchet-code  = X_fin-code-an-uchet.fin-code
    .
  display
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    with frame {&frame-name} .
end.
END.

ON CHOOSE OF B-cel-nazn IN FRAME Dialog-Frame /* Btn 1 */
  DO:
    define variable rid-list as character no-undo.
{ gbl/stdbtn.i }
rid-list = "":U .
run ref/fwcode-2.w (
  parParentProc
  ,"b-sel"
  ,{&company}
  ,input (if available X_fin-code-cel-nazn then recid(X_fin-code-cel-nazn) else ?)
  ,input p-curr-host-code
  ,output rid-list ).
if rid-list <> "":U then 
do:
  FIND FIRST X_fin-code-cel-nazn WHERE
    recid( X_fin-code-cel-nazn ) = integer(entry(1, rid-list)) NO-LOCK .
  if X_fin-code-cel-nazn.status_ <> integer({&current-status-int}) then 
  do:
    message
      "Нельзя выбрать удаленный код целевого назначения "
      view-as alert-box error .
    return no-apply.
  end.

  assign
    tt-fin-doc.cel-nazn-value = X_fin-code-cel-nazn.code-value
    f-cel-nazn-descr          = X_fin-code-cel-nazn.descr
    tt-fin-doc.cel-nazn-code  = X_fin-code-cel-nazn.fin-code
    .
  display
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    with frame {&frame-name} .

end.
END.

ON CHOOSE OF B-cor-acc IN FRAME Dialog-Frame /* Btn 1 */
  DO:
    define variable rid-list as character no-undo.
{ gbl/stdbtn.i }
rid-list = "":U .
run ref/fwcode-1.w (
  parParentProc
  ,"b-sel"
  ,{&company}
  ,input (if available X_fin-code-cor-acc then recid(X_fin-code-cor-acc) else ?)
  ,input p-curr-host-code
  ,output rid-list ).

if rid-list <> "":U then 
do:
  FIND FIRST X_fin-code-cor-acc WHERE
    recid( X_fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
  if X_fin-code-cor-acc.status_ <> integer({&current-status-int}) then 
  do:
    message
      "Нельзя выбрать удаленный корр счет"
      view-as alert-box error .
    return no-apply.
  end.
  assign
    tt-fin-doc.cor-acc-value = X_fin-code-cor-acc.code-value
    f-cor-acc-descr          = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc       = X_fin-code-cor-acc.fin-code
    .
  display
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    with frame {&frame-name} .
end.
END.

&if "{&doc-type}" = "income-cash" or "{&doc-type}" = "expense-cash"  &then

on leave of tt-fin-doc.shift-date in frame {&frame-name} 
  do:
    if input frame {&frame-name} tt-fin-doc.shift-date <> tt-fin-doc.shift-date then 
    do:
      assign
        tt-fin-doc.shift-name = ""
        tt-fin-doc.shift-num  = 0.
      display
        tt-fin-doc.shift-name
        tt-fin-doc.shift-num with frame {&frame-name}.
      apply "entry" to tt-fin-doc.shift-name in frame {&frame-name}.
      return no-apply.
    end.
  end.

on return of tt-fin-doc.shift-date in frame {&frame-name} 
  do:
    apply "entry" to tt-fin-doc.shift-name in frame {&frame-name}.
    return no-apply.
  end.


on leave of tt-fin-doc.shift-num  in frame {&frame-name} 
  do:
    run proc-shift-num no-error.
    if error-status:error then 
    do:
      return no-apply.
    end.
  end.

on leave of tt-fin-doc.shift-name in frame {&frame-name} 
  do:
    run proc-shift-name no-error.
    if error-status:error then 
    do:
      return no-apply.
    end.
  end.


ON CHOOSE OF r-sht IN FRAME Dialog-Frame /* r-sht */
  DO:
    run proc-sht in this-procedure no-error.
  END.
&endif

&if "{&doc-type}" = "income-cash" or "{&doc-type}" = "expense-cash"  or "{&doc-type}" = "income-payoff" or "{&doc-type}" = "expense-payoff"   &then


ON CHOOSE OF B-cor-acc1 IN FRAME Dialog-Frame /* Btn 1 */
  DO:
    define variable rid-list as character no-undo.
{ gbl/stdbtn.i }
rid-list = "":U .
run ref/fwcode-1.w (
  parParentProc
  ,"b-sel"
  ,{&company}
  ,input (if available X_fin-code-cor-acc1 then recid(X_fin-code-cor-acc1) else ?)
  ,input p-curr-host-code
  ,output rid-list ).
if rid-list <> "":U then 
do:
  FIND FIRST X_fin-code-cor-acc1 WHERE
    recid( X_fin-code-cor-acc1 ) = integer(entry(1, rid-list)) NO-LOCK .
  if X_fin-code-cor-acc1.status_ <> integer({&current-status-int}) then 
  do:
    message
      "Нельзя выбрать удаленный корр счет"
      view-as alert-box error .
    return no-apply.
  end.

  assign
    tt-fin-doc.cor-acc1-value = X_fin-code-cor-acc1.code-value
    f-cor-acc1-descr          = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc1       = X_fin-code-cor-acc1.fin-code
    .
  display
    tt-fin-doc.cor-acc1-value
    f-cor-acc1-descr
    with frame {&frame-name} .
end.
END.

ON LEAVE OF tt-fin-doc.cor-acc1-value IN FRAME Dialog-Frame /* cor-acc1-value */
  DO:
{ gbl/stdbtn.i }
assign
  tt-fin-doc.cor-acc1-value.
FIND X_fin-code-cor-acc1 WHERE
  X_fin-code-cor-acc1.code-value  = tt-fin-doc.cor-acc1-value
  AND      X_fin-code-cor-acc1.host-code  = tt-fin-doc.host-code
  AND X_fin-code-cor-acc1.status_ = integer({&current-status-int})
  NO-LOCK NO-error.

if not available X_fin-code-cor-acc1
  then 
do:
  assign
    tt-fin-doc.cor-acc1-value = {&question-mark}
    f-cor-acc1-descr          = "":U
    .
  display
    tt-fin-doc.cor-acc1-value
    f-cor-acc1-descr
    with frame {&frame-name}.
  .
end.
else 
do:
  assign
    f-cor-acc1-descr = X_fin-code-cor-acc1.descr
    .
  display
    tt-fin-doc.cor-acc1-value
    f-cor-acc1-descr
    with frame {&frame-name}.
  .
end.
END.
&endif

ON CHOOSE OF B-currency IN FRAME Dialog-Frame /* Btn 1 */
  DO:
    define variable rr          as recid no-undo.
    define variable v-curr-code like ub.fin-doc.curr-code no-undo.
{ gbl/stdbtn.i }
assign
  v-curr-code = tt-fin-doc.curr-code
  tt-fin-doc.curr-code.

if available X_currency then rr = recid(X_currency).
else rr = ?.
run ref/currency.w (parparentproc, "b-sel", input-output rr ).
if rr <> ? then 
do:
  FIND FIRST X_currency WHERE
    recid( X_currency ) = rr NO-LOCK .
  assign
    tt-fin-doc.curr-code = X_currency.curr-code
    f-curr-abbr          = X_currency.curr-abbr
    .
  DISPLAY
    tt-fin-doc.curr-code
    f-curr-abbr
    with frame {&frame-name} .
end.
if tt-fin-doc.curr-code <> v-curr-code then 
do:
  run recalc in this-procedure("curr-code":U) no-error.
  if error-status:error then 
  do:
    assign
      tt-fin-doc.curr-code = v-curr-code
      .
    display tt-fin-doc.curr-code
      with frame {&frame-name}.
  end.
  run hide-view-currency in this-procedure .
end.
END.

ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
  DO:
{ gbl/stdbtn.i }
find tt0-fin-doc-tax no-lock where
  tt0-fin-doc-tax.host-code = tt-fin-doc.host-code
  AND tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code no-error .
if not available tt0-fin-doc-tax
  or
  tt0-fin-doc-tax.sum-line-doc = 0
  then 
do:
  run proc-create-default-tax  in this-procedure .
  run proc-update-sum-vat-chr in this-procedure (input-output v-start).
end.
run proc-save in this-procedure (yes)  no-error.
if error-status:error then return no-apply.

END.

ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
  DO:
    define variable v-rid-list as character no-undo.
{ gbl/stdbtn.i }
run ref/fincdocs.w
  (
  input parParentProc
  ,input p-curr-host-code
  ,input "":U /*bttns*/
  ,input "one":U
  ,input locked_fin-doc.host-code
  ,input '' /*p-obj-type*/
  ,input 0 /*p-obj-code*/
  ,input locked_fin-doc.fin-doc-code
  ,input-output v-rid-list
  )
  .

END.

ON CHOOSE OF B-payer-view IN FRAME Dialog-Frame /* Плательщик */
  DO:
{ gbl/stdbtn.i }
if available X_payer
  or tt-fin-doc.fin-doc-type = {&expense-cash}
  or tt-fin-doc.fin-doc-type = {&expense-cashless}
  or tt-fin-doc.fin-doc-type = {&expense-payoff}
  or p-mode <> {&add-def}
  then
  run ref/showcli.p
    (input parParentProc
    ,input tt-fin-doc.payer-type /* p-obj-type */
    ,input tt-fin-doc.payer-code /* p-obj-code */
    ).

END.

ON CHOOSE OF B-receiver-view IN FRAME Dialog-Frame /* Получатель */
  DO:
{ gbl/stdbtn.i }
if available X_receiver
  or tt-fin-doc.fin-doc-type = {&income-cash}
  or tt-fin-doc.fin-doc-type = {&income-cashless}
  or tt-fin-doc.fin-doc-type = {&income-payoff}
  or p-mode <> {&add-def}
  then
  run ref/showcli.p
    (input parParentProc
    ,input tt-fin-doc.receiver-type /* p-obj-type */
    ,input tt-fin-doc.receiver-code /* p-obj-code */
    ).

END.

ON CHOOSE OF B-tax IN FRAME Dialog-Frame /* Налоги */
  DO:
{ gbl/stdbtn.i }
find first tt0-fin-doc-tax no-lock where
  tt0-fin-doc-tax.host-code = tt-fin-doc.host-code
  AND tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code no-error .
if not available tt0-fin-doc-tax
  or
  tt0-fin-doc-tax.sum-line-doc = 0
  then 
do:
  run proc-create-default-tax  in this-procedure .
end.
assign
  tt-fin-doc.obj-code
  tt-fin-doc.obj-type = (if tt-fin-doc.obj-code = 0 then "":U else tt-fin-doc.obj-type)
  .
run ref/fndocti.w (
  INPUT parParentProc
  ,input p-curr-host-code
  ,input (if tt-fin-doc.status_ = {&fin-new} then p-mode else {&lookup})
  ,input tt-fin-doc.host-code
  ,input tt-fin-doc.fin-doc-code
  ,input tt-fin-doc.fin-doc-type
  ,input tt-fin-doc.fin-ext-doc-type
  ,input tt-fin-doc.trn-doc-code
  ,input tt-fin-doc.contract-code
  ,input tt-fin-doc.sum-doc
  ,input tt-fin-doc.curr-code
  ,input tt-fin-doc.base-rate
  ,input tt-fin-doc.base-scale
  ,input tt-fin-doc.exch-rate
  ,input tt-fin-doc.exch-scale
  ,input tt-fin-doc.obj-type
  ,input tt-fin-doc.obj-code
  ,input-output table tt0-fin-doc-tax
  ,input 0 /*chip-num в моде показа истории*/
  ).
run proc-update-sum-vat-chr in this-procedure (input-output v-start).
END.

&if "{&doc-type}" = "income-cash"
or "{&doc-type}" = "income-cashless"
or "{&doc-type}" = "income-payoff"
&then
ON CHOOSE OF B-cards IN FRAME Dialog-Frame /* Налоги */
  DO:
{ gbl/stdbtn.i }
assign
  tt-fin-doc.obj-code
  tt-fin-doc.obj-type = (if tt-fin-doc.obj-code = 0 then "":U else tt-fin-doc.obj-type)
  .
run ref/fndocdc.w (
  INPUT parParentProc
  ,input p-curr-host-code
  ,input (if tt-fin-doc.status_ = {&fin-new} then p-mode else {&lookup})
  ,input tt-fin-doc.host-code
  ,input tt-fin-doc.fin-doc-code
  ,input tt-fin-doc.fin-doc-type
  ,input tt-fin-doc.fin-ext-doc-type
  ,input tt-fin-doc.trn-doc-code
  ,input tt-fin-doc.payer-type
  ,input tt-fin-doc.payer-code
  ,input tt-fin-doc.sum-doc
  ,input tt-fin-doc.doc-date
  ,input tt-fin-doc.pay-date
  ,input tt-fin-doc.curr-code
  ,input tt-fin-doc.base-rate
  ,input tt-fin-doc.base-scale
  ,input tt-fin-doc.exch-rate
  ,input tt-fin-doc.exch-scale
  ,input tt-fin-doc.obj-type
  ,input tt-fin-doc.obj-code
  ,input-output table tt0-payment
  ,input 0 /*chip-num в моде показа истории*/
  ).
END.
&endif

ON LEAVE OF tt-fin-doc.cel-nazn-value IN FRAME Dialog-Frame /* Код цел.назн. */
  DO:
{ gbl/stdbtn.i }
assign
  tt-fin-doc.cel-nazn-value.
FIND X_fin-code-cel-nazn WHERE
  X_fin-code-cel-nazn.code-value  = tt-fin-doc.cel-nazn-value
  AND     X_fin-code-cel-nazn.host-code  = tt-fin-doc.host-code
  AND X_fin-code-cel-nazn.status_ = integer({&current-status-int})
  NO-LOCK NO-error.

if not available X_fin-code-cel-nazn
  then 
do:
  assign
    tt-fin-doc.cel-nazn-value = {&question-mark}
    f-cel-nazn-descr          = "":U
    .
  display
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    with frame {&frame-name}.
  .
end.
else 
do:
  assign
    f-cel-nazn-descr          = X_fin-code-cel-nazn.descr
    tt-fin-doc.cel-nazn-value = X_fin-code-cel-nazn.code-value
    .
  display
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    with frame {&frame-name}.
  .
end.
END.

ON LEAVE OF tt-fin-doc.cor-acc-value IN FRAME Dialog-Frame /* Корсчет */
  DO:
{ gbl/stdbtn.i }
assign
  tt-fin-doc.cor-acc-value.
FIND X_fin-code-cor-acc WHERE
  X_fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
  AND X_fin-code-cor-acc.host-code  = tt-fin-doc.host-code
  AND  X_fin-code-cor-acc.status_ = integer({&current-status-int})
  NO-LOCK NO-error.

if not available X_fin-code-cor-acc
  then 
do:
  assign
    tt-fin-doc.cor-acc-value = {&question-mark}
    f-cor-acc-descr          = "":U
    .
  display
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    with frame {&frame-name}.
  .
end.
else 
do:
  assign
    f-cor-acc-descr = X_fin-code-cor-acc.descr
    .
  display
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    with frame {&frame-name}.
  .
end.
END.

ON LEAVE OF tt-fin-doc.curr-code IN FRAME Dialog-Frame /* Вал */
  DO:
    define variable v-curr-code like ub.fin-doc.curr-code no-undo.
{ gbl/stdbtn.i }
assign
  v-curr-code = tt-fin-doc.curr-code
  tt-fin-doc.curr-code.
FIND FIRST X_currency WHERE
  X_currency.curr-code = tt-fin-doc.curr-code NO-LOCK NO-error.

if not available X_currency then 
do:
  message
    "Нет валюты с кодом"   tt-fin-doc.curr-code
    view-as alert-box error.
  assign
    tt-fin-doc.curr-code = v-curr-code.
  display
    tt-fin-doc.curr-code
    with frame {&frame-name}.
  .
end.
else 
do:
  assign
    f-curr-abbr = X_currency.curr-abbr
    .
  display
    f-curr-abbr
    tt-fin-doc.curr-code
    with frame {&frame-name}.
  .
  if tt-fin-doc.curr-code <> v-curr-code then 
  do:
    run recalc in this-procedure("curr-code":U) no-error.
    if error-status:error then 
    do:
      assign
        tt-fin-doc.curr-code = v-curr-code
        .
      display tt-fin-doc.curr-code
        with frame {&frame-name}.
    end.
    run hide-view-currency in this-procedure .
  end.
end.
END.

ON LEAVE OF tt-fin-doc.doc-date IN FRAME Dialog-Frame /* Дата сост. */
  DO:
{ gbl/stdbtn.i }
define variable v-doc-date as date    no-undo.
define variable vlog       as logical no-undo .
  &if "{&doc-type}" = "income-cash" or "{&doc-type}" = "expense-cash"  &then
if tt-fin-doc.shift-flag = integer({&fin-flag-shift}) then 
do:
  if tt-fin-doc.shift-date >  input frame {&frame-name}  tt-fin-doc.doc-date  then 
  do:
    message
      "Дата документа не может быть меньше даты смены!"
      view-as alert-box error .
    return no-apply.
  end.
end.
  &endif
assign
  v-doc-date = tt-fin-doc.doc-date
  tt-fin-doc.doc-date
  .
if tt-fin-doc.doc-date <> v-doc-date
  and (input frame {&frame-name}   tt-fin-doc.sum-doc <> 0
  or tt-fin-doc.sum-doc <> 0)
  then 
do:
  message
    "Пересчитать суммы документа в соответствии с курсами на новую дату?"
    view-as alert-box QUESTION buttons YEs-NO update vlog.
  if  vlog then 
  do:
    run recalc in this-procedure ("doc-date":U) no-error.
    if error-status:error then 
    do:
      assign
        tt-fin-doc.doc-date = v-doc-date
        .
      display tt-fin-doc.doc-date
        with frame {&frame-name}.
    end.
  end.
end.
END.


ON VALUE-CHANGED OF RS-view IN FRAME Dialog-Frame
  DO:
    assign
      RS-view
      .
    assign
      v-not-uf-set = no
      .
    run change-view in this-procedure(rs-view).
  END.

ON LEAVE OF tt-fin-doc.sum-doc IN FRAME Dialog-Frame /* Сумма */
  DO:
    define variable v-sum-doc like ub.fin-doc.sum-doc no-undo .
{ gbl/stdbtn.i }
assign
  v-sum-doc = tt-fin-doc.sum-doc
  tt-fin-doc.sum-doc
  .
if v-sum-doc <> tt-fin-doc.sum-doc then
  run recalc in this-procedure("sum-doc").
END.


PROCEDURE check-sums-rate :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define variable v-exch-rate  like ub.fin-doc.sum-doc no-undo .
  define variable v-exch-scale like ub.fin-doc.sum-doc no-undo .
/*
if tt-fin-doc.curr-code = 0 then do:
    RUN recalc in this-procedure(v-main-sum).
end.
assign
v-exch-rate = tt-fin-doc.sum-rubl / tt-fin-doc.sum-doc
v-exch-scale = 1
.
if v-exch-rate / v-exch-scale <> tt-fin-doc.exch-rate / tt-fin-doc.exch-scale then do:
  message
  "Не согласованы курсы и суммы по документу"
  view-as alert-box error .
  return error.
end.
*/
END PROCEDURE.


PROCEDURE disable-enable :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define input parameter p-main-widget as character no-undo.
  define input parameter p-main-curr as character no-undo .
  /*сначала все позадизайблим*/
  disable
    tt-fin-doc.sum-doc
    tt-fin-doc.sum-rubl
    tt-fin-doc.sum-base
    tt-fin-doc.base-rate
    tt-fin-doc.base-scale
    tt-fin-doc.exch-rate
    tt-fin-doc.exch-scale
    tt-fin-doc.sum-contr
    tt-fin-doc.contract-rate
    tt-fin-doc.contract-scale
    with frame {&frame-name} .
  assign
    v-main-sum  = if p-main-widget <> "":U then p-main-widget else v-main-sum
    v-main-curr = if p-main-curr <> "":U then p-main-curr else v-main-curr
    .
  if v-limit-access > 0 then 
  do:
    display
      tt-fin-doc.sum-rubl            
      when v-rubf
      tt-fin-doc.sum-base            
      when v-basef
      tt-fin-doc.exch-rate           
      when v-exchf
      tt-fin-doc.exch-scale          
      when v-exchf
      tt-fin-doc.base-rate           
      when v-basef
      tt-fin-doc.base-scale          
      when v-basef
      tt-fin-doc.sum-contr           
      when v-contractf
      tt-fin-doc.contract-rate       
      when v-contractratef
      tt-fin-doc.contract-scale      
      when v-contractratef
      with frame {&frame-name}.
    return.
  end.
  CASE p-main-widget:
    when "sum-doc" then 
      do:
        enable
          tt-fin-doc.sum-doc
          with frame {&frame-name}.
        APPLY "ENTRY" to tt-fin-doc.sum-doc.
      end.
  END CASE.
  display
    tt-fin-doc.sum-rubl            
    when v-rubf
    tt-fin-doc.sum-base            
    when v-basef
    tt-fin-doc.exch-rate           
    when v-exchf
    tt-fin-doc.exch-scale          
    when v-exchf
    tt-fin-doc.base-rate           
    when v-basef
    tt-fin-doc.base-scale          
    when v-basef
    tt-fin-doc.sum-contr           
    when v-contractf
    tt-fin-doc.contract-rate       
    when v-contractratef
    tt-fin-doc.contract-scale      
    when v-contractratef
    with frame {&frame-name}.
  CASE rs-view:
    when "full":u then 
      do:
        assign
          v-tab-order = {&full-view-tab-order}
          .
      end.
    when "brief":u then 
      do:
        assign
          v-tab-order = {&brief-view-tab-order}
          .
      end.
    when "contract":u then 
      do:
        assign
          v-tab-order = {&contract-view-tab-order}
          .
      end.
  END CASE.


END PROCEDURE.

{ str/lib-farh.i }
PROCEDURE fill-tables :
  define buffer buf_fin-doc-tax  for ub.fin-doc-tax.
  define buffer buf_fin-doc-attr for ub.fin-doc-attr.
  define buffer buf_fin-ob-tax   for ub.fin-ob-tax.
  define buffer buf_fin-connect  for ub.fin-connect.
  define buffer buf_fin-ob       for ub.fin-ob.
  define buffer buf_payment      for ub.payment.

  if p-mode = {&add-def}
    AND p-ob-doc-code <> "" then 
  do:
    for each buf_fin-ob-tax no-lock where
      buf_fin-ob-tax.host-code = tt-fin-doc.fin-doc-code
      AND buf_fin-ob-tax.doc-code = p-ob-doc-code:
      create tt0-fin-doc-tax.
      buffer-copy buf_fin-ob-tax to tt0-fin-doc-tax.
    end.
    return.
  end.
  if p-mode = {&add-def}
    and v-copy-mode = yes then 
  do:
    for each buf_fin-doc-tax no-lock where
      buf_fin-doc-tax.host-code = locked_fin-doc.host-code
      AND buf_fin-doc-tax.fin-doc-code = locked_fin-doc.fin-doc-code
      :
      create tt0-fin-doc-tax.
      buffer-copy buf_fin-doc-tax except fin-doc-code to tt0-fin-doc-tax
        assign
        tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
        .
    end.
    for each buf_payment no-lock where
      buf_payment.source-type = {&pmnt-fin-doc}
      AND buf_payment.source-ref = string(locked_fin-doc.fin-doc-code)
      :
      create tt0-payment.
      buffer-copy buf_payment except source-ref to tt0-payment
        assign
        tt0-payment.source-ref = string(tt-fin-doc.fin-doc-code)
        .
    end.

    for each buf_fin-doc-attr no-lock where
      buf_fin-doc-attr.host-code = locked_fin-doc.host-code
      AND buf_fin-doc-attr.fin-doc-code = locked_fin-doc.fin-doc-code
      :
      create tt0-fin-doc-attr.
      buffer-copy buf_fin-doc-attr to tt0-fin-doc-attr
        assign
        tt0-fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code
        .
    end.
  end.
  else 
  do:
    for each buf_fin-doc-tax no-lock where
      buf_fin-doc-tax.host-code = tt-fin-doc.host-code
      AND buf_fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
      :
      create tt0-fin-doc-tax.
      buffer-copy buf_fin-doc-tax to tt0-fin-doc-tax.
    end.
    for each buf_payment no-lock where
      buf_payment.source-type = {&pmnt-fin-doc}
      AND buf_payment.source-ref = string(tt-fin-doc.fin-doc-code)
      :
      create tt0-payment.
      buffer-copy buf_payment to tt0-payment.
    end.

    for each buf_fin-doc-attr no-lock where
      buf_fin-doc-attr.host-code = tt-fin-doc.host-code
      AND buf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code
      :
      create tt0-fin-doc-attr.
      buffer-copy buf_fin-doc-attr to tt0-fin-doc-attr.
    end.
    for each tt0-fin-doc-attr no-lock where
      tt0-fin-doc-attr.host-code = tt-fin-doc.host-code
      AND tt0-fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code
      :
    end.

  end.
  { gbl/fautoobj.i tt-fin-doc.host-code tt-fin-doc.fin-doc-code v-is-auto-obj }
  if getCliKassa(tt-fin-doc.{&cli-side}-type, tt-fin-doc.{&cli-side}-code, "Vnecli", tt-fin-doc.cashbookId) then paramVne = "vne" .
  else if getCliKassa(tt-fin-doc.{&cli-side}-type, tt-fin-doc.{&cli-side}-code, "Avanscli", tt-fin-doc.cashbookId) then paramVne = "avans" .
  else paramVne = "" .
  run proc-update-sum-vat-chr in this-procedure (input-output v-start).

END PROCEDURE.


PROCEDURE hide-view-currency :
  define buffer buf_currency for ub.currency.
  /*сначала все похайдим*/
  assign
    v-rubf          = no
    v-exchf         = no
    v-basef         = no
    v-baseratef     = no
    v-contractf     = no
    v-contractratef = no
    .
  hide
    tt-fin-doc.sum-rubl in frame {&frame-name}
    tt-fin-doc.exch-rate
    tt-fin-doc.exch-scale
    tt-fin-doc.sum-base
    tt-fin-doc.base-rate
    tt-fin-doc.base-scale
    tt-fin-doc.sum-contr
    tt-fin-doc.contract-rate
    tt-fin-doc.contract-scale
    in frame {&frame-name} .
  if tt-fin-doc.curr-code <> 0 then 
  do:
    if tt-fin-doc.curr-code:visible then
      display
        tt-fin-doc.exch-rate
        tt-fin-doc.exch-scale
        tt-fin-doc.sum-rubl
        with frame {&frame-name}.
    assign
      v-rubf  = yes
      v-exchf = yes
      .
  end.
  if v-base-code <> tt-fin-doc.curr-code
    and v-base-code <> 0
    then 
  do:
    find first buf_currency no-lock where
      buf_currency.curr-code = v-base-code .
    assign
      tt-fin-doc.sum-base:label = "Б.в.("  + buf_currency.curr-abbr + ")":U
      .
    if tt-fin-doc.curr-code:visible then
      display
        tt-fin-doc.base-rate
        tt-fin-doc.base-scale
        tt-fin-doc.sum-base
        with frame {&frame-name}.
    assign
      v-basef     = yes
      v-baseratef = yes
      .
  end.
  if tt-fin-doc.contract-code  <> 0 and
    (tt-fin-doc.contract-curr <> 0
    and tt-fin-doc.contract-curr <> tt-fin-doc.curr-code
    and tt-fin-doc.contract-curr <> v-base-code
    )
    then 
  do:
    find first buf_currency no-lock where
      buf_currency.curr-code = tt-fin-doc.contract-curr .
    assign
      tt-fin-doc.sum-contr:label = "Вал.дог.("  + buf_currency.curr-abbr + ")":U
      .
    if tt-fin-doc.curr-code:visible then
      display
        tt-fin-doc.sum-contr
        tt-fin-doc.contract-rate
        tt-fin-doc.contract-scale
        with frame {&frame-name}.
    assign
      v-contractf     = yes
      v-contractratef = yes
      .
  end.
  assign
    v-sum-curr-tab-order = v-sum-doc-tab-order
    .
  run disable-enable in this-procedure (v-main-sum, v-main-curr).
END PROCEDURE.

PROCEDURE recalc :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define input parameter p-main-widget as character no-undo.
  define variable v-curr-abbr      like ub.currency.curr-abbr no-undo.
  define variable v-contract-rate  like ub.fin-doc.exch-rate no-undo.
  define variable v-contract-scale like ub.fin-doc.exch-scale no-undo.

&scop get-f-sum-contract     tt-fin-doc.sum-contr = (if tt-fin-doc.contract-curr = 0 ~
                                                      then tt-fin-doc.sum-rubl ~
                                                      else tt-fin-doc.sum-rubl / (tt-fin-doc.contract-rate / tt-fin-doc.contract-scale) ~
                                                    )
  if p-main-widget = "curr-code":u then 
  do:
    assign
      frame {&frame-name}
      tt-fin-doc.sum-doc
      .
    { gbl/baserate.i  tt-fin-doc.host-code tt-fin-doc.doc-date tt-fin-doc.base-rate tt-fin-doc.base-scale }
    { gbl/exchrate.i  tt-fin-doc.curr-code tt-fin-doc.doc-date tt-fin-doc.exch-rate tt-fin-doc.exch-scale v-curr-abbr }
    { gbl/exchrate.i  tt-fin-doc.contract-curr tt-fin-doc.doc-date tt-fin-doc.contract-rate tt-fin-doc.contract-scale v-curr-abbr }

    if tt-fin-doc.curr-code <> 0
      or tt-fin-doc.curr-code <> v-base-code
      or tt-fin-doc.curr-code <> tt-fin-doc.contract-curr
      then 
    do:
      if tt-fin-doc.curr-code <> 0 then
        display
          tt-fin-doc.exch-rate
          tt-fin-doc.exch-scale
          with frame {&frame-name}.
      assign
        p-main-widget = "sum-doc":U.
    end.
  end.
  if p-main-widget  = "doc-date":U then 
  do:
    assign
      frame {&frame-name}
      tt-fin-doc.sum-doc
      .
  { gbl/baserate.i  tt-fin-doc.host-code tt-fin-doc.doc-date tt-fin-doc.base-rate tt-fin-doc.base-scale }
  { gbl/exchrate.i  tt-fin-doc.curr-code tt-fin-doc.doc-date tt-fin-doc.exch-rate tt-fin-doc.exch-scale v-curr-abbr }
  { gbl/exchrate.i  tt-fin-doc.contract-curr tt-fin-doc.doc-date tt-fin-doc.contract-rate tt-fin-doc.contract-scale v-curr-abbr }
    if tt-fin-doc.base-rate:visible in frame {&frame-name} then 
    do:
      display
        tt-fin-doc.base-rate
        tt-fin-doc.base-scale
        with frame {&frame-name}.
      assign
        p-main-widget = "sum-doc":U.
    end.
    if tt-fin-doc.exch-rate:visible in frame {&frame-name} then 
    do:
      display
        tt-fin-doc.exch-rate
        tt-fin-doc.exch-scale
        with frame {&frame-name}.
      assign
        p-main-widget = "sum-doc":U.
    end.
    if tt-fin-doc.contract-rate:visible in frame {&frame-name} then 
    do:
      display
        tt-fin-doc.contract-rate
        tt-fin-doc.contract-scale
        with frame {&frame-name}.
      assign
        p-main-widget = "sum-doc":U.
    end.
  end.


  CASE p-main-widget:
    when "sum-doc" then 
      do:
        assign
          frame {&frame-name}
          tt-fin-doc.exch-rate
          tt-fin-doc.exch-scale
          tt-fin-doc.sum-doc
          .
        CASE tt-fin-doc.curr-code:
          when 0 then 
            do:
              assign
                tt-fin-doc.sum-rubl = tt-fin-doc.sum-doc
                tt-fin-doc.sum-base = tt-fin-doc.sum-doc / tt-fin-doc.base-rate * tt-fin-doc.base-scale
                {&get-f-sum-contract}
                .
            end. /*when tt-fin-doc.curr-code = 0*/
          when v-base-code then 
            do:
              assign
                tt-fin-doc.sum-rubl = tt-fin-doc.sum-doc * tt-fin-doc.exch-rate / tt-fin-doc.exch-scale
                tt-fin-doc.sum-base = tt-fin-doc.sum-rubl / tt-fin-doc.base-rate * tt-fin-doc.base-scale
                {&get-f-sum-contract}
                .
            end. /*when base-code*/
          otherwise 
          do: /*ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
            assign
              tt-fin-doc.sum-rubl = tt-fin-doc.sum-doc * tt-fin-doc.exch-rate / tt-fin-doc.exch-scale
              tt-fin-doc.sum-base = tt-fin-doc.sum-rubl / tt-fin-doc.base-rate * tt-fin-doc.base-scale
              {&get-f-sum-contract}
              .
          end. /*when ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
        END CASE.
      end. /*sum-doc*/
  END CASE.
  assign
    f-rest-con-sum = tt-fin-doc.sum-contr - tt-fin-doc.con-sum-contr
    .

  display
    f-rest-con-sum
    with frame {&frame-name}.
  if tt-fin-doc.sum-doc:visible in frame {&frame-name} then
    display
      tt-fin-doc.sum-doc
      tt-fin-doc.curr-code
      with frame {&frame-name}.
  if tt-fin-doc.sum-rubl:visible in frame {&frame-name} then
    display
      tt-fin-doc.sum-rubl
      tt-fin-doc.exch-rate
      tt-fin-doc.exch-scale
      with frame {&frame-name}.
  if tt-fin-doc.sum-base:visible in frame {&frame-name} then
    display
      tt-fin-doc.sum-base
      tt-fin-doc.base-rate
      tt-fin-doc.base-scale
      with frame {&frame-name}.

  if tt-fin-doc.sum-contr:visible in frame {&frame-name} then
    display
      tt-fin-doc.sum-contr
      tt-fin-doc.contract-rate
      tt-fin-doc.contract-scale
      with frame {&frame-name}.
  if not v-first-start then
    run proc-update-sum-vat-chr in this-procedure (input-output v-start).

END PROCEDURE.

procedure proc-create-default-tax :
  do
    on error undo, return error
    :
    If p-mode = {&add-def} then 
    do:
      if p-ob-doc-code = "" then 
      do:
        find tt0-fin-doc-tax where
          tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
          AND tt0-fin-doc-tax.host-code = tt-fin-doc.host-code no-error .
        if not avail tt0-fin-doc-tax
          and not AMBIGUOUS tt0-fin-doc-tax
          then 
        do:
          create tt0-fin-doc-tax.
        end.
        if AMBIGUOUS tt0-fin-doc-tax then return.
        
        assign
          tt0-fin-doc-tax.fin-doc-code     = tt-fin-doc.fin-doc-code
          tt0-fin-doc-tax.host-code        = tt-fin-doc.host-code
          tt0-fin-doc-tax.line-num         = 1
          tt0-fin-doc-tax.slt-pc           = 0
          tt0-fin-doc-tax.sum-line-doc     = tt-fin-doc.sum-doc
          tt0-fin-doc-tax.sum-slt-line-doc = 0
          tt0-fin-doc-tax.with-slt         = no
          .
        case paramVne:
          when "vne" then do:
          assign
            tt0-fin-doc-tax.sum-vat-line-doc = 0
            tt0-fin-doc-tax.vat-pc           = -1
            tt0-fin-doc-tax.with-vat         = no
            .
          end.
          when "avans" then do:
          assign
            tt0-fin-doc-tax.vat-pc           = 22
            tt0-fin-doc-tax.sum-vat-line-doc = (tt-fin-doc.sum-doc * tt0-fin-doc-tax.vat-pc)/(100 + tt0-fin-doc-tax.vat-pc)
            tt0-fin-doc-tax.with-vat         = yes
            .
          end.
          otherwise do:
          assign
            tt0-fin-doc-tax.sum-vat-line-doc = 0
            tt0-fin-doc-tax.vat-pc           = 0
            tt0-fin-doc-tax.with-vat         = no
            .
          end.
        end case .          

        release tt0-fin-doc-tax.
      end.
    end.
  end. /*doe*/
end procedure. /* proc-create-default-tax */



procedure proc-update-sum-vat-chr :
  define input-output parameter p-start as integer no-undo .
  define variable v-sum-vat      like ub.fin-doc-tax.sum-vat-line-doc no-undo .
  define variable v-sum-vat-chr  as character no-undo .
  define variable v-each-vat-chr as character no-undo. /* Сюда размещаем информацию о каждом налоге: его процент и значение (не сумму всех налогов, как было до этой задачи!!!) Арн. #3076. 2014г */
  define variable v-vat-pc       as integer no-undo .
&if "{&doc-type}" = "income-cash" or  "{&doc-type}" = "expense-cashless" &then


  do
    on error undo, return error
    :
    for each tt0-fin-doc-tax no-lock where
      tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
      AND tt0-fin-doc-tax.host-code = tt-fin-doc.host-code:
      /*      assign*/
      do:
        if tt0-fin-doc-tax.with-vat then 
        do: /* Если tt0-fin-doc-tax.with-vat - существует, то: */
          v-vat-pc = tt0-fin-doc-tax.vat-pc .
          if paramVne <> "avans" then 
          do:
            v-each-vat-chr = v-each-vat-chr +
              substitute (" &1% = &2;"
              , string(tt0-fin-doc-tax.vat-pc)             /* Берём процент одного налога (из возможных нескольких, по порядку). */
              , string(truncate(tt0-fin-doc-tax.sum-vat-line-doc, 0)) + {&space-char} +  "{&abbr_rub}." + {&space-char} +     /* Берём сумму одного налога (из возможных нескольких, по порядку и вставляем обвязку: руб, коп.*/
              (if tt0-fin-doc-tax.sum-vat-line-doc <> truncate(tt0-fin-doc-tax.sum-vat-line-doc, 0)
              then (string(100 * round(tt0-fin-doc-tax.sum-vat-line-doc - truncate(tt0-fin-doc-tax.sum-vat-line-doc, 0), 2))  + {&space-char} + "{&abbr_kop}.")
              else "":U)).
          end.
          else 
          do:
            v-each-vat-chr = v-each-vat-chr +
              substitute (" = &1;"
              , string(truncate(tt0-fin-doc-tax.sum-vat-line-doc, 0)) + {&space-char} +  "{&abbr_rub}." + {&space-char} +     /* Берём сумму одного налога (из возможных нескольких, по порядку и вставляем обвязку: руб, коп.*/
              (if tt0-fin-doc-tax.sum-vat-line-doc <> truncate(tt0-fin-doc-tax.sum-vat-line-doc, 0)
              then (string(100 * round(tt0-fin-doc-tax.sum-vat-line-doc - truncate(tt0-fin-doc-tax.sum-vat-line-doc, 0), 2))  + {&space-char} + "{&abbr_kop}.")
              else "":U)).
          end.
        end.    
           
        v-sum-vat = v-sum-vat +
          (if tt0-fin-doc-tax.with-vat then tt0-fin-doc-tax.sum-vat-line-doc else 0).
      /*      .*/
      end.
    end. /* for each tt0-fin-doc-tax no-lock where */

    if tt-fin-doc.curr-code = 0 then 
    do:
      case paramVne :
      when "vne" then do:
      if v-vat-pc > 0 then do:
        v-sum-vat-chr = "в том числе НДС" + right-trim (v-each-vat-chr , ";").
      end .  
      else     
      assign
        v-sum-vat-chr = "в т.ч. без налога (НДС)" 
        .        
      end.
      when "avans" then do:
        if v-vat-pc <> 0 then v-sum-vat-chr = "в т.ч. " + string(v-vat-pc) + "/" + string(100 + v-vat-pc) + " (НДС)" + right-trim (v-each-vat-chr , ";").
        else v-sum-vat-chr = "в т.ч. 22/122 (НДС)" + right-trim (v-each-vat-chr , ";").
      end.
      otherwise do:  
        v-sum-vat-chr = "в том числе НДС" + right-trim (v-each-vat-chr , ";").
      end.
    end case .      
    end. /* if tt-fin-doc.curr-code = 0 then do: */
    else 
    do:
      assign
        v-sum-vat-chr = "в том числе НДС" + {&space-char} +
                      string(v-sum-vat)
        .
    end. /* else do: */
    &if "{&doc-type}" = "income-cash" &then
    if p-start = 0 then
      assign
        frame {&frame-name}
        tt-fin-doc.including
        .
    if p-start = 1 then p-start = 0.
    if num-entries(tt-fin-doc.including, "@":U) < 2 and p-start = 2 then 
    do:
      assign
        tt-fin-doc.including = tt-fin-doc.including + "@" +
                                  (if tt-fin-doc.including = "":U
                                  then "":U
                                  else ({&comma-char} + {&space-char} )
                                  ) +
                                  v-sum-vat-chr.
    end. /* if num-entries(tt-fin-doc.including, "@":U) < 2 and p-start = 2 then do: */
    if num-entries(tt-fin-doc.including, "@":U) > 1 then 
    do:
      assign
        entry(2, tt-fin-doc.including, "@":U) = {&comma-char} + {&space-char}  + v-sum-vat-chr.
    end. /* if num-entries(tt-fin-doc.including, "@":U) > 1 then do: */
    display
      tt-fin-doc.including
      with frame {&frame-name} .
    &endif
    &if "{&doc-type}" = "expense-cashless" &then
    if p-start  = 0 then
      assign
        frame {&frame-name}
        tt-fin-doc.naznach-plat
        .
    if p-start = 1 then p-start = 0.
    if num-entries(tt-fin-doc.naznach-plat, "@":U) < 2 and p-start = 2 then 
    do:
      assign
        tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" +
                                  (if tt-fin-doc.naznach-plat = "":U
                                  then "":U
                                  else ({&comma-char} + {&space-char} )
                                  ) +
                                  v-sum-vat-chr.
    end. /*  if num-entries(tt-fin-doc.naznach-plat, "@":U) < 2 and p-start = 2 then do: */
    if num-entries(tt-fin-doc.naznach-plat, "@":U) > 1 then 
    do:
      assign
        entry(2, tt-fin-doc.naznach-plat, "@":U) = {&comma-char} + {&space-char}  + v-sum-vat-chr.
    end. /* if num-entries(tt-fin-doc.naznach-plat, "@":U) > 1 then do: */
    display
      tt-fin-doc.naznach-plat
      with frame {&frame-name} .
    &endif

    if p-start = 2 then p-start = 0.
  end. /* do on error undo, return error: */
&endif
end procedure. /* proc-update-sum-vat-chr */

/* конец части &if "{&action}" = "triggers" &then*/

&endif

/* $Workfile: findocip.i $ e n d */