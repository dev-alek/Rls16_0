 define  temp-table temp-list-buyer no-undo ~
field obj-type as character ~
field obj-code as integer   ~
index pi is primary unique  ~
obj-type ~
obj-code.
define input parameter ParParentProc as handle NO-UNDO.
DEFINE input-output parameter IOP-SupGds  AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-SupCons AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-SupServ AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-BuyGds  AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-BuyCons AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-BuyServ AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-WLim-kr AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-GRP     AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-TURN    AS LOGICAL NO-UNDO.
DEFINE input-output parameter p-sum-1     as character no-undo .
DEFINE input-output parameter p-sum-2     as character no-undo .
DEFINE input-output parameter p-gr-name   as character no-undo .
define input-output parameter p-grp-buyer-id     as integer   no-undo .
define input-output parameter p-grp-buyer-db-num as integer   no-undo .
define input-output parameter table for temp-list-buyer .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание условий выборки клиентов".
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
define variable log-res            as logical no-undo .
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-grp-buyer AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-sum-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 17.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-sum-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 70 BY 5.5.
DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 70 BY 2.77.
DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 70 BY 2.7
     BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE BuyCons AS LOGICAL INITIAL yes
     LABEL "Товары - на консигнацию"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1 NO-UNDO.
DEFINE VARIABLE BuyGds AS LOGICAL INITIAL yes
     LABEL "Товары - выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 17.9 BY 1 NO-UNDO.
DEFINE VARIABLE BuyServ AS LOGICAL INITIAL yes
     LABEL "Услуги"
     VIEW-AS TOGGLE-BOX
     SIZE 10 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE SupCons AS LOGICAL INITIAL yes
     LABEL "Товары - на консигнацию"
     VIEW-AS TOGGLE-BOX
     SIZE 24.5 BY .8 NO-UNDO.
DEFINE VARIABLE SupGds AS LOGICAL INITIAL yes
     LABEL "Товары - выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 16.5 BY .8 NO-UNDO.
DEFINE VARIABLE SupServ AS LOGICAL INITIAL yes
     LABEL "Услуги"
     VIEW-AS TOGGLE-BOX
     SIZE 9.6 BY .8 NO-UNDO.
DEFINE VARIABLE T-grp AS LOGICAL INITIAL no
     LABEL "По группе покупателей"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .67 NO-UNDO.
DEFINE VARIABLE T-oborot AS LOGICAL INITIAL no
     LABEL "По обороту покупателя"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .67 NO-UNDO.
DEFINE VARIABLE WLim-kr AS LOGICAL INITIAL no
     LABEL "Ненулевой лимит кредита"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.
DEFINE FRAME DLGOKCAN
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     SupGds AT ROW 4.7 COL 4.8
     SupCons AT ROW 4.7 COL 22.5
     SupServ AT ROW 4.7 COL 49.3
     BuyGds AT ROW 7.77 COL 5
     BuyCons AT ROW 8.93 COL 5
     BuyServ AT ROW 10.07 COL 5
     WLim-kr AT ROW 10.07 COL 35.8
     T-oborot AT ROW 13 COL 5
     T-grp AT ROW 14.27 COL 5
     v-sum-1 AT ROW 13 COL 28.5 COLON-ALIGNED NO-LABEL
     v-sum-2 AT ROW 13 COL 47 COLON-ALIGNED NO-LABEL
     v-grp-buyer AT ROW 14.27 COL 29 COLON-ALIGNED NO-LABEL
     "Поставщики :" VIEW-AS TEXT
          SIZE 12.8 BY 1 AT ROW 3.77 COL 27.4
          BGCOLOR 8 FGCOLOR 4
     "Условия объединяются по ~"Или~"" VIEW-AS TEXT
          SIZE 32.3 BY 1 AT ROW 2.27 COL 20.4
          FGCOLOR 1
     "Покупатели :" VIEW-AS TEXT
          SIZE 13.5 BY 1 AT ROW 6.27 COL 27.4
          BGCOLOR 8 FGCOLOR 4
     "Условия объединяются по ~"И~"" VIEW-AS TEXT
          SIZE 30 BY .67 AT ROW 11.77 COL 21.9
          FGCOLOR 1
     RECT-9 AT ROW 3.27 COL 1
     RECT-21 AT ROW 6 COL 1
     RECT-23 AT ROW 12.77 COL 1
     SPACE(0.74) SKIP(3.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 1 "Фильтры":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE
       FRAME DLGOKCAN:PRIVATE-DATA     =
                "DLGCLOSE".
ASSIGN
       SupServ:HIDDEN IN FRAME DLGOKCAN           = TRUE.
ON CHOOSE OF Btn_Cancel IN FRAME DLGOKCAN
DO:
    return "NO" .
END.
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN
DO:
    if IOP-WLim-kr <> ? then
        do:
            assign WLim-kr .
            IOP-WLim-kr = WLim-kr .
        end.
    if IOP-SupGds <> ? then
        do:
            assign SupGds .
            IOP-SupGds = SupGds .
        end.
    if IOP-SupCons <> ? then
        do:
            assign SupCons .
            IOP-SupCons = SupCons .
        end.
    if IOP-BuyGds <> ? then
        do:
            assign BuyGds .
            IOP-BuyGds = BuyGds .
        end.
    if IOP-BuyCons <> ? then
        do:
            assign BuyCons .
            IOP-BuyCons = BuyCons .
        end.
    if IOP-BuyServ <> ? then
        do:
            assign BuyServ .
            IOP-BuyServ = BuyServ .
        end.
    assign
      frame DLGOKCAN t-grp  T-oborot
      IOP-GRP   =  t-grp
      IOP-TURN  =  T-oborot
      p-sum-1   =  v-sum-1
      p-sum-2   =  v-sum-2
      p-gr-name =  v-grp-buyer
    .
    Run remake-tt.
    return "OK" .
END.
ON VALUE-CHANGED OF BuyCons IN FRAME DLGOKCAN
DO:
    assign BuyCons .
END.
ON VALUE-CHANGED OF BuyGds IN FRAME DLGOKCAN
DO:
    assign BuyGds .
END.
ON VALUE-CHANGED OF BuyServ IN FRAME DLGOKCAN
DO:
    assign BuyServ .
END.
ON VALUE-CHANGED OF SupCons IN FRAME DLGOKCAN
DO:
    assign SupCons .
END.
ON VALUE-CHANGED OF SupGds IN FRAME DLGOKCAN
DO:
    assign SupGds .
END.
ON VALUE-CHANGED OF SupServ IN FRAME DLGOKCAN
DO:
    assign SupServ .
END.
ON VALUE-CHANGED OF T-grp IN FRAME DLGOKCAN
DO:
define variable p-recids as character no-undo .
define buffer buf_buyer-group for ub.buyer-group  .
p-grp-buyer-id     = ? .
p-grp-buyer-db-num = ? .
  ASSIGN t-grp .
  v-grp-buyer = "" .
  if t-grp = true then do:
      run ref/gr-bupr.w ( ParParentProc, "b-sel" , input-output p-recids ) .
      find first buf_buyer-group no-lock where recid (buf_buyer-group) = integer(p-recids) no-error .
      if error-status :error then do:
        t-grp = false .
        DISPLAY v-grp-buyer t-grp with FRAME DLGOKCAN.
        return no-apply.
      end.
      v-grp-buyer        = buf_buyer-group.name .
      p-grp-buyer-id     = buf_buyer-group.bgr-id .
      p-grp-buyer-db-num = buf_buyer-group.bgr-db-num .
  end.
  DISPLAY v-grp-buyer  t-grp  with FRAME DLGOKCAN.
END.
ON VALUE-CHANGED OF T-oborot IN FRAME DLGOKCAN
DO:
define variable vs-sum-1 as decimal   no-undo .
define variable vs-sum-2 as decimal   no-undo .
  ASSIGN t-oborot.
  v-sum-1 = "" .
  v-sum-2 = "" .
  IF t-oborot = false  THEN do:
     for each temp-list-buyer : delete temp-list-buyer. end.
  end.
  IF t-oborot = true  THEN
  run str/two-sum.w (
      input ('sums-calc'),
      input-OUTPUT vs-sum-1 ,
      input-OUTPUT vs-sum-2,
      OUTPUT TABLE temp-list-buyer ).
IF t-oborot THEN do:
   v-sum-1 = "c " + string( vs-sum-1 ) .
if vs-sum-2 <> ? then  v-sum-2 = "по " + string( vs-sum-2 ) .
                  else v-sum-2 = " ..."  .
end.
else do:
  v-sum-1 = "" .
  v-sum-2 = "" .
end.
DISPLAY  v-sum-1
        v-sum-2 with FRAME DLGOKCAN.
END.
ON VALUE-CHANGED OF WLim-kr IN FRAME DLGOKCAN
DO:
    assign    WLim-kr .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
    assign
        SupGds = IOP-SupGds
        SupCons = ( if IOP-SupCons <> ? then IOP-SupCons else FALSE )
        SupServ = ( if IOP-SupServ <> ? then IOP-SupServ else FALSE )
        BuyGds = IOP-BuyGds
        BuyCons = ( if IOP-BuyCons <> ? then IOP-BuyCons else FALSE )
        BuyServ = ( if IOP-BuyServ <> ? then IOP-BuyServ else FALSE )
        WLim-kr = ( if IOP-WLim-kr <> ? then IOP-WLim-kr else FALSE )
        T-grp   = ( if IOP-GRP <> ? then IOP-GRP else FALSE )
        T-oborot   = ( if  IOP-TURN  <> ? then  IOP-TURN  else FALSE )
        .
if T-oborot = true then do:
                  assign
                    v-sum-1 =  p-sum-1
                    v-sum-2 =  p-sum-2
                  .
    display v-sum-1  v-sum-2  with frame DLGOKCAN .
end.
if T-grp = true then do:
                  assign
                    v-grp-buyer =  p-gr-name
                  .
    display v-grp-buyer  with frame DLGOKCAN .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN enable_UI.
    WAIT-FOR GO OF FRAME DLGOKCAN.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY SupGds SupCons BuyGds BuyCons BuyServ WLim-kr T-oborot T-grp
          v-sum-1 v-sum-2 v-grp-buyer
      WITH FRAME DLGOKCAN.
  ENABLE Btn_OK RECT-9 RECT-21 Btn_Cancel b-help SupGds SupCons BuyGds
         BuyCons BuyServ WLim-kr T-oborot T-grp v-sum-1 v-sum-2 v-grp-buyer
      WITH FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE remake-tt :
define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
if iop-turn = true and iop-grp = true then do:
    for each temp-list-buyer :
        find first buf_buyer-in-buyer-group no-lock where
                  buf_buyer-in-buyer-group.stts       = 0      and
                  buf_buyer-in-buyer-group.bbg-obj-type = temp-list-buyer.obj-type and
                  buf_buyer-in-buyer-group.bbg-obj-code = temp-list-buyer.obj-code and
                  buf_buyer-in-buyer-group.bgr-id       = p-grp-buyer-id      and
                  buf_buyer-in-buyer-group.bgr-db-num   = p-grp-buyer-db-num
                  no-error .
        if not available buf_buyer-in-buyer-group then delete temp-list-buyer .
    end.
end.
if iop-turn = false and iop-grp = true then do:
    for each temp-list-buyer : delete temp-list-buyer. end.
    for each  buf_buyer-in-buyer-group no-lock where
              buf_buyer-in-buyer-group.stts       = 0      and
              buf_buyer-in-buyer-group.bgr-id     = p-grp-buyer-id      and
              buf_buyer-in-buyer-group.bgr-db-num = p-grp-buyer-db-num  :
        create temp-list-buyer .
          assign
            temp-list-buyer.obj-type = buf_buyer-in-buyer-group.bbg-obj-type
            temp-list-buyer.obj-code = buf_buyer-in-buyer-group.bbg-obj-code
          .
    end.
end.
END PROCEDURE.
