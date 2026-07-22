block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sndwssh.p $
$Archive: str/sndwssh.p $

Отправка масок серийных МЦ на кассу одного магазина

Автор: Гридчина Полина Дмитриевна
Дата создания: 08/09/07
Author: Polina Gridchina
Creation date: 08/09/07

Input:

Output:

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter i-obj-type like ub.clients.obj-type no-undo.
define input parameter i-obj-code like ub.clients.obj-code no-undo.
define input parameter  v-ser-list-code   as character no-undo .
define input parameter action as char no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndwssh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sndwssh.p $":U .
define variable vss-description as character no-undo init "Отправка масок серийных МЦ на кассу одного магазина".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ ref/cp-attr.i }

/*define variable v-ser-list-code as character no-undo.  */
define variable ii     as integer      no-undo.
define variable v-prod-bc    as character    no-undo. /*короткий топливный код*/
define buffer buf_wth-ser   for ub.wth-ser.
define buffer buf_snd-wth-gds   for ub.wth-gds.
define buffer buf_snd-wth-par   for ub.wth-par.
define buffer buf_snd-cash-pay    for ub.cash-pay.

/*define variable log-file-name                as character      no-undo init "send-cd.txt".     */

&scop view-log   ~{ str/cdviewlg.i   ~
                   "'!!!При отсылке информации на кассы произошли ошибки!!!'" ~
                   "'send-cd.txt'" ~}   ~
                    return
FUNCTION pet-code RETURNS CHARACTER  /*функция определения короткого топливного кода*/
  ( INPUT p-gds-code AS INTEGER ) :
  DEFINE VARIABLE main-b-code LIKE ub.bar-code.b-code NO-UNDO.
  DEFINE VARIABLE l-is-petrol-code AS LOGICAL NO-UNDO.
  DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
  if p-gds-code = 0 then return "":U.
  /*??????? ????????? ??????? ??? ??????*/
  { gbl/gdsbcode.i p-gds-code ? main-b-code NO-ERROR }
  IF ERROR-STATUS:ERROR THEN RETURN "":U.

  FOR EACH buf_prod-bc NO-LOCK WHERE
          buf_prod-bc.b-code = main-b-code:
    { gbl/prodbcat.i buf_prod-bc 'petrolium=request' l-is-petrol-code NO-ERROR }
    IF l-is-petrol-code THEN RETURN buf_prod-bc.b-str.
  END.

  RETURN "".   /* Function return value. */
END FUNCTION.


FIND ub.shop WHERE ub.shop.obj-code = i-obj-code NO-LOCK .
FIND ub.sysconf WHERE ub.sysconf.host-code = ub.shop.host-code NO-LOCK .


run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка на кассы &1&2 масок МЦ", {&shop}, i-obj-code)
                                              ).
/*если v-ser-list-code пустой, то по всем сериям, иначе по списку*/
if v-ser-list-code = '' then do:
  fe-block: for each buf_wth-ser no-lock:
          find first buf_snd-wth-gds no-lock where
                  buf_snd-wth-gds.wth-code = buf_wth-ser.wth-code no-error.
        if not available buf_snd-wth-gds then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найдена связка с товарами для МЦ &1, серия &2 ", buf_wth-ser.wth-code, buf_wth-ser.series )
                                               ).
          next fe-block.
        end.
        find first buf_snd-wth-par no-lock where
                   buf_snd-wth-par.par-code = buf_wth-ser.par-code no-error.
        if not available buf_snd-wth-par then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найден номинал &3 для МЦ &1, серия &2 ", buf_wth-ser.wth-code, buf_wth-ser.series,buf_wth-ser.par-code )
                                               ).
          next fe-block.
        end.

        find first buf_snd-cash-pay no-lock where
                   buf_snd-cash-pay.wth-code = buf_wth-ser.wth-code no-error.
        if not available buf_snd-cash-pay then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найден тип платежа для МЦ &1, серия &2 ", buf_wth-ser.wth-code, buf_wth-ser.series)
                                               ).
          next fe-block.
        end.
        v-prod-bc = pet-code(buf_snd-wth-gds.gds-code).
        if v-prod-bc > '' then.
        else do:
          run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Не определен короткий код для товара &3 (МЦ &1 серия &2) ", buf_wth-ser.wth-code, buf_wth-ser.series,buf_snd-wth-gds.gds-code)
                                                ).
            next fe-block.
        end.
    RUN SENDING in this-procedure /*( input stop-lf_get-acode-from-slc(p-stop-list-code) )*/ no-error.
    {&sending-error}.

  end.
end.
else ii-block:  DO ii = 1 to NUM-ENTRIES(v-ser-list-code):
      FIND FIRST buf_wth-ser No-LOCK WHERE
                recid(buf_wth-ser) = integer(entry(ii, v-ser-list-code)) No-ERROR.
      IF avail buf_wth-ser then do:
        find first buf_snd-wth-gds no-lock where
                  buf_snd-wth-gds.wth-code = buf_wth-ser.wth-code no-error.
        if not available buf_snd-wth-gds then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найдена связка с товарами для МЦ &1, серия &2 ", buf_wth-ser.wth-code, buf_wth-ser.series )
                                               ).
          next ii-block.
        end.
        find first buf_snd-wth-par no-lock where
                   buf_snd-wth-par.par-code = buf_wth-ser.par-code no-error.
        if not available buf_snd-wth-par then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найден номинал &3 для МЦ &1, серия &2 ", buf_wth-ser.wth-code, buf_wth-ser.series,buf_wth-ser.par-code )
                                               ).
          next ii-block.
        end.
        find first buf_snd-cash-pay no-lock where
                   buf_snd-cash-pay.wth-code = buf_wth-ser.wth-code no-error.
        if not available buf_snd-cash-pay then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найден тип платежа для МЦ &1, серия &2 ", buf_wth-ser.wth-code, buf_wth-ser.series)
                                               ).
          next ii-block.
        end.
        v-prod-bc = pet-code(buf_snd-wth-gds.gds-code).
        if v-prod-bc > '' then.
        else do:
          run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Не определен короткий код для товара &3 (МЦ &1 серия &2) ", buf_wth-ser.wth-code, buf_wth-ser.series,buf_snd-wth-gds.gds-code)
                                                ).
            next ii-block.
        end.
        RUN SENDING in this-procedure /*( input stop-lf_get-acode-from-slc(p-stop-list-code) )*/ no-error.
       {&sending-error}.
      end.
END.



{&viewlog}.
 /*PROCEDURE putc-cli.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-ws.i }

/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cyws.i }

/*PROCEDURE SENDING.*/
{ str/cd-sedws.i }


