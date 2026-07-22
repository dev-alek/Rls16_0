define input parameter parparentproc as widget-handle no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream imp-str.
define variable v-list        as character no-undo .
DEFINE VARIABLE v-ok          AS logical   no-undo .
define variable char-gds-code as character no-undo .
define variable unit-rec      as recid     no-undo .
define variable v-rid         as recid     no-undo .
define variable agnt-list     as character no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_goods    for ub.goods .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_gds-prt  for ub.gds-prt .
DEFINE BUTTON b-goods
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-goods-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор договора".
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 11 BY 1.
DEFINE BUTTON b-unit
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 11 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Привязать"
     SIZE 11 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-goods AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 30 BY 4 NO-UNDO.
DEFINE VARIABLE f-index AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Коэффициент"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-unit AS CHARACTER FORMAT "X(256)":U
     LABEL "Единица измерения"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 12
     b-help AT ROW 1 COL 52 WIDGET-ID 2
     f-unit AT ROW 4 COL 24 COLON-ALIGNED WIDGET-ID 4
     b-unit AT ROW 4.08 COL 40.25 WIDGET-ID 60
     f-goods AT ROW 5.25 COL 26 NO-LABEL WIDGET-ID 70
     b-goods AT ROW 5.25 COL 56.5 WIDGET-ID 64
     b-goods-contract AT ROW 6.25 COL 56.5 WIDGET-ID 72
     f-index AT ROW 9.54 COL 24 COLON-ALIGNED WIDGET-ID 14
     "Список товаров:" VIEW-AS TEXT
          SIZE 15.5 BY .67 AT ROW 5.46 COL 9.88 WIDGET-ID 68
     SPACE(38.36) SKIP(7.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязать ед.изм. к товарам"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
      APPLY "END-ERROR":U TO SELF.
   END.
ON CHOOSE OF b-goods IN FRAME Dialog-Frame
DO:
      define variable i as integer no-undo .
      assign f-goods .
      run ref/gds-ref.p (parparentproc, 'b-sel,b-mark', ?, ?, ?, ?, ?, ?, ?, v-cntxt-obj-type, v-cntxt-obj-code, ?, output v-list) no-error.
      if error-status:error or v-list = ? or v-list = "" then
      do:
         message "Ошибка при выборе товара для добавления в справочник." view-as alert-box.
         return no-apply.
      end.
      v-ok = false.
      repeat i = 1 to num-entries (v-list) :
         for first ub.goods no-lock where recid(ub.goods) =  integer (entry (i, v-list))
            :
         if lookup(string(ub.goods.gds-code),char-gds-code) = 0 then do:
            f-goods = f-goods + "," + chr(10) + string(ub.goods.gds-name).
            char-gds-code = char-gds-code + "," + string(ub.goods.gds-code).
         end.
         end.
         f-goods = trim(f-goods, "," + chr(10)) .
         char-gds-code = trim(char-gds-code,",") .
      end.
      display f-goods with frame Dialog-Frame .
   end.
ON CHOOSE OF b-goods-contract IN FRAME Dialog-Frame
DO:
      define variable i as integer no-undo .
      define buffer buf_contract for ub.contract .
      define buffer buf_contract-specif for ub.contract-specif .
      assign f-goods .
      run str/cont-all.w ( input  parParentProc,
                           input v-cntxt-host-code-obj,
                           input "b-sel,b-mark":U,
                           input 'все':U,
                           input ?,
                           input ?,
                           input  ?,
                           input  ?,
                           input  "current",
                           input "all" ,
                           input-output agnt-list   ) no-error .
      if error-status:error or agnt-list = ? or agnt-list = "" then
      do:
         message "Ошибка при выборе договора для добавления в справочник." view-as alert-box.
         return no-apply.
      end.
      v-ok = false.
      repeat i = 1 to num-entries (agnt-list) :
         for first buf_contract no-lock where recid(buf_contract) = integer (entry (i, agnt-list)):
            for each buf_contract-specif no-lock where buf_contract-specif.host-code = buf_contract.host-code and
                                                       buf_contract-specif.contract-num = buf_contract.contract-code,
               first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code:
            if lookup(string(buf_goods.gds-code),char-gds-code) = 0 then do:
            f-goods = f-goods + "," + chr(10) + string(buf_goods.gds-name).
            char-gds-code = char-gds-code + "," + string(buf_goods.gds-code).
            end .
         end.
         end.
         f-goods = trim(f-goods, "," + chr(10)) .
         char-gds-code = trim(char-gds-code,",") .
      end.
      display f-goods with frame Dialog-Frame .
   end.
ON CHOOSE OF b-unit IN FRAME Dialog-Frame
DO:
      assign f-unit .
      run ref/units.w ( input parparentproc
         , input yes
         , output unit-rec ).
      for first ub.units no-lock where recid(ub.units) = unit-rec:
         f-unit:screen-value = ub.units.unit-name .
      end.
      assign f-unit .
   END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
      if f-unit = "" or f-goods = "" or f-index = 0 then
      do:
         message "Не все данные заполнены"
            view-as alert-box.
         return no-apply .
      end.
      run proc-create no-error .
      if error-status:error then
      do:
         message "Ошибка привязки"
            view-as alert-box.
      end.
   END.
ON LEAVE OF f-index IN FRAME Dialog-Frame
DO:
      assign f-index .
   END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
   THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   RUN enable_UI.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-unit f-goods f-index
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help b-unit f-goods b-goods b-goods-contract
         f-index
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-create :
   define variable ii   as integer no-undo .
   define variable v-ok as logical no-undo .
   do ii = 1 to num-entries (char-gds-code) :
      for first buf_goods no-lock where buf_goods.gds-code =  integer (entry (ii, char-gds-code)):
         find first buf_bar-code exclusive-lock where buf_bar-code.gds-code = buf_goods.gds-code and
            buf_bar-code.unit-cli = f-unit no-error .
         if available (buf_bar-code) then
         do:
            message "К товару " + buf_goods.gds-name + " уже привязана единица измерения " + f-unit skip
               "с коэффициентом пересчета " + string(buf_bar-code.cli-base-rate) skip
               "Установить коэффициент " + string(f-index) skip
               view-as alert-box question buttons yes-no update v-ok .
            if v-ok then
            do:
               buf_bar-code.cli-base-rate = f-index .
            end.
            end.
            else
            do:
               for first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code:
                  run ref/barcode1.p (
                     input 'ДОБАВЛЕНИЕ':U
                     ,input no
                     ,input 0
                     ,input buf_goods.gds-code
                     ,input buf_bar-code.node-code
                     ,input buf_bar-code.part-code
                     ,input buf_bar-code.in-code
                     ,input f-unit
                     ,input f-index
                     ,output v-rid) no-error.
               end.
            end.
         end.
   end.
END PROCEDURE.
