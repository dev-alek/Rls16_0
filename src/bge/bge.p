block-level on error undo, throw.
&ANALYZE-SUSPend _VERSIon-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WindoW-NAME CURRENT-WindoW
&Scoped-define frame-NAME DLG-LOG
&ANALYZE-SUSPend _UIB-CODE-BLOCK _CUStoM _definITIonS DLG-LOG
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: bge.p $
$Archive: bge/bge.p $

Экспорт во внешнюю бухгалтерию.

Автор: Хныкин Павел Андреевич
Дата создания: 09/08/05
Author: Pavel Khnykin
Creation date: 09/08/05

Input:
    p-format-type - формат:
        'tree' - дерево, 'flat' или любое другое значение - плоский.
    p-export-type   - тип экспорта:
        'ALL'       - справочники и документы.
        'DOC'       - только документы.
        'SHIFT'     - смены.
        'FINDOC'    - платежи
        'FIN-OB'    - фин.обязательства
        'CONTRACT'  - договора
        'REF'       - только справочники.
        'STK'       - остатки по всем объектам на начало и на конец интервала.
        'STD'       - остатки с выбором объектов на дату.
        'STT'       - остатки с выбором объектов по типам приобретения на дату.
        'PRC'       - цены товаров
        'DAY'       - обороты за каждый день интервала.
        'WAY'       - товары в пути.
        'CARD'      - данные продаж по дисконтным картам
        'SCHET-FACTUR' - счета-фактуры
        'util,1,2,3,4'  - список типов экспорта:
            1 - Экспорт справочников.
            2 - Экспорт документов.
            3 - Экспорт продаж по кассам.
            4 - Экспорт товарных остатаков.
            5 - Экспорт по товарам по дням.
            6 - Товары в пути.
*/

define input parameter parparentproc        as widget-handle no-undo .
define input parameter p-format-type        as character no-undo.
define input parameter p-export-type        as character no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$date: 14.08.03 11:06 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge.p $":U .
define variable vss-description as character no-undo init "Экспорт XML".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/bgelib.i   }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable v-bge-isbgeold          as logical      no-undo.
define variable v-bge-host-code         as integer      no-undo.
define variable v-bge-editor-handle     as handle       no-undo.
define variable v-bge-fillin-handle     as handle       no-undo.
define variable v-bge-shift-mode        as logical      no-undo.
define variable v-bge-format-dbf        as logical      no-undo.
define variable v-host-code             as integer      no-undo.
define variable v-pay-type-list         as character    no-undo.

&scop start-mess ~
    message ~
      ~{&mess-text~} ~
    view-as alert-box question ~
    buttons yes-no ~
    title "Экспорт XML" ~
    update go-ahead.

def var go-ahead as logical no-undo.

&ANALYZE-RESUME

&ANALYZE-SUSPend _UIB-PREPROCESSor-BLOCK

/* ********************  Preprocessor definitions  ******************** */

&Scoped-define procedure-TYPE DIALOG-BOX

/* Name of first frame and/or Browse and/or first Query                 */
&Scoped-define frame-NAME DLG-LOG

/* Standard List definitions                                            */
&Scoped-define enableD-OBJECTS DLG-COUNTER Btn_OK EDT-LOG
&Scoped-define displayED-OBJECTS DLG-COUNTER EDT-LOG

/* Custom List definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSor-BLOCK-end */
&ANALYZE-RESUME


/* ***********************  Control definitions  ********************** */

/* define a dialog box                                                  */

/* definitions of the field level widgets                               */
define BUTton Btn_OK AUto-end-KEY
     LABEL "OK"
     SIZE 10 BY 1.13
     BGCOLor 8 .

define variable EDT-LOG as character
     view-as EDItor SCROLLBAR-VERTICAL no-WorD-WRAP LARGE
     SIZE 82.88 BY 15.67 no-undo.

define variable DLG-COUNTER as character format "X(65)":U
     view-as text
     SIZE 65.00 BY 1.17
     FGCOLor 9  no-undo.

/* ************************  frame definitions  *********************** */

define frame DLG-LOG
     DLG-COUNTER at ROW 1.04 COL 11.00 colon-aligned no-label
     Btn_OK at ROW 1.08 COL 1.75
     EDT-LOG at ROW 2.38 COL 1.5 no-label
     space(0.36) skip(0.15)
    with view-as DIALOG-BOX KEEP-TAB-orDER
         SIDE-LABELS no-UNDERLinE THREE-D  SCROLLABLE
         TITLE "Экспорт XML"
         defAULT-BUTton Btn_OK.


/* *********************** procedure Settings ************************ */

&ANALYZE-SUSPend _procedure-SETTinGS
/* Settings for THIS-procedure
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _end-procedure-SETTinGS


/* ***************  runtime attributes and UIB Settings  ************** */

&ANALYZE-SUSPend _run-TIME-atTRIBUTES
/* SETTinGS for DIALOG-BOX DLG-LOG
                                                                        */
assign
       frame DLG-LOG:SCROLLABLE       = false
       frame DLG-LOG:HIDDEN           = true.

/* SETTinGS for BUTton Btn_OK in frame DLG-LOG
   no-enable                                                            */
/* SETTinGS for EDItor EDT-LOG in frame DLG-LOG
   no-enable                                                            */
assign
       EDT-LOG:READ-onLY in frame DLG-LOG        = true
.

/* _run-TIME-atTRIBUTES-end */
&ANALYZE-RESUME

/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME DLG-LOG
&ANALYZE-SUSPend _UIB-CODE-BLOCK _ConTROL DLG-LOG DLG-LOG
on WindoW-close OF frame DLG-LOG /* Экспорт XML */
do:
  APPLY "end-error":U to SELF.
end.

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&UNdefine SELF-NAME

&ANALYZE-SUSPend _UIB-CODE-BLOCK _CUStoM _MAin-BLOCK DLG-LOG


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WindoW, if there is no parent.   */
if VALID-handle(ACTIVE-WindoW) and frame {&frame-NAME}:PARENT eq ?
then frame {&frame-NAME}:PARENT = ACTIVE-WindoW.


/* now enable the interface and wait for the exit condition.            */
/* (notE: handle error and end-KEY so cleanup code will always fire.    */
MAin-BLOCK:
do on error   undo MAin-BLOCK, leave MAin-BLOCK
   on end-key undo MAin-BLOCK, leave MAin-BLOCK:
/*  assign*/
/*    DLG-LOG :title = "Экспорт XML"*/
/*  .*/
define variable v-par-value     as character      no-undo.
define variable v-par-type      as character      no-undo.
define variable v-param-type      as character  no-undo .
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .

{ gbl/getcntxt.i get }
assign
    v-bge-isbgeold  = ( p-format-type = "tree":U )
    v-bge-host-code = v-cntxt-host-code-obj
.
run bgelib-read-config in this-procedure .
assign
    v-bge-editor-handle = EDT-LOG :handle
in frame DLG-LOG.
assign
    v-bge-fillin-handle = DLG-COUNTER :handle
in frame DLG-LOG.

run adm/shattri.p ( input "get":U
                  , input  '':u
                  , input  0
                  , input  {&attr-bge-export}
                  , input  {&attr-bge-export_bgeshift}
                  , output v-value-character
                  , output v-value-date
                  , output v-value-decimal
                  , output v-value-integer
                  , output v-value-logical
                  , output v-param-type
                  , input-output table-handle v-tth
                  ) no-error .
if error-status :error
then do:
  assign
      v-bge-shift-mode = no
  .
end.
else do:
  assign
      v-bge-shift-mode = ( v-value-character = "distinct":U )
  .
end.
delete object v-tth.

run adm/shattri.p ( input "get":U
                  , input  '':u
                  , input  0
                  , input  {&attr-bge-export}
                  , input  {&attr-bge-export_bgefmt}
                  , output v-value-character
                  , output v-value-date
                  , output v-value-decimal
                  , output v-value-integer
                  , output v-value-logical
                  , output v-param-type
                  , input-output table-handle v-tth
                  ) no-error .
if error-status :error
then do:
  assign
      v-bge-format-dbf = no
  .
end.
else do:
  assign
      v-bge-format-dbf = ( v-value-character = "dbf":U )
  .
end.
delete object v-tth.

case p-export-type:
    when 'ALL-DOC-REF'
    then do:
    end.
    when 'ALL-DAY-WAY'
    then do:
    end.
    when 'DOC'
    then do:
    end.
    when 'SHIFT'
    then do:
    end.
    when 'FINDOC'
    then do:
    end.
    when 'FIN-OB'
    then do:
    end.
    when 'CONTRACT'
    then do:
    end.
    when 'SCHET-FACTUR'
    then do:
    end.
    when 'STK'
    then do:
    end.
    when 'STD'
    then do:
    end.
    when 'STT'
    then do:
    end.
    when 'PRC'
    then do:
    end.
    when 'DAY'
    then do:
    end.
    when 'WAY'
    then do:
        &scop mess-text "Экспортировать данные по товарам в пути? Операция может занять много времени"
        {&start-mess}
        if go-ahead = no
        then do:
            undo, return no-apply.
        end.
    end.
    when 'KASS'
    then do:
    end.
    when 'REF'
    then do:
        &scop mess-text "Экспортировать справочники? Операция может занять много времени"
        {&start-mess}
        if go-ahead = no
        then do:
            undo, return no-apply.
        end.
    end.

    when 'CARD'
    then do:
      &scop mess-text "Экспортировать данные продаж по дисконтным картам? Операция может занять много времени"
      {&start-mess}
      if go-ahead = no
      then do:
        return.
      end.
    end.
    otherwise do:
        if entry( 1, p-export-type ) <> "util"
        then do:
            message
                "Неверный параметр вызова программы экспорта bge.p"
            view-as alert-box.
            return.
        end.
    end.
end case.

  run enable_UI.
  run start-bge.
  WAIT-for GO OF frame {&frame-NAME}.
end.
run disable_UI.

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME


/* **********************  internal procedures  *********************** */

&ANALYZE-SUSPend _UIB-CODE-BLOCK _procedure disable_UI DLG-LOG _defAULT-disable
procedure disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     disable the User interface
  parameters:  <none>
  notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* hide all frames. */
  hide frame DLG-LOG.
end procedure.

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME


&ANALYZE-SUSPend _UIB-CODE-BLOCK _procedure enable_UI DLG-LOG _defAULT-enable
procedure enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     enable the User interface
  parameters:  <none>
  notes:       Here we display/view/enable the widgets in the
               user-interface.  in addition, OPEN all queries
               associated with each frame and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  display DLG-COUNTER EDT-LOG
      with frame DLG-LOG.
  enable DLG-COUNTER Btn_OK EDT-LOG
      with frame DLG-LOG.
  view frame DLG-LOG.
  assign DLG-COUNTER :visible = false.
  {&OPEN-BROWSERS-in-QUERY-DLG-LOG}
end procedure.

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME

/*============================================================================*/
procedure start-bge:
do
on error undo, return error
:
define variable v-date-from         as date             no-undo. /* начало периода экспорта */
define variable v-shift-num-from    as integer          no-undo.
define variable v-date-to           as date             no-undo. /* конец  периода экспорта */
define variable v-shift-num-to      as integer          no-undo.
define variable v-range             as integer          no-undo.
define variable v-obj-list          as character        no-undo.
define variable v-pay-code          as logical          no-undo.  /* надо ли экспортировать суммы по касс. платежам */
define variable v-doc-type-list     as character        no-undo.  /* список типов операций для выгрузки документов */
define variable v-cst               as logical          no-undo.  /* надо ли экспортировать ГТД в строке товара */
define variable v-parts             as logical          no-undo.  /* надо ли экспортировать партии в строке товара */
define variable v-chk-pay-code      as logical          no-undo.  /* надо ли экспортировать разброс по касс. платежам */
define variable v-pay-desk          as logical          no-undo.  /* надо ли экспортировать разброс по кассам */
define variable v-pay-desk-cards    as logical          no-undo.  /* надо ли экспортировать разброс по кассам */
define variable v-deleted           as logical          no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
define variable v-count             as integer          no-undo.
define variable v-list-item         as character        no-undo.
define variable v-cancel            as logical          no-undo.

case p-export-type:

    when "ALL-DOC-REF":U
    then do:
        run bgelib-write-edt in this-procedure (
              input v-bge-editor-handle
            , input 1
            , input "Экспорт документов и справочников..."
        ).
        if v-bge-shift-mode = yes
        and v-bgelib-bgefmt = "xml":U
        then do:
            run export-docs-shifts in this-procedure (
                input no
            ).
        end.        /* if v-bge-shift-mode = yes */
        else do:
            run export-docs-no-shifts in this-procedure (
                  input no
            ).
        end.        /* NOT ( if v-bge-shift-mode = yes ) */
        run export-refs in this-procedure.
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт документов и справочников завершён." ).
    end.        /* when "ALL-DOC-REF":U */

    when "ALL-DAY-WAY":U
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по товарам по дням и по товарам в пути..." ).
        run export-day in this-procedure.
        run export-way in this-procedure.
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по товарам по дням и по товарам в пути завершён.").
    end.        /* when "ALL-DAY-WAY":U */
    when "SHIFT":U
    then do:
        run export-shift in this-procedure.
    end.        /* when "SHIFT":U */
    when "DOC":U
    then do:
        if v-bge-shift-mode = yes
        and v-bgelib-bgefmt = "xml":U
        then do:
            run export-docs-shifts in this-procedure (
                input no
            ).
        end.        /* if v-bge-shift-mode = yes */
        else do:
            run export-docs-no-shifts in this-procedure (
                input no
            ).
        end.        /* NOT ( if v-bge-shift-mode = yes ) */
    end.
    when "STK":U
    then do:
        run export-stk in this-procedure (
              input 2
            , input yes
        ).
    end.
    when "STD":U
    then do:
        run export-std in this-procedure.
    end.
    when "STT":U
    then do:
        run export-stt in this-procedure.
    end.
    when "PRC":U
    then do:
        run export-prc in this-procedure.
    end.        /* when 'PRC' */
  when "DAY":U
  then do:
        run export-day in this-procedure.
  end.
  when "WAY":U
  then do:
    run export-way in this-procedure.
  end.
  when "KASS":U
  then do:
    run export-kass in this-procedure (
        input 0
    ).
  end.
  when "REF":U
  then do:
    run export-refs in this-procedure.
  end.
  when "CARD":U
  then do:
    run export-card in this-procedure .
  end.
  when "FINDOC":U
  then do:
    run export-findoc in this-procedure.
  END.
  when "FIN-OB":U
  then do:
    run export-fin-ob in this-procedure.
  END.
  when "CONTRACT":U
  then do:
    run export-contract in this-procedure.
  END.
  when "SCHET-FACTUR":U
  then do:
    run export-schet-factur in this-procedure.
  end.      /* when "SCHET-FACTUR":U */
  OTHERWISE do:
    if entry( 1, p-export-type ) <> "util":U
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Неверный параметр " + p-export-type + " в вызове процедуры" + vss-description).
    end.
    else do:
        if entry( 2, p-export-type ) = "g-expie":U /* Выгрузка всех документов внешнего прихода и расхода */
        then do:
            if v-bge-shift-mode = yes
            and v-bgelib-bgefmt = "xml":U
            then do:
                run export-docs-shifts in this-procedure (
                    input yes
                ).
            end.        /* if v-bge-shift-mode = yes */
            else do:
                run export-docs-no-shifts in this-procedure (
                    input yes 
                ).
            end.        /* NOT ( if v-bge-shift-mode = yes ) */
        end.        /* if entry( 2, p-export-type ) = "g-expie" */
        else do:
            do v-count = 2 to num-entries( p-export-type )
            :
                case entry( v-count, p-export-type )
                :
                    when "1"
                    then do:
                        run export-refs in this-procedure.
                    end.
                    when "2"
                    then do:
                        if v-bge-shift-mode = yes
                        and v-bgelib-bgefmt = "xml":U
                        then do:
                            run export-docs-shifts in this-procedure (
                                input no
                            ).
                        end.        /* if v-bge-shift-mode = yes */
                        else do:
                            run export-docs-no-shifts in this-procedure (
                                input no
                            ).
                        end.        /* NOT ( if v-bge-shift-mode = yes ) */
                    end.
                    when "3" 
                    then do:
                        run export-kass in this-procedure (
                            input 1
                        ).
                    end.
                    when "4"
                    then do:
                        run export-stk in this-procedure (
                              input 1
                            , input no
                        ).
                    end.
                    when "5"
                    then do:
                        run export-day in this-procedure .
                    end.
                    when "6"
                    then do:
                        run export-way in this-procedure.
                    end.
                    otherwise do:
                        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Ошибка выбора типа экспорта ..." ).
                    end.
                end case.
            end.
        end.        /* entry( 2, p-export-type ) <> "g-expie":U */
    end.        /* entry( 1, p-export-type ) = "util":U */
  end.      /* OTHERWISE */
end case.
enable
    Btn_Ok
    EDT-LOG
with frame DLG-LOG.
end.
end procedure.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-docs-no-shifts {&FRAME-NAME}
PROCEDURE export-docs-no-shifts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-need-opened-docs   as logical          no-undo.

    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dper.w (
          input parparentproc
        , input 1
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ?
    then do:
        return error. /* отказ */
    end.
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input substitute( "Экспорт документов, диапазон дат &1 - &2"
                                , string( v-date-from, "99.99.99" )
                                , string( v-date-to, "99.99.99" ) )
    ).
    run bgelib-write-edt in this-procedure (
        input v-bge-editor-handle
        , input 1
        , input substitute( "Диапазон: &1"
                                , ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) ) )
    ).
    if v-pay-code = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По видам оплат" ).
    end.
    if v-cst = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Со строкой ГТД в документах" ).
    end.
    if v-parts = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По партиям" ).
    end.
    if v-chk-pay-code = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По типам кассовых платежей" ).
    end.
    if v-pay-desk = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По кассам" ).
    end.
    if v-pay-desk-cards = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По префиксам карт" ).
    end.
    if v-deleted = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Удаленные документы" ).
    end.
    if v-chk = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Чеки" ).
    end.

    if v-bge-format-dbf = yes
    then do:
        run bge/bge-docd.p (
              input parparentproc
            , input v-date-from
            , input v-date-to
            , input v-range
            , input v-obj-list
            , input v-doc-type-list
            , input v-pay-code
            , input v-cst
            , input v-parts
            , input v-chk-pay-code
            , input v-pay-desk
            , input v-pay-desk-cards
            , input v-deleted
            , input v-chk
            , input v-doc-rvs
            , input p-need-opened-docs
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта документов"
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.        /* if v-bge-format-dbf = yes */
    else do:
        if v-bge-isbgeold = yes
        then do:
            if v-bgelib-bgeflold = "firm":U
            then do:
                run bge/bge-docf.p (
                      input parparentproc
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input v-doc-type-list
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input v-pay-desk-cards
                    , input v-deleted
                    , input v-chk
                    , input v-doc-rvs
                    , input p-need-opened-docs
                    , input v-bge-editor-handle
                    , input v-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка экспорта документов"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.        /* if v-bgelib-bgeflold = "firm":U  */
            else do:
                run bge/bge-docs.p (
                      input parparentproc
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input v-doc-type-list
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input v-pay-desk-cards
                    , input v-deleted
                    , input v-chk
                    , input v-doc-rvs
                    , input p-need-opened-docs
                    , input v-bge-editor-handle
                    , input v-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка экспорта документов"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.        /* NOT ( if v-bgelib-bgeflold = "firm":U  ) */
        end.        /* if v-bge-isbgeold = yes  */
        else do:
            run bge/bgedocs.p (
                  input parparentproc
                , input v-date-from
                , input v-date-to
                , input v-range
                , input v-obj-list
                , input v-doc-type-list
                , input v-pay-code
                , input v-cst
                , input v-parts
                , input v-chk-pay-code
                , input v-pay-desk
                , input v-pay-desk-cards
                , input v-deleted
                , input p-need-opened-docs
                , input v-bge-editor-handle
                , input v-bge-fillin-handle
            ) no-error.
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка экспорта документов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.        /* NOT ( if v-bge-isbgeold = yes  ) */
    end.        /* NOT ( if v-bge-format-dbf = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт документов завершён.").
end.
END PROCEDURE. /* export-docs-no-shifts */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-docs-shifts {&FRAME-NAME}
PROCEDURE export-docs-shifts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-need-opened-docs   as logical          no-undo.

    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после слива по топливным приходным документам */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dpeh.w (
          input parparentproc
        , input 1
        , input v-doc-type-list
        , output v-date-from
        , output v-shift-num-from
        , output v-date-to
        , output v-shift-num-to
        , output v-shift-on
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ?
    then do:
        return error. /* отказ */
    end.
    if v-shift-on = yes
    then do:
        run bgelib-write-edt in this-procedure (
            input v-bge-editor-handle
            , input 1
            , input substitute( "Экспорт документов, &1 (смена &2) - &3 (смена &4)"
                                    , string( v-date-from, "99.99.99" )
                                    , v-shift-num-from
                                    , string( v-date-to, "99.99.99" )
                                    , v-shift-num-to    )
        ).
    end.        /* if v-shift-on = yes */
    else do:
        run bgelib-write-edt in this-procedure (
              input v-bge-editor-handle
            , input 1
            , input substitute( "Экспорт документов, диапазон дат &1 - &2"
                                    , string( v-date-from, "99.99.99" )
                                    , string( v-date-to, "99.99.99" ) )
        ).
    end.        /* NOT ( if v-shift-on = yes ) */
    run bgelib-write-edt in this-procedure (
        input v-bge-editor-handle
        , input 1
        , input substitute( "Диапазон: &1"
                                , ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) ) )
    ).
    if v-pay-code = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По видам оплат" ).
    end.
    if v-cst = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Со строкой ГТД в документах" ).
    end.
    if v-parts = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По партиям" ).
    end.
    if v-chk-pay-code = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По типам кассовых платежей" ).
    end.
    if v-pay-desk = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По кассам" ).
    end.
    if v-pay-desk-cards = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По префиксам карт" ).
    end.
    if v-deleted = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Удаленные документы" ).
    end.
    if v-chk = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Чеки" ).
    end.
    if v-doc-rvs = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Сверки до/после слива" ).
    end.

    if v-shift-on = yes
    then do:
        run bge/bge-doch.p (
              input parparentproc
            , input v-date-from
            , input v-shift-num-from
            , input v-date-to
            , input v-shift-num-to
            , input v-shift-on
            , input v-range
            , input v-obj-list
            , input v-doc-type-list
            , input v-pay-code
            , input v-cst
            , input v-parts
            , input v-chk-pay-code
            , input v-pay-desk
            , input v-pay-desk-cards
            , input v-deleted
            , input v-chk
            , input v-doc-rvs
            , input p-need-opened-docs
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта документов"
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.        /* if v-shift-on = yes */
    else do:
        if v-bge-format-dbf = yes
        then do:
            run bge/bge-docd.p (
                  input parparentproc
                , input v-date-from
                , input v-date-to
                , input v-range
                , input v-obj-list
                , input v-doc-type-list
                , input v-pay-code
                , input v-cst
                , input v-parts
                , input v-chk-pay-code
                , input v-pay-desk
                , input v-pay-desk-cards
                , input v-deleted
                , input v-chk
                , input v-doc-rvs
                , input p-need-opened-docs
                , input v-bge-editor-handle
                , input v-bge-fillin-handle
            ) no-error.
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка экспорта документов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.        /* if v-bge-format-dbf = yes */
        else do:
            if v-bge-isbgeold = yes
            then do:
                run bge/bge-docs.p (
                      input parparentproc
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input v-doc-type-list
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input v-pay-desk-cards
                    , input v-deleted
                    , input v-chk
                    , input v-doc-rvs
                    , input p-need-opened-docs
                    , input v-bge-editor-handle
                    , input v-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка экспорта документов"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.        /* if v-bge-isbgeold = yes  */
            else do:
                run bge/bgedocs.p (
                      input parparentproc
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input v-doc-type-list
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input v-pay-desk-cards
                    , input v-deleted
                    , input p-need-opened-docs
                    , input v-bge-editor-handle
                    , input v-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка экспорта документов"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.        /* NOT ( if v-bge-isbgeold = yes  ) */
        end.        /* NOT ( if v-bge-format-dbf = yes ) */
    end.        /* NOT ( if v-shift-on = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт документов завершён.").
end.
END PROCEDURE. /* export-docs-shifts */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-refs {&FRAME-NAME}
PROCEDURE export-refs :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт справочников..." ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-ref.p (
              input parparentproc
            , input "good-ext":U
            , input no
            , input v-bge-host-code
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.        /* if v-bge-isbgeold = yes */
    else do:
        run bge/bgeref.p (
              input parparentproc
            , input "good-ext":U
            , input no
            , input v-bge-host-code
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.        /* NOT ( if v-bge-isbgeold = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт справочников завершён." ).
end.
END PROCEDURE. /* export-refs */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-day {&FRAME-NAME}
PROCEDURE export-day :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по товарам по дням..." ).

    run bge/bge-dper.w (
          input parparentproc
        , input 3
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error. /* отказ */


    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт товаров по дням, диапазон дат "
                                + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                                + " ..."
                    ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-day.p (
              input parparentproc
            , input v-date-from
            , input v-date-to
            , input v-range
            , input v-obj-list
            , input v-bge-host-code
            , input no
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.        /* if v-bge-isbgeold = yes */
    else do:
        /* Плоского экспорта нет */
    end.        /* NOT ( if v-bge-isbgeold = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт товаров по дням завершён.").
end.
END PROCEDURE. /* export-day */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-way {&FRAME-NAME}
PROCEDURE export-way :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт товаров в пути...").
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-way.p (
              input v-bge-host-code
            , input no
            , input 0
            , input ""
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.        /* if v-bge-isbgeold = yes */
    else do:
        /* Плоского экспорта нет */
    end.        /* NOT ( if v-bge-isbgeold = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт товаров в пути завершён.").
end.
END PROCEDURE. /* export-way */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-shift {&FRAME-NAME}
PROCEDURE export-shift :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-void-logical      as logical      no-undo.
    define variable v-void-character    as character    no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dpeh.w (
          input parparentproc
        , input 5
        , input "":U
        , output v-date-from
        , output v-shift-num-from
        , output v-date-to
        , output v-shift-num-to
        , output v-void-logical     /* v-shift-on */
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , output v-void-character   /* v-doc-type-list  */
        , output v-void-logical     /* v-pay-code       */
        , output v-void-logical     /* v-cst            */
        , output v-void-logical     /* v-parts          */
        , output v-void-logical     /* v-chk-pay-code   */
        , output v-void-logical     /* v-pay-desk       */
        , output v-void-logical     /* v-pay-desk-cards */
        , output v-void-logical     /* v-deleted        */
        , output v-void-logical     /* v-chk            */
        , output v-void-logical     /* v-doc-rvs        */
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ?
    then do:
        return error. /* отказ */
    end.
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input substitute( "Экспорт смен, &1 (смена &2) - &3 (смена &4)"
                            , string( v-date-from, "99.99.99" )
                            , v-shift-num-from
                            , string( v-date-to, "99.99.99" )
                            , v-shift-num-to    )
    ).
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input substitute( "Диапазон: &1"
                                , ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) ) )
    ).
    run bge/bge-shft.p (
          input parparentproc
        , input v-date-from
        , input v-shift-num-from
        , input v-date-to
        , input v-shift-num-to
        , input v-range
        , input v-obj-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта документов"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт документов завершён.").
end.
END PROCEDURE. /* export-shift */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-stk {&FRAME-NAME}
PROCEDURE export-stk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-dialog-mode    as integer          no-undo.
define input parameter p-cst            as logical          no-undo.

    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dper.w (
          input parparentproc
        , input p-dialog-mode
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error. /* отказ */

    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Остатки по товарам"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                                + " ..."
                    ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-stk.p (
              input parparentproc
            , input v-bge-host-code
            , input v-date-from
            , input v-date-to
            , input ( if p-cst = no then no else v-cst )
            , input no
            , input 0
            , input ""
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.        /* if v-bge-isbgeold = yes */
    else do:
        /* Плоского экспорта нет */
    end.        /* NOT ( if v-bge-isbgeold = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Остатки по товарам выгружены.").
end.
END PROCEDURE. /* export-stk */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-std {&FRAME-NAME}
PROCEDURE export-std :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dper.w (
          input parparentproc
        , input 4
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки остатков по складам."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-to = ? then return error. /* отказ */
    run bgelib-write-edt in this-procedure (
        input v-bge-editor-handle
        , input 1
        , input "Остатки по товарам на дату "
                + string(v-date-to, "99.99.99")
                + " ..."
    ).
    if v-bge-isbgeold = yes
    then do:        /* XML - дерево или плоский. В данном случае одинаково. */
        run bge/bgestd.p (
              input parparentproc
            , input v-bge-host-code
            , input v-range
            , input v-obj-list
            , input v-date-to
            , input v-cst
            , input v-parts
            , input no
            , input 0
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.        /* if v-bge-isbgeold = yes */
    else do:

        run bge/bgestd.p (
              input parparentproc
            , input v-bge-host-code
            , input v-range
            , input v-obj-list
            , input v-date-to
            , input v-cst
            , input v-parts
            , input no
            , input 0
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.        /* NOT ( if v-bge-isbgeold = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Остатки по товарам выгружены.").
end.
END PROCEDURE. /* export-std */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-stt {&FRAME-NAME}
PROCEDURE export-stt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
        run bge/bge-dper.w (
              input parparentproc
            , input 4
            , input v-doc-type-list
            , output v-date-from
            , output v-date-to
            , output v-range
            , output v-bge-host-code
            , output v-obj-list
            , OUTPUT v-pay-type-list
            , output v-doc-type-list
            , output v-pay-code
            , output v-cst
            , output v-parts
            , output v-chk-pay-code
            , output v-pay-desk
            , output v-pay-desk-cards
            , output v-deleted
            , output v-chk
            , output v-doc-rvs
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка ввода параметров выгрузки остатков по складам по типам приобретения."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        if v-cancel = yes
        then do:
            undo, return error .
        end.
        if v-date-to = ? then return error. /* отказ */
        run bgelib-write-edt in this-procedure (
            input v-bge-editor-handle
            , input 1
            , input "Остатки по товарам по типам приобретения на дату "
                    + string(v-date-to, "99.99.99")
                    + " ..."
        ).
        if v-bge-isbgeold = yes
        then do:        /* XML - дерево или плоский. В данном случае одинаково. */
            run bge/bgestt.p (
                  input parparentproc
                , input v-bge-host-code
                , input v-range
                , input v-obj-list
                , input v-date-to
                , input v-cst
                , input no
                , input 0
                , input v-bge-editor-handle
                , input v-bge-fillin-handle
            ).
        end.        /* if v-bge-isbgeold = yes */
        else do:
            run bge/bgestt.p (
                  input parparentproc
                , input v-bge-host-code
                , input v-range
                , input v-obj-list
                , input v-date-to
                , input v-cst
                , input no
                , input 0
                , input v-bge-editor-handle
                , input v-bge-fillin-handle
            ).
        end.        /* NOT ( if v-bge-isbgeold = yes ) */
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Остатки по товарам по типам приобретения выгружены.").
end.
END PROCEDURE. /* export-stt */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-prc {&FRAME-NAME}
PROCEDURE export-prc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
        run bge/bge-dper.w (
              input parparentproc
            , input 5
            , input v-doc-type-list
            , output v-date-from
            , output v-date-to
            , output v-range
            , output v-bge-host-code
            , output v-obj-list
            , OUTPUT v-pay-type-list
            , output v-doc-type-list
            , output v-pay-code
            , output v-cst
            , output v-parts
            , output v-chk-pay-code
            , output v-pay-desk
            , output v-pay-desk-cards
            , output v-deleted
            , output v-chk
            , output v-doc-rvs
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка ввода параметров выгрузки документов."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        if v-cancel = yes
        then do:
            undo, return error .
        end.
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт цен товаров...").
        run bge/bgeprc.p (
              input parparentproc
            , input no
            , input "all":U
            , input table temp_bgelib_goods
            , input v-bge-host-code
            , input v-range
            , input v-obj-list
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт цен товаров завершён.").
end.
END PROCEDURE. /* export-prc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-kass {&FRAME-NAME}
PROCEDURE export-kass :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-dialog-mode    as integer          no-undo.

    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dper.w (
          input parparentproc
        , input p-dialog-mode
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки документов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error. /* отказ */

    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт продаж через кассы..."
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                                + " ..."
                      ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-kass.p (
              input parparentproc
            , input v-date-from
            , input v-date-to
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.        /* if v-bge-isbgeold = yes */
    else do:
        /* Плоского экспорта нет */
    end.        /* NOT ( if v-bge-isbgeold = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт продаж через кассы завершён.").
end.
END PROCEDURE. /* export-kass */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-card {&FRAME-NAME}
PROCEDURE export-card :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.  /* надо ли экспортировать суммы по касс. платежам */
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cst               as logical      no-undo.  /* надо ли экспортировать ГТД в строке товара */
    define variable v-parts             as logical      no-undo.  /* надо ли экспортировать партии в строке товара */
    define variable v-chk-pay-code      as logical      no-undo.  /* надо ли экспортировать разброс по касс. платежам */
    define variable v-pay-desk          as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-pay-desk-cards    as logical      no-undo.  /* надо ли экспортировать разброс по кассам */
    define variable v-deleted           as logical      no-undo.  /* надо ли экспортировать удаленные в заданный период документы */
    define variable v-chk               as logical      no-undo.  /* надо ли выгружать чеки */
    define variable v-doc-rvs           as logical      no-undo.  /* надо ли выгружать сверки до/после */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных продаж по дисконтным картам...").
    run bge/bge-dper.w (
          input parparentproc
        , input 0
        , input ""
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки данных продаж по дисконтным картам."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error. /* отказ */

    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных продаж по дисконтным картам"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) )
                      ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-card.p (
              input parparentproc
            , input v-date-from
            , input v-date-to
            , input v-range
            , input v-obj-list
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта данных продаж по дисконтным картам"
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.        /* if v-bge-isbgeold = yes */
    else do:
        /* Плоского экспорта нет */
    end.        /* NOT ( if v-bge-isbgeold = yes ) */
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных продаж по дисконтным картам завершён.").
end.
END PROCEDURE. /* export-card */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-findoc {&FRAME-NAME}
PROCEDURE export-findoc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bgefdper.w (
          input parparentproc
        , input '':U   /*doc-list*/
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-obj-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки документов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error. /* отказ */

    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт платежей"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else (" по фирмам: "  + v-obj-list))
                      ).
    run bge/bgefdoc.p (
          input v-date-from
        , input v-date-to
        , input v-range
        , input "":U
        , input v-bge-host-code
        , input v-obj-list
        , input 0
        , input v-doc-type-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта данных по документам платежей"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по документам платежей завершён.").
end.
END PROCEDURE. /* export-findoc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-fin-ob {&FRAME-NAME}
PROCEDURE export-fin-ob :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bgefinob.w (
          input parparentproc
        , input '':U   /*doc-list*/
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-obj-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки документов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error. /* отказ */

    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт финансовых обязательств"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else (" по фирмам: "  + v-obj-list))
                      ).
    run bge/bgefo.p (
          input v-date-from
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта данных по ФО"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по ФО завершён.").
end.
END PROCEDURE. /* export-fin-ob */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-contract {&FRAME-NAME}
PROCEDURE export-contract :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-doc-type-list     as character    no-undo.  /* список типов операций для выгрузки документов */
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bgectper.w (
          input parparentproc
        , input '':U
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-obj-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки договоров."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error. /* отказ */

    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт договоров"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else (" по фирмам: "  + v-obj-list))
                      ).
    run bge/bgecont.p (
          input v-date-from
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input v-doc-type-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта данных по договорам"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по договорам завершён.").
end.
END PROCEDURE. /* export-contract */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-schet-factur {&FRAME-NAME}
PROCEDURE export-schet-factur :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo. /* начало периода экспорта */
    define variable v-date-to           as date         no-undo. /* конец  периода экспорта */
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-s-f.w (
          input parparentproc
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-obj-list
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description skip "Ошибка ввода параметров выгрузки счетов-фактур." skip return-value
          skip trim(error-status :get-message(1))  trim(error-status :get-message(2)) trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ?
    or v-date-to = ?
    then do:        /* отказ */
        return error.
    end.
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input substitute( "Экспорт счетов-фактур, диапазон дат &1 - &2"
                            , string(v-date-from, "99.99.99")
                            , string(v-date-to, "99.99.99")    )
    ).
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input "Диапазон:" + ( if v-range = 1 then " по всем фирмам" else (" по фирмам: "  + v-obj-list) )
    ).
    process events.
    run bge/bge-sf.p (
          input parparentproc
        , input v-date-from
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip "Ошибка экспорта счетов-фактур" skip return-value
        skip trim(error-status :get-message(1))  trim(error-status :get-message(2)) trim(error-status :get-message(3))
      view-as alert-box error.
      undo, return error .
    end.
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input "Экспорт счетов-фактур завершен."
    ).
end.
END PROCEDURE. /* export-schet-factur */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME