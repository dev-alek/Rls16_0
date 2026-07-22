block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по версиям RC на УБД.

Автор: Белоусов Илья Александрович
Дата создания: 11/22/07
Author: Ilia Belousov
Creation date: 11/22/07

*/
define input parameter parparentproc  as widget-handle no-undo .
define input parameter p-date_from    as date          no-undo.
define input parameter p-date_to      as date          no-undo .
define input parameter p-db-list      as character     no-undo.
define input parameter p-log          as logical       no-undo .


define variable vss-revision          as character no-undo init "$Revision$":U .
define variable vss-author            as character no-undo init "$Author$":U .
define variable vss-date              as character no-undo init "$Date$":U .
define variable vss-workfile          as character no-undo init "$Workfile$":U .
define variable vss-archive           as character no-undo init "$Archive$":U .
define variable vss-description       as character no-undo init "Отчет по версиям RC на УБД.".

define variable v-report-name-html    as CHARACTER no-undo .
define variable v-report-name-html-RC as CHARACTER no-undo .

define variable v-file-date           as character no-undo .
define variable v-file-time           as character no-undo .
define variable v-today               as date      no-undo.
define variable v-time                as integer   no-undo.
define variable p-report-id           as integer   no-undo .

define stream out-stream.
define stream OutStr-html.

define variable ii         as integer   no-undo.
define variable jj         as integer   no-undo.
define variable v-menedger as character no-undo.
define variable v-name     as character no-undo.
 
define buffer buf_db            for ub.db .
define buffer buf_upgrade       for ub.upgrade .
define buffer buf_upgrade-attr  for ub.upgrade-attr .
define buffer buf_person        for ub.person .
define buffer buf_user-account  for ub.user-account .
define buffer buf_code          for ub.code .

define buffer buf_rvs-line-attr for ub.rvs-line-attr .
define temp-table temp_db-list no-undo
  field db-num as integer
  index pi is primary unique db-num
  .
  
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/showinf.i    }
{ rep/fmtcli.i     }
/*{ cmp/r-page1.i    }*/
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ gbl/cur-time.i   }
{ gbl/getcntxt.i def }

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end



&global-define frame-width  188

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-infodb-date d-db 
FUNCTION get-infodb-date RETURNS Character
  ( INPUT p-db-num as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-time d-db 
FUNCTION get-time RETURNS Character
  ( INPUT p-time as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-infodb-ver d-db
FUNCTION get-infodb-ver RETURNS character 
  ( INPUT p-db-num as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

define variable v-rep-list as character no-undo.


DEFINE STREAM out-stream.

define buffer buf_clients for ub.clients .

/*************************************************
  MAIN-BLOCK

**************************************************/
do
  on error  undo , return error return-value
  on endkey undo , return error return-value
  on stop   undo , return error return-value
  :
  run get-report-num in parParentProc (
    output p-report-id
    ).

    run cur-time in this-procedure ( output v-today
    , output v-time
    ).
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

  ii = 0 .
  
define variable v-date_from as character no-undo .
define variable v-date_to   as character no-undo .

  if string(entry(3,string(p-date_from),"/")) >= "90" then v-date_from = "19" + string(entry(3,string(p-date_from),"/")) + "_" + string(entry(2,string(p-date_from),"/")) + "_" + string(entry(1,string(p-date_from),"/")) .
  else v-date_from = "20" + string(entry(3,string(p-date_from),"/")) + "_" + string(entry(2,string(p-date_from),"/")) + "_" + string(entry(1,string(p-date_from),"/")) .
  if string(entry(3,string(p-date_to),"/")) >= "90" then v-date_to = "19" + string(entry(3,string(p-date_to),"/")) + "_" + string(entry(2,string(p-date_to),"/")) + "_" + string(entry(1,string(p-date_to),"/")) .
  else v-date_to = "20" + string(entry(3,string(p-date_to),"/")) + "_" + string(entry(2,string(p-date_to),"/")) + "_" + string(entry(1,string(p-date_to),"/")) .
  find first ub.db no-lock no-error .
  v-report-name-html = session:temp-directory + "VERRC_" + string(substring (ub.db.db-key,1,4)) + "_TH_16_0_" + string(v-today,"99.99.99") + "_" +  replace (string(time,"HH:MM:SS"),":","") + ".html".
  
  /*вызов процедуры печати шапки отчета*/      
  output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
  put stream OutStr-html unformatted
    { rep/htmlhead.i }
    .
                        
                        
  put stream OutStr-html unformatted
    '<body>' skip
    /*Первая таблица*/
    '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD colspan="12" style="font-weight: bold;">Отчет по версиям RC на БД</TD>' skip 
    '</TR>' skip
    '<TR>' skip
    '<TD colspan="12" style="font-weight: bold;">Дата: ' + string (v-today,"99.99.9999") + '</TD>' skip  
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="12" style="font-weight: bold;">Время: ' + get-time(v-time) + '</TD>' skip        
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="12" style="font-weight: bold;">Фильтры: с ' + string (p-date_from,"99.99.9999") + " по " + string(p-date_to,"99.99.9999") + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="12" style="font-weight: bold;">БД: ' + if p-db-list = "" then "Все" + '</TD>' else string(p-db-list) + '</TD>' skip
    '</TR>'skip
    .
  put stream OutStr-html unformatted            
    '</thead>' skip
    '<tbody>' skip
    .
        
        
  put stream OutStr-html unformatted
    '<tr>' skip
    '<th text_wrap="true" style="align: center;">№</th>' skip
    '<th text_wrap="true" style="align: center;">Номер БД</th>' skip
    '<th text_wrap="true" style="align: center;">Наименование БД</th>' skip
    '<th text_wrap="true" style="align: center;">Ключ БД</th>' skip
    '<th text_wrap="true" style="align: center;">Дата актуальности информации о БД и RC</th>' skip
    '<th text_wrap="true" style="align: center;">Версия структуры БД</th>' skip
    '<th text_wrap="true" style="align: center;">Индентификатор версии RC</th>' skip
    '<th text_wrap="true" style="align: center;">Дата и время компиляции RC</th>' skip
    '<th text_wrap="true" style="align: center;">Дата и время копирования индентификатора версии RC на ПК</th>' skip
    '<th text_wrap="true" style="align: center;">Дата и время записи данных о версии в БД</th>' skip
    '<th text_wrap="true" style="align: center;">Дата и время версии конфигурации типов маркировки</th>' skip
    '<th text_wrap="true" style="align: center;">Имя пользователя</th>' skip
    '</tr>' skip
    .
  if p-db-list = "" then 
  do:
    empty temp-table temp_db-list .
    if v-cntxt-db-num = 0 then 
    do: 
      for each ub.db no-lock:
        create temp_db-list .
        temp_db-list.db-num = ub.db.db-num .
      end.  
    end.
    else 
    do:
      for each ub.db no-lock where ub.db.db-num = v-cntxt-db-num:
        create temp_db-list .
        temp_db-list.db-num = ub.db.db-num .
      end.  
    end.  
  end.  
  else 
  do:
    empty temp-table temp_db-list .
    do jj = 1 to num-entries (p-db-list,{&comma-char}):
      create temp_db-list .
      temp_db-list.db-num = integer(entry (jj,p-db-list, {&comma-char})) .
    end.
  end.    

  for each temp_db-list,
    last buf_db no-lock where buf_db.db-num = temp_db-list.db-num by buf_db.db-num :
    _next:
    for each buf_upgrade where buf_upgrade.db-num = buf_db.db-num and entry(1,buf_upgrade.version-num," ") >= v-date_from and entry(1,buf_upgrade.version-num," ") <= v-date_to
    and (lookup ("Rel",buf_upgrade.version-num," ") > 0 or buf_upgrade.version-num = "v16_0000.000.000")
    by buf_upgrade.UpgDate desc by buf_upgrade.UpgTime desc:
/*    for each buf_upgrade where buf_upgrade.db-num = buf_db.db-num and buf_upgrade.UpgDate >= p-date_from and buf_upgrade.UpgDate <= p-date_to*/
/*    and (lookup ("Patch",buf_upgrade.version-num," ") > 0 or buf_upgrade.version-num = "v16_0000.000.000")                                   */
/*    by buf_upgrade.UpgDate desc by buf_upgrade.UpgTime desc:                                                                                 */
      ii = ii + 1 .
  
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td style="align: center;">' + string(ii) + '</td>' skip
        '<td text_wrap="true" style="align: center;">' + string(buf_db.db-num) + '</td>' skip
        '<td text_wrap="true" style="align: center;">' + string(buf_db.db-name) + '</td>' skip
        '<td text_wrap="true" style="align: center;">' + string(buf_db.db-key) + '</td>' skip
        '<td text_wrap="true" style="align: center;">' + string(get-infodb-date(buf_db.db-num) ) + '</td>' skip
        '<td text_wrap="true" style="align: center;">' + string(buf_db.reserve1-char) + '</td>' skip
        '<td text_wrap="true" style="align: center;">' + string(entry(1,buf_upgrade.version-num,{&delim-par})) + '</td>' skip
        .
      find first buf_upgrade-attr no-lock where 
        buf_upgrade-attr.db-num = buf_upgrade.db-num and 
        buf_upgrade-attr.version-num = buf_upgrade.version-num and
        buf_upgrade-attr.attr-code = "compile-date" no-error .
       
      put stream OutStr-html unformatted
        '<td text_wrap="true" style="align: center;">' + if available (buf_upgrade-attr) and string(buf_upgrade-attr.attr-value) <> ? then string(buf_upgrade-attr.attr-value) + '</td>' else " " + '</td>' skip
        .
      v-file-date = "" .
      v-file-time = "" .
      v-menedger = "" .
      for first buf_upgrade-attr no-lock where 
        buf_upgrade-attr.db-num = buf_upgrade.db-num and 
        buf_upgrade-attr.version-num = buf_upgrade.version-num and
        buf_upgrade-attr.attr-code = "file-date" :
        v-file-date = buf_upgrade-attr.attr-value .
      end.  
      for first buf_upgrade-attr no-lock where 
        buf_upgrade-attr.db-num = buf_upgrade.db-num and 
        buf_upgrade-attr.version-num = buf_upgrade.version-num and
        buf_upgrade-attr.attr-code = "file-time" :
        v-file-time = get-time(integer(buf_upgrade-attr.attr-value)) .
      end.         
      put stream OutStr-html unformatted
        '<td text_wrap="true" style="align: center;">' + if v-file-date = "" or v-file-time = "" then "" + '</td>' else string(v-file-date) + "_" + string (v-file-time) + '</td>' skip
        .
      put stream OutStr-html unformatted
        '<td text_wrap="true" style="align: center;">' + string(buf_upgrade.UpgDate) + "_" + string(buf_upgrade.UpgTime) + '</td>' skip  .
      
      find first buf_code where
                 buf_code.parent = substitute("Versions&1&2",{&delim-par},buf_db.db-num)
             and buf_code.code = "MarkType"
           no-lock no-error.
      put stream OutStr-html unformatted        
        '<td text_wrap="true" style="align: center;">' if avail buf_code then buf_code.codevalue else '' '</td>' skip.
        
      for first buf_upgrade-attr no-lock where 
        buf_upgrade-attr.db-num = buf_upgrade.db-num and 
        buf_upgrade-attr.version-num = buf_upgrade.version-num and
        buf_upgrade-attr.attr-code = "user" ,
        first ub.user-login no-lock where ub.user-login.db-num = buf_upgrade.db-num
        and ub.user-login.user-login = buf_upgrade-attr.attr-value,
        first buf_user-account no-lock where buf_user-account.user-id = ub.user-login.user-id: 
        v-menedger = buf_user-account.last-name + '  ' + buf_user-account.first-name + ' ':U + buf_user-account.second-name.
       end.
        put stream OutStr-html unformatted        
          '<td text_wrap="true" style="align: center;">' + string(v-menedger) + '</td>' skip.
         put stream OutStr-html unformatted                  '</tr>' skip.
        leave _next .
      
    end.  
  end.
  put stream OutStr-html unformatted
    '</tbody>' skip  
    '</table>' skip
    .

  put stream OutStr-html unformatted
        
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.   
end.

if p-log then do:
  /* вызов программы печати */ 
  run prn-lib-reportviewer-report-name in this-procedure (
    input parParentProc
    ,input v-report-name-html
    ).
end.
else do:
  define variable v-report-name       as character no-undo .
  define variable v-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
  do:
    v-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
  end.
  else
  do:
    message "Не найдена программа просмотра отчёта!" view-as alert-box error.
  end.

  os-command no-wait value(v-fill-path-RepView + " false " + v-report-name-html).
end.  


  


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-infodb-date d-db 
FUNCTION get-infodb-date RETURNS character
  ( INPUT p-db-num as integer) :
  DEFINE BUFFER buf_db-info FOR ub.db-info.
  find last buf_db-info no-lock where
    buf_db-info.db-num = p-db-num use-index  pi no-error.
  IF AVAILABLE buf_db-info  THEN RETURN string(buf_db-info.date-info).
  RETURN "".   /* Function return value. */

END FUNCTION.


FUNCTION get-time RETURNS character
  ( INPUT p-time as integer) :
  define variable v-time_ as character no-undo .

  v-time_ = string(truncate (p-time / 3600, 0)) + ":" + string((p-time modulo 3600) / 60,"99") .
  RETURN v-time_.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-infodb-ver d-db
FUNCTION get-infodb-ver RETURNS character 
  ( INPUT p-db-num as integer) :
  DEFINE BUFFER upgrade FOR upgrade.
  block-step:
  for each upgrade where upgrade.db-num   eq p-db-num
    no-lock by upgrade.db-num descending 
    by upgrade.step-num descending :
    leave block-step.        
  end.
   
  return if available upgrade then  entry(1,upgrade.version-num,{&delim-par}) else "?".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-report-num Dialog-Frame
PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME