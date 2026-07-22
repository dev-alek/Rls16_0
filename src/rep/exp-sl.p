block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exp-sl.p $
$Archive: rep/exp-sl.p $

Выгрузка продаж для Nielsen

Автор: Белоусов Илья Александрович
Дата создания: 03/25/09
Author: Ilia Belousov
Creation date: 03/25/09

*/
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-db-num-char    as character    no-undo.
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-db-num         as integer      no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-sl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/exp-sl.p $":U .
define variable vss-description as character no-undo init "Выгрузка продаж для Nielsen".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ rep/exp-sl.i       }
{ ref/shd-attr.i }
{ trg/factord.i  }

   &scop display-message    run write-log-and-file in p-log-handle (  ~
         input 1                                                      ~
         , input "shd-free.log"                                          ~
         , input 1                                                      ~
         , input ~{&my-message~})

define variable v-ftp-address   as character    no-undo.
define variable v-login         as character    no-undo.
define variable v-password      as character    no-undo.
define variable v-name          as character    no-undo.
define variable vHost-code_list as character    no-undo.
define variable v-task-num      as integer      no-undo.
define variable v-param-list    as character    no-undo.
define variable v-param-type    as character    no-undo.
define variable v-obj-list      as character    no-undo.
define variable v-ii1           as integer      no-undo.
define variable v-ii2           as integer      no-undo.
define variable vRadio-set-1    as integer      no-undo.

define buffer buf_tt-obj for tt-obj.
define buffer buf_schedule for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.

define variable v-par-val                 as character            no-undo .
define variable v-par-type                as character            no-undo .
define variable v-nielsen    as logical      no-undo.

do
on error undo, return error
:
  run gbl/conf-rd.p ("nielsen":U, "":U, "":U, 0, "":U, "":U, "":U, no, output v-par-val, output v-par-type) no-error.
  IF error-status:error then
    v-nielsen = no.
  else
     ASSIGN
       v-nielsen = LOGICAL( v-par-val )
       NO-ERROR.
  IF error-status:error
  OR v-nielsen = FALSE
  THEN DO:
    &scop my-message "Запрещена выгрузка для Nielsen"
    {&display-message}.
    return.
  END.

  if p-task-num > 0
  then do:
    v-task-num = p-task-num.
  end.
  else do:
    for each buf_schedule
       where buf_schedule.task-type     = p-task-type
         AND buf_schedule.cre-db-num    = INTEGER(p-db-num-char)
       no-lock
       ,
       first buf_schedule-attr
       where buf_schedule-attr.task-type   = p-task-type
         AND buf_schedule-attr.cre-db-num  = INTEGER(p-db-num-char)
         AND buf_schedule-attr.task-num    = buf_schedule.task-num
         AND buf_schedule-attr.attr-code   = ({&attr-schd-free-id} + {&delim-par} + 'exp-sale')
       no-lock
       :
       ASSIGN
          v-task-num = buf_schedule.task-num
       .
       leave .
    end.
  end.
  if v-task-num > 0
  then do:
    run schedule-attr-value in this-procedure  ( input p-db-num-char
                                               , input p-task-type
                                               , input v-task-num
                                               , input {&attr-schedule-param-list-h}
                                               , output v-param-list
                                               , output v-param-type
                                               ) NO-ERROR .
  end.
  v-ii2 = num-entries( v-param-list, {&delim-par} ).
  if v-ii2 < 6 THEN do:
    do v-ii1 = v-ii2 to 6:
      v-param-list = v-param-list
                   + '':U
                   + {&delim-par}.
    end.
  end.
  ASSIGN
     v-ftp-address   = ENTRY(1, v-param-list, {&delim-par})
     v-login         = ENTRY(2, v-param-list, {&delim-par})
     v-password      = ENTRY(3, v-param-list, {&delim-par})
     v-name          = ENTRY(4, v-param-list, {&delim-par})
     vRadio-set-1    = INTEGER( ENTRY(5, v-param-list, {&delim-par}) )
     vHost-code_list = ENTRY(6, v-param-list, {&delim-par})
  .
  EMPTY TEMP-TABLE buf_tt-obj.
  if vRadio-set-1 <> 3 /*все по фирме*/ then do:
    if v-task-num > 0 then
      run schedule-attr-value in this-procedure  ( input p-db-num-char
                                                 , input p-task-type
                                                 , input v-task-num
                                                 , input {&attr-schedule-obj-list-h}
                                                 , output v-obj-list
                                                 , output v-param-type
                                                 ) NO-ERROR .
      define variable ii    as integer      no-undo.
      define variable v-entry  as character no-undo .

      do ii = 1 to num-entries(v-obj-list, {&delim-par})
      on error undo, next
      :
         assign
            v-entry = entry(ii, v-obj-list, {&delim-par})
         .
         FIND FIRST ub.clients
              WHERE ub.clients.obj-type = ENTRY(1, v-entry, {&comma-char})
                AND ub.clients.obj-code = INTEGER(ENTRY(2, v-entry, {&comma-char}))
              NO-LOCK
              NO-ERROR
              .
         IF AVAILABLE ub.clients
         THEN DO:
            create tt-obj.
            ASSIGN
               tt-obj.obj-code  = ub.clients.obj-code
               tt-obj.obj-type  = ub.clients.obj-type
               tt-obj.obj-name  = ub.clients.obj-name
               tt-obj.host-code = ub.clients.host-code
            .
         END.
      end.
    end.
    else do:
      FOR EACH ub.clients NO-LOCK
        WHERE ub.clients.obj-type = {&shop}
      :
        if lookup( string( ub.clients.host-code ), vHost-code_list ) = 0 then
          next.
        CREATE tt-obj.
        ASSIGN
           tt-obj.obj-code  = ub.clients.obj-code
           tt-obj.obj-type  = ub.clients.obj-type
           tt-obj.obj-name  = ub.clients.obj-name
           tt-obj.host-code = ub.clients.host-code
        .
      END.
    end.

  run rep/r-exp-sl.p ( INPUT ?
                 , INPUT v-ftp-address
                 , INPUT ""
                 , INPUT ""
                 , INPUT v-login
                 , INPUT v-password
                 , INPUT v-name
                 , INPUT p-log-handle
                 , INPUT TABLE tt-obj
                 ) .
end.