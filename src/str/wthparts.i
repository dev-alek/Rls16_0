 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека работы с партиями Материальных ценностей

Автор: Гридчина Полина Дмитриевна
Дата создания: 01/07/07
Author: Polina Gridchina
Creation date: 01/07/07

Input:

Output:

*/
/*{ cmp/trg-def.i  }    */

{ cmp/str-glbl.i }
&if "{1}"  = 'def'
&THEN  { cmp/trg-def.i  }
&ENDIF
/*{ cmp/trg-def.i  }  */
/*{ cmp/library.i  }   */
{ gbl/thbjattr.i }
{ str/mpl-auto.i }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ str/wthcalib.i }
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
def temp-table tt-wthlib-parts no-undo like ub.wth-parts.

/*Закрытие партии */
Procedure wth-doc-close:
    define input parameter p-rec        as recid     no-undo .
    DEFINE BUFFER cur-wth-parts FOR ub.wth-parts.
  do
  on error undo, return error return-value
  :
    find first cur-wth-parts where recid(cur-wth-parts) = p-rec exclusive-lock no-wait no-error.
    if not available cur-wth-parts then return error substitute("Не найдена партия").
    CASE cur-wth-parts.ext-doc-type:
        WHEN {&WDEDT_Inc_Ext} or when {&WDEDT_Ret_Int_Free} or when {&WDEDT_Inc_Int_free}
        OR WHEN {&WDEDT_Inc_Obj_Free}
        THEN DO:  /* внеш. приход */
           RUN wth-parts-close(BUFFER cur-wth-parts, {&free-code} ).
        END.
        WHEN {&WDEDT_Exp_Ext} THEN DO:
            RUN wth-parts-close(BUFFER cur-wth-parts, {&cli-zone} ).
        END.
        WHEN {&WDEDT_Put_Sale} OR WHEN {&WDEDT_Put_Cli} OR WHEN {&WDEDT_Ret_Int_Put}
          OR WHEN {&WDEDT_Inc_Int_Put} OR WHEN {&WDEDT_Put_Cash}
          OR WHEN {&WDEDT_Inc_Obj_Put}
           THEN DO:
            RUN wth-parts-close(BUFFER cur-wth-parts, {&put-zone} ).
        END.
        WHEN {&WDEDT_Dst_free} OR WHEN {&WDEDT_Dst_Put} OR WHEN {&WDEDT_Dst_Cli} THEN DO:
          RUN wth-parts-close(BUFFER cur-wth-parts, {&output-code} ).
        end.
        when {&WDEDT_Exp_Int_Put} or when {&WDEDT_Exp_Int_Free}
        OR WHEN {&WDEDT_Exp_Obj_Put} or when {&WDEDT_Exp_Obj_Free}
        then .
        when {&WDEDT_Exch} then do:
          if cur-wth-parts.type = {&income} then
               RUN wth-parts-close(BUFFER cur-wth-parts, {&put-zone} ).
          else RUN wth-parts-close(BUFFER cur-wth-parts, {&cli-zone} ).
        end.
        OTHERWISE DO:
            RETURN ERROR substitute("Неверный вызов процедуры закрытия: расш. тип = &1"
                                 , cur-wth-parts.ext-doc-type
                                    ).
        END.
    END CASE.
    RELEASE cur-wth-parts.
    END.
END.

PROCEDURE wth-parts-close:
    DEFINE PARAMETER BUFFER bfrom_wth-parts FOR ub.wth-parts.
    DEFINE INPUT PARAMETER p-zone AS CHAR NO-UNDO.
    define variable v-rec as recid.
    if bfrom_wth-parts.stts  = 1 then return.
       run str/wthpartp.p  ( INPUT     {&add-def},
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,      /*in-code*/
                  INPUT     p-zone,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,          /* p-contract-code   */
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,      /* p-supp-type       */
                  INPUT     bfrom_wth-parts.supp-code,      /*p-supp-code        */
                  INPUT     bfrom_wth-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     bfrom_wth-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     bfrom_wth-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     bfrom_wth-parts.gds-code,      /*p-gds-code        */
                  INPUT     bfrom_wth-parts.stts               ,          /*p-stts            */
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,                         /*p-cli-code        */
                  INPUT     bfrom_wth-parts.cli-type,                         /*p-cli-type        */
                  INPUT     bfrom_wth-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     bfrom_wth-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     bfrom_wth-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     bfrom_wth-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     bfrom_wth-parts.out-code ,
                  INPUT  yes,
                  INPUT     '':U ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .

/*      CREATE b-wth-parts.
      BUFFER-COPY bb-wth-parts EXCEPT bb-wth-parts.fact-date
                                     bb-wth-parts.fact-num
                                     bb-wth-parts.fact-order
                                     bb-wth-parts.shift-date
                                     bb-wth-parts.shift-num
                                     bb-wth-parts.out-code
                              TO b-wth-parts .
      ASSIGN b-wth-parts.in-code = bb-wth-parts.out-code
             b-wth-parts.out-code = p-zone
             .    */
END.


/*разрезервирование партии */
Procedure wth-doc-razrez:
    define input parameter p-rec as recid NO-UNDO.
    define input parameter p-doc-del AS log NO-UNDO.

    define variable v-mess AS CHAR NO-UNDO.
    define variable p-silent AS LOG INIT NO NO-UNDO.
    DEFINE BUFFER b-wth-parts FOR ub.wth-parts.
    DEFINE BUFFER buf_wth-parts FOR ub.wth-parts.
    DEFINE BUFFER cur-wth-parts FOR ub.wth-parts.

  do
  on error undo, return error return-value
  :

    FIND FIRST cur-wth-parts WHERE recid(cur-wth-parts) = p-rec
                              EXCLUSIVE-LOCK .
    IF AVAILABLE cur-wth-parts THEN DO:
        CASE cur-wth-parts.ext-doc-type:
            WHEN {&WDEDT_Inc_Ext} or when {&WDEDT_Inc_Int_Put} or when {&WDEDT_Ret_Int_Put}
            or when {&WDEDT_Inc_Int_Free} or when {&WDEDT_Ret_Int_Free}
            or when {&WDEDT_Inc_Obj_Free} or when {&WDEDT_Inc_Obj_Put}
            THEN DO:
                /*приход внешний*/
                RUN wth-parts-raz(BUFFER cur-wth-parts, "":U,p-doc-del) .
            END.
            WHEN {&WDEDT_Exp_Ext} or when {&WDEDT_Exp_Int_Free} or when {&WDEDT_Exp_Obj_Free}
            THEN DO:
                /*расход внешний*/
                RUN wth-parts-raz(BUFFER cur-wth-parts, {&free-code},p-doc-del) .
            END.
            WHEN {&WDEDT_Exp_Int_Put} or when {&WDEDT_Exp_Obj_Put} THEN DO:
                /*расход внутренний зоны погашения*/
                RUN wth-parts-raz(BUFFER cur-wth-parts, {&put-zone},p-doc-del) . /*????? не знаю*/
            END.
            WHEN {&WDEDT_Put_Cash} THEN DO:
                /*погашение через кассу*/
                RUN wth-parts-raz(BUFFER cur-wth-parts, {&cli-zone},p-doc-del)  .
            END.
            WHEN {&WDEDT_Dst_Put} THEN DO:
                /*уничтожение*/
                RUN wth-parts-raz(BUFFER cur-wth-parts, {&put-zone},p-doc-del)  .
            END.
            WHEN {&WDEDT_Dst_Free} THEN DO:
                /*уничтожение*/
                RUN wth-parts-raz(BUFFER cur-wth-parts, {&free-code},p-doc-del)  .
            END.
            WHEN {&WDEDT_Dst_Cli} THEN DO:
                /*уничтожение талонов, принадлежащих покупателю*/
                RUN wth-parts-raz(BUFFER cur-wth-parts, {&cli-zone},p-doc-del) /*????? не знаю*/ .
            END.
            WHEN {&WDEDT_Put_Sale} OR WHEN {&WDEDT_Put_Cli} THEN DO:
                /*погашение за реализованное топливо - погашение за нереализованное топливо*/
                RUN wth-parts-raz(BUFFER cur-wth-parts, {&cli-zone},p-doc-del).
            END.
            when {&WDEDT_Exch} then do:
              if cur-wth-parts.type = {&income} then
                   RUN wth-parts-raz(BUFFER cur-wth-parts, {&cli-zone},p-doc-del ).
              else RUN wth-parts-raz(BUFFER cur-wth-parts,  {&free-code} ,p-doc-del).
            end.

            OTHERWISE DO:
                RETURN ERROR substitute("Неверный вызов процедуры разрезервирования: расш. тип =  :&1&2&3"
                                     , cur-wth-parts.ext-doc-type
                                     , error-status:get-message(1)
                                     /*, p-out-code*/
                                     , return-value
                                     ).
            END.
        END CASE.

    END.

  END.

END.

PROCEDURE wth-parts-raz:
    DEFINE PARAMETER BUFFER bfrom_wth-parts FOR ub.wth-parts.
    DEFINE INPUT PARAMETER p-zone AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-doc-del AS log NO-UNDO.

    define variable v-mes as char no-undo.
    define variable v-rec as recid no-undo.
    DEFINE BUFFER buf_wth-parts FOR ub.wth-parts.

  do
  on error undo, return error return-value
  :
    v-mes = substitute('Код серии: &1-&2 Диапазон &3-&4'
                                   ,bfrom_wth-parts.ser-code
                                   ,bfrom_wth-parts.db-num
                                   ,bfrom_wth-parts.doc-rangeFrom
                                   ,bfrom_wth-parts.doc-rangeTo).

    IF lookup(bfrom_wth-parts.out-code,{&WDEDT_List-Zone}) > 0 THEN DO:
        RETURN ERROR substitute("Нельзя удалять партии МЦ из зоны :&1&2&3&4&5"
                             , error-status:get-message(1)
                             , bfrom_wth-parts.out-code
                             , return-value
                             ,{&new-line}
                             ,v-mes
                             ).
    END.
    v-rec = recid(bfrom_wth-parts).
    CASE bfrom_wth-parts.ext-doc-type:
        WHEN {&WDEDT_Inc_Ext}  or when {&WDEDT_Inc_Obj_Free} or when  {&WDEDT_Inc_Obj_Put} THEN DO:
            /*Внешний приход*/
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , {&new-line}
                                   , return-value
                                   ,v-mes
                                   ).
            END.
        END. /*when*/
        when {&WDEDT_Ret_Int_Put} or when {&WDEDT_Ret_Int_free} then do:
          if p-doc-del then do:
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , {&new-line}
                                   , return-value
                                   ,v-mes
                                   ).
            END.
          end.
          else   RETURN ERROR 'Нельзя удалять партии документа внутреннего возврата.'  .
        end.
        when {&WDEDT_Inc_Int_Put} or when {&WDEDT_Inc_Int_Free} then do:
          if p-doc-del then do:
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , {&new-line}
                                   , return-value
                                   ,v-mes
                                   ).
            END.
          end.
          else do:
            run str/wthpartp.p  ( INPUT     {&update},
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,      /*in-code*/
                  INPUT     bfrom_wth-parts.out-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo   ,
                  INPUT     bfrom_wth-parts.doc-RangeFrom ,
                  INPUT     bfrom_wth-parts.doc-rangeTo  ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code ,          /* p-contract-code   */
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,      /* p-supp-type       */
                  INPUT     bfrom_wth-parts.supp-code,      /*p-supp-code        */
                  INPUT     bfrom_wth-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     bfrom_wth-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     bfrom_wth-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     bfrom_wth-parts.gds-code,      /*p-gds-code        */
                  INPUT     1            ,          /*p-stts            */
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,                         /*p-cli-code        */
                  INPUT     bfrom_wth-parts.cli-type,                         /*p-cli-type        */
                  INPUT     bfrom_wth-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     bfrom_wth-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     bfrom_wth-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     bfrom_wth-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     bfrom_wth-parts.doc-code ,
                  INPUT  yes,
                  INPUT     bfrom_wth-parts.type ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
             if error-status:error then undo, return error return-value + {&new-line} + error-status:get-message(1) .
          end.
        end.
        OTHERWISE DO:
         run str/wthpartp.p  ( INPUT     {&update},
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,      /*in-code*/
                  INPUT     p-zone,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo   ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo  ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code ,          /* p-contract-code   */
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,      /* p-supp-type       */
                  INPUT     bfrom_wth-parts.supp-code,      /*p-supp-code        */
                  INPUT     bfrom_wth-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     bfrom_wth-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     bfrom_wth-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     bfrom_wth-parts.gds-code,      /*p-gds-code        */
                  INPUT     bfrom_wth-parts.stts             ,          /*p-stts            */
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,                         /*p-cli-code        */
                  INPUT     bfrom_wth-parts.cli-type,                         /*p-cli-type        */
                  INPUT     bfrom_wth-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     bfrom_wth-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     bfrom_wth-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     bfrom_wth-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     bfrom_wth-parts.doc-code ,
                  INPUT  yes,
                  INPUT      "":U ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + {&new-line} + error-status:get-message(1) .

        END. /*otherwise*/
    END CASE. /*case*/
  END. /* do */
END.

procedure wth-parts-rezerv:
   /* define input parameter        p-mode as character no-undo.  /* {&add-def} - режим порождения и изменения партий документа. (например при приеме новостей партии создавать не надо) */*/
    define input parameter        p-param            as logical no-undo.
    define input parameter        p-fact-rangeFrom   LIKE ub.wth-parts.Fact-RangeFrom no-undo .
    define input parameter        p-fact-RangeTo     LIKE ub.wth-parts.Fact-RangeTo no-undo   .
    define input parameter        p-beg-dt           LIKE ub.wth-parts.beg-dt no-undo .
    define input parameter        p-end-dt           LIKE ub.wth-parts.end-dt no-undo .
    define input parameter        p-ser-code         LIKE ub.wth-parts.ser-code no-undo.
    define input parameter        p-db-num           LIKE ub.wth-parts.db-num no-undo .
    define input parameter        p-price-rubl       LIKE ub.wth-parts.price-rubl no-undo .
    define input parameter        p-price-base       LIKE ub.wth-parts.price-base no-undo .
    define input parameter        p-vat-pc           LIKE ub.wth-parts.vat-pc no-undo .
    define input parameter        p-host-code        LIKE ub.wth-parts.host-code no-undo .
    define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
    define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
    define input parameter        p-w-p-code         LIKE ub.wth-parts.w-p-code no-undo .
    define input parameter        p-wth-code         LIKE ub.wth-parts.wth-code no-undo .
    define input parameter        p-par-code         LIKE ub.wth-parts.par-code no-undo .
    define input parameter        p-in-code          LIKE ub.wth-parts.in-code no-undo .
    define input parameter        p-doc-code         LIKE ub.wth-parts.out-code no-undo .
    define input parameter        p-cli-type         LIKE ub.wth-parts.cli-type no-undo .
    define input parameter        p-cli-code         LIKE ub.wth-parts.cli-code no-undo .
    define input parameter        p-ext-doc-type     LIKE ub.wth-parts.ext-doc-type no-undo .
    define input parameter        p-gds-code         LIKE ub.wth-parts.gds-code no-undo .
    define input parameter        p-type             LIKE ub.wth-parts.type no-undo .
    define input-output parameter p-rec        as recid     no-undo .

  define buffer bfrom_wth-parts   for ub.wth-parts.
  define buffer bufr_wth-doc      for ub.wth-doc.
  define variable v-rec    as recid        no-undo.
  define variable v-recDop as recid        no-undo.
  define variable v-zone   as character    no-undo.
  DEFINE variable v-beg-dt           LIKE ub.wth-parts.beg-dt no-undo .
  define VARIABLE v-end-dt           LIKE ub.wth-parts.end-dt no-undo .
  define variable v-price-rubl       LIKE ub.wth-parts.price-rubl no-undo .
  define variable v-price-base       LIKE ub.wth-parts.price-base no-undo .
  define variable v-vat-pc           LIKE ub.wth-parts.vat-pc no-undo .
  define variable v-mpl-date         as date      no-undo.
  empty temp-table tt-wthlib-parts.
main-block:
do  transaction
on error  undo main-block, return error return-value + {&space-char} + error-status:get-message(1)
on stop   undo main-block, return error
on endkey undo main-block, return error
:
FIND FIRST bufr_wth-doc WHERE bufr_wth-doc.doc-code = p-doc-code NO-LOCK NO-ERROR.
IF NOT AVAILABLE bufr_wth-doc THEN RETURN ERROR SUBSTITUTE('Не найден документ МЦ с номером &1',p-doc-code).
  if lookup(p-ext-doc-type,{&WDEDT_Not-Rezerv}) > 0
        then do:  /*Если пратии по такому типу не подлежат резервированию, то создаем новую запись*/
     run str/wthpartp.p  ( INPUT {&add-def},
                  INPUT  p-obj-type,
                  INPUT  p-obj-code,
                  INPUT  p-w-p-code,
                  INPUT  p-wth-code,
                  INPUT  p-par-code,
                  INPUT  p-in-code,
                  INPUT  p-doc-code,
                  INPUT  p-ser-code,
                  INPUT  p-db-num  ,
                  INPUT  p-Fact-RangeFrom ,
                  INPUT  p-fact-rangeTo  ,
                  INPUT  p-Fact-RangeFrom ,
                  INPUT  p-fact-rangeTo ,
                  INPUT  p-host-code     ,
                  INPUT  0   ,          /* p-contract-code   */
                  INPUT  p-price-rubl    ,
                  INPUT  p-price-base    ,
                  INPUT  '':U,      /* p-supp-type       */
                  INPUT  0,      /*p-supp-code        */
                  INPUT  p-obj-type      ,          /*p-in-obj-type     */
                  INPUT  p-obj-code      ,          /*p-in-obj-code     */
                  INPUT  p-ext-doc-type,  /*p-ext-doc-type    */
                  INPUT  p-gds-code,      /*p-gds-code        */
                  INPUT  0           ,          /*p-stts            */
                  INPUT  p-beg-dt        ,
                  INPUT  p-end-dt        ,
                  INPUT  p-vat-pc      ,
                  INPUT  0,                         /*p-cli-code        */
                  INPUT  '':U,                      /*p-cli-type        */
                  INPUT  0,                         /*p-out-obj-code    */
                  INPUT  '':U,                      /*p-out-obj-type    */
                  INPUT  0,                         /*p-sale-obj-code   */
                  INPUT  '':U,                      /*p-sale-obj-type   */
                  INPUT  p-doc-code,
                  INPUT  yes,
                  INPUT p-type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
                if error-status:error then undo main-block, return error return-value + error-status:get-message(1) .
  end.
  else do:
    if p-rec <> ? then do:     /*Если  указана recid записи из которой надо резервировать, ищем ее*/
      find first bfrom_wth-parts exclusive-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      if  available bfrom_wth-parts
        and bfrom_wth-parts.wth-code = p-wth-code
        and bfrom_wth-parts.par-code = p-par-code
        and bfrom_wth-parts.ser-code = p-ser-code
        and lookup(bfrom_wth-parts.out-code,{&WDEDT_List-zone}) > 0
      then.
      else if  available bfrom_wth-parts and lookup(bfrom_wth-parts.out-code,{&WDEDT_List-zone}) = 0
      then return error substitute('Резервирование из партии (Код серии: &1-&2 Диапазон &3-&4) невозможно, т.к. партия уже входит в состав документа'
                                   ,bfrom_wth-parts.ser-code
                                   ,bfrom_wth-parts.db-num
                                   ,bfrom_wth-parts.doc-rangeFrom
                                   ,bfrom_wth-parts.doc-rangeTo).
      else if  available bfrom_wth-parts then undo, return error 'Партия указанная для резервирования не соответсвует указанным параметрам!'.

      if available bfrom_wth-parts
         and bfrom_wth-parts.doc-rangeFrom > p-fact-rangeFrom
         or bfrom_wth-parts.doc-rangeTo   < p-fact-rangeTo
      then undo, return error substitute('Нельзя увеличивать границы диапазона.&1Диапазон партии &2-&3.&1Диапазон резервирования &4-&5'
                                         ,{&new-line}
                                         ,bfrom_wth-parts.doc-rangeFrom
                                         ,bfrom_wth-parts.doc-rangeTo
                                         ,p-fact-rangeFrom
                                         ,p-fact-rangeTo).

    end.
    else do:
      if p-ext-doc-type = {&WDEDT_Put_Cli} or (p-ext-doc-type = {&WDEDT_Exch} and p-type = {&income} )then do:  /*если погашение, то ищем еще и по клиенту*/
        for first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = {&cli-zone}
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and bfrom_wth-parts.cli-code = p-cli-code
                              and bfrom_wth-parts.cli-type = p-cli-type
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              use-index  wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
         end.
/*если не смогли зарезервировать партии с указанным номером порождения, попробуем найти что есть. Скорее всего это фальш. зона.
Сразу не ищем без проверки на in-code в надежде выбрать то что надо. */
        If p-rec = ? and p-in-code > '' then do:
           for first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = {&cli-zone}
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and bfrom_wth-parts.cli-code = p-cli-code
                              and bfrom_wth-parts.cli-type = p-cli-type
                              use-index  wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
              end.
        end.
              if p-rec <> ? then  find first bfrom_wth-parts no-lock where
                recid(bfrom_wth-parts) = p-rec no-error.

      end.
      else if p-ext-doc-type = {&WDEDT_Put_Cash} or p-ext-doc-type = {&WDEDT_Put_Sale} or p-ext-doc-type = {&WDEDT_Dst_Cli} then do:  /*Если погашение или уничтожение принадлежащих покупателю, то по объекту и МХ не проверяем*/
        for first bfrom_wth-parts no-lock where bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = {&cli-zone}
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              use-index wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
         end.
        If p-rec = ? and p-in-code > '' then do:
         for first bfrom_wth-parts no-lock where bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = {&cli-zone}
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              :
                              p-rec = recid(bfrom_wth-parts).
         end.

        end.
        if p-rec <> ? then  find first bfrom_wth-parts no-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      end.
      else do:
        CASE p-ext-doc-type:
                WHEN {&WDEDT_Exp_Ext} or when {&WDEDT_Exch} or WHEN {&WDEDT_Exp_Int_Free}
                or when {&WDEDT_Exp_Obj_Free} THEN DO:
                    v-zone = {&free-code}.
                END.
                WHEN {&WDEDT_Exp_Int_Put} or when {&WDEDT_Exp_Obj_Put} THEN DO:
                    v-zone = {&put-zone}.
                END.
                WHEN {&WDEDT_Dst_Free} THEN DO:
                    v-zone = {&free-code}.
                END.
                WHEN {&WDEDT_Dst_Put}  THEN DO:
                    v-zone = {&put-zone}.
                END.
                WHEN {&WDEDT_Put_Cash} OR WHEN {&WDEDT_Put_Sale} OR WHEN {&WDEDT_Put_Cli} OR WHEN {&WDEDT_Dst_Cli} THEN DO:
                    v-zone = {&cli-zone}.
                END.
                OTHERWISE DO:
                    RETURN ERROR substitute("Неверный вызов процедуры резервирования: расш. тип = &1"
                                         , p-ext-doc-type
                                            ).
                END.
        END CASE.
       /*message  p-fact-rangeFrom  p-fact-rangeTo p-wth-code p-obj-code  p-obj-type  p-w-p-code  p-par-code p-ser-code p-db-num v-zone 'zone' p-in-code '88888888888888888888888888888888'.*/
        find first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.obj-code = p-obj-code
                              and bfrom_wth-parts.obj-type = p-obj-type
                              and bfrom_wth-parts.w-p-code = p-w-p-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = v-zone
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              no-error.
       If not available bfrom_wth-parts and p-in-code > '' then do:
               find first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.obj-code = p-obj-code
                              and bfrom_wth-parts.obj-type = p-obj-type
                              and bfrom_wth-parts.w-p-code = p-w-p-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = v-zone
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              no-error.

       end.
      end.  /*else*/
    end.  /*p-rec = ? */

    if not available bfrom_wth-parts then do:
         if g#news then do:
          return error 'forged':U.
         end.
         else
          undo, return error substitute("Не найдена партия МЦ для резервирования &1Код МЦ &2&1Код номинала &3&1Код серии &4&1Диапазон с &5 по &6&1
                                        ",{&new-line},p-wth-code,p-par-code,p-ser-code,p-fact-rangeFrom,
                                        p-fact-rangeTo).
    end.
    p-rec = recid(bfrom_wth-parts).
    find current bfrom_wth-parts exclusive-lock.

    /*Создаем запись во времен.таблице что сохранить первоначальный вид партии. (таблица т.к. лень заводить переменные:))*/
    create tt-wthlib-parts.

/*    message v-zone  tt-wthlib-parts.out-code p-ext-doc-type 'rezerv rezerv'.*/
    buffer-copy bfrom_wth-parts to tt-wthlib-parts.
        ASSIGN v-beg-dt = if p-param then p-beg-dt else bfrom_wth-parts.beg-dt
               v-end-dt = if p-param then p-end-dt else bfrom_wth-parts.end-dt
               v-vat-pc = if p-param then p-vat-pc else bfrom_wth-parts.vat-pc
               v-price-rubl = if p-param then p-price-rubl else bfrom_wth-parts.price-rubl
               v-price-base = if p-param then p-price-base else bfrom_wth-parts.price-base  .
    IF  not g#news and (p-ext-doc-type = {&WDEDT_Exp_Ext} or p-ext-doc-type = {&WDEDT_Exch})  THEN DO:
        /*Если не заполнен срок годности для расходных накладных инициируем автоматическое заполнение*/
        IF v-beg-dt = ? AND v-end-dt = ? THEN DO:
            RUN init_prtdate ( INPUT p-obj-type
                                              ,INPUT p-obj-code
                                              ,INPUT p-ser-code
                                              ,INPUT p-db-num
                                              ,INPUT bufr_wth-doc.doc-date
                                              ,OUTPUT v-beg-dt
                                              ,OUTPUT v-end-dt ) NO-ERROR.
            if error-status:error then undo, return error return-value + error-status:get-message(1) .
        END.
        IF v-price-rubl = 0 AND v-price-base = 0 THEN DO:
          run set-wthmpl-date ( bufr_wth-doc.doc-code
                             ,bufr_wth-doc.doc-date
                             , v-beg-dt
                             , output v-mpl-date) no-error.
            RUN INIT_prtprice (
                          p-host-code
                        , p-obj-type
                        , p-obj-code
                        , p-cli-type
                        , p-cli-code
                        , p-wth-code
                        , p-gds-code
                        , p-par-code
                        , v-mpl-date
                        , OUTPUT  v-vat-pc
                        , OUTPUT  v-price-rubl
                        , OUTPUT  v-price-base
                ) NO-ERROR.
          if error-status:error then undo, return error return-value + error-status:get-message(1) .
        END.
    END.

      run str/wthpartp.p  ( INPUT     {&update},
                  INPUT     p-obj-type,
                  INPUT     p-obj-code,
                  INPUT     p-w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     p-doc-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,          /* p-contract-code   */
                  INPUT     v-price-rubl ,
                  INPUT     v-price-base  ,
                  INPUT     bfrom_wth-parts.supp-type,      /* p-supp-type       */
                  INPUT     bfrom_wth-parts.supp-code,      /*p-supp-code        */
                  INPUT     bfrom_wth-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     bfrom_wth-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     p-ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     bfrom_wth-parts.gds-code,      /*p-gds-code        */
                  INPUT     0              ,          /*p-stts            */
                  INPUT     v-beg-dt    ,
                  INPUT     v-end-dt   ,
                  INPUT     v-vat-pc    ,
                  INPUT     bfrom_wth-parts.cli-code,                         /*p-cli-code        */
                  INPUT     bfrom_wth-parts.cli-type,                         /*p-cli-type        */
                  INPUT     bfrom_wth-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     bfrom_wth-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     bfrom_wth-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     bfrom_wth-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     yes,
                  INPUT     p-type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    /*end.
    else do:
      delete bfrom_wth-parts no-error.
      if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.*/
    if tt-wthlib-parts.fact-rangeFrom <> p-fact-rangeFrom then do:   /*Оставляем диапазон спарава*/
    /*message  tt-wthlib-parts.out-code. */
    run str/wthpartp.p ( INPUT     {&add-def},
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,          /* p-contract-code   */
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,      /* p-supp-type       */
                  INPUT     tt-wthlib-parts.supp-code,      /*p-supp-code        */
                  INPUT     tt-wthlib-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     tt-wthlib-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     tt-wthlib-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     tt-wthlib-parts.gds-code,      /*p-gds-code        */
                  INPUT     tt-wthlib-parts.stts               ,          /*p-stts            */
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,                         /*p-cli-code        */
                  INPUT     tt-wthlib-parts.cli-type,                         /*p-cli-type        */
                  INPUT     tt-wthlib-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     tt-wthlib-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     tt-wthlib-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     tt-wthlib-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT  yes,
                  INPUT    tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
    /*Если диапазон вырезается создаем вторую партию*/
    if tt-wthlib-parts.fact-rangeTo <> p-fact-rangeTo then do:       /*Оставляем диапазон слева*/

            run str/wthpartp.p    ( INPUT {&add-def},
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,          /* p-contract-code   */
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,      /* p-supp-type       */
                  INPUT     tt-wthlib-parts.supp-code,      /*p-supp-code        */
                  INPUT     tt-wthlib-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     tt-wthlib-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     tt-wthlib-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     tt-wthlib-parts.gds-code,      /*p-gds-code        */
                  INPUT     tt-wthlib-parts.stts               ,          /*p-stts            */
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,                         /*p-cli-code        */
                  INPUT     tt-wthlib-parts.cli-type,                         /*p-cli-type        */
                  INPUT     tt-wthlib-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     tt-wthlib-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     tt-wthlib-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     tt-wthlib-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT     yes,
                  INPUT     tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.

      if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
  end.  /*резерв*/
end. /*transaction*/
end procedure.

procedure wth-parts-inter-edit:
  define input parameter        p-fact-rangeFrom   LIKE ub.wth-parts.Fact-RangeFrom no-undo .
  define input parameter        p-fact-RangeTo     LIKE ub.wth-parts.Fact-RangeTo no-undo   .
  define input-output parameter p-rec        as recid     no-undo .

  define buffer bfrom_wth-parts   for ub.wth-parts.
  define variable v-recDop as recid        no-undo.

  do on error undo, return error:
      find first bfrom_wth-parts exclusive-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      if not available bfrom_wth-parts then return error
        substitute('Не найдена партия (recid &1)', p-rec).
      if p-fact-rangeFrom < bfrom_wth-parts.doc-rangeFrom or
         p-fact-rangeTo > bfrom_wth-parts.doc-rangeTo then do:
         return error 'Нельзя увеличивать границы диапазона.'.
      end.
      empty temp-table tt-wthlib-parts.
      create tt-wthlib-parts.  /*созадем запись во врем. таблице чтобы запомнить первоначальный вид партии и не заводить переменные*/
      buffer-copy bfrom_wth-parts to tt-wthlib-parts.

      run str/wthpartp.p  ( INPUT     {&update},
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,          /* p-contract-code   */
                  INPUT     bfrom_wth-parts.price-rubl  ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,      /* p-supp-type       */
                  INPUT     bfrom_wth-parts.supp-code,      /*p-supp-code        */
                  INPUT     bfrom_wth-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     bfrom_wth-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     bfrom_wth-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     bfrom_wth-parts.gds-code,      /*p-gds-code        */
                  INPUT     0              ,          /*p-stts            */
                  INPUT     bfrom_wth-parts.beg-dt      ,
                  INPUT     bfrom_wth-parts.end-dt      ,
                  INPUT     bfrom_wth-parts.vat-pc      ,
                  INPUT     bfrom_wth-parts.cli-code,                         /*p-cli-code        */
                  INPUT     bfrom_wth-parts.cli-type,                         /*p-cli-type        */
                  INPUT     bfrom_wth-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     bfrom_wth-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     bfrom_wth-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     bfrom_wth-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     yes,
                  INPUT     bfrom_wth-parts.type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .

    if tt-wthlib-parts.fact-rangeFrom <> p-fact-rangeFrom then do:   /*Оставляем диапазон спарава*/
    run str/wthpartp.p ( INPUT     {&add-def},
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,          /* p-contract-code   */
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,      /* p-supp-type       */
                  INPUT     tt-wthlib-parts.supp-code,      /*p-supp-code        */
                  INPUT     tt-wthlib-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     tt-wthlib-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     tt-wthlib-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     tt-wthlib-parts.gds-code,      /*p-gds-code        */
                  INPUT     1             ,          /*p-stts            */
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,                         /*p-cli-code        */
                  INPUT     tt-wthlib-parts.cli-type,                         /*p-cli-type        */
                  INPUT     tt-wthlib-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     tt-wthlib-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     tt-wthlib-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     tt-wthlib-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT  yes,
                  INPUT    tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
    /*Если диапазон вырезается создаем вторую партию*/
    if tt-wthlib-parts.fact-rangeTo <> p-fact-rangeTo then do:       /*Оставляем диапазон слева*/

            run str/wthpartp.p    ( INPUT {&add-def},
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,          /* p-contract-code   */
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,      /* p-supp-type       */
                  INPUT     tt-wthlib-parts.supp-code,      /*p-supp-code        */
                  INPUT     tt-wthlib-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT     tt-wthlib-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT     tt-wthlib-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT     tt-wthlib-parts.gds-code,      /*p-gds-code        */
                  INPUT     1             ,          /*p-stts            */
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,                         /*p-cli-code        */
                  INPUT     tt-wthlib-parts.cli-type,                         /*p-cli-type        */
                  INPUT     tt-wthlib-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT     tt-wthlib-parts.out-obj-type,                         /*p-out-obj-type    */
                  INPUT     tt-wthlib-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT     tt-wthlib-parts.sale-obj-type,                         /*p-sale-obj-type   */
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT     yes,
                  INPUT     tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.

      if error-status:error then undo, return error return-value + error-status:get-message(1) .
      end.

  end.
end procedure.  /*wth-parts-inter-edit*/
PROCEDURE INIT_prtdate:
    define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
    define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
    define input parameter        p-ser-code         LIKE ub.wth-parts.ser-code no-undo.
    define input parameter        p-db-num           LIKE ub.wth-parts.db-num no-undo .
    define input parameter        p-date                AS DATE no-undo .
    DEFINE OUTPUT PARAMETER p-beg-dt AS DATE NO-UNDO.
    DEFINE OUTPUT PARAMETER p-end-dt AS DATE NO-UNDO.
    DEFINE BUFFER buf_wth-ser FOR ub.wth-ser.
    DEFINE VARIABLE v-rangeRule AS INT NO-UNDO.
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-param-type as character no-undo .
    FIND FIRST buf_wth-ser NO-LOCK
        WHERE buf_wth-ser.ser-code = p-ser-code
        AND buf_wth-ser.db-num = p-db-num.
    IF buf_wth-ser.chk-bdt = 2 THEN DO:
        p-beg-dt = buf_wth-ser.beg-dt.
    END.
    IF buf_wth-ser.chk-edt = 2 THEN DO:
        p-end-dt = buf_wth-ser.end-dt.
    END.
    IF buf_wth-ser.chk-bdt = 0 AND buf_wth-ser.chk-edt = 0 THEN DO:
        run adm/shattri.p (
            input "get":U
            ,input  p-obj-type
            ,input  p-obj-code
            ,input  {&attr-wthdoc_obj}
            ,input  {&attr-wthdoc_obj_rangerule} /*p-param-code*/
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        IF not error-status:error  then do:
            v-rangeRule =  v-value-integer.
        END.
        CASE v-rangeRule:
        WHEN 1 THEN DO:     /* Следующий месяц */
            IF MONTH(p-date) < 11 THEN ASSIGN p-beg-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 1,YEAR(p-date)))
                                              p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 2,YEAR(p-date))) - 1.
            ELSE IF MONTH(p-date) = 11 THEN ASSIGN p-beg-dt = DATE(substitute('01/12/&1',YEAR(p-date)))
                                              p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date) + 1)).
            ELSE IF MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('01/01/&1',YEAR(p-date) + 1))
                                              p-end-dt = DATE(substitute('31/01/&1',YEAR(p-date) + 1)).

        END.
        when 2 then do: /* Текущий месяц */
          IF MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('&1/12/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date))).
          else ASSIGN p-beg-dt = DATE(substitute('&3/&1/&2',MONTH(p-date),YEAR(p-date),day(p-date)))
                      p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 1,YEAR(p-date))) - 1
                     .

        end.
        WHEN 3 THEN DO:     /* 3 месяца */
            IF MONTH(p-date) < 10 THEN ASSIGN p-beg-dt = DATE(substitute('&1/&2/&3',day(p-date),MONTH(p-date),YEAR(p-date)))
                                              p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 3,YEAR(p-date))) - 1.
            else if MONTH(p-date) = 10 THEN ASSIGN p-beg-dt = DATE(substitute('&1/10/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date))).
            else if MONTH(p-date) = 11 THEN ASSIGN p-beg-dt = DATE(substitute('&1/11/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/01/&1',YEAR(p-date) + 1)).
            else if MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('&1/12/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('01/03/&1',YEAR(p-date) + 1)) - 1.

        END.
        when 4 then do:
             p-beg-dt = p-date.
             p-end-dt = date(substitute('31/12/&1',YEAR(p-date))).
        end.

        END CASE.
    END.

END. /*init_prtdate*/
PROCEDURE INIT_prtprice:
define input parameter        p-host-code        LIKE ub.wth-parts.obj-type no-undo .
define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
define input parameter        p-cli-type         LIKE ub.wth-parts.cli-type no-undo .
define input parameter        p-cli-code         LIKE ub.wth-parts.cli-code no-undo .
define input parameter        p-wth-code         LIKE ub.wth-parts.ser-code no-undo.
define input parameter        p-gds-code         LIKE ub.wth-parts.gds-code no-undo .
define input parameter        p-par-code         LIKE ub.wth-parts.par-code no-undo .
define input parameter        p-date                AS DATE no-undo .
DEFINE OUTPUT PARAMETER p-vat-pc LIKE ub.wth-parts.vat-pc NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-rubl LIKE ub.wth-parts.price-rubl NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-base LIKE ub.wth-parts.price-base NO-UNDO.

DEFINE BUFFER b-cash-pay FOR ub.cash-pay.
DEFINE BUFFER b-wth-par FOR ub.wth-par.
DEF VAR v-cash-type-pay AS CHAR no-undo.
define variable p-plt-id AS INT no-undo.
define variable  p-plt-db-num   AS INT no-undo.
define variable  p-pdf-id  AS INT no-undo.
define variable  p-pdf-db-num AS INT no-undo.
define variable  p-sale-price-base AS DEC no-undo.
define variable  p-sale-price-rubl AS DEC no-undo.
define variable  p-road-tax-base AS DEC no-undo.
define variable  p-road-tax-rubl AS DEC no-undo.
define variable  p-excise-base AS DEC no-undo.
define variable  p-excise-rubl AS DEC no-undo.
define variable  p-fact-order  AS DEC no-undo.

do on error undo, return error return-value :

  FIND FIRST b-wth-par NO-LOCK WHERE b-wth-par.par-code = p-par-code
                                  AND b-wth-par.wth-code = p-wth-code NO-ERROR.
  IF NOT AVAILABLE b-wth-par THEN RETURN ERROR SUBSTITUTE("Не наден номинал с кодом &1",p-par-code).
  FIND FIRST b-cash-pay WHERE b-cash-pay.wth-code = p-wth-code NO-LOCK NO-ERROR.
  IF AVAILABLE b-cash-pay THEN v-cash-type-pay = STRING(recid(b-cash-pay)).
  ELSE v-cash-type-pay = ?.
  run fact-order-mpl (
      INPUT p-date ,
      INPUT p-obj-type ,
      INPUT p-obj-code ,
      OUTPUT p-fact-order
      ) no-error .
  if error-status:error then do:
    message   return-value skip error-status:get-message(1)
    skip  'Получение цены из множественного прайс-листа отклонено.'
    view-as alert-box.
    return.
  end.

  { gbl/pftxvalg.i p-gds-code {&vat-tax-code} ? p-host-code p-obj-type p-obj-code  p-vat-pc no-error }

  run mpl-autoprice in this-procedure
    ( input    false
      ,input   p-cli-type
      ,input   p-cli-code
      ,input   p-gds-code
      ,input   p-gds-code
      ,input   p-obj-type
      ,input   p-obj-code
      ,input   0
      ,input   0
      ,input   ""  /* вид оплаты */
      ,input   v-cash-type-pay      /* тип кассового платежа */
      ,input   p-fact-order
      ,output  p-plt-id
      ,output  p-plt-db-num
      ,output  p-pdf-id
      ,output  p-pdf-db-num
      ,output  p-sale-price-base
      ,output  p-sale-price-rubl
      ,output  p-road-tax-base
      ,output  p-road-tax-rubl
      ,output  p-excise-base
      ,output  p-excise-rubl
      ) no-error .
  if error-status:error then do:
    message   return-value skip error-status:get-message(1) view-as alert-box.
    return.
  end.

  p-price-rubl = p-sale-price-rubl * b-wth-par.par-val.
  p-price-base = p-sale-price-base * b-wth-par.par-val.
/*    message  p-sale-price-rubl  p-sale-price-base
    b-wth-par.par-val view-as alert-box.  */
end.
END. /*init_prtsum*/
/*Процедура определения даты расчета цены. Возвращает первую заполненную дату в след.последовательности:
Дата сч.фактуры, срок годности, дата документа*/
procedure  set-wthmpl-date:
define input parameter p-doc-code like ub.wth-doc.doc-code no-undo.
define input parameter p-doc-date like ub.wth-doc.doc-date no-undo.
define input parameter p-beg-dt   like ub.wth-parts.beg-dt no-undo.
define output parameter p-date    like ub.wth-doc.doc-date no-undo.

define variable v-atrValue      as character no-undo .
define variable v-atrDsf      as CHARACTER no-undo .
define variable v-atrType     as character no-undo .

do on error undo, return error return-value :
  { str/wthatval.i
      p-doc-code
      {&wthcattr-dsf}
      v-atrValue
      v-atrType
  }
  p-date = date(v-atrValue) no-error.
  if p-date = ? then p-date = p-beg-dt no-error.
  if p-date = ? then p-date = p-doc-date.
end.
end procedure. /* set-wthmpl-date */

/* $Workfile$ e n d */