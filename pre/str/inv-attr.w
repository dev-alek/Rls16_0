define variable vss-revision as character no-undo initial "$Revision: dbafd66ddb70, 2290, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ShklyarEL $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Dec 26 15:31:55 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-attr.w $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/inv-attr.w $":U .
define variable vss-description as character no-undo initial "Редактирование атрибутов инвентаризации":U .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function funcgrzp returns character
( input p-par-code as char  ,
  input p-par-value as char ) .
def buffer buf_clients for ub.clients .
define variable v-type as character no-undo .
define variable v-code as integer   no-undo .
if lookup(p-par-code,'Recipient':U) = 0  then return "".
assign
  v-type = substring(p-par-value,1,3)
  v-code = int(substring(p-par-value,4,15) )
.
if error-status :error then return "".
find first buf_clients no-lock where
           buf_clients.obj-type = v-type and
           buf_clients.obj-code = v-code
           no-error .
           if error-status :error then return "" .
return buf_clients.obj-name .
end function.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define input parameter parParentProc as handle no-undo .
define input parameter parbtn as character no-undo.
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define input parameter table for tt-upd-attr .
define variable varrec-id          as recid     no-undo.
define variable v-no-news          as logical   no-undo init false .
define variable v-attr-mandat-wayb as character no-undo .
define variable ii                 as integer   no-undo .
define variable bcol               as handle    extent no-undo.
define variable hBrowse            as handle    no-undo.
define buffer buf_trn-doc for ub.trn-doc .
define temp-table tt-inv-attr no-undo
  field attr-code     as character
  field attr-value    as character
  field second-code   as character
  field second-value  as character
  field label-attr    as character
  field user-can-edit as logical
  field sort_         as integer
  index code is primary unique attr-code
  index by-sort                sort_
  .
DEFINE BUTTON b-chg
  LABEL "&Изменить"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-END-KEY
  LABEL "&Выход"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE BUTTON b-lkp
  LABEL "&Просмотр"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE VARIABLE tech AS LOGICAL INITIAL no
  LABEL "Техническая операция"
  VIEW-AS TOGGLE-BOX
  SIZE 24.5 BY .83 NO-UNDO.
DEFINE QUERY b-doc-attr FOR
  tt-inv-attr SCROLLING.
DEFINE BROWSE b-doc-attr
  QUERY b-doc-attr NO-LOCK DISPLAY
  tt-inv-attr.label-attr COLUMN-LABEL "Код" FORMAT "X(45)"
  tt-inv-attr.attr-value COLUMN-LABEL "Значение" FORMAT "X(30)"
  tt-inv-attr.second-value COLUMN-LABEL "Должность" FORMAT "X(30)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.63 BY 19.29.
DEFINE FRAME Dialog-Frame
  b-exit AT ROW 1 COL 1
  b-lkp AT ROW 1 COL 21
  b-chg AT ROW 1 COL 31
  tech AT ROW 1.08 COL 44 WIDGET-ID 2
  b-doc-attr AT ROW 2.46 COL 1.75
  SPACE(0.00) SKIP(0.07)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Атрибуты инвентаризации"
  DEFAULT-BUTTON b-exit.
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
  b-doc-attr:COLUMN-RESIZABLE IN FRAME Dialog-Frame = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
  DO:
    apply "chose":U to b-exit .
    APPLY "END-ERROR":U TO SELF.
  END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
  DO:
    define variable is-check as logical   no-undo .
    define variable is-mes   as character no-undo .
    define variable varlog   as logical   no-undo .
    define buffer fio_inv-attr    for tt-inv-attr .
    define buffer pos_inv-attr    for tt-inv-attr .
    define buffer prikaz_inv-attr for tt-inv-attr .
    if lookup ("b-chg", parbtn) = 0 then return .
    if not tech then
    do:
      if not can-find (first prikaz_inv-attr no-lock where
        prikaz_inv-attr.attr-code = 'trdcattr-prikaz-date':U and
        prikaz_inv-attr.attr-value <> "") then
      do:
        is-check = true .
      end.
      if not can-find (first fio_inv-attr no-lock where
        (fio_inv-attr.attr-code = 'trdcattr-fio-agent':U or
        fio_inv-attr.attr-code = 'trdcattr-fio-player1':U or
        fio_inv-attr.attr-code = 'trdcattr-fio-player2':U or
        fio_inv-attr.attr-code = 'trdcattr-fio-player3':U) and
        fio_inv-attr.attr-value <> "") then
      do:
        is-check = true .
      end.
      if not can-find (first fio_inv-attr no-lock where
        (fio_inv-attr.second-code = 'trdcattr-pos-agent':U or
        fio_inv-attr.second-code = 'trdcattr-pos-player1':U or
        fio_inv-attr.second-code = 'trdcattr-pos-player2':U or
        fio_inv-attr.second-code = 'trdcattr-pos-player3':U) and
        fio_inv-attr.second-value <> "")then
      do:
        is-check = true .
      end.
      if is-check then is-mes = "Не заполнены обязательные атрибуты накладной инвентаризации." + chr(10).
        find first fio_inv-attr no-lock where
        fio_inv-attr.attr-code = 'trdcattr-fio-agent':U and
        fio_inv-attr.attr-value <> "" no-error .
        if not available (fio_inv-attr) then do:
        find first pos_inv-attr no-lock where
        pos_inv-attr.second-code = 'trdcattr-pos-agent':U and
        pos_inv-attr.second-value <> "" no-error .
        if available (pos_inv-attr) then is-mes = is-mes + "Не заполнена ФИО председателя комиссии." + chr(10).
        end.
        else do:
        find first pos_inv-attr no-lock where
        pos_inv-attr.second-code = 'trdcattr-pos-agent':U and
        pos_inv-attr.second-value <> "" no-error .
        if not available (pos_inv-attr) then is-mes = is-mes + "Не заполнена должность председателя комиссии." + chr(10).
        end.
        find first fio_inv-attr no-lock where
        fio_inv-attr.attr-code = 'trdcattr-fio-player1':U and
        fio_inv-attr.attr-value <> "" no-error .
        if not available (fio_inv-attr) then do:
        find first pos_inv-attr no-lock where
        pos_inv-attr.second-code = 'trdcattr-pos-player1':U and
        pos_inv-attr.second-value <> "" no-error .
        if available (pos_inv-attr) then is-mes = is-mes + "Не заполнена ФИО первого участника комиссии." + chr(10).
        end.
        else do:
        find first pos_inv-attr no-lock where
        pos_inv-attr.second-code = 'trdcattr-pos-player1':U and
        pos_inv-attr.second-value <> "" no-error .
        if not available (pos_inv-attr) then is-mes = is-mes + "Не заполнена должность первого участника комиссии." + chr(10).
        end.
        find first fio_inv-attr no-lock where
        fio_inv-attr.attr-code = 'trdcattr-fio-player2':U and
        fio_inv-attr.attr-value <> "" no-error .
        if not available (fio_inv-attr) then do:
        find first pos_inv-attr no-lock where
        pos_inv-attr.second-code = 'trdcattr-pos-player2':U and
        pos_inv-attr.second-value <> "" no-error .
        if available (pos_inv-attr) then is-mes = is-mes + "Не заполнена ФИО второго участника комиссии." + chr(10).
        end.
        else do:
        find first pos_inv-attr no-lock where
        pos_inv-attr.second-code = 'trdcattr-pos-player2':U and
        pos_inv-attr.second-value <> "" no-error .
        if not available (pos_inv-attr) then is-mes = is-mes + "Не заполнена должность второго участника комиссии." + chr(10).
        end.
        find first fio_inv-attr no-lock where
        fio_inv-attr.attr-code = 'trdcattr-fio-player3':U and
        fio_inv-attr.attr-value <> "" no-error .
        if not available (fio_inv-attr) then do:
        find first pos_inv-attr no-lock where
        pos_inv-attr.second-code = 'trdcattr-pos-player3':U and
        pos_inv-attr.second-value <> "" no-error .
        if available (pos_inv-attr) then is-mes = is-mes + "Не заполнена ФИО третьего участника комиссии." + chr(10).
        end.
        else do:
        find first pos_inv-attr no-lock where
        pos_inv-attr.second-code = 'trdcattr-pos-player3':U and
        pos_inv-attr.second-value <> "" no-error .
        if not available (pos_inv-attr) then is-mes = is-mes + "Не заполнена должность третьего участника комиссии." + chr(10).
        end.
        if is-mes <> "" then is-mes = is-mes + "Вы уверены, что хотите выйти, не заполнив обязательные атрибуты?" .
      if is-mes <> "" then
      do:
        message
          is-mes
          view-as alert-box question buttons yes-no update varlog.
          if not varlog then return no-apply.
      end.
    end.
  END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
  DO:
    define variable vartemp-char  as character no-undo.
    define variable p-anyfromproc as character no-undo .
    define variable p-start-h     as integer   no-undo.
    define variable p-start-m     as integer   no-undo.
    define variable p-end-h       as integer   no-undo.
    define variable p-end-m       as integer   no-undo.
    if available tt-inv-attr then
    do:
      find first tt-upd-attr no-lock where tt-upd-attr.code = tt-inv-attr.attr-code no-error .
      if available (tt-upd-attr) then
      do:
        if tt-inv-attr.second-code = "" then
        do:
          run gbl/d-prompt.w (
            'title=':u + 'Изменение атрибутов инвентаризации' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'no':u + '\':u
            , input-output tt-inv-attr.attr-value
            ) no-error.
          if error-status:error then
          do:
            message "Ошибка при изменении атрибута." skip
              return-value skip
              error-status:get-message(1) view-as alert-box error.
            return no-apply.
          end.
          if return-value = 'false':u then
          do:
            return no-apply.
          end.
          if tt-inv-attr.attr-code = 'trdcattr-prikaz-date':U or tt-inv-attr.attr-code = 'trdcattr-inv-date':U
          then do:
              define variable ddate as date no-undo.
              if tt-inv-attr.attr-value <> "" then do:
                  ddate = date(tt-inv-attr.attr-value) no-error.
                  if error-status:error then do:
                      message "Некорректный формат даты." view-as alert-box error.
                      return no-apply.
                  end.
                  if year(ddate) < 2000 or year(ddate) > 2100 then do:
                      message "Год должен быть от 2000 до 2100. " view-as alert-box error.
                      return no-apply.
                  end.
              end.
          end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-wrt in g#trdcalib ( input pardoc-code ,
                       input tt-inv-attr.attr-code ,
                       input tt-inv-attr.attr-value ) no-error .
          if error-status :error then
          do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
          end.
        end.
        else
        do:
          run ref/d-invAttr.w (
            'title=':u + 'Изменение атрибутов инвентаризации' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'text2=':u + "Должность" + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'no':u + '\':u
            , input tech
            , input-output tt-inv-attr.attr-value
            , input-output tt-inv-attr.second-value
            ) no-error.
          if error-status:error then
          do:
            message "Ошибка при изменении атрибута." skip
              return-value skip
              error-status:get-message(1) view-as alert-box error.
            return no-apply.
          end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-wrt in g#trdcalib ( input pardoc-code ,
                       input tt-inv-attr.second-code ,
                       input tt-inv-attr.second-value ) no-error .
          if error-status :error then
          do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
          end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-wrt in g#trdcalib ( input pardoc-code ,
                       input tt-inv-attr.attr-code ,
                       input tt-inv-attr.attr-value ) no-error .
          if error-status :error then
          do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
          end.
        end.
        assign
          varrec-id = recid(tt-inv-attr).
        OPEN QUERY b-doc-attr FOR EACH tt-inv-attr NO-LOCK by tt-inv-attr.sort                                         .
        reposition b-doc-attr to recid varrec-id.
      end.
    end.
  END.
ON return OF b-doc-attr IN FRAME Dialog-Frame
  DO:
    if  b-chg:sensitive THEN apply "CHOOSE":U to b-chg.
    else apply "choose":U to b-lkp.
    return no-apply.
  END.
ON ROW-DISPLAY OF b-doc-attr IN FRAME Dialog-Frame
  DO:
    run rowdisp .
  END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
  DO:
    define variable vartemp-char as character no-undo.
    if available tt-inv-attr then
    do:
      find first tt-upd-attr no-lock where tt-upd-attr.code = tt-inv-attr.attr-code no-error .
      if available (tt-upd-attr) then
      do:
        assign
          vartemp-char = tt-inv-attr.attr-value
          .
        if tt-inv-attr.second-code = "" then
        do:
          run gbl/d-prompt.w (
            'title=':u + 'Изменение атрибутов документа' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'yes':u + '\':u
            , input-output vartemp-char
            ) no-error.
        end.
        else
        do:
          run ref/d-invAttr.w (
            'title=':u + 'Изменение атрибутов инвентаризации' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'text2=':u + "Должность" + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'yes':u + '\':u
            , input-output tt-inv-attr.attr-value
            , input-output tt-inv-attr.second-value
            ) no-error.
        end.
      end.
    end.
  end.
ON VALUE-CHANGED OF tech IN FRAME Dialog-Frame
  DO:
    assign tech .
    find first ub.inv-doc-attr exclusive-lock where ub.inv-doc-attr.doc-code = pardoc-code and
      ub.inv-doc-attr.attr-code = "invTech" no-error .
    if not available (ub.inv-doc-attr) then
    do:
      create ub.inv-doc-attr .
      assign
        ub.inv-doc-attr.doc-code  = pardoc-code
        ub.inv-doc-attr.attr-code = "invTech"
        .
    end.
    ub.inv-doc-attr.attr-value = string(tech) .
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  OPEN QUERY b-doc-attr FOR EACH tt-inv-attr NO-LOCK by tt-inv-attr.sort                                         .
    apply "VALUE-CHANGED" to b-doc-attr.
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  b-doc-attr :SET-REPOSITIONED-ROW(4, "CONDITIONAL") .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup ("b-lkp", parbtn) > 0 then
  do:
    enable b-lkp with frame Dialog-Frame.
  end.
  if lookup ("b-chg", parbtn) > 0 then
  do:
    enable b-chg tech with frame Dialog-Frame.
  end.
  run init-proc in this-procedure .
  hbrowse = browse b-doc-attr:handle.
  extent (bcol) = hbrowse:num-columns.
  bcol[1] = hbrowse:first-column.
  do ii = 1 to extent (bcol).
    bcol[ii] = hbrowse:get-browse-column (ii).
  end.
  RUN enable_UI.
  apply 'entry':u to browse b-doc-attr .
  wait-for go of frame Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY tech
    WITH FRAME Dialog-Frame.
  ENABLE b-exit b-doc-attr
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY b-doc-attr FOR EACH tt-inv-attr NO-LOCK by tt-inv-attr.sort                                         .
END PROCEDURE.
PROCEDURE init-proc :
  define variable v-func-name as character no-undo .
  define variable v-proc-name as character no-undo .
  define variable tt          as character no-undo .
  define variable i           as integer   no-undo .
  define variable list-attr   as character no-undo .
  list-attr = 'trdcattr-fio-player3':U + "/" + 'trdcattr-fio-player2':U + "/" + 'trdcattr-fio-player1':U + "/" + 'trdcattr-fio-agent':U .
  for each tt-upd-attr where tt-upd-attr.output-display = yes  :
    create tt-inv-attr .
    assign
      tt-inv-attr.label-attr = tt-upd-attr.label-attr
      tt-inv-attr.attr-code  = tt-upd-attr.code
      tt-inv-attr.sort_      = tt-upd-attr.sort_
      .
    if lookup(tt-inv-attr.attr-code,list-attr,"/") > 0 then
    do:
      case tt-inv-attr.attr-code:
        when 'trdcattr-fio-agent':U then
          do:
            tt-inv-attr.second-code = 'trdcattr-pos-agent':U .
          end.
        when 'trdcattr-fio-player1':U then
          do:
            tt-inv-attr.second-code = 'trdcattr-pos-player1':U .
          end.
        when 'trdcattr-fio-player2':U then
          do:
            tt-inv-attr.second-code = 'trdcattr-pos-player2':U .
          end.
        when 'trdcattr-fio-player3':U then
          do:
            tt-inv-attr.second-code = 'trdcattr-pos-player3':U .
          end.
      end case .
    end.
  end.
  for each tt-inv-attr:
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = tt-inv-attr.attr-code and
      ub.inv-doc-attr.doc-code = pardoc-code:
      tt-inv-attr.attr-value = ub.inv-doc-attr.attr-value .
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = tt-inv-attr.second-code and
      ub.inv-doc-attr.doc-code = pardoc-code:
      tt-inv-attr.second-value = ub.inv-doc-attr.attr-value .
    end.
  end.
  find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = pardoc-code and
    ub.inv-doc-attr.attr-code = "invTech" no-error .
  if available (ub.inv-doc-attr) then tech = logical (ub.inv-doc-attr.attr-value) .
END PROCEDURE.
PROCEDURE rowdisp :
END PROCEDURE.
PROCEDURE st-attr :
  define variable varattr-code like ub.doc-attr.attr-code no-undo.
  define buffer bf_doc-attr for ub.doc-attr.
  define variable vartemp-char as character no-undo.
  define buffer buf_doc-attr    for ub.doc-attr .
  define buffer buf_tt-upd-attr for tt-upd-attr .
  do
    transaction on error undo, return error return-value
    :
    for each buf_tt-upd-attr
      on error undo, return error return-value
      :
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = pardoc-code
        and buf_doc-attr.attr-code = buf_tt-upd-attr.code
        no-error .
      if available buf_doc-attr
        then
      do:
        assign
          buf_tt-upd-attr.can-select = false
          .
      end.
      else
      do:
        assign
          buf_tt-upd-attr.can-select = true
          .
      end.
    end.
    run str/b-attr.w
      (input table tt-upd-attr
      ,output varattr-code
      ) no-error .
    if error-status :error
      then
    do:
      if return-value <> ""
        then
      do:
        message
          "Ошибка при выборе добавляемого атрибута."
          view-as alert-box error.
      end.
      undo, return error.
    end.
    find first tt-upd-attr where tt-upd-attr.code = varattr-code no-error.
    if not available tt-upd-attr then
    do:
      message "Не верно выбран атрибут для добавления." view-as alert-box error.
      undo, return error.
    end.
    if tt-upd-attr.user-can-edit <> yes then
    do:
      message "Атрибут нельзя добавить в данном интерфейсе." view-as alert-box.
      undo, return error.
    end.
    find first bf_doc-attr where bf_doc-attr.doc-code   = pardoc-code and
      bf_doc-attr.attr-code = varattr-code no-lock no-error.
    if available bf_doc-attr then
    do:
      message "Атрибут " tt-upd-attr.label-attr " уже есть в документе " pardoc-code " ."
        view-as alert-box error.
      undo, return error.
    end.
    create ub.inv-doc-attr.
    assign
      ub.inv-doc-attr.doc-code  = pardoc-code
      ub.inv-doc-attr.attr-code = varattr-code.
    run gbl/d-prompt.w (
      'title=':u + 'Изменение атрибутов документа' + '\':u
      + 'text1=':u + tt-upd-attr.label-attr + '\':u
      + 'format=' + tt-upd-attr.format-attr + '\':u
      + 'type=' + tt-upd-attr.type-attr + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
      + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
      + 'max-chars=70\':u
      + 'readonly=' + 'no':u + '\':u
      , input-output vartemp-char
      ) no-error.
    if error-status:error then
    do:
      message "Ошибка при изменении атрибута." skip
        return-value skip
        error-status:get-message(1) view-as alert-box error.
      undo, return error.
    end.
    if return-value = 'false':u then
    do:
      undo, return error.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-wrt in g#trdcalib ( input ub.inv-doc-attr.doc-code ,
                       input ub.inv-doc-attr.attr-code ,
                       input vartemp-char ) no-error .
    if error-status :error then
    do:
      message "Ошибка при сохранении атрибута." view-as alert-box.
      undo, return error.
    end.
    assign
      varrec-id = recid(ub.doc-attr)
      .
    if not v-no-news  then
    do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-oth in g#trdcalib ( input ub.inv-doc-attr.doc-code ,
                       input ub.inv-doc-attr.attr-code ,
                       input vartemp-char ) no-error .
      if error-status :error then
      do:
        message "Ошибка при обработке атрибута." view-as alert-box.
        undo, return no-apply.
      end.
    end.
  end.
END PROCEDURE.
