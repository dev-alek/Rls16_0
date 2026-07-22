DEFINE BUFFER X_order FOR ub.order-doc.
DEFINE BUFFER X_order-line FOR ub.order-line.
define input parameter  parparentproc as widget-handle no-undo .
define input parameter p-doc-code as integer no-undo .
define input parameter par-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка заказа".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
      .
      if v-curr-sv-date = ?
      then do:
        run gbl/getcurdt.p
          (output v-curr-sv-date
          ) .
      end.
      if v-curr-sv-date <> ?
      then do:
        run gbl/d-inpday.w
          (input ?
          ,input "Выбор даты"
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table  tt-dateZakaz     no-undo
field id as integer
field dateStart as date
field dateEnd as date
index pi id
    .
DEFINE TEMP-TABLE tt-typeDocChoose NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
 define temp-table choose-gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
  define temp-table tt-gds-list like ub.goods
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi gds-code.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-rid-list    as character no-undo .
define variable row_order     as rowid     no-undo .
define variable recid_order   as integer   no-undo .
define variable ii            as integer   no-undo .
define variable recid_line    as integer   no-undo .
define variable varschartic   as character initial " " no-undo.
define variable ref-list      as character no-undo.
define variable contract-code as character no-undo .
define variable gds-rec       as integer   no-undo .
define variable title0         as character no-undo .
define variable StatusOrder   as class     ibs.th.str.order.sts.order no-undo .
define variable bcol          as handle    extent no-undo.
define variable hBrowse       as handle    no-undo.
define variable vUndo         as logical   no-undo init no.
FUNCTION gds-name RETURNS character
    (p-code as integer ) FORWARD.
FUNCTION stock RETURNS character
    (p-code as integer ) FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-cancel AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1.
DEFINE BUTTON b-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-excel
     LABEL "Печать"
     SIZE 10 BY 1.
DEFINE BUTTON b-hist
     IMAGE-UP FILE "cmp/b-hist.bmp":U
     IMAGE-DOWN FILE "cmp/b-hist.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-hist.bmp":U NO-CONVERT-3D-COLORS
     LABEL "&История"
     SIZE 3 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 3 BY 1.
DEFINE BUTTON b-notOk
     LABEL "&Отклонить"
     SIZE 10 BY 1.
DEFINE BUTTON b-ok
     LABEL "&Принять"
     SIZE 10 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 3 BY 1.
DEFINE BUTTON b-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON b-send AUTO-GO
     LABEL "Отправить"
     SIZE 10 BY 1.
DEFINE VARIABLE c-status AS CHARACTER FORMAT "X(256)":U
     LABEL "Статус"
     VIEW-AS FILL-IN
     SIZE 44.5 BY 1 NO-UNDO.
DEFINE VARIABLE contract-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 72.5 BY 1 NO-UNDO.
DEFINE VARIABLE user-name AS CHARACTER FORMAT "x(256)":U
     LABEL "Исполнитель"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.
DEFINE VARIABLE v-doc-code AS CHARACTER FORMAT "X(16)":U
     LABEL "Номер заказа"
     VIEW-AS FILL-IN
     SIZE 29.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-doc-date AS date FORMAT "99/99/9999":U
          LABEL "Дата создания"
          VIEW-AS FILL-IN
          SIZE 20 BY 1 NO-UNDO.
DEFINE QUERY br-line FOR
      X_order-line SCROLLING.
DEFINE BROWSE br-line
    QUERY br-line exclusive-lock DISPLAY
    mark-string( input recid(X_order-line), input v-rid-list) column-label "*" format "X(1)":U
    X_order-line.gds-code column-label "Код" FORMAT "9999999999":U
    X_order-line.artic column-label "Артикул" FORMAT "x(16)":U
    gds-name(X_order-line.gds-code) column-label "Наименование" format "X(256)":U WIDTH 50
    X_order-line.order-qnty column-label "Заказ " FORMAT "->>>>>>>>9":U
    X_order-line.fact-qnty column-label "Подтвержденное!количество" FORMAT "->>>>>>>>9":U
    X_order-line.rest column-label "Остаток!товара"
    X_order-line.sales column-label "Продажи за!период"
    X_order-line.average-sales column-label "Среднесуточные!продажи за!период"
    stock(X_order-line.stock-goods) column-label "Запас!товара"
    X_order-line.volume-goods  column-label "Расчетный объем!заказа с учетом!темпа продаж"
    X_order-line.volume-stock  column-label "Расчетный объем!заказа с учетом!миним. запаса"
    X_order-line.min-stock column-label "Минимальный!запас"
    X_order-line.garant-stock  column-label "Гарантийный!запас"
    X_order-line.promo     column-label "Товар!участвует в!промоакции"
  ENABLE
      X_order-line.order-qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 18 fit-last-column.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1 WIDGET-ID 2
     b-prev AT ROW 1 COL 11 WIDGET-ID 4
     b-send AT ROW 1 COL 11 WIDGET-ID 8
     b-next AT ROW 1 COL 14 WIDGET-ID 6
     b-excel AT ROW 1 COL 21 WIDGET-ID 208
     b-cancel AT ROW 1 COL 31 WIDGET-ID 10
     b-hist AT ROW 1 COL 128.5 WIDGET-ID 18
     v-doc-code AT ROW 2.33 COL 14.38 COLON-ALIGNED WIDGET-ID 204
     v-doc-date AT ROW 2.33 COL 91.5 COLON-ALIGNED WIDGET-ID 16
     X_order.cli-code AT ROW 3.58 COL 14.38 COLON-ALIGNED WIDGET-ID 18
          LABEL "Поставщик"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     X_order.cli-type AT ROW 3.58 COL 22.88 COLON-ALIGNED NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     X_order.cli-name AT ROW 3.58 COL 27.25 COLON-ALIGNED NO-LABEL WIDGET-ID 22
          VIEW-AS FILL-IN
          SIZE 44.25 BY 1
     X_order.order-date AT ROW 3.58 COL 91.5 COLON-ALIGNED WIDGET-ID 14
          LABEL "Дата поставки"
          VIEW-AS FILL-IN
          SIZE 11.5 BY 1
     b-date AT ROW 3.63 COL 105 WIDGET-ID 202
     X_order.contract-prn-code AT ROW 4.83 COL 14.38 COLON-ALIGNED WIDGET-ID 24
          LABEL "Договор"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
     X_order.contract-code AT ROW 4.83 COL 44.88 COLON-ALIGNED WIDGET-ID 264
          LABEL "Вн.№"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     contract-name AT ROW 4.83 COL 57 COLON-ALIGNED NO-LABEL WIDGET-ID 266
     c-status AT ROW 6.08 COL 14.38 COLON-ALIGNED WIDGET-ID 206
     user-name AT ROW 6.08 COL 91.5 COLON-ALIGNED WIDGET-ID 28
     X_order.info AT ROW 7.25 COL 16.38 NO-LABEL WIDGET-ID 260
          VIEW-AS EDITOR NO-WORD-WRAP MAX-CHARS 1000 SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          SIZE 115.13 BY 2.29
     b-mark AT ROW 9.75 COL 1 WIDGET-ID 34
     b-add AT ROW 9.75 COL 4 WIDGET-ID 36
     b-del AT ROW 9.75 COL 14 WIDGET-ID 40
     b-ok AT ROW 9.75 COL 24 WIDGET-ID 254
     b-notOk AT ROW 9.75 COL 34 WIDGET-ID 256
     br-line AT ROW 10.75 COL 1 WIDGET-ID 200
     "Внимание! Справочные данные рассчитаны на момент создания заказа" VIEW-AS TEXT
          SIZE 76.5 BY .67 AT ROW 9.92 COL 40.25 WIDGET-ID 268
          FGCOLOR 12
     "Информация:" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 7.33 COL 4.25 WIDGET-ID 262
     SPACE(116.99) SKIP(20.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       br-line:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
        apply "choose":U to b-cancel in frame Dialog-Frame.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
        define buffer bf_order-line  for ub.order-line .
        define buffer buF_order-line for ub.order-line .
        define variable line-num as integer no-undo .
        empty temp-table gds-list .
        empty temp-table tt-gds-list .
        for each buF_order-line no-lock where buF_order-line.doc-code = p-doc-code:
            create tt-gds-list .
            assign
                tt-gds-list.artic     = buF_order-line.artic
                tt-gds-list.gds-code  = buF_order-line.gds-code
                tt-gds-list.prod-code = buF_order-line.prod-code
                tt-gds-list.prod-type = buF_order-line.prod-type
                .
        end.
        RUN str/order_choose.w (
            input  parparentproc,
            input  "b-mark,b-sel",
            input  v-cntxt-host-code-obj,
            input  X_order.contract-code,
            input integer(''),
            input  X_order.params,
            input X_order.doc-code,
            input X_order.db-num,
            input table tt-gds-list,
            output table gds-list
            ).
        find last bf_order-line no-lock where bf_order-line.doc-code = X_order.doc-code no-error .
        if available (bf_order-line) then line-num = bf_order-line.line-num .
        for each gds-list:
            find first buf_order-line no-lock where buf_order-line.gds-code = gds-list.gds-code
                and buf_order-line.doc-code = X_order.doc-code no-error .
            if not available (buf_order-line) then
            do:
                line-num = line-num + 1 .
                create buf_order-line .
                assign
                    buf_order-line.doc-code   = X_order.doc-code
                    buf_order-line.db-num     = X_order.db-num
                    buf_order-line.line-num   = line-num
                    buf_order-line.artic      = gds-list.artic
                    buf_order-line.order-qnty = gds-list.doc-qnty
                    buf_order-line.gds-code   = gds-list.gds-code
                    buf_order-line.prod-code  = gds-list.prod-code
                    buf_order-line.prod-type  = gds-list.prod-type
                    .
            end.
        end.
        OPEN QUERY br-line FOR EACH X_order-line no-lock where X_order-line.doc-code = p-doc-code INDEXED-REPOSITION.
    END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
        define variable p-ok as logical no-undo .
        find first X_order-line no-lock where X_order-line.db-num = X_order.db-num and X_order-line.doc-code = X_order.doc-code no-error .
        if not available (X_order-line) then do:
         message "Вы уверены, что хотите закрыть заказ без сохранения?" skip
                 "Пустой заказ будет удален"
         view-as alert-box question buttons yes-no update p-ok.
         if p-ok then do:
         delete X_order .
         end.
         else return no-apply .
        end.
        vUndo = yes.
        return.
    END.
ON CHOOSE OF b-date IN FRAME Dialog-Frame
DO:
        if par-mode <> 'ПРОСМОТР':U then
        do:
            run sel-date in this-procedure
                (input X_order.order-date :handle
                ,input ""
                ) .
            if date(X_order.order-date:screen-value) < today then
            do:
                message "Дата заказа должна быть равна или больше текущей"
                    view-as alert-box.
                display X_order.order-date with frame Dialog-Frame .
                return no-apply .
            end.
            assign X_order.order-date .
        end.
    END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
        define variable ii as integer no-undo .
        define buffer bf_order-line for ub.order-line .
        define variable recid_line as integer no-undo init ?.
        if v-rid-list = "" then
        do:
            if available (X_order-line) then
            do:
                ii = X_order-line.line-num .
                delete X_order-line .
            end.
            find first X_order-line where X_order-line.doc-code = X_order.doc-code and
            X_order-line.db-num = X_order.db-num and X_order-line.line-num > ii no-error .
            if available (X_order-line) then do:
                recid_line = recid(X_order-line) .
            end.
        end.
        else
        do:
            do ii = 0 to num-entries (v-rid-list):
                find first bf_order-line exclusive-lock where recid(bf_order-line) = integer(entry (ii,v-rid-list)) no-error .
                if available (bf_order-line) then
                do:
                    delete bf_order-line .
                end.
            end.
        end.
         OPEN QUERY br-line FOR EACH X_order-line no-lock where X_order-line.doc-code = p-doc-code INDEXED-REPOSITION.
        if recid_line <> ? then reposition br-line to recid recid_line no-error .
    END.
ON CHOOSE OF b-excel IN FRAME Dialog-Frame
DO:
        define variable Log-Res as logical no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_lookup':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
            if not log-res then return no-apply .
        run rep/r-order.p(input parparentproc,
            input X_order.doc-code,
            input X_order.db-num,
            input X_order.params)  .
    END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
        define variable v-rid-list as character no-undo.
        if available (X_order) then
        do:
            row_order = rowid (X_order) .
            run ref/cordhist.w (
                X_order.db-num,
                X_order.doc-code,
                parparentproc,
                0,
                "",
                0,
                "",
                "one",
                ?,
                "",
                "" ,
                v-cntxt-db-num,
                ?,
                input-output v-rid-list ) .
        end.
    END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
        define variable loc#log as logical no-undo .
        if available X_order-line then
        do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid7 as character no-undo .
define variable v-num-entry7 as integer   no-undo .
assign
  v-str-recid7 = trim( string( recid( X_order-line ) , "->>>>>>>>>>>9":U ) )
  v-num-entry7 = lookup( v-str-recid7 , v-rid-list )
.
if v-num-entry7 > 0 then do:
  assign
    entry( v-num-entry7, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid7
  .
end.
            row_order = rowid(X_order-line).
            loc#log = br-line:refresh() .
            reposition br-line to rowid row_order.
            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then
            do:
                loc#log = br-line:select-next-row ().
                apply "VALUE-CHANGED" to br-line in frame Dialog-Frame.
            end.
        end.
        apply "entry" to br-line in frame Dialog-Frame.
    END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
        assign .
    END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
        assign .
    END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
    define variable p-ok as logical no-undo .
    find first X_order-line no-lock where X_order-line.db-num = X_order.db-num and X_order-line.doc-code = X_order.doc-code no-error .
        if not available (X_order-line) then do:
         message "Вы уверены, что хотите закрыть заказ?" skip
                 "Пустой заказ будет удален"
         view-as alert-box question buttons yes-no update p-ok.
         if p-ok then do:
         delete X_order .
         return .
         end.
         else return no-apply .
        end.
    END.
ON CHOOSE OF b-send IN FRAME Dialog-Frame
DO:
        define variable p-ok as logical no-undo .
        find first X_order-line no-lock where X_order-line.doc-code = X_order.doc-code and
        X_order-line.db-num = X_order.db-num no-error .
        if not available (X_order-line) then do:
            message "Нельзя отправить заказ, т.к. нет товаров по нему"
            view-as alert-box.
            return no-apply .
        end.
        find first X_order-line no-lock where X_order-line.doc-code = X_order.doc-code and
        X_order-line.db-num = X_order.db-num and X_order-line.order-qnty <= 0 no-error .
        if not available (X_order-line) then
        do:
            message "Вы уверены, что хотите отправить заказ поставщику?"
                view-as alert-box question buttons yes-no update p-ok.
            if p-ok then
            do:
                run bge\send1cerp.p (parparentproc,
                    this-procedure,
                    this-procedure,
                    "order",
                    (buffer X_order:handle),
                    ?,
                    ?) no-error.
                if  error-status:error then
                do:
                    message return-value
                        view-as alert-box.
                    return .
                end.
                X_order.sts = StatusOrder:Sended:KeyIntDB .
                run init_tt .
            end.
        end.
        else
        do:
            message "Количество товара в заказе не может быть отрицательным или равным нулю"
            view-as alert-box .
            return no-apply .
        end.
    END.
ON ROW-DISPLAY OF br-line IN FRAME Dialog-Frame
DO:
        if  X_order-line.order-qnty <= 0 then
        do:
            do ii = 1 to extent (bcol):
                if valid-handle (bcol[ii])
                    then
                do:
                    assign
                        bcol[ii]:fgcolor = red_COLOR.
                end.
            end.
        end.
        if X_order.sts <> StatusOrder:NewStatus:KeyIntDB and
           X_order.sts <> StatusOrder:Sended:KeyIntDB then
        do:
        if  X_order-line.order-qnty <> X_order-line.fact-qnty then
        do:
            do ii = 1 to extent (bcol):
                if valid-handle (bcol[ii])
                    then
                do:
                    assign
                        bcol[ii]:fgcolor = red_COLOR.
                end.
            end.
        end.
        end.
    END .
ON row-leave OF br-line IN FRAME Dialog-Frame
DO:
        find current X_order-line exclusive-lock.
        assign
            browse br-line X_order-line.order-qnty
            .
            if X_order-line.order-qnty = ? then do:
                return no-apply .
            end.
            X_order-line.fact-qnty = X_order-line.order-qnty .
        find current X_order-line no-lock.
        br-line:refresh ().
        apply "ROW-DISPLAY" to br-line IN FRAME Dialog-Frame.
    end.
ON LEAVE OF X_order.order-date IN FRAME Dialog-Frame
DO:
        apply "TAB":U to self .
    END.
ON RETURN OF X_order.order-date IN FRAME Dialog-Frame
DO:
        apply "TAB":U to self .
    END.
ON TAB OF X_order.order-date IN FRAME Dialog-Frame
DO:
        date(X_order.order-date:screen-value) no-error.
        if error-status:error then
        do:
            message "Ошибка ввода даты"
                view-as alert-box.
            display X_order.order-date with frame Dialog-Frame .
            return no-apply .
        end.
        if string(X_order.order-date) <> X_order.order-date:screen-value then
        do:
            if date(X_order.order-date:screen-value) < today then
            do:
                message "Дата заказа должна быть равна или больше текущей"
                    view-as alert-box.
                display X_order.order-date with frame Dialog-Frame .
                return no-apply.
            end.
            assign X_order.order-date .
            display X_order.order-date with frame Dialog-Frame .
        end.
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of v-doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of v-doc-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of v-doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of v-doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of v-doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date9
    MENU-ITEM m-ed-date9-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date9-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date9-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date9-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-doc-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-doc-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date9 :HANDLE
      v-doc-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle9 as handle no-undo .
  assign
    v-label-handle9 = v-doc-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle9)
  then do:
    if v-label-handle9 :tooltip = ""
    or v-label-handle9 :tooltip = ?
    then do:
      assign
        v-label-handle9 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date9-1 in menu m-ed-date9 DO:
    apply "ctrl-b":U to v-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-2 in menu m-ed-date9 DO:
    apply "ctrl-d":U to v-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-3 in menu m-ed-date9 DO:
    apply "ctrl-e":U to v-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-4 in menu m-ed-date9 DO:
    apply "ctrl-f":U to v-doc-date in frame Dialog-Frame .
  END.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-line :SET-REPOSITIONED-ROW(12, "CONDITIONAL") .
end.
StatusOrder =  new ibs.th.str.order.sts.order().
if par-mode = 'ПРОСМОТР':U then find first X_order no-lock where X_order.doc-code = p-doc-code no-error .
else find first X_order exclusive-lock where X_order.doc-code = p-doc-code no-error .
v-doc-date = X_order.doc-date .
extent (bcol) = ?.
hbrowse = browse br-line:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).
    bcol[ii] = hbrowse:get-browse-column (ii).
end.
if X_order.order-item <> "" then title0 = "Заказ № " + string(X_order.order-item).
else title0 = "Заказ".
run init_tt .
RUN enable_UI .
run enable_tt .
frame Dialog-Frame:title = title0 .
   on F9 of frame Dialog-Frame anywhere
      do:
         if not available X_order-line then  return no-apply.
         find first goods no-lock where goods.gds-code = X_order-line.gds-code .
         gds-rec = recid(goods) .
         run ref/gds-form.w
            (input  parParentProc
            ,input  'ПРОСМОТР':U
            ,input  v-cntxt-obj-type
            ,input  v-cntxt-obj-code
            ,input ?
            ,input-output gds-rec
            ).
         apply "entry" to br-line in frame Dialog-Frame.
         return no-apply.
      end.
WAIT-FOR GO OF FRAME Dialog-Frame .
if vUndo then
  UNDO MAIN-BLOCK, LEAVE.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_tt :
    if par-mode = 'ПРОСМОТР':U or X_order.sts <> StatusOrder:NewStatus:KeyIntDB then
    do:
        disable
            b-add
            b-del
            b-date
            v-doc-date
            b-send
            X_order.order-date
            with frame Dialog-Frame .
            X_order-line.order-qnty:column-read-only in browse br-line = true .
    end.
    if X_order.sts = StatusOrder:NewStatus:KeyIntDB or X_order.sts = StatusOrder:Sended:KeyIntDB or X_order.sts = StatusOrder:Cancelled:KeyIntDB then
    X_order-line.fact-qnty:visible IN BROWSE br-line = false.
    else X_order-line.fact-qnty:visible IN BROWSE br-line = true.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY c-status user-name
        WITH FRAME Dialog-Frame.
    IF AVAILABLE X_order THEN
        DISPLAY X_order.doc-code v-doc-date X_order.cli-code
            X_order.cli-type X_order.cli-name X_order.order-date user-name contract-name
            v-doc-code X_order.info X_order.contract-code X_order.contract-prn-code
            WITH FRAME Dialog-Frame.
    ENABLE b-save b-send b-next b-excel X_order.order-date b-date
        b-mark b-add b-del br-line b-hist b-cancel
        WITH FRAME Dialog-Frame.
    hide b-prev b-next b-prev b-next b-ok b-notOk in frame Dialog-Frame .
    VIEW FRAME Dialog-Frame.
    OPEN QUERY br-line FOR EACH X_order-line no-lock where X_order-line.doc-code = p-doc-code INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE init_tt :
    v-doc-code = string(X_order.order-item) .
    find first ub.contract no-lock where ub.contract.contract-code = X_order.contract-code no-error .
    if available (ub.contract) then contract-name = ub.contract.contract-name .
    if X_order.user-id <> '' then
    do:
        find first ub.user-account no-lock where ub.user-account.user-id = X_order.user-id no-error .
        if available (ub.user-account) then
        do:
            user-name = ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name .
        end.
    end.
    c-status = StatusOrder:GetLabel(X_order.sts) .
END PROCEDURE.
FUNCTION gds-name RETURNS character
    (p-code as integer ):
    define variable v-gds-name as character no-undo.
    find first ub.goods no-lock where ub.goods.gds-code = p-code no-error .
    if available (ub.goods) then
    do:
        v-gds-name = ub.goods.gds-name .
    end.
    return v-gds-name.
end function.
FUNCTION stock RETURNS character
    (p-code as integer ):
    define variable stock-code as character no-undo.
    if p-code = -1 then stock-code = "-" .
    else stock-code = string (p-code) .
    return stock-code.
end function.
