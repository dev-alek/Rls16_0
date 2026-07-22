define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение дисконтных карт по списку-запуск".
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
define new shared temp-table dc-list no-undo like ub.dis-card
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
define  new shared  temp-table dc-list-hist no-undo
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable defltdc as char no-undo.
define variable deflt-d-pcnt like ub.dis-card.d-pcnt no-undo.
define variable cards as char no-undo.
define variable DCARDMODE as char no-undo init "".
define variable cli-str as char no-undo.
define variable where-phrase as char no-undo.
define variable dc-pfx as character no-undo.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lst
     LABEL "&Список"
     SIZE 10 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-shop
     IMAGE-UP FILE "adeicon\y-combo":U
     LABEL "Btn 6"
     SIZE 4.3 BY 1.
DEFINE BUTTON B-type
     IMAGE-UP FILE "adeicon\y-combo":U
     LABEL "Btn 6"
     SIZE 4.3 BY 1.
DEFINE VARIABLE cash-d-pcnt AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE category AS INTEGER FORMAT ">9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE cli-message AS CHARACTER FORMAT "X(256)":U INITIAL "0"
     VIEW-AS FILL-IN
     SIZE 52 BY 1 NO-UNDO.
DEFINE VARIABLE d-pcnt AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE dc-type AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 12.8 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE emitent-host-code AS INTEGER FORMAT "99999" INITIAL 0
     LABEL "Код фирмы эмитента"
      VIEW-AS TEXT
     SIZE 7.4 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE issue-code AS INTEGER FORMAT "99999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.4 BY 1 NO-UNDO.
DEFINE VARIABLE issue-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.
DEFINE VARIABLE lim-kr AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.9 BY 1 NO-UNDO.
DEFINE VARIABLE n-cash-d-pcnt AS CHARACTER FORMAT "X(256)":U INITIAL "% скидки на итог:"
      VIEW-AS TEXT
     SIZE 18.1 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-category AS CHARACTER FORMAT "X(256)":U INITIAL "категория:"
      VIEW-AS TEXT
     SIZE 10 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-cli-message AS CHARACTER FORMAT "X(256)":U INITIAL "Сообщ. для клиента"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-credit-card AS CHARACTER FORMAT "X(256)":U INITIAL "Кредитная карта"
      VIEW-AS TEXT
     SIZE 16.1 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-d-pcnt AS CHARACTER FORMAT "X(256)":U INITIAL "% скидки на товар:"
      VIEW-AS TEXT
     SIZE 17.9 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-d-pcnt-method AS CHARACTER FORMAT "X(256)":U INITIAL "Метод исп скидки"
      VIEW-AS TEXT
     SIZE 17.9 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-dc-status AS CHARACTER FORMAT "X(256)":U INITIAL "Статус карты"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-dc-type AS CHARACTER FORMAT "X(256)":U INITIAL "Тип карты:"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-debet-card AS CHARACTER FORMAT "X(256)":U INITIAL "Кредитная карта"
      VIEW-AS TEXT
     SIZE 16.1 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-issue-code AS CHARACTER FORMAT "X(256)":U INITIAL "Выдал магазин"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-issue-date AS CHARACTER FORMAT "X(256)":U INITIAL "Дата выдачи:"
      VIEW-AS TEXT
     SIZE 12.4 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-lim-kr AS CHARACTER FORMAT "X(256)":U INITIAL "Лимит кредита"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-staff-card AS CHARACTER FORMAT "X(256)":U INITIAL "Кредитная карта"
      VIEW-AS TEXT
     SIZE 16.1 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-valid-date AS CHARACTER FORMAT "X(256)":U INITIAL "По:"
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-valid-from AS CHARACTER FORMAT "X(256)":U INITIAL "Действительна c:"
      VIEW-AS TEXT
     SIZE 16 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE valid-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.
DEFINE VARIABLE valid-from AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.
DEFINE IMAGE l-cash-d-pcnt
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-category
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-cli-message
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-credit-card
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-d-pcnt
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-d-pcnt-method
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-dc-status
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-dc-type
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-debet-card
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-issue-code
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-issue-date
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-lim-kr
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-staff-card
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-valid-date
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-valid-from
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE VARIABLE d-pcnt-method AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 41.1 BY .93 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.5 BY 3.63.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.5 BY 2.8.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.5 BY 3.27.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.6 BY 2.87.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.6 BY 2.87.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.5 BY 1.43.
DEFINE VARIABLE dc-status AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "1"
     SIZE 13.9 BY 2.03 NO-UNDO.
DEFINE VARIABLE credit-card AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE debet-card AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE staff-card AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      ub.dis-card SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-lst AT ROW 1 COL 21
     B-Help AT ROW 1 COL 81
     B-type AT ROW 2.57 COL 36.1
     cash-d-pcnt AT ROW 5.67 COL 57.1 COLON-ALIGNED NO-LABEL
     category AT ROW 5.67 COL 80.1 COLON-ALIGNED NO-LABEL
     d-pcnt AT ROW 5.77 COL 25.1 COLON-ALIGNED NO-LABEL
     d-pcnt-method AT ROW 6.97 COL 25.1 NO-LABEL
     valid-date AT ROW 8.47 COL 77.5 COLON-ALIGNED NO-LABEL
     issue-date AT ROW 8.67 COL 19.3 COLON-ALIGNED NO-LABEL
     valid-from AT ROW 8.67 COL 52.5 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     issue-code AT ROW 10.43 COL 21.1 COLON-ALIGNED NO-LABEL
     B-shop AT ROW 10.47 COL 30.3
     debet-card AT ROW 12.5 COL 32
     staff-card AT ROW 12.5 COL 57.5
     credit-card AT ROW 12.63 COL 7
     lim-kr AT ROW 14 COL 20.5 COLON-ALIGNED NO-LABEL
     dc-status AT ROW 15.77 COL 24.5 NO-LABEL
     cli-message AT ROW 18.27 COL 24.5 COLON-ALIGNED NO-LABEL
     n-dc-type AT ROW 2.53 COL 5.1 COLON-ALIGNED NO-LABEL
     dc-type AT ROW 2.57 COL 20.8 COLON-ALIGNED NO-LABEL
     emitent-host-code AT ROW 4 COL 21.5 COLON-ALIGNED
     n-cash-d-pcnt AT ROW 5.63 COL 40.3 NO-LABEL
     n-category AT ROW 5.63 COL 70.3 NO-LABEL
     n-d-pcnt AT ROW 5.7 COL 6.9 NO-LABEL
     n-d-pcnt-method AT ROW 6.83 COL 7 NO-LABEL
     n-valid-date AT ROW 8.47 COL 75 NO-LABEL
     n-valid-from AT ROW 8.67 COL 38 NO-LABEL WIDGET-ID 4
     n-issue-date AT ROW 8.7 COL 7.8 NO-LABEL
     n-issue-code AT ROW 10.53 COL 5 COLON-ALIGNED NO-LABEL
     n-debet-card AT ROW 12.5 COL 36 NO-LABEL
     n-staff-card AT ROW 12.5 COL 61.5 NO-LABEL
     n-credit-card AT ROW 12.63 COL 11 NO-LABEL
     n-lim-kr AT ROW 14 COL 6.5 NO-LABEL
     n-dc-status AT ROW 15.77 COL 6 COLON-ALIGNED NO-LABEL
     n-cli-message AT ROW 18.27 COL 5.5 COLON-ALIGNED NO-LABEL
     RECT-2 AT ROW 15.27 COL 2
     l-category AT ROW 5.77 COL 67
     l-cli-message AT ROW 18.27 COL 3.5
     l-credit-card AT ROW 12.43 COL 3.1
     l-d-pcnt AT ROW 5.77 COL 3.6
     l-d-pcnt-method AT ROW 7 COL 3.6
     l-dc-status AT ROW 15.77 COL 3
     l-dc-type AT ROW 2.53 COL 3.6
     l-debet-card AT ROW 12.43 COL 28
     l-issue-code AT ROW 10.57 COL 4
     l-issue-date AT ROW 8.87 COL 4
     l-lim-kr AT ROW 14 COL 3
     l-staff-card AT ROW 12.5 COL 53.5
     l-valid-date AT ROW 8.73 COL 72
     RECT-1 AT ROW 8.27 COL 2
     RECT-3 AT ROW 12 COL 2
     RECT-5 AT ROW 5.3 COL 1.9
     RECT-6 AT ROW 2.2 COL 1.9
     RECT-7 AT ROW 18 COL 2
     l-cash-d-pcnt AT ROW 5.77 COL 37
     l-valid-from AT ROW 8.73 COL 34.5 WIDGET-ID 6
     SPACE(56.89) SKIP(9.77)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение дисконтных карт по списку"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       emitent-host-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    run b-exit-proc in this-procedure no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF B-lst IN FRAME Dialog-Frame
DO:
    define variable Filter-name as char no-undo.
    run str/dc-list.w ( input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code).
END.
ON CHOOSE OF B-shop IN FRAME Dialog-Frame
DO:
    define variable rid-list as char no-undo.
  rid-list = "".
  run adm/shops.w ( input parparentproc, "b-sel", input-output rid-list, input no).
  if rid-list <> "" then do:
    FIND FIRST ub.shop No-LOCK WHERE recid(ub.shop) = integer(rid-list) No-ERROR.
    if ub.shop.host-code <> v-cntxt-host-code-obj then do:
        message "Нельзя выдать дисконтную карту для чужой фирмы!"
        view-as alert-box ERROR.
        return no-apply.
    end.
    assign
    issue-code:screen-value = string(shop.obj-code)
    emitent-host-code:screen-value = string(shop.host-code).
  end.
END.
ON CHOOSE OF B-type IN FRAME Dialog-Frame
DO:
 run proc-b-type in this-procedure no-error.
 if error-status:error then return no-apply.
END.
ON RIGHT-MOUSE-CLICK OF B-type IN FRAME Dialog-Frame
DO:
    assign
    n-dc-type:fgcolor = 15
    l-dc-type:visible = true.
    display dc-type with frame Dialog-Frame.
    disable b-type with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF cash-d-pcnt IN FRAME Dialog-Frame
DO:
    assign
    n-cash-d-pcnt:fgcolor = 15
    cash-d-pcnt = ?
    l-cash-d-pcnt:visible = true.
    display cash-d-pcnt with frame Dialog-Frame.
    disable cash-d-pcnt with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF category IN FRAME Dialog-Frame
DO:
    assign
    n-category:fgcolor = 15
    category = ?
    l-category:visible = true.
    display category with frame Dialog-Frame.
    disable category with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF cli-message IN FRAME Dialog-Frame
DO:
    assign
    n-cli-message:fgcolor = 15
    cli-message = "":U
    l-cli-message:visible = true.
    display cli-message with frame Dialog-Frame.
    disable cli-message with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF credit-card IN FRAME Dialog-Frame
DO:
     assign
    n-credit-card:fgcolor = 15
    l-credit-card:visible = true.
    display credit-card with frame Dialog-Frame.
    disable credit-card with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF d-pcnt IN FRAME Dialog-Frame
DO:
    assign
    n-d-pcnt:fgcolor = 15
    d-pcnt = ?
    l-d-pcnt:visible = true.
    display d-pcnt with frame Dialog-Frame.
    disable d-pcnt with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF d-pcnt-method IN FRAME Dialog-Frame
DO:
     assign
    n-d-pcnt-method:fgcolor = 15
    d-pcnt-method = string('1':U)
    l-d-pcnt-method:visible = true.
    display d-pcnt-method with frame Dialog-Frame.
    disable d-pcnt-method with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF dc-status IN FRAME Dialog-Frame
DO:
    assign
    n-dc-status:fgcolor = 15
    l-dc-status:visible = true.
    display dc-status with frame Dialog-Frame.
    disable dc-status with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF debet-card IN FRAME Dialog-Frame
DO:
     assign
    n-debet-card:fgcolor = 15
    l-debet-card:visible = true.
    display debet-card with frame Dialog-Frame.
    disable debet-card with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF issue-code IN FRAME Dialog-Frame
DO:
    assign
    n-issue-code:fgcolor = 15
    issue-code = ?
    l-issue-code:visible = true.
    display issue-code with frame Dialog-Frame.
    disable issue-code b-shop with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF issue-date IN FRAME Dialog-Frame
DO:
    assign
    n-issue-date:fgcolor = 15
    issue-date = ?
    l-issue-date:visible = true.
    display issue-date with frame Dialog-Frame.
    disable issue-date with frame Dialog-Frame.
END.
ON MOUSE-SELECT-CLICK OF l-cash-d-pcnt IN FRAME Dialog-Frame
DO:
   IF l-cash-d-pcnt:visible then do:
    assign
    n-cash-d-pcnt:fgcolor = ?
    l-cash-d-pcnt:visible = false.
    enable cash-d-pcnt with frame Dialog-Frame.
    APPLY "ENTRY" TO cash-d-pcnt.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-category IN FRAME Dialog-Frame
DO:
   IF l-category:visible then do:
    assign
    n-category:fgcolor = ?
    l-category:visible = false.
    enable category with frame Dialog-Frame.
    APPLY "ENTRY" TO category.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-cli-message IN FRAME Dialog-Frame
DO:
   IF l-cli-message:visible then do:
    assign
    n-cli-message:fgcolor = ?
    l-cli-message:visible = false.
    enable cli-message with frame Dialog-Frame.
    APPLY "ENTRY" TO cli-message.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-credit-card IN FRAME Dialog-Frame
DO:
   IF l-credit-card:visible then do:
    assign
    n-credit-card:fgcolor = ?
    l-credit-card:visible = false.
    enable credit-card with frame Dialog-Frame.
    APPLY "ENTRY" TO credit-card.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-d-pcnt IN FRAME Dialog-Frame
DO:
   IF l-d-pcnt:visible then do:
    assign
    n-d-pcnt:fgcolor = ?
    l-d-pcnt:visible = false.
    enable d-pcnt with frame Dialog-Frame.
    APPLY "ENTRY" TO d-pcnt.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-d-pcnt-method IN FRAME Dialog-Frame
DO:
   IF l-d-pcnt-method:visible then do:
    assign
    n-d-pcnt-method:fgcolor = ?
    l-d-pcnt-method:visible = false.
    enable d-pcnt-method with frame Dialog-Frame.
    APPLY "ENTRY" TO d-pcnt-method.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-dc-status IN FRAME Dialog-Frame
DO:
   IF l-dc-status:visible then do:
    assign
    n-dc-status:fgcolor = ?
    l-dc-status:visible = false.
    enable dc-status with frame Dialog-Frame.
    APPLY "ENTRY" TO dc-status.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-dc-type IN FRAME Dialog-Frame
DO:
   IF l-dc-type:visible then do:
    assign
    n-dc-type:fgcolor = ?
    l-dc-type:visible = false.
    enable b-type with frame Dialog-Frame.
    APPLY "ENTRY" TO dc-type.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-debet-card IN FRAME Dialog-Frame
DO:
   IF l-debet-card:visible then do:
    assign
    n-debet-card:fgcolor = ?
    l-debet-card:visible = false.
    enable debet-card with frame Dialog-Frame.
    APPLY "ENTRY" TO debet-card.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-issue-code IN FRAME Dialog-Frame
DO:
   IF l-issue-code:visible then do:
    assign
    n-issue-code:fgcolor = ?
    l-issue-code:visible = false.
    enable
    issue-code
    B-shop
    with frame Dialog-Frame.
    APPLY "ENTRY" TO issue-code.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-issue-date IN FRAME Dialog-Frame
DO:
   IF l-issue-date:visible then do:
    assign
    n-issue-date:fgcolor = ?
    l-issue-date:visible = false.
    enable issue-date with frame Dialog-Frame.
    APPLY "ENTRY" TO issue-date.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-lim-kr IN FRAME Dialog-Frame
DO:
   IF l-lim-kr:visible then do:
    assign
    n-lim-kr:fgcolor = ?
    l-lim-kr:visible = false.
    enable
    lim-kr
    with frame Dialog-Frame.
    APPLY "ENTRY" TO lim-Kr.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-staff-card IN FRAME Dialog-Frame
DO:
   IF l-staff-card:visible then do:
    assign
    n-staff-card:fgcolor = ?
    l-staff-card:visible = false.
    enable staff-card with frame Dialog-Frame.
    APPLY "ENTRY" TO staff-card.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-valid-date IN FRAME Dialog-Frame
DO:
   IF l-valid-date:visible then do:
    assign
    n-valid-date:fgcolor = ?
    l-valid-date:visible = false.
    enable valid-date with frame Dialog-Frame.
    APPLY "ENTRY" TO valid-date.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-valid-from IN FRAME Dialog-Frame
DO:
   IF l-valid-from:visible then do:
    assign
    n-valid-from:fgcolor = ?
    l-valid-from:visible = false.
    enable valid-from with frame Dialog-Frame.
    APPLY "ENTRY" TO valid-from.
  end.
END.
ON RIGHT-MOUSE-CLICK OF lim-kr IN FRAME Dialog-Frame
DO:
   assign
    n-lim-kr:fgcolor = 15
    l-lim-kr:visible = true.
    display lim-kr with frame Dialog-Frame.
    disable lim-kr with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF n-dc-type IN FRAME Dialog-Frame
DO:
     assign
    n-dc-type:fgcolor = 15
    dc-type = ""
    l-dc-type:visible = true.
    display dc-type with frame Dialog-Frame.
    disable b-type with frame Dialog-Frame.
    Hide emitent-host-code in frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF staff-card IN FRAME Dialog-Frame
DO:
     assign
    n-staff-card:fgcolor = 15
    l-staff-card:visible = true.
    display staff-card with frame Dialog-Frame.
    disable staff-card with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF valid-date IN FRAME Dialog-Frame
DO:
    assign
    n-valid-date:fgcolor = 15
    valid-date = ?
    l-valid-date:visible = true.
    display valid-date with frame Dialog-Frame.
    disable valid-date with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF valid-from IN FRAME Dialog-Frame
DO:
    assign
    n-valid-from:fgcolor = 15
    valid-from = ?
    l-valid-from:visible = true.
    display valid-from with frame Dialog-Frame.
    disable valid-from with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
if ( g#db-num > 0 ) then do:
    message "Данная утилита может быть запущена только в ГБД!" view-as alert-box.
    return.
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable glog as logical   no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_referense-dis_input-deletion-updating':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog
then do:
  return.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  dc-status:list-items = 'тек':U + chr(44) + 'блок':U + chr(44) + 'удал':U.
  d-pcnt-method:radio-buttons =
       "Товар" + chr(44) + string('1':U) + chr(44) +
     "Итог_чека" + chr(44) + string('2':U) + chr(44) +
     "Товары_и_итог_чека" + chr(44) + string('3':U).
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI in this-procedure .
PROCEDURE b-exit-proc :
define variable mystr as char format "X(500)".
define variable glog as logical no-undo .
define variable II AS INTEGER NO-UNDO.
DEFINE VARIABLE var-run-names as character no-undo .
define variable ok-to-restore as logical no-undo .
if not can-find(first dc-list) then do:
  BELL.
  message
  "В списке дисконтных карт нет ни одной карты!"
  view-as alert-box WARNING.
  return error.
end.
assign
frame Dialog-Frame dc-status
dc-type
d-pcnt
cash-d-pcnt
category
emitent-host-code
issue-code
issue-date
credit-card
LIM-KR
valid-date
d-pcnt-method
debet-card
staff-card
cli-message
.
if issue-code:sensitive and integer(issue-code:screen-value) = 0 then do:
    message "Укажите код магазина, выдавшего карту!" view-as alert-box WARNING.
    return error .
end.
if issue-date:sensitive and issue-date:screen-value = "  /  /    " then do:
    message "Укажите дату выдачи карты!" view-as alert-box WARNING.
    return error .
end.
if b-type:sensitive and dc-type = "" then do:
    message "Укажите тип карты!" view-as alert-box WARNING.
    return error .
end.
if d-pcnt:sensitive and ((d-pcnt < 0 ) OR ( d-pcnt = ? )) then do:
        message "Вам следует ввести" skip
                        "НЕОТРИЦАТЕЛЬНЫЙ процент скидки (на товары)."
                        view-as alert-box INFORMATION .
        apply "ENTRY":U to d-pcnt IN frame Dialog-Frame.
        return error .
end.
if cash-d-pcnt:sensitive and ((cash-d-pcnt < 0 ) OR ( cash-d-pcnt = ? )) then do:
        message "Вам следует ввести" skip
                        "НЕОТРИЦАТЕЛЬНЫЙ процент скидки (на итог)."
                        view-as alert-box INFORMATION .
        apply "ENTRY":U to cash-d-pcnt IN frame Dialog-Frame.
        return error .
end.
IF dc-status:sensitive and dc-status = 'тек':U or dc-status = 'блок':U then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_referense-dis_current-status':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output ok-to-restore
    )  .
end.
  if not ok-to-restore then do:
    message
    substitute("ВНИМАНИЕ!&1" +
              "У Вас нет прав на восстановление удаленных карт&1" +
              "Для удаленных карт статус карты на &2  изменен не будет!"
              , chr(10)
              , dc-status  )
    view-as alert-box  WARNING.
  end.
end.
IF credit-card:sensitive
    AND credit-card
    AND debet-card:sensitive
    AND debet-card THEN DO:
   message
  "Карта не может быть одновреенно кредитной и дебетовой"
  view-as ALERT-BOX ERROR.
  RETURN ERROR.
END.
mystr =   (IF dc-status:sensitive then ("СТАТУС="+                   dc-status + chr(10) ) else "") +
          (IF b-type:sensitive then ("ТИП КАРТЫ=" +                  dc-type + chr(10) ) else "") +
          (IF b-type:sensitive then ("ЭМИТЕНТ=" +                    string(ub.dis-card-type.emitent-host-code) + chr(10) ) else "") +
          (IF d-pcnt:sensitive then ("% СКИДКИ НА ТОВАР=" +          string(d-pcnt) + chr(10) ) else "") +
          (IF cash-d-pcnt:sensitive then ("% СКИДКИ НА ИТОГ=" +      string(cash-d-pcnt) + chr(10) ) else "") +
          (IF category:sensitive then ("КАТЕГОРИЯ=" +                string(category) + chr(10) ) else "") +
          (IF issue-date:sensitive then ("ДАТА ВЫДАЧИ=" +            string(issue-date, "99/99/9999") ) else "") +
          (IF issue-code:sensitive then ("ВЫДАЛ МАГАЗИН=" +          string(issue-code, "99999") ) else "") +
          (IF credit-card:sensitive then ("КРЕДИТНАЯ КАРТА=" +       string(credit-card, "да/нет") ) else "") +
          (IF debet-card:sensitive then ("ДЕБЕТОВАЯ КАРТА=" +        string(debet-card, "да/нет") ) else "") +
          (IF staff-card:sensitive then ("КАРТА ПЕРСОНАЛА=" +        string(staff-card, "да/нет") ) else "") +
          (IF lim-kr:sensitive then ("ЛИМИТ КРЕДИТА=" +              string(lim-kr)) else "") +
          (IF valid-date:sensitive then ("ДАТА ДЕЙСТВИЯ ДО=" +       string(valid-date, "99/99/9999") ) else "") +
          (IF d-pcnt-method:sensitive then ("ТИП СКИДКИ=" +          radio-label(d-pcnt-method, d-pcnt-method:radio-buttons) + chr(10)) else "":U) +
          (IF cli-message:sensitive then ("СООБЩЕНИЕ ДЛЯ КЛИЕНТА=" + string(cli-message, "X(128)" )) else "")
.
if REPLACE(mystr, chr(10), "") = "" then do:
  message "Не выбраны поля и значения для внесения изменений" view-as alert-box
  Warning.
  return error .
end.
message
"В выбранных дисконтных картах будут произведены следующие изменения:" skip
mystr skip "Продолжать?"
view-as alert-box QUESTION buttons YES-NO update glog.
IF not glog then return error.
run str/diallog.w (
             input parparentproc
            ,input this-procedure
            ,input 'utl/discarun.p':U
            ,input
            (v-cntxt-obj-type + chr(4) +
             string(v-cntxt-obj-code) + chr(4) +
            (IF dc-status:sensitive     then (dc-status + chr(44) + string(ok-to-restore)) else "":U )     + chr(4) +
            (IF b-type:sensitive        then dc-type  else "":U )                                               + chr(4) +
            (IF b-type:sensitive        then string(dis-card-type.emitent-host-code)  else "":U )               + chr(4) +
            (IF d-pcnt:sensitive        then string(d-pcnt) else "")                                            + chr(4) +
            (IF cash-d-pcnt:sensitive   then string(cash-d-pcnt)  else "")                                      + chr(4) +
            (IF category:sensitive      then string(category)  else "")                                         + chr(4) +
            (IF issue-date:sensitive    then string(issue-date, "99/99/9999") else "")                          + chr(4) +
            (IF issue-code:sensitive    then string(issue-code)  else "")                                       + chr(4) +
            (IF credit-card:sensitive   then string(credit-card)  else "")                                      + chr(4) +
            (IF debet-card:sensitive    then string(debet-card) else "")                                        + chr(4) +
            (IF staff-card:sensitive    then string(staff-card) else "")                                        + chr(4) +
            (IF lim-kr:sensitive        then string(lim-kr) else "")                                            + chr(4) +
            (IF valid-from:sensitive    then string(valid-from, "99/99/9999") else "")                          + chr(4) +
            (IF valid-date:sensitive    then string(valid-date, "99/99/9999") else "")                          + chr(4) +
            (IF d-pcnt-method:sensitive then string(d-pcnt-method) else "":U)                                   + chr(4) +
            (IF cli-message:sensitive   then string(cli-message, "X(128)" ) else "") +
            chr(1) +
            (IF dc-status:sensitive     then "yes" else "no":U)                                                 + chr(4) +
            (IF b-type:sensitive        then "yes" else "no":U)                                                 + chr(4) +
            (IF b-type:sensitive        then "yes" else "no":U)                                                 + chr(4) +
            (IF d-pcnt:sensitive        then "yes" else "no":U)                                                 + chr(4) +
            (IF cash-d-pcnt:sensitive   then "yes" else "no":U)                                                 + chr(4) +
            (IF category:sensitive      then "yes" else "no":U)                                                 + chr(4) +
            (IF issue-date:sensitive    then "yes" else "no":U)                                                 + chr(4) +
            (IF issue-code:sensitive    then "yes" else "no":U)                                                 + chr(4) +
            (IF credit-card:sensitive   then "yes" else "no":U)                                                 + chr(4) +
            (IF debet-card:sensitive    then "yes" else "no":U)                                                 + chr(4) +
            (IF staff-card:sensitive    then "yes" else "no":U)                                                 + chr(4) +
            (IF lim-kr:sensitive        then "yes" else "no":U)                                                 + chr(4) +
            (IF valid-from:sensitive    then "yes" else "no":U)                                                 + chr(4) +
            (IF valid-date:sensitive    then "yes" else "no":U)                                                 + chr(4) +
            (IF d-pcnt-method:sensitive then "yes" else "no":U)                                                 + chr(4) +
            (IF cli-message:sensitive   then "yes" else "no":U)
            )
            ,input no
            ,input "&Стоп"
            ,input 'Изменение ДК по списку') .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.dis-card SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY cash-d-pcnt category d-pcnt d-pcnt-method valid-date issue-date
          valid-from issue-code debet-card staff-card credit-card lim-kr
          dc-status cli-message n-dc-type dc-type n-cash-d-pcnt n-category
          n-d-pcnt n-d-pcnt-method n-valid-date n-valid-from n-issue-date
          n-issue-code n-debet-card n-staff-card n-credit-card n-lim-kr
          n-dc-status n-cli-message
      WITH FRAME Dialog-Frame.
  ENABLE b-exit l-category l-cli-message l-credit-card l-d-pcnt l-d-pcnt-method
         l-dc-status l-dc-type l-debet-card l-issue-code l-issue-date l-lim-kr
         l-staff-card l-valid-date RECT-1 RECT-3 RECT-5 RECT-6 RECT-7
         l-cash-d-pcnt l-valid-from B-quit B-lst B-Help d-pcnt-method n-dc-type
         dc-type n-cash-d-pcnt n-category n-d-pcnt n-d-pcnt-method n-valid-date
         n-valid-from n-issue-date n-issue-code n-debet-card n-staff-card
         n-credit-card n-lim-kr n-dc-status n-cli-message
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
  OPEN QUERY Dialog-Frame FOR EACH ub.dis-card SHARE-LOCK.
  GET FIRST Dialog-Frame.
  assign
    d-pcnt = ?
    cash-d-pcnt = ?
    category = ?
    .
  DISPLAY cash-d-pcnt d-pcnt category d-pcnt-method valid-date issue-date issue-code
          credit-card cli-message debet-card staff-card lim-kr dc-status n-dc-type dc-type n-cash-d-pcnt n-d-pcnt
          n-d-pcnt-method n-valid-date n-issue-date n-issue-code n-credit-card n-debet-card n-staff-card
          n-lim-kr n-dc-status n-cli-message
      WITH FRAME Dialog-Frame.
  ENABLE b-exit l-dc-type l-cash-d-pcnt l-category l-credit-card l-debet-card l-staff-card
          l-d-pcnt  l-lim-kr
         l-dc-status l-issue-code l-issue-date l-valid-date
         l-d-pcnt-method l-cli-message B-quit B-lst B-Help n-dc-type
         n-cash-d-pcnt n-d-pcnt n-d-pcnt-method n-valid-date
         n-issue-date n-issue-code n-credit-card n-lim-kr n-dc-status n-debet-card n-staff-card n-cli-message
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-type :
define variable var-rid-str as character no-undo.
define variable v-d-pcnt as decimal no-undo .
define variable v-cash-d-pcnt as decimal no-undo .
define variable v-categ as integer no-undo .
define buffer b_clients for ub.clients.
  run ref/dc-types.w (
                  input parparentproc
                ,input "":U
                ,input "b-sel":U
                ,input 0
                ,input 0
                ,input "":U
                ,input 0
                ,input-output  var-rid-str) .
  if var-rid-str = "" then return ERROR.
find first ub.dis-card-type no-lock where
              recid(ub.dis-card-type) = integer(var-rid-str) No-ERROR.
if not avail ub.dis-card-type then return ERROR.
if ub.dis-card-type.emitent-host-code = 0 then do:
end.
else do:
      find first b_clients No-LOCK WHERE
              b_clients.obj-type = 'орг':U and
              b_clients.obj-code = ub.dis-card-type.emitent-host-code No-ERROR.
      if not avail b_clients then return ERROR.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  ub.dis-card-type.type
  ,input  ub.dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-d-pcnt
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  ub.dis-card-type.type
  ,input  ub.dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-cash-d-pcnt
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  ub.dis-card-type.type
  ,input  ub.dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-categ':U
  ,output v-categ
  )  .
if v-d-pcnt = ? then do:
  v-d-pcnt = 0.
end.
if v-cash-d-pcnt = ? then do:
  v-cash-d-pcnt = 0.
end.
if v-categ = ? then do:
  v-categ = 0.
end.
display
ub.dis-card-type.type @ dc-type
ub.dis-card-type.emitent-host-code @ emitent-host-code
v-d-pcnt @ d-pcnt
v-cash-d-pcnt @ cash-d-pcnt
with frame Dialog-Frame
.
if ub.dis-card-type.dflt-credit-card then do:
  APPLY   "mouse-select-click" TO l-credit-card.
  APPLY   "mouse-select-click" TO l-LIM-KR.
  CREDIT-CARD:SCREEN-VALUE = "YES".
  display
  ub.dis-card-type.lim-kr @ lim-kr
  with frame Dialog-Frame.
end.
else do:
  APPLY   "right-mouse-click" TO credit-card.
  APPLY   "right-mouse-click" TO LIM-KR.
end.
END PROCEDURE.
