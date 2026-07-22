block-level on error undo, throw.
/*

$Revision: 63c9a434965b, 3578, rls $
$Author: VSpiridonov $
$Date: 2023/12/14 13:36:13 $
$Workfile: r-dispet.p $
$Archive: rep/r-dispet.p $

Отчет диспетчера

Автор: Белоусов Илья Александрович
Дата создания: 11/22/07
Author: Ilia Belousov
Creation date: 11/22/07

*/

define input parameter parParentProc   as handle    no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-rebh as handle no-undo .
define input parameter p-rdbh                   as handle                  no-undo . /*destination*/
define input parameter p-report-id as character no-undo .
define input parameter p-xsd-file as character no-undo .
define input parameter p-log-file-name as character no-undo .
define input parameter p-batch        as integer  no-undo .
define input parameter p-codex-id               as integer no-undo .
define input parameter p-ruleset-id             as integer no-undo .
define input parameter p-time as integer          no-undo.
define input parameter p-date         as date   no-undo .
define input parameter p-cli-list     as character        no-undo.
define input parameter p-excel         as logical          no-undo .
define input parameter p-xml           as logical          no-undo .
define input parameter p-dir-excel          as character no-undo .
define input parameter p-dir-xml          as character no-undo .
define output parameter p-dataseth as handle no-undo .
define output parameter p-xmlh as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: 63c9a434965b, 3578, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/14 13:36:13 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-dispet.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-dispet.p $":U .
define variable vss-description as character no-undo init "Отчет диспетчера".

define variable g#report-num  as integer      no-undo .
define variable v-sort-list    as character    no-undo.
define variable v-sort-type    as character    no-undo.
define variable v-sort         as logical      no-undo.
define variable v-sort-MAX     as integer      no-undo.
define variable v-sort-code    as integer      no-undo.
define variable v-message    as character    no-undo.
define variable v-err-mess as character no-undo .
define variable v-start-datetime as datetime no-undo .

define buffer buf_rvs-line-attr for ub.rvs-line-attr .

{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/showinf.i    }
{ rep/fmtcli.i     }
/*{ cmp/r-page1.i    }*/
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ gbl/cur-time.i   }
{ cmp/r-pril.i new }
{ gbl/paramls.i    }
{ rep/r-dispxl.i   }
/*{ gbl/getcntxt.i def }*/
{ ref/gds-attr.i   }
{ gbl/gate-clb.i }
{ rep/reprumpr.i print-xlt }
{ str/placelib.i     }
&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end



&global-define frame-width  212

/*
DEFINE TEMP-TABLE tt-place NO-UNDO
field gds-code           like ub.goods.gds-code
field sort-code          as integer
field pl-code            like ub.place.pl-code
field obj-code           like ub.place.obj-code
field obj-type           like ub.place.obj-type
field obj-name           like ub.clients.obj-name

field loc1               like ub.place.loc1
field gds-name           like ub.goods.gds-name
field max-qnty           like ub.place.max-qnty
field add-qnty           like ub.place.add-qnty
field obj-number         as INTEGER
field obj-address        as character
field obj-phone          as character
field found-in-rvs       as logical
field is-meas            as logical

field curr-qnty          like ub.rvs-line.state-measure-qnty /* из последней сверки */
field doc-qnty           like ub.rvs-line.state-measure-qnty /* из атрибутов последней сверки */
field sale-qnty-1        like ub.rvs-line.state-measure-qnty /* продажи предыдущего дня, */
field sale-qnty-7        like ub.rvs-line.state-measure-qnty /* продажи недельной давности */

field curr-time          as integer   /* время последней сверки */
field curr-time-str      as character /* время последней сверки */
field curr-date          as date      /* время последней сверки */
index pu as primary unique
      obj-type
      obj-code
      sort-code
      gds-code
      pl-code
index i-print
      obj-number
      sort-code
      gds-code
      pl-code
INDEX rvs
      obj-type
      obj-code
      found-in-rvs
.
DEFINE TEMP-TABLE  obj-list NO-UNDO LIKE ub.clients.

*/
{ rep/dispet-1.i t }

DEFINE VARIABLE sym1  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym2  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym3  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym4  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym5  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym6  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym7  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym8  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym9  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym10 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym16 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym17 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym11 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym12 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym13 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym14 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym15 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .

define variable v-obj-name-list    as character    no-undo.
define variable v-i    as integer      no-undo.
define variable v-obj-list    as character    no-undo.
define variable v-rep-list    as character    no-undo.
define variable v-write-err as logical no-undo .

DEFINE STREAM out-stream.

FUNCTION number-from-string RETURNS INTEGER
  ( input p-name as character, input p-code as integer )  FORWARD.

FUNCTION get-report-file-name returns character
   ( input p-date as date, input p-time as integer) FORWARD.



define buffer buf_clients     for ub.clients .

/*************************************************
  MAIN-BLOCK

**************************************************/
do
on error  undo , return error return-value
on endkey undo , return error return-value
on stop   undo , return error return-value
   :
  ASSIGN
  v-rep-list = "Dispet"
  .
  if p-report-id = "50/2034" then do:
    p-rebh = buffer report-errorst:handle.
  end.
  if valid-handle(p-parent-handle)
  and lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0
  and valid-handle(p-rebh)
  and p-xml = yes
  then do:
    v-write-err = yes.
  end.


/*   { gbl/getcntxt.i get }*/
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

  define variable v-param-type as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .

  run adm/shattri.p (
      input "get":U
      ,input  '' /*p-obj-type*/
      ,input  0 /*p-obj-code*/
      ,input  {&attr-report-glob}
      ,input  {&attr-report-glob_rep-sort} /*p-param-code*/
                    , output v-sort-list
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
                    ) no-error.
  if error-status:error
  or v-sort-list = "":U
  then do:
    delete object v-tth.
    &scop my-message  "Не заполнен параметр {&attr-prt-glob_rep-sort} в секции Настройки для ОТЧЕТОВ - Сортировка топлива в отчетах по октановому числу" 
    {&display-message}.
    if p-xml
    and v-write-err
    then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-high}
                                                    ,input {&my-message}).
    end.
    RETURN ERROR.
  end.
  else do:
    assign
    v-sort     = true
    v-sort-max = NUM-ENTRIES(v-sort-list) + 10
    .
  end.
  delete object v-tth.
  DO v-i = 1 TO NUM-ENTRIES(p-cli-list):
    FIND FIRST buf_clients
        WHERE RECID(buf_clients) = integer(entry(v-i , p-cli-list))
        NO-LOCK
        NO-ERROR
    .
    CREATE obj-list.
    Buffer-copy buf_clients TO obj-list.
  END.
  IF  NOT CAN-FIND( FIRST obj-list) THEN DO:
    &scop my-message "Не выбрано ни одного объекта"
    {&display-message}.
    if p-xml
    and v-write-err
    then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-high}
                                                    ,input {&my-message}).
    end.
    RETURN ERROR.
  END.

   /* выборка данных */
  run fill-data in this-procedure .

  { gbl/working.i }
  /* открываем поток текстового вывода */
  run get-report-num in parParentProc ( output g#report-num).
  IF p-batch = integer({&repcalc-type-operator}) THEN DO:
    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
  END.
  if p-excel
  or p-batch = integer({&repcalc-type-operator})
  then do:
    RUN disp-xl-init IN THIS-PROCEDURE.

    /*  печатаем шапку */
    RUN print-header IN THIS-PROCEDURE .

    /* печать отчета*/
    run print-body in this-procedure .

    { rep/repfrm.i off }
    /* закрываем потоки */
    RUN disp-xl-close IN THIS-PROCEDURE .
  end.
  /* передаем управление пользователю */
  IF p-batch  > 0 THEN DO:
    IF p-excel THEN DO:
      RUN reprumpr_print-xlt (  input p-dir-excel
                               ,input ""
                               ,input get-report-file-name( p-date, p-time) + ".xls"
                               ,input 8 /*p-disable-option*/
                               ,input 7 /*p-font-number*/
                             ) no-error.
      if error-status:error then do:
      &scop my-message v-message
      {&display-message}.
      end.
    END.
    IF  p-xml THEN DO:
      RUN print-xml IN THIS-PROCEDURE.
    END.
  END.
  ELSE DO:
    output stream out-stream close.
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable ReportFontNum   as integer no-undo .
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
    os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
    .
    run gbl/prnfilen.w
        ( input  ""
        , input  8
        , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
        , input  ReportFontNum
        , output v-user-action
        , output v-printed
        ) .
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  END.
  empty temp-table tt-place.
  { gbl/stopwork.i }
end. /* MAIN-BLOCK */


/*==========================================================================*/
procedure fill-data :
define buffer buf_place       for ub.place .
define buffer buf_rvs-doc     for ub.rvs-doc .
define buffer buf_rvs-line    for ub.rvs-line .
define buffer buf_pl-gds      for ub.pl-gds .
define buffer buf_goods       for ub.goods .
define buffer buf_prod-bc     for ub.prod-bc .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_doc-line-attr     for ub.doc-line-attr .

define buffer buf_tt-place    for tt-place .
define buffer buf_obj-list    for obj-list.

define variable v-not-first-obj    as logical      no-undo.
define variable v-gds-name    as character    no-undo.
define variable v-gds-code    as integer      no-undo.
define variable v-attr-value    as character no-undo .
define variable v-attr-type     as character no-undo .
define variable v-number      as INTEGER    no-undo.
define variable v-cntxt-db-num    as INTEGER       no-undo .
define variable v-fact-order      as decimal       no-undo .
define variable v-res as logical no-undo.
define variable v-value as character no-undo.
define variable v-min-qnty as decimal no-undo .
define variable v-income   as decimal no-undo .
define variable v-current-sale  as decimal no-undo .

do
on error undo, return error
:
  run get-db-num in parparentproc ( output v-cntxt-db-num).
  _obj:
  FOR EACH buf_obj-list NO-LOCK:
    /* на УБД только текущий объект */
    IF  v-not-first-obj
    AND v-cntxt-db-num <> 0
    and p-batch = integer({&repcalc-type-operator})
    THEN DO:
      &scop my-message "на УБД для отчета допустим только текущий объект"
      {&display-message}.
      leave _obj.
    end.

    RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  buf_obj-list.obj-type
                                            , INPUT  buf_obj-list.obj-code
                                            ) .
    ASSIGN
    v-obj-list = v-obj-list + SUBSTITUTE("&1 &2", buf_obj-list.obj-type, buf_obj-list.obj-code) + ","
    .

    find last buf_rvs-doc
        where buf_rvs-doc.obj-type  = buf_obj-list.obj-type
          and buf_rvs-doc.obj-code  = buf_obj-list.obj-code
          and buf_rvs-doc.status_   = {&fact}
          and ((buf_rvs-doc.doc-date < p-date)
          OR  (buf_rvs-doc.doc-date = p-date
          AND buf_rvs-doc.fact-time < p-time))
          use-index stat-fact
        no-lock
        no-error
        .
    IF NOT AVAILABLE buf_rvs-doc THEN DO:
       &scop my-message  Substitute ( "На объекте &1 &2 нет закрытых сверок" ~
                                  , buf_obj-list.obj-code ~
                                  , buf_obj-list.obj-type ~
                                  )
      {&display-message}.
      if p-xml
      and v-write-err
      then do:
        run cb_write-report-error in p-parent-handle ( input p-rebh
                                                      ,input p-report-id
                                                      ,input ?
                                                      ,input {&severity-high}
                                                      ,input {&my-message}).
      end.
      next _obj.
    END.
    assign
    v-fact-order    = buf_rvs-doc.fact-order
    v-obj-name-list = IF v-obj-name-list = "":U
                      THEN buf_obj-list.obj-name
                      else SUBSTITUTE ( "&1, &2"
                                      , v-obj-name-list
                                      , buf_obj-list.obj-name
                                      )
    .
    FOR EACH  buf_place
        WHERE buf_place.obj-type = buf_obj-list.obj-type
          and buf_place.obj-code = buf_obj-list.obj-code
          and buf_place.status_ <> {&deleted-status}
        no-lock :
        assign  
          v-min-qnty = 0
          v-income = 0
          v-current-sale = 0 
        .  
        run placelib_get-attr(
              {&dead-balance},
              buf_place.obj-code,
              buf_place.obj-type,
              buf_place.pl-code,
              output v-value,
              output v-res
          ).
          if v-res then do:
              v-min-qnty = decimal(v-value).
          end.  

          for first buf_rvs-line-attr no-LOCK where buf_rvs-line-attr.attr-code = "income"
                                 and buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code
                                 and buf_rvs-line-attr.obj-code = buf_place.obj-code
                                 and buf_rvs-line-attr.obj-type = buf_place.obj-type
                                 and buf_rvs-line-attr.pl-code = buf_place.pl-code
                                 and buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code:
            v-income = DECIMAL (buf_rvs-line-attr.attr-value) .
          end.                                   

          for first buf_rvs-line-attr no-LOCK where buf_rvs-line-attr.attr-code = "current-sale"
                                 and buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code
                                 and buf_rvs-line-attr.obj-code = buf_place.obj-code
                                 and buf_rvs-line-attr.obj-type = buf_place.obj-type
                                 and buf_rvs-line-attr.pl-code = buf_place.pl-code
                                 and buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code:
            v-current-sale = DECIMAL (buf_rvs-line-attr.attr-value) .
          end.   
                              
      assign
      v-sort-code = v-sort-max
      v-gds-code  = 0
      v-gds-name  = "":U
      .
/*      assign                                                                       */
/*      v-number = number-from-string( buf_obj-list.obj-name, buf_obj-list.obj-code )*/
/*      .                                                                            */
      assign
      .
      create buf_tt-place.
      assign
      buf_tt-place.obj-type = buf_place.obj-type
      buf_tt-place.obj-code = buf_place.obj-code
      buf_tt-place.pl-code  = buf_place.pl-code
      buf_tt-place.loc1     = buf_place.loc1
      buf_tt-place.max-qnty = buf_place.max-qnty
      buf_tt-place.add-qnty = buf_place.add-qnty
      buf_tt-place.min-qnty = v-min-qnty
      buf_tt-place.current-sale = v-current-sale
      buf_tt-place.income = v-income
      buf_tt-place.is-meas    = buf_place.is-meas
      buf_tt-place.obj-number = buf_place.obj-code
      buf_tt-place.obj-name = buf_obj-list.obj-name
      buf_tt-place.obj-address = ( if v-fmtcli-index <> '':U then ( v-fmtcli-index ) else '':U )
                                + ( if v-fmtcli-full-addres <> '':U then ( v-fmtcli-full-addres ) else '':U )
      buf_tt-place.obj-phone   = ( if v-fmtcli-phone <> '':U then v-fmtcli-phone else '':U )
      buf_obj-list.obj-number  = (if   buf_obj-list.obj-number <> buf_tt-place.obj-number
                              then buf_tt-place.obj-number
                              else  buf_obj-list.obj-number)
      buf_obj-list.obj-address = (if  buf_obj-list.obj-address <> buf_tt-place.obj-address
                              then buf_tt-place.obj-address
                              else  buf_obj-list.obj-address)
      buf_obj-list.obj-phone   = (if  buf_obj-list.obj-phone <> buf_tt-place.obj-phone
                              then buf_tt-place.obj-phone
                              else  buf_obj-list.obj-phone)
      .
      IF available buf_rvs-doc then do:

        find first buf_rvs-line
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = buf_place.obj-type
                and buf_rvs-line.obj-code = buf_place.obj-code
                and buf_rvs-line.pl-code  = buf_place.pl-code
            no-lock
            no-error
            .

        if available buf_rvs-line then do:
          find  first buf_goods
                where buf_goods.gds-code = buf_rvs-line.gds-code
                no-lock
                no-error
                        .
          IF AVAILABLE buf_goods then do:
            assign
              v-gds-code = buf_goods.gds-code
              v-gds-name = buf_goods.gds-name
            .
            IF LOOKUP(string(buf_goods.gds-code) , v-sort-list) <> 0 then do:
              assign
                v-sort-code = LOOKUP(string(buf_goods.gds-code) , v-sort-list)
              .
            end.
            else do:
              assign
                v-sort-code = v-sort-max
              .
            end.
          end.
          else do:
            assign
            v-gds-code = buf_rvs-line.gds-code
            v-gds-name = SUBSTITUTE("Нет товара &1", buf_rvs-line.gds-code)
            .
          end.
          assign
          buf_tt-place.found-in-rvs  = TRUE
          buf_tt-place.curr-qnty     = buf_rvs-line.state-measure-qnty
          buf_tt-place.level-water   = buf_rvs-line.state-level-water
          buf_tt-place.volume-water  = buf_rvs-line.state-brutto-qnty - buf_rvs-line.state-measure-qnty
          buf_tt-place.curr-date     = buf_rvs-doc.fact-date
          buf_tt-place.curr-time     = buf_rvs-doc.fact-time
          buf_tt-place.curr-time-str = STRING(buf_rvs-doc.fact-time, "HH:MM:SS") + ".000"
          buf_tt-place.gds-code      = v-gds-code
          buf_tt-place.gds-name      = v-gds-name
          buf_tt-place.sort-code     = v-sort-code
          .
          find first buf_doc-line-attr
                where buf_doc-line-attr.doc-code   = buf_rvs-doc.rvs-code
                  and buf_doc-line-attr.gds-code   = buf_goods.gds-code
                  and buf_doc-line-attr.attr-code  = SUBSTITUTE("rvs-&1",buf_place.pl-code)
              no-lock
              no-error
              .
          if available buf_doc-line-attr then do:
            assign
            buf_tt-place.doc-qnty     = DECIMAL(ENTRY(1, buf_doc-line-attr.attr-value, {&delim-par}))
            .
          END.
        end.
      end.

      /* old
      IF buf_tt-place.found-in-rvs THEN DO:
        /* поиск более свежих сверок
        run get-next-rvs ( buffer buf_tt-place
                          , input buf_rvs-doc.fact-order
                          ) .
        */
      END.
      ELSE DO:
        /* поиск более ранних сверок */
        run get-prev-rvs ( buffer buf_tt-place
                          , input buf_rvs-doc.fact-order
                          ) .
      END.
      */

      /*
      IF NOT buf_tt-place.found-in-rvs THEN DO:
          find first buf_rvs-line
                where  buf_rvs-line.obj-type = buf_tt-place.obj-type
                  and buf_rvs-line.obj-code = buf_tt-place.obj-code
                  and buf_rvs-line.pl-code  = buf_tt-place.pl-code
                no-lock
                no-error
                .
        IF NOT AVAILABLE buf_rvs-line
        THEN DO:
            DELETE buf_tt-place.
            NEXT.
        END.
      END.
          */
    END. /* EACH  buf_place */

    IF CAN-FIND (FIRST buf_tt-place
                  WHERE buf_tt-place.obj-type = buf_obj-list.obj-type
                    AND buf_tt-place.obj-code = buf_obj-list.obj-code
                    AND buf_tt-place.found-in-rvs = FALSE)
    THEN DO:
        /* поиск более ранних сверок */
      run get-prev-rvs ( input v-fact-order
                        , input buf_obj-list.obj-type
                        , input buf_obj-list.obj-code
                          ) .
    END.
    FOR EACH buf_tt-place
          where  buf_tt-place.obj-type = buf_obj-list.obj-type
            and buf_tt-place.obj-code = buf_obj-list.obj-code
            and buf_tt-place.found-in-rvs = FALSE
          :
      DELETE buf_tt-place.
    END.


      /* расчет продаж... */
      /* ...за предыдущий день */
    run fill-sale IN THIS-PROCEDURE
                    ( input buf_obj-list.obj-type
                    , input buf_obj-list.obj-code
                    , input (p-date - 1)
                    , INput YES
                    ).
      /* ...недельной давности */
    run fill-sale IN THIS-PROCEDURE
                    ( input buf_obj-list.obj-type
                    , input buf_obj-list.obj-code
                    , input (p-date - 7)
                    , INput NO
                    ).

    release buf_rvs-doc.
    assign
    v-not-first-obj = TRUE
    .
  END. /* each buf_obj-list */

   /* выбрасываем все, кроме топлива */
  FOR EACH buf_tt-place :
    assign
    v-attr-value = ?
    v-attr-type  = ?
    .
    run gds-attr-value in this-procedure
        ( input  buf_tt-place.gds-code
        , input  {&attr-ptrl-without-rvs}
        , output v-attr-value
        , output v-attr-type
        ) .
    if lookup(v-attr-value, 'true,yes':u) > 0
    then do:
      delete buf_tt-place.
    end.
  end. /*  FOR EACH buf_tt-place :*/
end. /* do on error */
end procedure. /* fill-data */

/*==========================================================================*/
procedure fill-sale :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-sale-date  as date             no-undo.
define input parameter p-day        as logical          no-undo.

define variable v-prev-gds-code    as integer      no-undo.

define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_tt-place    for tt-place .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_inkas       for ub.inkas .

do
on error undo, return error
:
   for each  buf_chk-doc
      where  buf_chk-doc.obj-type = p-obj-type
         and buf_chk-doc.obj-code = p-obj-code
         and buf_chk-doc.chk-date = p-sale-date
         and (buf_chk-doc.chk-type = INTEGER({&rcpt-sale})
          OR  buf_chk-doc.chk-type = INTEGER({&rcpt-return}))
         and buf_chk-doc.out-code <> ?
         no-lock
         ,
        first buf_inkas
        where buf_inkas.inkas-code = buf_chk-doc.out-code
          and buf_inkas.status_    = {&fact}
      no-lock
      :

      ASSIGN
         v-prev-gds-code = 0
      .

      _place:
      FOR EACH  buf_tt-place
      where buf_tt-place.obj-type = p-obj-type
        and buf_tt-place.obj-code = p-obj-code
      :

/*         IF v-prev-gds-code = buf_tt-place.gds-code THEN DO:*/
/*            NEXT _place.                                    */
/*         END.                                               */

         FIND FIRST buf_bar-code
               where buf_bar-code.gds-code = buf_tt-place.gds-code
            NO-LOCK
            .


         FOR each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
            and buf_chk-gds.b-code = buf_bar-code.b-code
            and buf_chk-gds.loc1 = buf_tt-place.loc1
         no-lock
         :
            IF p-day then do:
               assign
                  buf_tt-place.sale-qnty-1 = buf_tt-place.sale-qnty-1 + buf_chk-gds.doc-qnty
               .
            end.
            else do:
               assign
                  buf_tt-place.sale-qnty-7 = buf_tt-place.sale-qnty-7 + buf_chk-gds.doc-qnty
               .
            end.
         end. /* each buf_chk-gds */
         ASSIGN
            v-prev-gds-code = buf_tt-place.gds-code
         .
      END. /* EACH  buf_tt-place */
   end. /* each buf_chk-doc */
end. /* do on error */
end procedure. /* fill-sale */


/*==========================================================================*/
procedure print-header :

do
on error undo, return error
:
   IF p-batch = integer({&repcalc-type-operator})
   THEN DO:
   put stream out-stream
      "ОТЧЕТ ДИСПЕТЧЕРА" at 25 skip(1)

      "АЗС: " v-obj-name-list FORMAT "x({&frame-width})"skip
         "Дата отчета:" p-date " время отчета:" STRING(p-time, "HH:MM:SS") skip(1)
"+--------------------+----------------------------------+---------------+---------------+--------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+--------+--------+-----------+"       skip
"|                    |                                  |               |               |        |           |           |           |           |           |           |           |        |        |           |"       skip
"|        АЗС         |              Адрес               |    телефон    |     Марка     | № ре-  |   Объем   |  Трубо-   | Ожидаемая | Фактиче-  | Уровень   |   Объем   | Остаток   |  Дата  | Время  |реализация |"       skip
"|                    |                                  |               |     н/пр      | зерву- |           |  провод   | реализация| ский      | воды, см  |  воды, л  | по чекам  |  изме- | изме-  |( прошлые  |"       skip
"|                    |                                  |               |               | ара    |           |           |           | остаток   |           |           | и док-ам  |  рения | рения  |   сутки ) |"       skip
"|                    |                                  |               |               |        |           |           |           |           |           |           |           |        |        |           |"       skip
"+--------------------+----------------------------------+---------------+---------------+--------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+--------+--------+-----------+"       skip
   .
   END.
   run disp-xl-write-cell-data in this-procedure ( input {&disp-xl-h_obj-name-list},  input v-obj-name-list ).
   run disp-xl-write-cell-data in this-procedure ( input {&disp-xl-h_date},           input p-date ) .
   run disp-xl-write-cell-data in this-procedure ( input {&disp-xl-h_time},           input STRING( p-time, "HH:MM:SS" ) ) .

end. /* do on error */
end procedure. /* print-header */


/*==========================================================================*/
procedure print-body :

define buffer buf_tt-place    for tt-place .

define variable v-line    as character    no-undo.

  define frame f-first
    sym1                       no-label format "X(1)"       space(0)
    buf_tt-place.obj-name      no-label format "X(20)"      space(0)
    sym2                       no-label format "X(1)"       space(0)
    buf_tt-place.obj-address   no-label format "X(34)"      space(0)
    sym3                       no-label format "X(1)"       space(0)
    buf_tt-place.obj-phone     no-label format "X(15)"      space(0)
    sym4                       no-label format "X(1)"       space(0)
    buf_tt-place.gds-name      no-label format "x(15)"      space(0)
    sym5                       no-label format "X(1)"       space(0)
    buf_tt-place.loc1          no-label format "X(8)"       space(0)
    sym6                       no-label format "X(1)"       space(0)
    buf_tt-place.max-qnty      no-label format "->>>,>>9.99" space(0)
    sym7                       no-label format "X(1)"       space(0)
    buf_tt-place.add-qnty      no-label format "->>>,>>9.99" space(0)
    sym8                       no-label format "X(1)"       space(0)
    buf_tt-place.sale-qnty-7   no-label format "->>>,>>9.99" space(0)
    sym9                       no-label format "X(1)"       space(0)
    buf_tt-place.curr-qnty     no-label format "->>>,>>9.99" space(0)
    sym16                      no-label format "X(1)"       space(0)
    buf_tt-place.level-water   no-label format "->>>,>>9.99" space(0)
    sym17                      no-label format "X(1)"       space(0)
    buf_tt-place.volume-water  no-label format "->>>,>>9.99" space(0)
    sym10                      no-label format "X(1)"       space(0)
    buf_tt-place.doc-qnty      no-label format "->>>,>>9.99" space(0)
    sym15                      no-label format "X(1)"       space(0)
    buf_tt-place.curr-date     no-label format "99/99/99"   space(0)
    sym12                      no-label format "X(1)"       space(0)
    buf_tt-place.curr-time-str no-label format "X(8)"       space(0)
    sym13                      no-label format "X(1)"       space(0)
    buf_tt-place.sale-qnty-1   no-label format "->>>,>>9.99" space(0)
    sym14                      no-label format "X(1)"       space(0)
    skip
/*
  header
    "+--------------------+----------------------------------+---------------+---------------+--------+-----------+----------+-----------+----------+-----------+--------+--------+-----------+" skip
    "|                    |                                  |               |               |        |           |          |           |          |           |        |        |           |" skip
    "|        АЗС         |              Адрес               |    телефон    |     Марка     | № ре-  |   Объем   | Мертвый  | Ожидаемая | Фактиче- | Остаток   |  Дата  | Время  |реализация |" skip
    "|                    |                                  |               |     н/пр      | зерву- |           | остаток  | реализация| ский     | по чекам  |  изме- | изме-  |( прошлые  |" skip
    "|                    |                                  |               |               | ара    |           |          |           | остаток  | и док-ам  |  рения | рения  |   сутки ) |" skip
    "|                    |                                  |               |               |        |           |          |           |          |           |        |        |           |" skip
*/
  with width {&frame-width} down stream-io no-labels no-box.

do
on error undo, return error
:
   assign
      v-line        = fill( "-" , {&frame-width} )
   .

   FOR EACH buf_tt-place
   :
      /* выводим ТОЛЬКО товары присутствующие в списке сортировки,
         чтобы исключить незамерзайку */
      IF buf_tt-place.sort-code >= v-sort-max
      OR buf_tt-place.sort-code <= 0
      THEN DO:
         DELETE buf_tt-place.
      END.
   end.


   FOR EACH buf_tt-place
       BREAK BY buf_tt-place.obj-number
             BY buf_tt-place.sort-code
             BY buf_tt-place.gds-code
   :

      IF FIRST-OF (buf_tt-place.obj-number)
      then do:
         IF p-batch = integer({&repcalc-type-operator})
         THEN DO:
         DISPLAY STREAM out-stream
               buf_tt-place.obj-name
               buf_tt-place.obj-address
               buf_tt-place.obj-phone
               buf_tt-place.gds-name
               buf_tt-place.loc1
               buf_tt-place.max-qnty
               buf_tt-place.add-qnty
               buf_tt-place.sale-qnty-7
/*                  (IF buf_tt-place.is-meas THEN buf_tt-place.curr-qnty ELSE 0 ) @ buf_tt-place.curr-qnty*/
               buf_tt-place.curr-qnty
               buf_tt-place.level-water
               buf_tt-place.volume-water
               buf_tt-place.doc-qnty
               buf_tt-place.curr-date
               buf_tt-place.curr-time-str
               buf_tt-place.sale-qnty-1

                  sym1  sym2  sym3
               sym4  sym5  sym6
               sym7  sym8  sym9
                  sym16 sym17 
                  sym10 sym12
               sym13 sym14 sym15

         with frame f-first.
         down stream out-stream with frame f-first
         .
         END.
         run disp-xl-write-line-data IN THIS-PROCEDURE
                     ( INPUT buf_tt-place.obj-name
                     , INPUT buf_tt-place.obj-address
                     , INPUT buf_tt-place.obj-phone
                     , INPUT buf_tt-place.gds-name
                     , INPUT buf_tt-place.loc1
                     , INPUT buf_tt-place.max-qnty
                     , INPUT buf_tt-place.add-qnty
                     , INPUT buf_tt-place.sale-qnty-7
/*                     , INPUT IF buf_tt-place.is-meas THEN buf_tt-place.curr-qnty ELSE 0*/
                     , INPUT buf_tt-place.curr-qnty
                     , INPUT buf_tt-place.level-water
                     , INPUT buf_tt-place.volume-water
                     , INPUT buf_tt-place.doc-qnty
                     , INPUT buf_tt-place.curr-date
                     , INPUT buf_tt-place.curr-time-str
                     , INPUT buf_tt-place.sale-qnty-1
                     ) .
      end. /* FIRST-OF (buf_tt-place.obj-code) */
      ELSE DO:
         IF FIRST-OF (buf_tt-place.gds-code)
         then do:
            IF p-batch = integer({&repcalc-type-operator})
            THEN DO:
            DISPLAY STREAM out-stream
                  "":U @ buf_tt-place.obj-name
                  "":U @ buf_tt-place.obj-address
                  "":U @ buf_tt-place.obj-phone
                  buf_tt-place.gds-name
                  buf_tt-place.loc1
                  buf_tt-place.max-qnty
                  buf_tt-place.add-qnty
                  buf_tt-place.sale-qnty-7
/*                     (IF buf_tt-place.is-meas THEN buf_tt-place.curr-qnty ELSE 0) @ buf_tt-place.curr-qnty*/
                  buf_tt-place.curr-qnty
                  buf_tt-place.level-water
                  buf_tt-place.volume-water
                  buf_tt-place.doc-qnty
                  buf_tt-place.curr-date
                  buf_tt-place.curr-time-str
                  buf_tt-place.sale-qnty-1
                     sym1  sym2  sym3
                  sym4  sym5  sym6
                  sym7  sym8  sym9
                     sym16 sym17 
                     sym10 sym12 sym15
                  sym13 sym14
            with frame f-first.
            down stream out-stream with frame f-first
            .
            END.
            run disp-xl-write-line-data IN THIS-PROCEDURE
                        ( INPUT "":U
                        , INPUT "":U
                        , INPUT "":U
                        , INPUT buf_tt-place.gds-name
                        , INPUT buf_tt-place.loc1
                        , INPUT buf_tt-place.max-qnty
                        , INPUT buf_tt-place.add-qnty
                        , INPUT buf_tt-place.sale-qnty-7
/*                        , INPUT IF buf_tt-place.is-meas THEN buf_tt-place.curr-qnty ELSE 0*/
                        , INPUT buf_tt-place.curr-qnty
                        , INPUT buf_tt-place.level-water
                        , INPUT buf_tt-place.volume-water
                        , INPUT buf_tt-place.doc-qnty
                        , INPUT buf_tt-place.curr-date
                        , INPUT buf_tt-place.curr-time-str
                        , INPUT buf_tt-place.sale-qnty-1
                        ) .
         end. /* FIRST-OF (buf_tt-place.gds-code) */
         else do:
            IF p-batch = integer({&repcalc-type-operator})
            THEN DO:
            DISPLAY STREAM out-stream
                  "":U @ buf_tt-place.obj-name
                     /*
                  "":U @ buf_tt-place.obj-address
                  "":U @ buf_tt-place.obj-phone
                     */
                  buf_tt-place.gds-name
                  buf_tt-place.loc1
                  buf_tt-place.max-qnty
                  buf_tt-place.add-qnty
                  "":U @ buf_tt-place.sale-qnty-7
/*                     (IF buf_tt-place.is-meas THEN buf_tt-place.curr-qnty ELSE 0) @ buf_tt-place.curr-qnty*/
                  buf_tt-place.curr-qnty
                  buf_tt-place.level-water
                  buf_tt-place.volume-water
                  buf_tt-place.curr-date
                  buf_tt-place.curr-time-str
                  "":U @ buf_tt-place.sale-qnty-1
                     sym1  /* sym2  sym3 */
                  sym4  sym5  sym6
                  sym7  sym8  sym9
                     sym16 sym17 sym10 sym12
                  sym13 sym14
            with frame f-first.
            down stream out-stream with frame f-first
            .
            END.
            run disp-xl-write-line-data IN THIS-PROCEDURE
                        ( INPUT "":U
                        , INPUT "":U
                        , INPUT "":U
                        , INPUT buf_tt-place.gds-name
                        , INPUT buf_tt-place.loc1
                        , INPUT buf_tt-place.max-qnty
                        , INPUT buf_tt-place.add-qnty
                        , INPUT "":U
/*                        , INPUT IF buf_tt-place.is-meas THEN buf_tt-place.curr-qnty ELSE 0*/
                        , INPUT buf_tt-place.curr-qnty
                        , INPUT buf_tt-place.level-water
                        , INPUT buf_tt-place.volume-water
                        , INPUT buf_tt-place.doc-qnty
                        , INPUT buf_tt-place.curr-date
                        , INPUT buf_tt-place.curr-time-str
                        , INPUT "":U
                        ) .
         end.
      END.
      IF LAST-OF (buf_tt-place.obj-number)
      AND p-batch = integer({&repcalc-type-operator})
      then do:
         put stream out-stream
            v-line   FORMAT "x({&frame-width})"
         .
      end.
   end. /* EACH buf_tt-place */
end. /* do on error */
end procedure. /* print-body */

/*==========================================================================*/
procedure get-prev-rvs :
define input parameter p-fact-order as decimal          no-undo.
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.

define buffer buf_tt-place FOR tt-place.

define variable v-fact-order    as decimal      no-undo.
define variable v-gds-name    as character    no-undo.
define variable v-gds-code    as integer      no-undo.

define buffer buf_rvs-doc  for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .
define buffer buf_goods    for ub.goods .
define buffer buf_prod-bc     for ub.prod-bc .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_doc-line-attr     for ub.doc-line-attr .

do
on error undo, return error
:
   assign
      v-fact-order = p-fact-order
   .
   do while CAN-FIND (FIRST buf_tt-place
                      WHERE buf_tt-place.obj-type = p-obj-type
                        AND buf_tt-place.obj-code = p-obj-code
                        AND buf_tt-place.found-in-rvs = FALSE
                        ) :
      FIND LAST buf_rvs-doc
         where buf_rvs-doc.obj-type = p-obj-type
         and buf_rvs-doc.obj-code   = p-obj-code
         and buf_rvs-doc.status_    = {&fact}
         and buf_rvs-doc.fact-order < v-fact-order
         no-lock
         no-error
         .
      IF available buf_rvs-doc then do:
         FOR EACH buf_tt-place
            WHERE buf_tt-place.obj-type = p-obj-type
              AND buf_tt-place.obj-code = p-obj-code
              AND buf_tt-place.found-in-rvs = FALSE
            NO-LOCK
            ,
            first  buf_rvs-line
            where  buf_rvs-line.rvs-code  = buf_rvs-doc.rvs-code
               and buf_rvs-line.obj-type = buf_tt-place.obj-type
               and buf_rvs-line.obj-code = buf_tt-place.obj-code
               and buf_rvs-line.pl-code  = buf_tt-place.pl-code
            no-lock
            :
               find  first buf_goods
                     where buf_goods.gds-code = buf_rvs-line.gds-code
                     no-lock
                     no-error
                     .
               assign
                  v-sort-code = v-sort-max
                  v-gds-code  = 0
                  v-gds-name  = "":U
               .
               IF AVAILABLE buf_goods then do:
                  assign
                     v-gds-code = buf_goods.gds-code
                     v-gds-name = buf_goods.gds-name
                  .
                  IF LOOKUP(string(buf_goods.gds-code) , v-sort-list) <> 0 then do:
                    assign
                        v-sort-code = LOOKUP(string(buf_goods.gds-code) , v-sort-list)
                    .
                  end.
                  else do:
                    assign
                        v-sort-code = v-sort-max
                    .
                  end.

                  IF AVAILABLE buf_prod-bc THEN dO:
                  end.
               end.
               else do:
                  assign
                     v-gds-code = buf_rvs-line.gds-code
                     v-gds-name = SUBSTITUTE("Нет товара &1", buf_rvs-line.gds-code)
                  .
               end.
               assign
                  buf_tt-place.found-in-rvs  = TRUE
                  buf_tt-place.curr-qnty     = buf_rvs-line.state-measure-qnty
                  buf_tt-place.level-water   = buf_rvs-line.state-level-water
                  buf_tt-place.volume-water  = buf_rvs-line.state-brutto-qnty - buf_rvs-line.state-measure-qnty
                  buf_tt-place.curr-date     = buf_rvs-doc.fact-date
                  buf_tt-place.curr-time     = buf_rvs-doc.fact-time
                  buf_tt-place.curr-time-str = STRING(buf_rvs-doc.fact-time, "HH:MM:SS") + ".000"
                  buf_tt-place.gds-code      = v-gds-code
                  buf_tt-place.gds-name      = v-gds-name
                  buf_tt-place.sort-code     = v-sort-code
               .
               find first buf_doc-line-attr
                  where buf_doc-line-attr.doc-code   = buf_rvs-doc.rvs-code
                     and buf_doc-line-attr.gds-code   = buf_goods.gds-code
                     and buf_doc-line-attr.attr-code  = SUBSTITUTE("rvs-&1",buf_rvs-line.pl-code)
                  no-lock
                  no-error
                  .
               if available buf_doc-line-attr then do:
                     assign
                        buf_tt-place.doc-qnty     = DECIMAL(ENTRY(1, buf_doc-line-attr.attr-value, {&delim-par}))
                     .
               END.
         end.
      end.
      ELSE DO:
         RETURN.
      END.
      assign
         v-fact-order = buf_rvs-doc.fact-order
      .
   end.
end. /* do on error */

/*
define parameter buffer buf_tt-place FOR tt-place.
define input parameter p-fact-order as decimal          no-undo.

define variable v-fact-order    as decimal      no-undo.
define variable v-gds-name    as character    no-undo.
define variable v-gds-code    as integer      no-undo.

define buffer buf_rvs-doc  for rvs-doc .
define buffer buf_rvs-line for rvs-line .
define buffer buf_goods    for goods .
define buffer buf_prod-bc     for ub.prod-bc .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_doc-line-attr     for doc-line-attr .

do
on error undo, return error
:
assign
   v-fact-order = p-fact-order
.

do while not buf_tt-place.found-in-rvs :
   FIND LAST buf_rvs-doc
      where buf_rvs-doc.obj-type = buf_tt-place.obj-type
      and buf_rvs-doc.obj-code   = buf_tt-place.obj-code
      and buf_rvs-doc.status_    = {&fact}
      and buf_rvs-doc.fact-order < v-fact-order
      no-lock
      no-error
      .
   IF available buf_rvs-doc then do:
      find first buf_rvs-line
            where buf_rvs-line.rvs-code  = buf_rvs-doc.rvs-code
               and buf_rvs-line.obj-type = buf_tt-place.obj-type
               and buf_rvs-line.obj-code = buf_tt-place.obj-code
               and buf_rvs-line.pl-code  = buf_tt-place.pl-code
            no-lock
            no-error
            .
      if available buf_rvs-line then do:
         find  first buf_goods
               where buf_goods.gds-code = buf_rvs-line.gds-code
               no-lock
               no-error
               .
         assign
            v-sort-code = v-sort-max
            v-gds-code  = 0
            v-gds-name  = "":U
         .
         IF AVAILABLE buf_goods then do:
            find first buf_bar-code
                  where buf_bar-code.gds-code = buf_goods.gds-code
                  no-lock
                  no-error
                  .
            find first buf_prod-bc
                  where buf_prod-bc.b-code = buf_bar-code.b-code
                  no-lock
                  no-error
                  .
            assign
               v-gds-code = buf_goods.gds-code
               v-gds-name = buf_goods.gds-name
            .
            IF AVAILABLE buf_prod-bc THEN dO:
               IF LOOKUP(buf_prod-bc.b-str , v-sort-list) <> 0 then do:
                  assign
                     v-sort-code = LOOKUP(buf_prod-bc.b-str , v-sort-list)
                  .
               end.
               else do:
                  assign
                     v-sort-code = v-sort-max
                  .
               end.
            end.
         end.
         else do:
            assign
               v-gds-code = buf_rvs-line.gds-code
               v-gds-name = SUBSTITUTE("Нет товара &1", buf_rvs-line.gds-code)
            .
         end.
         assign
            buf_tt-place.found-in-rvs  = TRUE
            buf_tt-place.curr-qnty     = buf_rvs-line.state-measure-qnty
            buf_tt-place.curr-date     = buf_rvs-doc.fact-date
            buf_tt-place.curr-time     = buf_rvs-doc.fact-time
            buf_tt-place.curr-time-str = STRING(buf_rvs-doc.fact-time, "HH:MM:SS")
            buf_tt-place.gds-code      = v-gds-code
            buf_tt-place.gds-name      = v-gds-name
            buf_tt-place.sort-code     = v-sort-code
         .
         find first buf_doc-line-attr
            where buf_doc-line-attr.doc-code   = buf_rvs-doc.rvs-code
               and buf_doc-line-attr.gds-code   = buf_goods.gds-code
               and buf_doc-line-attr.attr-code  = SUBSTITUTE("rvs-&1",buf_rvs-line.pl-code)
            no-lock
            no-error
            .
         if available buf_doc-line-attr then do:
               assign
                  buf_tt-place.doc-qnty     = DECIMAL(ENTRY(1, buf_doc-line-attr.attr-value, {&delim-par}))
               .
         END.
         RETURN.
      end.
      else do:
         assign
            v-fact-order = buf_rvs-doc.fact-order
         .
         RELEASE buf_rvs-doc.
      end.
   end.
   ELSE DO:
      RETURN.
   END.
end.
end. /* do on error */
*/
end procedure. /* get-prev-rvs */


procedure get-next-rvs :
define parameter buffer buf_tt-place FOR tt-place.
define input parameter p-fact-order as decimal          no-undo.

define buffer buf_rvs-doc     for ub.rvs-doc .
define buffer buf_rvs-line    for ub.rvs-line .
do
on error undo, return error
:

   FOR EACH buf_rvs-doc
      where buf_rvs-doc.obj-type = buf_tt-place.obj-type
      and buf_rvs-doc.obj-code   = buf_tt-place.obj-code
      and buf_rvs-doc.status_    = {&fact}
      and buf_rvs-doc.fact-order > p-fact-order
      no-lock
   :
      find first buf_rvs-line
            where buf_rvs-line.rvs-code  = buf_rvs-doc.rvs-code
               and buf_rvs-line.obj-type = buf_tt-place.obj-type
               and buf_rvs-line.obj-code = buf_tt-place.obj-code
               and buf_rvs-line.pl-code  = buf_tt-place.pl-code
               and buf_rvs-line.gds-code = buf_tt-place.gds-code
            no-lock
            no-error
            .
      if available buf_rvs-line then do:
         assign
            buf_tt-place.found-in-rvs  = TRUE
            buf_tt-place.curr-qnty     = buf_rvs-line.state-measure-qnty
            buf_tt-place.level-water   = buf_rvs-line.state-level-water
            buf_tt-place.volume-water  = buf_rvs-line.state-brutto-qnty - buf_rvs-line.state-measure-qnty
            buf_tt-place.curr-date     = buf_rvs-doc.fact-date
            buf_tt-place.curr-time     = buf_rvs-doc.fact-time
            buf_tt-place.curr-time-str = STRING(buf_rvs-doc.fact-time, "HH:MM:SS") + ".000"
         .
      end.
   end.
end. /* do on error */
end procedure. /* get-next-rvs */

FUNCTION number-from-string RETURNS INTEGER
  ( input p-name as character
  , input p-code as integer
  ) :

define variable v-temp-number as character    no-undo.
define variable v-temp-char   as character    no-undo.
define variable v-count       as integer      no-undo.
define variable v-found       as logical      no-undo.

_find:
DO v-count = 1 to LENGTH(p-name):
  assign
      v-temp-char = substring( p-name, v-count, 1)
  .
  IF LOOKUP(v-temp-char, "0,1,2,3,4,5,6,7,8,9") > 0 THEN DO:
      ASSIGN
        v-temp-number = v-temp-number + v-temp-char
        v-found = TRUE
      .
  END.
  ELSE DO:
      IF v-found
      THEN LEAVE _find .
  END.
END.

IF v-temp-number <> ""
THEN RETURN INTEGER(v-temp-number) .
ELSE RETURN p-code + 1000000 .

END FUNCTION.

function get-report-file-name returns character ( input p-date as date
                                          ,input p-time as integer):
DEFINE VARIABLE v-hour     AS INTEGER.
DEFINE VARIABLE v-minute   AS INTEGER.
DEFINE VARIABLE v-sec      AS INTEGER.
DEFINE VARIABLE v-timeleft AS INTEGER.


/* seconds till next midnight */
v-sec = p-time MOD 60.
v-timeleft = (p-time - v-sec) / 60.

/* minutes till next midnight */
v-minute = v-timeleft MOD 60.

/* hours till next midnight */
v-hour = (v-timeleft - v-minute) / 60.
return SUBSTITUTE("&1_&2-&3", STRING(p-date, "99-99-9999") , STRING(v-hour, "99"), STRING(v-minute, "99")).
end function.






/*======================================*/
procedure print-xml :
define variable v-gate-rec as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .

define buffer buf_temp-xml-tables for temp-xml-tables.
v-xmlh = buffer buf_temp-xml-tables:handle.
if p-report-id  = "52/2039" then do:
  run get-gate-rec in this-procedure ( input p-xsd-file
                                      ,output v-gate-rec) no-error.
  if error-status:error then do:
    undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", p-xsd-file).
  end.
  /*create p_dataset внутри get-gate-by-rec*/
  v-longchar = ?.
  run get-gate-by-rec in this-procedure ( input v-gate-rec
                                        ,output v-dataseth
                                        ,input-output v-xmlh
                                        ,input-output v-longchar
                                        ) no-error.
  if error-status:error then do:
    &scop my-message substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2&3&2&4" ~
                              , v-gate-rec ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1) ~
                              , return-value )
    {&display-message}.
    delete object v-dataseth no-error.
    undo, return error '':U.
  end.
end.
else do:
  define variable v-xsd-file as character no-undo .
  v-xsd-file = search(p-xsd-file).
  run get-gate-by-file in this-procedure ( input v-xsd-file
                                          ,input '' /*p-gate-rec*/
                                          ,output v-dataseth
                                          ,input-output v-xmlh
                                          ) no-error.
  if error-status:error then do:
    &scop my-message substitute("Ошибка при создании структуры маршрутизируемых данных согласно схеме:&1&2&3&2&4" ~
                              , v-gate-rec ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1) ~
                              , return-value )
    {&display-message}.
    delete object v-dataseth no-error.
    undo, return error '':U.
  end.
  /*запоним шапку отчета*/
  run cb_fill-report-header in p-parent-handle ( input buffer report-headert:handle
                                                ,input p-report-id
                                                ,input "dispet"
                                                ,input "Отчет диспетчера"
                                                ,input v-start-datetime
                                                ,input cur-time-datetime()
                                                ).
  run cb_fill-report-parameters in p-parent-handle ( input buffer report-parameterst:handle
                                                    ,input p-report-id
                                                    ).
  run cb_write-report-parameter in p-parent-handle (
                                                      input (buffer report-parameterst:handle)
                                                     ,input p-report-id
                                                     ,input "p-data-datetime"
                                                     ,input "Дата-время"
                                                     ,input {&abl-datatype-character}
                                                     ,input substitute("&1 &2.000"
                                                                      , string(p-date, "99/99/9999")
                                                                      , string(p-time, "hh:mm:ss"))
                                                     ,input ?
                                                     ,input 0.0
                                                     ,input 0
                                                     ,input no
                                                     ,input 0
                                                     ,input 'Дата-время актуальность данных отчета'
                                                     ).

end.
_xml-tables:
for each buf_temp-xml-tables:
  case buf_temp-xml-tables.tbl-name:
    when "Dispet" then do:
      buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer obj-list:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "dispetRow" then do:
      buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer tt-place:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "report-header" then do:
      if p-report-id  <> "52/2039" then do:
        buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                        buffer report-headert:handle
                                                      , yes /*append-mode*/
                                                      , no /*replace-mode*/
                                                      , yes /*loose-mode*/
                                                      ) no-error.
      end.
    end.
    when "report-parameters" then do:
      if p-report-id  <> "52/2039" then do:
        buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                        buffer report-parameterst:handle
                                                      , yes /*append-mode*/
                                                      , no /*replace-mode*/
                                                      , yes /*loose-mode*/
                                                      ) no-error.
      end.
    end.
    when "report-errors" then do:
      if p-report-id  <> "52/2039" then do:
        buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                        buffer report-errorst:handle
                                                      , yes /*append-mode*/
                                                      , no /*replace-mode*/
                                                      , yes /*loose-mode*/
                                                      ) no-error.
      end.
    end.
    otherwise do:
      next _xml-tables.
    end.
  end case.
  if error-status:error then do:
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-extreme}
                                                    ,input substitute("Ошибка при сохранении в XML отчета диспетчера - таблица &1&2&3&2&4"
                                                                      , buf_temp-xml-tables.tbl-name
                                                                      , {&new-line}
                                                                      , error-status:get-message(1)
                                                                      , return-value
                                                                      )).
    end.
  end.
end. /*for each buf_temp-xml-tables:*/
if p-report-id  = "52/2039" then do:
  p-dataseth = v-dataseth.
  p-xmlh = v-xmlh.
end.
else do:
  v-dataseth:write-xml("FILE"
                    , (p-dir-xml +  get-report-file-name( p-date, p-time) + ".xml")
                    , yes /*lFormatted*/
                    , "windows-1251"
                    , ? /*schemaloc*/
                    , no /*writeschema*/
                    , no /*lMinSchema*/) no-error.
  if error-status:error then do:
    &scop my-message substitute("Ошибка при записи данных в файл согласно схеме:&1&2&3&2&4" ~
                              , p-xsd-file ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1) ~
                              , return-value )
    {&display-message}.
    delete object v-dataseth no-error.
    undo, return error '':U.
  end.
  run gate-clear in this-procedure ( input v-dataseth
                                   ,input v-xmlh) no-error.
end.

end procedure. /* print-xml */