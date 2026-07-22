define temp-table temp_fin-doc-code no-undo
field host-code as integer
field fin-doc-code as integer
index pi is primary unique fin-doc-code
.
define input parameter parparentproc    as handle           no-undo.
define input parameter p-call-handle     as handle           no-undo.
define input parameter table for temp_fin-doc-code .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список печатных форм для печати документов.".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table Tmp#List no-undo like ub.ord-blank
field id                        as integer
field proc-name                 as character
field proc-param                as character
field print-options             as character
field orient                    as character
field orient-orientation        as character
field orient-font-num           as integer
field font-num                  as character
field filtr                     as character
field view_                     as integer  init 1
field sys-key                   as character
field sys-key-black             as character
field type-val                  as character
field type-val-enabled          as logical
index pi is primary unique id
index in-name
blank-name
index lu
last-use
.
define temp-table temp_form-list no-undo
field host-code as integer
field fin-doc-code  as integer
field id        as integer
field fin-doc-type  as character
field status_   as character
index pi is primary unique
host-code
fin-doc-code
id
index idx
id
.
define temp-table temp_menu-doc_disabled-doc-list no-undo
field host-code      as integer
field fin-doc-code      as integer
field blank-name    as character
field reason        as character
index pi is primary unique
host-code
fin-doc-code
blank-name
.
define variable v-menu-doc-sys-key              as character    no-undo.
define variable v-menu-doc-fin-doc-code         as integer      no-undo.
define variable v-menu-doc-host-code            as integer      no-undo .
define variable v-menu-doc-fin-doc-type         as character    no-undo.
define variable v-menu-doc-fin-ext-doc-type     as character    no-undo.
define variable v-menu-doc-status_              as character    no-undo.
define variable v-menu-doc-item-counter         as integer      no-undo.
define variable v-menu-doc-item-disabled        as logical      no-undo.
define variable vss-include-info3 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
function check-entry-with-mask returns logical ( input p-element as character, input p-list as character, input p-delimiter as character ) :
  define variable p-entry   as logical   no-undo .
  define variable v-ind as integer   no-undo .
  if p-delimiter = "*":U then do:
    message
      vss-workfile "(check-entry-with-mask)" vss-revision vss-description skip
      substitute('Разделитель не может быть равный "&1"', p-delimiter ) skip
      view-as alert-box error .
    return ? .
  end.
  assign
    p-entry = true
  .
  if lookup( p-element, p-list, p-delimiter ) = 0 then do:
    assign
      p-entry = false
    .
    if num-entries( p-list, "*":U ) > 1 then do:
      block_check-list:
      do v-ind = 1 to num-entries( p-list, p-delimiter )
      :
        if p-element matches entry( v-ind, p-list, p-delimiter ) then do:
          assign
            p-entry = true
          .
          leave block_check-list .
        end.
      end.
    end.
  end.
  return p-entry .
end function .
procedure menufdoc-create-menu-item
:
define input parameter p-type   as   character no-undo.
define input parameter p-stat   as   character no-undo.
define input parameter param-1  as   character no-undo.
define input parameter param-2  as   character no-undo.
define input parameter param-5  as   character no-undo.
define input parameter param-6  as   character no-undo.
define input parameter param-7  as   character no-undo.
define input parameter param-8  as   character no-undo.
define input parameter param-9  as   character no-undo.
define input parameter param-10 as   character no-undo.
define input parameter param-11 as   character no-undo.
define input parameter param-12 as   character no-undo.
do
on error undo, return error
:
  assign
  v-menu-doc-item-disabled = yes
    .
  if v-menu-doc-sys-key <> 'ExpertekIBS':U
  and ( ( param-10 <> "":U
          and check-entry-with-mask( v-menu-doc-sys-key, param-10, chr(44) ) = false
        )
        or ( param-12 <> "":U
              and check-entry-with-mask( v-menu-doc-sys-key, param-12, chr(44) ) = true )
            )
  then do:
    undo, return .
  end.
  if param-7 = "":U
  then do:
    undo, return .
  end.
  if param-1 = '*':U
  or lookup( p-type, param-1 ) > 0
  then do:
    if param-2 = '*':U
    or lookup( p-stat, param-2 ) > 0
    then do:
      assign
     v-menu-doc-item-disabled = no
      .
      find first tmp#list
            where tmp#list.blank-name     = param-5
              and tmp#list.filtr          = param-6
              and tmp#list.proc-name      = param-7
              and tmp#list.proc-param     = param-8
              and tmp#list.print-options  = param-9
              and tmp#list.sys-key        = param-10
              and tmp#list.orient         = param-11
              and tmp#list.sys-key-black  = param-12
      no-error.
      if not available tmp#list
      then do:
        assign
        v-menu-doc-item-counter = v-menu-doc-item-counter + 1
        .
        create tmp#list.
        assign
        tmp#list.id             = v-menu-doc-item-counter
        tmp#list.cli-code       = v-menu-doc-item-counter
        tmp#list.blank-name     = param-5
        tmp#list.filtr          = param-6
        tmp#list.proc-name      = param-7
        tmp#list.proc-param     = param-8
        tmp#list.print-options  = param-9
        tmp#list.sys-key        = param-10
        tmp#list.orient         = param-11
        tmp#list.sys-key-black  = param-12
        .
        assign
        tmp#list.orient-orientation     = entry( 1, tmp#list.orient )
        tmp#list.orient-font-num        = 7
        .
        assign
        tmp#list.orient-font-num      = ( if num-entries( tmp#list.orient ) > 1
                                          then integer( entry( 2, tmp#list.orient ) )
                                          else 7 )
        no-error.
        if error-status :error
        then do:
          assign
          tmp#list.orient-font-num = 7
          .
        end.
        run menufdoc-set-visible-options in this-procedure (
              input tmp#list.print-options
            , output tmp#list.type-val-enabled
        ).
      end.
    end.
  end.
  if v-menu-doc-item-disabled = yes then do:
    find first tmp#list
          where tmp#list.blank-name     = param-5
            and tmp#list.filtr          = param-6
            and tmp#list.proc-name      = param-7
            and tmp#list.proc-param     = param-8
            and tmp#list.print-options  = param-9
            and tmp#list.sys-key        = param-10
            and tmp#list.orient         = param-11
            and tmp#list.sys-key-black  = param-12
      no-error.
  if available tmp#list
  then do:
    find first temp_menu-doc_disabled-doc-list
          where temp_menu-doc_disabled-doc-list.host-code     = v-menu-doc-host-code
            and temp_menu-doc_disabled-doc-list.fin-doc-code     = v-menu-doc-fin-doc-code
            and temp_menu-doc_disabled-doc-list.blank-name   = param-5
    no-error.
    if not available temp_menu-doc_disabled-doc-list
    then do:
      create temp_menu-doc_disabled-doc-list.
      assign
      temp_menu-doc_disabled-doc-list.host-code    = v-menu-doc-host-code
      temp_menu-doc_disabled-doc-list.fin-doc-code    = v-menu-doc-fin-doc-code
      temp_menu-doc_disabled-doc-list.blank-name  = param-5
      .
    end.
    if param-1 <> '*':U
    and lookup( p-type, param-1 ) > 0
    then do:
      assign
      temp_menu-doc_disabled-doc-list.reason   = "type":U
      .
    end.
    assign
    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
    .
    if param-2 <> '*':U
    and lookup( p-stat, param-2 ) > 0
    then do:
      assign
      temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "stat":U
      .
    end.
    assign
    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
    .
    assign
    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
    .
    if v-menu-doc-sys-key = 'ExpertekIBS':U
    then do:
      run menufdoc-extend-blank-name-for-IBS in this-procedure (
              input tmp#list.blank-name
            , input tmp#list.sys-key
            , input Tmp#List.sys-key-black
            , output tmp#list.blank-name
        ).
    end.
  end.
  else do:
    assign
    v-menu-doc-item-disabled = no
    .
  end.
end.
  if v-menu-doc-item-disabled = no
  then do:
    find first tmp#list
          where tmp#list.blank-name     = param-5
            and tmp#list.filtr          = param-6
            and tmp#list.proc-name      = param-7
            and tmp#list.proc-param     = param-8
            and tmp#list.print-options  = param-9
            and tmp#list.sys-key        = param-10
            and tmp#list.orient         = param-11
            and tmp#list.sys-key-black  = param-12
    no-error.
    if available tmp#list
    then do:
      find first temp_form-list
            where temp_form-list.host-code  = v-menu-doc-host-code
              and temp_form-list.fin-doc-code  = v-menu-doc-fin-doc-code
              and temp_form-list.id        = tmp#list.id
      no-error.
      if not available temp_form-list then do:
        create temp_form-list.
        assign
        temp_form-list.host-code      = v-menu-doc-host-code
        temp_form-list.fin-doc-code  = v-menu-doc-fin-doc-code
        temp_form-list.id        = tmp#list.id
        temp_form-list.fin-doc-type  = v-menu-doc-fin-doc-type
        temp_form-list.status_   = v-menu-doc-status_
        .
       end.
       if v-menu-doc-sys-key = 'ExpertekIBS':U
       then do:
         run menufdoc-extend-blank-name-for-IBS in this-procedure (
                      input tmp#list.blank-name
                    , input tmp#list.sys-key
                    , input Tmp#List.sys-key-black
                    , output tmp#list.blank-name
                ).
       end.
     end.
  end.
end.
end procedure.
procedure menufdoc-set-visible-options :
define input parameter p-print-options          as character        no-undo.
define output parameter p-type-val-enabled      as logical          no-undo.
do
on error undo, return error
:
  assign
  p-type-val-enabled      = ( if substring( p-print-options, 1, 1 ) = "+" then yes else no )
  .
end.
end procedure.
procedure menufdoc-create-options-string :
define input parameter p-tmp-list-id        as integer          no-undo.
define output parameter p-options-string    as character        no-undo.
define buffer buf_tmp#list      for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
  find first buf_tmp#list
        where buf_tmp#list.id = p-tmp-list-id
  .
  assign
  p-options-string =  ( if trim( buf_tmp#list.type-val    ) = "+":U then "+":U else "-":U )
  .
end.
end procedure.
procedure menufdoc-set-options-string :
define input parameter p-tmp-list-id            as integer          no-undo.
define input parameter p-options-string         as character        no-undo.
define buffer buf_tmp#list      for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
  find first buf_tmp#list
        where buf_tmp#list.id = p-tmp-list-id
  .
  assign
  buf_tmp#list.type-val    = ( if buf_tmp#list.type-val-enabled       = yes then substitute( "  &1", substring( p-options-string, 1, 1 ) ) else " ":U )
    .
end.
end procedure.
procedure menufdoc-create-options-enabled-string :
define input parameter p-tmp-list-id                as integer          no-undo.
define output parameter p-options-enabled-string    as character        no-undo.
define buffer buf_tmp#list      for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
  find first buf_tmp#list
        where buf_tmp#list.id = p-tmp-list-id
    .
 assign
  p-options-enabled-string =  ( if buf_tmp#list.type-val-enabled    = yes then "+":U else "-":U )
                                .
end.
end procedure.
procedure menufdoc-extend-blank-name-for-IBS :
define input parameter p-in-blank-name      as character        no-undo.
define input parameter p-sys-key            as character        no-undo.
define input parameter p-sys-key-black      as character        no-undo.
define output parameter p-out-blank-name    as character        no-undo.
do
on error undo, return error
:
  assign
  p-out-blank-name = p-in-blank-name
  .
  if p-sys-key <> "":U
  then do:
    assign
    p-out-blank-name = substring( p-in-blank-name + " '" + p-sys-key + "'" , 1, 120 )
    .
  end.
  if p-sys-key-black <> ""
  then do:
    assign
    p-out-blank-name = substring( p-in-blank-name + " no-'" + p-sys-key-black + "'", 1, 120 )
    .
  end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new shared variable print-graft as logical no-undo .
define new shared variable no-vat      as logical no-undo .
define new shared variable sort-gr     as logical no-undo .
define new shared variable sort-name   as logical no-undo .
define new shared variable CostPrice   as logical no-undo .
define new shared variable PrintScale  as logical no-undo .
define new shared variable PrintParts  as logical no-undo .
define variable v-par-value         as character    no-undo.
define variable v-par-type          as character    no-undo.
define variable in-docprvalue       as character    no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.1.
DEFINE BUTTON b-deselect
     LABEL "&Снять *"
     SIZE 10 BY 1.1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 3.6 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-print-doc
     LABEL ".   Пе&чать":L
     SIZE 11.8 BY 1.1
     BGCOLOR 8 .
DEFINE BUTTON b-sel
     LABEL "*"
     SIZE 3 BY 1.1.
DEFINE BUTTON i-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U
     LABEL ""
     SIZE 4 BY .95.
DEFINE VARIABLE fi-default-printer AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 97 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY br-table FOR
      Tmp#List SCROLLING.
DEFINE BROWSE br-table
  QUERY br-table NO-LOCK DISPLAY
      Tmp#List.last-use COLUMN-LABEL "*" FORMAT "*/"
    Tmp#List.blank-name COLUMN-LABEL "Название печатной формы":C53 FORMAT "X(255)"
    Tmp#List.type-val       column-label "в ..."    format "X(5)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.8 BY 20.24 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.6
     b-sel AT ROW 1 COL 11.6
     b-deselect AT ROW 1 COL 14.6
     b-chg AT ROW 1 COL 24.8
     b-print-doc AT ROW 1 COL 34.8
     b-help AT ROW 1 COL 96
     i-print AT ROW 1.05 COL 35 WIDGET-ID 2 NO-TAB-STOP
     br-table AT ROW 2.24 COL 1.6
     fi-default-printer AT ROW 22.76 COL 1.6 NO-LABEL
     SPACE(1.27) SKIP(0.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список печатных форм".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       fi-default-printer:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
define variable v-options-string            as character    no-undo.
define variable v-options-string-new        as character    no-undo.
define variable v-options-enabled-string    as character    no-undo.
if available tmp#list
then do:
  run menufdoc-create-options-string in this-procedure (
        input tmp#list.id
      , output v-options-string
  ).
  run menufdoc-create-options-enabled-string in this-procedure (
        input tmp#list.id
      , output v-options-enabled-string
  ).
  run rep/d-docmd.w (
        input tmp#list.blank-name
      , input v-options-string
      , input v-options-enabled-string
      , output v-options-string-new
  ) no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description
    skip(1)
    skip "Ошибка изменения параметров печати."
    skip return-value
    skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return no-apply .
  end.
  if v-options-string-new <> v-options-string
  then do:
      run menufdoc-set-options-string in this-procedure (
              input tmp#list.id
            , input v-options-string-new
      ).
    browse br-table :refresh().
    apply "entry" to br-table in frame Dialog-Frame.
  end.
end.
END.
ON CHOOSE OF b-deselect IN FRAME Dialog-Frame
DO:
  for each tmp#list no-lock
  :
    assign
    tmp#list.last-use = no
    .
  end.
  browse br-table :refresh().
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  run save-form-parameters in this-procedure no-error.
  if error-status :error
  then do:
      message
      vss-workfile vss-revision vss-description
      skip(1)
      skip "Ошибка при сохранении параметров"
      skip "списка печатных форм."
      skip return-value
      skip trim(error-status :get-message(1))
      view-as alert-box error.
  end.
END.
ON CHOOSE OF b-print-doc IN FRAME Dialog-Frame
DO:
define variable v-is-selected   as logical      no-undo.
define buffer buf_temp_tmp#list      for tmp#list.
assign
v-is-selected = no
.
test-selecting:
for each buf_temp_tmp#list
:
  if buf_temp_tmp#list.last-use <> no
  then do:
    assign
    v-is-selected = yes
    .
    leave test-selecting.
  end.
end.
if v-is-selected = no
then do:
  message
  "Не выбрано ни одной формы"
  skip "для печати."
  view-as alert-box information
  title "Печать невозможна"
  .
  undo, return no-apply.
end.
else do:
  run print-docs in this-procedure no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description
    skip(1)
    skip "Ошибка печати документов."
    skip return-value
    skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return no-apply .
  end.
end.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if available tmp#list
  then do:
    assign
    tmp#list.last-use = ( if tmp#list.last-use = yes then no else yes )
    .
    run reposition-browse in this-procedure .
    browse br-table :refresh().
  end.
END.
ON 1 OF br-table IN FRAME Dialog-Frame
DO:
  if available tmp#list
  then do:
    if tmp#list.type-val = "  +":U
    or tmp#list.type-val = "  -":U
    then do:
      assign
      tmp#list.type-val = ( if tmp#list.type-val = "  +":U then "  -":U else "  +":U )
      .
    end.
    br-table :refresh().
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME Dialog-Frame
DO:
  if available Tmp#List
  then do:
    run select-or-deselect-item in this-procedure (
        input Tmp#List.id
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка выбора или отмены выбора."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    br-table :refresh().
  end.
END.
ON ROW-DISPLAY OF br-table IN FRAME Dialog-Frame
DO:
  if tmp#list.type-val-enabled = no
  then do:
    assign
    Tmp#List.type-val :bgcolor in browse br-table = GREY_COLOR
    .
  end.
  if lookup("other", tmp#list.filtr) > 0  then do:
    assign
    Tmp#List.last-use          :bgcolor in browse br-table = yellow_COLOR
    Tmp#List.blank-name        :bgcolor in browse br-table = yellow_COLOR
    .
  end.
  else do:
    assign
    Tmp#List.last-use          :bgcolor in browse br-table = ?
    Tmp#List.blank-name        :bgcolor in browse br-table = ?
    .
  end.
  if Tmp#List.orient-font-num <> 7
  then do:
    assign
    Tmp#List.last-use          :fgcolor in browse br-table = DARK_GREEN_COLOR
    Tmp#List.blank-name        :fgcolor in browse br-table = DARK_GREEN_COLOR
    .
  end.
  else do:
    if Tmp#List.orient-orientation = 'A4port':U
    or Tmp#List.orient-orientation = 'A3port':U
    then do:
      Tmp#List.last-use          :fgcolor in browse br-table = BLUE_COLOR.
      Tmp#List.blank-name        :fgcolor in browse br-table = BLUE_COLOR.
    end.
    else do:
      if Tmp#List.orient-orientation = 'EXCEL':U
      or Tmp#List.orient-orientation = 'self':U
      then do:
        Tmp#List.last-use   :fgcolor in browse br-table = CYAN_COLOR.
        Tmp#List.blank-name :fgcolor in browse br-table = CYAN_COLOR.
      end.
      else do:
        Tmp#List.last-use   :fgcolor in browse br-table = BLACK_COLOR.
        Tmp#List.blank-name :fgcolor in browse br-table = BLACK_COLOR.
      end.
    end.
  end.
END.
ON CHOOSE OF i-print IN FRAME Dialog-Frame
DO:
  APPLY "choose" TO b-print-doc.
END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-table :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  Tmp#List.type-val:label =  "в руб"  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run get-quest-print in parparentproc (
      output g#quest-print
  ).
  run get-report-num in parparentproc (
      output g#report-num
  ).
  run init-fields in this-procedure.
  RUN enable_UI.
  run ui-disable-all in this-procedure.
  run ui-enable in this-procedure.
  apply "value-changed" to br-table.
  apply "entry" to br-table.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE create-menu-items1 :
define input parameter p-host-code      as integer          no-undo .
define input parameter p-fin-doc-code   as integer          no-undo.
define input parameter p-doc-type       as character        no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-status_        as character        no-undo.
define variable xtype        as character    no-undo.
define variable xstatus      as character    no-undo.
do
on error undo, return error
:
  if p-doc-type <> 'инв':U
  then do:
    assign
    xtype = p-doc-type
    .
  end.
  else do:
    assign
    xtype = p-ext-doc-type
    .
  end.
  assign
  xstatus             = string( p-status_  )
  .
  assign
  v-menu-doc-host-code = p-host-code
  v-menu-doc-fin-doc-code = p-fin-doc-code
  v-menu-doc-fin-doc-type = xtype
  v-menu-doc-fin-ext-doc-type = p-ext-doc-type
  v-menu-doc-status_      = xstatus
  .
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'пко':U
          , input 'факт,разрешен,новый':U
          , input 'форма N КО-1'
          , input 'doc,rubl,base'
          , input 'rep/findocpr.p'
          , input ''
          , input '-'
          , input ''
          , input 'HTML'
          , input ''
      ).
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'рко':U
          , input 'факт,разрешен,новый':U
          , input 'Заявка на оплату'
          , input 'doc,rubl,base'
          , input 'rep/prn-zay.p'
          , input 'plat,yes'
          , input '-'
          , input ''
          , input 'A4port'
          , input ''
      ).
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'рко':U
          , input 'факт,разрешен,новый':U
          , input 'форма N КО-2'
          , input 'doc,rubl,base'
          , input 'rep/findocpr.p'
          , input ''
          , input '-'
          , input ''
          , input 'HTML'
          , input ''
      ).
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'рко':U
          , input 'факт,разрешен,новый':U
          , input 'препроводительная ведомость'
          , input 'doc,rubl,base'
          , input 'rep/findocpr2.p'
          , input ''
          , input '-'
          , input ''
          , input 'HTML'
          , input ''
      ).
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'ппп':U
          , input 'факт,банк,разрешен,новый':U
          , input 'форма N 0401060'
          , input 'doc,rubl,base'
          , input 'rep/findocpr.p'
          , input ''
          , input '-'
          , input ''
          , input 'A4port'
          , input ''
      ).
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'рпп':U
          , input 'факт,банк,разрешен,новый':U
          , input 'форма N 0401060'
          , input 'doc,rubl,base'
          , input 'rep/findocpr.p'
          , input ''
          , input '-'
          , input ''
          , input 'A4port'
          , input ''
      ).
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'рпп':U
          , input 'факт,банк,разрешен,новый':U
          , input 'Заявка на оплату'
          , input 'doc,rubl,base'
          , input 'rep/prn-zay.p'
          , input 'plat,yes'
          , input '-'
          , input ''
          , input 'A4port'
          , input ''
      ).
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'апп':U
          , input 'факт,разрешен,новый':U
          , input 'форма АПЗ'
          , input 'doc,rubl,base'
          , input 'rep/findocpr.p'
          , input ''
          , input '-'
          , input ''
          , input 'A4port'
          , input ''
      ).
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'апр':U
          , input 'факт,разрешен,новый':U
          , input 'форма АПЗ'
          , input 'doc,rubl,base'
          , input 'rep/findocpr.p'
          , input ''
          , input '-'
          , input ''
          , input 'A4port'
          , input ''
      ).
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      run menufdoc-create-menu-item in this-procedure
        (   input xtype
          , input xstatus
          , input 'апр':U
          , input 'факт,разрешен,новый':U
          , input 'Заявка на оплату'
          , input 'doc,rubl,base'
          , input 'rep/prn-zay.p'
          , input 'plat,yes'
          , input '-'
          , input ''
          , input 'A4port'
          , input ''
      ).
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-default-printer
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-chg b-print-doc b-help i-print br-table fi-default-printer
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run local-open-query in this-procedure .
END PROCEDURE.
PROCEDURE get-call-point :
define input parameter p-tmp#list-id as integer          no-undo.
define output parameter p-call-point as character        no-undo.
define variable v-doc-type        as character    no-undo.
define variable v-doc-status      as character    no-undo.
define buffer buf_temp_form-list        for temp_form-list.
do
for buf_temp_form-list
on error undo, return error
:
  assign
  v-doc-type     = "":U
  v-doc-status   = "":U
  .
  for each buf_temp_form-list
      where buf_temp_form-list.id = Tmp#List.id
  :
    if lookup( buf_temp_form-list.fin-doc-type, v-doc-type ) = 0
    then do:
      assign
      v-doc-type = ( if v-doc-type = "":U then "":U else "_":U ) + buf_temp_form-list.fin-doc-type
      .
    end.
    if lookup( buf_temp_form-list.status_, v-doc-status ) = 0
    then do:
      assign
      v-doc-status = ( if v-doc-status = "":U then "":U else "_":U ) + buf_temp_form-list.status_
            .
    end.
  end.
  assign
  p-call-point = substitute( "&1,&2", v-doc-type, v-doc-status )
  .
end.
END PROCEDURE.
PROCEDURE get-handle-all-docs :
define output parameter p-handle as handle no-undo .
p-handle =  p-call-handle .
END PROCEDURE.
PROCEDURE get-saved-character :
define input parameter p-list           as character        no-undo.
define input parameter p-name           as character        no-undo.
define output parameter p-character     as character        no-undo.
define variable v-position    as integer      no-undo.
do
on error undo, return error
:
  assign
  v-position = lookup( p-name, p-list )
  .
  if v-position = 0
  then do:
    assign
    p-character = "":U
        .
  end.
  else do:
    if num-entries( p-list ) > v-position
    then do:
      assign
      p-character = entry( v-position + 1, p-list )
      .
    end.
    else do:
      assign
      p-character = "":U
      .
    end.
  end.
end.
END PROCEDURE.
PROCEDURE get-saved-logical :
define input parameter p-list       as character        no-undo.
define input parameter p-name       as character        no-undo.
define output parameter p-logical   as character        no-undo.
define variable v-position    as integer      no-undo.
do
on error undo, return error
:
  assign
      v-position = lookup( p-name, p-list )
  .
  if v-position = 0
  then do:
    assign
    p-logical = "  -":U
    .
  end.
  else do:
    if num-entries( p-list ) > v-position
    then do:
      assign
      p-logical = "  ":U + entry( v-position + 1, p-list )
      .
      if trim( p-logical ) = "":U
      then do:
        assign
        p-logical = "  -":U
        .
      end.
    end.
    else do:
      assign
      p-logical = "  -":U
      .
    end.
  end.
end.
END PROCEDURE.
PROCEDURE init-fields :
define variable xtype        as character    no-undo.
define variable xstatus      as character    no-undo.
define variable v-temp-char     as character    no-undo.
define variable v-par-type      as character    no-undo.
define variable v-call-point    as character    no-undo.
define variable v-doc-counter   as integer      no-undo.
define variable v-form-title    as character    no-undo.
define buffer buf_fin-doc           for ub.fin-doc.
define buffer buf_usr-flt           for ubflt.usr-flt.
do
for buf_fin-doc
  , buf_usr-flt
with frame Dialog-Frame
on error undo, return error
:
  assign
 fi-default-printer = session :printer-name
  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-menu-doc-sys-key
  ) no-error .
  for each temp_fin-doc-code
  on error undo, return error
  :
    assign
    v-doc-counter = v-doc-counter + 1
    .
    find first buf_fin-doc no-lock
          where buf_fin-doc.host-code = temp_fin-doc-code.host-code
           and  buf_fin-doc.fin-doc-code = temp_fin-doc-code.fin-doc-code
    .
    run create-menu-items1 in this-procedure (
          input buf_fin-doc.host-code
        , input buf_fin-doc.fin-doc-code
        , input buf_fin-doc.fin-doc-type
        , input buf_fin-doc.fin-ext-doc-type
        , input buf_fin-doc.status_
      ).
  end.
  if v-doc-counter = 1
  then do:
    assign
    v-form-title = substitute( "Печать документа   Тип: &1 Статус: &2  Фирма &3 вн. № &4"
        , v-menu-doc-fin-doc-type
        , v-menu-doc-status_
        , v-menu-doc-host-code
        , v-menu-doc-fin-doc-code )
    .
  end.
  else do:
    assign
    v-form-title = substitute( "Печать выбранных документов по списку" )
    .
  end.
  assign
  frame Dialog-Frame :title = v-form-title
  .
  for each Tmp#List
  :
    run get-call-point in this-procedure (
          input Tmp#List.id
        , output v-call-point
    ).
    find first buf_usr-flt no-lock
          where buf_usr-flt.user-name  = v-cntxt-userid
            and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                        , Tmp#List.blank-name
                                        , Tmp#List.sys-key
                                        , Tmp#List.sys-key-black
                                        , v-call-point )
    no-error.
    if available buf_usr-flt
    then do:
      run get-saved-logical in this-procedure (
            input buf_usr-flt.list_
          , input "type-val":U
          , output Tmp#List.type-val
      ).
      assign
      v-temp-char = "":U
      .
      run get-saved-logical in this-procedure (
            input buf_usr-flt.list_
          , input "selection":U
          , output v-temp-char
      ).
      if v-temp-char = "  +":U
      then do:
        assign
        Tmp#List.last-use = yes
        .
      end.
    end.
    else do:
      assign
      Tmp#List.type-val     = "  -":U
      .
    end.
    if Tmp#List.type-val-enabled = no
    then do:
      assign
      Tmp#List.type-val     = " ":U
      .
    end.
    if v-doc-counter > 1 then do:
      if lookup("no-print-many" ,Tmp#List.filtr )  > 0 then do:
        Tmp#List.view_ = 0.
      end.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE local-open-query :
open query br-table
for each Tmp#List no-lock
    where Tmp#List.view_ <> 0
by Tmp#List.blank-name
.
END PROCEDURE.
PROCEDURE print-docs :
define variable v-doc-type          as character    no-undo.
define variable v-status            as character    no-undo.
define variable v-form-amount       as integer      no-undo.
define variable v-user-action       as character    no-undo.
define variable v-printed           as logical      no-undo.
define buffer buf_fin-doc       for ub.fin-doc.
define buffer buf_t_tmp#list    for tmp#list.
define buffer buf_tmp#list      for tmp#list.
do
for buf_fin-doc
  , buf_t_tmp#list
  , buf_tmp#list
with frame Dialog-Frame
on error undo, return error
:
if g#quest-print = yes
then do:
  output  to value( string( session:temp-directory + "$" + string( g#report-num ) ) ) .
  output close.
End.
output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
output close.
output to value( string( session:temp-directory + "rpt" + string( g#report-num ) ) + ".txl" ) .
output close.
for each temp_form-list
by temp_form-list.fin-doc-code
on error undo, return error
:
  for each buf_tmp#list
      where buf_tmp#list.id = temp_form-list.id
  on error undo, return error
   :
    if buf_tmp#list.last-use <> no
    then do:
      find first buf_t_tmp#list no-lock
            where buf_t_tmp#list.id = temp_form-list.id
      .
      assign
      v-form-amount = v-form-amount + 1
      .
      find first buf_fin-doc
            where buf_fin-doc.host-code = temp_form-list.host-code
            and buf_fin-doc.fin-doc-code = temp_form-list.fin-doc-code
      no-lock.
      assign
      v-doc-type = buf_fin-doc.fin-doc-type
      v-status   = string( buf_fin-doc.status_  )
      .
      assign
      PrintRubl   = ( trim( buf_tmp#list.type-val    ) = "+":U )
      .
      case num-entries( buf_tmp#list.proc-param )
      :
        when 0
        then do:
          run value ( buf_tmp#list.proc-name )  (
                input parparentproc
              , input recid( buf_fin-doc )
            ).
        end.
        when 1
        then do:
          run value ( buf_tmp#list.proc-name ) (
                input parparentproc
              , input recid( buf_fin-doc )
              , input buf_tmp#list.proc-param
            ).
        end.
        when 2
        then do:
          run value ( buf_tmp#list.proc-name )  (
                input parparentproc
              , input recid( buf_fin-doc )
              , input entry( 1, buf_tmp#list.proc-param )
              , input entry( 2, buf_tmp#list.proc-param )
            ).
        end.
        when 3
        then do:
          run value ( buf_tmp#list.proc-name )  (
                input parparentproc
              , input recid( buf_fin-doc )
              , input entry( 1, buf_tmp#list.proc-param )
              , input entry( 2, buf_tmp#list.proc-param )
              , input entry( 3, buf_tmp#list.proc-param )
            ).
        end.
        when 4
        then do:
          run value ( buf_tmp#list.proc-name )  (
                  input parparentproc
                , input recid( buf_fin-doc )
                , input entry( 1, buf_tmp#list.proc-param )
                , input entry( 2, buf_tmp#list.proc-param )
                , input entry( 3, buf_tmp#list.proc-param )
                , input entry( 4, buf_tmp#list.proc-param )
            ).
        end.
        when 5
        then do:
            run value ( buf_tmp#list.proc-name )  (
                  input parparentproc
                , input recid( buf_fin-doc )
                , input entry( 1, buf_tmp#list.proc-param )
                , input entry( 2, buf_tmp#list.proc-param )
                , input entry( 3, buf_tmp#list.proc-param )
                , input entry( 4, buf_tmp#list.proc-param )
                , input entry( 5, buf_tmp#list.proc-param )
            ).
          end.
          when 6
          then do:
              run value ( buf_tmp#list.proc-name )  (
                    input parparentproc
                  , input recid( buf_fin-doc )
                  , input entry( 1, buf_tmp#list.proc-param )
                  , input entry( 2, buf_tmp#list.proc-param )
                  , input entry( 3, buf_tmp#list.proc-param )
                  , input entry( 4, buf_tmp#list.proc-param )
                  , input entry( 5, buf_tmp#list.proc-param )
                  , input entry( 6, buf_tmp#list.proc-param )
              ).
          end.
        end case.
      end.
    end.
  end.
  if g#quest-print = yes
  Then do:
    os-delete  value( string( session:temp-directory ) + "rpt" + string( g#report-num ) )
      .
    os-rename
        value(  string( session:temp-directory ) + "$" + string( g#report-num ) )
        value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) )
    .
    os-delete
          value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
      .
    os-rename
          value(  string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
          value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
      .
    find first buf_tmp#list
          where buf_tmp#list.last-use = yes
    no-error.
    if available buf_tmp#list
    then do:
      if buf_tmp#list.orient-orientation = "runexcelport":U
      or buf_tmp#list.orient-orientation = "runexcellans":U
      then do:
        os-rename
            value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
            value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".tx_" )
        .
      end.
      case buf_tmp#list.orient-orientation
      :
        when "A4port":U
        or when "runexcelport":U
        then do:
          run gbl/prnfilen.w (
                input "":U
              , input 0
              , input string( session :temp-directory )
                          + "rpt"
                          + string( g#report-num )
              , input buf_tmp#list.orient-font-num
              , output v-user-action
              , output v-printed
          ) .
        end.
        when "A4lans":U
        or when "runexcellans":U
        or when "":U
        then do:
          run gbl/prnfilen.w (
                input "":U
              , input 8
              , input string( session :temp-directory )
                          + "rpt"
                          + string( g#report-num )
              , input buf_tmp#list.orient-font-num
              , output v-user-action
              , output v-printed
          ) .
        end.
      end case.
      if buf_tmp#list.orient-orientation = "runexcelport":U
      or buf_tmp#list.orient-orientation = "runexcellans":U
      then do:
        os-rename
            value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".tx_" )
            value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
        .
      end.
    end.
  end.
  else do:
   Message 'Задание распечатано'.
  end.
end.
END PROCEDURE.
PROCEDURE reposition-browse :
do
with frame Dialog-Frame
on error undo, return error
:
  define variable v-focused-row    as integer      no-undo.
  assign
 v-focused-row     = br-table :focused-row in frame Dialog-Frame.
  .
  get next br-table.
  if available tmp#list
  then do:
    if v-focused-row >= br-table :height-chars - 4
    then do:
      br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dialog-Frame.
    end.
    else do:
      br-table :set-repositioned-row( v-focused-row + 1, "ALWAYS" ) in frame Dialog-Frame.
    end.
    reposition br-table to rowid rowid( tmp#list ) no-error.
  end.
  else do:
    get last br-table.
  end.
end.
END PROCEDURE.
PROCEDURE reposition-to-recid :
define input parameter p-ext-system-recid  as recid        no-undo.
do
on error undo, return error
:
  if p-ext-system-recid <> ?
  then do:
    reposition br-table to recid p-ext-system-recid no-error .
  end.
  do with frame Dialog-Frame
  :
    apply "entry":u to browse br-table .
  end.
end.
END PROCEDURE.
PROCEDURE save-form-parameters :
define variable v-call-point    as character    no-undo.
define buffer buf_tmp#list          for tmp#list.
define buffer buf_usr-flt           for ubflt.usr-flt.
define buffer buf_temp_form-list    for temp_form-list.
do
for buf_tmp#list
  , buf_usr-flt
  , buf_temp_form-list
on error undo, return error
:
  for each buf_tmp#list
  :
    run get-call-point in this-procedure (
          input buf_tmp#list.id
        , output v-call-point
    ).
    find first buf_usr-flt exclusive-lock
          where buf_usr-flt.user-name  = v-cntxt-userid
            and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                        , buf_tmp#list.blank-name
                                        , buf_tmp#list.sys-key
                                        , buf_tmp#list.sys-key-black
                                        , v-call-point )
    no-error.
    if not available buf_usr-flt
    then do:
      create buf_usr-flt.
      assign
      buf_usr-flt.user-name  = v-cntxt-userid
      buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                  , buf_tmp#list.blank-name
                                  , buf_tmp#list.sys-key
                                  , buf_tmp#list.sys-key-black
                                  , v-call-point )
      .
    end.
    assign
    buf_usr-flt.list_ = substitute( "selection,&1,type-val,&2":U
                            , ( if buf_tmp#list.last-use = yes then "+":U else "-":U )
                            , ( if index( buf_tmp#list.type-val   , "+":U ) <> 0 then "+":U else "-":U )
                            )
    .
  end.
end.
END PROCEDURE.
PROCEDURE select-or-deselect-item :
define input  parameter p-id as integer    no-undo.
define buffer buf_tmp#list for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
  find first buf_tmp#list
        where buf_tmp#list.id = p-id
  .
  if buf_tmp#list.last-use = yes
  then do:
    assign
    buf_tmp#list.last-use = no
    .
  end.
  else do:
    assign
    buf_tmp#list.last-use = yes
    .
  end.
end.
END PROCEDURE.
PROCEDURE test-temp-tables :
    define buffer buf_t_tmp#list      for tmp#list.
do
for buf_t_tmp#list
on error undo, return error
:
  output to "D:\111.txt".
  for each temp_fin-doc-code no-lock
  :
    put unformatted
    skip substitute( "&1", temp_fin-doc-code.fin-doc-code )
    .
  end.
  put unformatted
  skip "================================================================================"
  .
  for each temp_form-list no-lock
  on error undo, return error
  :
    find first buf_t_tmp#list no-lock
          where buf_t_tmp#list.id = temp_form-list.id
    .
    put unformatted
    skip substitute( "&1 &2 &3 &4 &5 &6", temp_form-list.fin-doc-code, temp_form-list.fin-doc-type, temp_form-list.status_, temp_form-list.id, buf_t_tmp#list.blank-name, buf_t_tmp#list.last-use )
    .
  end.
  put unformatted
  skip "================================================================================"
  .
  for each temp_menu-doc_disabled-doc-list no-lock
  on error undo, return error
  :
    put unformatted
    skip substitute( "&1 &2 &3", temp_menu-doc_disabled-doc-list.fin-doc-code, temp_menu-doc_disabled-doc-list.blank-name, temp_menu-doc_disabled-doc-list.reason )
    .
  end.
  output close.
end.
END PROCEDURE.
PROCEDURE ui-disable-all :
do
on error undo, return error
:
end.
END PROCEDURE.
PROCEDURE ui-enable :
define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
  enable
  b-sel
  b-deselect
  with frame Dialog-Frame .
  Tmp#List.blank-name:width in browse br-table = 53.
  Tmp#List.blank-name:resizable in browse br-table = yes.
end.
END PROCEDURE.
