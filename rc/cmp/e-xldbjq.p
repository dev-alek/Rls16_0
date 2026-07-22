block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-xldbjq.p $
$Archive: cmp/e-xldbjq.p $

Заполнение полей временной таблицы для отчета итоги по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

/*вызвается с параметрами компиляции -
{1} LIST если есть dc-list
{2} опции выбора группы
 (if current-gcode = 0
then "ALL"
else
(IF DCARDmode = "GROUP"
then "ONE"
else "LIST")
)
{3} - base или rubl
{4} sort
*/
define input parameter p-host-code like ub.sysconf.host-code no-undo .
DEFINE INPUT PARAMETER DcardMode as char no-undo.
/*может быть ALL, ONE, LIST, GROUP*/
DEFINE INPUT PARAMETER FixDCard as char no-undo.
/*номер карты в режиме one*/
DEFINE INPUT PARAMETER current-gcode like cli-grp.node-code.
/*номер группы в режиме GROUP*/
DEFINE INPUT PARAMETER cli-str as char no-undo.
/*список ресидов в режиме LIST*/
DEFINE INPUT PARAMETER filter-name as char no-undo.
DEFINE INPUT PARAMETER TotalOnly as logical no-undo.
define input parameter t-legacy as logical no-undo .
define input parameter t-subsid as logical no-undo .
define input parameter par-run-names as character no-undo .
define input parameter p-call-handle as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: e-xldbjq.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cmp/e-xldbjq.p $":u .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для отчета итоги по дисконтным картам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ cmp/e-xldbjd.i "SHARED" }
{ cmp/obj-list.i }
{ cmp/dc-list.i dc-list def "shared" }

&if "{1}" = "LIST" &then
&SCOP dc-buffer dc-list
{ cmp/getdpcnt.i dc-list dc-list }
&endif
{ cmp/getdpcnt.i dis-card }
&if "{1}" = "ALL" &then
&SCOP dc-buffer dis-card
&endif



define variable new-card as logical no-undo.
DEFINE VARIABLE vwait as character no-undo .
DEFINE VARIABLE vproc-arch-disc-cards as character no-undo .
DEFINE VARIABLE loc-d-pcnt like ub.dis-card.d-pcnt no-undo .

define buffer card-clients for clients.
define buffer bsj-groups for sj-groups.
define buffer bsj-cards for sj-cards.
define buffer buf_dis-card for ub.dis-card.
define buffer osn_dis-card for ub.dis-card.
define buffer cli-obj for ub.clients.
assign
vwait = entry(1, par-run-names, {&delim-par})
vproc-arch-disc-cards = entry(2, par-run-names, {&delim-par})
.
if valid-handle(p-call-handle)
and p-call-handle:get-signature ('waifram-show':U) <> "":U then do:
  run waitfram-show in P-CALL-HANDLE (vwait).
END.

create bsj-cards.
assign
bsj-cards.d-card = ?
.


FOR EACH obj-list no-lock ,
    FIRST cli-obj no-lock where
         cli-obj.obj-type = obj-list.obj-type
    AND  cli-obj.obj-code = obj-list.obj-code:
  FOR EACH
&if "{1}" = "LIST" &then
      dc-list no-lock, first
&endif
  dis-obj no-lock WHERE
        dis-obj.dt-code = 0
    and
&if "{1}" = "LIST" &then
         dis-obj.d-card = dc-list.d-card  and
&endif
         obj-list.obj-type = dis-obj.obj-type AND
         obj-list.obj-code = dis-obj.obj-code
&if "{1}" = "ALL" &then
    AND dis-obj.host-code = cli-obj.host-code,
    FIRST dis-card No-LOCK
    WHERE dis-card.d-card = dis-obj.d-card
&endif
    , FIRST card-clients NO-LOCK WHERE
             card-clients.obj-type = {&dc-buffer}.cli-type
         AND card-clients.obj-code = {&dc-buffer}.cli-code
&if "{2}"  = "ONE":U &then
          AND
          card-clients.grp-code = current-gcode
&endif
                                         :
    PROCESS EVENTS .
    dis-obj-found = yes.
    ACCUMULATE     dis-obj.d-card ( COUNT ) .
    if ( ( ACCUM COUNT dis-obj.d-card ) modulo 10 ) = 0 AND
         ( ACCUM COUNT dis-obj.d-card ) >= 10 then do:
        if valid-handle(p-call-handle)
        and p-call-handle:get-signature ('waifram-show':U) <> "":U then do:
          run waitfram-show in p-call-handle (
                                              obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                                              vproc-arch-disc-cards + string( ACCUM COUNT dis-obj.d-card )
          ).
        end.
      end.
    assign
    new-card = no.
&if "{4}" = "group":U &then
     FIND  FIRST  bsj-groups WHERE
                  bsj-groups.g-code = card-clients.grp-code AND
                  bsj-groups.obj-code = 0
                  NO-ERROR.
&if "{2}" = "LIST":U &then
     if NOT avail bsj-groups then do:
         NEXT.
     end.
&endif
    IF NOT AVAIL bsj-groups then do:
      FIND FIRST cli-grp No-LOCK WHERE
                 cli-grp.node-code = card-clients.grp-code NO-ERROR.
      create bsj-groups.
      assign
      bsj-groups.g-code = card-clients.grp-code
      bsj-groups.g-name = (if avail cli-grp then cli-grp.node-name else "")
      bsj-groups.obj-code = 0
      .
    end. /*if not avail bsj-groups*/
    FIND FIRST sj-groups WHERE
               sj-groups.g-code = card-clients.grp-code AND
               sj-groups.obj-code = dis-obj.obj-code No-ERROR.
    IF NOT AVAIL sj-groups then do:
      FIND FIRST cli-grp No-LOCK WHERE
                 cli-grp.node-code = card-clients.grp-code NO-ERROR.
      create sj-groups.
      assign
      sj-groups.g-code = card-clients.grp-code
      sj-groups.g-name = (if avail cli-grp then cli-grp.node-name else "")
      sj-groups.obj-code = dis-obj.obj-code
      .
    end. /*if not avail sj-groups*/
&endif /*RS-sort = "GROUP"*/
    FIND FIRST sj-cards No-LOCK WHERE
               sj-cards.d-card = dis-obj.d-card NO-ERROR.
    IF NOT AVAIL sj-cards then do:
      FIND FIRST dis-host No-LOCK WHERE
                 dis-host.d-card = dis-obj.d-card
             AND dis-host.host-code = p-host-code
             and dis-host.dt-code = 0  No-ERROR.
      create
      sj-cards.
      assign
      new-card = yes
      sj-cards.d-card = dis-obj.d-card
      sj-cards.g-code = card-clients.grp-code
      sj-cards.global-card = ({&dc-buffer}.emitent-host-code = 0)
      sj-cards.credit-card = {&dc-buffer}.credit-card
      sj-cards.cli-type = {&dc-buffer}.cli-type
      sj-cards.cli-code = {&dc-buffer}.cli-code
      sj-cards.cli-name =  card-clients.obj-name
      sj-cards.d-pcnt = {&dc-buffer}.d-pcnt
      sj-cards.saldo = {&dc-buffer}.saldo-{3}
      sj-cards.must-pay = if sj-cards.saldo < 0 then (- sj-cards.saldo) else 0
      sj-cards.pay = (if avail dis-host then dis-host.pay-tot-{3} else 0)
      sj-cards.obj-qnty = 0
      sj-cards.first-main-card = dis-obj.first-main-card
      sj-cards.main-card = dis-obj.main-card
      sj-cards.first-card = dis-obj.first-card
      sj-cards.card-num-chr = (if t-legacy or t-subsid
                               then (if t-legacy
                                     and t-subsid
                                     then dis-obj.first-main-card
                                     else (if t-legacy
                                           then dis-obj.first-card
                                           else dis-obj.main-card)
                                     )
                               else  dis-obj.d-card)
      bsj-cards.saldo = bsj-cards.saldo + {&dc-buffer}.saldo-{3}
      bsj-cards.must-pay = bsj-cards.must-pay + (if sj-cards.saldo < 0 then (- sj-cards.saldo) else 0)
      bsj-cards.pay = bsj-cards.pay + (if avail dis-host then dis-host.pay-tot-{3} else 0)
      bsj-cards.obj-qnty = bsj-cards.obj-qnty + 1
      .
      &if "{1}" = "LIST" &then
      assign
      sj-cards.d-pcntchr = get-d-pcntdc-list ( buffer {&dc-buffer}
                                     ,input p-host-code
                                     ,input obj-list.obj-type
                                     ,input obj-list.obj-code
                                     ,input {&ddctr-def-pcnt}
                                     ,output loc-d-pcnt).
      &else
      assign
      sj-cards.d-pcntchr = get-d-pcnt ( buffer {&dc-buffer}
                                     ,input p-host-code
                                     ,input obj-list.obj-type
                                     ,input obj-list.obj-code
                                     ,input {&ddctr-def-pcnt}
                                     ,output loc-d-pcnt).
      &endif


    end. /*if not avail sj-cards*/
    assign
    sj-cards.tot = sj-cards.tot + dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}
    sj-cards.disc = sj-cards.disc + dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3}
    sj-cards.netto = sj-cards.netto + (dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}) -
                                      (dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3})
    sj-cards.instant-pay = sj-cards.instant-pay + dis-obj.pay-tot-{3}
    sj-cards.credit-pay = sj-cards.credit-pay + (dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}) -
                                                (dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3}) -
                                                dis-obj.pay-tot-{3}
    sj-cards.num-chk = sj-cards.num-chk + dis-obj.num-chk
    sj-cards.obj-qnty = if sj-cards.obj-qnty = 0
                        then dis-obj.obj-code
                        else (- 1)
    .
    if sj-cards.last-card = '':U
    and (t-legacy
    or t-subsid)
    then do:
      if t-legacy and not t-subsid then do:
        find first legacy-obj no-lock where
                  legacy-obj.obj-type = dis-obj.obj-type
              AND legacy-obj.obj-code = dis-obj.obj-code
          AND legacy-obj.card-num-chr = {&dc-buffer}.first-card
          no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = {&dc-buffer}.first-card
          legacy-obj.first-card = {&dc-buffer}.first-card
          legacy-obj.first-main-card = {&dc-buffer}.first-main-card
          legacy-obj.main-card = {&dc-buffer}.main-card
          .
          /*надо найти ТЕКУЩУЮ карту цепочки*/
          find last osn_dis-card no-lock where
          osn_dis-card.first-card = legacy-obj.first-card use-index isourced no-error.
          if not available osn_dis-card then do:
            message
            substitute("Не найдена текущая карта цепочки карт с ПЕРВОЙ КАРТОЙ = &1 для карты &2"
                       ,legacy-obj.first-card
                       ,dis-obj.d-card
                       )
            view-as alert-box .
            assign
            legacy-obj.d-card = dis-obj.d-card
            legacy-obj.d-pcnt = 0
            legacy-obj.d-pcntchr = "?"
            .
          end.
          else do:
            assign
            legacy-obj.d-card = osn_dis-card.d-card
            legacy-obj.d-pcnt = osn_dis-card.d-pcnt
            .
            assign
            legacy-obj.d-pcntchr = get-d-pcnt(buffer osn_dis-card
                                            ,input p-host-code
                                            ,input obj-list.obj-type
                                            ,input obj-list.obj-code
                                            ,input {&ddctr-def-pcnt}
                                            ,output loc-d-pcnt).
            .
          end.
        end.
      end.
      if not t-legacy and t-subsid then do:
        find first legacy-obj no-lock where
                  legacy-obj.obj-type = dis-obj.obj-type
              AND legacy-obj.obj-code = dis-obj.obj-code
              AND legacy-obj.card-num-chr = {&dc-buffer}.main-card
              no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = {&dc-buffer}.main-card
          legacy-obj.main-card = {&dc-buffer}.main-card
          legacy-obj.first-card = {&dc-buffer}.first-card
          legacy-obj.first-main-card = {&dc-buffer}.first-main-card
          .
          find first osn_dis-card no-lock where
          osn_dis-card.d-card = legacy-obj.main-card use-index isourced no-error .
          if not available osn_Dis-card then do:
            message
            substitute("Не найдена ОСНОВНАЯ карта &1 для карты &2"
                       ,{&dc-buffer}.main-card
                       ,dis-obj.d-card )
            view-as alert-box .
            assign
            legacy-obj.d-card = dis-obj.main-card
            legacy-obj.d-pcnt = 0
            legacy-obj.d-pcntchr = "?"
            .
          end.
          else do:
            assign
            legacy-obj.d-card = osn_dis-card.d-card
            legacy-obj.d-pcnt = osn_dis-card.d-pcnt
            .
            legacy-obj.d-pcntchr = get-d-pcnt(buffer osn_dis-card
                                            ,input p-host-code
                                            ,input obj-list.obj-type
                                            ,input obj-list.obj-code
                                            ,input {&ddctr-def-pcnt}
                                            ,output loc-d-pcnt)
            .
          end.
        end.
      end.
      if t-legacy and t-subsid then do:
        find first legacy-obj no-lock where
                  legacy-obj.obj-type = dis-obj.obj-type
              AND legacy-obj.obj-code = dis-obj.obj-code
              AND legacy-obj.card-num-chr = {&dc-buffer}.first-main-card
              no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = {&dc-buffer}.first-main-card
          legacy-obj.first-main-card = {&dc-buffer}.first-main-card
          legacy-obj.first-card = {&dc-buffer}.first-card
          legacy-obj.main-card = {&dc-buffer}.main-card
          .
          /*надо найти ТЕКУЩУЮ карту ОСНОВНОЙ цепочки*/
          find last osn_dis-card no-lock where
          osn_dis-card.first-card = legacy-obj.first-card
          and osn_dis-card.is-subsid = no
          use-index isourced no-error .
          if not available osn_dis-card then do:
            message
            substitute("Не найдена текущая ПЕРВАЯ ОСНОВНАЯ карта &1 для карты &2"
                       ,{&dc-buffer}.first-card
                       ,dis-obj.d-card )
            view-as alert-box .
            assign
            legacy-obj.d-card = dis-obj.first-card
            legacy-obj.d-pcnt = 0
            legacy-obj.d-pcntchr = "?"
            .
          end.
          else do:
            assign
            legacy-obj.d-card = osn_dis-card.d-card
            legacy-obj.d-pcnt = osn_dis-card.d-pcnt
            .
            legacy-obj.d-pcntchr = get-d-pcnt(buffer osn_dis-card
                                            ,input p-host-code
                                            ,input obj-list.obj-type
                                            ,input obj-list.obj-code
                                            ,input {&ddctr-def-pcnt}
                                            ,output loc-d-pcnt)
            .
          end.
        end.
      end.
      assign
      legacy-obj.gds-tot-rubl = legacy-obj.gds-tot-rubl + dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl
      legacy-obj.gds-dis-rubl = legacy-obj.gds-dis-rubl + dis-obj.gds-dis-rubl + dis-obj.sum-dis-rubl
      legacy-obj.pay-tot-rubl = legacy-obj.pay-tot-rubl + dis-obj.pay-tot-rubl
      legacy-obj.gds-tot-base = legacy-obj.gds-tot-base + dis-obj.gds-tot-base + dis-obj.sum-tot-base
      legacy-obj.pay-tot-base = legacy-obj.pay-tot-base + dis-obj.pay-tot-base
      legacy-obj.gds-dis-base = legacy-obj.gds-dis-base + dis-obj.gds-dis-base + dis-obj.sum-dis-base
      legacy-obj.num-chk      = legacy-obj.num-chk      + dis-obj.num-chk
      .
      assign
      sj-cards.last-card = legacy-obj.d-card
      .
    end.
&if "{4}" = "group":U &then
    assign
    sj-groups.tot = sj-groups.tot + dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}
    sj-groups.disc = sj-groups.disc + dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3}
    sj-groups.netto = sj-groups.netto + (dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}) -
                                      (dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3})
    sj-groups.instant-pay = sj-groups.instant-pay + dis-obj.pay-tot-{3}
    sj-groups.credit-pay = sj-groups.credit-pay + (dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}) -
                                                (dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3}) -
                                                dis-obj.pay-tot-{3}
    sj-groups.num-chk = sj-groups.num-chk + dis-obj.num-chk
    sj-groups.cards-qnty = sj-groups.cards-qnty + 1
    sj-groups.pay = 0
    sj-groups.must-pay = 0
    sj-groups.saldo = 0
    sj-groups.obj-qnty = (if sj-groups.obj-qnty = 0 then dis-obj.obj-code else (- 1))
    bsj-groups.tot = bsj-groups.tot + dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}
    bsj-groups.disc = bsj-groups.disc + dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3}
    bsj-groups.netto = bsj-groups.netto + (dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}) -
                                      (dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3})
    bsj-groups.instant-pay = bsj-groups.instant-pay +  dis-obj.pay-tot-{3}
    bsj-groups.credit-pay = bsj-groups.credit-pay + (dis-obj.gds-tot-{3} + dis-obj.sum-tot-{3}) -
                                                (dis-obj.gds-dis-{3} +  dis-obj.sum-dis-{3}) -
                                                dis-obj.pay-tot-{3}
    bsj-groups.num-chk = bsj-groups.num-chk + dis-obj.num-chk
    bsj-groups.cards-qnty = bsj-groups.cards-qnty + (if new-card then 1 else 0)
    bsj-groups.saldo = bsj-groups.saldo + (if new-card then sj-cards.saldo else 0)
    bsj-groups.must-pay = bsj-groups.must-pay + (if new-card then sj-cards.must-pay else 0)
    bsj-groups.pay = bsj-groups.pay +  (if new-card then sj-cards.pay else 0)
    bsj-groups.obj-qnty = (if bsj-groups.obj-qnty = 0 then dis-obj.obj-code else (- 1))
    .
&endif
  end. /*for each dis-obj*/
END. /*for each obj-list*/

if valid-handle(p-call-handle)
and p-call-handle:get-signature ('waifram-show':U) <> "":U then do:
  run waitfram-hide in p-call-handle .
end.