using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
block-level on error undo, throw.
class ibs.th.utl.method-for-draw-utility final:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
  define public variable Obj-type    as character no-undo.
  define public variable Obj-code    as integer   no-undo.
  define public variable v-host-code as integer   no-undo .
  define public variable mDebug      as logical   no-undo.
  define property parparentproc as handle no-undo
    get.
    set(input iH as handle):
      parparentproc = iH.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run hostcode in ibs.th.gbl.gbl-hndllib:g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
      Obj-code = v-cntxt-obj-code.
      Obj-type = v-cntxt-obj-type.
    end.
  define public variable mAddr as character no-undo.
  //define public variable mlogHand      as handle no-undo.
define variable varmes-log as logical no-undo.
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varbuttons  as   character        no-undo.
define variable varps-upd   as   logical          no-undo.
method private void nozzleav(
parobj-type    like ub.clients.obj-type,
parobj-code    like ub.clients.obj-code,
parnozzle-code like ub.nozzle.nozzle-code
):
define buffer bf_clients for ub.clients.
define buffer bf_nozzle  for ub.nozzle.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if available bf_nozzle then
             return error SUBSTITUTE("Уже есть пистолет с номером &1", parnozzle-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
create bf_nozzle.
assign bf_nozzle.obj-type    = parobj-type
       bf_nozzle.obj-code    = parobj-code
       bf_nozzle.nozzle-code = parnozzle-code.
end. // procedure/method
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method private logical nzpl-spl
(input p-obj-type as character
                                , input p-obj-code as integer):
define variable v-dopi    as integer no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-tth as handle no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type4 as character no-undo .
define variable v-value-date4 as date no-undo .
define variable v-value-decimal4 as decimal no-undo .
define variable v-value-integer4 as INTEGER no-undo .
define variable v-value-logical4 AS LOGICAL no-undo .
define variable v-tth4 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date4
    ,output v-value-decimal4
    ,output v-value-integer4
    ,output v-value-logical4
    ,output v-param-type4
    ,INPUT-OUTPUT table-handle v-tth4
    ) no-error .
delete object v-tth4 no-error.
if dflt-cd <> 'IBM':U
and dflt-cd <> 'IBM-XML':U then return no.
if dflt-cd = 'IBM-XML':U then return yes.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-type-ibm':U
    ,input  'ibmspool':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then do:
  delete object v-tth.
  return no.
end.
delete object v-tth.
assign
v-dopi = v-value-integer no-error .
if v-dopi >= 6 then return yes.
end. // FUNCTION/method
method private logical nzpl-two
                                 (input p-obj-type as character
                                  , input p-obj-code as integer):
  define variable v-nzpl-two as logical no-undo.
  nzpl-two-proc (input p-obj-type, input p-obj-code, output v-nzpl-two).
  return v-nzpl-two.
end. // FUNCTION/method
method private void nzpl-two-proc
( input p-obj-type   as character,
  input p-obj-code   as integer ,
  output varge-two-pl as logical
):
define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.
//do on error undo, return error return-value :
assign
  varge-two-pl = no.
for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type = p-obj-type        and
                              bf_pl-gds-pump.obj-code = p-obj-code        and
                              bf_pl-gds-pump.status_  = 'тек':U no-lock on error undo, return error return-value :
  find first bf-other_pl-gds-pump where bf-other_pl-gds-pump.obj-type  =  bf_pl-gds-pump.obj-type  and
                                        bf-other_pl-gds-pump.obj-code  =  bf_pl-gds-pump.obj-code  and
                                        bf-other_pl-gds-pump.pump-code =  bf_pl-gds-pump.pump-code and
                                        bf-other_pl-gds-pump.gds-code  =  bf_pl-gds-pump.gds-code  and
                                        bf-other_pl-gds-pump.status_   =  'тек':U        and
                                        bf-other_pl-gds-pump.pl-code   <> bf_pl-gds-pump.pl-code   no-lock no-error.
  if available bf-other_pl-gds-pump then do:
    assign
      varge-two-pl = yes.
    leave.
  end.
end.
//end.
end. // procedure/method .
method private void cplgdspm
( parobj-type  like ub.pl-gds-pump.obj-type ,
  parobj-code  like ub.pl-gds-pump.obj-code ,
  parpl-code   like ub.pl-gds-pump.pl-code  ,
  pargds-code  like ub.pl-gds-pump.gds-code ,
  parpump-code like ub.pl-gds-pump.pump-code,
  parstatus    like ub.pl-gds-pump.status_  ):
    define buffer bf_pl-gds-pump          for ub.pl-gds-pump.
    define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
    define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer bf-place                for ub.place.
    if parstatus = 'тек':U then do:
      for each bf_pl-gds-pump no-lock
        where bf_pl-gds-pump.obj-type  =  parobj-type
          and bf_pl-gds-pump.obj-code  =  parobj-code
          and bf_pl-gds-pump.gds-code  =  pargds-code
          and bf_pl-gds-pump.pump-code =  parpump-code
          and bf_pl-gds-pump.pl-code   <> parpl-code
          and bf_pl-gds-pump.status_   =  'тек':U
      on error undo, return error
      :
        find first place where
                   place.obj-type = parobj-type
               and place.obj-code = parobj-code
               and place.pl-code  = parpl-code
             no-lock no-error.
        find first bf-place where
                   bf-place.obj-type = parobj-type
               and bf-place.obj-code = parobj-code
               and bf-place.pl-code = bf_pl-gds-pump.pl-code
             no-lock no-error.
        if nzpl-spl(parobj-type, parobj-code) <> yes then do:
          return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                     ,parobj-type
                                     ,parobj-code
                                     ,if available place then place.loc1 else string(parpl-code)
                                     ,pargds-code
                                     ,parpump-code
                                     ,parstatus
                                     ,chr(10)
                                    )
                      + substitute( "КАССА не возвращает номер пистолета в чеке, а на объекте уже есть резервуар &1 с тем же товаром и связан он с этой же ТРК."
                                    ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                  ).
        end.
        else do:
          find first bf_pl-pump-nozzle no-lock
            where bf_pl-pump-nozzle.obj-type  = parobj-type
              and bf_pl-pump-nozzle.obj-code  = parobj-code
              and bf_pl-pump-nozzle.pump-code = parpump-code
              and bf_pl-pump-nozzle.pl-code   = parpl-code
            no-error.
          if available bf_pl-pump-nozzle then do:
            find first bf-other_pl-pump-nozzle no-lock
              where bf-other_pl-pump-nozzle.obj-type  = bf_pl-gds-pump.obj-type
                and bf-other_pl-pump-nozzle.obj-code  = bf_pl-gds-pump.obj-code
                and bf-other_pl-pump-nozzle.pump-code = bf_pl-gds-pump.pump-code
                and bf-other_pl-pump-nozzle.pl-code   = bf_pl-gds-pump.pl-code
              no-error.
            if available bf-other_pl-pump-nozzle
              and bf-other_pl-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
            then do:
              return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                       ,parobj-type
                                       ,parobj-code
                                       ,if available place then place.loc1 else string(parpl-code)
                                       ,pargds-code
                                       ,parpump-code
                                       ,parstatus
                                       ,chr(10)
                                     )
                          + substitute( "На объекте &1 &2 уже есть запись резервуар &3 в статусе &4, в котором находится этот же товар и он связан с этой же ТРК через этот же пистолет."
                                        ,bf_pl-gds-pump.obj-type
                                        ,bf_pl-gds-pump.obj-code
                                        ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                        ,bf_pl-gds-pump.status_
                                      ).
            end.
          end.
        end.
      end.
    end.
end . // procedure/method
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
            define variable g#language as character no-undo init "rus".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method private void doc-code (
                              parmode          as   character,
                              parobj-type      like ub.clients.obj-type,
                              parobj-code      like ub.clients.obj-code,
                              parroot-doc-code like ub.trn-doc.doc-code,
                   output     pardoc-code      like ub.trn-doc.doc-code
):
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
method private int64 get-doc-code-int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
                define temp-table tt-gds-prod
                  field gds-code   as integer
                  field b-str      as character
                  field bc-on-type as character
                  index pi as primary unique gds-code b-str
                  .
                define temp-table tt-rest-fin
                  field obj-code   as integer
                  field obj-type   as character
                  field CashBookId like ub.CashBook.id
                  field ostatok    as decimal
                  index pi is primary obj-code obj-type CashBookId
                  .
                define temp-table tt-version
                  field version-name as character
                  .
                define temp-table tt-place like ub.place .
                define temp-table tt-place-attr like ub.place-attr .
                define temp-table tt-pump like ub.pump .
                define temp-table tt-nozzle like ub.nozzle .
                define temp-table tt-pl-pump like ub.pl-pump .
                define temp-table tt-pump-nozzle like ub.pump-nozzle .
                define temp-table tt-pl-pump-nozzle like ub.pl-pump-nozzle .
                define temp-table tt-pl-level like ub.pl-level .
                define temp-table tt-pl-gds like ub.pl-gds .
                define temp-table tt-pl-gds-pump like ub.pl-gds-pump .
                define temp-table tt-cash-desk like ub.cash-desk
                  field isSave as logical.
                define temp-table tt-cash-desk-attr like ub.cash-desk-attr
                  field attr-value as character
                  .
                define temp-table temp-fin-sum no-undo
                  field cash-desk        as integer
                  field curr-code        as integer
                  field tot-sum          as decimal
                  field tot-base         as decimal
                  field tot-rubl         as decimal
                  field is-petrol        as logical
                  field cashbookid       as int64
                  field is-expense_cash  as logical
                  field num-expense_cash as int
                  index pi is unique primary
                  num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid
                  .
                define temp-table temp-tax no-undo
                  field with-vat         as logical init yes
                  field curr-code        as integer
                  field vat-pc           as decimal
                  field slt-pc           as decimal
                  field vat-base         as decimal
                  field vat-rubl         as decimal
                  field vat-doc          as decimal
                  field sum-base         as decimal
                  field sum-rubl         as decimal
                  field sum-doc          as decimal
                  field cash-desk        as integer
                  field is-petrol        as logical
                  field cashbookId       as int64
                  field is-expense_cash  as logical
                  field num-expense_cash as int
                  index pi is unique primary
                  num-expense_cash
                  is-expense_cash
                  cash-desk
                  curr-code
                  vat-pc
                  slt-pc
                  is-petrol
                  cashbookId
                  .
                define temp-table tt0-fin-doc-tax like ub.fin-doc-tax .
                define temp-table tt0-fin-doc-attr like ub.fin-doc-attr .
                define temp-table tt-fin-doc like ub.fin-doc .
                DEFINE TEMP-TABLE ttc-fin-doc NO-UNDO LIKE ub.fin-doc.
                DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.
                define temp-table tt-user-account like ub.user-account .
                define temp-table tt-user-login like ub.user-login .
                define temp-table tt-user-obj like ub.user-obj .
                define temp-table tt-user-host like ub.user-host .
                define temp-table tt-user-menu-group like ub.user-menu-group .
                define temp-table tt-schedule like ub.schedule .
                define temp-table tt-schedule-attr like ub.schedule-attr .
                define temp-table tt-fbr-gds-obj like ub.fbr-gds-obj .
                define temp-table tt-fbr-gds-obj-attr like ub.fbr-gds-obj-attr .
                define variable v-cash-num    as integer   no-undo .
                define variable v-string-cash as character no-undo .
                define variable v-RfNumber    as integer   no-undo .
                define variable v-cash-rf     as integer   no-undo .
                define variable v-send-Rf     as logical   no-undo .
                define temp-table tt-rvs-doc like ub.rvs-doc
                  field Findex as logical
                  index pi FINdex.
                define temp-table tt-rvs-doc-attr like ub.rvs-doc-attr
                  field Findex as logical
                  index pi FINdex.
                define temp-table tt-rvs-line-attr like ub.rvs-line-attr
                  field Findex as logical
                  index pi FINdex.
                define temp-table tt-rvs-line like ub.rvs-line
                  field loc1   as character
                  field Findex as logical
                  index pi FINdex.
                define temp-table tt-rvs-pump like ub.rvs-pump
                  field Findex as logical
                  index pi FINdex.
                define temp-table tt-rvs-pump-attr like ub.rvs-pump-attr
                  field Findex as logical
                  index pi FINdex.
                define temp-table tt-rvs-line-pump-attr like ub.rvs-line-pump-attr
                  field loc1   as character
                  field Findex as logical
                  index pi FINdex.
                define temp-table tt-rvs-line-pump like rvs-line-pump
                  field loc1   as character
                  field Findex as logical
                  index pi FINdex.
                define temp-table tt-cash-passwd
                  field staff-code as integer   // like staff.staff-code
                  field password   as character // like staff.password
                  .
                define temp-table tt-gds-mapping
                  field gds-code15 as integer
                  field gds-code16 as integer
                  index pi as primary
                  gds-code15
                  .
                define temp-table tt-gds-price
                  field gds-code as integer
                  field price    as decimal
                  index pi as primary unique
                  gds-code
                  .
                define temp-table tt-place-loc
                  field pl-code as integer
                  field loc1    as character
                  index pi as primary unique
                  pl-code
                  .
                define temp-table tt-icnt-doc like ub.icnt-doc .
                define temp-table tt-icnt-line like ub.icnt-line .
define temp-table tt-imp-parts no-undo // скопировано из utl/imp-doc4.p
   field artic         as character
           field f02           as character
   field part-code     as character
   field in-code       like ub.parts.in-code
   field gds-code      as int64
   field price-rubl    like ub.parts.price-rubl
   field fact-qnty     like ub.parts.fact-qnty
           field f08           as character
           field f09           as character
           field f10           as character
   field vat-tax-value as decimal
           field f12           as character
           field f13           as character
   field name-gtd      as character
           field f15           as character
           field f16           as character
   field srok-god      as character
           field f18           as character
           field f19           as character
   field supp-code     as integer
   field supp-type     as character
   field cont-prn-code like ub.contract.contract-prn-code
           field imp-row       as character // исходая строка из файла импорта
.
                define temp-table tt-imp-parts-ptrl no-undo // скопировано из utl/imp-doc4.p
   field artic         as character
           field f02           as character
   field part-code     as character
   field in-code       like ub.parts.in-code
   field gds-code      as integer
   field price-rubl    like ub.parts.price-rubl
   field fact-qnty     like ub.parts.fact-qnty
           field f08           as character
           field f09           as character
           field f10           as character
   field vat-tax-value as decimal
           field f12           as character
           field f13           as character
   field name-gtd      as character
           field f15           as character
           field f16           as character
   field srok-god      as character
           field f18           as character
           field f19           as character
   field supp-code     as integer
   field supp-type     as character
   field cont-prn-code like ub.contract.contract-prn-code
   field pl-loc1       as character
   field cli-qnty      as decimal
           field imp-row       as character // исходая строка из файла импорта
.
                define temp-table tt-stk-gd no-undo
                  field gds-name      as character
                  field gds-code      as integer
                  field fact-qnty     as decimal
                  field sum-rubl-cost as decimal
                  field vat-rubl      as decimal
                  field sum-rubl-crsa as decimal
                  .
                define temp-table tt-stk-gd2 no-undo
                  field gds-name        as character
                  field gds-code15      as character
                  field fact-qnty       as decimal
                  field sum-rubl-cost   as decimal
                  field vat-rubl        as decimal
                  field sum-rubl-crsa   as decimal
                  field gds-code16      as integer
                  field fact-qnty16     as decimal
                  field sum-rubl-cost16 as decimal
                  field vat-rubl16      as decimal
                  field sum-rubl-crsa16 as decimal
                  index pi is primary gds-code16
                  .
                define temp-table tt-stk-fu no-undo
                  field gds-name     as character
                  field gds-code     as integer
                  field fact-qnty-lt as decimal
                  field fact-qnty-kg as decimal
                  .
                define temp-table tt-stk-fu2 no-undo like tt-stk-fu
                  field gds-code16     as integer
                  field fact-qnty-lt16 as decimal
                  field fact-qnty-kg16 as decimal
                  index pi is primary gds-code16
                  .
                DEFINE TEMP-TABLE tt-rp-by-call NO-UNDO LIKE ub.rp-by-call.
                DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.
                DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
                DEFINE TEMP-TABLE tt0-rp-by-call NO-UNDO LIKE ub.rp-by-call.
                DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
                DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
                DEFINE TEMP-TABLE tt2-rule-call-param NO-UNDO LIKE ub.rule-call-param.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-price-doc no-undo
field line-num as integer
field doc-date as date
field doc-num  as integer
field doc-num-ES as character
field doc-id   as character
field obj-type as character
field obj-code as integer
field cmnt     as character
index pi line-num doc-num
index pi2 doc-num
index pi3 doc-id
.
define temp-table temp-price-list no-undo
field line-num     as integer
field doc-num      as integer
field bar-code     as integer
field gds-code     as integer
field price-sale   as decimal
index pi  doc-num  line-num  bar-code
index pi2 bar-code
.
                define public property version-name as character
                  get:
                    return if available tt-version then tt-version.version-name else "15.X".
                  end.
                define variable mJsonObj      as JsonObject        no-undo.
                define variable mParser       as ObjectModelParser no-undo.
                define variable results-array as JsonArray         no-undo.
                define variable myResultObj   as JsonObject        no-undo.
                define variable mplacelib     as class             ibs.th.str.placelib no-undo.
                define stream lsIN.
                define stream lsOUT.
                constructor public method-for-draw-utility (  ):
                  super ().
                  mplacelib = new ibs.th.str.placelib().
                  mParser = new ObjectModelParser().
                  mDebug = session:debug-alert.
                end constructor.
                destructor public method-for-draw-utility ( ):
                  delete object mJsonObj no-error.
                  delete object mParser  no-error.
                  delete object mplacelib.
                end destructor.
                define public event write-log
                  signature void ( input pcCustName as character ).
                method public void put-log (iText as character ):
                  put-log-all(Itext).
                  publish "write-log" from parparentproc (Itext ).
                  write-log:PUBLISH (iText).
                end method.
                method public void put-err-log (iText as character ):
                  publish "write-log-err" from parparentproc (Itext ).
                  put-log-all(Itext).
                end method.
                method public void put-log-all(itext as char):
                  output to value(substitute("&1darw_util_&2.log", ibs.th.gbl.gbl-inipar:logDir,v-cntxt-obj-code)) append.
                  if itext = ""
                    then
                    put unformatted skip(1) .
                  else
                    put unformatted itext skip .
                  output close.
                end.
                method public void put-log-allerr(itext as char):
                  output to value(substitute("&1darw_util_&2.err", ibs.th.gbl.gbl-inipar:logDir,v-cntxt-obj-code)) append.
                  if itext = ""
                    then
                    put unformatted skip(1) .
                  else
                    put unformatted itext skip .
                  output close.
                end.
                method private void pumpav(
                  parobj-type  like ub.clients.obj-type,
                  parobj-code  like ub.clients.obj-code,
                  parpump-code like ub.pump.pump-code
                  ):
                  define buffer bf_clients for ub.clients.
                  define buffer bf_pump    for ub.pump.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
                  find first bf_pump no-lock
                    where bf_pump.obj-type  = parobj-type
                    and bf_pump.obj-code  = parobj-code
                    and bf_pump.pump-code = parpump-code
                    no-error.
                  if available bf_pump then
                  do:
                    put-log(substitute("Уже есть ТРК с номером &1", parpump-code) +  "").
                    return error substitute("Уже есть ТРК с номером &1", parpump-code) .
                  end.
                  create bf_pump.
                  assign
                    bf_pump.obj-type  = parobj-type
                    bf_pump.obj-code  = parobj-code
                    bf_pump.pump-code = parpump-code
                    .
                end method.
                method private void pumpnzav(
                  parobj-type    like ub.clients.obj-type,
                  parobj-code    like ub.clients.obj-code,
                  parpump-code   like ub.pump.pump-code,
                  parnozzle-code like ub.nozzle.nozzle-code,
                  paris-meas     like ub.pump-nozzle.is-meas,
                  paref-nid      like ub.pump-nozzle.ef-nid
                  ):
                  define buffer bf_clients     for ub.clients.
                  define buffer bf_pump        for ub.pump.
                  define buffer bf_nozzle      for ub.nozzle.
                  define buffer bf_pump-nozzle for ub.pump-nozzle.
                  define buffer bf_rvs-doc     for ub.rvs-doc.
                  define buffer bf_icnt-doc    for ub.icnt-doc.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
find first bf_pump where bf_pump.obj-type  = parobj-type  and
                         bf_pump.obj-code  = parobj-code  and
                         bf_pump.pump-code = parpump-code no-lock no-error.
if not available bf_pump then
   return error SUBSTITUTE("Нет ТРК с номером &1", parpump-code) .
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_nozzle then
   return error SUBSTITUTE("Нет пистолета ТРК с номером &1", parnozzle-code) .
 find first bf_rvs-doc where bf_rvs-doc.obj-type =  parobj-type       and
                             bf_rvs-doc.obj-code =  parobj-code       and
                             bf_rvs-doc.status_  <> 'факт':U           and
                             bf_rvs-doc.rvs-type <> 'перед_док':U and
                             bf_rvs-doc.rvs-type <> 'после_док':U  and
                             bf_rvs-doc.rvs-type <> 'проверка':U       no-lock no-error.
if available bf_rvs-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ сверки &1 .", bf_rvs-doc.rvs-code).
end.
find first bf_icnt-doc where bf_icnt-doc.obj-type  =  parobj-type and
                             bf_icnt-doc.obj-code  =  parobj-code and
                             bf_icnt-doc.status_   <> 'факт':U     no-lock no-error.
if available bf_icnt-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ инвентаризации счетчиков ТРК &1 .", bf_icnt-doc.doc-code).
end.
                  find first bf_pump-nozzle where bf_pump-nozzle.obj-type    = parobj-type    and
                    bf_pump-nozzle.obj-code    = parobj-code    and
                    bf_pump-nozzle.pump-code   = parpump-code   and
                    bf_pump-nozzle.nozzle-code = parnozzle-code no-lock no-error.
                  if available bf_pump-nozzle then
                  do:
                    put-log(substitute ("Уже есть запись ТРК-пистолет с номером ТРК &1 и номером пистолета &2", parpump-code, parnozzle-code) + " " + "").
                    return error substitute ("Уже есть запись ТРК-пистолет с номером ТРК &1 и номером пистолета &2", parpump-code, parnozzle-code) .
                  end.
                  create bf_pump-nozzle.
                  assign
                    bf_pump-nozzle.obj-type    = parobj-type
                    bf_pump-nozzle.obj-code    = parobj-code
                    bf_pump-nozzle.pump-code   = parpump-code
                    bf_pump-nozzle.nozzle-code = parnozzle-code
                    bf_pump-nozzle.is-meas     = paris-meas
                    bf_pump-nozzle.ef-nid      = paref-nid
                    .
                end method.
                method private void plpumpav(
                  parobj-type  like ub.clients.obj-type,
                  parobj-code  like ub.clients.obj-code,
                  parpl-code   like ub.place.pl-code,
                  parpump-code like ub.pump.pump-code
                  ):
                  define buffer bf_clients           for ub.clients.
                  define buffer bf_pump              for ub.pump.
                  define buffer bf_place             for ub.place.
                  define buffer bf_pl-pump           for ub.pl-pump.
                  define buffer bf_pl-gds            for ub.pl-gds.
                  define buffer bf_goods             for ub.goods.
                  define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
                  define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.
                  define variable varstatus as character no-undo.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
find first bf_pump where bf_pump.obj-type  = parobj-type  and
                         bf_pump.obj-code  = parobj-code  and
                         bf_pump.pump-code = parpump-code no-lock no-error.
if not available bf_pump then
   return error SUBSTITUTE("Нет ТРК с номером &1", parpump-code) .
find first bf_place where bf_place.obj-type = parobj-type and
                          bf_place.obj-code = parobj-code and
                          bf_place.pl-code  = parpl-code  no-lock no-error.
if not available bf_place then return error SUBSTITUTE("Нет такого складского места &1", parpl-code) .
                  find first bf_pl-pump no-lock
                    where bf_pl-pump.obj-type   = parobj-type
                    and bf_pl-pump.obj-code   = parobj-code
                    and bf_pl-pump.pl-code    = parpl-code
                    and bf_pl-pump.pump-code  = parpump-code
                    no-error.
                  if available bf_pl-pump then
                  do:
                    put-log(substitute("Уже есть запись резервуар-ТРК с номером резервуара &1 и номером ТРК &2", parpl-code, parpump-code) + " " + "").
                    return error substitute("Уже есть запись резервуар-ТРК с номером резервуара &1 и номером ТРК &2", parpl-code, parpump-code) .
                  end.
                  find first bf_pl-gds no-lock
                    where bf_pl-gds.obj-type = parobj-type
                    and bf_pl-gds.obj-code = parobj-code
                    and bf_pl-gds.pl-code  = parpl-code
                    no-error.
                  tr:
                  do transaction
                    on error undo tr, return error return-value
                    :
                    if available bf_pl-gds then
                    do:
                      find first bf_goods no-lock
                        where bf_goods.gds-code = bf_pl-gds.gds-code
                        .
                      assign
                        varstatus = 'тек':U
                        .
                      find first bf-other_pl-gds-pump no-lock
                        where bf-other_pl-gds-pump.obj-type  = parobj-type
                        and bf-other_pl-gds-pump.obj-code  = parobj-code
                        and bf-other_pl-gds-pump.gds-code  = bf_goods.gds-code
                        and bf-other_pl-gds-pump.pump-code = parpump-code
                        and bf-other_pl-gds-pump.status_   = 'тек':U
                        no-error.
                      if available bf-other_pl-gds-pump
                        and nzpl-spl(bf-other_pl-gds-pump.obj-type, bf-other_pl-gds-pump.obj-code) <> yes
                        then
                      do:
                        assign
                          varstatus = 'блок':U
                          .
                      end.
                      create bf_pl-gds-pump.
                      assign
                        bf_pl-gds-pump.obj-type  = parobj-type
                        bf_pl-gds-pump.obj-code  = parobj-code
                        bf_pl-gds-pump.pl-code   = parpl-code
                        bf_pl-gds-pump.gds-code  = bf_goods.gds-code
                        bf_pl-gds-pump.pump-code = parpump-code
                        bf_pl-gds-pump.status_   = varstatus
                        .
                      cplgdspm
                        ( input bf_pl-gds-pump.obj-type
                        ,input bf_pl-gds-pump.obj-code
                        ,input bf_pl-gds-pump.pl-code
                        ,input bf_pl-gds-pump.gds-code
                        ,input bf_pl-gds-pump.pump-code
                        ,input bf_pl-gds-pump.status_
                        ) no-error.
                      if error-status:error then
                      do:
                        put-log(substitute ("Ошибка при смене статуса записи резервуар-ТРК-пистолет: &1 &2.", return-value, error-status:get-message(1))).
                        undo tr, return error substitute ("Ошибка при смене статуса записи резервуар-ТРК-пистолет: &1 &2.", return-value, error-status:get-message(1)).
                      end.
                    end.
                    create bf_pl-pump.
                    assign
                      bf_pl-pump.obj-type  = parobj-type
                      bf_pl-pump.obj-code  = parobj-code
                      bf_pl-pump.pl-code   = parpl-code
                      bf_pl-pump.pump-code = parpump-code
                      .
                  end.
                end method.
                method private void plpmnzav(
                  parobj-type    like ub.clients.obj-type  ,
                  parobj-code    like ub.clients.obj-code  ,
                  parpl-code     like ub.place.pl-code     ,
                  parpump-code   like ub.pump.pump-code    ,
                  parnozzle-code like ub.nozzle.nozzle-code
                  ):
                  define buffer bf_clients              for ub.clients.
                  define buffer bf_place                for ub.place.
                  define buffer bf_pump                 for ub.pump.
                  define buffer bf_nozzle               for ub.nozzle.
                  define buffer bf_pl-pump              for ub.pl-pump.
                  define buffer bf_pump-nozzle          for ub.pump-nozzle.
                  define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
                  define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
                  define buffer bf_rvs-doc              for ub.rvs-doc.
                  define buffer bf_icnt-doc             for ub.icnt-doc.
                  define buffer bf_pl-gds-pump          for ub.pl-gds-pump.
                  define buffer bf-other_pl-gds-pump    for ub.pl-gds-pump.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
find first bf_pump where bf_pump.obj-type  = parobj-type  and
                         bf_pump.obj-code  = parobj-code  and
                         bf_pump.pump-code = parpump-code no-lock no-error.
if not available bf_pump then
   return error SUBSTITUTE("Нет ТРК с номером &1", parpump-code) .
find first bf_place where bf_place.obj-type = parobj-type and
                          bf_place.obj-code = parobj-code and
                          bf_place.pl-code  = parpl-code  no-lock no-error.
if not available bf_place then return error SUBSTITUTE("Нет такого складского места &1", parpl-code) .
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_nozzle then
   return error SUBSTITUTE("Нет пистолета ТРК с номером &1", parnozzle-code) .
find first bf_pl-pump where bf_pl-pump.obj-type  = parobj-type  and
                            bf_pl-pump.obj-code  = parobj-code  and
                            bf_pl-pump.pl-code   = parpl-code   and
                            bf_pl-pump.pump-code = parpump-code no-lock no-error.
if not available bf_pl-pump then
   return error SUBSTITUTE("Нет записи резервуар-ТРК с номером резервуара &1 и номером ТРК &2",
                           parpl-code, parpump-code) .
find first bf_pump-nozzle where bf_pump-nozzle.obj-type    = parobj-type    and
                                bf_pump-nozzle.obj-code    = parobj-code    and
                                bf_pump-nozzle.pump-code   = parpump-code   and
                                bf_pump-nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_pump-nozzle then
   return error SUBSTITUTE("Нет записи ТРК-пистолет с номером ТРК &1 и номером пистолета &2",
                                                        parpump-code,
                                                        parnozzle-code) .
 find first bf_rvs-doc where bf_rvs-doc.obj-type =  parobj-type       and
                             bf_rvs-doc.obj-code =  parobj-code       and
                             bf_rvs-doc.status_  <> 'факт':U           and
                             bf_rvs-doc.rvs-type <> 'перед_док':U and
                             bf_rvs-doc.rvs-type <> 'после_док':U  and
                             bf_rvs-doc.rvs-type <> 'проверка':U       no-lock no-error.
if available bf_rvs-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ сверки &1 .", bf_rvs-doc.rvs-code).
end.
find first bf_icnt-doc where bf_icnt-doc.obj-type  =  parobj-type and
                             bf_icnt-doc.obj-code  =  parobj-code and
                             bf_icnt-doc.status_   <> 'факт':U     no-lock no-error.
if available bf_icnt-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ инвентаризации счетчиков ТРК &1 .", bf_icnt-doc.doc-code).
end.
                  do
                    on error undo, return error return-value
                    :
                    create bf_pl-pump-nozzle.
                    assign
                      bf_pl-pump-nozzle.obj-type    = parobj-type
                      bf_pl-pump-nozzle.obj-code    = parobj-code
                      bf_pl-pump-nozzle.pl-code     = parpl-code
                      bf_pl-pump-nozzle.pump-code   = parpump-code
                      bf_pl-pump-nozzle.nozzle-code = parnozzle-code
                      .
                  end.
                end method.
// перенос топологии
                method public void load_schem (ifile-path as character):
                  load_schem(mAddr, ifile-path).
                end.
                method public void load_schem (iAddr as character, ifile-path as character ):
                  define variable v-rep-rec as recid     no-undo .
                  define variable v-ok      as logical   no-undo.
                  define variable VFlag     as logical   no-undo.
                  define variable cmd       as character no-undo.
                  put-log(string (now) + "   Отправляем запрос для получения топологии...").
                  load_gds_maping(ifile-path).
                  empty temp-table tt-gds-prod .
                  empty temp-table tt-place.
                  empty temp-table tt-place-attr.
                  empty temp-table tt-pump.
                  empty temp-table tt-nozzle.
                  empty temp-table tt-pl-pump.
                  empty temp-table tt-pump-nozzle.
                  empty temp-table tt-pl-pump-nozzle.
                  empty temp-table tt-pl-level.
                  empty temp-table tt-pl-gds.
                  empty temp-table tt-pl-gds-pump.
                  cmd = substitute ("&1 --http0.9 &2/THGetInfo?GetSchem >&3", search ("exe/curl.exe"), iAddr, "schem-temp.json").
                  os-command silent value (cmd).
                  put-log(string (now) + "   Разбираем полученные данные...").
                  fix-codepage_and_SetJsonObj (input "schem-temp.json") .
                  parse-json(input temp-table tt-place:default-buffer-handle, input "place") .
                  parse-json(input temp-table tt-place-attr:default-buffer-handle, input "place-attr") .
                  parse-json(input temp-table tt-pump:default-buffer-handle, input "pump") .
                  parse-json(input temp-table tt-nozzle:default-buffer-handle, input "nozzle") .
                  parse-json(input temp-table tt-pl-pump:default-buffer-handle, input "pl-pump") .
                  parse-json(input temp-table tt-pump-nozzle:default-buffer-handle, input "pump-nozzle") .
                  parse-json(input temp-table tt-pl-pump-nozzle:default-buffer-handle, input "pl-pump-nozzle") .
                  parse-json(input temp-table tt-pl-level:default-buffer-handle, input "pl-level") .
                  parse-json(input temp-table tt-pl-gds:default-buffer-handle, input "pl-gds") .
                  parse-json(input temp-table tt-pl-gds-pump:default-buffer-handle, input "pl-gds-pump") .
                  parse-json(input temp-table tt-gds-prod:default-buffer-handle, input "tt-gds-prod") .
  //  delete object myResultObj no-error.
  //delete object results-array no-error.
                  for each tt-gds-prod no-lock :
                    find first tt-gds-mapping no-lock where tt-gds-mapping.gds-code15 = tt-gds-prod.gds-code no-error .
                    if not available tt-gds-mapping
                      then
                    do :
                      put-log(("В файле соответсвий нет топлива " + string(tt-gds-prod.gds-code) + " с коротким кодом " + tt-gds-prod.b-str)).
                      undo, return error ("В файле соответсвий нет топлива " + string(tt-gds-prod.gds-code) + " с коротким кодом " + tt-gds-prod.b-str) .
                    end.
                    find first ub.goods no-lock where ub.goods.gds-code = tt-gds-mapping.gds-code16 no-error.
                    if not available ub.goods
                      then
                    do :
                      put-log(("Нет топлива с кодом " + string(tt-gds-mapping.gds-code16) + " . Код в v" + string(version-name) +  " - " + string(tt-gds-mapping.gds-code15)) ).
                      undo, return error ("Нет топлива с кодом " + string(tt-gds-mapping.gds-code16) + " . Код в v" + string(version-name) +  " - " + string(tt-gds-mapping.gds-code15)) .
                    end.
                    else
                    do:
                      find first ub.prod-bc no-lock where ub.prod-bc.b-code = ub.goods.gds-code and ub.prod-bc.b-str = tt-gds-prod.b-str no-error .
                      if not available (ub.prod-bc) then
                      do:
                        create ub.prod-bc.
                        assign
                          ub.prod-bc.b-code     = ub.goods.gds-code
                          ub.prod-bc.b-str      = tt-gds-prod.b-str
                          ub.prod-bc.bc-on      = true
                          ub.prod-bc.bc-on-type = tt-gds-prod.bc-on-type
                          ub.prod-bc.cr-db-num  = v-cntxt-db-num-obj
                          .
                      end.
                    end.
                  end.
                  put-log(string (now) + "   Начинаем загрузку топологии...").
                  for each tt-pump no-lock :
                    put-log("ТРК №" + string(tt-pump.pump-code)).
                    pumpav
                      ( input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input tt-pump.pump-code
                      ) no-error.
                    if error-status:error then
                    do:
                      put-Log(return-value).
                      undo, return error return-value.
                    end.
                  end.
                  for each tt-nozzle no-lock :
                    put-log( "Пистолет №" + string(tt-nozzle.nozzle-code)).
                    nozzleav (input v-cntxt-obj-type,
                      v-cntxt-obj-code,
                      tt-nozzle.nozzle-code) no-error.
                    if error-status:error then
                    do:
                      put-Log(return-value).
                      undo, return error return-value.
                    end.
                  end.
                  for each tt-pump-nozzle no-lock :
                    put-log( "Связка ТРК-Пистолет №" + string(tt-pump-nozzle.pump-code) +  "-" +  string(tt-pump-nozzle.nozzle-code)) .
                    pumpnzav( input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input tt-pump-nozzle.pump-code
                      ,input tt-pump-nozzle.nozzle-code
                      ,input tt-pump-nozzle.is-meas
                      ,input ""
                      ) no-error.
                    if error-status:error then
                    do:
                      put-Log(return-value).
                      undo, return error return-value.
                    end.
                  end.
                  for each tt-place no-lock :
                    if tt-place.status_ = "удал" then next .
                    put-log( "Резервуар координата1 " + string(tt-place.loc1)) .
                    run ref/place01.p
                      ( input-output v-rep-rec
                      , input 'ДОБАВЛЕНИЕ':U
                      , input yes
                      , input v-cntxt-obj-type
                      , input v-cntxt-obj-code
                      , input 0
                      , input tt-place.loc1
                      , input tt-place.loc2
                      , input tt-place.loc3
                      , input tt-place.loc4
                      , input tt-place.pl-name
                      , input tt-place.ps
                      , input tt-place.add-qnty
                      , input tt-place.is-meas
                      , input tt-place.max-qnty
                      , input tt-place.issue-year
                      , input tt-place.start-date
                      , input no
                      ) no-error.
                    if error-status:error then
                    do:
                      put-Log(return-value).
                      undo, return error return-value.
                    end.
                    find first ub.place no-lock where recid(ub.place) = v-rep-rec .
                    for each tt-place-attr no-lock where tt-place-attr.obj-type = tt-place.obj-type
                      and tt-place-attr.obj-code = tt-place.obj-code
                      and tt-place-attr.pl-code  = tt-place.pl-code :
                      mplacelib:placelib_write-attr
                        (input tt-place-attr.attr-code
                        ,input v-cntxt-obj-code
                        ,input v-cntxt-obj-type
                        ,input ub.place.pl-code
                        ,input tt-place-attr.attr-value
                        ,output v-ok      )
                        no-error.
                      if error-status:error then
                      do:
                        put-Log(return-value).
                        undo, return error return-value.
                      end.
                    end.
                    find first ub.place-attr no-lock where ub.place-attr.obj-type = v-cntxt-obj-type
                      and ub.place-attr.obj-code = v-cntxt-obj-code
                      and ub.place-attr.pl-code  = ub.place.pl-code
                      and ub.place-attr.attr-code = "place-error-mass"
                      no-error .
                    if not available ub.place-attr
                      then
                    do :
                      mplacelib:placelib_write-attr
                        (input "place-error-mass"
                        ,input v-cntxt-obj-code
                        ,input v-cntxt-obj-type
                        ,input ub.place.pl-code
                        ,input string(0.15)
                        ,output v-ok      )
                        no-error.
                      if error-status:error then
                      do:
                        put-Log(return-value).
                        undo, return error return-value.
                      end.
                    end.
                    find first ub.place-attr no-lock where ub.place-attr.obj-type = v-cntxt-obj-type
                      and ub.place-attr.obj-code = v-cntxt-obj-code
                      and ub.place-attr.pl-code  = ub.place.pl-code
                      and ub.place-attr.attr-code = "place-local"
                      no-error .
                    if not available ub.place-attr
                      then
                    do :
                      mplacelib:placelib_write-attr
                        (input "place-local"
                        ,input v-cntxt-obj-code
                        ,input v-cntxt-obj-type
                        ,input ub.place.pl-code
                        ,input string(2)
                        ,output v-ok      )
                        no-error.
                      if error-status:error then
                      do:
                        put-Log(return-value).
                        undo, return error return-value.
                      end.
                    end.
                    for each tt-pl-level no-lock where tt-pl-level.obj-type = tt-place.obj-type
                      and tt-pl-level.obj-code = tt-place.obj-code
                      and tt-pl-level.pl-code  = tt-place.pl-code :
                      create ub.pl-level.
                      assign
                        ub.pl-level.obj-type = v-cntxt-obj-type
                        ub.pl-level.obj-code = v-cntxt-obj-code
                        ub.pl-level.pl-code  = ub.place.pl-code
                        ub.pl-level.pl-level = tt-pl-level.pl-level
                        ub.pl-level.pl-qnty  = tt-pl-level.pl-qnty
                        .
                    end.
                    for each tt-pl-gds no-lock where tt-pl-gds.obj-type = tt-place.obj-type
                      and tt-pl-gds.obj-code = tt-place.obj-code
                      and tt-pl-gds.pl-code  = tt-place.pl-code,
                      first tt-gds-mapping no-lock where tt-gds-mapping.gds-code15 = tt-pl-gds.gds-code  :
                      run trg/plgdpmvc.p (
                        input  v-cntxt-obj-type,
                        input  v-cntxt-obj-code,
                        input  ub.place.pl-code,
                        input  tt-gds-mapping.gds-code16,
                        output v-ok) no-error.
                      if error-status:error then
                      do:
                        put-Log(return-value).
                        undo, return error return-value.
                      end.
                      if not v-ok then
                      do:
                      end.
                    end.
                    for each tt-pl-pump no-lock where tt-pl-pump.obj-type   = tt-place.obj-type
                      and tt-pl-pump.obj-code   = tt-place.obj-code
                      and tt-pl-pump.pl-code    = tt-place.pl-code :
                      put-log(  "Связка Резервуар-ТРК №" + string(ub.place.loc1) +  "-" + string(tt-pl-pump.pump-code) ) .
                      plpumpav
                        (input v-cntxt-obj-type,
                        input v-cntxt-obj-code,
                        input ub.place.pl-code,
                        input tt-pl-pump.pump-code) no-error.
                      if error-status:error then
                      do:
                        put-Log(return-value).
                        undo, return error return-value.
                      end.
                    end.
                    for each tt-pl-pump-nozzle no-lock where  tt-pl-pump-nozzle.obj-type   = tt-place.obj-type
                      and tt-pl-pump-nozzle.obj-code   = tt-place.obj-code
                      and tt-pl-pump-nozzle.pl-code    = tt-place.pl-code :
                      put-log( "Связка Резервуар-ТРК-Пистолет №" + string(ub.place.loc1) + "-" +  string(tt-pl-pump-nozzle.pump-code) + "-" + string(tt-pl-pump-nozzle.nozzle-code)).
                      plpmnzav
                        ( input v-cntxt-obj-type
                        ,input v-cntxt-obj-code
                        ,input ub.place.pl-code
                        ,input tt-pl-pump-nozzle.pump-code
                        ,input tt-pl-pump-nozzle.nozzle-code
                        ) no-error.
                      if error-status:error then
                      do:
                        put-Log(return-value).
                        undo, return error return-value.
                      end.
                    end.
                    for each tt-pl-gds-pump where tt-pl-gds-pump.obj-type = tt-place.obj-type and
                      tt-pl-gds-pump.obj-code = tt-place.obj-code and
                      tt-pl-gds-pump.pl-code = tt-place.pl-code,
                      first tt-gds-mapping no-lock where tt-gds-mapping.gds-code15 = tt-pl-gds-pump.gds-code :
                      find first pl-gds-pump exclusive-lock where pl-gds-pump.obj-type = v-cntxt-obj-type
                        and pl-gds-pump.obj-code = v-cntxt-obj-code
                        and pl-gds-pump.pl-code  = ub.place.pl-code
                        and pl-gds-pump.gds-code = tt-gds-mapping.gds-code16
                        and pl-gds-pump.pump-code = tt-pl-gds-pump.pump-code
                        no-error.
                      if available pl-gds-pump
                        then
                      do :
                        pl-gds-pump.status_ = tt-pl-gds-pump.status_ .
                      end.
                    end.
                  end.
                  vflag  = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("schem-temp.json") .
                      os-delete value("schem.json") .
                    end.
                    if vflag and Chek_Shem() then
                      put-log( string(now) + "   Топология загружена!" ).
                    else
                      put-log( string(now) + "   Топология не загружена!" ).
                  end finally.
                end method.
                method public logical Chek_Shem(
                  ):
                  define variable v-has-records as logical no-undo.
                  for each ub.place no-lock where ub.place.obj-type = v-cntxt-obj-type
                    and ub.place.obj-code = v-cntxt-obj-code :
                    v-has-records = true .
                    leave.
                  end.
                  if not v-has-records
                    then
                    for each ub.place-attr no-lock where ub.place-attr.obj-type = v-cntxt-obj-type
                      and ub.place-attr.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  if not v-has-records
                    then
                    for each ub.pump no-lock where ub.pump.obj-type = v-cntxt-obj-type
                      and ub.pump.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  if not v-has-records
                    then
                    for each ub.nozzle no-lock where ub.nozzle.obj-type = v-cntxt-obj-type
                      and ub.nozzle.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  if not v-has-records
                    then
                    for each ub.pump-nozzle no-lock where ub.pump-nozzle.obj-type = v-cntxt-obj-type
                      and ub.pump-nozzle.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  if not v-has-records
                    then
                    for each ub.pl-pump-nozzle no-lock where ub.pl-pump-nozzle.obj-type = v-cntxt-obj-type
                      and ub.pl-pump-nozzle.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  if not v-has-records
                    then
                    for each ub.pl-pump no-lock where ub.pl-pump.obj-type = v-cntxt-obj-type
                      and ub.pl-pump.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  if not v-has-records
                    then
                    for each ub.pl-gds no-lock where ub.pl-gds.obj-type = v-cntxt-obj-type
                      and ub.pl-gds.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  if not v-has-records
                    then
                    for each ub.pl-gds-pump no-lock where ub.pl-gds-pump.obj-type = v-cntxt-obj-type
                      and ub.pl-gds-pump.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  return v-has-records.
                end method.
                method public logical chek_schedule():
                  define variable v-has-records as logical no-undo.
                  for each ub.schedule no-lock where ub.schedule.cre-db-num = v-cntxt-db-num-obj :
                    v-has-records = true .
                    leave.
                  end.
                  if not v-has-records
                    then
                    for each ub.schedule-attr no-lock where ub.schedule-attr.cre-db-num = v-cntxt-db-num-obj :
                      v-has-records = true .
                      leave.
                    end.
                  return  v-has-records.
                end method.
                method public logical chek_fbrgds():
                  define variable v-has-records as logical no-undo.
                  for each ub.fbr-gds-obj no-lock where ub.fbr-gds-obj.obj-code = v-cntxt-obj-code and ub.fbr-gds-obj.obj-type = v-cntxt-obj-type and
                    ub.fbr-gds-obj.is-modificator = true :
                    v-has-records = true .
                    leave.
                  end.
                  return  v-has-records.
                end method.
                method public void load_schedule ():
                  define variable v-file-sch  as character no-undo .
                  define variable v-file-attr as character no-undo .
                  define variable vFlag       as logical   no-undo.
                  define buffer buf_schedule      for ub.schedule .
                  define buffer buf_schedule-attr for ub.schedule-attr .
                  define buffer buf_rp-by-call    for ub.rp-by-call.
                  define variable v-uniq-key-rec as character no-undo .
                  define variable v-call#-id     as integer   no-undo .
                  define variable p-call-id      as character no-undo .
                  define variable p-profile-id   as integer   no-undo .
                  define variable p-once-more    as integer   no-undo .
                  define buffer buf_rule-by-call        for ub.rule-by-call.
                  define buffer buf_Rule-call-param     for ub.rule-call-param .
                  define buffer buf_tt-rule-call-param  for tt-rule-call-param.
                  define buffer buf_tt0-rp-by-call      for tt0-rp-by-call.
                  define buffer buf_tt0-rule-by-call    for tt0-rule-by-call.
                  define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
                  vFlag = no .
                  empty temp-table tt-schedule .
                  empty temp-table tt-schedule-attr .
                  put-log(string (now) + "   Создаем расписания для автозаданий...").
                  v-file-sch = search("cmp/schedule.txt") .
                  file-info:file-name = v-file-sch .
                  if file-info:file-type = ? then
                  do :
                    put-log("Отсутствует файл с эталонным расписанием для автозаданий schedule.txt") .
                    return error "Отсутствует файл с эталонным расписанием для автозаданий schedule.txt" .
                  end.
                  v-file-attr = search("cmp/schedule-attr.txt") .
                  file-info:file-name = v-file-attr .
                  if file-info:file-type = ? then
                  do :
                    put-log("Отсутствует файл с атрибутами для эталонного расписания автозаданий utl/schedule-attr.txt") .
                    return error "Отсутствует файл с атрибутами для эталонного расписания автозаданий utl/schedule-attr.txt" .
                  end.
                  input from value(v-file-sch) .
                  repeat :
                    create tt-schedule .
                    import tt-schedule .
                  end.
                  input close .
                  input from value(v-file-attr) .
                  repeat :
                    create tt-schedule-attr .
                    import tt-schedule-attr .
                  end.
                  input close .
                  for each tt-schedule no-lock :
                    if tt-schedule.task-num = ? or tt-schedule.task-num <= 0 then next .
                    create buf_schedule.
                    buffer-copy tt-schedule to buf_schedule
                      assign
                      buf_schedule.cre-db-num  = v-cntxt-db-num-obj
                      buf_schedule.db-num-char = string(v-cntxt-db-num-obj)
                      .
                    if buf_schedule.task-type = "autonws" then buf_schedule.db-num-char = "0" .
                    if buf_schedule.task-type = "autosuz" then
                    do:
                      v-uniq-key-rec = gen-key-rec ('schedule':U,(buffer buf_schedule:handle)).
                      run rul/g-callid.p ( input 'rep':U
                        ,input v-uniq-key-rec
                        ,output v-call#-id).
                      p-call-id = "thbj-attr" + chr(3) + chr(3) + string(0) + chr(3) + "rum" + chr(3) + "rep"  .
                      p-profile-id = 50 .
                      p-once-more = 1 .
                      for each  buf_rp-by-call where
                        buf_rp-by-call.call_id = p-call-id
                        and buf_rp-by-call.profile_id = p-profile-id
                        and buf_rp-by-call.once-more = p-once-more
                        :
                        create buf_tt0-rp-by-call.
                        buffer-copy buf_rp-by-call
                          except once-more call_id call#_id
                          to buf_tt0-rp-by-call
                          assign
                          buf_tt0-rp-by-call.call_id = v-uniq-key-rec
                          buf_tt0-rp-by-call.call#_id = v-call#-id
                          buf_tt0-rp-by-call.once-more = 1
                          .
                        RELEASE buf_tt0-rp-by-call.
                      end.
                      for each  buf_rule-by-call where
                        buf_rule-by-call.call_id = p-call-id
                        and buf_rule-by-call.profile_id = p-profile-id
                        and buf_rule-by-call.once-more = p-once-more
                        :
                        create buf_tt0-rule-by-call.
                        buffer-copy buf_rule-by-call
                          except once-more call_id call#_id
                          to buf_tt0-rule-by-call
                          assign
                          buf_tt0-rule-by-call.call_id = v-uniq-key-rec
                          buf_tt0-rule-by-call.call#_id = v-call#-id
                          buf_tt0-rule-by-call.once-more = 1
                          .
                        RELEASE buf_tt0-rule-by-call.
                      end.
                      for each buf_Rule-call-param no-lock where
                        buf_rule-call-param.call_id = p-call-id
                        and  buf_rule-call-param.profile_id = p-profile-id
                        AND buf_rule-call-param.once-more = p-once-more:
                        create buf_tt0-rule-call-param.
                        buffer-copy buf_Rule-call-param
                          except once-more call_id call#_id
                          to buf_tt0-rule-call-param
                          assign
                          buf_tt0-rule-call-param.call_id = v-uniq-key-rec
                          buf_tt0-rule-call-param.call#_id = v-call#-id
                          buf_tt0-rule-call-param.once-more = 1
                          .
                        if buf_rule-call-param.param-num = 1 and buf_rule-call-param.param-value-integer <> 0 then buf_tt0-rule-call-param.param-value-integer = v-cntxt-db-num-obj .
                      end.
                      run rul/g-callid.p ( input 'rep':U
                        ,input v-uniq-key-rec
                        ,output v-call#-id).
                      run rul/thbjrum1.p (
                        input 'ДОБАВЛЕНИЕ':U
                        ,input 'rep':U
                        ,input v-uniq-key-rec
                        ,input 0
                        ,input "":U
                        ,input 0
                        ,input ?
                        ,INPUT TABLE tt0-rp-by-call
                        ,INPUT TABLE tt0-rule-by-call
                        ,INPUT TABLE tt0-rule-call-param) no-error .
                      if error-status :error then
                      do:
                        message
                          error-status:get-message(1)  skip
                          return-value
                          view-as alert-box error .
                        return error.
                      end.
                    end.
                  end.
                  for each tt-schedule-attr no-lock :
                    if tt-schedule-attr.task-num = ? or tt-schedule-attr.task-num <= 0 then next .
                    create buf_schedule-attr.
                    buffer-copy tt-schedule-attr to buf_schedule-attr
                      assign
                      buf_schedule-attr.cre-db-num = v-cntxt-db-num-obj
                      .
                    if buf_schedule-attr.task-type = "autogcd"
                      and buf_schedule-attr.attr-code = "schedule-obj-list"
                      then
                    do :
                      buf_schedule-attr.attr-value = replace(buf_schedule-attr.attr-value, string(tt-schedule-attr.cre-db-num), string(v-cntxt-db-num-obj)) .
                    end.
                    if buf_schedule-attr.task-type = "autoexp"
                      then
                    do :
                      case buf_schedule-attr.attr-code:
                        when "schedule-obj-list" then
                          do:
                            assign
                              buf_schedule-attr.attr-value = v-cntxt-obj-type + "," + string(v-cntxt-obj-code) .
                            .
                          end.
                        when "schedule-param-list" then
                          do:
                            assign
                              entry(15,buf_schedule-attr.attr-value,",") = string(v-cntxt-host-code-obj)
                              .
                          end.
                      end case .
                    end.
                    if buf_schedule-attr.task-type = "autosale"
                      then
                    do :
                      case buf_schedule-attr.attr-code:
                        when "schedule-param-list" then
                          do:
                            assign
                              entry(2,buf_schedule-attr.attr-value,",") = string(v-cntxt-host-code-obj)
                              .
                          end.
                      end case .
                    end.
                    if buf_schedule-attr.task-type = "autosuz"
                      then
                    do :
                      define variable formatObjCode as character no-undo .
                      case buf_schedule-attr.attr-code:
                        when "schedule-param-list" then
                          do:
                            case length(v-cntxt-obj-code):
                              when 1 or
                              when 2 then
                                do:
                                  formatObjCode = "999" .
                                end.
                              when 4 then
                                do:
                                  formatObjCode = "99999" .
                                end.
                            end case .
                            assign
                              entry(1,buf_schedule-attr.attr-value,"|") = "C:\Trade_House16x\Exchange\news-dir\exch\" + (if formatObjCode <> "" then string(v-cntxt-obj-code, formatObjCode) else string(v-cntxt-obj-code)) + "-000"
                              entry(2,buf_schedule-attr.attr-value,"|") = "C:\Trade_House16x\Exchange\news-dir\exch\" + (if formatObjCode <> "" then string(v-cntxt-obj-code, formatObjCode) else string(v-cntxt-obj-code)) + "-000"
                              .
                          end.
                      end case .
                    end.
                  end.
                  vflag  = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("schem-temp.json") .
                      os-delete value("schem.json") .
                    end.
                    if vflag and Chek_Schedule() then
                      put-log( string(now) + "   Расписания для автозаданий созданы!") .
                    else
                      put-log( string(now) + "   Расписания для автозаданий не созданы!") .
                  end finally.
                end.
                method public void  load_fbrgds (ifile-path as character ):
                  load_fbrgds (maddr,ifile-path ).
                end method .
                method public void  load_fbrgds (iAddr as character,ifile-path as character ):
                  define variable v-rid as recid     no-undo .
                  define variable vcmd  as character no-undo.
                  define variable vFlag as logical   no-undo.
                  define buffer buf_fbr-gds-obj for ub.fbr-gds-obj .
                  empty temp-table tt-fbr-gds-obj.
                  put-log(string (now) + "   Отправляем запрос для получения атрибутов автопроизводства...").
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetFbrGds >&3", search ("exe/curl.exe"), iAddr, "fbrgds-temp.json").
                  os-command silent value (vcmd).
                  put-log(string (now) + "   Разбираем полученные данные...").
                  fix-codepage_and_SetJsonObj (input "fbrgds-temp.json") .
                  parse-json(input temp-table tt-fbr-gds-obj:default-buffer-handle, input "fbr-gds-obj") .
                  put-log( string(now) + "   Начинаем загрузку атрибутов автопроизводства...") .
                  load_gds_maping(ifile-path).
                  for each tt-fbr-gds-obj no-lock :
                    find first tt-gds-mapping no-lock where tt-gds-mapping.gds-code15 = tt-fbr-gds-obj.gds-code no-error .
                    if available tt-gds-mapping
                      then
                    do :
                      if tt-gds-mapping.gds-code15 = 0 or tt-gds-mapping.gds-code15 = ?
                        or tt-gds-mapping.gds-code16 = 0 or tt-gds-mapping.gds-code16 = ?
                        then next .
                      find first ub.goods no-lock where ub.goods.gds-code = tt-gds-mapping.gds-code16 no-error.
                      if available ub.goods
                        then
                      do :
                        find first buf_fbr-gds-obj exclusive-lock where buf_fbr-gds-obj.gds-code = ub.goods.gds-code no-error .
                        if not available (buf_fbr-gds-obj) then
                        do:
                          if tt-fbr-gds-obj.is-menu then
                          do:
                            put-err-log(
                              "Товар с кодом " + string(tt-gds-mapping.gds-code16) + " .Код в " + string(version-name) +  " " + string(tt-fbr-gds-obj.gds-code) + " " +
                              "Атрибут: Является блюдом меню, в " + string(version-name) +  " версии имеет значение: " + string(tt-fbr-gds-obj.is-menu) + " а в 16 " + "no").
                            next .
                          end.
                          create buf_fbr-gds-obj .
                          assign
                            buf_fbr-gds-obj.gds-code     = ub.goods.gds-code
                            buf_fbr-gds-obj.obj-code     = v-cntxt-obj-code
                            buf_fbr-gds-obj.obj-type     = v-cntxt-obj-type
                            buf_fbr-gds-obj.fbr-obj-code = v-cntxt-obj-code
                            buf_fbr-gds-obj.fbr-obj-type = v-cntxt-obj-type
                            .
                          buffer-copy tt-fbr-gds-obj except tt-fbr-gds-obj.obj-code
                            tt-fbr-gds-obj.obj-type
                            tt-fbr-gds-obj.gds-code
                            tt-fbr-gds-obj.fbr-obj-code
                            tt-fbr-gds-obj.fbr-obj-type to buf_fbr-gds-obj no-error .
                          if error-status:error then
                          do:
                            put-Log(return-value).
                            undo, return error return-value.
                          end.
                        end.
                        else
                        do:
                          if tt-fbr-gds-obj.is-menu <> buf_fbr-gds-obj.is-menu then
                          do:
                            put-err-log(
                              "Товар с кодом " + string(tt-gds-mapping.gds-code16) + " .Код в " + string(version-name) +  " " + string(tt-fbr-gds-obj.gds-code) + " " +
                              "Атрибут: Является блюдом меню, в " + string(version-name) +  " версии имеет значение: " + string(tt-fbr-gds-obj.is-menu) + " а в 16 " + string (buf_fbr-gds-obj.is-menu)).
                            next .
                          end.
                          else buf_fbr-gds-obj.is-modificator = tt-fbr-gds-obj.is-modificator .
                          buffer-copy tt-fbr-gds-obj except tt-fbr-gds-obj.obj-code
                            tt-fbr-gds-obj.obj-type
                            tt-fbr-gds-obj.gds-code
                            tt-fbr-gds-obj.is-menu
                            tt-fbr-gds-obj.is-modificator
                            tt-fbr-gds-obj.fbr-obj-code
                            tt-fbr-gds-obj.fbr-obj-type to buf_fbr-gds-obj no-error .
                          if error-status:error then
                          do:
                            put-Log(return-value).
                            undo, return error return-value.
                          end.
                        end.
                      end.
                      else
                      do :
                        put-err-log(
                          "Не найден товар с кодом " + string(tt-gds-mapping.gds-code16) + " .Код в " + string(version-name) +  " " + string(tt-fbr-gds-obj.gds-code)).
                      end.
                    end.
                    else
                    do :
                      put-err-log(
                        "В файле соответствия " + ifile-path + " нет данных по товару с кодом " + string(tt-fbr-gds-obj.gds-code)).
                    end.
                  end.
                  vflag  = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("fbrgds-temp.json") .
                      os-delete value("fbrgds.json") .
                    end.
                    if vflag and Chek_fbrgds() then
                      put-log( string(now) + "   Атрибуты автопроизводства загружены!") .
                    else
                      put-log( string(now) + "   Атрибуты автопроизводства не загружены!") .
                  end finally.
                end.
                method public void  load_version ():
                  load_version (maddr).
                end method .
                method public void  load_version (iAddr as character):
                  define variable vcmd as character no-undo.
                  define variable vOk  as logical   no-undo.
                  put-log(string (now) + "   Отправляем запрос для получения верcии.").
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetVersion >&3", search ("exe/curl.exe"), iaddr, "version-temp.json").
                  os-command silent value (vcmd).
                  fix-codepage_and_SetJsonObj (input "version-temp.json") no-error.
  //empty temp-table tt-version.
                  if error-status:error
                    then
                  do:
                    put-log("Не удалось узнать версию.").
                    return.
                  end.
                  parse-json(input temp-table tt-version:default-buffer-handle, input "tt-version") .
                  delete object mJsonObj no-error.
                  find first tt-version no-lock no-error .
                  put-log(substitute ("Версия &1 по адресу &2", version-name, iAddr)).
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("version-temp.json") .
                      os-delete value("version.json") .
                    end.
                  end finally.
                end.
                method public logical chek_cash_desk():
                  define variable v-has-records as logical no-undo.
                  for each ub.cash-desk no-lock where ub.cash-desk.db-num = v-cntxt-db-num-obj
                    and ub.cash-desk.obj-code = v-cntxt-obj-code :
                    v-has-records = true .
                    leave.
                  end.
                  if not v-has-records
                    then
                    for each ub.cash-desk-attr no-lock where ub.cash-desk-attr.db-num = v-cntxt-db-num-obj
                      and ub.cash-desk-attr.obj-code = v-cntxt-obj-code :
                      v-has-records = true .
                      leave.
                    end.
                  return  v-has-records.
                end method.
// Перенос справочника касс
                method public character load_cashdesk ():
                  return load_cashdesk(mAddr ).
                end.
                method public character load_cashdesk(iAddr as character ) :
                  define variable v-rid       as recid     no-undo .
                  define variable vcmd        as character no-undo.
                  define variable vFlag       as logical   no-undo.
                  define variable v-addr-path as character no-undo .
                  define buffer buf_tt-cash-desk for tt-cash-desk .
                  define buffer bf_tt-cash-desk  for tt-cash-desk .
                  define variable isCashDesk as logical no-undo init true .
                  empty temp-table tt-cash-desk.
                  empty temp-table tt-cash-desk-attr.
                  put-log(string (now) + "   Отправляем запрос для получения касс...").
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetCashDesk >&3", search ("exe/curl.exe"), iAddr, "cashdesk-temp.json").
                  os-command silent value (vcmd).
                  put-log(string (now) + "   Разбираем полученные данные...").
                  fix-codepage_and_SetJsonObj (input "cashdesk-temp.json") .
                  parse-json(input temp-table tt-cash-desk:default-buffer-handle, input "cash-desk") .
                  parse-json(input temp-table tt-cash-desk-attr:default-buffer-handle, input "cash-desk-attr") .
                  put-log( string(now) + "   Начинаем загрузку касс...") .
                  v-cash-num = 0 .
                  for each tt-cash-desk where exclusive-lock by tt-cash-desk.cash-num by tt-cash-desk.pos-type:
                    if tt-cash-desk.is-del then next .
                    tt-cash-desk.addr-path = replace(tt-cash-desk.addr-path, "|", chr(4)) .
                    for first tt-cash-desk-attr no-lock where tt-cash-desk-attr.db-num = tt-cash-desk.db-num
                      and tt-cash-desk-attr.obj-code = tt-cash-desk.obj-code
                      and tt-cash-desk-attr.pos-type = tt-cash-desk.pos-type
                      and tt-cash-desk-attr.cash-num = tt-cash-desk.cash-num
                      and tt-cash-desk-attr.attr-code = "fr-type" :
                      tt-cash-desk.fr-type = tt-cash-desk-attr.attr-value .
                    end.
                  end.
                  do while isCashDesk:
                    if can-find (first tt-cash-desk where tt-cash-desk.isSave = false) then
                    do:
                      load_cashdesk1 () .
                    end.
                    else isCashDesk = false .
                  end.
                  v-string-cash = trim(v-string-cash,";") .
                  vflag  = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("cashdesk-temp.json") .
                      os-delete value("cashdesk.json") .
                    end.
                    if vflag and chek_cash_desk() then
                    do:
                      if v-RfNumber <> 0 then v-string-cash = string(v-cash-rf) + chr(4) + string(v-RfNumber) + chr(4) + v-string-cash .
                      find first ub.cash-desk-attr exclusive-lock where ub.cash-desk-attr.attr-code = "string-cash" and
                        ub.cash-desk-attr.cash-num = 0 and
                        ub.cash-desk-attr.db-num = v-cntxt-db-num and
                        ub.cash-desk-attr.obj-code = v-cntxt-obj-code no-error .
                      if not available (ub.cash-desk-attr) then
                      do:
                        create ub.cash-desk-attr .
                        assign
                          ub.cash-desk-attr.attr-code = "string-cash"
                          ub.cash-desk-attr.cash-num  = 0
                          ub.cash-desk-attr.db-num    = v-cntxt-db-num
                          ub.cash-desk-attr.obj-code  = v-cntxt-obj-code
                          .
                      end.
                      ub.cash-desk-attr.attr-value-character = v-string-cash .
                      put-log( string(now) + "   Кассы загружены!") .
                      return v-string-cash .
                    end.
                    else
                    do:
                      put-log( string(now) + "   Кассы не загружены!") .
                      return "" .
                    end.
                  end finally.
                end method.
                method public void load_cashdesk1() :
                  define variable v-rid       as recid     no-undo .
                  define variable v-addr-path as character no-undo .
                  define buffer buf_tt-cash-desk for tt-cash-desk .
                  define variable v-send as logical no-undo .
                  for each tt-cash-desk where not tt-cash-desk.is-del and not tt-cash-desk.isSave exclusive-lock:
                    v-send = false .
                    find first buf_tt-cash-desk where not buf_tt-cash-desk.isSave and buf_tt-cash-desk.pos-type = "Autotank" and buf_tt-cash-desk.autonomy = 2 no-error .
                    if available (buf_tt-cash-desk) then
                    do:
                      buf_tt-cash-desk.isSave = true .
                      if integer(entry (2,buf_tt-cash-desk.addr-path,":")) = 7999 then
                        v-addr-path = entry (1,buf_tt-cash-desk.addr-path,":") .
                    end.
                    else
                    do:
                      find first buf_tt-cash-desk where not buf_tt-cash-desk.isSave and buf_tt-cash-desk.pos-type = "IBM-XML" no-error .
                      if available (buf_tt-cash-desk) then
                      do:
                        v-cash-num = v-cash-num + 1 .
                        if v-addr-path = entry (1,buf_tt-cash-desk.addr-path,":") then
                        do:
                          v-cash-rf = v-cash-num .
                          v-send-Rf = true .
                        end.
                        buf_tt-cash-desk.isSave = true .
                      end.
                      else
                      do:
                        find first buf_tt-cash-desk where not buf_tt-cash-desk.isSave and buf_tt-cash-desk.pos-type = "Autotank" no-error .
                        if available (buf_tt-cash-desk) then
                        do:
                          v-cash-num = v-cash-num + 1 .
                          if v-send-Rf then v-RfNumber = v-cash-num .
                          v-send-Rf = false .
                          buf_tt-cash-desk.isSave = true .
                        end.
                      end .
                    end.
                    put-log(  "Касса " + buf_tt-cash-desk.pos-type
                      + " №"     + string(buf_tt-cash-desk.cash-num)
                      + " IP: "  + entry(if buf_tt-cash-desk.addr-path eq "" then 1 else num-entries(buf_tt-cash-desk.addr-path, chr(4)) ,
                      buf_tt-cash-desk.addr-path,
                      chr(4))).
                    define variable vOldCashNum as integer no-undo.
                    vOldCashNum = buf_tt-cash-desk.cash-num.
                    if buf_tt-cash-desk.cash-num <> v-cash-num then
                      assign
                        buf_tt-cash-desk.cash-num = v-cash-num
                        v-send                    = true .
                    run ref/cashdsk1.p (
                      input-output v-rid
                      ,input 'ДОБАВЛЕНИЕ':U
                      ,input v-cntxt-db-num-obj
                      ,input v-cntxt-obj-code
                      ,input buf_tt-cash-desk.pos-type
                      ,input buf_tt-cash-desk.cash-num
                      ,input buf_tt-cash-desk.autonomy
                      ,input buf_tt-cash-desk.addr-path
                      ,input no
                      ,input buf_tt-cash-desk.cash-os
                      ,input buf_tt-cash-desk.is-del
                      ,input buf_tt-cash-desk.remote
                      ,input buf_tt-cash-desk.version
                      ,input buf_tt-cash-desk.registration-code
                      ,input buf_tt-cash-desk.serial-code
                      ,input buf_tt-cash-desk.fr-type
                      ,input ?
                      ) no-error .
                    if error-status:error then
                    do:
                      put-Log(return-value).
                      undo, return error return-value.
                    end.
                    if v-send then
                    do:
                      v-string-cash = v-string-cash + ";" + string(buf_tt-cash-desk.cash-num) .
                    end.
                  end.
                end method.
                method public void parse-json (
                  pBuff as handle,
                  p-array-name as character):
                  define variable v-data-type as character no-undo .
                  define variable vCount      as integer   no-undo.
                  define variable vLength     as integer   no-undo.
                  define variable vI          as integer   no-undo.
                  results-array = mJsonObj:GetJsonArray(p-array-name) no-error.
                  if error-status:error then return.
                  vLength = results-array:LENGTH.
                  do vCount = 1 to vLength:
                    myResultObj = results-array:GetJsonObject(vCount).
                    pBuff:buffer-create () .
                    do vI = 1 to pBuff:num-fields:
                      v-data-type = pBuff:buffer-field[vI]:data-type .
                      case v-data-type :
                        when "character" then
                          do:
                            pBuff:buffer-field[vI]:buffer-value = myResultObj:GetCharacter(pBuff:buffer-field[vI]:name) no-error .
                          end.
                        when "integer" then
                          do:
                            pBuff:buffer-field[vI]:buffer-value = integer(myResultObj:GetCharacter(pBuff:buffer-field[vI]:name)) no-error .
                          end.
                        when "int64" then
                          do:
                            pBuff:buffer-field[vI]:buffer-value = int64(myResultObj:GetCharacter(pBuff:buffer-field[vI]:name)) no-error .
                          end.
                        when "decimal" then
                          do:
                            pBuff:buffer-field[vI]:buffer-value = decimal(myResultObj:GetCharacter(pBuff:buffer-field[vI]:name)) no-error .
                          end.
                        when "logical" then
                          do:
                            pBuff:buffer-field[vI]:buffer-value = logical(myResultObj:GetCharacter(pBuff:buffer-field[vI]:name)) no-error .
                          end.
                        when "date" then
                          do:
                            pBuff:buffer-field[vI]:buffer-value = date(myResultObj:GetCharacter(pBuff:buffer-field[vI]:name)) no-error .
                          end.
                      end.
                    end.
                  end.
                end method .
                method public logical chek_price():
                  define variable v-has-records as logical no-undo.
                  for each ub.price-doc no-lock where ub.price-doc.obj-type = v-cntxt-obj-type
                    and ub.price-doc.obj-code = v-cntxt-obj-code :
                    v-has-records = true .
                    leave.
                  end.
                  for each ub.price-list no-lock where ub.price-list.obj-type = v-cntxt-obj-type
                    and ub.price-list.obj-code = v-cntxt-obj-code :
                    v-has-records = true .
                    leave.
                  end.
                  return v-has-records.
                end method.
                method public void load_gds_maping(ifile-path as character ):
                  define variable v-line    as character no-undo.
                  define variable v-err-msg as character no-undo.
                  file-info:file-name = ifile-path .
                  if file-info:file-type = ? then
                  do :
                    v-err-msg = substitute("Отсутствует файл соответствия товаров &1", ifile-path) .
                    message v-err-msg
                      view-as alert-box.
                    undo, throw new Progress.Lang.AppError (v-err-msg) .
                  end .
                  empty temp-table tt-gds-mapping .
                  input from value(ifile-path) .
                  repeat:
                    import unformatted v-line.
                    create tt-gds-mapping .
                    assign
                      tt-gds-mapping.gds-code15 = integer(trim(entry(1, v-line, ";")))
                      tt-gds-mapping.gds-code16 = integer(trim(entry(2, v-line, ";"))) no-error .
                    if error-status:error then leave .
                  end.
                end method.
                method public void  load_price (ifile-path as character ):
                  load_price (maddr,ifile-path ).
                end method .
                method public void  load_price (iAddr as character,ifile-path as character ):
                  define variable vFlag as logical no-undo.
                  load_gds_maping(ifile-path).
                  put-log(string (now) + "   Отправляем запрос для получения цен...").
                  define variable vcmd       as character no-undo.
                  define variable num-rec-ok as integer   no-undo .
                  define variable ii         as integer   no-undo initial 0 .
                  define variable jj         as integer   no-undo initial 0 .
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetPrice >&3", search ("exe/curl.exe"), iaddr, "price-temp.json").
                  os-command silent value (vcmd).
                  put-log(string (now) + "   Разбираем полученные данные...").
                  fix-codepage_and_SetJsonObj(input "price-temp.json") .
                  empty temp-table tt-gds-price.
                  parse-json(input temp-table tt-gds-price:default-buffer-handle, input "tt-gds-price") .
                  create temp-price-doc .
                  assign
                    temp-price-doc.doc-date = today
                    temp-price-doc.doc-num  = 1
                    temp-price-doc.line-num = 1
                    temp-price-doc.obj-code = v-cntxt-obj-code
                    temp-price-doc.obj-type = v-cntxt-obj-type
                    temp-price-doc.doc-id   = "_"
                    .
                  put-log( string (now) +  "    Начинаем загрузку цен...").
                  for each tt-gds-price no-lock :
                    find first tt-gds-mapping no-lock where tt-gds-mapping.gds-code15 = tt-gds-price.gds-code no-error .
                    if available tt-gds-mapping
                      then
                    do :
                      if tt-gds-mapping.gds-code15 = 0 or tt-gds-mapping.gds-code15 = ?
                        or tt-gds-mapping.gds-code16 = 0 or tt-gds-mapping.gds-code16 = ?
                        then next .
                      find first ub.goods no-lock where ub.goods.gds-code = tt-gds-mapping.gds-code16 no-error.
                      if available ub.goods
                        then
                      do :
                        create temp-price-list.
                        assign
                          temp-price-list.doc-num    = 1
                          temp-price-list.line-num   = 1
                          temp-price-list.gds-code   = tt-gds-mapping.gds-code16
                          temp-price-list.price-sale = tt-gds-price.price
                          .
                        put-log(
                          "Код в " + string(version-name) + " " +  string(tt-gds-price.gds-code) + " .Код в 16.0 " +  string(tt-gds-mapping.gds-code16) +
                          " . Цена: " + string(tt-gds-price.price)) .
                      end.
                      else
                      do :
                        ii = ii + 1 .
                        put-err-log(
                          "Не найден товар с кодом " + string(tt-gds-mapping.gds-code16) + " .Код в " + string(version-name) + " " + string(tt-gds-price.gds-code) +
                          " . Цена: " + string(tt-gds-price.price) ).
                      end.
                    end.
                    else
                    do :
                      jj = jj + 1 .
                      put-err-log(
                        "В файле соответствия " + ifile-path + " нет данных по товару с кодом " + string(tt-gds-price.gds-code) +
                        " . Цена: " + string(tt-gds-price.price)).
                    end.
                  end.
                  run utl/ora-i301-draw-util.p (
                    input parparentproc, //this-procedure ,
                    input this-object , //this-procedure ,
                    input table temp-price-doc ,
                    input table temp-price-list ,
                    output num-rec-ok
                    ) no-error .
                  if error-status:error
                    then
                  do :
                    put-Log(return-value).
                    undo, return error return-value.
                  end.
                  if ii > 0 or jj > 0
                    then
                  do :
                    put-log( substitute("Всего отвергнуто &1 записей при загрузке цен. Из них:",ii )).
                    put-log( substitute("  нет соответствий по товарам &1", ii )).
                    put-log( substitute("В файле соотвествия нет данных по &1 товаров.",jj)) .
                  end.
                  vflag  = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("price-temp.json") .
                      os-delete value("price.json") .
                    end.
                    if vflag and chek_price() then
                      put-log( string( now) + "   Цены загружены!") .
                    else
                      put-log( string( now) + "   Цены  не загружены!") .
                    put-log("").
                  end finally.
                end method .
                method public logical chek_user():
                  define variable v-has-records as logical no-undo.
                  v-has-records = can-find (first ub.user-login where ub.user-login.user-login <> "адм" and ub.user-login.user-login <> "sysadm"  ).
                  return v-has-records .
                end method.
                method public logical load_user ( ) :
                  load_user(mAddr).
                end method.
                method public void load_user(iAddr as character ) :
                  define variable v-rid     as recid     no-undo .
                  define variable vcmd      as character no-undo.
                  define variable vFlag     as logical   no-undo.
                  define variable v-user-id as character no-undo .
                  empty temp-table tt-user-account.
                  empty temp-table tt-user-login.
                  empty temp-table tt-user-host.
                  empty temp-table tt-user-obj.
                  empty temp-table tt-user-menu-group.
                  define buffer buf_user-login      for ub.user-login .
                  define buffer buf_user-host       for ub.user-host .
                  define buffer buf_user-obj        for ub.user-obj .
                  define buffer buf_user-menu-group for ub.user-menu-group .
                  define buffer buf_user-account    for ub.user-account .
                  define buffer buf_tt-user-login   for tt-user-login .
                  define buffer bf_tt-user-login    for tt-user-login .
                  put-log(string (now) + "   Отправляем запрос для получения пользователей...").
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetUser >&3", search ("exe/curl.exe"), iAddr, "user-temp.json").
                  os-command silent value (vcmd).
                  put-log(string (now) + "   Разбираем полученные данные...").
                  fix-codepage_and_SetJsonObj (input "user-temp.json") .
                  parse-json(input temp-table tt-user-account:default-buffer-handle, input "user-account") .
                  parse-json(input temp-table tt-user-login:default-buffer-handle, input "user-login") .
                  parse-json(input temp-table tt-user-host:default-buffer-handle, input "user-host") .
                  parse-json(input temp-table tt-user-obj:default-buffer-handle, input "user-obj") .
                  parse-json(input temp-table tt-user-menu-group:default-buffer-handle, input "user-menu-group") .
                  put-log( string(now) + "   Начинаем загрузку пользователей...") .
                  user_:
                  for each tt-user-account where tt-user-account.status_ = 0 exclusive-lock,
                    first buf_tt-user-login where buf_tt-user-login.user-id = tt-user-account.user-id:
                    put-log(  "Пользователь " + string(tt-user-account.user-id) ).
                    find first buf_user-account exclusive-lock where buf_user-account.user-id = tt-user-account.user-id no-error .
                    if available (buf_user-account) then
                    do:
                      next user_ .
                    end.
                    for each tt-user-login no-lock where tt-user-login.user-id = tt-user-account.user-id and tt-user-login.status_ = 0:
                      find first bf_tt-user-login where bf_tt-user-login.user-id = tt-user-login.user-id and bf_tt-user-login.user-login = "адм" no-error .
                      if available (bf_tt-user-login) then
                      do:
                        next user_ .
                      end.
                      else
                      do:
                        run str/usracc01.p (
                          input 'ДОБАВЛЕНИЕ':U
                          , input v-cntxt-db-num
                          , input "":U
                          , input tt-user-account.last-name
                          , input tt-user-account.first-name
                          , input tt-user-account.second-name
                          , input tt-user-account.nik
                          , input tt-user-account.phone-number
                          , input tt-user-account.mobile-phone-number
                          , input tt-user-account.company
                          , input tt-user-account.department
                          , input tt-user-account.position
                          , input tt-user-account.room
                          , input tt-user-account.e-mail
                          , input tt-user-account.internal-phone-number
                          , input tt-user-account.PS
                          , input tt-user-account.psn-code
                          , input no
                          , output v-user-id
                          ) no-error.
                        if error-status :error
                          then
                        do:
                          put-Log(return-value).
                        end.
                        create buf_user-login .
                        buffer-copy tt-user-login except tt-user-login.user-id tt-user-login.db-num to buf_user-login .
                        assign
                          buf_user-login.user-id = v-user-id
                          buf_user-login.db-num  = v-cntxt-db-num
                          .
                      end.
                    end.
                    for each tt-user-host no-lock where tt-user-host.user-id = tt-user-account.user-id:
                      create buf_user-host .
                      assign
                        buf_user-host.user-id         = v-user-id
                        buf_user-host.host-code       = v-host-code
                        buf_user-host.db-num          = v-cntxt-db-num
                        buf_user-host.whole-send-news = tt-user-host.whole-send-news
                        .
                    end.
                    for each tt-user-obj no-lock where tt-user-obj.user-id = tt-user-account.user-id:
                      create buf_user-obj .
                      assign
                        buf_user-obj.user-id         = v-user-id
                        buf_user-obj.db-num          = v-cntxt-db-num
                        buf_user-obj.obj-type        = v-cntxt-obj-type
                        buf_user-obj.obj-code        = v-cntxt-obj-code
                        buf_user-obj.host-code       = v-host-code
                        buf_user-obj.whole-send-news = tt-user-obj.whole-send-news
                        .
                    end.
                    for each tt-user-menu-group no-lock where tt-user-menu-group.user-id = tt-user-account.user-id,
                      first ub.menu-group where ub.menu-group.menu-group-id = tt-user-menu-group.menu-group-id and ub.menu-group.menu-code = tt-user-menu-group.menu-code:
                      create buf_user-menu-group .
                      assign
                        buf_user-menu-group.db-num               = v-cntxt-db-num
                        buf_user-menu-group.menu-code            = ub.menu-group.menu-code
                        buf_user-menu-group.menu-group-code      = ub.menu-group.menu-group-code
                        buf_user-menu-group.menu-group-context   = tt-user-menu-group.menu-group-context
                        buf_user-menu-group.menu-group-id        = ub.menu-group.menu-group-id
                        buf_user-menu-group.user-id              = v-user-id
                        buf_user-menu-group.host-code            = v-host-code
                        buf_user-menu-group.obj-code             = v-cntxt-obj-code
                        buf_user-menu-group.obj-type             = v-cntxt-obj-type
                        buf_user-menu-group.user-menu-group-code = next-value(s-user-menu-group)
                        .
                    end.
                  end.
                  vflag  = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("user-temp.json") .
                      os-delete value("user.json") .
                    end.
                    if vflag and chek_user() then
                      put-log( string(now) + "   Пользователи загружены!") .
                    else
                      put-log( string(now) + "   Пользователи не загружены!") .
                  end finally.
                end method.
                method public void fix-codepage_and_SetJsonObj (p-file as character):
                  define variable vline      as char      no-undo .
                  define variable vline2     as char      no-undo .
                  define variable v-out-file as character no-undo .
                  case p-file :
                    when "schem-temp.json"       then
                      v-out-file = "schem.json" .
                    when "pumpdoc-temp.json"     then
                      v-out-file = "pumpdoc.json" .
                    when "cashdesk-temp.json"    then
                      v-out-file = "cashdesk.json" .
                    when "price-temp.json"       then
                      v-out-file = "price.json" .
                    when "rest-temp.json"        then
                      v-out-file = "rest.json" .
                    when "rest-ptrl-temp.json"   then
                      v-out-file = "rest-ptrl.json" .
                    when "verify-rest-temp.json" then
                      v-out-file = "verify-rest.json" .
                    when "rvs-temp.json"         then
                      v-out-file = "rvs.json" .
                    when "cashp-temp.json"       then
                      v-out-file = "cashp.json" .
                    when "user-temp.json"        then
                      v-out-file = "user.json" .
                    when "fbrgds-temp.json"  then
                      v-out-file = "fbrgds.json" .
                    when "rest-fin-temp.json"    then
                      v-out-file = "restfin.json" .
                    when "version-temp.json" then
                      v-out-file = "version.json" .
                  end case.
                  input STREAM lsIN from value(search(p-file)) convert target "UTF-8" source "1251".
                  output STREAM lsOUT to value(v-out-file).
                  repeat:
                    vline2 = vline.
                    import stream lsIN unformatted vline.
                    vLine = replace(vline, chr(4), "|") .
                    if vline2 = vline and length(vline2) < 3 then leave.
                    put stream lsOUT unformatted  vline skip .
                  end.
                  input STREAM lsIN close.
                  output STREAM lsOUT close.
                  delete object mJsonObj no-error.
                  mJsonObj = cast(mParser:ParseFile(search(v-out-file)), JsonObject) no-error.
                  if error-status:error
                    then
                  do:
                    put-log("Данные не получены либо содержат ошибку в формате.").
                    return error "Данные не получены либо содержат ошибку в формате.".
                  end.
                end method.
                method public logical chek_pumpdoc ():
                  define variable v-has-records as logical no-undo.
                  for each ub.icnt-doc no-lock where ub.icnt-doc.obj-type = v-cntxt-obj-type
                    and ub.icnt-doc.obj-code = v-cntxt-obj-code :
                    v-has-records = true .
                    leave.
                  end.
                  for each ub.icnt-line no-lock where ub.icnt-line.obj-type = v-cntxt-obj-type
                    and ub.icnt-line.obj-code = v-cntxt-obj-code :
                    v-has-records = true .
                    leave.
                  end.
                  return v-has-records.
                end method.
                method public void load_pumpdoc (ifile-path as character ) :
                  load_pumpdoc (maddr, ifile-path ).
                end.
                method public void load_pumpdoc (iaddr as character, ifile-path as character ) :
                  define variable v-doc-code as character no-undo .
                  define variable v-recid    as recid     no-undo .
                  define variable vcmd       as character no-undo.
                  define variable vFlag      as logical   no-undo.
                  put-log(string (now) + "   Отправляем запрос для получения инвентаризации счётчиков ТРК...").
                  load_gds_maping(ifile-path).
                  empty temp-table tt-gds-prod .
                  empty temp-table tt-place-loc .
                  empty temp-table tt-icnt-doc.
                  empty temp-table tt-icnt-line.
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetPumpDoc >&3", search ("exe/curl.exe"), iaddr, "pumpdoc-temp.json").
                  os-command silent value (vcmd).
                  put-log(string (now) + "   Разбираем полученные данные...").
                  fix-codepage_and_SetJsonObj(input "pumpdoc-temp.json") .
                  parse-json(input temp-table tt-icnt-doc:default-buffer-handle, input "icnt-doc") .
                  parse-json(input temp-table tt-icnt-line:default-buffer-handle, input "icnt-line") .
                  parse-json(input temp-table tt-gds-prod:default-buffer-handle, input "tt-gds-prod") .
                  parse-json(input temp-table tt-place-loc:default-buffer-handle, input "tt-place-loc") .
                  put-log(string( now) + "   Начинаем загрузку инвентаризации счётчиков ТРК...") .
                  for each tt-icnt-doc no-lock :
                    put-log( "Номер документа в " + string(version-name) +  "   " + tt-icnt-doc.doc-code).
                    for each tt-icnt-line exclusive-lock where tt-icnt-line.doc-code = tt-icnt-doc.doc-code :
                      find first tt-gds-mapping no-lock where tt-gds-mapping.gds-code15 = tt-icnt-line.gds-code no-error .
                      if not available tt-gds-mapping
                        then
                      do :
                        put-log(("В файле соответсвий нет топлива " + string(tt-icnt-line.gds-code))).
                        undo, return error ("В файле соответсвий нет топлива " + string(tt-icnt-line.gds-code)) .
                      end.
                      find first ub.goods no-lock where ub.goods.gds-code = tt-gds-mapping.gds-code16 no-error.
                      if not available ub.goods
                        then
                      do :
                        put-log(("Нет топлива с кодом " + string(tt-gds-mapping.gds-code16) + " . Код в v" + string(version-name) +  " - " + string(tt-gds-mapping.gds-code15)) ).
                        undo, return error ("Нет топлива с кодом " + string(tt-gds-mapping.gds-code16) + " . Код в v" + string(version-name) +  " - " + string(tt-gds-mapping.gds-code15)) .
                      end.
                      find first tt-place-loc no-lock where tt-place-loc.pl-code = tt-icnt-line.pl-code no-error.
                      if not available tt-place-loc
                        then
                      do :
                        put-log(substitute ("Не найдено место хранения с кодом &1 в переданных данных",tt-icnt-line.pl-code )).
                        undo, return error "No place-loc" .
                      end.
                      find first ub.place no-lock where ub.place.loc1 = tt-place-loc.loc1 no-error.
                      if not available ub.place
                        then
                      do :
                        put-log(substitute ("Не найдено место хранения с коротким кодом &1",tt-place-loc.loc1)).
                        undo, return error "No place" .
                      end.
                      assign
                        tt-icnt-line.obj-code = v-cntxt-obj-code
                        tt-icnt-line.obj-type = v-cntxt-obj-type
                        tt-icnt-line.gds-code = tt-gds-mapping.gds-code16
                        tt-icnt-line.pl-code  = ub.place.pl-code
                        .
                    end.
                    run str/icntdoc1.p (
                      input 'ДОБАВЛЕНИЕ':U
                      ,input yes
                      ,input-output v-recid
                      ,input ""
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input v-cntxt-host-code-obj
                      ,input 'инв-сч-трк':U
                      ,input 'ip':U
                      ,input tt-icnt-doc.wrkr
                      ,input tt-icnt-doc.agnt
                      ,input tt-icnt-doc.boss
                      ,input tt-icnt-doc.doc-date
                      ,input tt-icnt-doc.meas-el-cnt
                      ,input tt-icnt-doc.state-el-cnt
                      ,input tt-icnt-doc.state-mh-cnt
                      ,input tt-icnt-doc.PS
                      ,input tt-icnt-doc.creid
                      ,input '':U
                      ,input table tt-icnt-line
                      ) no-error.
                    if error-status:error then
                    do:
                      put-log(return-value).
                      undo, return error return-value.
                    end.
                    run str/icntdoc2.p ( input v-recid
                      ,input yes
                      ) no-error.
                    if error-status:error then
                    do:
                      put-log(return-value).
                      undo, return error return-value.
                    end.
                  end.
                  vflag  = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("pumpdoc-temp.json") .
                      os-delete value("pumpdoc.json") .
                    end.
                    if vflag and chek_pumpdoc() then
                      put-log( string( now) +  "   Инвентаризация счётчиков ТРК загружена!" ) .
                    else
                      put-log( string( now) +  "   Инвентаризация счётчиков ТРК не загружена!" ) .
                    put-log("").
                  end finally.
                end method.
                method public logical chek-sht-open():
                  define buffer open-shift for ub.shift-obj .
                  find last open-shift where
                    open-shift.obj-type = v-cntxt-obj-type and
                    open-shift.obj-code = v-cntxt-obj-code and
                    open-shift.status_ = 'тек':U
                    use-index pi no-error.
                  return  available open-shift.
                end method.
                method public void  sht-open(): // открытие смены
                  define variable vOk as logical no-undo.
                  put-log("Открытие смены").
                  run gbl/sht-open-bach.p (this-object,output vOk,parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ).
                  put-log(if chek-sht-open() then "Смены открыта" else "Смена не открыта").
                end method.
                method public logical chek_rvs():
                  define buffer open-shift  for ub.shift-obj .
                  define buffer buf_rvs-doc for ub.rvs-doc .
                  find last open-shift where
                    open-shift.obj-type = v-cntxt-obj-type and
                    open-shift.obj-code = v-cntxt-obj-code and
                    open-shift.status_ = 'тек':U
                    use-index pi no-error.
                  if available open-shift
                    then
                    find first  buf_rvs-doc where buf_rvs-doc.obj-type eq v-cntxt-obj-type
                      and buf_rvs-doc.obj-code eq v-cntxt-obj-code
                      and buf_rvs-doc.shift-date eq open-shift.shift-date
                      and buf_rvs-doc.shift-num  eq open-shift.shift-num
                      no-lock no-error.
                  return  available buf_rvs-doc.
                end method.
                method public void  rvs-auto(): // содание сверки
                  define variable vOk as logical no-undo.
                  put-log("Создание нулевой сверки").
                  run str/rvs-auto-draw.p (this-object).
                  put-log(if chek_rvs() then "Нулевая сверка создана" else "Нулевая сверка не создана").
                  put-log("").
                end method.
                method public logical load_rest (
                  iosn-fname   as character,  // список соответствия поставщиков
                  iart-fname   as  character, // список соответствия товаров
                  iretry-fname as character   // файл для повторного импорта
                  ):
                  return load_rest(maddr, iosn-fname, iart-fname, iretry-fname).
                end method.
                method public logical load_rest (iaddr as character,
                  iosn-fname   as character,  // список соответствия поставщиков
                  iart-fname   as  character, // список соответствия товаров
                  iretry-fname as character   // файл для повторного импорта
                  ):
                  define variable vcmd as character no-undo.
                  define variable vOk  as logical   no-undo.
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetRest >&3", search ("exe/curl.exe"), iaddr, "rest-temp.json").
                  os-command silent value (vcmd).
                  fix-codepage_and_SetJsonObj (input "rest-temp.json") .
                  empty temp-table tt-imp-parts.
                  parse-json(input temp-table tt-imp-parts:default-buffer-handle, input "tt-imp-parts") .
                  delete object mJsonObj no-error.
                  put-log ( string(now) +  "   Начинаем загрузку остатков...") .
                  define variable v-count-err as integer no-undo .
                  run utl/imp-doc4cr-draw.p ( this-object
                    , iosn-fname // список соответствия поставщиков
                    , iart-fname // список соответствия товаров
                    , iretry-fname // файл для повторного импорта
                    , input table tt-imp-parts
                    ) .
                  vok = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("rest-temp.json") .
                      os-delete value("rest.json") .
                    end.
                    vok = chek_rest() and vok.
                    put-log( string( now) + if  vok then "   Остатки по товарам загружены!" else "   Остатки по товарам не загружены!") .
                    put-log("").
                    return vok.
                  end finally.
                end method .
                method public logical load_rest_ptrl (
                  iosn-fname   as character,  // список соответствия поставщиков
                  iart-fname   as  character, // список соответствия товаров
                  iretry-fname as character   // файл для повторного импорта
                  ):
                  return load_rest_ptrl (maddr, iosn-fname, iart-fname, iretry-fname).
                end method.
                method public logical load_rest_ptrl (iaddr as character,
                  iosn-fname   as character,  // список соответствия поставщиков
                  iart-fname   as  character, // список соответствия товаров
                  iretry-fname as character   // файл для повторного импорта
                  ):
                  define variable vcmd as character no-undo.
                  define variable vOk  as logical   no-undo.
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetRestPtrl >&3", search ("exe/curl.exe"), iaddr, "rest-ptrl-temp.json").
                  os-command silent value (vcmd).
                  fix-codepage_and_SetJsonObj (input "rest-ptrl-temp.json") .
                  empty temp-table tt-imp-parts-ptrl.
                  parse-json(input temp-table tt-imp-parts-ptrl:default-buffer-handle, input "tt-imp-parts-ptrl") .
                  put-log ( string(now) +  "   Начинаем загрузку остатков по топливу...") .
                  define variable v-count-err as integer no-undo .
                  run utl/imp-doc4cr-draw-ptrl.p ( this-object
                    , iosn-fname // список соответствия поставщиков
                    , iart-fname // список соответствия товаров
                    , iretry-fname // файл для повторного импорта
                    , input table tt-imp-parts-ptrl
                    ) .
// ?? Журналировать каждую загруженную строку ??
//        put stream log-stream unformatted
//          "Код в 15.0 " string(tt-gds-price.gds-code) " .Код в 16.0 " string(tt-gds-mapping.gds-code16)
//          " . Цена: " string(tt-gds-price.price) skip .
//  &scop my-message substitute("Всего прочитано &1 записей. Из них отвергнуто &2", v-count-all, v-count-err )
//  {&display-message}.
                  vok = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("rest-ptrl-temp.json") .
                      os-delete value("rest-ptrl.json") .
                    end.
                    vok = chek_rest_ptrl() and vok.
                    put-log( string( now) + if  vok then "   Остатки по топливу загружены!" else "   Остатки по топливу не загружены!") .
                    put-log("").
                    return vok.
                  end finally.
                end method .
                method public logical verify_rest (ifile-path as character):
                  return verify_rest(mAddr,ifile-path).
                end  method.
                method public logical verify_rest (iAddr as character, ifile-path as character) :
                  define variable vcmd              as character no-undo.
                  define variable vok               as logical   no-undo.
                  define variable v-count-confirm   as integer   no-undo .
                  define variable v-count-decline   as integer   no-undo .
                  define variable v-count-mismatch  as integer   no-undo .
                  define variable v-logfile-gd      as character no-undo .
                  define variable v-logfile-fu      as character no-undo .
                  define variable v-logfile-rj      as character no-undo .
                  define variable v-err-message     as character no-undo .
                  define variable v-today           as date      no-undo .
                  define variable v-fact-qnty16     as decimal   no-undo .
                  define variable v-sum-rubl-cost16 as decimal   no-undo .
                  define variable v-vat-rubl16      as decimal   no-undo .
                  define variable v-sum-rubl-crsa16 as decimal   no-undo .
                  define variable v-fact-qnty-lt16  as decimal   no-undo .
                  define variable v-fact-qnty-kg16  as decimal   no-undo .
                  define variable v-vat-rubl-delta  as decimal   no-undo .
                  define variable v-sum-rubl-delta  as decimal   no-undo .
                  define buffer buf_pl-gds   for ub.pl-gds .
                  define buffer buf_stk-line for ub.stk-line .
                  define buffer buf_goods    for ub.goods .
                  put-log(string (now) + "   Расчет архивов перед сравнением остатков...").
                  define variable v-date-start as date      no-undo .
                  define variable v-date-end   as date      no-undo .
                  define variable v-archive-ok as logical   no-undo .
                  define variable v-comment    as character no-undo .
                  define variable v-can-print  as logical   no-undo .
                  assign
                    v-today      = today
                    v-date-start = v-today
                    v-date-end   = v-today
                    .
                  run rep/chk-ahz.p
                    (input Obj-type
                    ,input Obj-code
                    ,input false
                    ,input true
                    ,input false
                    ,input false
                    ,input false
                    ,input 0
                    ,input ""
                    ,input-output v-date-start
                    ,input-output v-date-end
                    ,output       v-archive-ok
                    ,output       v-comment
                    ,output       v-can-print
                    ) .
                  load_version (iaddr).
                  put-log(string (now) + "   Отправляем запрос для сравнения остатков...").
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?VerifyRest >&3", search ("exe/curl.exe"), iaddr, "verify-rest-temp.json").
                  os-command silent value (vcmd).
                  put-log(string (now) + "   Разбираем полученные данные...").
                  fix-codepage_and_SetJsonObj(input "verify-rest-temp.json") .
                  empty temp-table tt-stk-gd .
                  parse-json(input temp-table tt-stk-gd:default-buffer-handle, input "tt-stk-gd") .
                  empty temp-table tt-stk-fu .
                  parse-json(input temp-table tt-stk-fu:default-buffer-handle, input "tt-stk-fu") .
                  load_gds_maping(ifile-path).
                  assign
                    v-logfile-gd    = substitute("&1darw_util_verified_good.log", ibs.th.gbl.gbl-inipar:logDir)
                    v-logfile-fu    = substitute("&1darw_util_verified_fuel.log", ibs.th.gbl.gbl-inipar:logDir)
                    v-logfile-rj    = substitute("&1darw_util_rest_mismatch.log", ibs.th.gbl.gbl-inipar:logDir)
                    v-count-confirm = 0
                    v-count-decline = 0
                    .
                  put-log(string( now) + "   Начинаем сравнение остатков...") .
                  empty temp-table tt-stk-fu2 .
                  for each tt-stk-fu:
                    find first tt-gds-mapping where tt-gds-mapping.gds-code15 = tt-stk-fu.gds-code no-error .
                    if not available tt-gds-mapping then
                    do :
                      v-count-decline = v-count-decline + 1 .
                      v-err-message = substitute("В файле соответствия отсутствует топливо &1", tt-stk-fu.gds-code) .
                      put-log(v-err-message).
                      next .
                    end.
                    assign
                      v-fact-qnty-lt16 = 0
                      v-fact-qnty-kg16 = 0
                      .
                    for each buf_pl-gds no-lock
                      where buf_pl-gds.gds-code = tt-gds-mapping.gds-code16
                      and buf_pl-gds.obj-type = Obj-type
                      and buf_pl-gds.obj-code = Obj-code :
                      assign
                        v-fact-qnty-lt16 = v-fact-qnty-lt16 + buf_pl-gds.fact-qnty
                        v-fact-qnty-kg16 = v-fact-qnty-kg16 + buf_pl-gds.cli-fact-qnty
                        .
                    end .
                    find first tt-stk-fu2 where tt-stk-fu2.gds-code16 = tt-gds-mapping.gds-code16 no-error .
                    if available tt-stk-fu2 then
                    do :
                      assign
                        tt-stk-fu2.fact-qnty-lt16 = tt-stk-fu2.fact-qnty-lt16 + v-fact-qnty-lt16
                        tt-stk-fu2.fact-qnty-kg16 = tt-stk-fu2.fact-qnty-kg16 + v-fact-qnty-kg16
                        v-count-confirm           = v-count-confirm + 1
      no-error .
                    end .
                    else
                    do :
                      create tt-stk-fu2 .
                      buffer-copy tt-stk-fu to tt-stk-fu2 assign
                        tt-stk-fu2.gds-code16     = tt-gds-mapping.gds-code16
                        tt-stk-fu2.fact-qnty-lt16 = v-fact-qnty-lt16
                        tt-stk-fu2.fact-qnty-kg16 = v-fact-qnty-kg16
                        v-count-confirm = v-count-confirm + 1
      no-error .
                    end .
                  end .
                  empty temp-table tt-stk-gd2 .
                  for each tt-stk-gd:
                    find first tt-gds-mapping where tt-gds-mapping.gds-code15 = integer(tt-stk-gd.gds-code) no-error .
                    if not available tt-gds-mapping then
                    do :
                      v-count-decline = v-count-decline + 1 .
                      v-err-message = substitute("В файле соответствия отсутствует товар &1", tt-stk-gd.gds-code) .
                      put-log(v-err-message).
                      next .
                    end.
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-mapping.gds-code16 no-error .
                    if not available buf_goods then
                    do :
                      v-count-decline = v-count-decline + 1 .
                      v-err-message = substitute( "В справочнике товаров отсутствует товар &1. Код в v&3 - &2"
                        , tt-gds-mapping.gds-code16, tt-gds-mapping.gds-code15, version-name ) .
                      put-log(v-err-message).
                      next .
                    end.
                    assign
                      v-fact-qnty16     = 0
                      v-sum-rubl-cost16 = 0
                      v-vat-rubl16      = 0
                      v-sum-rubl-crsa16 = 0
                      .
                    find last buf_stk-line no-lock
                      where buf_stk-line.obj-type   = Obj-type
                      and buf_stk-line.obj-code   = Obj-code
                      and buf_stk-line.artic      = buf_goods.artic
                      and buf_stk-line.prod-type  = buf_goods.prod-type
                      and buf_stk-line.prod-code  = buf_goods.prod-code
                      and buf_stk-line.sum-type   = 'cost':U
                      and buf_stk-line.cat-id     = '##,##':U
                      and buf_stk-line.fact-date <= v-today
                      use-index category no-error.
                    if available buf_stk-line then assign
                        v-fact-qnty16     = buf_stk-line.fact-qnty
                        v-sum-rubl-cost16 = buf_stk-line.sum-rubl
                        v-vat-rubl16      = buf_stk-line.VAT-rubl
                        .
                    find last buf_stk-line no-lock
                      where buf_stk-line.obj-type   = Obj-type
                      and buf_stk-line.obj-code   = Obj-code
                      and buf_stk-line.artic      = buf_goods.artic
                      and buf_stk-line.prod-type  = buf_goods.prod-type
                      and buf_stk-line.prod-code  = buf_goods.prod-code
                      and buf_stk-line.sum-type   = 'crsa':U
                      and buf_stk-line.cat-id     = '##,##':U
                      and buf_stk-line.fact-date <= v-today
                      use-index category no-error.
                    if available buf_stk-line then assign
                        v-fact-qnty16     = buf_stk-line.fact-qnty when v-fact-qnty16 = 0
                        v-sum-rubl-crsa16 = buf_stk-line.sum-rubl
                        .
                    find first tt-stk-gd2 where tt-stk-gd2.gds-code16 = tt-gds-mapping.gds-code16 no-error .
                    if not available tt-stk-gd2 then
                    do :
                      create tt-stk-gd2 .
                      buffer-copy tt-stk-gd to tt-stk-gd2
                        assign
                        tt-stk-gd2.gds-code16      = tt-gds-mapping.gds-code16
                        tt-stk-gd2.fact-qnty16     = v-fact-qnty16
                        tt-stk-gd2.sum-rubl-cost16 = v-sum-rubl-cost16
                        tt-stk-gd2.vat-rubl16      = v-vat-rubl16
                        tt-stk-gd2.sum-rubl-crsa16 = v-sum-rubl-crsa16
                        tt-stk-gd2.gds-code15 = string(tt-stk-gd.gds-code)
                        tt-stk-gd2.gds-name = buf_goods.gds-name
                        v-count-confirm = v-count-confirm + 1
                        no-error .
                    end .
                    else
                    do:
                      assign
                        tt-stk-gd2.gds-code15      = string(tt-stk-gd2.gds-code15) + ", " + string(tt-stk-gd.gds-code)
                        tt-stk-gd2.fact-qnty16     = v-fact-qnty16
                        tt-stk-gd2.sum-rubl-cost16 = v-sum-rubl-cost16
                        tt-stk-gd2.vat-rubl16      = v-vat-rubl16
                        tt-stk-gd2.sum-rubl-crsa16 = v-sum-rubl-crsa16
                        tt-stk-gd2.fact-qnty       = tt-stk-gd2.fact-qnty + tt-stk-gd.fact-qnty
                        tt-stk-gd2.sum-rubl-cost   = tt-stk-gd2.sum-rubl-cost + tt-stk-gd.sum-rubl-cost
                        tt-stk-gd2.vat-rubl        = tt-stk-gd2.vat-rubl + tt-stk-gd.vat-rubl
                        tt-stk-gd2.sum-rubl-crsa   = tt-stk-gd2.sum-rubl-crsa + tt-stk-gd.sum-rubl-crsa
                        v-count-confirm            = v-count-confirm + 1
                        .
                    end.
                    tt-stk-gd2.gds-code15 = trim(tt-stk-gd2.gds-code15,",").
                  end .
                  v-count-mismatch = 0 .
                  define variable vFirst as logical no-undo.
                  output STREAM lsOut to value(v-logfile-rj).
                  output STREAM lsIN  to value(v-logfile-gd).
                  put stream lsIn unformatted
                    "наименование товара в 16.0;"
                    "код товара в " + string(version-name) +  ";"
                    "количество в " + string(version-name) +  ";"
                    "сумма в учетных ценах в " + string(version-name) +  ";"
                    "сумма НДС в учетных ценах в " + string(version-name) +  ";"
                    "сумма в продажных ценах в " + string(version-name) +  ";"
                    "код товара в 16.0;"
                    "количество в 16.0;"
                    "сумма в учетных ценах в 16.0;"
                    "сумма НДС в учетных ценах в 16.0;"
                    "сумма в продажных ценах в 16.0" skip
                    .
                  Vfirst = yes.
                  put stream lsOut unformatted skip
                    "Расхождения по товарам:" skip.
                  for each tt-stk-gd2:
                    export stream lsIN delimiter ';':U tt-stk-gd2 .
                    assign
                      v-sum-rubl-delta = truncate(tt-stk-gd2.sum-rubl-cost16 - tt-stk-gd2.sum-rubl-cost, 4)
                      v-vat-rubl-delta = truncate(tt-stk-gd2.vat-rubl16      - tt-stk-gd2.vat-rubl,      4)
                      .
                    if (tt-stk-gd2.fact-qnty16     <> tt-stk-gd2.fact-qnty)
                      or (v-sum-rubl-delta <> 0)
                      or (v-vat-rubl-delta <> 0)
                      or (tt-stk-gd2.sum-rubl-crsa16 <> tt-stk-gd2.sum-rubl-crsa)
                      then
                    do :
                      if vFirst
                        then
                      do:
                        vfirst = no.
                        put stream lsOut unformatted
                          "наименование товара в 16.0;"
                          "код товара в " + string(version-name) +  ";"
                          "количество в " + string(version-name) +  ";"
                          "сумма в учетных ценах в " + string(version-name) +  ";"
                          "сумма НДС в учетных ценах в " + string(version-name) +  ";"
                          "сумма в продажных ценах в " + string(version-name) +  ";"
                          "код товара в 16.0;"
                          "количество в 16.0;"
                          "сумма в учетных ценах в 16.0;"
                          "сумма НДС в учетных ценах в 16.0;"
                          "сумма в продажных ценах в 16.0" skip
                          .
                      end.
                      export stream lsOut delimiter ';':U tt-stk-gd2 .
                      v-count-mismatch = v-count-mismatch + 1 .
                    end .
                  end.
                  if Vfirst
                    then
                    put stream lsOut unformatted "Расхождений не обнаружено." skip.
                  else
                    Vfirst = yes.
                  output STREAM lsIN close.
                  put stream lsOut unformatted skip
                    "Расхождения по топливу:" skip.
                  output STREAM lsIN to value(v-logfile-fu).
                  put stream lsIn unformatted
                    "наименование товара в 16.0;"
                    "код товара в " + string(version-name) +  ";"
                    "остатки в лт в " + string(version-name) +  ";"
                    "остатки в кг в " + string(version-name) +  ";"
                    "код товара в 16.0;"
                    "остатки в лт в 16.0;"
                    "остатки в кг в 16.0" skip
                    .
                  for each tt-stk-fu2:
                    export stream lsIN delimiter ';':U tt-stk-fu2 .
                    if (tt-stk-fu2.fact-qnty-lt16 <> tt-stk-fu2.fact-qnty-lt)
                      or (tt-stk-fu2.fact-qnty-kg16 <> tt-stk-fu2.fact-qnty-kg)
                      then
                    do :
                      if vfirst
                        then
                      do:
                        vfirst = no.
                        put stream lsOut unformatted
                          "наименование товара в 16.0;"
                          "код товара в " + string(version-name) +  ";"
                          "остатки в лт в " + string(version-name) +  ";"
                          "остатки в кг в " + string(version-name) +  ";"
                          "код товара в 16.0;"
                          "остатки в лт в 16.0;"
                          "остатки в кг в 16.0" skip
                          .
                      end.
                      export stream lsOut delimiter ';':U tt-stk-fu2 .
                      v-count-mismatch = v-count-mismatch + 1 .
                    end .
                  end.
                  if Vfirst
                    then
                    put stream lsOut unformatted "Расхождений не обнаружено." skip.
                  vok = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("verify-rest-temp.json") .
                      os-delete value("verify-rest.json") .
                    end.
                    output STREAM lsIN close.
                    output STREAM lsOUT close.
                    if vok then
                    do :
                      put-log( string(now) + "   Сравнение остатков выполнено." ) .
                      put-log(    substitute("   Всего в сравнении &1 записей о товарах и о топливе,", v-count-confirm + v-count-decline) ) .
                      put-log(    substitute("   из них для &1 записей найдены товары для сравнения в вер.16.0, а для &2 записей товары для сравнения в вер.16.0 отсутствуют.",
                        v-count-confirm, v-count-decline) ) .
                      put-log(    substitute("   При сравнении остатков выявлено &1 расхождений среди &2 товаров, найденных для сравнения в вер.16.", v-count-mismatch, v-count-confirm) ) .
                      put-log(    substitute("   Файл со сравнением товаров: &1",                  v-logfile-gd)     ) .
                      put-log(    substitute("   Файл со сравнением топлива: &1",                  v-logfile-fu)     ) .
                      put-log(    substitute("   Файл с расхождениями: &1",                        v-logfile-rj)     ) .
                    end .
                    else
                      put-log( string(now) + "   Сравнение остатков не выполнено!") .
                    put-log("").
                    return vok.
                  end finally.
                end method .
                method public logical load_rest_fin (
                  iosn-fname   as character,  // список соответствия поставщиков
                  iart-fname   as  character, // список соответствия товаров
                  icontr       as character,  // контрагент для ПКО РКО
                  iretry-fname as character   // файл для повторного импорта
                  ):
                  return load_rest_fin(maddr, iosn-fname, iart-fname, icontr, iretry-fname).
                end method.
                method public logical load_rest_fin (iaddr as character,
                  iosn-fname   as character,  // список соответствия поставщиков
                  iart-fname   as  character, // список соответствия товаров
                  icontr       as character,  // контрагент для ПКО РКО
                  iretry-fname as character   // файл для повторного импорта
                  ):
                  define variable vcmd              as character no-undo.
                  define variable vOk               as logical   no-undo.
                  define variable p-doc-rec         as recid     no-undo .
                  define variable mCashBook         as class     ibs.th.ref.cashbookstorage no-undo .
                  define variable p-by-cash-desk    as logical   no-undo .
                  define variable p-by-petrol-goods as logical   no-undo .
                  define variable p-by-osnovanie    as character no-undo .
                  define variable p-by-pril         as character no-undo .
                  define variable v-naznach-plat    as character no-undo .
                  define variable v-naznach-plat2   as character no-undo .
                  define variable o-uchet           as character no-undo .
                  define variable v-uchet           as character no-undo .
                  define variable v-real-obj-type   as character no-undo .
                  define variable v-real-obj-code   as integer   no-undo .
                  define variable v-limit-access    as integer   no-undo .
                  define variable v-base-code       as integer   no-undo .
                  define variable mOsnbag           as character no-undo.
                  define variable msumInc-save      as decimal   no-undo.
                  define variable mMoney            as character no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run basecode in ibs.th.gbl.gbl-hndllib:g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
                    mCashBook = new ibs.th.ref.cashbookstorage () .
                  define buffer buf_temp-fin-sum for temp-fin-sum .
                  define buffer buf_temp-tax     for temp-tax .
                  define buffer buf_fin-doc      for ub.fin-doc .
                  define buffer buf_fin-doc-tax  for ub.fin-doc-tax .
                  define buffer buf_fin-doc-attr for ub.fin-doc-attr .
                  define buffer buf_payment      for ub.payment .
                  define buffer buf_shift-obj    for ub.shift-obj.
                  empty temp-table tt-rest-fin .
                  empty temp-table temp-tax .
                  put-log(string (now) + "   Отправляем запрос для получения денежных остатков...").
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetRestFin >&3", search ("exe/curl.exe"), iaddr, "rest-fin-temp.json").
                  os-command silent value (vcmd).
                  fix-codepage_and_SetJsonObj (input "rest-fin-temp.json") .
                  parse-json(input temp-table tt-rest-fin:default-buffer-handle, input "tt-rest-fin") .
                  put-log ( string(now) +  "   Начинаем загрузку денежных остатков...") .
                  define variable v-count-err as integer no-undo .
                  find last buf_shift-obj
                    where buf_shift-obj.obj-type    = v-cntxt-obj-type
                    and buf_shift-obj.obj-code    = v-cntxt-obj-code
                    no-error.
                  for each tt-rest-fin:
                    find first ub.CashBook no-lock where ub.CashBook.id = tt-rest-fin.CashBookId no-error .
                    if not available (ub.CashBook) then next .
                    find first buf_temp-fin-sum
                      where buf_temp-fin-sum.curr-code = 0
                      and buf_temp-fin-sum.cashbookid = tt-rest-fin.CashBookId
                      and buf_temp-fin-sum.is-expense_cash = no
                      no-error.
                    if not available buf_temp-fin-sum
                      then
                    do:
                      create buf_temp-fin-sum.
                      assign
                        buf_temp-fin-sum.curr-code       = 0
                        buf_temp-fin-sum.cash-desk       = 0
                        buf_temp-fin-sum.is-petrol       = no
                        buf_temp-fin-sum.cashbookid      = tt-rest-fin.CashBookId
                        buf_temp-fin-sum.is-expense_cash = no
                        .
                    end.
                    assign
                      buf_temp-fin-sum.tot-rubl = buf_temp-fin-sum.tot-rubl + tt-rest-fin.ostatok
                      buf_temp-fin-sum.tot-base = buf_temp-fin-sum.tot-base + tt-rest-fin.ostatok
                      buf_temp-fin-sum.tot-sum  = buf_temp-fin-sum.tot-sum + tt-rest-fin.ostatok
                      .
                    if buf_temp-fin-sum.tot-sum eq 0
                      then delete buf_temp-fin-sum.
                    else
                    do:
                      create buf_temp-tax.
                      assign
                        buf_temp-tax.curr-code        = buf_temp-fin-sum.curr-code
                        buf_temp-tax.cash-desk        = buf_temp-fin-sum.cash-desk
                        buf_temp-tax.is-petrol        = buf_temp-fin-sum.is-petrol
                        buf_temp-tax.cashbookId       = buf_temp-fin-sum.cashbookid
                        buf_temp-tax.is-expense_cash  = buf_temp-fin-sum.is-expense_cash
                        buf_temp-tax.num-expense_cash = buf_temp-fin-sum.num-expense_cash
                        buf_temp-tax.sum-rubl         = buf_temp-fin-sum.tot-sum
                        buf_temp-tax.sum-base         = buf_temp-fin-sum.tot-sum
                        buf_temp-tax.sum-doc          = buf_temp-fin-sum.tot-sum
                        .
                    end.
                  end.
                  _temp-fin-sum:
                  for each buf_temp-fin-sum no-lock
                    by buf_temp-fin-sum.cashbookid desc
                    :
                    empty temp-table tt0-fin-doc-tax.
                    empty temp-table tt0-fin-doc-attr.
                    empty temp-table tt-fin-doc.
                    if buf_temp-fin-sum.tot-sum = 0  then
                    do:
                      next _temp-fin-sum.
                    end.
                    find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sum.CashBookId no-error .
                    define variable mCashbookName as character no-undo.
                    mCashbookName = string(ub.CashBook.id).
                    if available ub.CashBook then
                    do:
                      assign
                        v-real-obj-type = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, 'всем':U, 0, "CountCollect-type") .
                      v-real-obj-code = int(mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, 'всем':U, 0, "CountCollect-code") ).
                      mCashbookName = string(ub.CashBook.id) + " (" + CashBook.CashBookName + ")".
                      .
                    end.
                    define variable v-doc-rec          as recid     no-undo .
                    define variable v-fin-doc-type     as character no-undo .
                    define variable v-fin-ext-doc-type as character no-undo .
                    if  buf_temp-fin-sum.tot-rubl > 0 then
                      assign
                        v-fin-doc-type     = 'пко':U
                        v-fin-ext-doc-type = 'пко':U.
                    else
                      assign
                        v-fin-doc-type     = 'рко':U
                        v-fin-ext-doc-type = 'рко':U.
                    run ref/finfnoco.p (
                      INPUT parParentProc
                      ,INPUT ?
                      ,input v-host-code
                      ,input ('ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U + chr(4) + "тех_")
                      ,input v-host-code
                      ,input v-doc-rec
                      ,input 0
                      ,input v-fin-doc-type
                      ,input v-fin-ext-doc-type
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input 0
                      ,input ''
                      ,input 'орг':U
                      ,input v-host-code
                      ,input 0
                      ,input v-real-obj-type
                      ,input v-real-obj-code
                      ,input 0
                      ,input buf_temp-fin-sum.curr-code
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input buf_temp-fin-sum.cashbookid
                      ,input ""
                      ,INPUT-OUTPUT table tt-fin-doc
                      ,INPUT-OUTPUT table ttc-fin-doc
                      ,output table tt0-fin-doc-attr
                      ,output v-limit-access ) no-error.
                    if error-status:error then
                    do:
                      put-log(substitute("Ошибки при заполнении фин.док-та значениями по умолчанию &1 &2 ",chr(10),RETURN-VALUE)).
                    end.
                    find first tt-fin-doc.
                    define variable v-line-num as integer no-undo .
                    for each buf_temp-tax no-lock
                      where buf_temp-tax.curr-code        = buf_temp-fin-sum.curr-code
                      and buf_temp-tax.cash-desk         = buf_temp-fin-sum.cash-desk
                      and buf_temp-tax.is-petrol        = buf_temp-fin-sum.is-petrol
                      and buf_temp-tax.cashbookId       = buf_temp-fin-sum.cashbookId
                      and buf_temp-tax.is-expense_cash  = buf_temp-fin-sum.is-expense_cash
                      and buf_temp-tax.num-expense_cash = buf_temp-fin-sum.num-expense_cash
                      :
                      v-line-num = v-line-num + 1.
                      create tt0-fin-doc-tax .
                      assign
                        tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
                        tt0-fin-doc-tax.host-code          = tt-fin-doc.host-code
                        tt0-fin-doc-tax.line-num           = v-line-num
                        tt0-fin-doc-tax.VAT-pc             = buf_temp-tax.vat-pc
                        tt0-fin-doc-tax.slt-pc             = buf_temp-tax.slt-pc
                        tt0-fin-doc-tax.sum-line-contr     = 0
                        tt0-fin-doc-tax.sum-vat-line-contr = 0
                        tt0-fin-doc-tax.with-vat           = buf_temp-tax.with-vat
                        .
                      if buf_temp-fin-sum.tot-sum > 0  then
                      do :
                        assign
                          tt0-fin-doc-tax.sum-line-doc      = buf_temp-tax.sum-doc
                          tt0-fin-doc-tax.sum-vat-line-doc  = buf_temp-tax.vat-doc
                          tt0-fin-doc-tax.sum-line-rubl     = buf_temp-tax.sum-rubl
                          tt0-fin-doc-tax.sum-vat-line-rubl = buf_temp-tax.vat-rubl
                          tt0-fin-doc-tax.sum-line-base     = buf_temp-tax.sum-base
                          tt0-fin-doc-tax.sum-vat-line-base = buf_temp-tax.vat-base
                          .
                      end.
                      else
                      do :
                        assign
                          tt0-fin-doc-tax.sum-line-doc      = abs(buf_temp-tax.sum-doc)
                          tt0-fin-doc-tax.sum-vat-line-doc  = abs(buf_temp-tax.vat-doc)
                          tt0-fin-doc-tax.sum-line-rubl     = abs(buf_temp-tax.sum-rubl)
                          tt0-fin-doc-tax.sum-vat-line-rubl = abs(buf_temp-tax.vat-rubl)
                          tt0-fin-doc-tax.sum-line-base     = abs(buf_temp-tax.sum-base)
                          tt0-fin-doc-tax.sum-vat-line-base = abs(buf_temp-tax.vat-base)
                          .
                      end.
                    end.
                    tt-fin-doc.including = StrTax (tt-fin-doc.including) .
                    RoundTax() .
                    if available ub.CashBook
                      then
                    do :
                      p-by-cash-desk = ub.CashBook.FlagSepCash .
                      p-by-petrol-goods = ub.CashBook.FlagSepFull .
                      p-by-osnovanie = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, 'всем':U, 0, "BasisIncas") .
                      p-by-pril = ub.CashBook.RulePril .
                    end.
                    tt-fin-doc.enclosure = p-by-pril.
                    assign
                      tt-fin-doc.naznach-plat = "Перенос денежных остатков".
                    assign
                      tt-fin-doc.CashBookId = buf_temp-fin-sum.cashbookid
                      tt-fin-doc.sum-doc    = abs(buf_temp-fin-sum.tot-sum)
                      tt-fin-doc.sum-base   = abs(buf_temp-fin-sum.tot-base)
                      tt-fin-doc.sum-rubl   = abs(buf_temp-fin-sum.tot-rubl)
                      tt-fin-doc.exch-rate  = abs(if buf_temp-fin-sum.curr-code = 0 then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-sum )
                      tt-fin-doc.exch-scale = 1
                      tt-fin-doc.base-rate  = abs(if buf_temp-fin-sum.curr-code = v-base-code then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-base )
                      tt-fin-doc.base-scale = 1
                      .
                    o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
                    if available ub.CashBook
                      then
                    do :
                      tt-fin-doc.cor-acc-value  = ub.CashBook.OsnAcct .
                      tt-fin-doc.cor-acc1-value = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, 'всем':U, 0, "CorrAcctIncas") .
                      FIND ub.fin-code-cor-acc WHERE
                        ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
                        AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
                        AND  ub.fin-code-cor-acc.status_ = integer('0':U)
                        NO-LOCK NO-error.
                      if not available ub.fin-code-cor-acc
                        then
                      do:
                        assign
                          tt-fin-doc.cor-acc-value = ?
                          .
                      end.
                      else
                      do:
                        assign
                          tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code
                          .
                      end.
                      FIND ub.fin-code-cor-acc WHERE
                        ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc1-value
                        AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
                        AND  ub.fin-code-cor-acc.status_ = integer('0':U)
                        NO-LOCK NO-error.
                      if not available ub.fin-code-cor-acc
                        then
                      do:
                        assign
                          tt-fin-doc.cor-acc1-value = ?
                          .
                      end.
                      else
                      do:
                        assign
                          tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
                          .
                      end.
                    end.
                    if tt-fin-doc.cor-acc1-value eq "" or tt-fin-doc.cor-acc1-value eq ?
                      then
                    do:
                      put-log("Не задан счет для инкасации") .
                    end.
                    if o-uchet = "0"
                      then v-uchet = "cal" .
                    else v-uchet = "smen" .
                    define variable v-name     as character no-undo.
                    define variable v-codetype as character no-undo .
                    if icontr = "" then
                    do:
                      put-log("Не задан контрагент для ПКО/РКО") .
                    end.
                    v-codetype = trim(entry(1,icontr,"_")) .
                    v-name = trim(entry(2,icontr,"_")) .
                    if v-fin-doc-type = 'рко':U then
                    do:
                      tt-fin-doc.receiver-code = integer(substring (v-codetype, 4)) .
                      tt-fin-doc.receiver-type = substring (v-codetype, 1, 3) .
                      tt-fin-doc.receiver-name = v-name .
                    end.
                    else
                    do:
                      tt-fin-doc.payer-code = integer(substring (v-codetype, 4)) .
                      tt-fin-doc.payer-type = substring (v-codetype, 1, 3) .
                      tt-fin-doc.payer-name = v-name .
                    end.
                    if buf_shift-obj.status_ = 'зкр':U and v-uchet = "smen" then
                    do:
                      assign
                        tt-fin-doc.doc-date   = buf_shift-obj.close-date
                        tt-fin-doc.shift-date = buf_shift-obj.shift-date
                        tt-fin-doc.shift-num  = buf_shift-obj.shift-num
                        tt-fin-doc.shift-name = buf_shift-obj.shift-name
                        .
                    end.
                    assign
                      tt-fin-doc.doc-author = 'auto':U.
          run ref/findoc0.p (
      input-output v-doc-rec
            ,input 'ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U
            ,input yes
            ,input tt-fin-doc.host-code            ,input tt-fin-doc.fin-doc-code         ,input tt-fin-doc.an-uchet-code        ,input tt-fin-doc.an-uchet-value       ,input tt-fin-doc.base-rate            ,input tt-fin-doc.base-scale           ,input tt-fin-doc.cel-nazn-code        ,input tt-fin-doc.cel-nazn-value       ,input tt-fin-doc.contract-code        ,input tt-fin-doc.contract-curr        ,input tt-fin-doc.contract-rate        ,input tt-fin-doc.contract-scale       ,input tt-fin-doc.cor-acc              ,input tt-fin-doc.cor-acc-value        ,input tt-fin-doc.cor-acc1             ,input tt-fin-doc.cor-acc1-value       ,input tt-fin-doc.curr-code            ,input tt-fin-doc.doc-date             ,input tt-fin-doc.shift-date           ,input tt-fin-doc.shift-num            ,input tt-fin-doc.shift-name           ,input tt-fin-doc.enclosure            ,input tt-fin-doc.exch-rate            ,input tt-fin-doc.exch-scale           ,input tt-fin-doc.f104                 ,input tt-fin-doc.f105                 ,input tt-fin-doc.f106                 ,input tt-fin-doc.f107                 ,input tt-fin-doc.f108                 ,input tt-fin-doc.f109                 ,input tt-fin-doc.f110                 ,input tt-fin-doc.f22                  ,input tt-fin-doc.f23                  ,input tt-fin-doc.fact-date            ,input tt-fin-doc.fin-doc-type         ,input tt-fin-doc.fin-ext-doc-type     ,input tt-fin-doc.in-doc-code          ,input tt-fin-doc.in-host-code         ,input tt-fin-doc.including            ,input tt-fin-doc.nazn-pl              ,input tt-fin-doc.naznach-plat         ,input tt-fin-doc.ocher-pl             ,input tt-fin-doc.out-doc-code         ,input tt-fin-doc.out-host-code        ,input tt-fin-doc.pay-date             ,input tt-fin-doc.payer-bank-name      ,input tt-fin-doc.payer-bank-city      ,input tt-fin-doc.payer-bik            ,input tt-fin-doc.payer-c-schet        ,input tt-fin-doc.payer-code           ,input tt-fin-doc.payer-code-schet     ,input tt-fin-doc.payer-dop1           ,input tt-fin-doc.payer-dop2           ,input tt-fin-doc.payer-inn            ,input tt-fin-doc.payer-kpp            ,input tt-fin-doc.payer-name           ,input tt-fin-doc.payer-okpo           ,input tt-fin-doc.payer-passport      ,input tt-fin-doc.payer-r-schet        ,input tt-fin-doc.payer-type           ,input tt-fin-doc.perm-date            ,input tt-fin-doc.prn-doc-code         ,input tt-fin-doc.PS                   ,input tt-fin-doc.receiver-bank-name   ,input tt-fin-doc.receiver-bank-city   ,input tt-fin-doc.receiver-bik         ,input tt-fin-doc.receiver-c-schet     ,input tt-fin-doc.receiver-code        ,input tt-fin-doc.receiver-code-schet  ,input tt-fin-doc.receiver-dop1        ,input tt-fin-doc.receiver-dop2        ,input tt-fin-doc.receiver-inn         ,input tt-fin-doc.receiver-kpp         ,input tt-fin-doc.receiver-name        ,input tt-fin-doc.receiver-okpo        ,input tt-fin-doc.receiver-passport    ,input tt-fin-doc.receiver-r-schet     ,input tt-fin-doc.receiver-type        ,input tt-fin-doc.srok-pl              ,input tt-fin-doc.stat-pl              ,input tt-fin-doc.str-podr-code        ,input tt-fin-doc.str-podr-type        ,input tt-fin-doc.str-podr-name        ,input tt-fin-doc.sum-base             ,input tt-fin-doc.sum-doc              ,input tt-fin-doc.sum-rubl             ,input tt-fin-doc.sum-contr            ,input tt-fin-doc.trn-doc-code         ,input tt-fin-doc.vid-opl              ,input tt-fin-doc.vid-plat
            ,input tt-fin-doc.con-sum-rubl         ,input tt-fin-doc.con-sum-base         ,input tt-fin-doc.con-sum-doc          ,input tt-fin-doc.con-sum-contr        ,input tt-fin-doc.con-stat             ,input tt-fin-doc.payer-sign1                ,input tt-fin-doc.payer-sign2                ,input tt-fin-doc.payer-sign3                ,input tt-fin-doc.payer-sign4                ,input tt-fin-doc.receiver-sign1                ,input tt-fin-doc.receiver-sign2                ,input tt-fin-doc.receiver-sign3                ,input tt-fin-doc.receiver-sign4                ,input tt-fin-doc.obj-type                   ,input tt-fin-doc.obj-code                   ,input tt-fin-doc.doc-author                 ,input tt-fin-doc.fact-author                ,input tt-fin-doc.CashBookId
            ,input table tt0-fin-doc-tax
            ,input table tt0-fin-doc-attr
            ,input no
            ,input table tt0-payment
      ) no-error.
                    if error-status:error then
                    do:
                      put-log("Ошибки при сохранении фин.док-та")
                        .
                    end.
                    find first buf_fin-doc share-lock where
                      recid(buf_fin-doc) = v-doc-rec.
                    assign
                      buf_fin-doc.shift-flag = integer('1':U)
                      .
                    find first fin-doc-attr where fin-doc-attr.host-code    eq buf_fin-doc.host-code
                      and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                      and fin-doc-attr.attr-code    eq "pre-vedom"
                      exclusive-lock no-error.
                    if not available fin-doc-attr
                      then
                    do:
                      create fin-doc-attr.
                      assign
                        fin-doc-attr.host-code    = buf_fin-doc.host-code
                        fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
                        fin-doc-attr.attr-code    = "pre-vedom"
                        .
                    end.
                    define variable mPin as character no-undo.
                    mPin   = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "Pin") .
                    fin-doc-attr.attr-value = substitute("&1;&2;&3;&4;&5;&6;&7"
                      ,mOsnbag
                      ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankDepos-code")
                      ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankRecip-code")
                      ,mPin
                      ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "SourceCode")
                      ,msumInc-save
                      ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankRecip-acct")).
                    define variable Vparentrec as character no-undo.
                    if Vparentrec eq ""
                      then
                      Vparentrec = gen-key-rec ("fin-doc",(buffer buf_fin-doc:handle)).
                    find first fin-doc-attr where fin-doc-attr.host-code       eq buf_fin-doc.host-code
                      and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                      and fin-doc-attr.attr-code    eq "ParentMoney"
                      exclusive-lock no-error.
                    if not available fin-doc-attr
                      then
                    do:
                      create fin-doc-attr.
                      assign
                        fin-doc-attr.host-code    = buf_fin-doc.host-code
                        fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
                        fin-doc-attr.attr-code    = "ParentMoney"
                        .
                    end.
                    fin-doc-attr.attr-value = Vparentrec.
                    if mMoney ne ""
                      then
                    do:
                      find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
                        and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                        and fin-doc-attr.attr-code eq "cover_sheet"
                        exclusive-lock no-error.
                      if not available fin-doc-attr
                        then
                      do:
                        create fin-doc-attr.
                        assign
                          fin-doc-attr.host-code    = buf_fin-doc.host-code
                          fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
                          fin-doc-attr.attr-code    = "cover_sheet"
                          .
                      end.
                      fin-doc-attr.attr-value = mMoney.
                      mMoney = "".
                    end.
                    proc-close ( buffer buf_fin-doc) no-error.
                    if error-status :error then
                    do:
                      put-log("Ошибки при сохранении фин.док-та").
                    END.
                    if buf_fin-doc.status_ <> 'факт':U then
                    do:
                      proc-close ( buffer buf_fin-doc) NO-ERROR.
                      if error-status :error then
                      do:
                        put-log("Не удалось сменить статус фин.док-та").
                      END.
                    end.
                    if buf_fin-doc.status_ <> 'факт':U then
                    do:
                      proc-close ( buffer buf_fin-doc) no-error .
                      if error-status :error then
                      do:
                        put-log("Не удалось сменить статус фин.док-та").
                      END.
                    end.
                  end.
                  vok = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("rest-fin-temp.json") .
                      os-delete value("restfin.json") .
                    end.
                    vok = chek_rest_fin() and vok.
                    put-log( string( now) + if  vok then "   Денежные остатки загружены!" else "   Денежные остатки не загружены!") .
                    put-log("").
                    return vok.
                  end finally.
                end method .
                method public void proc-close (buffer buf_fin-doc for ub.fin-doc) :
                  define variable v-status_         as character no-undo .
                  define variable v-old-status_     as character no-undo .
                  define variable v-ask-date        as logical   no-undo .
                  define variable v-ask-message     as character no-undo .
                  define variable v-status-date-chr as character no-undo.
                  define variable v-date1           as date      no-undo .
                  assign
                    v-old-status_ = buf_fin-doc.status_
                    .
                  run trg/findgraf.p (
                    input  buf_fin-doc.host-code
                    ,input  buf_fin-doc.fin-doc-code
                    ,input  '<закрытие документа>':U
                    ,input  ''
                    ,input  v-old-status_
                    ,input  ?
                    ,output v-status_
                    ,output v-ask-date
                    ,output v-ask-message
                    ) no-error.
                  if error-status:error then
                  do:
                    return error substitute("Ошибка при проверке возможности &1&2&3"
                      ,'<закрытие документа>':U
                      , chr(10)
                      , return-value ).
                  end.
                  v-date1 = buf_fin-doc.doc-date.
                  run trg/findstat.p (
                    input parparentproc
                    ,input buf_fin-doc.host-code
                    ,input buf_fin-doc.fin-doc-code
                    ,input '<закрытие документа>':U
                    ,input 'auto':U
                    ,input v-status_
                    ,input-output v-date1
                    ,input no
                    ) no-error .
                  if error-status:error then
                  do:
                    return error substitute("Ошибка при переводе статуса финансового документа:&1&2&1&3"
                      ,'<закрытие документа>':U
                      , chr(10)
                      , return-value ).
                  end.
                end method.
                method public character gen-key-rec (p-tbl-name    as character,
                  p-bh_tbl-name as handle):
                  define variable p-key-rec        as character no-undo.
                  define variable fh               as handle    no-undo .
                  define variable v-ok             as logical   no-undo .
                  define variable v-inform         as character no-undo .
                  define variable v-ind            as integer   no-undo .
                  define variable v-idx-field-qnty as integer   no-undo .
                  if p-tbl-name = ?
                    or p-tbl-name = "":U
                    then
                  do:
                    return error substitute( "(gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы." ).
                  end.
                  if not p-bh_tbl-name:available then
                  do:
                    return error substitute( "(gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", p-tbl-name ).
                  end.
                  assign
                    p-key-rec = p-tbl-name
                    v-inform  = p-bh_tbl-name:index-information(1)
                    v-ind     = 2
                    .
                  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
                    on error undo, return error
                    :
                    assign
                      v-inform = p-bh_tbl-name:index-information( v-ind )
                      v-ind    = v-ind + 1
                      .
                  end.
                  if v-inform = ?
                    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
                    or entry( 3, v-inform, ",":U ) <> "1":U
                    then
                  do:
                    return error substitute( "Таблица &2 не имеет первичного ключа в БД",  p-tbl-name ).
                  end.
                  else
                  do:
                    assign
                      v-idx-field-qnty = num-entries( v-inform ) - 4
                      .
                    if v-idx-field-qnty < 2 then
                    do:
                      return error substitute( "Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", v-inform, p-tbl-name ).
                    end.
                    do v-ind = 1 to v-idx-field-qnty by 2
                      on error undo, return error
                      :
                      assign
                        fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
                      p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
                        .
                    end.
                  end.
                  if p-key-rec = ? then
                  do:
                    assign
                      p-key-rec = "":U
                      .
                    return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", p-tbl-name ).
                  end.
                  return p-key-rec.
                end method.
                method public character StrTax (str as character):
                  define variable v-envd as logical no-undo .
                  assign
                    str = " В т.ч.: "  .
                  for each tt0-fin-doc-tax :
                    if str <> " В т.ч.: " then str = str + "," .
                    if not tt0-fin-doc-tax.with-vat then assign str = str + "без НДС - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                    else
                    do:
                      if tt-fin-doc.curr-code = 0 then
                      do:
                        assign
                          str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " руб. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                      end.
                      else
                      do:
                        assign
                          str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                      end.
                    end.
                    if str = " В т.ч.: " then assign str = "" .
                  end.
                  return str .
                end method.
                method public void RoundTax() :
                  for each tt0-fin-doc-tax :
                    assign
                      tt0-fin-doc-tax.sum-line-doc      = ROUND( tt0-fin-doc-tax.sum-line-doc      , 2)
                      tt0-fin-doc-tax.sum-vat-line-doc  = ROUND( tt0-fin-doc-tax.sum-vat-line-doc  , 2)
                      tt0-fin-doc-tax.sum-line-rubl     = ROUND( tt0-fin-doc-tax.sum-line-rubl     , 2)
                      tt0-fin-doc-tax.sum-vat-line-rubl = ROUND( tt0-fin-doc-tax.sum-vat-line-rubl , 2)
                      tt0-fin-doc-tax.sum-line-base     = ROUND( tt0-fin-doc-tax.sum-line-base     , 2)
                      tt0-fin-doc-tax.sum-vat-line-base = ROUND( tt0-fin-doc-tax.sum-vat-line-base , 2)
                      .
                  end.
                END method.
                method public logical sendcode(icode as integer ):
                  run utl/sendcode.p(this-object,icode,?).
                  put-log("").
                  return yes.
                end method.
                method public logical sendnum(text-num as character ):
                  run utl/sendnum.p(this-object,text-num,v-cntxt-obj-code).
                  put-log("").
                  return yes.
                end method.
                method public logical sendparam(text_file as character ):
                  define variable cmd as character no-undo .
                  define buffer buf_cash-desk for ub.cash-desk .
                  define variable ii as integer no-undo .
                  do ii = 1 to num-entries (text_file,chr(4)):
                    if search (entry (ii,text_file,chr(4))) > ""
                      then
                      for each buf_cash-desk no-lock where buf_cash-desk.db-num   = v-cntxt-db-num
                        and buf_cash-desk.obj-code = v-cntxt-obj-code
                        and buf_cash-desk.pos-type = 'IBM-XML':U
                        and buf_cash-desk.cash-on
                        :
                        assign
                          cmd = substitute('&1 -X POST -H "Content-Type: text/xml" -d @&2 &3 >&4'
                      , search ("exe/curl.exe")
                      , search (entry (ii,text_file,chr(4)))
                      , (entry(1, buf_cash-desk.addr-path, chr(4)) + '://' + entry(2, buf_cash-desk.addr-path, chr(4)))
                      , "cashParResp.txt")
                          .
                        os-command silent value (cmd) .
                      end .
                  end.
                  return yes.
                end method.
                method public logical  chek_rest():
                  for each ub.trn-doc no-lock where ub.trn-doc.obj-type = v-cntxt-obj-type
                    and ub.trn-doc.obj-code = v-cntxt-obj-code,
                    each ub.doc-line no-lock where ub.doc-line.doc-code = ub.trn-doc.doc-code:
                    for first ub.goods no-lock where ub.goods.artic = ub.doc-line.artic and
                      ub.goods.prod-code = ub.doc-line.prod-code and
                      ub.goods.prod-type = ub.doc-line.prod-type,
                      first ub.units no-lock where ub.units.unit-name = ub.goods.unit-base:
                      if lookup( 'топ':U, ub.units.type ) > 0 then next .
                      else return yes .
                    end.
                  end.
                  return no .
                end  method.
                method public logical  chek_rest_ptrl():
                  for each ub.trn-doc no-lock where ub.trn-doc.obj-type = v-cntxt-obj-type
                    and ub.trn-doc.obj-code = v-cntxt-obj-code,
                    each ub.doc-line no-lock where ub.doc-line.doc-code = ub.trn-doc.doc-code:
                    for first ub.goods no-lock where ub.goods.artic = ub.doc-line.artic and
                      ub.goods.prod-code = ub.doc-line.prod-code and
                      ub.goods.prod-type = ub.doc-line.prod-type,
                      first ub.units no-lock where ub.units.unit-name = ub.goods.unit-base:
                      if lookup( 'топ':U, ub.units.type ) > 0 then return yes .
                      else next .
                    end.
                  end.
                  return no .
                end  method.
                method public logical  chek_rest_fin():
                  return can-find (first ub.fin-doc where ub.fin-doc.obj-type = v-cntxt-obj-type
                    and ub.fin-doc.obj-code = v-cntxt-obj-code).
                end  method.
                method public logical  load_rvs(ifile-path as character):
                  return load_rvs(mAddr,ifile-path).
                end  method.
                method public logical load_rvs(iAddr as character,ifile-path as character  ):
                  define variable vcmd       as character no-undo.
                  define variable v-rvs-code as character no-undo.
                  define variable vOk        as logical   no-undo.
                  define buffer open-shift       for ub.shift-obj .
                  define buffer buf_rvs-doc-prev for ub.rvs-doc .
                  put-log("Загрузка последней сменной сверки").
                  find first tt-gds-mapping no-error.
                  if not available tt-gds-mapping
                    then
                  do:
                    load_gds_maping(ifile-path ).
                    find first tt-gds-mapping no-error.
                    if not available tt-gds-mapping
                      then
                      return error.
                  end.
                  find last open-shift where
                    open-shift.obj-type = v-cntxt-obj-type and
                    open-shift.obj-code = v-cntxt-obj-code and
                    open-shift.status_ = 'тек':U
                    use-index pi no-error.
                  if available  open-shift
                    then
                  do:
                    for each tt-rvs-doc-attr:
                      delete tt-rvs-doc-attr.
                    end.
                    for each tt-rvs-line-attr:
                      delete tt-rvs-line-attr.
                    end.
                    for each tt-rvs-pump-attr:
                      delete tt-rvs-pump-attr.
                    end.
                    for each tt-rvs-line-pump-attr:
                      delete tt-rvs-line-attr.
                    end.
                    for each tt-rvs-line:
                      delete tt-rvs-line-pump-attr.
                    end.
                    for each tt-rvs-pump:
                      delete tt-rvs-pump.
                    end.
                    for each tt-rvs-line-pump:
                      delete tt-rvs-line-pump.
                    end.
                    for each tt-rvs-doc:
                      delete tt-rvs-doc.
                    end.
                    vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetRvs >&3", search ("exe/curl.exe"), iaddr, "rvs-temp.json").
                    os-command silent value (vcmd).
                    fix-codepage_and_SetJsonObj(input "rvs-temp.json") .
                    parse-json(input temp-table tt-rvs-doc              :default-buffer-handle, input "rvs-doc") .
                    parse-json(input temp-table tt-rvs-doc-attr         :default-buffer-handle, input "rvs-doc-attr") .
                    parse-json(input temp-table tt-rvs-line             :default-buffer-handle, input "rvs-line") .
                    parse-json(input temp-table tt-rvs-line-attr        :default-buffer-handle, input "rvs-line-attr") .
                    parse-json(input temp-table tt-rvs-pump             :default-buffer-handle, input "rvs-pump") .
                    parse-json(input temp-table tt-rvs-pump-attr        :default-buffer-handle, input "rvs-pump-attr") .
                    parse-json(input temp-table tt-rvs-line-pump        :default-buffer-handle, input "rvs-line-pump") .
                    parse-json(input temp-table tt-rvs-line-pump-attr   :default-buffer-handle, input "rvs-line-pump-attr") .
                    find first  buf_rvs-doc-prev where buf_rvs-doc-prev.obj-type eq v-cntxt-obj-type
                      and buf_rvs-doc-prev.obj-code eq v-cntxt-obj-code
                      and buf_rvs-doc-prev.shift-date eq open-shift.shift-date
                      and buf_rvs-doc-prev.shift-num  eq open-shift.shift-num
                      no-lock no-error.
                    if available  buf_rvs-doc-prev
                      then
    // изменения от базы к базе
                      for first tt-rvs-doc:
                        if tt-rvs-doc.doc-date eq ? then  tt-rvs-doc.doc-date =  open-shift.shift-date.
                        doc-code
                          (  input 'main':U
                          ,  input v-cntxt-obj-type
                          ,  input v-cntxt-obj-code
                          ,  input ?
                          , output v-rvs-code
                          ) .
                        for each tt-rvs-doc-attr where tt-rvs-doc-attr.rvs-code eq tt-rvs-doc.rvs-code:
                          tt-rvs-doc-attr.rvs-code = v-rvs-code.
                        end.
                        for each tt-rvs-line where tt-rvs-line.rvs-code eq tt-rvs-doc.rvs-code:
                          assign
                            tt-rvs-line.obj-type      = v-cntxt-obj-type
                            tt-rvs-line.obj-code      = v-cntxt-obj-code
                            tt-rvs-line.rvs-code      = v-rvs-code
                            tt-rvs-line.rvs-prev-code = buf_rvs-doc-prev.rvs-code
                            .
                          find first tt-gds-mapping where tt-gds-mapping.gds-code15 eq tt-rvs-line.gds-code
                            no-lock no-error.
                          if available tt-gds-mapping
                            then
                          do:
                            find first goods where goods.gds-code eq tt-gds-mapping.gds-code16 no-lock no-error.
                            if not available goods
                              then
                            do:
                              put-log(substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16)).
                              return error substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16).
                            end.
                            else
                              tt-rvs-line.gds-code = tt-gds-mapping.gds-code16.
                          end.
                          else
                          do:
                            put-log(substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-line.gds-code)).
                            return error substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-line.gds-code).
                          end.
                          find first ub.place where ub.place.loc1 eq tt-rvs-line.loc1
                            no-lock no-error.
                          if available ub.place
                            then
                            tt-rvs-line.pl-code = ub.place.pl-code.
                        end.
                        for each tt-rvs-line-attr where tt-rvs-line-attr.rvs-code eq tt-rvs-doc.rvs-code:
                          assign
                            tt-rvs-line-attr.obj-type = v-cntxt-obj-type
                            tt-rvs-line-attr.obj-code = v-cntxt-obj-code
                            tt-rvs-line-attr.rvs-code = v-rvs-code
                            .
                          find first tt-gds-mapping where tt-gds-mapping.gds-code15 eq tt-rvs-line-attr.gds-code
                            no-lock no-error.
                          if available tt-gds-mapping
                            then
                          do:
                            find first goods where goods.gds-code eq tt-gds-mapping.gds-code16 no-lock no-error.
                            if not available goods
                              then
                            do:
                              put-log(substitute ("Отсутствует товар с кодом  &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16)).
                              return error substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16).
                            end.
                            else
                              tt-rvs-line-attr.gds-code = tt-gds-mapping.gds-code16.
                          end.
                          else
                          do:
                            put-log(substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-line-attr.gds-code)).
                            return error substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-line-attr.gds-code).
                          end.
                          find first ub.place where ub.place.loc1 eq tt-rvs-line.loc1
                            no-lock no-error.
                          if available ub.place
                            then
                            tt-rvs-line.pl-code = ub.place.pl-code.
                        end.
                        for each tt-rvs-pump where tt-rvs-pump.rvs-code eq tt-rvs-doc.rvs-code:
                          assign
                            tt-rvs-pump.obj-type = v-cntxt-obj-type
                            tt-rvs-pump.obj-code = v-cntxt-obj-code
                            tt-rvs-pump.rvs-code = v-rvs-code
                            .
                          find first tt-gds-mapping where tt-gds-mapping.gds-code15 eq tt-rvs-pump.gds-code
                            no-lock no-error.
                          if available tt-gds-mapping
                            then
                          do:
                            find first goods where goods.gds-code eq tt-gds-mapping.gds-code16 no-lock no-error.
                            if not available goods
                              then
                            do:
                              put-log(substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16)).
                              return error substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16).
                            end.
                            else
                              tt-rvs-pump.gds-code = tt-gds-mapping.gds-code16.
                          end.
                          else
                          do:
                            put-log(substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-pump.gds-code)).
                            return error substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-pump.gds-code).
                          end.
                        end.
                        for each tt-rvs-pump-attr where tt-rvs-pump-attr.rvs-code eq tt-rvs-doc.rvs-code:
                          assign
                            tt-rvs-pump-attr.obj-type = v-cntxt-obj-type
                            tt-rvs-pump-attr.obj-code = v-cntxt-obj-code
                            tt-rvs-pump-attr.rvs-code = v-rvs-code
                            .
                        end.
                        for each tt-rvs-line-pump where tt-rvs-line-pump.rvs-code eq tt-rvs-doc.rvs-code:
                          assign
                            tt-rvs-line-pump.obj-type      = v-cntxt-obj-type
                            tt-rvs-line-pump.obj-code      = v-cntxt-obj-code
                            tt-rvs-line-pump.rvs-code      = v-rvs-code
                            tt-rvs-line-pump.rvs-prev-code = buf_rvs-doc-prev.rvs-code
                            .
                          find first tt-gds-mapping where tt-gds-mapping.gds-code15 eq tt-rvs-line-pump.gds-code
                            no-lock no-error.
                          if available tt-gds-mapping
                            then
                          do:
                            find first goods where goods.gds-code eq tt-gds-mapping.gds-code16 no-lock no-error.
                            if not available goods
                              then
                            do:
                              put-log(substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16)).
                              return error substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16).
                            end.
                            else
                              tt-rvs-line-pump.gds-code = tt-gds-mapping.gds-code16.
                          end.
                          else
                          do:
                            put-log(substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-line-pump.gds-code)).
                            return error substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-line-pump.gds-code).
                          end.
                          find first ub.place where ub.place.loc1 eq tt-rvs-line-pump.loc1
                            no-lock no-error.
                          if available ub.place
                            then
                            tt-rvs-line-pump.pl-code = ub.place.pl-code.
                        end.
                        for each tt-rvs-line-pump-attr where tt-rvs-line-pump-attr.rvs-code eq tt-rvs-doc.rvs-code:
                          assign
                            tt-rvs-line-pump-attr.obj-type = v-cntxt-obj-type
                            tt-rvs-line-pump-attr.obj-code = v-cntxt-obj-code
                            tt-rvs-line-pump-attr.rvs-code = v-rvs-code
                            .
                          find first tt-gds-mapping where tt-gds-mapping.gds-code15 eq tt-rvs-line-pump-attr.gds-code
                            no-lock no-error.
                          if available tt-gds-mapping
                            then
                          do:
                            find first goods where goods.gds-code eq tt-gds-mapping.gds-code16 no-lock no-error.
                            if not available goods
                              then
                            do:
                              put-log(substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16)).
                              return error substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16",tt-gds-mapping.gds-code16).
                            end.
                            else
                              tt-rvs-line-pump-attr.gds-code = tt-gds-mapping.gds-code16.
                          end.
                          else
                          do:
                            put-log(substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-line-pump-attr.gds-code)).
                            return error substitute ("В файле соответствия отсутствует товар с кодом &1",tt-rvs-line-pump-attr.gds-code).
                          end.
                          find first ub.place where ub.place.loc1 eq tt-rvs-line-pump-attr.loc1
                            no-lock no-error.
                          if available ub.place
                            then
                            tt-rvs-line-pump-attr.pl-code = ub.place.pl-code.
                        end.
                        assign
                          tt-rvs-doc.shift-date = open-shift.shift-date
                          tt-rvs-doc.shift-num  = open-shift.shift-num
                          tt-rvs-doc.shift-name = open-shift.shift-name
                          tt-rvs-doc.doc-date   = today
                          tt-rvs-doc.fact-date  = today
                          tt-rvs-doc.fact-time  = time
                          tt-rvs-doc.obj-type   = v-cntxt-obj-type
                          tt-rvs-doc.obj-code   = v-cntxt-obj-code
                          tt-rvs-doc.rvs-code   = v-rvs-code
                          tt-rvs-doc.status_    = 'новый':U
                          tt-rvs-doc.fact-order = ?
                          tt-rvs-doc.host-code  = v-host-code
                          tt-rvs-doc.PS         = "Последняя сменная сверка из " + string(version-name)
                          .
                      end.
                    for each tt-rvs-doc:
                      create ub.rvs-doc.
                      buffer-copy tt-rvs-doc to ub.rvs-doc.
                    end.
                    for each tt-rvs-doc-attr:
                      create ub.rvs-doc-attr.
                      buffer-copy tt-rvs-doc-attr to ub.rvs-doc-attr.
                    end.
                    for each tt-rvs-line:
                      create ub.rvs-line.
                      buffer-copy tt-rvs-line to ub.rvs-line.
                    end.
                    for each tt-rvs-line-attr:
                      create ub.rvs-line-attr.
                      buffer-copy tt-rvs-line-attr to ub.rvs-line-attr.
                    end.
                    for each tt-rvs-pump:
                      create ub.rvs-pump.
                      buffer-copy tt-rvs-pump to ub.rvs-pump.
                    end.
                    for each tt-rvs-pump-attr:
                      create ub.rvs-pump-attr.
                      buffer-copy tt-rvs-pump-attr to ub.rvs-pump-attr.
                    end.
                    for each tt-rvs-line-pump:
                      create ub.rvs-line-pump.
                      buffer-copy tt-rvs-line-pump to ub.rvs-line-pump.
                    end.
                    for each tt-rvs-line-pump-attr:
                      create ub.rvs-line-pump-attr.
                      buffer-copy tt-rvs-line-pump-attr to ub.rvs-line-pump-attr.
                    end.
                  end.
                  vOk = yes.
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("rvs-temp.json") .
                      os-delete value("rvs.json") .
                    end.
                    vOk = chek_rvs-shift() and vok.
                    put-log(if vOk then "Сверка загружена" else "Сверка не загружена").
                    put-log("").
                    return vOk .
                  end finally.
                end method.
                method public logical chek_rvs-shift():
                  define buffer open-shift  for ub.shift-obj .
                  define buffer buf_rvs-doc for ub.rvs-doc .
                  find last open-shift where
                    open-shift.obj-type = v-cntxt-obj-type and
                    open-shift.obj-code = v-cntxt-obj-code and
                    open-shift.status_ = 'тек':U
                    use-index pi no-error.
                  if available open-shift
                    then
                    find first  buf_rvs-doc where buf_rvs-doc.obj-type eq v-cntxt-obj-type
                      and buf_rvs-doc.obj-code eq v-cntxt-obj-code
                      and buf_rvs-doc.shift-date eq open-shift.shift-date
                      and buf_rvs-doc.shift-num  eq open-shift.shift-num
                      and buf_rvs-doc.rvs-type eq 'смена':U
                      no-lock no-error.
                  return  available buf_rvs-doc.
                end method.
                method public logical close-rvs-all ():
                  put-log("Закрытие сменной сверки и смены.").
                  define variable vok as logical no-undo.
                  vok = close-rvs ().
                  if not vok
                    then
                    vok = close-rvs ().
                  finally:
                    vok =   chek_rvs-close() and vok.
                    put-log(if vOk then "Сверка закрыта" else "Сверка не закрыта").
                    return vok.
                  end.
                end method.
                method public logical close-rvs ():
                  define buffer buf_rvs-doc for ub.rvs-doc .
                  define buffer open-shift  for ub.shift-obj .
                  define variable vok as logical no-undo.
                  find last open-shift where
                    open-shift.obj-type = v-cntxt-obj-type and
                    open-shift.obj-code = v-cntxt-obj-code and
                    open-shift.status_ = 'тек':U
                    use-index pi no-error.
                  if available open-shift
                    then
                    find first  buf_rvs-doc where buf_rvs-doc.obj-type eq v-cntxt-obj-type
                      and buf_rvs-doc.obj-code eq v-cntxt-obj-code
                      and buf_rvs-doc.shift-date eq open-shift.shift-date
                      and buf_rvs-doc.shift-num  eq open-shift.shift-num
                      and buf_rvs-doc.rvs-type eq 'смена':U
                      no-lock no-error.
                  if available buf_rvs-doc
                    then
                    run str/rvs-close.p (this-object,buf_rvs-doc.rvs-code) .
                  vok = yes.
                  finally:
                    vok =   chek_rvs-close() and vok.
                    return vok.
                  end finally.
                end method.
                method public logical chek_rvs-close():
                  define buffer open-shift  for ub.shift-obj .
                  define buffer buf_rvs-doc for ub.rvs-doc .
                  find first  buf_rvs-doc where buf_rvs-doc.obj-type eq v-cntxt-obj-type
                    and buf_rvs-doc.obj-code   eq v-cntxt-obj-code
                    and buf_rvs-doc.rvs-type   eq 'смена':U
                    and buf_rvs-doc.status_    =  'факт':U
                    no-lock no-error.
                  return  available buf_rvs-doc.
                end method.
                method public logical chek_cash_passwd():
                  define variable v-has-records as logical no-undo.
                  v-has-records = can-find (first ub.staff where ub.staff.role     = 'C':U
                    and ub.staff.password <> "").
                  return v-has-records .
                end method.
                method public logical load_cash_passwd ( ) :
                  load_cash_passwd(mAddr).
                end method.
                method public logical load_cash_passwd (iaddr as character) :
                  define variable vcmd as character no-undo.
                  define variable vOk  as logical   no-undo.
                  vcmd = substitute ("&1 --http0.9 &2/THGetInfo?GetCashp >&3", search ("exe/curl.exe"), iaddr, "cashp-temp.json").
                  os-command silent value (vcmd).
                  fix-codepage_and_SetJsonObj (input "cashp-temp.json") .
                  empty temp-table tt-cash-passwd.
                  parse-json(input temp-table tt-cash-passwd:default-buffer-handle, input "tt-cash-passwd") .
                  define variable v-count-confirm   as integer   no-undo .
                  define variable v-count-decline   as integer   no-undo .
                  define variable v-logfile-confirm as character no-undo .
                  define variable v-logfile-decline as character no-undo .
                  assign
                    v-logfile-confirm = substitute("&1darw_util_pswd_ok.log", ibs.th.gbl.gbl-inipar:logDir)
                    v-logfile-decline = substitute("&1darw_util_pswd_err.log", ibs.th.gbl.gbl-inipar:logDir)
                    v-count-confirm   = 0
                    v-count-decline   = 0
                    .
                  output STREAM lsIN  to value(v-logfile-confirm).
                  put stream lsIN unformatted
                    "Загружено (код, пароль);код;пароль" skip .
                  output STREAM lsOUT to value(v-logfile-decline).
                  put stream lsOUT unformatted
                    "Отвергнуто (код, пароль);код;пароль;причина" skip .
                  put-log ( string(now) +  "   Начинаем загрузку паролей кассиров...") .
                  define buffer buf_staff for ub.staff .
                  for each tt-cash-passwd :
                    find first buf_staff no-lock
                      where buf_staff.staff-code = tt-cash-passwd.staff-code no-error.
                    if not available buf_staff
                      then
                    do:
                      v-count-decline = v-count-decline + 1 .
                      put stream lsOUT unformatted
                        substitute ("Отвергнуто (код, пароль);&1;&2;запись отсутствует в вер.16"
                        , tt-cash-passwd.staff-code, fill("*",length(tt-cash-passwd.password)))
                        skip.
                    end.
                    else if buf_staff.role ne 'C':U
                        then
                      do:
                        v-count-decline = v-count-decline + 1 .
                        put stream lsOUT unformatted
                          substitute ("Отвергнуто (код, пароль);&1;&2;пользователь не является кассиром в вер.16"
                          , tt-cash-passwd.staff-code, fill("*",length(tt-cash-passwd.password)))
                          skip.
                      end.
                      else
                      do:
                        find current buf_staff exclusive-lock no-error no-wait .
                        if available buf_staff then
                        do :
                          buf_staff.password = tt-cash-passwd.password no-error .
                          if error-status:error then
                          do :
                            v-count-decline = v-count-decline + 1 .
                            put stream lsOUT unformatted
                              substitute ("Отвергнуто (код, пароль);&1;&2;&3 в вер.16"
                              , tt-cash-passwd.staff-code, fill("*",length(tt-cash-passwd.password)), error-status:get-message(1))
                              skip.
                          end .
                          else
                          do :
                            v-count-confirm = v-count-confirm + 1 .
                            put stream lsIN unformatted
                              substitute ("Загружено (код, пароль);&1;&2"
                              , tt-cash-passwd.staff-code, fill("*",length(tt-cash-passwd.password)))
                              skip.
                          end .
                        end .
                        else if locked buf_staff then
                          do :
                            v-count-decline = v-count-decline + 1 .
                            put stream lsOUT unformatted
                              substitute ("Отвергнуто (код, пароль);&1;&2;запись кассира занята другим пользователем в вер.16"
                              , tt-cash-passwd.staff-code, fill("*",length(tt-cash-passwd.password)))
                              skip.
                          end .
                          else
                          do :
                            v-count-decline = v-count-decline + 1 .
                            put stream lsOUT unformatted
                              substitute ("Отвергнуто (код, пароль);&1;&2;запись кассира кто-то уже удалил в вер.16"
                              , tt-cash-passwd.staff-code, fill("*",length(tt-cash-passwd.password)))
                              skip.
                          end .
                      end .
                  end .
                  vok = yes.
                  define variable Msg as character no-undo .
                  catch exAppErrors as class Progress.Lang.AppError :
                    Msg = exAppErrors:ReturnValue .
                    if Msg > "" then .
                    else
                    do :
                      Msg = exAppErrors:GetMessage(1) .
                      if Msg > "" then .
                      else Msg = "AppError в фирмах" .
                    end .
                    put-log ( string(now) +  "   AppError " + Msg) .
                  end catch .
                  catch exProErrors as class Progress.Lang.ProError :
                    Msg = exProErrors:GetMessage(1) .
                    if Msg > "" then .
                    else Msg = "ProError в фирмах" .
                    put-log ( string(now) +  "   ProError " + Msg) .
                  end catch .
                  catch exAnyErrors as class Progress.Lang.Error:
                    Msg = "Unexpected error в фирмах" .
                    put-log ( string(now) +  "   LangError " + Msg) .
                  end catch .
                  finally:
                    if not mDebug then
                    do:
                      os-delete value("cashp-temp.json") .
                      os-delete value("cashp.json") .
                    end.
                    output STREAM lsIN close.
                    output STREAM lsOUT close.
                    if vok then
                      put-log( string( now) +
                        substitute("   Пароли кассиров загружены. Загружено &1 записей, отвергнуто &2 записей.",
                        v-count-confirm, v-count-decline
                        )
                        ) .
                    else
                      put-log( string( now) + "   Пароли кассиров не загружены!") .
                    put-log("").
                    return vok.
                  end finally.
                end method .
                method public character  cangecash (input pcashlist as character ):
                  define variable v-rid-list as character no-undo.
                  define variable ii         as integer   no-undo .
                  define buffer buf_cash-desk for ub.cash-desk.
                  run ref/cashlist.w (input parparentproc
                    ,input "b-sel,b-mark"
                    ,input 'объект':U
                    ,input v-cntxt-db-num
                    ,input v-host-code
                    ,input obj-type
                    ,input obj-code
                    ,input ?
                    ,output v-rid-list) no-error.
                  if error-status:error
                    or v-rid-list = '':U then
                  do:
                    return error.
                  end.
                  do ii = 1 to num-entries(v-rid-list):
                    find first buf_cash-desk no-lock where
                      recid(buf_cash-desk) = integer(entry(ii, v-rid-list)) no-error .
                    if available buf_cash-desk then
                    do:
                      if lookup(string(buf_cash-desk.cash-num),pcashlist) eq 0
                        then
                        pcashlist = pcashlist + "," + string(buf_cash-desk.cash-num).
                    end.
                  end.
                  pcashlist = trim(pcashlist,",").
                  return pcashlist.
                end method.
                method public logical  sendcleanCash (input pcashlist as character ):
                  define variable vi       as integer   no-undo.
                  define variable vreclist as character no-undo.
                  define buffer buf_cash-desk for ub.cash-desk.
                  put-log("Начинаем отправку команды 'резервного копирования базы кассы и удаления всех чеков' на кассы ").
                  do vi = 1 to num-entries(pcashlist):
                    find first buf_cash-desk no-lock where
                      buf_cash-desk.db-num   eq v-cntxt-db-num
                      and buf_cash-desk.obj-code eq obj-code
                      and buf_cash-desk.pos-type eq 'IBM-XML':U
                      and buf_cash-desk.cash-num = integer(entry(vi, pcashlist)) no-error .
                    if available buf_cash-desk
                      then
                    do:
                      if buf_cash-desk.cash-on  = yes
                        then
                        vreclist = vreclist + "," + string(recid(buf_cash-desk)).
                      else
                        put-log("Касса с номером '" + entry(vi, pcashlist) + "' выключена. Касса будет пропущена.").
                    end.
                    else
                      put-log("Не найдена касса с номером '" + entry(vi, pcashlist) + "'. Касса будет пропущена.").
                  end.
                  vreclist = trim(vreclist,",").
                  run utl/sendcode.p(this-object,15,vreclist).
                  put-log("").
                  return yes.
                end method.
              end class.
