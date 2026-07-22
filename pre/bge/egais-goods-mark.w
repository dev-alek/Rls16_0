using ibs.th.bge.egais.*.
define input  parameter parparentproc as handle no-undo.
define input  parameter p-mode     as character   no-undo.
define input-output  parameter p-alc-code as character   no-undo.
define input-output parameter p-gds-code like ub.goods.gds-code  no-undo.
define output parameter p-gds-name like ub.goods.gds-name  no-undo.
define output parameter p-prod-full-name as character  no-undo.
define output parameter p-import-full-name as character  no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары ЕГАИС".
define temp-table tt-goods no-undo
  field gds-code         like goods.gds-code
  field artic            like goods.artic
  field gds-name         like goods.gds-name
  field alc-code         as character label "Алког.код"
  field import-full-name as character label "Импортер"
  field prod-full-name   as character label "Производитель"
  field CliRegIdProd     as character
  field INNProd          as character
  field KPPProd          as character
  field FullNameProd     as character
  field CountryProd      as character
  field CliRegIdImpor    as character
  field INNImpor         as character
  field KPPImpor         as character
  field FullNameImpor    as character
  field CountryImpor     as character
  index pi as primary unique gds-code alc-code .
define variable extGdsObj      as class     extgds no-undo.
define variable ii             as integer   no-undo .
define variable v-gds-code     as integer   no-undo .
define variable v-gds-code-old as integer   no-undo .
define variable v-alc-code-old as character no-undo .
define variable v-gds-name     as character no-undo .
define variable v-gds-name1    as character no-undo .
define variable v-prod-name    as character no-undo .
define variable v-prod-name1   as character no-undo .
define variable v-imp-name     as character no-undo .
define variable v-imp-name1    as character no-undo .
define variable glog           as logical   no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
FUNCTION Base2Int64 RETURNS INT64 ( INPUT i-hex AS CHARACTER, INPUT i-base AS INTEGER ) :
  DEFINE VARIABLE j_num AS INT64 NO-UNDO.
  RUN conv-base-to-int64 IN THIS-PROCEDURE ( INPUT i-hex, INPUT i-base, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION.
PROCEDURE conv-base-to-int64 :
  DEFINE  INPUT PARAMETER p-num  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-base AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int  AS INT64     NO-UNDO.
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_sign AS INT64   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-base > 60 THEN DO:
      ASSIGN p-int = ?.
      UNDO, RETURN ERROR.
    END.
    ASSIGN v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U +
                    'Б,Г,Д,Ё,Ж,З,И,Й,Л,П,У,Ф,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,@,$':U
           v_list = SUBSTRING( v_list, 1, p-base * 2 - 1 )
           p-num  = TRIM( p-num ).
    IF SUBSTRING( p-num, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-num  = SUBSTRING( p-num, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-num ) :
      ASSIGN p-int = p-int * p-base + LOOKUP( SUBSTRING( p-num, jj, 1 ), v_list ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END.
END PROCEDURE.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ProcAlcCode :
  define input  parameter p-mark-alc as character  no-undo .
  define output parameter p-alc-code as character  no-undo initial ''.
  define output parameter p-error as logical no-undo initial no.
  define output parameter p-error-lang as logical no-undo initial no.
  define variable v-kol              as integer    no-undo .
  define variable v-alc-code as character no-undo .
  define variable v-result as character no-undo .
  define variable ii as integer no-undo .
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  ASSIGN
    v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U .
  v-alc-code = SUBSTRing (p-mark-alc, 8, 12) .
  do ii = 1 to length (v-alc-code):
    if LOOKUP( SUBSTRING( v-alc-code, ii, 1 ), v_list )  < 1 then
    do:
      p-error-lang = yes .
      leave .
    end.
  end.
  p-alc-code = string (Base2Int64 (v-alc-code, 36) ) no-error.
  if (Base2Int64 (v-alc-code, 36) ) < 0 then
  do:
    p-error = yes.
  end.
  else
  do:
    if length(p-alc-code) < 20 then
    do:
      p-alc-code = fill('0', 19 - length(p-alc-code)) + p-alc-code.
    end.
  end.
END PROCEDURE.
PROCEDURE ProcFindGds  :
  define input  parameter p-alc-code as character  no-undo .
  define output parameter p-gds-code as integer    no-undo .
  define buffer x_ext-classif        for ub.ext-classif .
      find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.CharKey_One = p-alc-code
                                               no-error.
      if available x_ext-classif then p-gds-code = X_ext-classif.Key#_One.
END PROCEDURE.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE BUTTON Btn_add
     LABEL "Добавить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_del
     LABEL "Удалить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE v-AlcCode AS CHARACTER FORMAT "X(256)":U
     LABEL "Алк.код"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-CliRegIdImpor AS CHARACTER FORMAT "X(256)":U
     LABEL "Рег.ID"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-CliRegIdProd AS CHARACTER FORMAT "X(256)":U
     LABEL "Рег.ID"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-CountryImpor AS CHARACTER FORMAT "X(256)":U
     LABEL "Город"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-CountryProd AS CHARACTER FORMAT "X(256)":U
     LABEL "Город"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-FullNameGds AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-FullNameGds-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-FullNameImpor AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-FullNameImpor-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-FullNameProd AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-FullNameProd-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-GdsCode AS CHARACTER FORMAT "X(256)":U
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-INNImpor AS CHARACTER FORMAT "X(256)":U
     LABEL "ИНН"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-INNProd AS CHARACTER FORMAT "X(256)":U
     LABEL "ИНН"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-KPPImpor AS CHARACTER FORMAT "X(256)":U
     LABEL "КПП"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-KPPProd AS CHARACTER FORMAT "X(256)":U
     LABEL "КПП"
     VIEW-AS FILL-IN
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40 BY 7.75.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40 BY 7.75.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40 BY 7.75.
  DEFINE QUERY br-goods FOR
    tt-goods SCROLLING.
  DEFINE BROWSE br-goods
    QUERY br-goods  DISPLAY
    tt-goods.gds-code
    WIDTH 20
    tt-goods.artic
    WIDTH 20
    tt-goods.gds-name
    WIDTH 30
    tt-goods.alc-code format "X(256)"
    WIDTH 30
    tt-goods.import-full-name format "X(256)"
    WIDTH 30
    tt-goods.prod-full-name format "X(256)"
    WIDTH 30
    WITH NO-ROW-MARKERS SEPARATORS SIZE 121 BY 14.5 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 16.5
     Btn_add AT ROW 1.25 COL 31.5 WIDGET-ID 4
     Btn_del AT ROW 1.25 COL 46.5 WIDGET-ID 2
     br-goods AT ROW 3 COL 1.5 WIDGET-ID 200
     v-FullNameProd AT ROW 18.83 COL 2 NO-LABEL WIDGET-ID 10 AUTO-RETURN
     v-FullNameImpor AT ROW 18.83 COL 42.5 NO-LABEL WIDGET-ID 30 AUTO-RETURN
     v-FullNameGds AT ROW 18.83 COL 83 NO-LABEL WIDGET-ID 50 AUTO-RETURN
     v-FullNameProd-2 AT ROW 19.88 COL 2 NO-LABEL WIDGET-ID 52 AUTO-RETURN
     v-FullNameImpor-2 AT ROW 19.88 COL 42.5 NO-LABEL WIDGET-ID 54 AUTO-RETURN
     v-FullNameGds-2 AT ROW 19.88 COL 83 NO-LABEL WIDGET-ID 56 AUTO-RETURN
     v-CliRegIdProd AT ROW 21.38 COL 9 COLON-ALIGNED WIDGET-ID 14
     v-CliRegIdImpor AT ROW 21.38 COL 49.5 COLON-ALIGNED WIDGET-ID 26
     v-GdsCode AT ROW 21.38 COL 90 COLON-ALIGNED WIDGET-ID 40
     v-INNProd AT ROW 22.38 COL 9 COLON-ALIGNED WIDGET-ID 16
     v-INNImpor AT ROW 22.38 COL 49.5 COLON-ALIGNED WIDGET-ID 32
     v-AlcCode AT ROW 22.38 COL 90 COLON-ALIGNED WIDGET-ID 46
     v-KPPProd AT ROW 23.38 COL 9 COLON-ALIGNED WIDGET-ID 18
     v-KPPImpor AT ROW 23.38 COL 49.5 COLON-ALIGNED WIDGET-ID 34
     v-CountryProd AT ROW 24.38 COL 9 COLON-ALIGNED WIDGET-ID 20
     v-CountryImpor AT ROW 24.38 COL 49.5 COLON-ALIGNED WIDGET-ID 28
     "Товар:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 17.88 COL 83 WIDGET-ID 38
     "Импортер:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 17.88 COL 42.5 WIDGET-ID 24
     "Производитель:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 17.88 COL 2 WIDGET-ID 12
     RECT-1 AT ROW 17.75 COL 1.5 WIDGET-ID 6
     RECT-2 AT ROW 17.75 COL 42 WIDGET-ID 22
     RECT-3 AT ROW 17.75 COL 82.5 WIDGET-ID 36
     SPACE(0.87) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары ЕГАИС"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       br-goods:column-resizable IN FRAME Dialog-Frame              = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
      APPLY "END-ERROR":U TO SELF.
    END.
ON choose OF Btn_add IN FRAME Dialog-Frame
DO:
      define variable ref-list as character no-undo .
      define variable extGdsValueObjnew as class ExtGdsValue.
      define variable v-GdsCode as integer no-undo .
      define variable v-GdsCodenew as integer no-undo .
      define variable glog         as logical no-undo.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-ref':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then  return .
      run ref/gds-ref.p
        ( input parparentproc
        ,input "b-sel,b-add"
        ,input 'текущие':U
        ,input 'все':U
        ,input 'все':U
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input ?
        ,output ref-list).
      find first ub.goods where recid (ub.goods) = integer (ref-list) no-lock no-error .
      find first ub.goods-attr where ub.goods-attr.gds-code = ub.goods.gds-code and goods-attr.attr-code = "alcohol-prod" no-lock no-error .
      if available ub.goods-attr then do:
      if extGdsObj:NumBundles > 0 then
        do:
          do ii = 1 to extGdsObj:NumBundles:
            v-gds-code = extGdsObj:GetExtGdsValue(ii):GdsCode .
            v-GdsCodenew = ub.goods.gds-code .
            if v-GdsCodenew = v-Gds-Code then do:
              message "Такой товар уже есть"
              view-as alert-box.
              return no-apply.
            end.
          end.
        end.
      extGdsValueObjnew = new ExtGdsValue () .
      extGdsObj:CopyEgaisInfo(extGdsObj:GetExtGdsValue(), extGdsValueObjnew).
      extGdsValueObjnew:GdsCode = v-GdsCodenew.
      extGdsValueObjnew:AlcCode = p-alc-code.
      extGdsObj:CreateExtGds (extGdsValueObjnew).
      extGdsObj:OpenQueryExtGds(p-gds-code, p-alc-code).
      find first tt-goods where tt-goods.gds-code = extGdsValueObjnew:GdsCode and
        tt-goods.gds-name = ub.goods.gds-name and
        tt-goods.artic    = ub.goods.artic no-lock no-error.
      if not available tt-goods then do:
      create tt-goods .
        tt-goods.alc-code = extGdsValueObjnew:AlcCode .
        tt-goods.gds-code = extGdsValueObjnew:GdsCode .
        tt-goods.gds-name = ub.goods.gds-name .
        tt-goods.artic    = ub.goods.artic .
        tt-goods.import-full-name = extGdsValueObjnew:FullNameImpor .
        tt-goods.prod-full-name   = extGdsValueObjnew:FullNameProd .
        tt-goods.CliRegIdProd = extGdsValueObjnew:CliRegIdProd .
        tt-goods.CountryProd = extGdsValueObjnew:CountryProd .
        tt-goods.INNProd = extGdsValueObjnew:INNProd .
        tt-goods.KPPProd = extGdsValueObjnew:KPPProd .
        tt-goods.CliRegIdImpor = extGdsValueObjnew:CliRegIdImpor .
        tt-goods.CountryImpor = extGdsValueObjnew:CountryImpor .
        tt-goods.INNImpor = extGdsValueObjnew:INNImpor .
        tt-goods.KPPImpor = extGdsValueObjnew:KPPImpor .
        .
      end.
      end.
      else do:
        message "Товар не является алкогольным"
        view-as alert-box.
      end.
      open query br-goods for each tt-goods .
END.
ON choose OF Btn_Cancel IN FRAME Dialog-Frame
DO:
  assign
    p-alc-code = v-alc-code-old
    p-gds-code = v-gds-code-old
  .
END.
on value-changed of br-goods do:
  run local-value-changed.
end.
ON choose OF Btn_del IN FRAME Dialog-Frame
DO:
      define variable glog         as logical no-undo.
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-ref':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then  return .
      extGdsObj:DeleteExtGds (tt-goods.gds-code, p-alc-code).
      delete tt-goods.
      extGdsObj:OpenQueryExtGds(p-gds-code, p-alc-code).
      open query br-goods for each tt-goods .
END.
ON choose OF Btn_OK IN FRAME Dialog-Frame
DO:
      if available tt-goods then do:
      assign
        p-alc-code = tt-goods.alc-code
        p-gds-code = tt-goods.gds-code
        p-gds-name = tt-goods.gds-name
        p-import-full-name = tt-goods.import-full-name
        p-prod-full-name   = tt-goods.prod-full-name
        .
       end.
      RUN disable_UI.
    END.
  IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
  MAIN-BLOCK:
  DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    assign
      v-gds-code-old = p-gds-code
      v-alc-code-old = p-alc-code
    .
    RUN enable_UI.
    RUN enable_goods.
    WAIT-FOR GO OF FRAME Dialog-Frame.
  END.
  RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_goods :
  define variable extGdsValueObj  as class ExtGdsValue no-undo.
  extGdsObj = new ExtGds (true).
  extGdsObj:OpenQueryExtGds(p-gds-code, p-alc-code).
  if extGdsObj:NumBundles > 0 then
  do:
    do ii = 1 to extGdsObj:NumBundles:
      v-gds-code = extGdsObj:GetExtGdsValue(ii):GdsCode .
      find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
      if not available (ub.goods) then do:
        message "Не найден товар с кодом - " v-gds-code view-as alert-box.
      end.
      extGdsValueObj = extGdsObj:GetExtGdsValue(ii).
      create tt-goods .
      assign
        tt-goods.gds-code = extGdsValueObj:GdsCode
        tt-goods.alc-code = extGdsValueObj:AlcCode
        tt-goods.gds-name = ub.goods.gds-name
        tt-goods.artic    = ub.goods.artic
        tt-goods.import-full-name = extGdsValueObj:FullNameImpor
        tt-goods.prod-full-name   = extGdsValueObj:FullNameProd
        tt-goods.CliRegIdProd = extGdsValueObj:CliRegIdProd
        tt-goods.CountryProd = extGdsValueObj:CountryProd
        tt-goods.INNProd = extGdsValueObj:INNProd
        tt-goods.KPPProd = extGdsValueObj:KPPProd
        tt-goods.CliRegIdImpor = extGdsValueObj:CliRegIdImpor
        tt-goods.CountryImpor = extGdsValueObj:CountryImpor
        tt-goods.INNImpor = extGdsValueObj:INNImpor
        tt-goods.KPPImpor = extGdsValueObj:KPPImpor
      .
    end.
  end.
  open query br-goods for each tt-goods .
  run local-value-changed.
END PROCEDURE.
PROCEDURE local-value-changed :
  if available tt-goods then do:
    if length (tt-goods.prod-full-name) > 33 then do:
      v-prod-name = substring (tt-goods.prod-full-name,1,36,"character") .
      v-prod-name1 = substring (tt-goods.prod-full-name,37,81,"character") .
    end.
    else v-prod-name = tt-goods.prod-full-name .
    DISPLAY v-prod-name @ v-FullNameProd with frame Dialog-Frame.
    DISPLAY v-prod-name1 @ v-FullNameProd-2 with frame Dialog-Frame.
    DISPLAY tt-goods.CliRegIdProd @ v-CliRegIdProd with frame Dialog-Frame.
    DISPLAY tt-goods.CountryProd @ v-CountryProd with frame Dialog-Frame.
    DISPLAY tt-goods.INNProd @ v-INNProd with frame Dialog-Frame.
    DISPLAY tt-goods.KPPProd @ v-KPPProd with frame Dialog-Frame.
    if length (tt-goods.import-full-name) > 33 then do:
      v-imp-name = substring (tt-goods.import-full-name,1,36,"character") .
      v-imp-name1 = substring (tt-goods.import-full-name,37,81,"character") .
    end.
    else v-imp-name = tt-goods.import-full-name .
    DISPLAY v-imp-name @ v-FullNameImpor with frame Dialog-Frame.
    DISPLAY v-imp-name1 @ v-FullNameImpor-2 with frame Dialog-Frame.
    DISPLAY tt-goods.CliRegIdImpor @ v-CliRegIdImpor with frame Dialog-Frame.
    DISPLAY tt-goods.CountryImpor @ v-CountryImpor with frame Dialog-Frame.
    DISPLAY tt-goods.INNImpor @ v-INNImpor with frame Dialog-Frame.
    DISPLAY tt-goods.KPPImpor @ v-KPPImpor with frame Dialog-Frame.
    DISPLAY tt-goods.alc-code @ v-AlcCode with frame Dialog-Frame.
    DISPLAY string(tt-goods.gds-code) @ v-GdsCode with frame Dialog-Frame.
    if length (tt-goods.gds-name) > 33 then do:
      v-gds-name = substring (tt-goods.gds-name,1,33,"character") .
      v-gds-name1 = substring (tt-goods.gds-name,34,67,"character") .
    end.
    else v-gds-name = tt-goods.gds-name .
    DISPLAY v-gds-name @ v-FullNameGds with frame Dialog-Frame.
    DISPLAY v-gds-name1 @ v-FullNameGds-2 with frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_OK Btn_Cancel Btn_add Btn_del br-goods
      WITH FRAME Dialog-Frame.
  if p-mode = 'ПРОСМОТР':U then do:
  DISABLE Btn_add Btn_del
      WITH FRAME Dialog-Frame.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  end.
  if p-mode = 'ВЫБОР':U  then do:
   DISABLE Btn_add Btn_del Btn_OK WITH FRAME Dialog-Frame.
  end.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
