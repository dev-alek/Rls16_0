block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: discarun.p $
$Archive: utl/discarun.p $

Изменение дисконтных карт по списку

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/12/04
Author: Bakhtadze Natalya
Creation date: 11/12/04

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define variable p-curr-obj-type like ub.cleints.obj-type no-undo.
define variable p-curr-obj-code like ub.cleints.obj-code no-undo.
define variable pardc-status_ like ub.dis-card.status_ no-undo.
define variable pardc-type like ub.dis-card.type no-undo.
define variable par-emitent-host-code like ub.dis-card.emitent-host-code no-undo.
define variable pard-pcnt like dis-card.d-pcnt no-undo.
define variable parcash-d-pcnt like dis-card.cash-d-pcnt no-undo.
define variable parcategory like dis-card.category no-undo.
define variable parissue-date like dis-card.issue-date no-undo.
define variable parissue-code like dis-card.issue-code no-undo.
define variable parcredit-card like ub.dis-card.credit-card no-undo.
define variable pardebet-card like ub.dis-card.debet-card no-undo.
define variable parstaff-card like ub.dis-card.staff-card no-undo.
define variable parlim-kr like ub.dis-card.lim-kr no-undo.
define variable parvalid-from like ub.dis-card.valid-from no-undo .
define variable parvalid-date like ub.dis-card.valid-date no-undo .
define variable pard-pcnt-method like dis-card.d-pcnt-method no-undo.
define variable parcli-message   like dis-card.cli-message no-undo .
*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: discarun.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/discarun.p $":U .
define variable vss-description as character no-undo init "Изменение дисконтных карт по списку".
{ cmp/vssrevis.i }

define variable p-curr-obj-type like ub.clients.obj-type no-undo.
define variable p-curr-obj-code like ub.clients.obj-code no-undo.
define variable pardc-status_ like ub.dis-card.status_ no-undo.
define variable pardc-type like ub.dis-card.type no-undo.
define variable paremitent-host-code like ub.dis-card.emitent-host-code no-undo.
define variable pard-pcnt like ub.dis-card.d-pcnt no-undo.
define variable parcash-d-pcnt like ub.dis-card.cash-d-pcnt no-undo.
define variable parcategory like ub.dis-card.category no-undo.
define variable parissue-date like ub.dis-card.issue-date no-undo.
define variable parissue-code like ub.dis-card.issue-code no-undo.
define variable parcredit-card like ub.dis-card.credit-card no-undo.
define variable pardebet-card like ub.dis-card.debet-card no-undo.
define variable parstaff-card like ub.dis-card.staff-card no-undo.
define variable parlim-kr like ub.dis-card.lim-kr no-undo.
define variable parvalid-from like ub.dis-card.valid-from no-undo .
define variable parvalid-date like ub.dis-card.valid-date no-undo .
define variable pard-pcnt-method like ub.dis-card.d-pcnt-method no-undo.
define variable parcli-message   like ub.dis-card.cli-message no-undo .
{ cmp/trg-def.i }
{ cmp/dc-list.i dc-list def "shared" }
define variable num-rec as integer no-undo.
define variable num-rec-ok as integer no-undo.
DEFINE VARIABLE dc-ri as recid no-undo .


/*имя log-file */
define variable log-file-name                as character      no-undo init "discarun.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-rid                        as recid          no-undo .
define variable v-dop                        as character no-undo .
define variable v-val as character no-undo .
define variable v-do-str  as character no-undo .
define variable v-do      as logical no-undo extent 16.
define variable v-ii      as integer no-undo .
define temp-table tt0-dis-card-property no-undo like ub.dis-card-property .


&scop       dc-status         1
&scop       dc-type           2
&scop       emitent-host-code 3
&scop       d-pcnt            4
&scop       cash-d-pcnt       5
&scop       category          6
&scop       issue-date        7
&scop       issue-code        8
&scop       credit-card       9
&scop       debet-card       10
&scop       staff-card       11
&scop       lim-kr           12
&scop       valid-from       13
&scop       valid-date       14
&scop       d-pcnt-method    15
&scop       cli-message      16


&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При изменении дисконтных карт по списку произошли ошибки!!!'" ~
                    "'discarun.txt'" ~}   ~
                    return

if num-entries(p-parameter, {&delim-nws}) <> 2 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.
assign
v-val = entry(1, p-parameter, {&delim-nws})
v-do-str = entry(2, p-parameter, {&delim-nws})
.
if num-entries(v-val, {&delim-par}) <> 18
or num-entries(v-do-str, {&delim-par}) <> 16
then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.
do v-ii = 1 to 15:
  assign
  v-do[v-ii] = logical(entry(v-ii, v-do-str, {&delim-par}))
  no-error
  .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Ошибка входных параметров &1:&2&3&4"
                            , p-parameter
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            )).
      assign
      v-view-log = yes.
      {&view-log}.
  end.
end.


assign
p-curr-obj-type = entry(1, v-val, {&delim-par})
p-curr-obj-code = integer(entry(2, v-val, {&delim-par}))
pardc-status_ = entry(3, v-val, {&delim-par})
pardc-status_ = (if num-entries(pardc-status_) > 1
               then (entry(1, pardc-status_) + {&delim-par} + entry(2, pardc-status_))
               else pardc-status_)
pardc-type    = entry(4, v-val, {&delim-par})
paremitent-host-code   = integer(entry(5, v-val, {&delim-par}))
pard-pcnt = if entry(6, v-val, {&delim-par}) = "":U then ? else decimal(entry(6, v-val, {&delim-par}))
parcash-d-pcnt = if entry(7, v-val, {&delim-par}) = "":U then ? else decimal(entry(7, v-val, {&delim-par}))
parcategory = if entry(8, v-val, {&delim-par}) = "":U then ? else integer(entry(8, v-val, {&delim-par}))
v-dop = entry(9, v-val, {&delim-par})
parissue-date =  if v-do[{&issue-date}]
                  then
                  date(integer(substring(v-dop, 4, 2)),
                                        integer(substring(v-dop, 1, 2)),
                                        integer(substring(v-dop, 7, 4))
                                        )
                  else 01/01/1990
parissue-code = integer(entry(10, v-val, {&delim-par}))
parcredit-card = if trim(entry(11, v-val, {&delim-par}))= "yes":U then yes else no
pardebet-card = if trim(entry(12, v-val, {&delim-par}))= "yes":U then yes else no
parstaff-card = if trim(entry(13, v-val, {&delim-par}))= "yes":U then yes else no
parlim-kr = decimal(entry(14, v-val, {&delim-par}))
v-dop = entry(15, v-val, {&delim-par})
parvalid-from   = if v-do[{&valid-from}]
                  then
                  date(integer(substring(v-dop, 4, 2)),
                                        integer(substring(v-dop, 1, 2)),
                                        integer(substring(v-dop, 7, 4))
                                        )
                  else (01/01/1990)
v-dop = entry(16, v-val, {&delim-par})
parvalid-date   = if v-do[{&valid-date}]
                  then
                  date(integer(substring(v-dop, 4, 2)),
                                        integer(substring(v-dop, 1, 2)),
                                        integer(substring(v-dop, 7, 4))
                                        )
                  else (01/01/1990)
pard-pcnt-method = if entry(17, v-val, {&delim-par}) = "":U then ? else integer(entry(18, v-val, {&delim-par}))
parcli-message   = entry(18, v-val, {&delim-par})
no-error .
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.
if (p-curr-obj-type <> {&shop}
AND p-curr-obj-type <> {&stock})
or not can-find (first ub.clients no-lock where
                      ub.clients.obj-type = p-curr-obj-type
                 AND  ub.clients.obj-code = p-curr-obj-code )
                 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров p-curr-obj-type &1 p-curr-obj-code &2:&3&4&5"
                         , p-curr-obj-type
                         , p-curr-obj-code
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.

end.

if NOT g#db-num = 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Изменение дисконтных карт возможно только в ГБД")).
  assign
  v-view-log = yes.
  return.
end.

run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Изменение дисконтных карт по списку")).


_dc-list:
for each dc-list no-lock,
    first ub.dis-card no-lock where
          ub.dis-card.d-card = dc-list.d-card:
  assign
  num-rec = num-rec + 1
  dc-ri = recid(dis-card)
  .
  if pardc-type <> "":U then do:
    find first ub.dis-card-type no-lock where
              ub.dis-card-type.type = pardc-type
          AND ub.dis-card-type.emitent-host-code = paremitent-host-code no-error .
      if not avail ub.dis-card-type then do:
      neXt .
    end.
  end.
  else do:
    find first dis-card-type no-lock where
              dis-card-type.type = dis-card.type
          AND dis-card-type.emitent-host-code = dis-card.emitent-host-code no-error .
      if not avail dis-card-type then do:
      neXt .
    end.

  end.
  run ref/dcardi01.p (
                   input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input ? /*handle для вызова процедур истории и маршрутизации - используется в saledc*/
                  ,input yes
                  ,input-output dc-ri
                  ,input {&update}
                  ,input '':U /*par-mode2*/
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ,input dis-card.d-card
                  ,input (if v-do[{&dc-type}] then paremitent-host-code else dis-card.emitent-host-code)
                  ,input dis-card.cli-type
                  ,input dis-card.cli-code
                  ,input (if v-do[{&dc-status}] then pardc-status_ else  dis-card.status_)
                  ,input (if v-do[{&dc-type}] then pardc-type else dis-card.type)
                  ,input (IF v-do[{&d-pcnt}]
                          and (
                                (
                                  (dis-card.d-pcnt-method = integer({&dc-d-pcnt-good}))
                                    or
                                  (dis-card.d-pcnt-method = integer({&dc-d-pcnt-both}))
                                )
                                OR
                                (
                                  v-do[{&d-pcnt-method}] and
                                  (
                                    (pard-pcnt-method = integer({&dc-d-pcnt-good}))
                                  or
                                    (pard-pcnt-method = integer({&dc-d-pcnt-both}))
                                  )
                                )
                              )
                        then pard-pcnt
                        else dis-card.d-pcnt)
                  ,input (IF v-do[{&cash-d-pcnt}]
                         and (
                                (
                                   (dis-card.d-pcnt-method = integer({&dc-d-pcnt-cash}))
                                     or
                                   (dis-card.d-pcnt-method = integer({&dc-d-pcnt-both}))
                                )
                              OR
                                (
                                  v-do[{&d-pcnt-method}] and
                                  (
                                    (pard-pcnt-method = integer({&dc-d-pcnt-cash}))
                                  or
                                    (pard-pcnt-method = integer({&dc-d-pcnt-both}))
                                  )
                                )
                              )
                        then parcash-d-pcnt
                        else dis-card.cash-d-pcnt)
                  ,input (if v-do[{&category}]
                          THEN parCategory
                          else dis-card.category)
                  ,input (if v-do[{&d-pcnt-method}]
                          then integer(pard-pcnt-method)
                          else dis-card.d-pcnt-method)
                  ,input (if v-do[{&credit-card}]
                          THEN parCREDIT-CARD
                          else dis-card.credit-card)
                  ,input (if v-do[{&lim-kr}]
                        then parlim-kr
                        else dis-card.lim-kr)
                  ,input (if v-do[{&debet-card}]
                          THEN pardebet-CARD
                          else dis-card.debet-card)
                  ,input (if v-do[{&staff-card}]
                          THEN parstaff-CARD
                          else dis-card.staff-card)
                  ,input (IF v-do[{&issue-date}]
                          then parissue-date
                          else dis-card.issue-date)
                  ,input (IF v-do[{&issue-code}]
                          then parissue-code
                          else dis-card.issue-code)
                  ,input (IF v-do[{&valid-from}]
                          then parvalid-from
                          else dis-card.valid-from)
                  ,input (IF v-do[{&valid-date}]
                          then parvalid-date
                          else dis-card.valid-date)
                  ,input dis-card.sourced-card
                  ,input (if v-do[{&cli-message}]
                          THEN parCli-message
                          else dis-card.cli-message)
                  ,input no
                  ,input dis-card.main-card
                  ,input dis-card.is-subsid
                  ,INPUT no /*v-update-property*/
                  ,INPUT table tt0-dis-card-property
                                    ) no-error.
    IF ERROR-STATUS:ERROR then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка изменения записи дисконтной карты &1:&2&3 &4"
                              , dc-list.d-card
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              ) ).
        assign
        v-view-log = yes.
    end.
    else do:
      num-rec-ok = num-rec-ok + 1.
    end.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                                , num-rec
                                                , num-rec-ok
                                                )) no-error.
    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _dc-list.
    end.
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение по списку ДК завершено: из &1 записей отредактировано &2", num-rec, num-rec-ok )).
{&view-log}.