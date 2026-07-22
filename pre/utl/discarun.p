block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: discarun.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/discarun.p $":U .
define variable vss-description as character no-undo init "Изменение дисконтных карт по списку".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table dc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable num-rec as integer no-undo.
define variable num-rec-ok as integer no-undo.
DEFINE VARIABLE dc-ri as recid no-undo .
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
if num-entries(p-parameter, chr(1)) <> 2 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении дисконтных карт по списку произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action3   as character no-undo .
  define variable v-printed3       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении дисконтных карт по списку произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'discarun.txt')
    ,input  7
    ,output v-user-action3
    ,output v-printed3
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'discarun.txt').
end.
                        return.
end.
assign
v-val = entry(1, p-parameter, chr(1))
v-do-str = entry(2, p-parameter, chr(1))
.
if num-entries(v-val, chr(4)) <> 18
or num-entries(v-do-str, chr(4)) <> 16
then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении дисконтных карт по списку произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action5   as character no-undo .
  define variable v-printed5       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении дисконтных карт по списку произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'discarun.txt')
    ,input  7
    ,output v-user-action5
    ,output v-printed5
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'discarun.txt').
end.
                        return.
end.
do v-ii = 1 to 15:
  assign
  v-do[v-ii] = logical(entry(v-ii, v-do-str, chr(4)))
  no-error
  .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Ошибка входных параметров &1:&2&3&4"
                            , p-parameter
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            )).
      assign
      v-view-log = yes.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении дисконтных карт по списку произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action7   as character no-undo .
  define variable v-printed7       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении дисконтных карт по списку произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'discarun.txt')
    ,input  7
    ,output v-user-action7
    ,output v-printed7
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'discarun.txt').
end.
                        return.
  end.
end.
assign
p-curr-obj-type = entry(1, v-val, chr(4))
p-curr-obj-code = integer(entry(2, v-val, chr(4)))
pardc-status_ = entry(3, v-val, chr(4))
pardc-status_ = (if num-entries(pardc-status_) > 1
               then (entry(1, pardc-status_) + chr(4) + entry(2, pardc-status_))
               else pardc-status_)
pardc-type    = entry(4, v-val, chr(4))
paremitent-host-code   = integer(entry(5, v-val, chr(4)))
pard-pcnt = if entry(6, v-val, chr(4)) = "":U then ? else decimal(entry(6, v-val, chr(4)))
parcash-d-pcnt = if entry(7, v-val, chr(4)) = "":U then ? else decimal(entry(7, v-val, chr(4)))
parcategory = if entry(8, v-val, chr(4)) = "":U then ? else integer(entry(8, v-val, chr(4)))
v-dop = entry(9, v-val, chr(4))
parissue-date =  if v-do[7]
                  then
                  date(integer(substring(v-dop, 4, 2)),
                                        integer(substring(v-dop, 1, 2)),
                                        integer(substring(v-dop, 7, 4))
                                        )
                  else 01/01/1990
parissue-code = integer(entry(10, v-val, chr(4)))
parcredit-card = if trim(entry(11, v-val, chr(4)))= "yes":U then yes else no
pardebet-card = if trim(entry(12, v-val, chr(4)))= "yes":U then yes else no
parstaff-card = if trim(entry(13, v-val, chr(4)))= "yes":U then yes else no
parlim-kr = decimal(entry(14, v-val, chr(4)))
v-dop = entry(15, v-val, chr(4))
parvalid-from   = if v-do[13]
                  then
                  date(integer(substring(v-dop, 4, 2)),
                                        integer(substring(v-dop, 1, 2)),
                                        integer(substring(v-dop, 7, 4))
                                        )
                  else (01/01/1990)
v-dop = entry(16, v-val, chr(4))
parvalid-date   = if v-do[14]
                  then
                  date(integer(substring(v-dop, 4, 2)),
                                        integer(substring(v-dop, 1, 2)),
                                        integer(substring(v-dop, 7, 4))
                                        )
                  else (01/01/1990)
pard-pcnt-method = if entry(17, v-val, chr(4)) = "":U then ? else integer(entry(18, v-val, chr(4)))
parcli-message   = entry(18, v-val, chr(4))
no-error .
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении дисконтных карт по списку произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action9   as character no-undo .
  define variable v-printed9       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении дисконтных карт по списку произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'discarun.txt')
    ,input  7
    ,output v-user-action9
    ,output v-printed9
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'discarun.txt').
end.
                        return.
end.
if (p-curr-obj-type <> 'маг':U
AND p-curr-obj-type <> 'скл':U)
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
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении дисконтных карт по списку произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action11   as character no-undo .
  define variable v-printed11       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении дисконтных карт по списку произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'discarun.txt')
    ,input  7
    ,output v-user-action11
    ,output v-printed11
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'discarun.txt').
end.
                        return.
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
                  ,input ?
                  ,input yes
                  ,input-output dc-ri
                  ,input 'ИЗМЕНЕНИЕ':U
                  ,input '':U
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ,input dis-card.d-card
                  ,input (if v-do[2] then paremitent-host-code else dis-card.emitent-host-code)
                  ,input dis-card.cli-type
                  ,input dis-card.cli-code
                  ,input (if v-do[1] then pardc-status_ else  dis-card.status_)
                  ,input (if v-do[2] then pardc-type else dis-card.type)
                  ,input (IF v-do[4]
                          and (
                                (
                                  (dis-card.d-pcnt-method = integer('1':U))
                                    or
                                  (dis-card.d-pcnt-method = integer('3':U))
                                )
                                OR
                                (
                                  v-do[15] and
                                  (
                                    (pard-pcnt-method = integer('1':U))
                                  or
                                    (pard-pcnt-method = integer('3':U))
                                  )
                                )
                              )
                        then pard-pcnt
                        else dis-card.d-pcnt)
                  ,input (IF v-do[5]
                         and (
                                (
                                   (dis-card.d-pcnt-method = integer('2':U))
                                     or
                                   (dis-card.d-pcnt-method = integer('3':U))
                                )
                              OR
                                (
                                  v-do[15] and
                                  (
                                    (pard-pcnt-method = integer('2':U))
                                  or
                                    (pard-pcnt-method = integer('3':U))
                                  )
                                )
                              )
                        then parcash-d-pcnt
                        else dis-card.cash-d-pcnt)
                  ,input (if v-do[6]
                          THEN parCategory
                          else dis-card.category)
                  ,input (if v-do[15]
                          then integer(pard-pcnt-method)
                          else dis-card.d-pcnt-method)
                  ,input (if v-do[9]
                          THEN parCREDIT-CARD
                          else dis-card.credit-card)
                  ,input (if v-do[12]
                        then parlim-kr
                        else dis-card.lim-kr)
                  ,input (if v-do[10]
                          THEN pardebet-CARD
                          else dis-card.debet-card)
                  ,input (if v-do[11]
                          THEN parstaff-CARD
                          else dis-card.staff-card)
                  ,input (IF v-do[7]
                          then parissue-date
                          else dis-card.issue-date)
                  ,input (IF v-do[8]
                          then parissue-code
                          else dis-card.issue-code)
                  ,input (IF v-do[13]
                          then parvalid-from
                          else dis-card.valid-from)
                  ,input (IF v-do[14]
                          then parvalid-date
                          else dis-card.valid-date)
                  ,input dis-card.sourced-card
                  ,input (if v-do[16]
                          THEN parCli-message
                          else dis-card.cli-message)
                  ,input no
                  ,input dis-card.main-card
                  ,input dis-card.is-subsid
                  ,INPUT no
                  ,INPUT table tt0-dis-card-property
                                    ) no-error.
    IF ERROR-STATUS:ERROR then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка изменения записи дисконтной карты &1:&2&3 &4"
                              , dc-list.d-card
                              , chr(10)
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении дисконтных карт по списку произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action13   as character no-undo .
  define variable v-printed13       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении дисконтных карт по списку произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'discarun.txt')
    ,input  7
    ,output v-user-action13
    ,output v-printed13
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'discarun.txt').
end.
                        return.
