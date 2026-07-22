block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-xldbj.p $
$Archive: rep/e-xldbj.p $

Заполнение полей временной таблицы для отчета итоги по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

define input parameter p-host-code like ub.sysconf.host-code no-undo .
DEFINE INPUT PARAMETER DcardMode as char no-undo.
/*может быть ALL, ONE, LIST, GROUP*/
DEFINE INPUT PARAMETER FixDCard as char no-undo.
/*номер карты в режиме one*/
DEFINE INPUT PARAMETER current-gcode like ub.cli-grp.node-code.
/*номер группы в режиме GROUP*/
DEFINE INPUT PARAMETER cli-str as char no-undo.
/*список ресидов в режиме LIST*/
DEFINE INPUT PARAMETER filter-name as char no-undo.
DEFINE INPUT PARAMETER TotalOnly as logical no-undo.
define input parameter t-legacy as logical no-undo .
define input parameter t-subsid as logical no-undo .
define input parameter p-curr-type as character no-undo .
define input parameter p-sort-mode as character no-undo .
define input parameter p-group-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: e-xldbj.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/e-xldbj.p $":u .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для отчета итоги по дисконтным картам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ rep/e-xldbj.i "SHARED" }
{ cmp/obj-list.i }
{ cmp/dc-list.i dc-list def "shared" }
{ gbl/waitfram.i }
{ cmp/getdpcnt.i dc-list dc-list }
{ cmp/getdpcnt.i ub.dis-card }


define variable new-card as logical no-undo.
DEFINE VARIABLE vwait as character no-undo .
DEFINE VARIABLE vproc-arch-disc-cards as character no-undo .
DEFINE VARIABLE loc-d-pcnt like ub.dis-card.d-pcnt no-undo .

define buffer card-clients for ub.clients.
define buffer bsj-groups for sj-groups.
define buffer bsj-cards for sj-cards.
define buffer buf_dis-card for ub.dis-card.
define buffer osn_dis-card for ub.dis-card.
define buffer cli-obj for ub.clients.
define variable v-count as integer   no-undo .
run waitfram-show in this-procedure  ( input "Ждите... Обработано архивов по ДК").

define temp-table temp-dis-card no-undo like ub.dis-card.
create bsj-cards.
assign
bsj-cards.d-card = ?
.

create temp-dis-card.


FOR EACH obj-list no-lock ,
    FIRST cli-obj no-lock where
         cli-obj.obj-type = obj-list.obj-type
    AND  cli-obj.obj-code = obj-list.obj-code:
  case dcardmode:
    when "LIST"
    or
    when "ONE" then do:
      FOR EACH dc-list no-lock,
         first ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0
        and ub.dis-obj.d-card = dc-list.d-card
        and ub.dis-obj.obj-type = obj-list.obj-type
        AND ub.dis-obj.obj-code = obj-list.obj-code,
         FIRST card-clients NO-LOCK WHERE
              card-clients.obj-type = dc-list.cli-type
          AND card-clients.obj-code = dc-list.cli-code:
        if p-group-mode =  "ONE":U
        and  card-clients.grp-code <> current-gcode then next.
        PROCESS EVENTS .
        dis-obj-found = yes.
        buffer-copy dc-list to temp-dis-card.
        run process-dis-obj in this-procedure .
      end.
    end.
    otherwise do:
      FOR EACH ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0
        and obj-list.obj-type = ub.dis-obj.obj-type
        AND obj-list.obj-code = ub.dis-obj.obj-code
        AND ub.dis-obj.host-code = cli-obj.host-code,
        FIRST ub.dis-card No-LOCK WHERE
            ub.dis-card.d-card = ub.dis-obj.d-card,
       FIRST card-clients NO-LOCK WHERE
            card-clients.obj-type = ub.dis-card.cli-type
        AND card-clients.obj-code = ub.dis-card.cli-code:
        if p-group-mode =  "ONE":U
        and  card-clients.grp-code <> current-gcode then next.
        PROCESS EVENTS .
        dis-obj-found = yes.
        buffer-copy dis-card to temp-dis-card.
        run process-dis-obj in this-procedure .
      end.
    end.
  end case.
end. /*FOR EACH obj-list no-lock ,*/
run waitfram-hide in this-procedure  .


procedure process-dis-obj :

do
on error undo, return error return-value
:

    v-count = v-count + 1.
    if v-count modulo 10  = 0
    AND v-count  >= 10 then do:
      run waitfram-show in this-procedure ( input substitute("&1&2 Обработано архивов по ДК: &3"
                                                            ,obj-list.obj-type
                                                            ,obj-list.obj-code
                                                            ,v-count )
                                           ).

    end.
    assign
    new-card = no.
    if p-sort-mode = "group":U then do:
      FIND  FIRST  bsj-groups WHERE
                    bsj-groups.g-code = card-clients.grp-code AND
                    bsj-groups.obj-code = 0
                    NO-ERROR.
      if p-group-mode = "LIST":U then do:
        if NOT avail bsj-groups then do:
            NEXT.
        end.
      end.
      IF NOT AVAIL bsj-groups then do:
        FIND FIRST ub.cli-grp No-LOCK WHERE
                  ub.cli-grp.node-code = card-clients.grp-code NO-ERROR.
        create bsj-groups.
        assign
        bsj-groups.g-code = card-clients.grp-code
        bsj-groups.g-name = (if avail ub.cli-grp then ub.cli-grp.node-name else "")
        bsj-groups.obj-code = 0
        .
      end. /*if not avail bsj-groups*/
      FIND FIRST sj-groups WHERE
                sj-groups.g-code = card-clients.grp-code AND
                sj-groups.obj-code = ub.dis-obj.obj-code No-ERROR.
      IF NOT AVAIL sj-groups then do:
        FIND FIRST ub.cli-grp No-LOCK WHERE
                  ub.cli-grp.node-code = card-clients.grp-code NO-ERROR.
        create sj-groups.
        assign
        sj-groups.g-code = card-clients.grp-code
        sj-groups.g-name = (if avail cli-grp then cli-grp.node-name else "")
        sj-groups.obj-code = dis-obj.obj-code
        .
      end. /*if not avail sj-groups*/
    end. /*if p-sort-mode = "group":U then do:*/
    FIND FIRST sj-cards No-LOCK WHERE
               sj-cards.d-card = dis-obj.d-card NO-ERROR.
    IF NOT AVAIL sj-cards then do:
      FIND FIRST ub.dis-host No-LOCK WHERE
                 ub.dis-host.d-card = ub.dis-obj.d-card
             AND ub.dis-host.host-code = p-host-code
             and ub.dis-host.dt-code = 0  No-ERROR.
      create
      sj-cards.
      assign
      new-card = yes
      sj-cards.d-card = ub.dis-obj.d-card
      sj-cards.g-code = card-clients.grp-code
      sj-cards.global-card = (temp-dis-card.emitent-host-code = 0)
      sj-cards.credit-card = temp-dis-card.credit-card
      sj-cards.cli-type = temp-dis-card.cli-type
      sj-cards.cli-code = temp-dis-card.cli-code
      sj-cards.cli-name =  card-clients.obj-name
      sj-cards.d-pcnt = temp-dis-card.d-pcnt
      sj-cards.saldo = (if p-curr-type = {&r-b-rubl}
                        then temp-dis-card.saldo-rubl
                        else temp-dis-card.saldo-base
                        )
      sj-cards.must-pay = if sj-cards.saldo < 0 then (- sj-cards.saldo) else 0
      sj-cards.pay = (if avail dis-host
                      then (if p-curr-type = {&r-b-rubl}
                            then dis-host.pay-tot-rubl
                            else dis-host.pay-tot-base )
                      else 0)
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
      bsj-cards.saldo = bsj-cards.saldo +
                        (if p-curr-type = {&r-b-rubl}
                         then temp-dis-card.saldo-rubl
                         else temp-dis-card.saldo-base
                        )
      bsj-cards.must-pay = bsj-cards.must-pay + (if sj-cards.saldo < 0 then (- sj-cards.saldo) else 0)
      bsj-cards.pay = bsj-cards.pay + (if avail dis-host
                                       then (if p-curr-type = {&r-b-rubl}
                                             then dis-host.pay-tot-rubl
                                             else dis-host.pay-tot-base)
                                       else 0)
      bsj-cards.obj-qnty = bsj-cards.obj-qnty + 1
      .
      if dcardmode = "LIST"
      or dcardmode = "ONE" then do:
        assign
        sj-cards.d-pcntchr = get-d-pcntdc-list ( buffer dc-list
                                      ,input p-host-code
                                      ,input obj-list.obj-type
                                      ,input obj-list.obj-code
                                      ,input {&ddctr-def-pcnt}
                                      ,output loc-d-pcnt).
      end.
      else do:
        assign
        sj-cards.d-pcntchr = get-d-pcnt ( buffer ub.dis-card
                                      ,input p-host-code
                                      ,input obj-list.obj-type
                                      ,input obj-list.obj-code
                                      ,input {&ddctr-def-pcnt}
                                      ,output loc-d-pcnt).
      end.
    end. /*if not avail sj-cards*/
    if p-curr-type = {&r-b-rubl} then do:
      assign
      sj-cards.tot = sj-cards.tot + dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl
      sj-cards.disc = sj-cards.disc + dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl
      sj-cards.netto = sj-cards.netto + (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl) -
                                        (dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl)
      sj-cards.instant-pay = sj-cards.instant-pay + dis-obj.pay-tot-rubl
      sj-cards.credit-pay = sj-cards.credit-pay + (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl) -
                                                  (dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl) -
                                                  dis-obj.pay-tot-rubl
      sj-cards.num-chk = sj-cards.num-chk + dis-obj.num-chk
      sj-cards.obj-qnty = if sj-cards.obj-qnty = 0
                          then dis-obj.obj-code
                          else (- 1)
      .
    end.
    else do:
      assign
      sj-cards.tot = sj-cards.tot + dis-obj.gds-tot-base + dis-obj.sum-tot-base
      sj-cards.disc = sj-cards.disc + dis-obj.gds-dis-base +  dis-obj.sum-dis-base
      sj-cards.netto = sj-cards.netto + (dis-obj.gds-tot-base + dis-obj.sum-tot-base) -
                                        (dis-obj.gds-dis-base +  dis-obj.sum-dis-base)
      sj-cards.instant-pay = sj-cards.instant-pay + dis-obj.pay-tot-base
      sj-cards.credit-pay = sj-cards.credit-pay + (dis-obj.gds-tot-base + dis-obj.sum-tot-base) -
                                                  (dis-obj.gds-dis-base +  dis-obj.sum-dis-base) -
                                                  dis-obj.pay-tot-base
      sj-cards.num-chk = sj-cards.num-chk + dis-obj.num-chk
      sj-cards.obj-qnty = if sj-cards.obj-qnty = 0
                          then dis-obj.obj-code
                          else (- 1)
      .

    end.
    if (t-legacy or t-subsid)
    then do:
      if t-legacy and not t-subsid then do:
        find first legacy-obj no-lock where
                  legacy-obj.obj-type = dis-obj.obj-type
              AND legacy-obj.obj-code = dis-obj.obj-code
          AND legacy-obj.card-num-chr = temp-dis-card.first-card
          no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = temp-dis-card.first-card
          legacy-obj.first-card = temp-dis-card.first-card
          legacy-obj.first-main-card = temp-dis-card.first-main-card
          legacy-obj.main-card = temp-dis-card.main-card
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
              AND legacy-obj.card-num-chr = temp-dis-card.main-card
              no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = temp-dis-card.main-card
          legacy-obj.main-card = temp-dis-card.main-card
          legacy-obj.first-card = temp-dis-card.first-card
          legacy-obj.first-main-card = temp-dis-card.first-main-card
          .
          find first osn_dis-card no-lock where
          osn_dis-card.d-card = legacy-obj.main-card use-index isourced no-error .
          if not available osn_Dis-card then do:
            message
            substitute("Не найдена ОСНОВНАЯ карта &1 для карты &2"
                       ,temp-dis-card.main-card
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
              AND legacy-obj.card-num-chr = temp-dis-card.first-main-card
              no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = temp-dis-card.first-main-card
          legacy-obj.first-main-card = temp-dis-card.first-main-card
          legacy-obj.first-card = temp-dis-card.first-card
          legacy-obj.main-card = temp-dis-card.main-card
          .
          /*надо найти ТЕКУЩУЮ карту ОСНОВНОЙ цепочки*/
          find last osn_dis-card no-lock where
          osn_dis-card.first-card = legacy-obj.first-card
          and osn_dis-card.is-subsid = no
          use-index isourced no-error .
          if not available osn_dis-card then do:
            message
            substitute("Не найдена текущая ПЕРВАЯ ОСНОВНАЯ карта &1 для карты &2"
                       ,temp-dis-card.first-card
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
    if p-sort-mode = "group":U then do:
&scop assign-sj-groups                                                                                                                  ~
      assign                                                                                                                            ~
      sj-groups.tot = sj-groups.tot + dis-obj.gds-tot-~{&curr-type~} + dis-obj.sum-tot-~{&curr-type~}                                   ~
      sj-groups.disc = sj-groups.disc + dis-obj.gds-dis-~{&curr-type~} +  dis-obj.sum-dis-~{&curr-type~}                                ~
      sj-groups.netto = sj-groups.netto + (dis-obj.gds-tot-~{&curr-type~} + dis-obj.sum-tot-~{&curr-type~}) -                           ~
                                        (dis-obj.gds-dis-~{&curr-type~} +  dis-obj.sum-dis-~{&curr-type~})                              ~
      sj-groups.instant-pay = sj-groups.instant-pay + dis-obj.pay-tot-~{&curr-type~}                                         ~
      sj-groups.credit-pay = sj-groups.credit-pay + (dis-obj.gds-tot-~{&curr-type~} + dis-obj.sum-tot-~{&curr-type~}) -                 ~
                                                  (dis-obj.gds-dis-~{&curr-type~} +  dis-obj.sum-dis-~{&curr-type~}) -                  ~
                                                  dis-obj.pay-tot-~{&curr-type~}                                             ~
      sj-groups.num-chk = sj-groups.num-chk + dis-obj.num-chk                                                     ~
      sj-groups.cards-qnty = sj-groups.cards-qnty + 1                                                             ~
      sj-groups.pay = 0                                                                                           ~
      sj-groups.must-pay = 0                                                                                      ~
      sj-groups.saldo = 0                                                                                         ~
      sj-groups.obj-qnty = (if sj-groups.obj-qnty = 0 then dis-obj.obj-code else (- 1))                           ~
      bsj-groups.tot = bsj-groups.tot + dis-obj.gds-tot-~{&curr-type~} + dis-obj.sum-tot-~{&curr-type~}                                 ~
      bsj-groups.disc = bsj-groups.disc + dis-obj.gds-dis-~{&curr-type~} +  dis-obj.sum-dis-~{&curr-type~}                              ~
      bsj-groups.netto = bsj-groups.netto + (dis-obj.gds-tot-~{&curr-type~} + dis-obj.sum-tot-~{&curr-type~}) -                         ~
                                        (dis-obj.gds-dis-~{&curr-type~} +  dis-obj.sum-dis-~{&curr-type~})                              ~
      bsj-groups.instant-pay = bsj-groups.instant-pay +  dis-obj.pay-tot-~{&curr-type~}                                      ~
      bsj-groups.credit-pay = bsj-groups.credit-pay + (dis-obj.gds-tot-~{&curr-type~} + dis-obj.sum-tot-~{&curr-type~}) -               ~
                                                  (dis-obj.gds-dis-~{&curr-type~} +  dis-obj.sum-dis-~{&curr-type~}) -                  ~
                                                  dis-obj.pay-tot-~{&curr-type~}                                             ~
      bsj-groups.num-chk = bsj-groups.num-chk + dis-obj.num-chk                                                   ~
      bsj-groups.cards-qnty = bsj-groups.cards-qnty + (if new-card then 1 else 0)                                 ~
      bsj-groups.saldo = bsj-groups.saldo + (if new-card then sj-cards.saldo else 0)                              ~
      bsj-groups.must-pay = bsj-groups.must-pay + (if new-card then sj-cards.must-pay else 0)                     ~
      bsj-groups.pay = bsj-groups.pay +  (if new-card then sj-cards.pay else 0)                                   ~
      bsj-groups.obj-qnty = (if bsj-groups.obj-qnty = 0 then dis-obj.obj-code else (- 1))


      if p-curr-type = {&r-b-rubl} then do:
  &scop curr-type rubl
        {&assign-sj-groups}.

      end.
      else do:
  &scop curr-type base
        {&assign-sj-groups}.

      end.
  end. /*if p-sort-mode = group*/
end.

end procedure. /* process-dis-obj */