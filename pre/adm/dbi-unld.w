define input param mode as char no-undo.
define input-output param  ri as recid no-undo init ?.
define output parameter p-unload-history as logical no-undo .
define output parameter p-db-dst as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование БД".
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
    assign
      p-vss-parameters = substitute('&1',mode)
    .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
Function reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure check-enc.
  define input  parameter p-db-num    as integer   no-undo .
  define input  parameter p-db-key    as character no-undo .
  define input  parameter p-code      as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-beg-date  as date      no-undo .
  define input  parameter p-end-date  as date      no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  if p-db-num <> 0
    and p-db-key = "":U
  then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-db-key = "unload-db":U then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-code = ""  then do:
    assign
      tmp = string( p-db-num ) + reverse (p-db-key).
    .
  end.
  else do:
    assign
      tmp = string( p-db-num )
            + trim( p-db-key )
            + reverse( trim( p-code ) )
            + reverse( trim( p-value ) )
            + reverse( string( p-beg-date, "99.99.9999" ) )
            + reverse( string( p-end-date, "99.99.9999" ) )
    .
  end.
  run pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
procedure save-db-key :
  define input parameter p-db-key like ub.db.db-key no-undo .
  do
  on error undo, return error
  :
    define buffer buf_rep for ub.rep .
    find buf_rep
      where buf_rep.rep-num = 1996011200
      no-error
    .
    if not available buf_rep then do:
      create buf_rep.
      assign
        buf_rep.rep-num = 1996011200
      .
    end.
    if lookup( p-db-key, buf_rep.name1 ) = 0 then do:
      assign
        buf_rep.name1 = buf_rep.name1 + ",":U + p-db-key
      .
    end.
  end.
end procedure.
procedure del-db-key :
  define input parameter p-db-key like ub.db.db-key no-undo .
  do
  on error undo, return error
  :
    define buffer buf_rep for ub.rep .
    define buffer buf_db  for ub.db .
    find first buf_db
      where buf_db.db-key = p-db-key
      no-error
    .
    if not available buf_db then do:
      find first buf_rep
        where buf_rep.rep-num = 1996011200
        no-error
      .
      if available buf_rep
        and lookup( p-db-key, buf_rep.name1 ) <> 0
      then do:
        assign
          buf_rep.name1 = diff-list( buf_rep.name1, p-db-key, ",":U )
        .
      end.
    end.
  end.
end procedure.
procedure chk-db-key :
  define input  parameter p-db-num     like ub.db.db-num     no-undo.
  define input  parameter p-db-key     like ub.db.db-key     no-undo.
  define input  parameter p-db-key-enc like ub.db.db-key-enc no-undo.
  define output parameter p-result     as   integer          no-undo .
  do
  on error undo, return error
  :
    define buffer buf_rep for ub.rep .
    define buffer buf_db  for ub.db .
    define variable v-ok as logical no-undo .
    if p-db-key = ?
      or p-db-key = ""
    then do:
      assign
        p-result = 1
      .
      return string("Не задано значение ключа БД.").
    end.
    if p-db-key-enc = ?
      or p-db-key-enc = ""
    then do:
      assign
        p-result = 2
      .
      return string("Не задано кодированное значение ключа БД.").
    end.
    find buf_rep
      where buf_rep.rep-num = 1996011200
      no-error
    .
    if not available buf_rep then do:
      create buf_rep.
      assign
        buf_rep.rep-num = 1996011200
      .
    end.
    for each buf_db no-lock
    on error undo, return error
    :
      if lookup( buf_db.db-key, buf_rep.name1 ) = 0 then do:
        assign
          buf_rep.name1 = buf_rep.name1 + ",":U + buf_db.db-key
        .
      end.
    end.
    assign
      p-result = 0
    .
    if lookup( p-db-key, buf_rep.name1 ) <> 0 then do:
      assign
        p-result = 1
      .
      return string("Данное значение ключа БД уже существует.").
    end.
    run check-enc in this-procedure
      ( input p-db-num
       ,input p-db-key
       ,input ""
       ,input ""
       ,input ?
       ,input ?
       ,input p-db-key-enc
       ,output v-ok
      ) no-error.
    if error-status:error then do:
      assign
        p-result = 1
      .
      return substitute( "Ошибка при проверке правильности кодирования. &1", error-status:get-message (1) ) .
    end.
    if v-ok <> true then do:
      assign
        p-result = 2
      .
      return string("Неверное кодированное значение ключа БД.").
    end.
  end.
end procedure.
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "&Ввод ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE VARIABLE f-days AS CHARACTER FORMAT "X(256)":U INITIAL "дней"
      VIEW-AS TEXT
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE f-if AS CHARACTER FORMAT "X(256)":U INITIAL "Условия переформирования пакетов:"
      VIEW-AS TEXT
     SIZE 34.5 BY .67 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 68 BY 2.25.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 68 BY 1.5.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 68 BY 4.75.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 68 BY 3.5.
DEFINE VARIABLE t-save-packs AS LOGICAL INITIAL no
     LABEL "Удалять файлы пакетов СПН из каталога heap"
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE t-unload-history AS LOGICAL INITIAL yes
     LABEL "Выгружать историю"
     VIEW-AS TOGGLE-BOX
     SIZE 64 BY .83
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE v-db-dst AS CHARACTER FORMAT "X(256)":U
     LABEL "Целевая БД"
     VIEW-AS FILL-IN
     SIZE 30.88 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 68 BY 3.1.
DEFINE FRAME dbi
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 67
     ub.db.db-num AT ROW 2.67 COL 10.63 COLON-ALIGNED
          FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     ub.db.db-key AT ROW 2.67 COL 30.5 COLON-ALIGNED
          LABEL "Ключ БД" FORMAT "X(12)"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     ub.db.db-key-enc AT ROW 2.67 COL  55 COLON-ALIGNED
          LABEL "Кодировка" FORMAT "X(16)"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     ub.db.db-name AT ROW 3.88 COL 10.63 COLON-ALIGNED FORMAT "X(40)"
          VIEW-AS FILL-IN
          SIZE 57.38 BY 1
     ub.db.add-clients AT ROW 5.75 COL 3
          VIEW-AS TOGGLE-BOX
          SIZE 22.5 BY .83 TOOLTIP "Возможность добавления клиентов"
     ub.db.remote-stock AT ROW 5.75 COL 27 HELP
          ""
          VIEW-AS TOGGLE-BOX
          SIZE 16.5 BY .83 TOOLTIP "Отправка чужих остатков"
     ub.db.send-check AT ROW 5.75 COL 50.5 HELP
          ""
          LABEL "Пересылать чеки"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY .83 TOOLTIP "ОТправлять чеки из БД в ГБД"
     ub.db.add-goods AT ROW 6.75 COL 3
          VIEW-AS TOGGLE-BOX
          SIZE 22.13 BY .83 TOOLTIP "Возможность добавлять товары"
     ub.db.on-line-rest AT ROW 6.75 COL 27 WIDGET-ID 2
          VIEW-AS TOGGLE-BOX
          SIZE 22 BY .83
     t-save-packs AT ROW 8 COL 3 WIDGET-ID 8
     ub.db.save-packs AT ROW 8 COL 53.5 COLON-ALIGNED HELP
          "" WIDGET-ID 6
          LABEL "через"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     ub.db.max-p-size AT ROW 9.5 COL 51 COLON-ALIGNED
          LABEL "Максимальное кол-во записей в пакете"
          VIEW-AS FILL-IN
          SIZE 14.38 BY 1
     ub.db.max-p-queue AT ROW 11.5 COL 51 COLON-ALIGNED
          LABEL "Кол-во неподтвержденных пакетов больше"
          VIEW-AS FILL-IN
          SIZE 6.25 BY 1
     ub.db.max-p-time AT ROW 12.75 COL 51 COLON-ALIGNED HELP
          ""
          LABEL "Время ожидания подтверждения больше (мин)" FORMAT ">>>>>9"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     ub.db.unload-arch AT ROW 14.25 COL 3
          LABEL "Выгружать складские архивы по товарам и по поставщикам"
          VIEW-AS TOGGLE-BOX
          SIZE 64 BY .83
          FGCOLOR 12
     ub.db.unload-aht AT ROW 15.25 COL 3
          LABEL "Выгружать складской архив по типам приобретения"
          VIEW-AS TOGGLE-BOX
          SIZE 64 BY .83
          FGCOLOR 12
     t-unload-history AT ROW 16.25 COL 3 WIDGET-ID 4
     f-days AT ROW 8 COL 59.5 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     f-if AT ROW 10.75 COL 2.5 NO-LABEL
     RECT-2 AT ROW 7.75 COL 2
     RECT-4 AT ROW 14 COL 2
     RECT-1 AT ROW 5.5 COL 2
     RECT-3 AT ROW 9.25 COL 2 WIDGET-ID 12
     RECT-5 at row 17.75 col 2
     "Целевая база данных" VIEW-AS TEXT
          SIZE 21.38 BY .75 AT ROW 18 COL 3
     v-db-dst AT ROW 19.5 COL 14.5 COLON-ALIGNED
     SPACE(0.74) SKIP(0.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "БД":L
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME dbi:SCROLLABLE       = FALSE.
ASSIGN
       f-days:HIDDEN IN FRAME dbi           = TRUE
       f-days:READ-ONLY IN FRAME dbi        = TRUE.
ASSIGN
       f-if:HIDDEN IN FRAME dbi           = TRUE
       f-if:READ-ONLY IN FRAME dbi        = TRUE.
ASSIGN
       ub.db.max-p-queue:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       ub.db.max-p-size:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       ub.db.max-p-time:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       ub.db.on-line-rest:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       RECT-2:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       RECT-3:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       RECT-4:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       ub.db.remote-stock:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       ub.db.save-packs:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       ub.db.send-check:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       t-save-packs:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       t-unload-history:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       ub.db.unload-aht:HIDDEN IN FRAME dbi           = TRUE.
ASSIGN
       ub.db.unload-arch:HIDDEN IN FRAME dbi           = TRUE.
ON CHOOSE OF b-exit IN FRAME dbi
DO:
  define variable ret-val as integer no-undo .
  define variable v-db-attr-del as logical   no-undo .
  define buffer buf1_db     for ub.db .
  define buffer buf_clients for ub.clients .
  define buffer buf_gds-obj for ub.gds-obj .
  if mode = "add":U then do:
    if input frame dbi ub.db.db-num = ? then do:
      message "Введите номер БД."
              view-as alert-box error.
      apply "ENTRY" to ub.db.db-num.
      return no-apply.
    end.
    if can-find (buf1_db where buf1_db.db-num = input frame dbi ub.db.db-num no-lock ) then do:
      message "БД с таким номером уже есть."
              view-as alert-box error.
      apply "ENTRY" to ub.db.db-num.
      undo, return no-apply.
    end.
  end.
  if ub.db.db-num :sensitive in frame dbi = true then do:
    assign
      ub.db.db-num
    .
  end.
  if ub.db.db-key :sensitive in frame dbi = true then do:
    if mode = "unld":U
      or ( mode <> "unld":U
           and trim( ub.db.db-key ) <> "":U
         )
    then do:
      run chk-db-key
        ( input ( input frame dbi ub.db.db-num )
        ,input ( input frame dbi ub.db.db-key )
        ,input ( input frame dbi ub.db.db-key-enc )
        ,output ret-val
        ).
      if ret-val <> 0 then do:
        message return-value
                view-as alert-box error.
        if ret-val = 1 then do:
          apply "ENTRY" to ub.db.db-key.
        end.
        else do:
          apply "ENTRY" to ub.db.db-key-enc.
        end.
        undo, return no-apply.
      end.
      assign
        ub.db.db-key
        ub.db.db-key-enc
        .
    end.
  end.
  if input frame dbi ub.db.db-name = "" then do:
    message "Название БД не может быть пустым."
            view-as alert-box error.
    apply "ENTRY" to ub.db.db-name.
    undo, return no-apply.
  end.
  if ub.db.on-line-rest = true
    and input frame dbi ub.db.on-line-rest = false
  then do:
    for each buf_clients no-lock
      where buf_clients.db-num = ub.db.db-num
      ,each buf_gds-obj
      where buf_gds-obj.obj-type = buf_clients.obj-type
        and buf_gds-obj.obj-code = buf_clients.obj-code
    on error undo, return no-apply
    :
      assign
        buf_gds-obj.on-line-rest = ?
      .
    end.
  end.
  assign
    ub.db.db-name
    ub.db.add-clients
    ub.db.add-goods
    ub.db.on-line-rest
    ub.db.remote-stock
    ub.db.max-p-queue
    ub.db.max-p-time
    ub.db.max-p-size
    ub.db.db-key
    ub.db.db-key-enc
    ub.db.send-check
    ub.db.unload-arch
    ub.db.unload-aht
    t-save-packs
    t-unload-history when mode = "unld"
    v-db-dst when mode = "unld"
    ri = recid (ub.db)
    p-unload-history = t-unload-history
    p-db-dst = v-db-dst
  .
  if trim( ub.db.db-key ) <> "":U then do:
    run save-db-key( ub.db.db-key ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Невозможно сохранить ключ базы." ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      undo, return no-apply.
    end.
  end.
  if p-db-dst = "":U and mode = "unld" then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Нeобходимо указать параметры соединения с целевой базой!" ) skip
      view-as alert-box error
    .
    apply "entry" to v-db-dst in frame dbi .
    return no-apply.
  end.
  if t-save-packs :sensitive in frame dbi = true then do:
    if t-save-packs = true then do:
      assign
        ub.db.save-packs
      .
    end.
    else do:
      assign
        ub.db.save-packs = ?
      .
    end.
  end.
END.
ON CHOOSE OF b-quit IN FRAME dbi
DO:
  if mode = "add":U then do:
    delete ub.db.
  end.
  if mode <> "lkp":U then do:
    assign
      ri = ?
    .
  end.
END.
ON LEAVE OF ub.db.save-packs IN FRAME dbi
DO:
  assign
    ub.db.save-packs
  .
  if ub.db.save-packs < 10 then do:
    message
      substitute( "Удалять пакеты раньше чем через 10 дней нельзя!" )
      view-as alert-box.
    assign
      ub.db.save-packs = 10
    .
  end.
END.
ON VALUE-CHANGED OF t-save-packs IN FRAME dbi
DO:
  assign
    t-save-packs
  .
  if t-save-packs = true then do:
    if ub.db.save-packs = ?
      or ub.db.save-packs < 10
    then do:
      assign
        ub.db.save-packs = 10
      .
    end.
    enable
      ub.db.save-packs
      with frame dbi
      .
    display
      ub.db.save-packs
      f-days
      with frame dbi
      .
  end.
  else do:
    hide
      ub.db.save-packs
      f-days
      in frame dbi
      .
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME dbi:PARENT eq ?
THEN FRAME dbi:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME dbi APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame dbi
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame dbi
do:
  apply "help":u to frame dbi .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame dbi:width - 0.3
                fh            = frame dbi:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
  define variable ret-val as integer no-undo .
  define variable v-db-attr-value as character no-undo .
  define variable v-db-attr-type  as character no-undo .
  if mode <> "add":U then do:
    if mode = "lkp":U then do:
      find ub.db no-lock
        where recid (ub.db) = ri
        no-error
      .
    end.
    else do:
      find ub.db exclusive-lock
        where recid (ub.db) = ri
        no-error
      .
    end.
    if not available ub.db then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "БД &1 удалена." ) skip
        view-as alert-box information
      .
      return error .
    end.
  end.
  case mode:
    when "add":U then do:
      create ub.db.
      frame dbi:title = "Добавление БД".
      assign
        ub.db.db-key      = "":U
        ub.db.db-key-enc  = "":U
        ub.db.max-p-size  = 10000
        ub.db.max-p-time  = 20
        ub.db.max-p-queue = 10
      .
    end.
    when "unld":U then do:
      frame dbi:title = "Выгрузка БД".
      if trim( ub.db.db-key ) <> "":U
        and trim( ub.db.db-key-enc ) <> "":U
      then do:
        run chk-db-key ( input ub.db.db-num
                        ,input ub.db.db-key
                        ,input ub.db.db-key-enc
                        ,output ret-val
                       ).
      end.
      assign
        ub.db.db-key     = "":U
        ub.db.db-key-enc = "":U
      .
    end.
    when "upd":U then do:
      frame dbi:title = "Изменение БД".
    end.
    when "lkp":U then do:
      frame dbi:title = "Просмотр БД".
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Не предусмотрена операция &1", mode ) skip
        view-as alert-box error
      .
      return error .
    end.
  end case.
  session:data-entry-return = yes .
  if ub.db.db-num = 0 then do:
    assign
      frame dbi :height-chars = 8.5
    .
  end.
  RUN enable_UI.
  if ub.db.db-num <> 0 then do:
    enable
      ub.db.on-line-rest
      ub.db.send-check
      ub.db.remote-stock
      ub.db.max-p-queue
      ub.db.max-p-time
      ub.db.max-p-size
      ub.db.unload-arch
      ub.db.unload-aht
      t-save-packs
      RECT-2
      RECT-3
      RECT-4
      f-if
      WITH FRAME dbi
    .
    display
      ub.db.on-line-rest
      ub.db.send-check
      ub.db.remote-stock
      ub.db.max-p-queue
      ub.db.max-p-time
      ub.db.max-p-size
      ub.db.unload-arch
      ub.db.unload-aht
      t-save-packs
      f-if
      WITH FRAME dbi
    .
    if ub.db.save-packs <> ? then do:
      assign
        t-save-packs = true
      .
    end.
    else do:
      assign
        t-save-packs = false
      .
    end.
    display
      t-save-packs
      with frame dbi
    .
    apply "VALUE-CHANGED" to t-save-packs in frame dbi .
  end.
  case mode:
    when "add":U then do:
      ENABLE ub.db.db-num WITH FRAME dbi.
    end.
    when "unld":U then do:
      ENABLE ub.db.db-key ub.db.db-key-enc t-unload-history v-db-dst WITH FRAME dbi.
      display
        t-unload-history
        v-db-dst
        with frame dbi .
    end.
    when "upd":U then do:
      if trim( ub.db.db-key ) = "":U
        or trim( ub.db.db-key ) = ?
      then do:
        ENABLE ub.db.db-key ub.db.db-key-enc WITH FRAME dbi.
      end.
    end.
    when "lkp":U then do:
      disable all WITH FRAME dbi.
      ENABLE b-quit b-help WITH FRAME dbi.
    end.
  end case.
  WAIT-FOR GO OF FRAME dbi.
END.
RUN disable_UI.
session:data-entry-return = no .
PROCEDURE disable_UI :
  HIDE FRAME dbi.
END PROCEDURE.
PROCEDURE enable_UI :
  IF AVAILABLE ub.db THEN
    DISPLAY ub.db.db-num ub.db.db-key ub.db.db-key-enc ub.db.db-name
          ub.db.add-clients ub.db.add-goods
      WITH FRAME dbi.
  ENABLE b-exit b-quit b-help RECT-1 ub.db.db-name ub.db.add-clients
         ub.db.add-goods
      WITH FRAME dbi.
END PROCEDURE.
