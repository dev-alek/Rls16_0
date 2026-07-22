/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура резервирования / снятия резервов для документа продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
define variable rsrv-title                  as character no-undo . /*титл сообщения*/
define variable rgds-dtl                    as recid no-undo .
define variable cashplace                   as logical no-undo .  /*СКЛАДСКОМЕСТНЫЙ*/
define variable cashparts                   as logical no-undo . /*ПАРТИОННЫЙ*/
define variable cashfbr                     as logical no-undo . /*проиводимый*/
define variable btltaxcd                    as INTEGER                  no-undo.
define variable btltaxunittypes             as char no-undo.
DEFINE VARIABLE bottle as logical no-undo .
/*количество резервируемых позиций*/
define variable num_rec                     as integer no-undo .
/*количество зарезервированных позиций*/
define variable num_rec_res                 as integer no-undo.
/*количество резервируемых позиций чужих товаров*/
define variable num_rec_other                as integer no-undo .
/*количество зарезервированных позиций чужих товаров*/
define variable num_rec_other_res            as integer no-undo.
define variable cost-base                    as decimal no-undo .
define variable cost-rubl                    as decimal no-undo .
/*сколько именно надо снять с резерва - используется при компенсации*/
define variable r-qnty                      as decimal no-undo .
/*с какого складского места при продаже по складскому месту*/
define variable r-pl-code                   as integer no-undo .
/*с какой партии надо снять - используется при продаже по партиям и компенсации*/
define variable r-b-code                    as integer no-undo .
/*с какой партии надо снять - используется при продаже по партиям и компенсации при twounit*/
define variable r-doc-prts-qnty             as decimal no-undo .
/**/
define variable r-artic                     like ub.doc-line.artic no-undo .
define variable r-prod-type                 like ub.doc-line.prod-type no-undo .
define variable r-prod-code                 like ub.doc-line.prod-code no-undo .
define variable r-prt-code                  like ub.gds-dtl.prt-code no-undo .
{ cmp/croslist.i }
{ cmp/strcodec.i }
{ str/is-gas.i }
&else

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE RSRv-line:
define input parameter p-r-v                as integer no-undo . /*1 расход - 1 возврат*/
define input parameter p-auto-fbr           as logical no-undo . /*можно ли резервировать производство ресторана?*/
define input parameter p-rsrv-prop-goods    as logical no-undo . /*резервировать чужие товары на своем объекте только при закрытии как и p-auto-fbr*/
define input parameter p-auto-fbr-on        as logical no-undo . /*включена ли настройка auto-fbr и check-box*/
&if "{1}" = "sale" &then
define input parameter p-rest-dish          as logical no-undo .
define input parameter p-fbr-income-doc-code like ub.trn-doc.doc-code no-undo .
&else
define variable p-rest-dish                 as logical no-undo .
define variable p-fbr-income-doc-code       like ub.trn-doc.doc-code no-undo.
&endif
define input parameter p-tpsi-obj           as logical no-undo .
define input parameter p-rest-tpsi          as logical no-undo .
DEFINE INPUT PARAMETER rz                   as logical no-undo. /*резерв.снятие*/
DEFINE INPUT PARAMETER gdscode              like ub.goods.gds-code.
DEFINE INPUT PARAMETER nodecode             like ub.gds-prt.node-code.
define output parameter p-run-tpsi          as logical no-undo .
DEFINE parameter buffer b-doc-line for ub.doc-line.
DEFINE parameter buffer b-trn-doc for ub.trn-doc.
define parameter buffer buf_sale-doc for ub.sale-doc.

define buffer loc-doc-prts for ub.doc-prts.
define buffer loc-doc-pl for ub.doc-pl.
define buffer loc-doc-fbr-gds for ub.doc-fbr-gds.
DEFINE BUFFER loc-gds-dtl for ub.gds-dtl.
define buffer buf_parts for ub.parts .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl  for ub.gds-dtl.
define buffer buf_doc-fbr-gds for ub.doc-fbr-gds .
define variable res-qnty                    as decimal no-undo.
define variable gds-dtl-res-qnty            as decimal no-undo.
define variable no-partion-qnty             as decimal no-undo.
define variable no-place-qnty               as decimal no-undo.
define variable res-parts                   as decimal no-undo.
define variable ser-chg-qnty                as decimal no-undo.  /* Запрашиваемое количество cсерийного товара*/
define variable pl-chg-qnty                 as decimal no-undo.  /* Запрашиваемое количество cкладско-местного товара*/
define variable pl-chg-cli-qnty             as decimal no-undo.  /* Запрашиваемое количество cкладско-местного товара*/
define variable old-pl-qnty                 as decimal no-undo.  /* Уже зарезервированное количество cкладско-местного товара*/
define variable new-pl-qnty                 as decimal no-undo.  /* Необходимое для резервирования количество cкладско-местного товара*/
define variable chg-qnty                    as decimal no-undo.  /* Запрашиваемое количество */
define variable fbr-qnty                    as decimal no-undo .
define variable fbr-chg-qnty                as decimal no-undo .
define variable parts-OK                    as logical no-undo init yes.
define variable place-OK                    as logical no-undo init yes.
define variable rsrv-option                 as character no-undo.
define variable rsrv-option-place           as character no-undo.
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-is-own                    as logical no-undo .
define variable v-to-reserv                 as logical no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-doc-qnty      like ub.gds-dtl.fact-qnty no-undo .
define variable v-return-st-fl              as logical no-undo .
define variable v-return-status             like ub.trn-doc.status_ no-undo .
define variable v-return-flag               like ub.trn-doc.flag    no-undo .
define variable v-dop-sale-negative-check   as character no-undo .
define variable v-nc-option                 as character no-undo .
define variable current-rgds-dtl            as recid no-undo .
define variable v-qnty                      as decimal no-undo .
define variable v-cli-qnty                  as decimal no-undo .
define variable v-err-msg                   as character no-undo .

&scop num_rec_plus if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl)
&scop num_rec_res_plus if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or ~
                          (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end


define buffer tpsi_sale-doc for ub.sale-doc.
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
{ str/in-vatp.i def b-doc-line.  b-trn-doc. g }
&if "{1}" = "sale" &then
define buffer buf_dtl-rests for dtl-rests.
if buf_sale-doc.in-inkas = no
and not can-find(first dtl-rests no-lock where dtl-rests.gds-code = gdscode) then do:
   v-dop-sale-negative-check = ',' + {&rsrv-dtl_negative-check} + "=1".
end.
&else
  if not rz and v-dop-sale-negative-check = '':U then v-dop-sale-negative-check = ',' + {&rsrv-dtl_negative-check} + "=1".
&endif

if not p-rsrv-prop-goods    /*в режиме закрытия все резервируется со своего объекта*/
AND (p-tpsi-obj
and p-r-v = 1 /*и расход*/
and not cashplace
and not cashparts
and not b-trn-doc.office)
then do:
  run tpsi-gds-proprietor in this-procedure (
                                              input gdscode
                                             ,input g#db-num
                                             ,output v-proprietor-host-code
                                             ,output v-proprietor-obj-type
                                             ,output v-proprietor-obj-code ) no-error .
  if error-status:error then do:
    num_rec = num_rec + 1.
    undo, return error substitute("Ошибки при проверке атрибута товара на объекте ПРИНАДЛЕЖНОСТЬ ТОВАРА для товара с кодом &1 на БД &2:&3&4 &5"
                                  ,gdscode
                                  ,g#db-num
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
  end.
  if (v-proprietor-obj-type = "":U
      and
      v-proprietor-obj-code = 0)
  or v-proprietor-obj-code = ?
      then do:
    num_rec = num_rec + 1.
    undo, return error substitute("Не установлен атрибут товара на объекте ПРИНАДЛЕЖНОСТЬ ТОВАРА для товара с кодом &1 ни для одного объекта БД &2"
                                  ,gdscode
                                  ,g#db-num
                                  ).
  end.
  if (v-proprietor-obj-type = b-trn-doc.obj-type
  and v-proprietor-obj-code = b-trn-doc.obj-code)
  then do:
    assign
    v-is-own = yes
    .
  end.
  else do:
    assign
    p-run-tpsi = yes.
    if v-proprietor-host-code = v-host-code then do:
      assign
      v-ext-doc-type = {&TDEDT_Ras_Perem} .
    end.
    else do:
      assign
      v-ext-doc-type =  {&TDEDT_Ras_Vnesh} .
    end.
    find first tpsi_sale-doc no-lock where
              tpsi_sale-doc.inkas-code = buf_sale-doc.inkas-code
          and tpsi_sale-doc.tpsidoc = yes
          and tpsi_sale-doc.obj-type = v-proprietor-obj-type
          AND tpsi_sale-doc.obj-code = v-proprietor-obj-code
          AND tpsi_sale-doc.ext-doc-type = v-ext-doc-type  no-error .
   end.
end.
/*если не tpsi объект
или не расход
или складскоместный
или партионный/серийный
или УСЛУГИ
то считаем его своим - ОН ДОЛЖЕН БЫТЬ ЗАРЕЗЕРВИРОВАН У НАС НА ОБЪЕКТЕ !!!!!!!!*/
else v-is-own = yes.
if v-is-own then do:
  assign
  v-to-reserv = yes
&if "{2}" = "auto" &then
   rsrv-option =  (if (rgds-dtl = ?) and not p-auto-fbr
                  then {&rsrv-dtl_action_reserv}  + ',' + {&rsrv-dtl_no-msg-no-chk-acta-cr}
                  else {&rsrv-dtl_action_reserv}
                  )
&else
  rsrv-option = (if (rgds-dtl = ?) and not p-auto-fbr
                  then {&rsrv-dtl_action_reserv}  + ',' + {&rsrv-dtl_no-message}
                  else {&rsrv-dtl_action_reserv}
                  )
&endif
  + v-dop-sale-negative-check
  .
  /*товары производимые не резервируем*/
  if cashfbr and p-auto-fbr-on and rz and not p-auto-fbr then return.
&if "{1}" = "sale" &then
  if p-tpsi-obj
  and p-rsrv-prop-goods = yes then do:
    find first buf_dtl-rests no-lock where
              buf_dtl-rests.gds-code = gdscode no-error .
    if available buf_dtl-rests
    and buf_dtl-rests.prop > 0
    and buf_dtl-rests.ok-prop then do:
      assign
      v-nc-option = "=1":U.
      assign
      rsrv-option = rsrv-option + ',' + {&rsrv-dtl_negative-check} + v-nc-option
      .
    end.
  end.
&endif
end.
else do:
  /*товары производства если они одновеременно чужие - будем перемещать а не производить*/
  assign
  cashfbr = no.
  if p-rest-tpsi or rz = no then do:
    assign
    v-nc-option = "=2":U.
    assign
    v-to-reserv = yes
&if "{2}" = "auto" &then
    rsrv-option =  {&rsrv-dtl_action_reserv}  + ',' + {&rsrv-dtl_no-msg-no-chk-acta-cr} + ',' + {&rsrv-dtl_negative-check} + v-nc-option
&else
    rsrv-option = (if (rgds-dtl = ?) and not p-auto-fbr
                    then {&rsrv-dtl_action_reserv}  + ',' + {&rsrv-dtl_no-message} + ',' + {&rsrv-dtl_negative-check} + v-nc-option
                    else {&rsrv-dtl_action_reserv}  + ',' + {&rsrv-dtl_negative-check} + v-nc-option
                    )
&endif
    .
    if p-rest-tpsi then do:
      assign
      rsrv-option = rsrv-option + ',' + {&rsrv-dtl_sale-negative-check-on}
      .
    end.
  end.
  /*найдем запись во временной таблице - если нет ее то создадим*/

end.

if cashfbr
and (not p-rest-dish)
and p-auto-fbr-on and rz
and p-fbr-income-doc-code <> "":U
then do:
  _parts:
  for each buf_parts no-lock
      where buf_parts.obj-type  = b-trn-doc.obj-type
        and buf_parts.obj-code  = b-trn-doc.obj-code
        and buf_parts.prod-type = b-doc-line.prod-type
        and buf_parts.prod-code = b-doc-line.prod-code
        and buf_parts.artic     = b-doc-line.artic
        and buf_parts.status_   = yes
        and buf_parts.out-code  = p-fbr-income-doc-code
  on error undo, return error return-value
    :
    assign
    rsrv-option = {&rsrv-dtl_action_reserv}
                    /*+ "," + {&rsrv-dtl_no-message}*/
                    + "," + {&rsrv-dtl_rsrv-single-part}
                    + "," + {&rsrv-dtl_rsrv-in-code}   + "=":u + str-encode ( buf_parts.in-code  ,  "", ",=":u )
                    + "," + {&rsrv-dtl_rsrv-part-code} + "=":u + str-encode ( buf_parts.part-code,  "", ",=":u )
&if "{2}" = "auto" &then
    rsrv-option = rsrv-option  + ',' + {&rsrv-dtl_no-msg-no-chk-acta-cr}
&endif
    .
    leave _parts.
  end. /*for each buf_parts no-lock*/
end. /* if cashfbr  ...*/

if cashplace then do: /*складскоместный*/
  FIND FIRST loc-gds-dtl WHERE
          loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
          loc-gds-dtl.artic = b-doc-line.artic AND
          loc-gds-dtl.prod-type = b-doc-line.prod-type AND
          loc-gds-dtl.prod-code = b-doc-line.prod-code AND
          loc-gds-dtl.prt-code = nodecode
          EXCLUSIVE-LOCK NO-ERROR.
  IF rz  and loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then LEAVE.
  IF NOT rz and loc-gds-dtl.doc-qnty = 0 then LEAVE.
  IF NOT (rgds-dtl = ?) AND NOT recid(loc-gds-dtl) = rgds-dtl THEN LEAVE.
&scop my-count-message  substitute("&1 - обработано &2, из них успешно - &3" ~
                                                        , rsrv-title         ~
                                                        , num_rec            ~
                                                        , num_rec_res)
  if ( num_rec modulo 10 ) = 0 then
{&display-count-message}.

  if rz then
  find first buf_tt0-gds-dtl no-lock where
            buf_tt0-gds-dtl.artic = loc-gds-dtl.artic
       AND  buf_tt0-gds-dtl.prod-type = loc-gds-dtl.prod-type
       AND  buf_tt0-gds-dtl.prod-code = loc-gds-dtl.prod-code
       AND  buf_tt0-gds-dtl.prt-code  = loc-gds-dtl.prt-code no-error .
  assign
  chg-qnty   = 0.0
  res-qnty   = 0.0
  cost-base  = 0.0
  cost-rubl  = 0.0
  v-qnty     = 0.0
  v-cli-qnty = 0.0
  gds-dtl-res-qnty = if rz
                    then ((loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty) + (if available buf_tt0-gds-dtl
                                                                            then (buf_tt0-gds-dtl.fact-qnty - buf_tt0-gds-dtl.doc-qnty)
                                                                            else 0))
                    else (if r-qnty = ?
                          then (- loc-gds-dtl.doc-qnty)
                          else r-qnty)
  .
  _docpl:
  FOR EACH loc-doc-pl where
            loc-doc-pl.gds-code = gdscode AND
            loc-doc-pl.out-code = b-doc-line.doc-code ON ERROR UNDO, NEXT:
    assign
    v-qnty                  = v-qnty + loc-doc-pl.doc-qnty
    v-cli-qnty              = v-cli-qnty + loc-doc-pl.cli-doc-qnty
    .
    if rz and loc-doc-pl.fact-qnty <= loc-doc-pl.doc-qnty then NEXT.
    if not rz and loc-doc-pl.doc-qnty = 0 then NEXT.
    if NOT r-pl-code = ? AND r-pl-code <> loc-doc-pl.pl-code then NEXT.
    assign
    v-err-msg       = "":U
    pl-chg-qnty     = (if rz then loc-doc-pl.fact-qnty     else 0.0 ) - loc-doc-pl.doc-qnty
    pl-chg-cli-qnty = (if rz then loc-doc-pl.cli-fact-qnty else 0.0 ) - loc-doc-pl.cli-doc-qnty
    res-qnty = res-qnty + pl-chg-qnty
    no-partion-qnty = gds-dtl-res-qnty - res-qnty
    cost-base = 0
    cost-rubl = 0
    rsrv-option-place = rsrv-option + "," + {&rsrv-dtl_pl-code} + "=" + string(loc-doc-pl.pl-code)
&if "{2}" = "auto" &then
   rsrv-option  = rsrv-option  + ',' + {&rsrv-dtl_no-msg-no-chk-acta-cr}
                               + ',' + {&rsrv-dtl_negative-check} + "=1"
&endif
    .
    if b-trn-doc.status_ = {&doc-froze}
    or b-trn-doc.flag <> no
    then do:
      assign
      v-return-status =  b-trn-doc.status_
      v-return-flag = b-trn-doc.flag
      b-trn-doc.status_ = {&wayb}
      b-trn-doc.flag = no
      v-return-st-fl = yes
      .
    end.
    /*нет резервирования по складским местам чужих товаров!!!!!!!!!!!!!!*/
    if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> {&TDEDT_Vozvrat_Vnesh_Kass})
    then do :
      {&num_rec_plus}.
    end.

    /* снимаем полностью все резервы по месту хранения */
    assign
      old-pl-qnty = (- loc-doc-pl.doc-qnty)
    .
    if old-pl-qnty <> 0.0 then do:
      run trg/rsrv-dtl.p (
                      input parparentproc
                      ,input rsrv-option-place
                      ,buffer loc-gds-dtl
                      ,input-output old-pl-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      ,-1, "" ) no-error.
      if error-status :error then do:
        assign
        v-err-msg = substitute( "Ошибка при разрезервировании.&1&2"
                               , {&new-line}
                               , return-value
                              )
        .
      end.
      else do:
        if old-pl-qnty <> (- loc-doc-pl.doc-qnty) then do:
          assign
          v-err-msg = substitute( "Не удалось снять резервы по ранее зарезервированному количеству.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                , {&new-line}
                                , (- loc-doc-pl.doc-qnty)
                                , old-pl-qnty
                                )
          .
        end.
      end.
      if v-err-msg <> "":U then do:
&if "{2}" = "auto" &then
&scop my-message v-err-msg
{&display-message}.
&endif
&if "{2}" = "excl-chk" &then
        v-return-st-fl = no.
        undo _docpl, return error v-err-msg .
&else
        v-return-st-fl = no.
        undo _docpl, NEXT.
&endif
      end.
    end.

    /* полностью резервируем все новое кол-во */
    assign
    loc-doc-pl.doc-qnty     = loc-doc-pl.doc-qnty     + pl-chg-qnty
    loc-doc-pl.cli-doc-qnty = loc-doc-pl.cli-doc-qnty + pl-chg-cli-qnty
    loc-doc-pl.cli-qnty     = loc-doc-pl.cli-doc-qnty
    new-pl-qnty             = loc-doc-pl.doc-qnty
    v-qnty                  = v-qnty + pl-chg-qnty
    v-cli-qnty              = v-cli-qnty + pl-chg-cli-qnty
    .

    if new-pl-qnty <> 0.0 then do:
      run trg/rsrv-dtl.p (
                      input parparentproc
                      ,input rsrv-option-place
                      ,buffer loc-gds-dtl
                      ,input-output new-pl-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      ,-1 
                      ,"") no-error.
      if error-status :error then do:
        assign
        v-err-msg = substitute( "Ошибка при резервировании.&1&2"
                              , {&new-line}
                              , return-value
                              )
        .
      end.
      else do:
        if new-pl-qnty <> loc-doc-pl.doc-qnty then do:
          assign
          v-err-msg = substitute( "Не удалось зарезервировать все запрошенное количество.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                , {&new-line}
                                , loc-doc-pl.doc-qnty - old-pl-qnty
                                , new-pl-qnty - old-pl-qnty
                                )
          .
        end.
      end.
      if v-err-msg <> "":U then do:
&if "{2}" = "auto" &then
&scop my-message v-err-msg
if not is-gas(gdscode)
then do :
{&display-message}.
end.
&endif
&if "{2}" = "excl-chk" &then
        v-return-st-fl = no.
        undo _docpl, return error v-err-msg .
&else
        v-return-st-fl = no.
        undo _docpl, NEXT.
&endif
      end.
    end.
    if v-return-st-fl then do:
      assign
      b-trn-doc.status_ = v-return-status
      b-trn-doc.flag = v-return-flag
      v-return-st-fl = no
      .
    end.
&if "{2}" = "auto" &then
if pl-chg-qnty <> new-pl-qnty - old-pl-qnty then do:
  &scop my-message return-value
  {&display-message}.
end.
&endif
    assign
    chg-qnty = chg-qnty + pl-chg-qnty
    .
  END.
  if v-qnty <> 0.0
    and v-cli-qnty <> 0.0
  then do:
    assign
    b-doc-line.doc-density = v-cli-qnty / v-qnty
    .
  end.
  if chg-qnty <> 0 then  do:
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      b-doc-line.cli-qnty = v-cli-qnty
      .
      {&num_rec_res_plus}.
      if bottle then do:
        { str/in-vatp.i calc b-doc-line. b-trn-doc. g }
        assign
        b-doc-line.road-tax = (if v-curr-r-b = {&r-b-rubl} then road-tax-rubl-loc else road-tax-base-loc).
      end.
      if rz then do:
        if b-trn-doc.print-rubl then
        assign
        loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
        loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                 then 0
                                 else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .
        else
        assign
        loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                 then 0
                                 else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base) .
      end.
    end.
    /*по местам все ОК*/
    if chg-qnty = res-qnty then place-ok = yes.
    else place-ok = no.
    /*па партиям все нормально, непартионной части нет вообще*/
    release loc-gds-dtl.
    /*не удалось по всем партиям зарезервировать  - тогда дальше ничего не будем делать
    какие попало партии прилеплять НЕ БУДЕМ!!!! - если нет непартионной части */
    if no-place-qnty = 0 then return.
  end. /*партионный*/
  if NOT cashplace AND cashparts then do: /*партионный*/
    FIND FIRST loc-gds-dtl WHERE
              loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
              loc-gds-dtl.artic = b-doc-line.artic AND
              loc-gds-dtl.prod-type = b-doc-line.prod-type AND
              loc-gds-dtl.prod-code = b-doc-line.prod-code AND
              loc-gds-dtl.prt-code = nodecode
              EXCLUSIVE-LOCK NO-ERROR.
    IF rz  and loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then LEAVE.
    IF NOT rz and loc-gds-dtl.doc-qnty = 0 then LEAVE.
    IF NOT (rgds-dtl = ?) AND NOT recid(loc-gds-dtl) = rgds-dtl THEN LEAVE.

&scop my-count-message  substitute("&1 - обработано &2, из них успешно - &3" ~
                                                        , rsrv-title         ~
                                                        , num_rec            ~
                                                        , num_rec_res)
  if ( num_rec modulo 10 ) = 0 then
{&display-count-message}.
    assign
    chg-qnty = 0
    res-qnty = 0
    cost-base = 0
    cost-rubl = 0
    gds-dtl-res-qnty = if rz
                        then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                        else (if r-qnty = ?
                              then (- loc-gds-dtl.doc-qnty)
                              else r-qnty)
    .
    _docprts:
    FOR EACH loc-doc-prts where
            loc-doc-prts.gds-code = gdscode AND
            loc-doc-prts.out-code = b-doc-line.doc-code ON ERROR UNDO, NEXT:
      if rz and loc-doc-prts.fact-qnty <= loc-doc-prts.doc-qnty then NEXT.
      if not rz and loc-doc-prts.doc-qnty = 0 then NEXT.
      if NOT r-b-code = ? AND r-b-code <> loc-doc-prts.b-code then NEXT.
      if NOT r-doc-prts-qnty = ? AND r-doc-prts-qnty <> loc-doc-prts.fact-qnty then NEXT.
      assign
      res-parts = if rz
                  then loc-doc-prts.doc-qnty
                  else (if r-qnty = ?
                        then (- loc-doc-prts.doc-qnty)
                        else r-qnty)
      ser-chg-qnty = if rz
                      then loc-doc-prts.fact-qnty - res-parts
                      else (if r-qnty = ?
                            then (- loc-doc-prts.doc-qnty)
                            else r-qnty)
      res-qnty = res-qnty + ser-chg-qnty
      no-partion-qnty = gds-dtl-res-qnty - res-qnty
      cost-base = 0
      cost-rubl = 0
      .
      if b-trn-doc.status_ = {&doc-froze}
      or b-trn-doc.flag <> no
      then do:
        assign
        v-return-status =  b-trn-doc.status_
        v-return-flag = b-trn-doc.flag
        b-trn-doc.status_ = {&wayb}
        b-trn-doc.flag = no
        v-return-st-fl = yes
        .
      end.
      /*не резервирования по партиям чужих товаров!!!!!!!!!!!!!!!!*/
      if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> {&TDEDT_Vozvrat_Vnesh_Kass})
      then do :
        {&num_rec_plus}.
      end.
      run trg/rsrv-dtl.p (
                         input parparentproc
                        ,input rsrv-option
                        ,buffer loc-gds-dtl
                        ,input-output ser-chg-qnty
                        ,input-output cost-base
                        ,input-output cost-rubl
                        ,input (if loc-doc-prts.b-code < 0 then ? else loc-doc-prts.b-code)
                        , "" ) no-error.
      if error-status:error then  do:
&if "{2}" = "auto" &then
&scop my-message return-value
{&display-message}.
&endif
&if "{2}" = "excl-chk" &then
        v-return-st-fl = no.
        undo _docprts, return error.
&else
        v-return-st-fl = no.
        undo _docprts, NEXT.
&endif
      end.
      if v-return-st-fl then do:
        assign
        b-trn-doc.status_ = v-return-status
        b-trn-doc.flag = v-return-flag
        v-return-st-fl = no
        .
      end.
&if "{2}" = "auto" &then
if ser-chg-qnty <> res-parts then do:
  &scop my-message return-value
  {&display-message}.
end.
&endif

      assign
      chg-qnty = chg-qnty + ser-chg-qnty
      loc-doc-prts.doc-qnty = loc-doc-prts.doc-qnty + ser-chg-qnty
      .
      if r-doc-prts-qnty <> ? and r-b-code = ? then LEAVE.
    END.
    if chg-qnty <> 0 then  do:
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      .
      {&num_rec_res_plus}.
      if bottle then do:
        { str/in-vatp.i calc b-doc-line.  b-trn-doc. g }
        assign
        b-doc-line.road-tax = (if v-curr-r-b = {&r-b-rubl} then road-tax-rubl-loc else road-tax-base-loc).
      end.

      if rz then do:
        if b-trn-doc.print-rubl
        then assign
          loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
          loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
          loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                   then 0
                                   else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .
        else
        assign
        loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                 then 0
                                 else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base ).
      end.
    end.
    /*по партиям все ОК*/
    if chg-qnty = res-qnty
    then parts-ok = yes.
    else parts-ok = no.
    /*па партиям все нормально, непартионной части нет вообще*/
    release loc-gds-dtl.
    /*не удалось по всем партиям зарезервировать  - тогда дальше ничего не будем делать
    какие попало партии прилеплять НЕ БУДЕМ!!!! - если нет непартионной части */
    if no-partion-qnty = 0 then return.
  end. /*партионный*/
  /*непартионный или дорезервирование непартионной части*/
  if not cashparts or no-partion-qnty <> 0 or NOT cashplace OR no-place-qnty <> 0 then do:
  if cashplace then no-partion-qnty = no-place-qnty.
  _gdsdtl:
  FOR EACH loc-gds-dtl WHERE
          loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
          loc-gds-dtl.artic = b-doc-line.artic AND
          loc-gds-dtl.prod-type = b-doc-line.prod-type AND
          loc-gds-dtl.prod-code = b-doc-line.prod-code
          EXCLUSIVE-LOCK ON ERROR UNDO, NEXT:
    IF rz AND loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then NEXT.
    IF not rz AND loc-gds-dtl.doc-qnty = 0 AND v-is-own then NEXT.
    IF NOT (rgds-dtl = ?) then do:
      if NOT recid(loc-gds-dtl) = rgds-dtl THEN NEXT.
      assign
      r-prt-code = loc-gds-dtl.prt-code.
    end.
&scop my-count-message  substitute("&1 - обработано &2, из них успешно - &3" ~
                                                        , rsrv-title         ~
                                                        , num_rec            ~
                                                        , num_rec_res)
if ( num_rec modulo 10 ) = 0 then
{&display-count-message}.

    assign
    res-qnty = if cashparts
                then (if rz
                      then no-partion-qnty
                      else (if r-qnty = ?
                            then (- loc-gds-dtl.doc-qnty)
                            else no-partion-qnty)
                      )
                else (if rz
                      then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                      else (if r-qnty = ?
                            then (- loc-gds-dtl.doc-qnty)
                            else r-qnty
                            )
                      )
    chg-qnty = res-qnty
    cost-base = 0
    cost-rubl = 0 .
    if not v-is-own and rz then do:
      find first buf_tt0-gds-dtl no-lock where
                buf_tt0-gds-dtl.artic     = loc-gds-dtl.artic
            AND buf_tt0-gds-dtl.prod-type = loc-gds-dtl.prod-type
            AND buf_tt0-gds-dtl.prod-code = loc-gds-dtl.prod-code
            AND buf_tt0-gds-dtl.prt-code = loc-gds-dtl.prt-code no-error .
      if available buf_tt0-gds-dtl then do:
        assign
        chg-qnty = chg-qnty - buf_tt0-gds-dtl.doc-qnty.
      end.
    end.
    if not v-is-own and not rz and chg-qnty = 0 then
    assign
    v-to-reserv = no
    .
    if not v-is-own
    and rz
    and (available buf_tt0-gds-dtl and (buf_tt0-gds-dtl.doc-qnty + loc-gds-dtl.doc-qnty) = loc-gds-dtl.fact-qnty)
    then
    assign
    v-to-reserv = no
    .
    /* ПРОИЗВОДСТВО */
    if p-auto-fbr-on
    then do :
      find first goods no-lock where goods.artic = loc-gds-dtl.artic
                                 and goods.prod-type = loc-gds-dtl.prod-type
                                 and goods.prod-code = loc-gds-dtl.prod-code
                                 .
      if b-trn-doc.ext-doc-type =  {&TDEDT_Vozvrat_Vnesh_Kass}
      then do :                           
        find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = replace(loc-gds-dtl.doc-code, "=", "-")
                                             and buf_doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
        if available buf_doc-fbr-gds 
        then do :  
          if buf_doc-fbr-gds.fact-qnty > 0
          then do :
            assign
              v-to-reserv = no
            .
          end.
          else do :
            chg-qnty = if res-qnty >= 0 then abs(buf_doc-fbr-gds.fact-qnty) else buf_doc-fbr-gds.fact-qnty.
          end.
        end.                                   
      end.
      if b-trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh_Kass}
      then do :
        find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = loc-gds-dtl.doc-code
                                             and buf_doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
        if available buf_doc-fbr-gds 
        then do : 
          if buf_doc-fbr-gds.fact-qnty >= 0
          then do : 
            chg-qnty = if res-qnty >= 0 then buf_doc-fbr-gds.fact-qnty else - buf_doc-fbr-gds.fact-qnty .
          end.
          else do :
            assign
              v-to-reserv = no
            .
          end.
        end.                                     
      end.
    end.
    if v-to-reserv and chg-qnty <> 0 then do:
      if b-trn-doc.status_ = {&doc-froze}
      or b-trn-doc.flag <> no
      then do:
        assign
        v-return-status =  b-trn-doc.status_
        v-return-flag = b-trn-doc.flag
        b-trn-doc.status_ = {&wayb}
        b-trn-doc.flag = no
        v-return-st-fl = yes
        .
      end.
      if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> {&TDEDT_Vozvrat_Vnesh_Kass})
      then do :
        {&num_rec_plus}.
      end.

      run trg/rsrv-dtl.p (
                       input parparentproc
                      ,input rsrv-option
                      ,buffer loc-gds-dtl
                      ,input-output chg-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      , -1
                      , "" ) no-error.
      if error-status:error then  do:
&if "{2}" = "auto" &then
&scop my-message return-value
{&display-message}.
&endif
&if "{2}" = "excl-chk" &then
        v-return-st-fl = no.
        undo _gdsdtl, return error.
&else
        v-return-st-fl = no.
        undo _gdsdtl, NEXT.
&endif
      end.
    if v-return-st-fl then do:
      assign
      b-trn-doc.status_ = v-return-status
      b-trn-doc.flag = v-return-flag
      v-return-st-fl = no
      .
    end.
&if "{2}" = "auto" &then
if chg-qnty <> res-qnty and not available buf_doc-fbr-gds then do:
  &scop my-message return-value
  {&display-message}.
end.
&endif

      if cashfbr then do:
        /*сюда чужие товары с v-own = no не попадают*/
        assign
        fbr-qnty = chg-qnty
        .
        _fbr:
        for each loc-doc-fbr-gds where
                loc-doc-fbr-gds.gds-code = gdscode:
          assign
          fbr-chg-qnty = min(loc-doc-fbr-gds.fact-qnty - loc-doc-fbr-gds.doc-qnty, fbr-qnty)
          fbr-qnty = fbr-qnty - fbr-chg-qnty
          loc-doc-fbr-gds.doc-qnty = loc-doc-fbr-gds.doc-qnty + fbr-chg-qnty
          .
          if fbr-qnty = 0 then do:
              leave _fbR.
          end.
        end.
      end. /* if cashfbr then do:*/
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      .
      
      if available buf_doc-fbr-gds
      then do :
        if rz then do :
          if buf_doc-fbr-gds.fact-qnty > 0
          then do :
            if loc-gds-dtl.doc-qnty = buf_doc-fbr-gds.fact-qnty then assign num_rec_res = num_rec_res + 1 .
          end.
          else
          if buf_doc-fbr-gds.fact-qnty < 0 
          then do :
            if loc-gds-dtl.doc-qnty = - buf_doc-fbr-gds.fact-qnty then assign num_rec_res = num_rec_res + 1 .
          end.
          else do :
            {&num_rec_res_plus}.
          end.
        end.
        else do :
          if loc-gds-dtl.doc-qnty = 0 then assign num_rec_res = num_rec_res + 1 .
        end.
      end. 
      else do :
        {&num_rec_res_plus}.
      end.
      if bottle then do:
        { str/in-vatp.i calc b-doc-line.  b-trn-doc. g }
        assign
        b-doc-line.road-tax = (if v-curr-r-b = {&r-b-rubl}
                                then road-tax-rubl-loc
                                else road-tax-base-loc).
      end.
      if rz then do:
        if b-trn-doc.print-rubl
        then assign
              loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
              loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
              loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                       then 0
                                       else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .

        else assign
            loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
            loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
            loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                    then 0
                                    else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base) .
      end.
      if (not v-is-own and res-qnty = 0)
      or (not rz and (loc-gds-dtl.doc-qnty = 0  and res-qnty = 0) and p-tpsi-obj)
        then do:
      end.
      if chg-qnty = res-qnty and chg-qnty <> 0
      AND parts-OK
      AND (v-is-own
          OR ((not v-is-own)
              and v-to-reserv
              and (
                   ((loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty) and (rz))
                   OR
                   (not rz  and (loc-gds-dtl.doc-qnty = 0))
                  )
             )
          )
      /*считаем удачи только для своих товаров -
                     для тех кто частично резеврирует остатки чужих на своем объекте ПОКА НЕСЧИТАЕМ
                     или для полностью зарезервированных по остаткам на своем объекте чужих */
      then .
    end. /*if v-to-rezerv*/
    /*к этом момент зарезервировали остатки по сужим товарам если галкам стояла*/
    if not v-is-own then do:
      /*нет резервироания чужих товаров по партиям и складским местам!!!!!!!!!!!!!*/
      if cashparts
      or cashplace
      or (chg-qnty = res-qnty
        and  ((loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty) and (rz))

          )
      then do:
        p-run-tpsi = no.
      end.

       /*заполняем врем tpsi таблицу*/

      else do:
        run create-tt0-doc-line-gds-dtl(
                                         input v-proprietor-obj-type
                                        ,input v-proprietor-obj-code
                                        ,input v-ext-doc-type
                                        ,input (if available tpsi_sale-doc then tpsi_sale-doc.doc-code else "":U)
                                        ,input  b-doc-line.artic
                                        ,input  b-doc-line.prod-type
                                        ,input  b-doc-line.prod-code
                                        ,input  loc-gds-dtl.prt-code
                                        ,input  (if rz
                                                  then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                                                  else
                                                  (if r-qnty = ?
                                                  then ?
                                                  else r-qnty
                                                  )
                                                 )
                                        ,output v-was-gds-dtl-doc-qnty
                                        ,output v-gds-dtl-fact-qnty
                                        ,buffer b-doc-line
                                        ,buffer loc-gds-dtl
                                        ,buffer tpsi_sale-doc
                                        /*gds-dtl fact-qnty*/
                                        ).
        if not v-is-own and p-r-v > 0 and v-gds-dtl-fact-qnty <> 0 then do:
          /*снадо резервировать по чужим - подготовим счетчик */
          if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> {&TDEDT_Vozvrat_Vnesh_Kass})
          then do :
            {&num_rec_plus}.
          end.
          run write-tt0-info in this-procedure (
                                                input b-doc-line.artic
                                              ,input b-doc-line.prod-type
                                              ,input b-doc-line.prod-code
                                              ,input loc-gds-dtl.prt-code
                                              ,input v-proprietor-obj-type
                                              ,input v-proprietor-obj-code
                                              ,input (if available tpsi_sale-doc then tpsi_sale-doc.doc-code else "":U)
                                              ,input no /*from-tpsi*/
                                              ,input loc-gds-dtl.fact-qnty
                                              ,input loc-gds-dtl.doc-qnty
                                              ,input ?
                                              ,input loc-gds-dtl.fact-qnty
                                              ,input v-was-gds-dtl-doc-qnty
                                              ,input v-gds-dtl-fact-qnty
                                              ,input v-was-gds-dtl-doc-qnty
                                              ,input '':u).
        end.
        if v-gds-dtl-fact-qnty = 0 then do:
            p-run-tpsi = no.
        end.
      end. /*not cashplace not cashparts*/
    end. /*не v-to-reserv на своем объекте*/
  END. /*FOR EACH gd-sdtl*/
end. /*if not cashparts or loc-gds-dtl.doc-qnty < loc-gds-dtl.fact-qnty*/
END. /*PROCEDURE*/

&endif


/* $Workfile$ e n d */