/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

закрытие потока и сопутствующие операции для кассы MARIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found{&vssseq} as logical no-undo .
define variable v-is-script{&vssseq} as logical no-undo.
define variable v-fields-shift{&vssseq} as integer no-undo .

&if "{&subject}" = "dis-card" or  "{&subject}" = "pay" or  "{&subject}" = "good" or  "{&subject}" = "gds-obj-attr"  or  "{&subject}" = "tot-discnt" &then
&if "{&subject}" = "dis-card"  &then
   if can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = {&tekka-obj-clients} ) then do:
    v-fields-shift{&vssseq} = 13.
              /*два раза пишем скидки - для дебет и кредит*/
&endif
&if "{&subject}" = "pay"  &then
   if can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = {&tekka-obj-debet-card} )
   or can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = {&tekka-obj-credit-card} )
   or can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = {&tekka-obj-pay-card} )
   or v-found-maria-discnt
   then do:
    v-fields-shift{&vssseq} = 9 - 1.
&endif
&if "{&subject}" = "good"  &then
   if can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = {&tekka-obj-goods-grp1} )
   or can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = {&tekka-obj-petrol-price} )
   then do:
     v-fields-shift{&vssseq} = - 1.
&endif
&if "{&subject}" = "gds-obj-attr"  &then
   if true then do:
    v-fields-shift{&vssseq} = 1.
&endif

&if "{&subject}" = "tot-discnt"  &then
   if true then do:
    v-fields-shift{&vssseq} = 473.

&endif
if v-record <> '':U then
    run maria-put in this-procedure (
                                    buffer {&cd-buffer}
                                  , input out
                                  , input fname
                                  , input yes
                                  , input v-fields-shift{&vssseq}
                                  , input yes /*binary*/
                                  , input {&tekka-obj-discount-config}
                                  , input 1
                                  , input string(1)   /*в таблице система скидок одна запись*/
                                  , input v-record
                                    ).
   end.
&endif

&if "{&subject}" = "parameters"  &then
/*формат tasks
select 1,2,3,4,17,30,43,61 from :ftp:5712000555:00000000 where dsize=205 and dtime=123 and checktime=5
select 1,2,3,4,17,30,43,61 from COM2:+380502674120:5712000595:00000000 where and checktime=10 and zfactor=1
*/


if search(trim(trim(v-remote, {&slash-char}), {&back-slash-char}) + 'tasks') <> ? then do:
define variable ss{&vssseq} as character no-undo .
define variable ss2{&vssseq} as character no-undo .
  output stream IBmSTREAM to VALUE(out + fname + '.tsk') append.
  input from value(trim(trim(v-remote, {&slash-char}), {&back-slash-char}) + 'tasks').
  repeat:
    import unformatted ss{&vssseq} .
    assign
    ss2{&vssseq} = (if num-entries(ss{&vssseq}, {&space-char}) > 4
           then entry(4, ss{&vssseq}, {&space-char})
           else '':U)
    ss2{&vssseq} = (if num-entries(ss2{&vssseq}, ':':U) = 4
           then entry(3, ss2{&vssseq}, ':')
           else '':U
          )
    .
    find first temp-tekka-tsk where
              temp-tekka-tsk.send-get = 'task'
          AND temp-tekka-tsk.cash-num-char = ss2{&vssseq} no-error.
    if not available temp-tekka-tsk then do:
      put stream ibmstream unformatted ss{&vssseq} skip.
    end.
    else do:
      put stream ibmstream unformatted
      substitute("select &1 from &2 where &3"
                            ,temp-tekka-tsk.obj-name
                            ,substitute("&1:&2:&3:&4"
                                        ,temp-tekka-tsk.port-num /*"COM1"*/
                                        ,temp-tekka-tsk.way
                                        ,temp-tekka-tsk.cash-num-char
                                        ,temp-tekka-tsk.pswd)
                            ,temp-tekka-tsk.other-info)
      skip.
      delete temp-tekka-tsk.
    end.
  end.
  output stream IBmSTREAM  close.
end.
else do:
  output stream IBmSTREAM to VALUE(out + fname + '.tsk').
  for each temp-tekka-tsk:
    if temp-tekka-tsk.send-get = 'task' then do:
      /*сотрем чтобы не попало в место предназначеннное для всех temp-tekka-tsk - его подключим позже*/
        put stream ibmstream unformatted
        substitute("select &1 from &2 where &3"
                              ,temp-tekka-tsk.obj-name
                              ,substitute("&1:&2:&3:&4"
                                          ,temp-tekka-tsk.port-num /*"COM1"*/
                                          ,temp-tekka-tsk.way
                                          ,temp-tekka-tsk.cash-num-char
                                          ,temp-tekka-tsk.pswd)
                              ,temp-tekka-tsk.other-info)
        skip.
        delete temp-tekka-tsk.
    end. /*if temp-tekka-tsk.send-get = 'task' then do:*/
  end. /*for each */
  output stream IBMStream close.
end.
os-rename
VALUE(out + fname + '.tsk')
value(trim(trim(v-remote, {&slash-char}), {&back-slash-char}) + 'tasks')
.
&endif

/*пишем файл в TASKS*/
find first temp-tekka-tsk no-error.
if available temp-tekka-tsk then do:
   v-found{&vssseq} = yes.
end.


if v-found{&vssseq} = yes then do:


/*пишем файл в TASKS*/
output stream IBmSTREAM to VALUE(out + fname + '.tsk').
v-is-script{&vssseq} = no.
for each temp-tekka-tsk:
  if (temp-tekka-tsk.num-rec > 0
  or temp-tekka-tsk.send-get = 'task')
  and temp-tekka-tsk.task-num = fname then do:
    export stream IBmSTREAM temp-tekka-tsk.
    v-found{&vssseq} = yes.
  end.
  if temp-tekka-tsk.is-script then do:
    v-is-script{&vssseq} = yes.
  end.
  delete temp-tekka-tsk.
end.
output stream IBMStream
close.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файлы &1(..),&2файл задания &3"
                        , (out + fname)
                        , {&new-line}
                        , (out + fname + '.tsk')
                        )
                                       ).


run str/runtekka.p (
                     input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input out /*директория где лежат файлы bat*/
                    ,input out /*директория где лежат файлы объектов*/
                    ,input fname
                    ,input v-remote /*директория работы с Addin.exe*/
                    ,input v-is-script{&vssseq}
                    ) no-error .

/*error-status:error = no.*/
if error-status:error then do:
  for each temp-tekka-tsk:
    os-delete value( temp-tekka-tsk.filename) .
    delete temp-tekka-tsk.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Прерван обмен информацией с кассой &1,&2&3&2на кассе осталась устаревшая информация"
                           ,{&cd-buffer}.cash-num
                           ,{&new-line}
                           ,return-value
                        )
                                        ).
  assign
  v-view-log = yes
  .
  &if "{&subject}" = "good"  &then
    for each temp-cd-plu:
      delete temp-cd-plu.
    end.
  &endif
  &if "{&subject}" = "dis-card"  &then
    for each temp-cd-clu:
      delete temp-cd-clu.
    end.
  &endif
  return "error":U.
end.
else do:
  &if "{&subject}" = "good"  &then
  for each temp-cd-plu,
      first buf_cd-plu where
                  buf_cd-plu.obj-type = temp-cd-plu.obj-type
              and buf_cd-plu.obj-code = temp-cd-plu.obj-code
              and buf_cd-plu.pos-type = temp-cd-plu.pos-type
              and buf_cd-plu.plu-type = temp-cd-plu.plu-type
              and buf_cd-plu.plu-code = temp-cd-plu.plu-code:
    if temp-cd-plu.to-del = yes
    and v-del-mrkt-gds
    then do:
      if lookup(string({&cd-buffer}.cash-num), buf_cd-plu.charkey_one) > 0 then do:
        entry(lookup(string({&cd-buffer}.cash-num), buf_cd-plu.charkey_one)  ,  buf_cd-plu.charkey_one) = '':U.
        assign
        buf_cd-plu.charkey_one = replace(buf_cd-plu.charkey_one, {&comma-char} + {&comma-char}, {&comma-char})
        buf_cd-plu.to-del = (buf_cd-plu.charkey_one <> '':U)
        .
      end.
      if buf_cd-plu.charkey_one = '':U then do:
        delete buf_cd-plu.
        NEXT.
      end.
    end.
    if temp-cd-plu.charkey_two = "":U
    then
    assign
    buf_cd-plu.charkey_two = "":U
    buf_cd-plu.to-send = no
    .
    delete temp-cd-plu.
  end.
  &Endif
  &if "{&subject}" = "dis-card"  &then
  for each temp-cd-clu,
      first buf_cd-clu where
            buf_cd-clu.obj-type = temp-cd-clu.obj-type
       and  buf_cd-clu.obj-code = temp-cd-clu.obj-code
       and  buf_cd-clu.pos-type = temp-cd-clu.pos-type
       and  buf_cd-clu.clu-type = '':U
            :
    if temp-cd-clu.to-del <> yes
    and v-del-mrkt-cli
    then do:
      if lookup(string({&cd-buffer}.cash-num), buf_cd-clu.charkey_one) > 0 then do:
        entry(lookup(string({&cd-buffer}.cash-num), buf_cd-clu.charkey_one)  ,  buf_cd-clu.charkey_one) = '':U.
        assign
        buf_cd-clu.charkey_one = replace(buf_cd-clu.charkey_one, {&comma-char} + {&comma-char}, {&comma-char})
        .
      end.
      if buf_cd-clu.charkey_one = '':U then do:
        delete buf_cd-clu.
        NEXT.
      end.
    end.
    if temp-cd-clu.charkey_two = "":U
    then
    assign
    buf_cd-clu.charkey_two = "":U
    buf_cd-clu.to-send = no
    .
    delete temp-cd-clu.
  end.
  &Endif

end.
end. /*if v-found{&vssseq} = yes then do:*/
&if "{&subject}" = "good"  &then
run cd-mrkt_update-marketer in this-procedure (
                                                input {&cd-buffer}.db-num
                                                ,input {&cd-buffer}.obj-code
                                                ,input {&cd-buffer}.pos-type
                                                ,input {&cd-buffer}.cash-num
                                                ,input no
                                              )  .
&endif
&if "{&subject}" = "dis-card"  &then
run cd-mrkt_update-marketer-cli in this-procedure (
                                                input {&cd-buffer}.db-num
                                                ,input {&cd-buffer}.obj-code
                                                ,input {&cd-buffer}.pos-type
                                                ,input {&cd-buffer}.cash-num
                                              )  .
&endif


/* $Workfile$ e n d */