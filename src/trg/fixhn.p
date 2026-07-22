block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Приведение в соответствие с БД опций истории и маршрутизации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/06/07
Author: Bakhtadze Natalya
Creation date: 02/06/07

*/

define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Приведение в соответствие с БД опций истории и маршрутизации".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }  /* не убирать, иначе будет вызываться отовсюду, и СПН не сработает */
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ nws/nws-tabs.i }
{ cmp/tblbname.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-updated as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-mess as logical no-undo .

define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf2_hist-nws-option for ub.hist-nws-option.
define buffer locked_hist-nws-option for ub.hist-nws-option.

run waitfram-show in this-procedure ( "Реинициализация настроек опций истории и маршрутизации").

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  _v-ii:
  do v-ii = 1 to num-entries( news-list):
    find first buf_hist-nws-option no-lock where
              buf_hist-nws-option.db-num = g#db-num
          and buf_hist-nws-option.table-name = entry(v-ii, news-list) no-error.
    if entry(v-ii, news-list) begins "c-":U then next _v-ii.
    if not available buf_hist-nws-option  then do:
      if g#db-num > 0  then do:
        find first buf_hist-nws-option no-lock where
                  buf_hist-nws-option.db-num = 0
            and  buf_hist-nws-option.table-name = entry(v-ii, news-list)
            and  buf_hist-nws-option.charkey_one = '':U
            and  buf_hist-nws-option.charkey_two = '':U
            and  buf_hist-nws-option.charkey_three = '':U
            and  buf_hist-nws-option.key#_one = 0
            and  buf_hist-nws-option.key#_two = 0
            and  buf_hist-nws-option.key#_three = 0
            no-error.
        if available buf_hist-nws-option then do:
          if not available locked_hist-nws-option then do:
            if p-read-only then do:
              v-mess = yes.
              leave _v-ii.
            end.
            find first locked_hist-nws-option exclusive-lock where
                      locked_hist-nws-option.db-num = g#db-num
                  and locked_hist-nws-option.hn-id = 0.
          end.
          find first buf2_hist-nws-option share-lock where
                    buf2_hist-nws-option.db-num = g#db-num
                and buf2_hist-nws-option.hn-id = buf_hist-nws-option.hn-id no-error .
          if available buf2_hist-nws-option then do:
          end.
          else do:
            if p-read-only then do:
              v-mess = yes.
              leave _v-ii.
            end.
            create buf2_hist-nws-option.
            assign
            buf2_hist-nws-option.db-num = g#db-num
            buf2_hist-nws-option.hn-id = buf_hist-nws-option.hn-id.
          end.
          buffer-copy buf_hist-nws-option
          except
          db-num
          get-hist-from-nws
          hist-from-prim
          hist-to-nws
          nws-to-cd
          nws-to-hist
          smart-nws
          to buf2_hist-nws-option
          assign
          buf2_hist-nws-option.db-num = g#db-num
          buf2_hist-nws-option.get-hist-from-nws = ( if buf_hist-nws-option.get-hist-from-nws = integer({&hn-is-on-blocked})
                                                      or buf_hist-nws-option.get-hist-from-nws = integer({&hn-is-off-blocked})
                                                      then buf_hist-nws-option.get-hist-from-nws
                                                      else integer({&hn-is-on}))
          buf2_hist-nws-option.hist-from-prim = ( if buf_hist-nws-option.hist-from-prim = integer({&hn-is-on-blocked})
                                                      or buf_hist-nws-option.hist-from-prim = integer({&hn-is-off-blocked})
                                                      then buf_hist-nws-option.hist-from-prim
                                                      else integer({&hn-is-on}))
          buf2_hist-nws-option.hist-to-nws = ( if buf_hist-nws-option.hist-to-nws = integer({&hn-is-on-blocked})
                                                      or buf_hist-nws-option.hist-to-nws = integer({&hn-is-off-blocked})
                                                      then buf_hist-nws-option.hist-to-nws
                                                      else integer({&hn-is-on}))
          buf2_hist-nws-option.nws-to-cd = ( if buf_hist-nws-option.nws-to-cd = integer({&hn-is-on-blocked})
                                                      or buf_hist-nws-option.nws-to-cd = integer({&hn-is-off-blocked})
                                                      then buf_hist-nws-option.nws-to-cd
                                                      else integer({&hn-is-off}))
          buf2_hist-nws-option.nws-to-hist = ( if buf_hist-nws-option.nws-to-hist = integer({&hn-is-on-blocked})
                                                      or buf_hist-nws-option.nws-to-hist = integer({&hn-is-off-blocked})
                                                      then buf_hist-nws-option.nws-to-hist
                                                      else integer({&hn-is-on}))
          buf2_hist-nws-option.smart-nws = ( if buf_hist-nws-option.smart-nws = integer({&hn-is-on-blocked})
                                                      or buf_hist-nws-option.smart-nws = integer({&hn-is-off-blocked})
                                                      then buf_hist-nws-option.smart-nws
                                                      else integer({&hn-is-off}))
          v-updated                      = yes
          .
        end. /*if available buf_hist-nws-option then do:*/
      end. /*if g#db-num > 0  then do:*/
      else do:
        if p-read-only then do:
          v-mess = yes.
          leave _v-ii.
        end.
        /*заблокируем шапку*/
        if not available locked_hist-nws-option then do:
          find first locked_hist-nws-option exclusive-lock where
                    locked_hist-nws-option.db-num = g#db-num
                and locked_hist-nws-option.hn-id = 0 no-wait no-error.
          if locked locked_hist-nws-option then do:
             message
             substitute("В процессе входа в систему потребовалось реинициализировать настройки записи истории и маршрутизации&1"+
                        "однако ресурс занят&1" +
                        "ТАБЛИЦА &2" +
                        "Имя пользователя, использующего ресурс будет известно после нажатия клавиши ВВОД"
                        , {&new-line}
                        ,entry(v-ii, news-list)
                        )
             view-as alert-box error .
              find first locked_hist-nws-option exclusive-lock where
                        locked_hist-nws-option.db-num = g#db-num
                    and locked_hist-nws-option.hn-id = 0
                    no-error.
             return.
          end.
        end.
        create buf2_hist-nws-option.
        assign
        buf2_hist-nws-option.db-num = g#db-num
        buf2_hist-nws-option.hn-id  = next-value(s-hn-id, {&db-name_schema})
        buf2_hist-nws-option.subject-group = '':U
        buf2_hist-nws-option.table-name = entry(v-ii, news-list)
        buf2_hist-nws-option.get-hist-from-nws = integer({&hn-is-on})
        buf2_hist-nws-option.hist-from-prim    = integer({&hn-is-on})
        buf2_hist-nws-option.hist-to-nws       = integer({&hn-is-on})
        buf2_hist-nws-option.nws-to-cd         = integer({&hn-is-off})
        buf2_hist-nws-option.nws-to-hist       = integer({&hn-is-on})
        buf2_hist-nws-option.smart-nws         = integer({&hn-is-off})
        v-updated                              = yes
        .
      end.
    end. /*if not available buf_hist-nws-option  then do:*/
  end. /*do v-ii = 1 to num-entries( news-list):*/
  if v-mess then do:
    return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,{&new-line}).
  end.
  if v-updated then do:
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    locked_hist-nws-option.option-descr = substitute("&1 &2", string(v-today, "99/99/9999"), string(v-time, "HH:MM:SS")).

  end.
end. /*main-block:*/

run waitfram-hide in this-procedure .