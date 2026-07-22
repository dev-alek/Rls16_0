block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-in_ as character no-undo .
define input parameter p-spl as character no-undo .
define input parameter p-sav   as character no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo init yes.
define variable vss-revision    as character no-undo init "$Revision: 75002dd41ced, 247, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Sep 08 15:20:05 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-rkpf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-rkpf.p $":U .
define variable vss-description as character no-undo init "Сканирование файлов с касс r-keeper по директории".
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
define variable path as char no-undo.
define variable atr as char no-undo.
define variable file as char no-undo.
define variable adr as char no-undo.
def stream DirStream .
define variable in_ as char no-undo.
define variable spl as char no-undo.
define variable sav as char no-undo.
define variable out as char no-undo.
define variable out2 as character no-undo .
define variable v-remote as char no-undo.
define variable v-dir-remote as character no-undo .
define variable v-dir-remote-tmp as character no-undo .
define variable yestr as character no-undo .
define variable kass-list as char no-undo.
define variable cycle as logical no-undo.
def buffer for-cash-desk for ub.cash-desk.
define variable jj as int no-undo.
define variable v-lock-global as logical no-undo.
def frame a
path format "x(30)"
with view-as dialog-box side-labels
size 50 by 4.17 three-d title "Обработка файла ...".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-categ no-undo
field  SIFR  as integer         column-label "Идентификатор"
field  NAME  as character       column-label "Название"
field  is-DEL  as logical       column-label "удаленная / действующая"
index pi is unique primary
sifr.
define NEW SHARED temp-table temp-menu no-undo
field   SIFR          as integer       column-label "Идентификатор"
field   NAME          as character     column-label "Название"
field   CODE-chr      as character     column-label "Код"
field   TREETYPE      as character     column-label "Тип записи"
field   CATEG         as integer       column-label "Идентификатор категории"
field   PRICE         as decimal       column-label "Цена блюда"
field   PARENT        as integer       column-label "Идентификатор группы"
field   DEL           as logical       column-label "удаленное / действующee"
field   bar-code-chr  as character     column-label "штрих-код"
field   lvl-num       as integer
index pi is unique primary
SIFR
index itype
treetype
.
define NEW SHARED temp-table temp-modify no-undo
field   SIFR       as integer      column-label "Идентификатор"
field   NAME       as character    column-label "Название"
field   REALPRICE  as decimal      column-label "Не используется"
field   DEL        as logical      column-label "удаленный / действующий"
field   parent     as integer      column-label "код группы"
index pi is unique primary
SIFR.
define NEW SHARED temp-table temp-money no-undo
field   SIFR       as integer    column-label "Идентификатор"
field   NAME       as character  column-label "Название"
field   CODE-str   as character  column-label "код"
field   KURS       as decimal    column-label "курс"
field   PARENT     as integer    column-label "Идентификатор группы"
field   DEL        as logical    column-label "удаленная / действующая"
field   TIP        as integer    column-label "Тип платежа/валюты"
field   TREE       as logical    column-label "Тип записи"
index pi is unique primary
sifr.
define NEW SHARED temp-table temp-Personal no-undo
field   SIFR     as integer   column-label "Идентификатор"
field   NAME     as character column-label "имя"
field   CODE-str as character column-label  "код"
field   TYPE     as character column-label "тип"
field   DEL      as logical   column-label " удаленный / действующий"
index pi is unique primary
sifr.
define NEW SHARED temp-table temp-Reasons no-undo
field  SIFR     as integer    column-label "Идентификатор"
field  NAME     as character  column-label "название"
field  USED     as logical    column-label "применять списание"
field  DEL      as logical    column-label "удаленная / действующая"
index pi is unique primary
sifr.
define NEW SHARED temp-table temp-Charges   no-undo
field  SIFR     as integer    column-label "Идентификатор"
field  NAME     as character  column-label "Название"
field  DEL      as logical    column-label "удаленная / действующая"
index pi is unique primary
sifr.
define NEW SHARED temp-table temp-Avcheck no-undo
field  LOGICDATE as date  column-label "Кассовая дата"
field  REALDATE  as date  column-label "Физическая дата"
field  f_TIME      as character   column-label "Физическое время"
field  SIFR      as integer     column-label "Идентификатор"
field  COMP      as integer     column-label "Тип строчки"
field  QNT       as decimal     column-label "количество"
field  PRICE     as decimal      column-label "цена"
field  REASON    as integer    column-label "причина удаления"
field  MANAGER   as integer    column-label "Идентификатор менеджера"
field  WAITER    as integer    column-label "Идентификатор официанта"
field  TABLE_     as character  column-label "стол"
field  UNIT      as character  column-label "станция"
field  DEPART    as character  column-label "группа станций"
field  sys_num   as integer    column-label "ссылка на номер чека которую мы сами прописали"
field  del-time   as decimal
field  line-num   as integer
index pi is primary
sifr
index ifind
depart
unit
logicdate
del-time
index isys_num
sys_num
index iline-num
sys_num
line-num
.
define NEW SHARED temp-table temp-Acheck no-undo
field  SYS_NUM     as integer column-label  "Идентификатор чека"
field  CNUM        as integer column-label "Номер чека"
field  LOGICDATE   as date column-label "кассовая дата закрытия чека"
field  REALDATE    as date column-label "физическая дата закрытия чека"
field  OPENTIME    as character column-label "время открытия заказа"
field  CLOSETIME   as character column-label "время закрытия заказа"
field  COVER       as integer column-label "кол-во гостей"
field  CASHIER     as integer column-label "Идентификатор кассира"
field  WAITER      as integer column-label "Идентификатор официанта"
field  UNIT        as character column-label "станция"
field  DEPART      as character column-label "группа станций"
field  TOTAL       as decimal column-label "сумма чека без всех скидок/наценок в базовой валюте"
field  BASEKURS    as decimal column-label "курс базовой валюты"
field  DELETED     as integer
field  MANAGER     as integer column-label "Идентификатор менеджера"
field  CHARGE      as decimal column-label "Не используется"
field  TABLE_      as integer column-label "стол"
field  OPENDATE    as date    column-label "Кассовая дата открытия заказа"
field  NACKURS     as decimal column-label "курс национальной валюты"
field  TAXSUM      as decimal column-label "сумма налога с продаж в базовой валюте"
field  TAXRATE     as decimal column-label "отношение налог с продаж/(сумма чека+налог)"
field  DOP1        as decimal column-label "Не используется"
field  DOP2        as integer column-label "Не используется"
field  DOP3        as decimal column-label "Не используется"
field  DOP4        as decimal column-label "Не используется"
field  start-time   as decimal
field  end-time     as decimal
index pi is unique primary
sys_num
index ifind
depart
unit
logicdate
start-time
end-time
.
define NEW SHARED temp-table temp-Adcheck no-undo
field  SYS_NUM      as integer column-label "Идентификатор чека"
field  CNUM         as integer column-label "Номер чека"
field  SIFR         as integer column-label "Идентификатор скидки (наценки)"
field  SUM          as decimal column-label "сумма скидки (отрицательная) или наценки (положительная)"
field  CARDCOD      as integer column-label "Не используется"
field  PERSON       as integer column-label "0-автоматическая; иначе - Идентификатор применившего скидку"
 field  dop1  as decimal column-label "?????????????????"
field  line-num   as integer
index pi is primary
sys_num
index iline-num
sys_num
line-num
.
define NEW SHARED temp-table temp-Apcheck no-undo
field  SYS_NUM       as integer    column-label "Идентификатор чека"
field  CNUM          as integer    column-label "Номер чека"
field  CURRENCY      as integer    column-label "Идентификатор валюты"
field  BASESUMEQW    as decimal    column-label "сумма в базовой валюте, включающая скидку на валюту"
field  ORIGSUM       as decimal    column-label "сумма в валюте CURRENCY, не включающая скидку на валюту"
field  KURS          as decimal    column-label "курс валюты CURRENCY"
field  DISCOUNT      as decimal    column-label "скидка"
field  EXTRA         as character  column-label "Не используется"
field  DOP1          as decimal    column-label "Не используется"
field  DOP2          as decimal    column-label "Не используется"
field  DOP3          as logical
field  line-num   as integer
index pi is primary
sys_num currency
index iline-num
sys_num
line-num
.
define NEW SHARED temp-table temp-Archeck  no-undo
field  SYS_NUM      as integer     column-label "Идентификатор чека"
field  CNUM         as integer     column-label "Номер чека"
field  SIFR         as integer     column-label "Идентификатор блюда или модификатора"
field  QNT          as decimal     column-label "количество порций"
field  PRICE        as decimal     column-label "цена по меню"
field  COMPONENT    as logical     column-label "'T'-модификатор; 'F'-блюдо"
field  PAYSUM       as decimal     column-label  "Сумма"
field  DOP1         as decimal     column-label "Не используется"
field  NALOG        as decimal     column-label "налог с продаж в долях"
field  CONSUMANT    as logical     column-label "Консумант"
field  PAYPRICE     as decimal     column-label "цена нетто "
field  line-num   as integer
index pi is primary
sys_num sifr
index iline-num
sys_num
line-num
.
define NEW SHARED temp-table temp-control  no-undo
field  FILE_        as character column-label "название файла"
field  RECORDS      as integer   column-label "количество записей"
field  RESTSIFR     as integer   column-label "Идентификатор ресторана"
field  RESTNAME     as character column-label "Название ресторана"
field  STARTDATE    as date      column-label "Начальная кассовая дата экспортируемой информации"
field  STOPDATE     as date      column-label "Конечная кассовая дата экспортируемой информации"
index pi is unique primary
file_.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref3 as character no-undo .
define variable varpgscales-pref3 as character no-undo .
define variable varscales-pref-type3 as character no-undo.
define variable varpgscales-pref-type3 as character no-undo.
varscales-pref3  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref3
  ,output varscales-pref-type3
  ) no-error .
  if varscales-pref3 = ? then do:
    assign
      varscales-pref3 = '21,23,25':U.
  end.
varpgscales-pref3  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref3
  ,output varpgscales-pref-type3
  ) no-error .
  if varpgscales-pref3 = ? then do:
    assign
      varpgscales-pref3 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
  end.
procedure get-rkep-full-grp-name :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER p-grp-code LIKE ub.cd-grp.grp-code NO-UNDO.
define output parameter p-full-name as character    no-undo.
define variable v-upper-code    as integer  no-undo.
define buffer buf_cd-grp       for ub.cd-grp.
define buffer buf_upper_cd-grp for ub.cd-grp.
do
on error undo, return error
:
    if P-grp-code = 0
    then do:
        assign
            p-full-name = ""
        .
    end.
    else do:
        find first buf_cd-grp no-lock where
               buf_cd-grp.obj-type = 'маг':U
           and buf_cd-grp.obj-code = p-obj-code
           and buf_cd-grp.pos-type = 'r-keeper':U
           and buf_cd-grp.grp-type = '':U
           and buf_cd-grp.grp-code = p-grp-code
        no-error.
        if not available buf_cd-grp
        then do:
            undo, return error substitute("get-rkep-grp-name: Не найдена группа меню на кассе R-KEEPER с кодом &1", p-grp-code).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 0
        .
        do while true
        on error undo, return error "get-rkep-grp-name: Ошибка составления полного имени группы"
        :
            assign
            p-full-name  = buf_cd-grp.grp-name
                        + (if p-full-name <> "" then chr(47) else "")
                        + p-full-name
            v-upper-code = buf_cd-grp.upper-grp-code
            .
            if buf_cd-grp.grp-code = 0
            then do:
                leave.
            end.
            find first buf_cd-grp no-lock where
                      buf_cd-grp.obj-type = 'маг':U
                  and buf_cd-grp.obj-code = p-obj-code
                  and buf_cd-grp.pos-type = 'r-keeper':U
                  and buf_cd-grp.grp-type = '':U
                  and buf_cd-grp.grp-code = v-upper-code no-error.
            if not available buf_cd-grp
            then do:
                undo, return error "get-rkep-grp-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-id".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
        .
    end.
end.
end procedure.
function get-price-id-from-int returns character ( input p-file-num as integer):
  return ('price-list':U + chr(32) +  string(p-file-num)).
end function.
DEFINE VARIABLE v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-need-save               as logical                  no-undo .
define variable v-command-string1         as character                no-undo .
define variable v-command-string2         as character                no-undo .
define variable path-d                    as character                no-undo .
define variable path-a                    as character                no-undo .
define variable v-dbf-files               as logical                  no-undo  extent 13.
define variable v-chk-files               as logical                  no-undo  extent 7.
define variable v-not-get-all             as logical                  no-undo .
define variable v-not-get-files           as character                no-undo .
define variable v-result                  as character                no-undo .
define variable ii                        as integer                  no-undo .
define variable v-seq-num                 as integer                  no-undo .
define variable file-no-ext               as character                no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_cd-doc for ub.cd-doc.
define temp-table temp-string no-undo
field f_string as character
field f_id     as integer
index pi
is unique primary
f_id
.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Проверка необходимости ПОВТОРНОЙ ОБРАБОТКИ чеков, которые не удалось разобрать ранее..."
                      )
                                  ).
find last buf_cd-doc exclusive-lock where
         buf_cd-doc.obj-type = p-obj-type
     and buf_cd-doc.obj-code = p-obj-code
     and buf_cd-doc.pos-type = 'r-keeper':U
     and buf_cd-doc.doc-type = '' no-wait no-error.
if not available buf_cd-doc
and not locked(buf_cd-doc) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "НЕТ ранее неразобранных нуждающихся в ПОВТОРНОЙ ОБРАБОТКЕ чеков&1" +
                          "можно импортировать более поздние данные....."
                          , chr(10)
                        )
                                    ).
end.
else do:
  if buf_cd-doc.charkey_one <> "":U then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Есть неразобранные ранее нуждающиеся в ПОВТОРНОЙ ОБРАБОТКЕ чеки&1" +
                            "дата и время первоначальной загрузки &2 &3&1&1"
                            , chr(10)
                            , string(buf_cd-doc.datekey_one, "99/99/9999")
                            , string(buf_cd-doc.key#_one, "hh:mm:ss")
                          )
                                      ).
    do ii = 1 to num-entries("control,menu,reasons,acheck,adcheck,apcheck,archeck,avcheck":U):
      assign
      path = p-sav + "/" + entry(ii, "control,menu,reasons,acheck,adcheck,apcheck,archeck,avcheck":U) + "_" + buf_cd-doc.doc-code + ".d"
      file-no-ext = entry(ii, "control,menu,reasons,acheck,adcheck,apcheck,archeck,avcheck":U)
      .
      run gbl/filename.p (
                    input path
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!При ПОВТОРНОЙ ОБРАБОТКЕ ранее неразобранных чеков при чтении файла &1 произошла ошибка при получении полного пути файлу: &2"
                                , path
                                , return-value
                              )
                                          ).
        assign
        p-view-log = yes
        .
        input stream DirStream close.
        return.
      end.
      run str/get-rkep.p (
                    input parparentproc
                    ,input p-log-handle
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input p-host-code
                    ,input p-pos-type
                    ,input path
                    ,input file-no-ext
                    ,input - integer(buf_cd-doc.doc-code)
                    ,input-output p-view-log
                    ) no-error .
    end.
    run str/get-rkep.p (
                  input parparentproc
                  ,input p-log-handle
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input p-host-code
                  ,input p-pos-type
                  ,input "":U
                  ,input file-no-ext
                  ,input - integer(buf_cd-doc.doc-code)
                  ,input-output p-view-log
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!При обработке файла &1 произошла ошибка:&2&3 &4"
                              , path
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                            )
                                        ).
      assign
      p-view-log = yes
      .
    end.
  find last buf_cd-doc exclusive-lock where
          buf_cd-doc.obj-type = p-obj-type
      and buf_cd-doc.obj-code = p-obj-code
      and buf_cd-doc.pos-type = 'r-keeper':U
      and buf_cd-doc.doc-type = '':U no-wait no-error.
    if not available buf_cd-doc
    and not locked buf_cd-doc then.
    else do:
      if buf_cd-doc.charkey_one <> "":U then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Не удалось ПОЛНОСТЬЮ ПОВТОРНО ОБРАБОТАТЬ ранее неразобранные чеки:&1" +
                                "дата и время первоначальной загрузки &2 &3&1&1" +
                                "дальнейшее чтение чеков с касс невозможно&1&1" +
                                "!!!!!!!!ИЗ ДИРЕКТОРИИ &4 ЗАПРЕЩЕНО УДАЛЯТЬ ФАЙЛЫ С СУФФИКСОМ &5,&1" +
                                "ОНИ БУДУТ ИСПОЛЬЗОВАНЫ ДЛЯ ПОВТОРНОЙ ОБРАБОТКИ ЧЕКОВ!!!!!!!!!!"
                                , chr(10)
                                , string(buf_cd-doc.datekey_one, "99/99/9999")
                                , string(buf_cd-doc.key#_one, "hh:mm:ss")
                                , p-sav
                                , buf_cd-doc.doc-code
                              )
                                          ).
        assign
        p-view-log = yes
        .
        return .
      end.
    end.
  end.
  else do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "НЕТ ранее неразобранных нуждающихся в ПОВТОРНОЙ ОБРАБОТКЕ чеков&1" +
                            "можно импортировать более поздние данные....."
                            , chr(10)
                          )
                                      ).
  end.
end.
assign
v-not-get-all = no
v-not-get-files = "":u
.
for each temp-ACHECK:
  delete temp-acheck.
end.
for each temp-AdCHECK:
  delete temp-adcheck.
end.
for each temp-ApCHECK:
  delete temp-apcheck.
end.
for each temp-ArCHECK:
  delete temp-archeck.
end.
for each temp-AvCHECK:
  delete temp-avcheck.
end.
for each temp-categ:
  delete temp-categ.
end.
for each temp-charges:
  delete temp-charges.
end.
for each temp-control:
  delete temp-control.
end.
for each temp-menu:
  delete temp-menu.
end.
for each temp-modify:
  delete temp-modify.
end.
for each temp-money:
  delete temp-money.
end.
for each temp-personal:
  delete temp-personal.
end.
for each temp-reasons:
  delete temp-reasons.
end.
if search(p-in_ + p-spl + chr(47) + "finish.mrk") = ? then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Отсутствует сигнальный файл finish.mrk в директории &1:&2чтение чеков невозможно"
                          , (p-in_ + p-spl)
                          , chr(10)
                        )
                                    ).
  assign
  p-view-log = yes
  .
  return .
end.
input stream DirStream from os-dir ( p-in_ + p-spl ) .
REPEAT :
  import stream DirStream file path atr.
  if length(file) > 4
  AND ( substring( file, length(file) - 3, 4 ) = ".dbf" )
  AND can-do( "f", atr )
  AND lookup(substring( file, 1, length(file) - 4 ), "control,menu,modify,money,personal,reasons,charges,acheck,adcheck,apcheck,archeck,avcheck":U) > 0
  then do:
    if v-seq-num = 0 then
    assign
    v-seq-num  = next-value(s-file-num-2, ub)
    path-a     = p-in_ + p-spl + "/" + "_" + string(v-seq-num) + ".d"
    .
    assign
    path-d = path
    file-no-ext = file
    substring(file-no-ext, length(file) - 3, 4) = "":U
    substring( path-d, length(path-d) - 3, 4 ) = ".d"
    v-command-string1 = "dbf.exe":U + chr(32)  + "1" + chr(32)  +
                        "1"   + chr(32) +
                          path
    v-command-string2 = " > "
    .
    run syn-dbf in this-procedure (
                                    INPUT v-command-string1
                                    ,INPUT v-command-string2
                                    ,input path-d
                                    ,input substitute("Конвертация файла &1 из .dbf формата в .d формат":U
                                                      , path)
                                    ) no-error .
    if error-status:error then do:
      assign
      v-result = ?.
    end.
    else v-result = "":U.
    find first temp-string no-lock no-error .
    if not available temp-string
    or trim(trim(temp-string.f_string), chr(34)) <> "Data Conversion Complete":U
    or v-result = ?
    then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!При конвертации файла &1 из формата .dbf в формат .d произошла ошибка:&2&3 &4"
                              , path
                              , chr(10)
                              , (if error-status:error
                                  then error-status:get-message(1)
                                  else "":U)
                              , (if error-status:error
                                  then return-value
                                  else temp-string.f_string)
                            )
                                        ).
      assign
      p-view-log = yes
      .
      if v-result <> ? then do:
        for each temp-string no-lock where
                temp-string.f_id > 1 :
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input temp-string.f_string
                                            ).
        end.
      end.
    end.
    else do:
      assign
      v-dbf-files[lookup(file-no-ext, "control,menu,modify,money,personal,reasons,charges,acheck,adcheck,apcheck,archeck,avcheck":U)] = yes
      no-error
      .
    end.
    run gbl/filename.p (
                  input path
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!При обработке файла &1 произошла ошибка при получении полного пути файлу: &2"
                              , path
                              , return-value
                            )
                                        ).
      assign
      p-view-log = yes
      .
      input stream DirStream close.
      return.
    end.
    run str/get-rkep.p (
                  input parparentproc
                  ,input p-log-handle
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input p-host-code
                  ,input p-pos-type
                  ,input path-d
                  ,input file-no-ext
                  ,input v-seq-num
                  ,input-output p-view-log
                  ) no-error .
    os-copy
    value( path )
    value( p-sav + "/" + v-file-name-no-ext + "_" + string(v-seq-num) +  ".dbf" ) .
    if os-error > 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "Ошибка при копировании файла &1 в директорию архива &2"
                              , path, p-sav
                            )
                                        ).
      assign
      p-view-log = yes
      .
    end.
    else do:
        os-delete value( path ) .
    end.
    os-copy
    value( path-d )
    value( p-sav + "/" + v-file-name-no-ext + "_" + string(v-seq-num) +  ".d" ) .
    if os-error > 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "Ошибка при копировании файла &1 в директорию архива &2"
                              , path-d
                              , p-sav
                            )
                                        ).
      assign
      p-view-log = yes
      .
    end.
    else do:
        os-delete value( path-d ) .
    end.
  end.
END .
input stream DirStream close.
OS-DELETE value(p-in_ + p-spl + chr(47) + "finish.mrk").
do ii = 1 to num-entries("control,menu,modify,money,personal,reasons,charges,acheck,adcheck,apcheck,archeck,avcheck":U):
  if v-dbf-files[ii] = no then do:
    assign
    v-not-get-all = yes
    v-not-get-files = v-not-get-files +
                      (if v-not-get-files = "":u then "":U else chr(10) ) +
                       entry(ii, "control,menu,modify,money,personal,reasons,charges,acheck,adcheck,apcheck,archeck,avcheck":U) + ".dbf"
    .
  end.
end.
if v-not-get-all then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файлов .dbf с кассы &1 в директории &2&3НЕ БЫЛИ ПОЛУЧЕНЫ НЕОБХОДИМЫЕ ФАЙЛЫ:&3&4"
                          , 'r-keeper':U
                          , (p-in_ + p-spl)
                          , chr(10)
                          ,  v-not-get-files
                           )
                                    ).
  assign
  p-view-log = yes
  .
  return .
end.
find first buf_cd-doc exclusive-lock where
        buf_cd-doc.obj-type = p-obj-type
    and buf_cd-doc.obj-code = p-obj-code
    and buf_cd-doc.pos-type = 'r-keeper':U
    and buf_cd-doc.doc-type = '':U
    and buf_cd-doc.doc-code = string(v-seq-num) no-error.
 run cur-time in this-procedure(output v-today, output v-time).
if not available buf_cd-doc then do:
  create
  buf_cd-doc.
  assign
  buf_cd-doc.obj-type = p-obj-type
  buf_cd-doc.obj-code = p-obj-code
  buf_cd-doc.pos-type = 'r-keeper':U
  buf_cd-doc.doc-type = '':U
  buf_cd-doc.doc-code = string(v-seq-num)
  buf_cd-doc.datekey_one  = v-today
  buf_cd-doc.key#_one  = v-time
  buf_cd-doc.charkey_one   = "":U
  no-error
  .
  release buf_cd-doc.
end.
run str/get-rkep.p (
              input parparentproc
              ,input p-log-handle
              ,input p-obj-type
              ,input p-obj-code
              ,input p-host-code
              ,input p-pos-type
              ,input "":U
              ,input file-no-ext
              ,input v-seq-num
              ,input-output p-view-log
              ) no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка:&2&3 &4"
                          , path
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                        )
                                    ).
  assign
  p-view-log = yes
  .
end.
procedure syn-dbf :
DEFINE INPUT PARAMETER Cmd AS CHAR No-UNDO.
DEFINE INPUT PARAMETER Cmd2 AS CHAR No-UNDO.
define input parameter path-d as character no-undo .
DEFINE INPUT PARAMETER mess AS CHAR NO-UNDO.
define variable  err-file as character no-undo .
define variable ii as integer no-undo .
do
on error undo, return error
:
  define variable bat-file as character no-undo.
  define variable out-file as character no-undo .
  run gbl/_tmpfile.p ("", "bat", output bat-file) .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess                        ).
  assign
  err-file = bat-file
  substring( err-file, length(err-file) - 3, 4 ) = ".err"
  out-file = bat-file
  substring( out-file, length(out-file) - 3, 4 ) = ".d"
  .
  OS-DELETE value(err-file).
  OS-DELETE value(out-file).
  output to value(bat-file).
  cmd2 = cmd2 + substitute("&1", out-file).
  PUT  UNFORMATTED
  cmd chr(32)
  err-file chr(32)
  cmd2 SKIP.
  output close.
  OS-COMMAND silent value(bat-file).
  define variable v-time-count as integer no-undo .
  define variable v-err-file-found as logical no-undo .
  REPEAT WHILE v-time-count < 300 :
    assign
      v-time-count = v-time-count + 1
    .
    pause 1 no-message .
    assign
      FILE-INFO :FILE-NAME = err-file
    .
    IF INDEX(FILE-INFO:FILE-TYPE, "F")  > 0 then  do:
      input from value(err-file).
      for each temp-string:
        delete temp-string.
      end.
      REPEAT :
        ii = ii + 1.
        create temp-string.
        assign
        temp-string.f_id = ii .
        import unformatted temp-string.f_string no-error .
      end.
      input close.
      assign
        v-err-file-found = true
      .
      leave .
    end.
  END.
  if v-err-file-found <> true then do:
    OS-DELETE value(bat-file).
    OS-DELETE value(out-file).
    OS-DELETE value(err-file).
    return error substitute(vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
                            "Не найден файл с результатом выполнения задания &1 &2 &3"
                            , cmd
                            , err-file
                            , cmd2
                            ).
  end.
  OS-DELETE value(bat-file).
  OS-DELETE value(err-file).
  OS-RENAME value(out-file) value(path-d).
  if os-error > 0 then do:
    OS-DELETE value(out-file).
    return error substitute(vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
                            "Не удалось переименовать файл  конвертации из &1 в &2"
                            , out-file
                            , path-d
                            ).
  end.
end.
end procedure.
