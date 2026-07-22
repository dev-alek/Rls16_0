/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/29/06
Author: Bakhtadze Natalya
Creation date: 10/29/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if available tb-staff
and tb-staff.psn-code <> wt-staff.psn-code
then do:
  if wt-staff.db-num = g#news-source-db
  or (wt-staff.obj-type <> '':U and wt-staff.obj-code <> 0
      and can-find(first ub.clients no-lock where
                        ub.clients.db-num = g#news-source-db
                    and ub.clients.obj-type = wt-staff.obj-type
                    and ub.clients.obj-code = wt-staff.obj-code)) then do:
    if g#db-num = 0 then do:
      /*убиваем  имеющуюся*/
      delete tb-staff.
    end.
    else do:
      /*игнорируем*/
      v-import = no.
    end.
  end. /*if wt-staff.db-num = g#news-source-db*/
  if wt-staff.db-num = g#db-num
  or (wt-staff.obj-type <> '':U and wt-staff.obj-code <> 0
      and can-find(first ub.clients no-lock where
                        ub.clients.db-num = g#db-num
                    and ub.clients.obj-type = wt-staff.obj-type
                    and ub.clients.obj-code = wt-staff.obj-code)) then do:
    /* такое может быть только в УБД игнорируем*/
    v-import = no.
  end.
end.
/*ищем следуюую запись*/
for each buf_staff where
          buf_staff.role = wt-staff.role
     and  buf_staff.role-level = wt-staff.role-level
     and  buf_staff.work-place = wt-staff.work-place
     and  buf_staff.staff-code = wt-staff.staff-code
     and  buf_staff.date-end >= wt-staff.date-start
 by buf_staff.date-start
 on error undo, return error
 on stop undo, return error
 :
  IF buf_staff.psn-code = wt-staff.psn-code then do:
    /*было удаление из*/
    if buf_staff.date-end = {&end-of-age}
    then do:
      if buf_staff.date-start = wt-staff.date-start then do:
      buf_staff.date-end = wt-staff.date-end.
        v-import = no.
        leave.
    end.
    else do:
        v-import = no.
        leave.
      end.
    end.
    else do:
      if buf_staff.date-start = wt-staff.date-start
        and ( wt-staff.db-num = g#news-source-db
              or ( wt-staff.obj-type <> '':U
                   and wt-staff.obj-code <> 0
                   and can-find(first ub.clients no-lock where
                                      ub.clients.db-num = g#news-source-db
                                  and ub.clients.obj-type = wt-staff.obj-type
                                  and ub.clients.obj-code = wt-staff.obj-code
                                )
                 )
            )
      then do:
        buf_staff.date-end = wt-staff.date-end.
        v-import = no.
        leave.
      end.
      else do:
        v-import = no.
      end.
    end.
    if buf_staff.date-end < wt-staff.date-end then do:
      if buf_staff.date-start = wt-staff.date-start then do:
        buf_staff.date-end = wt-staff.date-end.
        v-import = yes.
        leave.
      end.
    end. 
  end.
  else do:
    if buf_staff.date-start < wt-staff.date-start
    and wt-staff.date-start >= v-today + 1 then do:
      /*сокращаем date-end для записи лежащей в */
      assign
      buf_staff.date-end = (if buf_staff.date-end - wt-staff.date-start >= 1
                            then wt-staff.date-start - 1
                            else buf_staff.date-end)
                            .
    end. /*if buf_staff.date-start < wt-staff.date-start*/
    else do:
      if wt-staff.db-num = g#news-source-db
      or (wt-staff.obj-type <> '':U and wt-staff.obj-code <> 0
          and can-find(first ub.clients no-lock where
                            ub.clients.db-num = g#news-source-db
                        and ub.clients.obj-type = wt-staff.obj-type
                        and ub.clients.obj-code = wt-staff.obj-code)) then do:
        if g#db-num = 0 then do:
          /*убиваем  имеющуюся*/
          delete buf_staff.
        end.
        else do:
          /*игнорируем*/
          v-import = no.
        end.
      end. /*if wt-staff.db-num = g#news-source-db*/
      if wt-staff.db-num = g#db-num
      or (wt-staff.obj-type <> '':U and wt-staff.obj-code <> 0
          and can-find(first ub.clients no-lock where
                            ub.clients.db-num = g#db-num
                        and ub.clients.obj-type = wt-staff.obj-type
                        and ub.clients.obj-code = wt-staff.obj-code)) then do:
        /* такое может быть только в УБД игнорируем*/
        v-import = no.
      end.
    END. /* else if buf_staff.date-start < wt-staff.date-start*/
  end. /*IF buf_staff.psn-code = wt-staff.psn-code then do:*/
END. /*for each buf_staff where*/

if v-import = yes then do:
  IF NOT AVAILABLE Tb-STAFF then DO:
    CREATE TB-STAFF.
  END.
  BUFFER-COPY wt-staff to tb-staff.
end.

if v-import = no then do:
  if available Tb-STAFF then do:
      Tb-STAFF.password = wt-staff.password.
  end.
end.

/* $Workfile$ e n d */