block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rkepsync.p $
$Archive: str/rkepsync.p $

Синхронизация имен персонала в IBS TH с именами персонала на кассе R-keeper

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/18/05
Author: Bakhtadze Natalya
Creation date: 02/18/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-rid-list as character no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rkepsync.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsync.p $":U .
define variable vss-description as character no-undo init "Синхронизация имен персонала в IBS TH с именами персонала на кассе R-keeper".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/fbrglib.i     }
{ str/libbcrcn.i }
{ str/r-keepth.i }
define temp-table tt0-staff no-undo like ub.staff.
{ trg/person1s.i tt0-staff }


define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ii0 AS INTEGER NO-UNDO.
define variable ii-ok as integer no-undo .
define variable v-callpoint as character no-undo .
define variable v-rid as recid no-undo .
define variable v-stop-state as logical no-undo .



define buffer buf_cd-clu for ub.cd-clu.
define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.

do
on error undo, return error return-value
:


  assign
  ii0 = num-entries(p-rid-list)
  .


  _ii:
  DO ii = 1 TO ii0:

    FIND FIRST buf_cd-clu Exclusive-lock WHERE
              RECID(buf_cd-clu) = INTEGER(ENTRY(ii, p-rid-list)) NO-ERROR.
    IF not AVAILABLE  buf_cd-clu  THEN do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Не найдена или занята запись персонала на кассе R-keeper c recid &1", INTEGER(ENTRY(ii, p-rid-list)))).
        assign
        v-view-log = yes.
        next _ii.
    end.
      /*найдем clients  */
    find first buf_clients exclusive-lock where
              buf_clients.obj-type = buf_cd-clu.cli-type
        AND  buf_clients.obj-code = buf_cd-clu.cli-code NO-WAIT no-error .
    find first buf_person exclusive-lock where
           buf_person.psn-code = buf_cd-clu.obj-code NO-WAIT no-error .

    if not available buf_clients and not locked buf_clients
    or (not available buf_person and not locked buf_person)
    then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Запись персонала на кассе R-KEEPER с id &1 <&2>&3 - не найдена соответствующая запись &4&5 в IBS TH"
                              , buf_cd-clu.clu-code
                              , buf_cd-clu.charkey_one
                              , {&new-line}
                              , buf_cd-clu.cli-type
                              , buf_cd-clu.cli-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
    end.
    if locked buf_clients
    or locked buf_person
    then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Запись персонала на кассе R-KEEPER с id &1 <&2>&3 - соответствующая запись &4&5 в IBS TH ЗАНЯТА"
                              , buf_cd-clu.clu-code
                              , buf_cd-clu.charkey_one
                              , {&new-line}
                              , buf_cd-clu.cli-type
                              , buf_cd-clu.cli-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
    end.
    /*переименуем если надо*/
    assign
    v-rid = recid(buf_Clients)
    v-callpoint = (if buf_cd-clu.clu-type = "K":U then {&role-cashier} else {&role-seller}).
    .
    if buf_clients.obj-name <> buf_cd-clu.charkey_one then do:
      run ref/person1.p (
                input parparentproc
              ,input this-procedure :handle
              ,input-output v-rid
              ,input {&update}
              ,input v-callpoint
              ,input yes /*p-silent*/
              ,input buf_clients.obj-code
              ,input buf_clients.stts
              ,input buf_cd-clu.charkey_one
              ,input buf_clients.lim-kr
              ,input buf_clients.PS
              ,input buf_clients.grp-code
              ,input buf_person.address
              ,input buf_person.city
              ,input buf_person.date-birth
              ,input buf_person.e-mail
              ,input buf_person.fax
              ,input buf_person.firm-code
              ,input buf_person.firm-name
              ,input buf_person.gender
              ,input buf_person.given-by
              ,input buf_person.ind
              ,input buf_person.inn
              ,input no /*p-no-check-inn */
              ,input buf_person.is-pboul
              ,input buf_person.kpp
              ,input buf_person.name1
              ,input buf_person.name2
              ,input buf_person.okonh
              ,input buf_person.okpo
              ,input buf_person.passp-num
              ,input buf_person.passp-ser
              ,input buf_person.phone1
              ,input buf_person.phone1-note
              ,input buf_person.position
              ,input buf_person.post-box
              ,input buf_person.post-address
              ,input buf_person.post-city
              ,input buf_person.post-ind
              ,input buf_clients.reg-code
              ,input no /* p-turnover-buyer     */
              ,input no /*p-turnover-buyer-gds */
      ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка при переименовании &1&2&3" +
                                "c <&4>&3 на <&5>:&3&6 &7"
                                , buf_cd-clu.cli-type
                                , buf_cd-clu.cli-code
                                , {&new-line}
                                , buf_clients.obj-name
                                , buf_cd-clu.charkey_one
                                , error-status:get-message(1)
                                , return-value
                              )).
        assign
        v-view-log = yes.
        next _ii.
      end.
    end.
    ii-ok = ii-ok + 1.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Обработано &1 записей по персоналу, из них упешно &2"
                                      , ii
                                      , ii-ok
                                      )) no-error.
    run get-stop-state in p-log-handle(output v-stop-state).
    if v-stop-state then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Процесс прерван пользователем"
                            )).
      assign
      v-view-log = yes.
     LEAVE _II.
    end.
  end. /*for eac tt-cd-clu*/

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Из &1 записей по персоналу успешно синхронизировано &2"
                          , ii0
                          , ii-ok
                        )).

end. /*doe*/