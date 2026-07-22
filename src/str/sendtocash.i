&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
define variable mObj-code  as integer   no-undo. /**/
define variable mObj-type  as character no-undo. /**/
define variable mPostType  as character no-undo. /* доступные типы касс */
define variable action    as character no-undo.
define variable mTitle     as character no-undo. /*  */
define variable mTitle-add as character no-undo. /* текст при action = "U" */
define variable mTitle-del as character no-undo. /* текст при action = "D" */
define variable mListrec as character no-undo init ?.

&if defined (subject) eq 0
&then
&scop subject gas-station
&endif

&if defined (data-by) eq 0
&then
&scop data-by object
&endif


/*Виды обрабатываемых касс*/
&glob cdt-ibm-xml yes

/* для включения типа необходио объявить препроцессор yes
&glob cdt-IBM no
&glob cdt-OMRON no
&glob cdt-OMRON-NEW no
&glob cdt-IPC-SERVISPL no
&glob cdt-pricecheck-Servispl no
&glob cdt-NCR-GM no
&glob cdt-NCR-AS-R no
&glob cdt-r-keeper no
&glob cdt-maria no
*/

{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ str/cdsnddef.i }
{ bge/bgelib.i }
{ str/cd-xml.i }


procedure   for-cash-cycle:

define input  parameter i-obj-code as integer   no-undo.
define input  parameter iPostType  as character no-undo.
define input  parameter iAction    as character no-undo.


define variable fname-list as character no-undo .
define variable out-list as character no-undo .
define variable var-file-num as integer no-undo .
define variable v-dir-remote as character no-undo .
define variable v-dir-remote-tmp as character no-undo .
define variable v-plu as character no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-temp-kat-file as character no-undo .
define variable v-kat-file as character no-undo .
define variable v-kat-file-save as character no-undo .
define variable v-updated-subject-dis-kat as logical no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .
define variable v-versiond as decimal no-undo .
define variable vText as character no-undo.

define buffer for-cash-desk for ub.cash-desk.

_for:
for each for-cash-desk no-lock where
        for-cash-desk.db-num = g#db-num and
        for-cash-desk.pos-type = iPostType and
        for-cash-desk.obj-code = i-obj-code and
        for-cash-desk.cash-on  = yes
    break
    by for-cash-desk.db-num
    by for-cash-desk.obj-code
    by for-cash-desk.pos-type
    by for-cash-desk.cash-on
    :
  if mListrec ne ?
     and not can-do (mListrec,string(recid(for-cash-desk)))
  then
     next.
  if lookup(for-cash-desk.pos-type,
            ({&cd-type-NCR-GM} + {&comma-char} +
             {&cd-type-IBM-XML} + {&comma-char} +
             {&cd-type-MAGIA-XML} + {&comma-char} +
             {&cd-type-NCR-AS-R} + {&comma-char}
               )) > 0
  and for-cash-desk.autonomy = integer({&cd-slave}) then next.
  
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
  
  vtext = substitute( "Начата '&2' ", (if iAction = "U" then mTitle-add else mTitle-del)).
  { str/outc-gen.i
  &cd-buffer=for-cash-desk
  &subject={&subject}
  &out-title="vtext"
  &data-by={&data-by}
  
  }
  /*сформируем вывод для кассы определенного типа*/
  run putc-obj in this-procedure
               ( input for-cash-desk.pos-type
                ,input for-cash-desk.version
                ,input for-cash-desk.cash-os
                ,input for-cash-desk.cash-num
                ,input iAction eq "U":U /*удалить весь справочник*/
                ).
  vtext = substitute( "Завершено '&2' ", (if iAction = "U" then mTitle-add else mTitle-del)).
  { str/cloc-gen.i
  &cd-buffer=for-cash-desk
  &subject={&subject}
  &out-title-add="vtext"
  &out-title-del="vtext"
  &data-by={&data-by}
  }
  
  
  
  


end . /*for each for-cash-desk*/
end procedure. /*for-cash-cycle*/

procedure SENDING:
   define input  parameter i-obj-code as integer no-undo.
   define input  parameter iAction    as character no-undo.
_cash-desk:
for each ub.cash-desk  where ub.cash-desk.db-num   = g#db-num 
                         and ub.cash-desk.obj-code = i-obj-code 
                         and ub.cash-desk.cash-on
no-lock
break
by ub.cash-desk.pos-type :

  /*выполним действия, разнящиеся для разных типов касс -
  разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  if first-of(ub.cash-desk.pos-type) then do:

    { str/cdg-gen.i
    &cd-buffer=ub.cash-desk
    &subject={&subject}
    &data-by={&data-by}
    }
    /*пройдем цикл по всем кассам одного типа*/
    run for-cash-cycle (i-obj-code,ub.cash-desk.pos-type,iAction) no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 &2", error-status:get-message(1), return-value)
                                              ).
      assign
      v-view-log = yes
      .
    end.
  end. /*IF FIRST-OF(ub.cash-desk.pos-type*/

  /*выполним действия, разнящиеся для разных типов касс - подчистки, сообщения и т.д.*/
  if last-of(ub.cash-desk.pos-type) then do:
    { str/cds-gen.i
    &cd-buffer=ub.cash-desk
    &subject={&subject}
    &data-by={&data-by}
    &out-title="mtitle"
    &out-title-add="mtitle-add"
    &out-title-del="mtitle-del"
    }
  end.
end. /*FOR EACH cash-desk*/

end procedure. /*SENDING*/

&else


find first ub.cash-desk where ub.cash-desk.db-num    = g#db-num 
                          and ub.cash-desk.obj-code  = mObj-code
                          and can-do(mPostType,ub.cash-desk.pos-type)
no-lock no-error.                         
            
if not avail(cash-desk) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!&1  реализуется только для касс  &2 "
                          , (if action = "U" then mTitle-add else mTitle-del)
                          , mPostType
                          
                        )
                                        ).
  return.
end.
run SENDING (mObj-code,action) no-error.

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при '&1' на кассы &2&3"
                         ,mTitle, mObj-type, mObj-code
                        )
                                        ).
end.

  finally :
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    os-append value(log-file-name) value(v-save-file-name).
    os-delete value(log-file-name).
  end finally .


&endif