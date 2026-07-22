block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rkepsyng.p $
$Archive: str/rkepsyng.p $

Синхронизация названий групп блюд в IBS TH с названиями групп блюд на кассе R-keeper

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
define variable vss-workfile    as character no-undo init "$Workfile: rkepsyng.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsyng.p $":U .
define variable vss-description as character no-undo init "Синхронизация названий групп блюд в IBS TH с названиями групп блюд на кассе R-keeper".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/fbrglib.i     }
{ str/libbcrcn.i }
{ str/r-keepth.i }


define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ii0 AS INTEGER NO-UNDO.
define variable ii-ok as integer no-undo .
define variable v-lvl-num as integer no-undo .
define variable v-upper-num as character no-undo .
define variable v-stop-state as logical no-undo .

define buffer buf_cd-grp for ub.cd-grp.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer upper_fbr-gds-grp for ub.fbr-gds-grp.

do
on error undo, return error return-value
:


  assign
  ii0 = num-entries(p-rid-list)
  .


  _ii:
  DO ii = 1 TO ii0:

    FIND FIRST buf_cd-grp Exclusive-lock WHERE
              RECID(buf_cd-grp) = INTEGER(ENTRY(ii, p-rid-list)) NO-ERROR.
    IF not AVAILABLE  buf_cd-grp  THEN do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Не найдена или занята запись группы блюд на кассе R-keeper c recid &1", INTEGER(ENTRY(ii, p-rid-list)))).
        assign
        v-view-log = yes.
        next _ii.
    end.
      /*найдем fbr-gds-grp на данном объекте с данным out-code */
    find first buf_Fbr-gds-grp exclusive-lock where
              buf_Fbr-gds-grp.obj-type = p-curr-obj-type
        AND  buf_Fbr-gds-grp.obj-code = p-curr-obj-code
        and  buf_Fbr-gds-grp.out-code = buf_cd-grp.grp-code NO-WAIT no-error .
    if not available buf_Fbr-gds-grp and not locked buf_Fbr-gds-grp then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Группа блюд на кассе R-KEEPER с кодом &1 <&2>&3 - не найдена соответствующая группа блюд на  &4&5 в IBS TH"
                              , buf_cd-grp.grp-code
                              , buf_cd-grp.grp-name
                              , {&new-line}
                              , p-curr-obj-type
                              , p-curr-obj-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
    end.
    if locked buf_Fbr-gds-grp then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Группа блюд на кассе R-KEEPER с кодом &1 <&2>&3 - запись для соответствующей группа блюд на &4&5 в IBS TH ЗАНЯТА"
                              , buf_cd-grp.grp-code
                              , buf_cd-grp.grp-name
                              , {&new-line}
                              , p-curr-obj-type
                              , p-curr-obj-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
    end.
    /*переименуем если надо*/
    if buf_Fbr-gds-grp.node-name <> buf_cd-grp.grp-name then do:
      assign
      buf_Fbr-gds-grp.node-name = buf_cd-grp.grp-name
      .
      release
      buf_fbr-gds-grp no-error.
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка при переименовании группа блюд с кодом на кассе &1&2" +
                                "c <&3>&2 на <&4>:&2&5 &6"
                                , buf_fbr-gds-grp.out-code
                                , {&new-line}
                                , buf_fbr-gds-grp.node-name
                                , buf_cd-grp.grp-name
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
    run write-counter in p-log-handle (substitute("Обработано &1 групп блюд, из них упешно &2"
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
  end. /*for eac tt-cd-grp*/

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Из &1 групп блюд успешно синхронизировано &2"
                          , ii0
                          , ii-ok
                        )).

end. /*doe*/