/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Блок обработки строк чека - как только продажных так и возвратных - которые рождаются на втором проходе чикла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/04/05
Author: Bakhtadze Natalya
Creation date: 02/04/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

assign
v-gds-create-write-off = no
v-gds-create-return = no
gds-sign = 1
gds-wo-type = chk-type_
.
&if "{1}" = "temp-archeck" &then
find first buf_cd-plu no-lock where
          buf_cd-plu.obj-type = p-obj-type
      and buf_cd-plu.obj-code = p-obj-code
      and buf_cd-plu.pos-type = {&cd-type-r-keeper}
      and buf_cd-plu.plu-type = (if {1}.component then 'modifier':U else '':U)
      and buf_cd-plu.plu-code = (/*(if {1}.component then - 1 else 1 ) **/ {1}.sifr) no-error.
&else
find first buf_cd-plu no-lock where
          buf_cd-plu.obj-type = p-obj-type
      and buf_cd-plu.obj-code = p-obj-code
      and buf_cd-plu.pos-type = {&cd-type-r-keeper}
      and buf_cd-plu.plu-type = '':U
      and buf_cd-plu.plu-code = ((if {1}.comp > 0 then - 1 else 1 ) * {1}.sifr) no-error.
&endif
if available buf_cd-plu then do:
  if buf_cd-plu.b-code > 0 then do:
    assign
    bc-buf = string(buf_cd-plu.b-code)
    .
  end.
  else do:
    run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Для строки чека &1 кассы &2 блюдo/модификатор с идентификатором &3&4" +
                              "не привязано к товару в IBS TH&4" +
                              "чек не будет сохранен и обработан"
                              , temp-acheck.cnum
                              , temp-acheck.unit
                              , {1}.sifr
                              , {&new-line}
                            )    ).
    assign
    p-view-log = yes
    .
    run save-for-future in this-procedure .
    undo  _temp-acheck, next _temp-acheck.
  end.
end.
else do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Для строки чека &1 кассы &2 не найдено блюдo с идентификатором &3&4" +
                            "чек не будет сохранен и обработан"
                            , temp-acheck.cnum
                            , temp-acheck.unit
                            , {1}.sifr
                            , {&new-line}
                          )    ).
  assign
  p-view-log = yes
  .
  run save-for-future in this-procedure .
  undo  _temp-acheck, next _temp-acheck.
/*  assign
  bc-buf = "0".*/
end.
&if "{1}" = "temp-avcheck" &then
find first temp-reasons no-lock where
          temp-reasons.sifr = temp-avcheck.reason no-error.
if not available temp-reasons then do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Для удаленной строки (товар с идентификатором & 5) чека &1 кассы &2 не найдена причина отмены с идентификатором &3&4" +
                            "чек не будет сохранен и обработан"
                            , temp-acheck.cnum
                            , temp-acheck.unit
                            , temp-acheck.deleted
                            , temp-avcheck.sifr
                            , {&new-line}
                          )    ).
  assign
  p-view-log = yes
  .
  run save-for-future in this-procedure .
  undo _temp-acheck, next _temp-acheck.
end.
if temp-reasons.used then do:
  assign
  v-gds-create-write-off = yes
  gds-wo-type2 = integer({&rcpt-return-write-off})
  gds-sign2  = - 1
  .
end.
else do:
  assign
  v-gds-create-return = yes
  gds-wo-type2 = integer({&rcpt-return})
  gds-sign2  = - 1
  .
end.
&endif

&glob gds-sign (if jj = 1 then gds-sign else gds-sign2) * ~{&chk-sign~}
/*будем лищние генерить только если списывать надо*/
/*if not v-gds-create-return then do:*/
_do-gds:
do jj = 1 to 2:
  CREATE ub.chk-gds.
  assign
  lng = lng + 1
  ub.chk-gds.doc-code = chk-doc.doc-code
  ub.chk-gds.line-num = lng
  ub.chk-gds.grp-code = 0
  ub.chk-gds.chk-date = chk-doc.chk-date
  ub.chk-gds.b-code = 0
  ub.chk-gds.src-code  = bc-buf
  ub.chk-gds.src-price = {1}.price
  ub.chk-gds.src-sum   = {1}.price * {1}.qnt
  ub.chk-gds.src-qnty = {&gds-sign} * {1}.qnt
  ub.chk-gds.doc-qnty = {&gds-sign} * {1}.qnt
  ub.chk-gds.price-service = 0
&if "{1}" = "temp-avcheck" &then
  ub.chk-gds.time-oper = (temp-avcheck.del-time - integer(temp-avcheck.realdate) ) * 10000
&else
  ub.chk-gds.time-oper = chk-doc.chk-time
&endif
  ub.chk-gds.src-discnt = 0
  ub.chk-gds.pass-gds = ?
  ub.chk-gds.is-error = no
  ub.chk-gds.pump = 0
  ub.chk-gds.road-tax = 0
  ub.chk-gds.depart-id = p-obj-code
  &if "{1}" = "temp-archeck" &then
  /*в этом месте блюда удаленных чеков*/
  ub.chk-gds.write-off-code = if v-create-write-off and ii = 2
                           then (if not temp-archeck.component
                                 then integer({&wro-cancell-all})
                                 else integer({&wro-v-modificator-ca})
                                 )
                           else  (if not temp-archeck.component
                                 then 0
                                 else (if chk-doc.chk-type =  integer({&rcpt-sale})
                                       then  integer({&wro-r-modificator})
                                       else  integer({&wro-v-modificator})
                                      )
                                 )
  &endif
  &if "{1}" = "temp-avcheck" &then
  /*удаленные из чеков блюда*/
  ub.chk-gds.write-off-code = if v-gds-create-write-off
                           then (if temp-avcheck.comp = 0
                                 then  integer({&wro-without-payment})
                                 else (if chk-doc.chk-type =  integer({&rcpt-sale})
                                       then  integer({&wro-r-modificator-wp})
                                       else  integer({&wro-v-modificator-ci})
                                      )
                                 )
                           else (if temp-avcheck.comp = 0
                                 then 0
                                 else (if chk-doc.chk-type =  integer({&rcpt-sale})
                                       then  integer({&wro-r-modificator})
                                       else  integer({&wro-v-modificator})
                                      )
                                )
  &endif
  ub.chk-gds.sales-man = chk-doc.sales-man
  /*
  ub.chk-gds.src-d-card = (if d-card_ <> "":U then d-card_ else ?)
  ub.chk-gds.src-cli-type = (if cli-type_ = "":u then ? else cli-type_)
  ub.chk-gds.src-cli-code = (if cli-code_ = 0 then ? else cli-code_)
  ub.chk-gds.d-card = if d-mask_ <> "":U then d-mask_ else ub.chk-gds.d-card
  chk-doc.src-d-card       = (if d-card_ = "":U
                            or chk-doc.src-d-card = d-card_
                            then chk-doc.src-d-card
                            else (if not v-flag-card
                                  and (chk-doc.src-d-card = ? or chk-doc.src-d-card = "":U)
                                  then d-card_
                                  else "-0":U
                                  )
                            )
  chk-doc.src-cli-type   = (if cli-type_ = "":U
                            or chk-doc.src-cli-type = cli-type_
                            then chk-doc.src-cli-type
                            else (if not v-flag-card
                                  and (chk-doc.src-cli-type = ? or chk-doc.src-cli-type = "":U)
                                  then cli-type_
                                  else ?)
                          )
  chk-doc.src-cli-code   = (if cli-code_ = 0
                            or chk-doc.src-cli-code = cli-code_
                            then chk-doc.src-cli-code
                            else (if not v-flag-card
                                  and (chk-doc.src-cli-code = ? or chk-doc.src-cli-code = 0)
                                  then cli-code_
                                  else ?)
                          )
  chk-doc.d-card = if d-mask_ <> "":U then d-mask_ else chk-doc.d-card
  v-flag-card         = (if not v-flag-card  and d-card_ <> "":U
                      then yes
                      else v-flag-card)
  */
  ub.chk-gds.line-sign = (if chk-doc.chk-type = integer({&rcpt-sale})
                      then (chk-gds.src-qnty >= 0)
                      else (chk-gds.src-qnty <= 0)
                      )
  ub.chk-gds.line-type = '':U
  netto-for-sub-d = netto-for-sub-d +
  (if ub.chk-gds.write-off-code = ?
  or ub.chk-gds.write-off-code <= 0
  then
  ((chk-gds.src-price - ub.chk-gds.src-discnt) * {&gds-sign} * ub.chk-gds.src-qnty)
  else 0)
  .
  if not v-gds-create-return then leave _do-gds.
end.
/*end. /*if not v-gds-create-return*/*/
/* $Workfile$ e n d */