block-level on error undo, throw.
/*

$Revision: 68fba9de0545, 1255, rls $
$Author: SSlivenko $
$Date: Mon Mar 19 12:52:28 2018 +0300 $
$Workfile: send-cur.p $
$Archive: str/send-cur.p $

отсылки курсов на кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/28/05
Author: Bakhtadze Natalya
Creation date: 09/28/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-action as character no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: 68fba9de0545, 1255, rls $":u .
define variable vss-author      as character   no-undo init "$Author: SSlivenko $":u .
define variable vss-date        as character no-undo init "$Date: Mon Mar 19 12:52:28 2018 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: send-cur.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/send-cur.p $":u .
define variable vss-description as character no-undo init "отсылки курсов на кассы" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define variable p-obj-type like ub.clients.obj-type no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo .
define variable action as character no-undo .

{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable s as character no-undo.
define variable right-curs as log no-undo.
define variable adr as character no-undo.
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable curr-list as character no-undo.
define variable ii as int no-undo.
define variable jj as int no-undo.
define variable name_ as character no-undo.
define variable abbr_ as character no-undo.
define variable scal_ as character no-undo.
define variable kurs_ as character no-undo.
define variable one-rubl as dec no-undo.
define variable one-usd as dec no-undo.
define variable one-val as dec no-undo.
define variable type as int no-undo.
define variable base-cass as int no-undo.

define variable kass-list as character no-undo.
define variable val-abbr as character no-undo.
define variable val-cass as character no-undo.
define variable val-shop as character no-undo.
define variable code as int no-undo.
define variable abbr as character no-undo.

define variable type-names  as  character  no-undo .
define variable kk                  as int      no-undo.
define variable kassa-rub-code       as integer no-undo.

define variable dec-buf          as dec      no-undo.
DEFINE VARIABLE conf-attr as character no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE conf-par as character no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE par-type as character no-undo.

define stream valutp1.
define stream valutp2.

define buffer b-curr-shop for ub.curr-shop .
define buffer b-currency for ub.currency .
define temp-table t-cs no-undo like ub.curr-shop
FIELD bexch-rate like ub.curr-bank.exch-rate
FIELD bexch-scale like ub.curr-bank.exch-scale
FIELD okv-code like ub.currency.okv-code
index pi is primary curr-code
.

define variable dob-curr as character no-undo.
/*define variable os-er as integer no-undo.*/
def buffer for-cash-desk for ub.cash-desk.
/*масштаб р_у_бля в курсах ЦБ РФ - нужен был до 1998 года и возможно ЕЩЕ ПОНАДОБИТСЯ*/

define variable temp-scale as integer no-undo init 1.
/*точность представления - кол-во знаков после зап*/
define variable rnd-znak as integer no-undo init 2.
define variable found as logical no-undo init no.
DEFINE VARIABLE fq as integer no-undo .
define variable v-err-txt as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-curr-r-b as character no-undo .
define variable dflt-cd as character no-undo .

/*PROCEDURE putc-1*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-1.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cycl1.i }

/*PROCEDURE SENDING.*/
{ str/cd-send1.i }


do
on error undo, return error
:


  assign
  p-obj-type = entry(1, p-parameter, {&delim-par})
  i-obj-code = integer(entry(2, p-parameter, {&delim-par}))
  action = entry(3, p-parameter, {&delim-par})
  no-error
  .
  if error-status:error  then return error.

  { gbl/hostcode.i
    p-obj-type
    i-obj-code
    v-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-rates_update':U
    {&cntxt-object}
    v-host-code
    p-obj-type
    i-obj-code
    0
    0
    0
    true
    glog
  }

  if NOT glog then  return .

  /*найдем масштаб р_у_бля*/
  { gbl/conf-rd.i
  "'rubscale'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  conf-par
  par-type
  no-error
  }
  IF not error-status:error then
  assign
  temp-scale = integer(conf-par) no-error.

  { gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
  for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_rnd-znk} then rnd-znak = thbjattr_thbj-attr.property-value-integer .
  end.

  { gbl/basecode.i v-host-code v-base-code }
  { gbl/dflt-cd.i p-obj-type i-obj-code dflt-cd }

/*сформируем временную таблицу на момент посылки*/
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if v-curr-r-b = {&r-b-base} then do:
    curr-list = "" .
    FOR EACH currency NO-LOCK :
        FIND LAST ub.curr-shop WHERE ub.curr-shop.obj-code = i-obj-code
                            and ub.curr-shop.obj-type = p-obj-type
                            and ub.curr-shop.curr-code = ub.currency.curr-code NO-ERROR .
                  if available ub.curr-shop then
                  curr-list = curr-list + string( ub.curr-shop.curr-code ) + {&comma-char} .
    END. /*FOR EACH currency*/
    curr-list = right-trim( curr-list, {&comma-char} ) .
    FIND LAST ub.curr-shop WHERE
                      ub.curr-shop.obj-code = i-obj-code and
                      ub.curr-shop.obj-type = p-obj-type and
                    ub.curr-shop.curr-code = v-base-code NO-ERROR.
    if available ub.curr-shop then
    one-rubl = ub.curr-shop.exch-rate / ub.curr-shop.exch-scale.
    else  do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!В БД отсутствует магазинный курс для базовой валюты &1 &2&3"
                            , v-base-code
                            , p-obj-type
                            , i-obj-code
                            )
                                            ).

      assign
      v-view-log = yes
      .
      return.
    end.
  end. /*if r-b = base*/
  FOR EACH ub.currency NO-LOCK :
    if dflt-cd = {&cd-type-nkt-ibm}
    and ub.currency.curr-code <> v-base-code
    and ub.currency.curr-code <> 0 then next.
    FIND LAST ub.curr-shop WHERE
            ub.curr-shop.obj-code = i-obj-code
        and ub.curr-shop.obj-type = p-obj-type
        and ub.curr-shop.curr-code = ub.currency.curr-code
        AND
                  (YEAR(ub.curr-shop.exch-date) = 9999) NO-ERROR .
    if not avail ub.curr-shop then
    FIND LAST ub.curr-shop WHERE
            ub.curr-shop.obj-code = i-obj-code
        and ub.curr-shop.obj-type = p-obj-type
        and ub.curr-shop.curr-code = ub.currency.curr-code No-ERROR.
     if not avail curr-shop then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!В БД отсутствует магазинный курс для валюты &1 &2&3"
                              ,  ub.currency.curr-code
                              , p-obj-type
                              , i-obj-code
                              )
                                              ).

        assign
        v-view-log = yes
        .
    end.
    if available ub.curr-shop then do:
      FIND LAST ub.curr-bank WHERE
                        ub.curr-bank.curr-code = ub.currency.curr-code AND
                        ub.curr-bank.exch-date <= today NO-ERROR.
      if NOT available ub.curr-bank and not ub.currency.curr-code = 0 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!В БД отсутствует текущий курс ЦБ РФ для валюты &1 &2&3"
                              ,  ub.currency.curr-code
                              , p-obj-type
                              , i-obj-code
                              )
                                              ).

        assign
        v-view-log = yes
        .
      end.
      else do:
        create t-cs.
        buffer-copy ub.curr-shop except exch-date exch-time to t-cs
        assign
        t-cs.exch-date = today
        t-cs.exch-time = time
        t-cs.bexch-rate = if ub.currency.curr-code = 0 then 1 else ub.curr-bank.exch-rate
        t-cs.bexch-scale = if ub.currency.curr-code = 0 then 1 else ub.curr-bank.exch-scale.
        if NOT YEAR(ub.curr-shop.exch-date) = 9999 then do:
            create b-curr-shop.
            buffer-copy ub.curr-shop except exch-date exch-time to b-curr-shop
            assign
            b-curr-shop.exch-date = today
            b-curr-shop.exch-time = time
            b-curr-shop.exch-date = DATE(1, 1, 9999).
        end.
      end. /*avail curr-bank*/
    end. /*avail curr-shop*/
  END .

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Пересылка на кассы &1&2 курсов валют", p-obj-type, i-obj-code)
                                            ).
  RUN SENDING no-error.
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибки при отсылке на кассы &1&2 курсов валют"
                          , p-obj-type
                          , i-obj-code
                          )
                                          ).

    assign
    v-view-log = yes
    .
  end.

  FOR EACH ub.currency No-LOCK,
    FIRST t-cs WHERE
          t-cs.curr-code = ub.currency.curr-code,
    FIRST ub.curr-shop WHERE
          ub.curr-shop.curr-code = ub.currency.curr-code AND
          ub.curr-shop.obj-type =  p-obj-type AND
          ub.curr-shop.obj-code = i-obj-code AND
          YEAR(ub.curr-shop.exch-date) = 9999:

    DO TRANSACTION:
      ASSIGN
      ub.curr-shop.exch-date = t-cs.exch-date
      ub.curr-shop.exch-time = t-cs.exch-time.
      DELETE t-cs.
    END.
  END.

  finally :
{ str/cdviewlg.i
"'!!!При отсылке информации на кассы произошли ошибки!!!'"
log-file-name not-delete }

    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).

    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).

  end finally .
end . /*doe*/

PROCEDURE out-back-curs :
FIND last ub.curr-shop WHERE
          ub.curr-shop.obj-code = i-obj-code AND
          ub.curr-shop.obj-type = p-obj-type AND
          ub.curr-shop.curr-code = v-base-code NO-ERROR.
if available ub.curr-shop then do:
  one-rubl = ub.curr-shop.exch-scale / ub.curr-shop.exch-rate.
  do ii = 1 to (if num-entries(curr-list) > 10 then 10 else num-entries(curr-list)):
    FIND FIRST ub.currency WHERE
            ub.currency.curr-code = int(entry(ii, curr-list)) NO-ERROR.
    if not available currency then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!В БД отсутствует валюта с кодом &1"
                            ,  int(entry(ii, curr-list))
                            )
                                            ).
      assign
      v-view-log = yes
      .
      output close.
      os-command silent value('del '+ out + fname + '.dat').
      undo,return error .
    end.
    FIND last t-cs WHERE t-cs.obj-code = i-obj-code AND
                         t-cs.obj-type = p-obj-type AND
                         t-cs.curr-code = int(entry(ii, curr-list)) use-index pi NO-ERROR.
      if available t-cs then do:
        if t-cs.curr-code <> 0 then do:
          one-usd = 1 / ( ( ( t-cs.exch-rate / t-cs.exch-scale ) ) * one-rubl ) .
          type = 4.
          if one-usd < 1000 then
          type = 3.
          if one-usd < 100 then
          type = 2.
          if one-usd < 10 then
          type = 1.
          if one-usd < 1 then
          type = 0.
          one-val = exp( 10, type ) / one-usd.
        end.
        else
        assign
        type = 1
        one-val = 1 .
      end.
      else do:
       type = 0.
       one-val = 0.
      end.
      name_ = name_ + caps(string(curr-name,'x(12)')).
      abbr_ = abbr_ + string(curr-abbr,'x(3)').
      scal_ = scal_ + string(type).
      kurs_ = kurs_ + string(one-val,'>>9.9999').
    end.
    do jj = ii + 1 to 10:
      scal_ = scal_ + '0'.
      kurs_ = kurs_ + '00000000'.
    end.
    name_ = string(name_,'x(120)').
    abbr_ = string(abbr_,'x(30)').
    put unformatted name_ abbr_ scal_ kurs_.
  end.
end.

PROCEDURE out-right-curs:

define variable hh as integer no-undo.
define variable CurCode like ub.currency.curr-code no-undo.

hh = ( if num-entries( curr-list ) > 10 then 10 else num-entries( curr-list ) ) .
DO ii = 1 TO hh :
  CurCode = int( entry( ii, curr-list ) ) .
  FIND FIRST ub.currency WHERE ub.currency.curr-code = CurCode NO-ERROR.
  if not available ub.currency then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!В БД отсутствует валюта с кодом &1"
                          ,  CurCode
                          )
                                          ).
    assign
    v-view-log = yes
    .
    output close.
    os-command silent value('del '+ out + fname + '.dat').
    undo,return error .
  end.
  FIND last t-cs WHERE t-cs.obj-code = i-obj-code AND
                       t-cs.obj-type = p-obj-type AND
                       t-cs.curr-code = CurCode NO-ERROR.
  if not available t-cs then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!В БД отсутствует валюта с кодом &1"
                          ,  CurCode
                          )
                                          ).
    assign
    v-view-log = yes
    .
    output close.
    os-command silent value('del '+ out + fname + '.dat').
    undo,return error .
  end.
  assign
  name_ = name_ + caps( string( curr-name, 'x(12)' ) )
  abbr_ = abbr_ + string( curr-abbr, 'x(3)' )
  scal_ = scal_ + "0" .
  if currency.curr-code = 0 then
  kurs_ = kurs_ + string( 1, '>>>>9.99' ).
  else
  kurs_ = kurs_ + string(t-cs.exch-rate / t-cs.exch-scale ,'>>>>9.99').
END .
DO jj = ii + 1 TO 10:
  assign
  scal_ = scal_ + '0'
  kurs_ = kurs_ + '00000000' .
END .
name_ = string(name_,'x(120)').
abbr_ = string(abbr_,'x(30)').

put unformatted name_ abbr_ scal_ kurs_.

end.

PROCEDURE out-back-curs-new-format :
FIND last ub.curr-shop WHERE
          ub.curr-shop.obj-code = i-obj-code AND
          ub.curr-shop.obj-type = p-obj-type AND
          ub.curr-shop.curr-code = v-base-code NO-ERROR.
if available ub.curr-shop then do:
  one-rubl = ub.curr-shop.exch-scale / ub.curr-shop.exch-rate.
  do ii = 1 to (if num-entries(curr-list) > 10 then 10 else num-entries(curr-list)):
    FIND FIRST ub.currency WHERE ub.currency.curr-code = int(entry(ii, curr-list)) NO-ERROR.
    if not available ub.currency then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!В БД отсутствует валюта с кодом &1"
                            ,  int(entry(ii, curr-list))
                            )
                                            ).
      assign
      v-view-log = yes
      .
      output close.
      os-command silent value('del '+ out + fname + '.dat').
      undo, return error.
    end.
    FIND last t-cs WHERE t-cs.obj-code = i-obj-code AND
                         t-cs.obj-type = p-obj-type AND
                         t-cs.curr-code = int(entry(ii, curr-list)) use-index pi NO-ERROR.
    if available t-cs then do:
      if t-cs.curr-code <> 0 then do:
        one-usd = 1 / ( ( ( t-cs.exch-rate / t-cs.exch-scale ) ) * one-rubl ) .
        type = 4.
        if one-usd < 1000 then
        type = 3.
        if one-usd < 100 then
        type = 2.
        if one-usd < 10 then
        type = 1.
        if one-usd < 1 then
        type = 0.
        one-val = exp( 10, type ) / one-usd.
      end.
      else
      assign
      type = 1
      one-val = 1 .
    end.
    else do:
      type = 0.
      one-val = 0.
    end.
    assign
    name_ =  caps(string(curr-name,'x(12)'))
    abbr_ =  string(curr-abbr,'x(3)')
    scal_ =  string(type)
    kurs_ =  string(one-val,'999.9999')
    .
    put unformatted
    string(currency.curr-code, "99":U)
    name_
    abbr_
    string(v-base-code, "999":U)
    scal_
    kurs_
    fill('0':U, 71)
    skip.
  end. /*do ii*/
end. /*if avail*/
end PROCEDURE.

PROCEDURE out-right-curs-new-format:

define variable hh as integer no-undo.
define variable CurCode like ub.currency.curr-code no-undo.

hh = ( if num-entries( curr-list ) > 10 then 10 else num-entries( curr-list ) ) .
DO ii = 1 TO hh :
  CurCode = int( entry( ii, curr-list ) ) .
  FIND FIRST ub.currency WHERE ub.currency.curr-code = CurCode NO-ERROR.
  if not available ub.currency then do:
    output close.
    os-command silent value('del '+ out + fname + '.dat').
    message "В базе отсутствует валюта с кодом " string(int(entry(ii, curr-list)))
    view-as alert-box WARNING .
    undo,return.
  end.
  FIND last t-cs WHERE t-cs.obj-code = i-obj-code AND
                       t-cs.obj-type = p-obj-type AND
                       t-cs.curr-code = CurCode NO-ERROR.
  if not available t-cs then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!В БД отсутствует валюта с кодом &1"
                          ,  CurCode
                          )
                                          ).
    assign
    v-view-log = yes
    .
    output close.
    os-command silent value('del '+ out + fname + '.dat').
    undo, return error.
  end.
  assign
  name_ = caps( string( curr-name, 'x(12)' ) )
  abbr_ = string( curr-abbr, 'x(3)' )
  scal_ =  "0" .
  if currency.curr-code = 0 then
  kurs_ = string( 1, '999.99' ).
  else
  kurs_ = string(t-cs.exch-rate / t-cs.exch-scale ,'999.99').
  put unformatted
  string(currency.curr-code, "99":U)
  name_
  abbr_
  string(0, "999":U)
  scal_
  kurs_
  fill('0', 71)
  skip.
END . /*do-ii*/

end PROCEDURE.