block-level on error undo, throw.
/*

$Revision: 077e8f550cdc, 482, rls $
$Author: EShklyar $
$Date: Sun Feb 28 19:22:49 2016 +0400 $
$Workfile: r-shift9.p $
$Archive: rep/r-shift9.p $

Сменный отчет лист 9 сбор данных

Автор: Белоусов Илья Александрович
Дата создания: 12/17/07
Author: Ilia Belousov
Creation date: 12/17/07

Input:

Output:

*/

define input parameter parparentproc as   widget-handle       no-undo .
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter p-report-id                as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
DEFINE INPUT PARAMETER p-obj-type         like ub.shift-obj.obj-type    no-undo.
DEFINE INPUT PARAMETER p-obj-code         like ub.shift-obj.obj-code    no-undo.
DEFINE INPUT PARAMETER p-shift-date-start like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-start  like ub.shift-obj.shift-num   no-undo.
DEFINE INPUT PARAMETER p-shift-date-end   like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-end    like ub.shift-obj.shift-num   no-undo.
define input parameter p-tog-1-out-pump-with-icnt as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 077e8f550cdc, 482, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Sun Feb 28 19:22:49 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shift9.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-shift9.p $":U .
define variable vss-description as character no-undo init "Сменный отчет лист 9 сбор данных".


define   shared stream  PrnLibStream.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/icm-9df.i  }
{ gbl/waitfram.i }
{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift9 }

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



define buffer buf_chk-doc  for ub.chk-doc .
define buffer bf_t-9      for t-9 .
define buffer buf_goods    for ub.goods .

define variable v-counter    as integer      no-undo.

define variable pol1  as character no-undo .
define variable pol2  as character no-undo .
define variable pol3  as character no-undo .
define variable pol4  as decimal   no-undo .
define variable pol5  as decimal   no-undo .
define variable pol6  as decimal   no-undo .
define variable pol7  as decimal   no-undo .
define variable pol8  as decimal   no-undo.
define variable pol9  as decimal   no-undo.
define variable pol10 as decimal  no-undo .
define variable pol11 as decimal  no-undo .
define variable pol12 as decimal  no-undo .
define variable pol13 as decimal  no-undo .

&scop All-sym sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
&scop All-Pol pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13

do
on error undo, return error
:

   /* расчет */
   for each  bf_t-9:
      delete bf_t-9.
   end.


   run calc-rest  ( INPUT p-obj-type
                  , INPUT p-obj-code
                  , INPUT p-shift-date-start
                  , INPUT p-shift-num-start
                  , INPUT p-shift-date-end
                  , INPUT p-shift-num-end
                  ) .

   _shift-chk:
   FOR EACH buf_chk-doc
      WHERE buf_chk-doc.obj-type = p-obj-type
      AND   buf_chk-doc.obj-code = p-obj-code
      AND   buf_chk-doc.shift-date >= p-shift-date-start
      AND   buf_chk-doc.shift-date <= p-shift-date-end
      AND    ( buf_chk-doc.chk-type = integer({&rcpt-sale})
            OR buf_chk-doc.chk-type = integer({&rcpt-return})
            OR buf_chk-doc.chk-type = integer({&rcpt-overflow})
            OR buf_chk-doc.chk-type = integer({&rcpt-trans-cancell})
            OR buf_chk-doc.chk-type = integer({&rcpt-trans-transfer})
            OR buf_chk-doc.chk-type = integer({&rcpt-tech-refuell})
             )
      NO-LOCK
      :

      IF ( buf_chk-doc.shift-date = p-shift-date-start
      AND  buf_chk-doc.shift-num  < p-shift-num-start)

      OR ( buf_chk-doc.shift-date = p-shift-date-end
      AND  buf_chk-doc.shift-num  > p-shift-num-end)
      THEN dO:
         NEXT _shift-chk.
      END.

      v-counter = v-counter + 1.
      IF v-counter MODULO 10 = 0
      then DO:
         run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 чеков по топливу", v-counter)).
      END.
      run add-chk in this-procedure ( input buf_chk-doc.obj-type
                                            , input buf_chk-doc.obj-code
                                            , input buf_chk-doc.doc-code
                                            , input buf_chk-doc.chk-type
                                            ) .
   END.

    run post-add-chks.

   /* печать */
   DEFINE FRAME FRAME-9
      pol1  no-label format "x(28)" space(0)
      sym1  no-label format "x(1)"  space(0)
      pol2  no-label format "x(3)" space(0)
      sym2  no-label format "x(1)"  space(0)
      pol3  no-label format "x(5)" space(0)
      sym3  no-label format "x(1)"  space(0)
      pol4  no-label format "->>>,>>>,>>9.99" space(0)
      sym4  no-label format "x(1)"  space(0)
      pol5  no-label format "->>>,>>>,>>9.99" space(0)
      sym5  no-label format "x(1)"  space(0)
      pol6  no-label format "->>>,>>>,>>9.99" space(0)
      sym6  no-label format "x(1)"  space(0)
      pol7  no-label format "->>>,>>>,>>9.99" space(0)
      sym7  no-label format "x(1)"  space(0)
      pol8  no-label format "->>>,>>>,>>9.99" space(0)
      sym8  no-label format "x(1)"  space(0)
      pol9  no-label format "->>>,>>>,>>9.99" space(0)
      sym9  no-label format "x(1)"  space(0)
      pol10 no-label format "->>>,>>>,>>9.99" space(0)
      sym10 no-label format "x(1)"  space(0)
      pol11 no-label format "->>>,>>>,>>9.99" space(0)
      sym11 no-label format "x(1)"  space(0)
      pol12 no-label format "->>>,>>>,>>9.99" space(0)
      sym12 no-label format "x(1)"  space(0)
      pol13 no-label format "->>>,>>>,>>9.99" space(0)

   with width {&DOS_CW_2} down stream-io use-text NO-BOX.

   FORM HEADER
   {&Header-Text9}
   with FRAME TopFrame width {&DOS_CW_2} PAGE-Top NO-LABELS NO-BOX .
   VIEW STREAM PrnLibStream FRAME TOpFrame .

   for each  bf_t-9
       break by bf_t-9.gds-code
       :

      run on-same-page in this-procedure ({&bottom-height} + 1) .
      IF first-of (bf_t-9.gds-code) THEN DO:
         assign
            pol1  = bf_t-9.gds-name
            pol2  = STRING(bf_t-9.pump-code, ">>9")
            pol3  = STRING(bf_t-9.nozzle-code, ">>9")
            pol4  = bf_t-9.start-mh-qnty
            pol5  = bf_t-9.end-mh-qnty
            pol6  = bf_t-9.meas-qnty
            pol7  = bf_t-9.doc-qnty
            pol8  = bf_t-9.tech-refuell-qnty
            pol9  = bf_t-9.delta
            pol10  = bf_t-9.cancell-qnty
            pol11  = bf_t-9.cancell-qnty-notot
            pol12 = bf_t-9.overflow-qnty
            pol13 = bf_t-9.trans-qnty
        .
      end.
      else do:
         assign
            pol1  = "":U
            pol2  = STRING(bf_t-9.pump-code, ">>9")
            pol3  = STRING(bf_t-9.nozzle-code, ">>9")
            pol4  = bf_t-9.start-mh-qnty
            pol5  = bf_t-9.end-mh-qnty
            pol6  = bf_t-9.meas-qnty
            pol7  = bf_t-9.doc-qnty
            pol8  = bf_t-9.tech-refuell-qnty
            pol9  = bf_t-9.delta
            pol10  = bf_t-9.cancell-qnty
            pol11  = bf_t-9.cancell-qnty-notot
            pol12 = bf_t-9.overflow-qnty
            pol13 = bf_t-9.trans-qnty
         .
      end.

      DISPLAY Stream PrnLibStream
          {&All-sym}
          {&All-pol}
      WITH FRAME Frame-9.
      down stream PrnLibStream with frame frame-9.

      {&PutExcel}
         pol1   {&tabulation}
         pol2   {&tabulation}
         pol3   {&tabulation}
         pol4   {&tabulation}
         pol5   {&tabulation}
         pol6   {&tabulation}
         pol7   {&tabulation}
         pol8   {&tabulation}
         pol9   {&tabulation}
         pol10  {&tabulation}
         pol11  {&tabulation}
         pol12  {&tabulation}
         pol13  {&tabulation}         
      SKIP.

      accumulate bf_t-9.start-mh-qnty       (Total by bf_t-9.gds-code).
      accumulate bf_t-9.end-mh-qnty         (Total by bf_t-9.gds-code).
      accumulate bf_t-9.meas-qnty           (Total by bf_t-9.gds-code).
      accumulate bf_t-9.doc-qnty            (Total by bf_t-9.gds-code).
      accumulate bf_t-9.delta               (Total by bf_t-9.gds-code).
      accumulate bf_t-9.tech-refuell-qnty   (Total by bf_t-9.gds-code).
      accumulate bf_t-9.cancell-qnty        (Total by bf_t-9.gds-code).
      accumulate bf_t-9.cancell-qnty-notot  (Total by bf_t-9.gds-code).
      accumulate bf_t-9.overflow-qnty       (Total by bf_t-9.gds-code).
      accumulate bf_t-9.trans-qnty          (Total by bf_t-9.gds-code).

      IF last-of (bf_t-9.gds-code) THEN DO:
         assign
            pol1  = SUBSTITUTE("Всего по &1", bf_t-9.gds-name)
            pol2  = ""
            pol3  = ""
            pol4  = accum Total by bf_t-9.gds-code bf_t-9.start-mh-qnty
            pol5  = accum Total by bf_t-9.gds-code bf_t-9.end-mh-qnty
            pol6  = accum Total by bf_t-9.gds-code bf_t-9.meas-qnty
            pol7  = accum Total by bf_t-9.gds-code bf_t-9.doc-qnty
            pol8  = accum Total by bf_t-9.gds-code bf_t-9.tech-refuell-qnty
            pol9  = accum Total by bf_t-9.gds-code bf_t-9.delta
            pol10 = accum Total by bf_t-9.gds-code bf_t-9.cancell-qnty
            pol11 = accum Total by bf_t-9.gds-code bf_t-9.cancell-qnty-notot
            pol12 = accum Total by bf_t-9.gds-code bf_t-9.overflow-qnty
            pol13 = accum Total by bf_t-9.gds-code bf_t-9.trans-qnty
         .
         underline stream PrnLibStream
            {&All-sym}
            {&All-Pol}
         with frame frame-9.
         down stream PrnLibStream with frame frame-9.
         DISPLAY Stream PrnLibStream
            {&All-sym}
            {&All-pol}
         WITH FRAME Frame-9.
         down stream PrnLibStream with frame frame-9.
         underline stream PrnLibStream
            {&All-sym}
            {&All-Pol}
         with frame frame-9.
         down stream PrnLibStream with frame frame-9.

         {&PutExcel}
            pol1   {&tabulation}
            pol2   {&tabulation}
            pol3   {&tabulation}
            pol4   {&tabulation}
            pol5   {&tabulation}
            pol6   {&tabulation}
            pol7   {&tabulation}
            pol8   {&tabulation}
            pol9   {&tabulation}
            pol10  {&tabulation}
            pol11  {&tabulation}
            pol12  {&tabulation}
            pol13  {&tabulation}            
         SKIP.
      END.
   end. /* each  bf_t-9 */
END.

procedure post-add-chks:
    def buffer buf_t-9 for t-9.
    
    for each buf_t-9:
        buf_t-9.delta = buf_t-9.delta + tech-refuell-qnty.
    end.
end.

procedure add-chk :
define input  parameter p-obj-type like ub.chk-doc.obj-type no-undo .
define input  parameter p-obj-code like ub.chk-doc.obj-code no-undo .
define input  parameter p-doc-code like ub.chk-doc.doc-code no-undo .
define input  parameter p-chk-type like ub.chk-doc.chk-type no-undo .


define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.

define buffer buf_t-9 for t-9.

define variable v-pump as integer   no-undo .
define variable v-nozzle-code    as integer      no-undo.
define variable v-qnty like ub.chk-gds.doc-qnty no-undo init 0.

do
on error undo, return error return-value
:
   for each buf_chk-gds
      where buf_chk-gds.doc-code = p-doc-code
      no-lock
      ,
      first buf_bar-code
      where buf_bar-code.b-code = buf_chk-gds.b-code
      no-lock
      :
      assign
         v-pump        = buf_chk-gds.pump
         v-nozzle-code = buf_chk-gds.nozzle-code
         v-qnty        = buf_chk-gds.doc-qnty
      .

      find first buf_t-9
            WHERE
            buf_t-9.gds-code    = buf_bar-code.gds-code
            AND buf_t-9.pump        = v-pump
            AND buf_t-9.nozzle-code = v-nozzle-code
      no-error
      .
      if not available buf_t-9 then do:
         /*не нашлось ТОЧНО ТАКОЙ ЖЕ СВЯЗКИ ТРК-ПИСТОЛЕТ*/
         /*к чему бы его присобачить???*/
         /*ищем нет ЕДИНСТВЕННАЯ ЛИ СВЯЗКА С ТАКИМ ТРК  или есть по многим пистолетам*/
         find /*first*/  buf_t-9
               WHERE
               buf_t-9.gds-code    = buf_bar-code.gds-code
               AND buf_t-9.pump        = v-pump
         no-error
         .
         if not available buf_t-9 then do:
            find first buf_t-9
                  WHERE
                      buf_t-9.gds-code    = buf_bar-code.gds-code
            no-error
            .
            if not available buf_t-9 then do:
              /*значит это скорее всего нетопливный товар - пропсукаем*/
            NEXT.
            end.
            else do:
              /*это топливный товар но ни к какой связке присобачить не удалось*/
            find first buf_goods
               where buf_goods.gds-code = buf_bar-code.gds-code
               no-lock
               .
            create buf_t-9.
            assign
               buf_t-9.gds-code    = buf_bar-code.gds-code
               buf_t-9.pump        = v-pump
               buf_t-9.nozzle-code = v-nozzle-code
               buf_t-9.gds-name    = buf_goods.gds-name
            .
            end.
         END.
         ELSE DO:
            /*нашлось ЕДИНСТВЕННОЕ сочетание ТРК-пистолет с таким ТРК и туда можно добавит наш чек */
         END.
      end.
      case p-chk-type:
      WHEN integer({&rcpt-sale})
      OR WHEN integer({&rcpt-return})
      then do:
         assign
            buf_t-9.doc-qnty      = buf_t-9.doc-qnty + v-qnty
            buf_t-9.delta         = buf_t-9.delta + v-qnty
         .
      end.
      WHEN integer({&rcpt-overflow}) THEN DO:
         assign
            buf_t-9.overflow-qnty = buf_t-9.overflow-qnty + v-qnty
         .
      end.
      WHEN integer({&rcpt-trans-cancell}) THEN DO:
         if buf_chk-gds.write-off-code = 0 then
         assign
            buf_t-9.cancell-qnty  = buf_t-9.cancell-qnty  + v-qnty
         .
         if buf_chk-gds.write-off-code = 1 then
         assign
            buf_t-9.cancell-qnty-notot  = buf_t-9.cancell-qnty-notot + v-qnty
         . 
      end.
      WHEN integer({&rcpt-trans-transfer}) THEN DO:
         assign
            buf_t-9.trans-qnty    = buf_t-9.trans-qnty    + v-qnty
         .
      end.
      WHEN integer({&rcpt-tech-refuell}) THEN DO:
          assign
            buf_t-9.tech-refuell-qnty = buf_t-9.tech-refuell-qnty + v-qnty
         .
      end.
      OTHERWISE DO:
      end.
      END case.
   end. /*for each buf_chk-gds*/
end. /*do on error */

end procedure. /* add-chk */


/*==========================================================================*/
procedure calc-rest :
DEFINE INPUT PARAMETER p-obj-type         like ub.shift-obj.obj-type    no-undo.
DEFINE INPUT PARAMETER p-obj-code         like ub.shift-obj.obj-code    no-undo.
DEFINE INPUT PARAMETER p-shift-date-start like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-start  like ub.shift-obj.shift-num   no-undo.
DEFINE INPUT PARAMETER p-shift-date-end   like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-end    like ub.shift-obj.shift-num   no-undo.

define buffer buf_rvs-doc        for ub.rvs-doc .
define buffer buf_rvs-line-pump  for ub.rvs-line-pump .
define buffer buf_t-9            for t-9 .
define buffer buf2_t-9            for t-9 .
define buffer buf_shift-obj      for ub.shift-obj .

define variable v-gds-name  as character    no-undo.
define variable v-dop as decimal no-undo .

do
on error undo, return error
:
   FIND LAST  buf_shift-obj
        WHERE buf_shift-obj.obj-type = p-obj-type
          AND buf_shift-obj.obj-code = p-obj-code
          and (
              (buf_shift-obj.shift-date = p-shift-date-start
          AND     buf_shift-obj.shift-num < p-shift-num-start)
           OR
               buf_shift-obj.shift-date < p-shift-date-start)
        use-index pi
        NO-LOCK
        NO-ERROR
        .

   /* Счетчики на начало */
   IF AVAILABLE buf_shift-obj THEN DO:
      find first buf_rvs-doc
         where  buf_rvs-doc.obj-type  = p-obj-type
         and   buf_rvs-doc.obj-code   = p-obj-code
         and   buf_rvs-doc.status_    = {&fact}
         and   buf_rvs-doc.shift-date = buf_shift-obj.shift-date
         and   buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
         and   buf_rvs-doc.rvs-type   = {&rvs-shift}
         no-lock
         no-error
         .
      IF AVAILABLE buf_rvs-doc THEN DO:
         FOR EACH    buf_rvs-line-pump
               WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
               NO-LOCK
               :
               find first buf_t-9
                     WHERE buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                       AND buf_t-9.pump        = buf_rvs-line-pump.pump-code
                       AND buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
               no-error
               .
               if not available buf_t-9 then do:
                    find first buf_goods
                         where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                         no-lock
                         no-error
                         .
                    IF AVAILABLE buf_goods THEN DO:
                       assign
                          v-gds-name = buf_goods.gds-name
                       .
                    END.
                    else do:
                       assign
                          v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line-pump.gds-code)
                       .
                    end.
                    create buf_t-9.
                    assign
                       buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                       buf_t-9.pump        = buf_rvs-line-pump.pump-code
                       buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                       buf_t-9.gds-name    = v-gds-name
                    .
               ASSIGN
          buf_t-9.start-mh-qnty = buf_rvs-line-pump.state-mh-cnt
          buf_t-9.end-mh-qnty = buf_rvs-line-pump.state-mh-cnt
          /*это на каждой следующей итерации в meas-qnty будем добавлять*/
          buf_t-9.prev-start-mh-qnty = buf_rvs-line-pump.state-mh-cnt
          buf_t-9.start-el-qnty = buf_rvs-line-pump.state-el-cnt
          buf_t-9.end-el-qnty = buf_rvs-line-pump.state-el-cnt
          /*это на каждой следующей итерации в meas-qnty будем добавлять*/
          buf_t-9.prev-start-el-qnty = buf_rvs-line-pump.state-el-cnt
          /*пока до места где вычитаем по чекам delta = обороту по счетчикам*/
          buf_t-9.delta         = - buf_t-9.meas-qnty
               .
        end. /*if not available buf_t-9 then do:*/
      END. /*FOR EACH    buf_rvs-line-pump NO-LOCK*/

         RELEASE buf_rvs-doc.
    END. /*IF AVAILABLE buf_rvs-doc THEN DO:*/
  END. /*IF AVAILABLE buf_shift-obj THEN DO:*/
  for each buf_shift-obj no-lock where
          buf_shift-obj.obj-type = p-obj-type
      and buf_shift-obj.obj-code = p-obj-code
      and (buf_shift-obj.shift-date > p-shift-date-start
      or (buf_shift-obj.shift-date = p-shift-date-start
          and
          buf_shift-obj.shift-num >= p-shift-num-start))
      and
         (buf_shift-obj.shift-date < p-shift-date-end
      or (buf_shift-obj.shift-date = p-shift-date-end
          and
          buf_shift-obj.shift-num <= p-shift-num-end))
  by buf_shift-obj.shift-date
  by buf_shift-obj.shift-num:

   /* Счетчики на конец */
   find first buf_rvs-doc
      where  buf_rvs-doc.obj-type  = p-obj-type
      and   buf_rvs-doc.obj-code   = p-obj-code
      and   buf_rvs-doc.status_    = {&fact}
      and   buf_rvs-doc.shift-date = buf_shift-obj.shift-date
      and   buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
      and   buf_rvs-doc.rvs-type   = {&rvs-shift}
      no-lock
      no-error
      .
   /*  конечная смена закрыта */
   IF AVAILABLE buf_rvs-doc THEN DO:
      FOR EACH    buf_rvs-line-pump
            WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
            NO-LOCK
            :
            find first buf_t-9
                  WHERE /*buf_t-9.obj-type  = p-obj-type
                  AND buf_t-9.obj-code    = p-obj-code
                  AND*/ buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                  AND buf_t-9.pump        = buf_rvs-line-pump.pump-code
                  AND buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
            no-error
            .
            if not available buf_t-9 then do:
          find first buf2_t-9
                WHERE /*buf_t-9.obj-type  = p-obj-type
                AND buf_t-9.obj-code    = p-obj-code
                AND*/  buf2_t-9.pump        = buf_rvs-line-pump.pump-code
                AND buf2_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
          no-error
        .
          /*в конфигурации ДО первой смены НЕ БЫЛО ТАКОЙ ТРК!!!*/
               find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                  no-lock
                  no-error
                  .
               IF AVAILABLE buf_goods THEN DO:
                  assign
                     v-gds-name = buf_goods.gds-name
                  .
               END.
               else do:
                  assign
                     v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line-pump.gds-code)
                  .
               end.
               create buf_t-9.
               assign
                  /*
                  buf_t-9.obj-type    = p-obj-type
                  buf_t-9.obj-code    = p-obj-code
                  */
                  buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                  buf_t-9.pump        = buf_rvs-line-pump.pump-code
                  buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                  buf_t-9.gds-name    = v-gds-name
               .
          if available buf2_t-9 then do:
            assign
            buf_t-9.start-mh-qnty = buf2_t-9.prev-start-mh-qnty
            buf_t-9.end-mh-qnty = buf2_t-9.prev-start-mh-qnty
            buf_t-9.prev-start-mh-qnty = buf2_t-9.prev-start-mh-qnty
            buf_t-9.start-el-qnty = buf2_t-9.prev-start-el-qnty
            buf_t-9.end-el-qnty = buf2_t-9.prev-start-el-qnty
            buf_t-9.prev-start-el-qnty = buf2_t-9.prev-start-el-qnty
            .
            end.
          else do:
          /*можeт надо из инвентаризации счетчиков взять???*/
          v-dop = ?.
          run get-state-mh-cnt-from-icnt-doc in this-procedure (
                                                                 input p-obj-type
                                                                ,input p-obj-code
                                                                ,input buf_shift-obj.shift-date
                                                                ,input buf_shift-obj.shift-num
                                                                ,input buf_rvs-doc.fact-order
                                                                ,input buf_t-9.gds-code
                                                                ,input buf_t-9.pump
                                                                ,input buf_t-9.nozzle-code
                                                                ,input-output buf_t-9.prev-start-mh-qnty
                                                                ,input-output buf_t-9.prev-start-el-qnty
                                                                ).

            ASSIGN
          /*это на каждой следующей итерации в meas-qnty будем добавлять*/
          buf_t-9.start-mh-qnty = buf_t-9.prev-start-mh-qnty
          buf_t-9.end-mh-qnty = buf_t-9.prev-start-mh-qnty
          buf_t-9.start-el-qnty = buf_t-9.prev-start-el-qnty
          buf_t-9.end-el-qnty = buf_t-9.prev-start-el-qnty
            .
          end.
        end. /*if not available buf_t-9 then do:*/
        if buf_rvs-line-pump.state-mh-cnt <  buf_t-9.end-mh-qnty then do:
          /*был переход через 0*/
            v-dop = ?.
            run get-state-mh-cnt-from-icnt-doc in this-procedure (
                                                                   input p-obj-type
                                                                  ,input p-obj-code
                                                                  ,input buf_shift-obj.shift-date
                                                                  ,input buf_shift-obj.shift-num
                                                                  ,input buf_rvs-doc.fact-order
                                                                  ,input buf_t-9.gds-code
                                                                  ,input buf_t-9.pump
                                                                  ,input buf_t-9.nozzle-code
                                                                  ,input-output buf_t-9.prev-start-mh-qnty
                                                                  ,input-output buf_t-9.prev-start-el-qnty
                                                                  ).
        end.
        ASSIGN
        buf_t-9.end-mh-qnty = buf_rvs-line-pump.state-mh-cnt
        buf_t-9.end-el-qnty = buf_rvs-line-pump.state-el-cnt
        buf_t-9.meas-qnty   = (if p-tog-1-out-pump-with-icnt
                              then (buf_t-9.meas-qnty + buf_rvs-line-pump.state-el-cnt - buf_t-9.prev-start-el-qnty)
                              else (buf_t-9.meas-qnty + buf_rvs-line-pump.state-mh-cnt - buf_t-9.prev-start-mh-qnty)
                              )
        /*пока до места где вычитаем по чекам delta = обороту по счетчикам*/
        buf_t-9.delta       = - buf_t-9.meas-qnty
        buf_t-9.prev-start-mh-qnty  = buf_rvs-line-pump.state-mh-cnt
        buf_t-9.prev-start-el-qnty  = buf_rvs-line-pump.state-el-cnt
        .
      END. /*FOR EACH    buf_rvs-line-pump*/
    END. /*IF AVAILABLE buf_rvs-doc THEN DO:*/
  end. /*  for each buf_shift-obj no-lock where*/
end. /* do on error */
end procedure. /* calc-rest */

procedure get-state-mh-cnt-from-icnt-doc :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-from-shift-date as date no-undo.
define input parameter p-from-shift-num as integer no-undo.
define input parameter p-fact-order as decimal no-undo.
define input parameter p-gds-code as integer no-undo .
define input parameter p-pump-code as integer no-undo .
define input parameter p-nozzle-code as integer no-undo .
define input-output parameter p-state-mh-cnt as decimal no-undo .
define input-output parameter p-state-el-cnt as decimal no-undo .
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
for each buf_icnt-doc no-lock
  where buf_icnt-doc.obj-type = p-obj-type
    and buf_icnt-doc.obj-code = p-obj-code
    and buf_icnt-doc.status_ = {&fact}
    and buf_icnt-doc.fact-order < p-fact-order
    by buf_icnt-doc.fact-order
    descending

on error undo, return error return-value
:
      find first buf_icnt-line no-lock where
            buf_icnt-line.doc-code = buf_icnt-doc.doc-code
        and buf_icnt-line.obj-code = buf_icnt-doc.obj-code
        and buf_icnt-line.obj-type = buf_icnt-doc.obj-type
        and buf_icnt-line.gds-code = p-gds-code
        and buf_icnt-line.pump-code = p-pump-code
        and buf_icnt-line.nozzle-code = p-nozzle-code no-error.
    if available buf_icnt-line then do:
      assign
      p-state-mh-cnt = buf_icnt-line.state-mh-cnt.
      p-state-el-cnt = buf_icnt-line.state-el-cnt.
      leave.
    end.

end.

end procedure. /* get-state-mh-cnt-from-icnt-doc */