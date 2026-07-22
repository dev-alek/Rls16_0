using ibs.th.bge.egais.*.
using ibs.th.str.alcohol.*.
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field type_         as character        label "Основание"   format "X(35)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field part-code     like ub.parts.part-code     label "Партия"
    field doc-code      as character                label "№ накладной TH"
    field doc-date      like ub.trn-doc.fact-date   label "Дата TH"
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-A      as character                label "Справка А"               format "X(20)"
    field A-qnty        as decimal                  label "Кол-во в справке"
    field A-bottleDate  as date                     label "Дата розлива"
    field A-ttnNumber   as character                label "№ ТТН справки А"         format "X(15)"
    field A-ttnDate     as date                     label "Дата"
    field A-fixNumber   as character                label "№ фиксации в ЕГАИС"      format "X(20)"
    field A-fixDate     as date                     label "Дата фикс."
    field inform-B      as character                label "Справка Б"               format "X(20)"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code doc-code
.
define   temp-table tt-marks
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)"
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)"
    field flag                as logical              label "T"
    field reserv              as integer              label "R"
    field parts               as character            label "Партия"         format "X(130)"
    index pi as primary unique
        mark
.
define temp-table tt-marks-doc
    field exciseMark   as character label "Марка"    format "X(150)"
    field alc-code     as character label "Алк. код" format "X(20)"
    field artic        as character label "Артикл"   format "X(20)"
    field prod-type    as character
    field prod-code    as integer
    field gds-code     as integer
    field doc-code     as character
    field partID       as character
    field refB         as character
    field rowid-part   as rowid
    field line-num     as integer
    field isCurr       as logical
    index pi as primary unique
        exciseMark
.
define temp-table tt-alc-qnty
    field artic        as character label "Артикл"   format "X(20)"
    field prod-type    as character
    field prod-code    as integer
    field gds-code     as integer
    field alc-code     as character label "Алк. код" format "X(20)"
    field qnty         as integer   label "Кол."
    field isCurr       as logical
    index pi as primary unique
        artic prod-type prod-code alc-code
.
define input parameter parparentproc     as handle       no-undo.
define input parameter p-num             as character    no-undo .
define input parameter p-position        as integer      no-undo .
define input parameter p-alc-code        as character    no-undo.
define input parameter p-qnty-goods      as integer      no-undo.
define input parameter p-mode            as character    no-undo.
define INPUT-OUTPUT PARAMETER TABLE FOR  tt-marks.
define variable l-error         as logical   no-undo.
define variable v-user-action   as character no-undo.
define variable v-printed       as logical   no-undo.
define variable v-proc-name-err as character no-undo initial 'impmark.err'.
define variable v-proc-name-alc as character no-undo initial 'alc-code.txt'.
def    var      extGdsObj       as class     extgds.
define variable browse-br-marks as handle    no-undo.
define variable bcol            as handle    no-undo.
define variable bcol1           as handle    no-undo.
define variable bcol2           as handle    no-undo.
define variable bcol3           as handle    no-undo.
define variable bcol4           as handle    no-undo.
define variable bcol5           as handle    no-undo.
define variable v-mode          as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Акцизные марки".
define variable v-gds-code    like ub.goods.gds-code     no-undo .
define variable v-gds-name    as character    no-undo .
define variable v-alc-code    as character    no-undo .
define variable v-error-lang  as logical      no-undo .
define variable sort-column-name as character no-undo .
define variable v-key-rec as character no-undo .
define stream str-err .
define stream str-alc .
define variable excMarks as class excisemarks no-undo.
define temp-table tt-del-marks like tt-marks .
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
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_del
     LABEL "Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_EXIT AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_goods
     LABEL "Товары"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_excpmarks
     LABEL "Неучт. марки"
     SIZE 13 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_imp
     LABEL "Импорт"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(255)"
     LABEL "Марка"
     VIEW-AS FILL-IN
     SIZE 80 BY 1.
DEFINE VARIABLE v-qnty-goods AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "кол-во в партии"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-qnty-marks AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "кол-во марок"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.
DEFINE QUERY br-marks FOR
      tt-marks SCROLLING.
DEFINE BROWSE br-marks
  QUERY br-marks NO-LOCK DISPLAY
      (IF tt-marks.flag THEN "+":U ELSE "-":U) FORMAT "x(1)":U COLUMN-LABEL "Т"
    (IF tt-marks.reserv = 1 THEN "+":U ELSE "-":U) FORMAT "x(1)":U COLUMN-LABEL "R"
    tt-marks.parts
    WIDTH 10
    tt-marks.mark
    WIDTH 40
    tt-marks.alc-code
    WIDTH 20
    tt-marks.gds-code
    WIDTH 10
    tt-marks.gds-name
    WIDTH 30
    tt-marks.impor-full-name
    WIDTH 30
    tt-marks.prod-full-name
    WIDTH 30
    WITH NO-ROW-MARKERS SEPARATORS SIZE 112 BY 20.21 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 2
     Btn_EXIT AT ROW 1.25 COL 2
     Btn_Cancel AT ROW 1.25 COL 12
     Btn_del AT ROW 1.25 COL 22
     Btn_imp AT ROW 1.25 COL 32
     Btn_goods AT ROW 1.25 COL 42
     Btn_excpmarks AT ROW 1.25 COL 52 WIDGET-ID 12
     v-qnty-marks AT ROW 1.25 COL 106 COLON-ALIGNED WIDGET-ID 8
     v-qnty-goods AT ROW 2.25 COL 106 COLON-ALIGNED WIDGET-ID 10
     v-mark AT ROW 2.71 COL 7 COLON-ALIGNED
     br-marks AT ROW 4 COL 2
     SPACE(1.00) SKIP(0.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод Акцизных марок"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
      APPLY "END-ERROR":U TO SELF.
    END.
ON ROW-DISPLAY OF br-marks IN FRAME Dialog-Frame
DO:
    if p-num = "" and p-position = 0 then
    do:
      if tt-marks.gds-code = 0 then
      do:
        tt-marks.gds-code:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.alc-code:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.mark:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.gds-name:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.prod-full-name:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.impor-full-name:BGCOLOR in browse br-marks = red_COLOR.
      end.
      if tt-marks.flag = yes then
      do:
        tt-marks.gds-code:BGCOLOR in browse br-marks = DARK_GREY_COLOR.
      end.
    end.
END.
ON VALUE-CHANGED OF br-marks IN FRAME Dialog-Frame
DO:
  if available tt-marks then do:
        if tt-marks.gds-code <> 0 and p-mode = 'ИЗМЕНЕНИЕ':U then do:
          enable Btn_goods
          WITH FRAME Dialog-Frame.
        end.
        else do:
          disable Btn_goods
          WITH FRAME Dialog-Frame.
        end.
   end.
END.
ON choose OF Btn_Cancel IN FRAME Dialog-Frame
DO:
      for each tt-marks exclusive-lock where tt-marks.new_ :
        delete tt-marks .
      end.
      for each tt-del-marks where not tt-del-marks.new_ :
        create tt-marks.
        buffer-copy tt-del-marks to tt-marks .
      end.
    END.
ON choose OF Btn_del IN FRAME Dialog-Frame
DO:
      if not available tt-marks then return no-apply .
      find first tt-del-marks no-lock where tt-del-marks.mark = tt-marks.mark no-error .
      if not available tt-del-marks
      then do :
          create tt-del-marks.
          buffer-copy tt-marks to tt-del-marks .
      end.
      delete tt-marks .
      open query br-marks for each tt-marks where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position.
    END.
ON choose OF Btn_goods IN FRAME Dialog-Frame
DO:
      define variable v-prod-full-name as character no-undo .
      define variable v-import-full-name as character no-undo .
      if available tt-marks then
      do:
        v-mode = 'ПРОСМОТР':U.
        v-gds-code = 0 .
        run bge/egais-goods-mark.w ( input parparentproc, input v-mode, input-output tt-marks.alc-code, input-output v-gds-code, output v-gds-name, output v-prod-full-name, output v-import-full-name )  .
        if v-gds-code <> 0 then
        do:
          assign
            tt-marks.gds-code = v-gds-code
            tt-marks.gds-name = v-gds-name
            tt-marks.prod-full-name = v-prod-full-name
            tt-marks.impor-full-name = v-import-full-name
            .
        end.
        Br-marks:refresh() in frame Dialog-Frame .
      end.
      else
        message "Не выбран алког. код"
          view-as alert-box.
    END.
ON CHOOSE OF Btn_excpmarks IN FRAME Dialog-Frame
DO:
  excMarks = new excisemarks(v-cntxt-obj-type, v-cntxt-obj-code).
  excMarks:GetMarkForInvDoc(v-key-rec, p-alc-code, input-output table tt-marks-doc).
  for each tt-marks-doc:
    create tt-marks.
    assign
      tt-marks.alc-code = tt-marks-doc.alc-code
      tt-marks.gds-code = tt-marks-doc.gds-code
      tt-marks.mark = tt-marks-doc.exciseMark
    no-error.
    if error-status:error
      then delete tt-marks.
  end.
  open query br-marks for each tt-marks .
  assign
    v-mark:screen-value = "" .
  assign v-mark .
  apply "entry" to v-mark in FRAME Dialog-Frame.
END.
ON choose OF Btn_imp IN FRAME Dialog-Frame
DO:
      run proc-choose-file no-error .
      open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .
      assign
        v-mark:screen-value = "" .
      assign v-mark .
      apply "entry" to v-mark in FRAME Dialog-Frame.
END.
ON choose OF Btn_OK IN FRAME Dialog-Frame
DO:
      for each tt-marks exclusive-lock :
        assign
          tt-marks.new_ = false .
      end.
    END.
ON return OF v-mark IN FRAME Dialog-Frame
DO:
            define variable v-error as logical no-undo init no.
            output stream str-err to value(v-proc-name-err) append.
            output stream str-alc to value(v-proc-name-alc) append.
            def var ii as int.
            assign
                v-mark = v-mark:screen-value .
            RUN ProcAlcCode IN THIS-PROCEDURE (input v-mark, output v-alc-code, output l-error, output v-error-lang) no-error.
            if v-error-lang then
            do:
                message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
                    view-as alert-box.
                put stream str-err unformatted
                    "Не корректно считана акцизная марка, акцизная марка содержит не допустимые символы или русские буквы."
                    skip .
                assign
                    v-mark              = ""
                    v-mark:screen-value = ""
                    .
            end.
            else
            do:
                if l-error then
                do:
                    message substitute ("Алког. код не преобразовывается в десятичную систему из акцизной марки: &1", v-mark)
                        view-as alert-box.
                    v-alc-code = "".
                    put stream str-err unformatted
                        substitute ("Алког. код не преобразовывается в десятичную систему из акцизной марки: &1", v-mark)
                        skip .
                end.
                else
                do:
                    extGdsObj = new ExtGds (true).
                    extGdsObj:OpenQueryExtGds(0, v-alc-code).
                    if extGdsObj:NumBundles = 0 then
                    do:
                        message substitute ("Для алког. кода &1 не найден товар (не установлено соответствие)", v-alc-code)
                            view-as alert-box.
                        put stream str-err unformatted
                            substitute ("Для алког. кода &1 не найден товар (не установлено соответствие)", v-alc-code)
                            skip .
                        if p-num = "" and p-position = 0 then
                        do:
                            find first tt-marks where tt-marks.mark = v-mark no-lock no-error.
                            if not available tt-marks then
                            do:
                                create tt-marks .
                            end.
                            assign
                                tt-marks.mark     = v-mark
                                tt-marks.new_     = true
                                tt-marks.alc-code = v-alc-code
                                .
                        end.
                    end.
                    else
                    do:
                        if p-alc-code <> "" and p-alc-code <> extGdsObj:GetExtGdsValue(1):AlcCode then
                        do :
                            message "Не тот товар! Вы вводите марки для алк. кода " + p-alc-code skip
                                "Алк. код в марке - " extGdsObj:GetExtGdsValue(1):AlcCode view-as alert-box .
                        end.
                        if (p-alc-code <> "" and p-alc-code = extGdsObj:GetExtGdsValue(1):AlcCode) or p-alc-code = "" then
                        do:
                            find first tt-marks where tt-marks.mark = v-mark no-lock no-error.
                            if AVAILABLE tt-marks then
                            do:
                                MESSAGE "Марка с таким" v-mark "кодом уже введена"
                                    VIEW-AS ALERT-BOX.
                            end.
                            else
                            do:
                                create tt-marks .
                            end.
                            assign
                                tt-marks.num                = p-num
                                tt-marks.gds-part-position_ = p-position
                                tt-marks.mark               = v-mark
                                tt-marks.new_               = true .
                            tt-marks.gds-code           = extGdsObj:GetExtGdsValue(1):GdsCode .
                            tt-marks.alc-code           = extGdsObj:GetExtGdsValue(1):AlcCode .
                            tt-marks.prod-full-name     = extGdsObj:GetExtGdsValue(1):FullNameProd .
                            tt-marks.impor-full-name    = extGdsObj:GetExtGdsValue(1):FullNameImpor .
                            .
                            v-gds-code = extGdsObj:GetExtGdsValue(1):GdsCode .
                            find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
                            if available ub.goods then tt-marks.gds-name = ub.goods.gds-name .
                            if extGdsObj:NumBundles > 1 then tt-marks.flag = yes .
                            if p-num = "" and p-position = 0 then
                            do:
                                do ii = 1 to extGdsObj:NumBundles:
                                    find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
                                    if available ub.goods then v-gds-name = ub.goods.gds-name .
                                    put stream str-alc unformatted
                                        substitute  ("&1 &2 &3 &4 &5 &6 &7 &8 &9",extGdsObj:GetExtGdsValue(ii):AlcCode, extGdsObj:GetExtGdsValue(ii):GdsCode, v-gds-name,
                                        extGdsObj:GetExtGdsValue(ii):CliRegIdProd, extGdsObj:GetExtGdsValue(ii):FullNameProd, extGdsObj:GetExtGdsValue(ii):INNProd,
                                        extGdsObj:GetExtGdsValue(ii):KPPProd, extGdsObj:GetExtGdsValue(ii):CountryProd, extGdsObj:GetExtGdsValue(ii):CliRegIdImpor).
                                    put stream str-alc unformatted
                                        substitute  ("&1 &2 &3 &4", extGdsObj:GetExtGdsValue(ii):FullNameImpor, extGdsObj:GetExtGdsValue(ii):INNImpor, extGdsObj:GetExtGdsValue(ii):KPPImpor, extGdsObj:GetExtGdsValue(ii):CountryImpor) skip .
                                end.
                            end.
                        end.
                    end.
                    delete object extGdsObj .
                end.
                open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .
                assign
                    v-mark:screen-value = "" .
                assign v-mark .
                run count-marks-parts no-error .
                apply "entry" to v-mark in FRAME Dialog-Frame.
            end.
            output stream str-alc close.
            output stream str-err close.
            apply "value-changed" to br-marks IN FRAME Dialog-Frame .
        END.
  IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
  MAIN-BLOCK:
  DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if num-entries (p-mode) > 1
    then do:
      assign
        v-key-rec = entry (2, p-mode)
        p-mode = entry (1, p-mode)
      .
    end.
    RUN count-marks-parts no-error .
    RUN enable_UI.
    WAIT-FOR GO OF FRAME Dialog-Frame.
  END.
  RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    br-marks:column-resizable in frame dialog-frame = true .
    ENABLE Btn_OK Btn_Cancel Btn_del Btn_imp Btn_EXIT v-mark br-marks Btn_excpmarks
        WITH FRAME Dialog-Frame.
    DISABLE Btn_goods v-qnty-marks v-qnty-goods
        WITH FRAME Dialog-Frame.
    if p-mode = 'ИЗМЕНЕНИЕ':U then
    do:
        if p-num = "" and p-position = 0 then
        do:
            disable Btn_Cancel Btn_del Btn_OK
                WITH FRAME Dialog-Frame.
            hide Btn_OK v-qnty-marks v-qnty-goods
                IN FRAME Dialog-Frame.
        end.
        else
        do:
            hide Btn_EXIT
                IN FRAME Dialog-Frame.
        end.
    end.
    else
    do:
        disable Btn_Cancel Btn_del Btn_OK Btn_imp
            WITH FRAME Dialog-Frame.
        hide Btn_OK
            IN FRAME Dialog-Frame.
    end.
    VIEW FRAME Dialog-Frame.
    open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .
    apply "value-changed" to br-marks IN FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-choose-file :
    if search (v-proc-name-err) <> ? then
    do:
        os-delete value(v-proc-name-err).
    end.
    if search (v-proc-name-alc) <> ? then
    do:
        os-delete value(v-proc-name-alc).
    end.
    DEFINE VARIABLE vCh AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vLg AS LOGICAL   NO-UNDO.
    def    var      ii  as int.
    SYSTEM-DIALOG GET-FILE vCh
        MUST-EXIST
        TITLE "Выбор файла"
        USE-FILENAME UPDATE vLg.
    IF vCh <> "" THEN
    DO:
        output stream str-err to value(v-proc-name-err)  APPEND .
        output stream str-alc to value(v-proc-name-alc)  APPEND .
        INPUT FROM value(vCh).
        REPEAT:
            IMPORT v-mark.
            find first tt-marks where tt-marks.mark = v-mark no-lock no-error .
            if not available tt-marks then
            do:
                create tt-marks.
                tt-marks.mark = v-mark .
                run ProcAlcCode  IN THIS-PROCEDURE (input v-mark, output v-alc-code, output l-error, output v-error-lang ) no-error.
                if v-error-lang then
                do:
                    put stream str-err unformatted
                        "Не корректно считана акцизная марка, акцизная марка содержит не допустимые символы или русские буквы."
                        skip .
                    v-alc-code = "".
                    l-error = yes .
                end.
                else
                do:
                    if p-alc-code <> "" and v-alc-code <> p-alc-code then
                    do:
                        put stream str-err unformatted
                            substitute ("Алког. кода &1 не соответствует алког. коду в партии", v-alc-code)
                            skip.
                        l-error = yes .
                    end.
                    else
                    do:
                        extGdsObj = new ExtGds (true).
                        extGdsObj:OpenQueryExtGds(0, v-alc-code).
                        if extGdsObj:NumBundles = 0 then
                        do:
                            put stream str-err unformatted
                                substitute ("Для алког. кода &1 не найден товар (не установлено соответствие)", v-alc-code)
                                skip.
                            l-error = yes .
                            if p-num = "" and p-position = 0 then
                            do:
                                find first tt-marks where tt-marks.mark = v-mark no-lock no-error.
                                if not available tt-marks then
                                do:
                                    create tt-marks .
                                end.
                                assign
                                    tt-marks.mark     = v-mark
                                    tt-marks.new_     = true
                                    tt-marks.alc-code = v-alc-code .
                            end.
                        end.
                        else
                        do:
                            find first tt-marks where tt-marks.mark = v-mark no-lock no-error.
                            if not available tt-marks then
                            do:
                                create tt-marks .
                            end.
                            assign
                                tt-marks.num                = p-num
                                tt-marks.gds-part-position_ = p-position
                                tt-marks.mark               = v-mark
                                tt-marks.new_               = true .
                            tt-marks.gds-code           = extGdsObj:GetExtGdsValue(1):GdsCode .
                            tt-marks.alc-code           = v-alc-code .
                            tt-marks.prod-full-name     = extGdsObj:GetExtGdsValue(1):FullNameProd .
                            tt-marks.impor-full-name    = extGdsObj:GetExtGdsValue(1):FullNameImpor .
                            .
                            v-gds-code = extGdsObj:GetExtGdsValue(1):GdsCode .
                            find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
                            if available ub.goods then tt-marks.gds-name = ub.goods.gds-name .
                            if extGdsObj:NumBundles > 1 then tt-marks.flag = yes .
                            if p-num = "" and p-position = 0 then
                            do:
                                put stream str-alc unformatted
                                    substitute  ("Информация по марке: &1:", v-mark) skip .
                                do ii = 1 to extGdsObj:NumBundles:
                                    find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
                                    if available ub.goods then v-gds-name = ub.goods.gds-name .
                                    put stream str-alc unformatted
                                        substitute  ("&1 &2 &3 &4 &5 &6 &7 &8 &9",extGdsObj:GetExtGdsValue(ii):AlcCode, extGdsObj:GetExtGdsValue(ii):GdsCode, v-gds-name,
                                        extGdsObj:GetExtGdsValue(ii):CliRegIdProd, extGdsObj:GetExtGdsValue(ii):FullNameProd, extGdsObj:GetExtGdsValue(ii):INNProd,
                                        extGdsObj:GetExtGdsValue(ii):KPPProd, extGdsObj:GetExtGdsValue(ii):CountryProd, extGdsObj:GetExtGdsValue(ii):CliRegIdImpor).
                                    put stream str-alc unformatted
                                        substitute  ("&1 &2 &3 &4", extGdsObj:GetExtGdsValue(ii):FullNameImpor, extGdsObj:GetExtGdsValue(ii):INNImpor, extGdsObj:GetExtGdsValue(ii):KPPImpor, extGdsObj:GetExtGdsValue(ii):CountryImpor) skip .
                                end.
                            end.
                        end.
                    end.
                end.
            end.
        END.
        INPUT CLOSE.
        output stream str-alc close.
        output stream str-err close.
        if l-error then
        do:
            if search (v-proc-name-err) <> ? then
            do:
                run gbl/prnfilen.w
                    (input  substitute ("Не все марки были загружены")
                    ,input  0
                    ,input  v-proc-name-err
                    ,input  7
                    ,output v-user-action
                    ,output v-printed
                    ).
            end.
        end.
        else
        do:
            if p-num = "" and p-position = 0 then
            do:
                message substitute("Импорт акцизных марок завершен успешно и выгружены в &2.",v-proc-name-alc)
                    view-as alert-box.
            end.
            else
            do:
                message substitute("Импорт акцизных марок завершен успешно.")
                    view-as alert-box.
            end.
        end.
        delete object extGdsObj no-error.
    END.
    else os-delete value(v-proc-name-err).
    run count-marks-parts no-error .
END PROCEDURE.
PROCEDURE count-marks-parts :
    do
        on error undo, return error
        :
        DEFINE VARIABLE ii as INTEGER no-undo .
        open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .
        ii = 0 .
        v-qnty-goods = p-qnty-goods .
        if p-alc-code <> "" then
        do:
            for each tt-marks where tt-marks.alc-code = p-alc-code :
                ii = ii + 1 .
            end.
        end.
        else
        do:
            for each tt-marks :
                ii = ii + 1 .
            end.
        end.
        v-qnty-marks = ii .
        display
            v-qnty-marks
            v-qnty-goods
            with frame Dialog-Frame.
    end.
END PROCEDURE.
