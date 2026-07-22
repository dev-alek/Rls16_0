DEFINE TEMP-TABLE tt-tax-rate NO-UNDO LIKE ub.tax-rate.
def input parameter ref-mode as char no-undo.
def input-output param rid as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка ставки налога" .
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
define variable taxcode like ub.tax.tax-code no-undo.
define buffer buf_tax-rate-attr for ub.tax-rate-attr .
define VARIABLE v-envd-old as LOGICAL NO-UNDO .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE T-envd AS LOGICAL INITIAL no
     LABEL "без НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE QUERY d-add-tax-rate FOR
      tt-tax-rate SCROLLING.
DEFINE FRAME d-add-tax-rate
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 40
     T-envd AT ROW 3.08 COL 42 WIDGET-ID 2
     tt-tax-rate.tax-code AT ROW 3.13 COL 21.88 COLON-ALIGNED
          LABEL "Код вида налога"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-tax-rate.rate-code AT ROW 4.42 COL 21.88 COLON-ALIGNED
          LABEL "Код ставки налога" FORMAT ">>>>>9"
          VIEW-AS FILL-IN
          SIZE 9.88 BY 1
     tt-tax-rate.rate-name AT ROW 5.71 COL 21.88 COLON-ALIGNED
          LABEL "Название ставки"
          VIEW-AS FILL-IN
          SIZE 30.5 BY 1
     SPACE(0.99) SKIP(1.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ставка налога"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-add-tax-rate:SCROLLABLE       = FALSE
       FRAME d-add-tax-rate:HIDDEN           = TRUE.
ON GO OF FRAME d-add-tax-rate
DO:
  find first tt-tax-rate No-ERROR.
 if not avail tt-tax-rate then create tt-tax-rate.
 assign
 tt-tax-rate.rate-code
 tt-tax-rate.rate-name
 tt-tax-rate.tax-code
 .
 if v-envd-old <> t-envd then do:
     find first buf_tax-rate-attr where buf_tax-rate-attr.tax-code = tt-tax-rate.tax-code
                                    and buf_tax-rate-attr.attr-code = "envd" no-error .
        if AVAILABLE buf_tax-rate-attr then do:
                 if t-envd then do:
                     MESSAGE SUBSTITUTE ("У кода ставки налога &1, уже есть атрибут без НДС", buf_tax-rate-attr.rate-code)
                     VIEW-AS ALERT-BOX.
                 end.
                 else do:
                    delete buf_tax-rate-attr.
                 end.
        end.
        else do:
                     create buf_tax-rate-attr .
                     assign
                        buf_tax-rate-attr.tax-code = tt-tax-rate.tax-code
                        buf_tax-rate-attr.attr-code = "envd"
                        buf_tax-rate-attr.rate-code = tt-tax-rate.rate-code
                     .
        end.
  end.
 run ref/taxrati1.p
 ( input-output rid
 , input ref-mode
 , input no
 , input taxcode
 , input tt-tax-rate.rate-code
 , input tt-tax-rate.rate-name
 , input tt-tax-rate.status_
 ) no-error.
  if error-status:error then do:
        if return-value = "":U then return no-apply.
    case return-value:
            when "rate-name":U then do:
                APPLY "ENTRY" to tt-tax-rate.rate-name.
            end.
            when "rate-code":U then do:
                 APPLY "ENTRY" to tt-tax-rate.rate-code.
            end.
        end.
    return no-apply.
  end.
 END.
ON WINDOW-CLOSE OF FRAME d-add-tax-rate
DO:
  rid = ?.
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-quit IN FRAME d-add-tax-rate
DO:
  rid = ?.
END.
ON VALUE-CHANGED OF T-envd IN FRAME d-add-tax-rate
DO:
    IF T-envd:checked then do:
            assign T-envd
            .
     end.
     else t-envd = no.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-add-tax-rate:PARENT eq ?
THEN FRAME d-add-tax-rate:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-add-tax-rate
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
on choose of b-help in frame d-add-tax-rate
do:
  apply "help":u to frame d-add-tax-rate .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-add-tax-rate:width - 0.3
                fh            = frame d-add-tax-rate:first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if ref-mode <> 'ИЗМЕНЕНИЕ':U and ref-mode <> 'ДОБАВЛЕНИЕ':U then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова ref-mode"
        view-as alert-box ERROR.
        return error.
    end.
  IF ref-mode = 'ДОБАВЛЕНИЕ':U then do:
    FIND FIRST ub.tax Exclusive-LOCK WHERE recid(ub.tax) = rid No-WAIT no-error.
    if locked tax then do:
      message vss-workfile vss-revision vss-description skip
              "Запись налога занята"
      view-as alert-box error .
      return error.
    end.
    IF NOT AVAIL tax then do:
      message vss-workfile vss-revision vss-description skip
              "Запись налога не найдена"
      view-as alert-box error .
      return error.
    end.
    assign
    taxcode =  tax.tax-code.
  end.
  else do:
    FIND FIRST ub.tax-rate EXclusive-lock WHERE recid(ub.tax-rate) = rid no-wait no-error .
    if locked ub.tax-rate then do:
      message vss-workfile vss-revision vss-description skip
              "Запись ставки налога занята"
      view-as alert-box error .
      return error.
    end.
    IF NOT AVAIL tax-rate then do:
      message vss-workfile vss-revision vss-description skip
              "Запись ставки налога не найдена"
      view-as alert-box error .
      return error.
    end.
    if tax-rate.status_ = 'удал':U then do:
      message "Ставка удалена - изменение невозможно"
      view-as alert-box ERROR.
      return error.
    end.
    for each tt-tax-rate:
            delete tt-tax-rate.
        end.
        create tt-tax-rate.
        buffer-copy tax-rate to tt-tax-rate.
  end.
  RUN MyEnable.
  WAIT-FOR GO OF FRAME d-add-tax-rate.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-add-tax-rate.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY d-add-tax-rate FOR EACH tt-tax-rate SHARE-LOCK.
  GET FIRST d-add-tax-rate.
  DISPLAY T-envd
      WITH FRAME d-add-tax-rate.
  IF AVAILABLE tt-tax-rate THEN
    DISPLAY tt-tax-rate.tax-code tt-tax-rate.rate-code tt-tax-rate.rate-name
      WITH FRAME d-add-tax-rate.
  ENABLE b-exit b-quit B-help T-envd tt-tax-rate.rate-code
         tt-tax-rate.rate-name
      WITH FRAME d-add-tax-rate.
  VIEW FRAME d-add-tax-rate.
END PROCEDURE.
PROCEDURE MyEnable :
  IF AVAILABLE tt-tax-rate THEN
    DISPLAY
    tt-tax-rate.tax-code
    tt-tax-rate.rate-code
    tt-tax-rate.rate-name
    WITH FRAME D-add-tax-rate.
  find first buf_tax-rate-attr where buf_tax-rate-attr.tax-code = tt-tax-rate.tax-code
                                    and buf_tax-rate-attr.rate-code = tt-tax-rate.rate-code
                                    and buf_tax-rate-attr.attr-code = "envd" no-error .
    if AVAILABLE buf_tax-rate-attr then do:
     T-envd = yes.
     v-envd-old = yes.
    end.
  ENABLE
  B-exit
  B-quit
  B-Help
  tt-tax-rate.rate-name
  T-envd
  WITH FRAME D-add-tax-rate.
  VIEW FRAME D-add-tax-rate.
  display t-envd with frame d-add-tax-rate.
  ENABLE
  tt-tax-rate.rate-code when ref-mode = 'ДОБАВЛЕНИЕ':U
  WITH FRAME d-add-tax-rate.
  IF ref-mode = 'ИЗМЕНЕНИЕ':U then do:
      FRAME d-add-tax-rate:title = "Изменение ставки налога".
      DISPLAY
      tt-tax-rate.tax-code
      tt-tax-rate.rate-code
      tt-tax-rate.rate-name
      WITH frame d-add-tax-rate.
  END.
  ELSE do:
    DISPLAY
    taxcode @ tt-tax-rate.tax-code
    WITH frame d-add-tax-rate.
  END.
END PROCEDURE.
