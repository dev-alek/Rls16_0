/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с остатками и оборотами мат. ценности на объектах, субобъектах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

/*Текущий остаток по мат. ценности на месте хранения объекта*/
{ cmp/str-glbl.i }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure wth-lib_cur-stock-place:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parw-p-code like ub.wth-pobj.w-p-code  no-undo.
define input  parameter parwth-code like ub.wth-pobj.wth-code  no-undo.
define output parameter parstock    like ub.wth-pobj.income-pl no-undo.
define buffer bf_wth-pobj for ub.wth-pobj.
find first bf_wth-pobj where bf_wth-pobj.obj-type = parobj-type and
                             bf_wth-pobj.obj-code = parobj-code and
                             bf_wth-pobj.w-p-code = parw-p-code and
                             bf_wth-pobj.wth-code = parwth-code no-lock no-error.
if available bf_wth-pobj then assign parstock = bf_wth-pobj.income-pl - bf_wth-pobj.incass-pl.
                         else assign parstock = 0.
end procedure.

/*текущий остаток мат. ценности на объекте*/
procedure wth-lib_cur-stock-obj:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parwth-code like ub.wth-obj.wth-code   no-undo.
define output parameter parstock    like ub.wth-obj.income     no-undo.
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then assign parstock = bf_wth-obj.income - bf_wth-obj.incass.
                        else assign parstock = 0.

end.

/*текущий остаток мат. ценности на объекте(функция)*/
FUNCTION wth-lib_cur-stock-obj-func RETURNS DECIMAL (INPUT parobj-type AS CHARACTER,
                                                     INPUT parobj-code AS INTEGER,
                                                     INPUT parwth-code AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then return (bf_wth-obj.income - bf_wth-obj.incass).
                        else return 0.00.
end function.

/*текущий остаток мат. ценности на фирме(функция)*/
FUNCTION wth-lib_cur-stock-host-func RETURNS DECIMAL (INPUT parhost-code AS INTEGER,
                                                      INPUT parwth-code  AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.

define variable v-stock like ub.wth-obj.income no-undo.
for each bf_wth-obj no-lock where bf_wth-obj.host-code = parhost-code and
                                  bf_wth-obj.wth-code = parwth-code :
  v-stock = v-stock +  bf_wth-obj.income - bf_wth-obj.incass.
end.
return v-stock.
end function.

&scop stock-ot-information ~
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        ~
define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        ~
define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        ~
~{&input-parameters~}                                                              ~
define output parameter parstock-start  like ub.wth-line.income       no-undo.        ~
define output parameter parstock-end    like ub.wth-line.income       no-undo.        ~
define output parameter parincome       like ub.wth-line.income       no-undo.        ~
define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        ~
define output parameter parincome-other like ub.wth-line.income-other no-undo.        ~
define output parameter parincass       like ub.wth-line.incass       no-undo.        ~
define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        ~
define output parameter parincass-other like ub.wth-line.incass-other no-undo.        ~
define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        ~
define buffer cur_wth-line   for ub.wth-line.                                         ~
define buffer start_wth-line for ub.wth-line.                                         ~
find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and           ~
                             cur_wth-line.obj-code   = parobj-code   and           ~
                             ~{&cur-place-where~}                                  ~
                             cur_wth-line.wth-code   = parwth-code   and           ~
                             ~{&cur-where~}                                        ~
                             cur_wth-line.status_    = {&fact}       use-index     ~
                             ~{&find-index~} no-lock no-error.                     ~
find last start_wth-line where start_wth-line.obj-type   = parobj-type         and ~
                               start_wth-line.obj-code   = parobj-code         and ~
                               ~{&start-place-where~}                              ~
                               start_wth-line.wth-code   = parwth-code         and ~
                               ~{&start-where~}                                    ~
                               start_wth-line.status_ = {&fact}                    ~
                               use-index ~{&find-index~} no-lock no-error.         ~
if not available start_wth-line then do:                                           ~
   if not available cur_wth-line then do:                                           ~
      assign                                                                          ~
      parstock-start   = 0                                                            ~
      parstock-end     = 0                                                            ~
      parincome        = 0                                                            ~
      parincome-cassa  = 0                                                            ~
      parincome-other  = 0                                                            ~
      parincass        = 0                                                            ~
      parincass-bank   = 0                                                            ~
      parincass-other  = 0.                                                           ~
      parincass-cassa  = 0.                                                           ~
   end.                                                                            ~
   else do:                                                                        ~
      assign parstock-start   = 0  ~
             parstock-end     = cur_wth-line.income~{&sf~} - cur_wth-line.incass~{&sf~} ~
             parincome        = cur_wth-line.income~{&sf~}        ~
             parincome-cassa  = cur_wth-line.income-cassa~{&sf~}  ~
             parincome-other  = cur_wth-line.income-other~{&sf~}  ~
             parincass        = cur_wth-line.incass~{&sf~}        ~
             parincass-bank   = cur_wth-line.incass-bank~{&sf~}   ~
             parincass-other  = cur_wth-line.incass-other~{&sf~}. ~
             parincass-cassa  = cur_wth-line.incass-cassa~{&sf~}. ~
                                                                                   ~
   end.                                                                            ~
end.                                                                               ~
else do:                                                                           ~
   if available cur_wth-line then do:                                              ~
      assign                                                                       ~
      parstock-start   = start_wth-line.income~{&sf~}     - start_wth-line.incass~{&sf~}         ~
      parstock-end     = cur_wth-line.income~{&sf~}       - cur_wth-line.incass~{&sf~}           ~
      parincome        = cur_wth-line.income~{&sf~}       - start_wth-line.income~{&sf~}         ~
      parincome-cassa  = cur_wth-line.income-cassa~{&sf~} - start_wth-line.income-cassa~{&sf~}   ~
      parincome-other  = cur_wth-line.income-other~{&sf~} - start_wth-line.income-other~{&sf~}   ~
      parincass        = cur_wth-line.incass~{&sf~}       - start_wth-line.incass~{&sf~}         ~
      parincass-bank   = cur_wth-line.incass-bank~{&sf~}  - start_wth-line.incass-bank~{&sf~}    ~
      parincass-other  = cur_wth-line.incass-other~{&sf~} - start_wth-line.incass-other~{&sf~}.  ~
      parincass-cassa  = cur_wth-line.incass-cassa~{&sf~} - start_wth-line.incass-cassa~{&sf~}.  ~
   end.                                                                            ~
   else do:                                                                        ~
      assign                                                                       ~
      parstock-start   = start_wth-line.income~{&sf~} - start_wth-line.incass~{&sf~}             ~
      parstock-end     = parstock-start                                            ~
      parincome        = 0                                                         ~
      parincome-cassa  = 0                                                         ~
      parincome-other  = 0                                                         ~
      parincass        = 0                                                         ~
      parincass-bank   = 0                                                         ~
      parincass-other  = 0.                                                        ~
      parincass-cassa  = 0.                                                        ~
   end.                                                                            ~
end.

/*Вся информации об остатках и оборотах по объекту за смену*/
procedure wth-lib_full-inf-shift:
/*input  parobj-type     like clients.obj-type      */
/*input  parobj-code     like clients.obj-code      */
/*input  parwth-code     like wth-line.wth-code     */
/*input  parshift-date   like shift-obj.shift-date  */
/*input  parshift-num    like shift-obj.shift-num   */
/*output parstock-start  like wth-line.income       */
/*output parstock-end    like wth-line.income       */
/*output parincome       like wth-line.income       */
/*output parincome-cassa like wth-line.income-cassa */
/*output parincome-other like wth-line.income-other */
/*output parincass       like wth-line.incass       */
/*output parincass-bank  like wth-line.incass-bank  */
/*output parincass-other like wth-line.incass-other */
/*output parincass-cassa like wth-line.incass-cassa */

&scop input-parameters define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo. ~
                       define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.
&scop cur-where        cur_wth-line.shift-date = parshift-date and ~
                       cur_wth-line.shift-num  = parshift-num  and
&scop start-where      (start_wth-line.shift-date = parshift-date and   ~
                        start_wth-line.shift-num  < parshift-num  or    ~
                        start_wth-line.shift-date < parshift-date ) and
&scop cur-place-where
&scop start-place-where
&scop sf
&scop find-index stat-sdn
{&stock-ot-information}
end procedure.

/*Вся информации об остатках и оборотах по объекту за интервал смен*/
procedure wth-lib_full-inf-shift-inter:
/*input  parobj-type     like clients.obj-type      */
/*input  parobj-code     like clients.obj-code      */
/*input  parwth-code     like wth-line.wth-code     */
/*input  parshift-date   like shift-obj.shift-date  */
/*input  parshift-num    like shift-obj.shift-num   */
/*input  parshift-date1  like shift-obj.shift-date  */
/*input  parshift-num1   like shift-obj.shift-num   */
/*output parstock-start  like wth-line.income       */
/*output parstock-end    like wth-line.income       */
/*output parincome       like wth-line.income       */
/*output parincome-cassa like wth-line.income-cassa */
/*output parincome-other like wth-line.income-other */
/*output parincass       like wth-line.incass       */
/*output parincass-bank  like wth-line.incass-bank  */
/*output parincass-other like wth-line.incass-other */
/*output parincass-cassa like wth-line.incass-cassa */

&scop input-parameters define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo. ~
                       define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo. ~
                       define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo. ~
                       define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.
&scop cur-where        ((cur_wth-line.shift-date = parshift-date1 and   ~
                        cur_wth-line.shift-num  <= parshift-num1)  or    ~
                        cur_wth-line.shift-date < parshift-date1 ) and
&scop start-where      (start_wth-line.shift-date = parshift-date and   ~
                        start_wth-line.shift-num  < parshift-num  or    ~
                        start_wth-line.shift-date < parshift-date ) and
&scop cur-place-where
&scop start-place-where
&scop sf
&scop find-index stat-sdn
{&stock-ot-information}
end procedure.

/*Вся информации об остатках и оборотах по месту за интервал смен - пока не используется нигде*/
procedure wth-lib_full-inf-shift-period-place:
/*input  parobj-type     like clients.obj-type      */
/*input  parobj-code     like clients.obj-code      */
/*input  parwth-code     like wth-line.wth-code     */
/*input  parw-p-code     like wth-line.w-p-code     */
/*input  parshift-date   like shift-obj.shift-date  */
/*input  parshift-num    like shift-obj.shift-num   */
/*input  parshift-date1  like shift-obj.shift-date  */
/*input  parshift-num1   like shift-obj.shift-num   */
/*output parstock-start  like wth-line.income       */
/*output parstock-end    like wth-line.income       */
/*output parincome       like wth-line.income       */
/*output parincome-cassa like wth-line.income-cassa */
/*output parincome-other like wth-line.income-other */
/*output parincass       like wth-line.incass       */
/*output parincass-bank  like wth-line.incass-bank  */
/*output parincass-other like wth-line.incass-other */
/*output parincass-cassa like wth-line.incass-cassa */

&scop input-parameters define input  parameter parw-p-code     like ub.wth-pobj.w-p-code  no-undo. ~
                       define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo. ~
                       define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo. ~
                       define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo. ~
                       define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.
&scop cur-where        ((cur_wth-line.shift-date = parshift-date1 and   ~
                        cur_wth-line.shift-num  <= parshift-num1)  or    ~
                        cur_wth-line.shift-date < parshift-date1 ) and
&scop start-where      (start_wth-line.shift-date = parshift-date and   ~
                        start_wth-line.shift-num  < parshift-num  or    ~
                        start_wth-line.shift-date < parshift-date ) and
&scop cur-place-where   cur_wth-line.w-p-code = parw-p-code and
&scop start-place-where start_wth-line.w-p-code = parw-p-code and
&scop sf                -pl
&scop find-index stat-sdn
{&stock-ot-information}
end procedure.


/*Вся информации об остатках и оборотах по месту хранения на объекте за смену*/
procedure wth-lib_full-inf-shift-place:
/*input  parobj-type     like clients.obj-type      */
/*input  parobj-code     like clients.obj-code      */
/*input  parwth-code     like wth-line.wth-code     */
/*input  parw-p-code     like wth-line.w-p-code     */
/*input  parshift-date   like shift-obj.shift-date  */
/*input  parshift-num    like shift-obj.shift-num   */
/*output parstock-start  like wth-line.income       */
/*output parstock-end    like wth-line.income       */
/*output parincome       like wth-line.income       */
/*output parincome-cassa like wth-line.income-cassa */
/*output parincome-other like wth-line.income-other */
/*output parincass       like wth-line.incass       */
/*output parincass-bank  like wth-line.incass-bank  */
/*output parincass-other like wth-line.incass-other */
/*output parincass-cassa like wth-line.incass-cassa */
&scop input-parameters define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo. ~
                       define input parameter parshift-date like ub.shift-obj.shift-date  no-undo. ~
                       define input parameter parshift-num  like ub.shift-obj.shift-num   no-undo.
&scop cur-where        cur_wth-line.shift-date = parshift-date and ~
                       cur_wth-line.shift-num  = parshift-num  and
&scop start-where      (start_wth-line.shift-date = parshift-date and   ~
                        start_wth-line.shift-num  < parshift-num  or    ~
                        start_wth-line.shift-date < parshift-date ) and
&scop cur-place-where    cur_wth-line.w-p-code   = parw-p-code and
&scop start-place-where  start_wth-line.w-p-code = parw-p-code and
&scop sf                 -pl
&scop find-index stat-sdn-pl
{&stock-ot-information}
end procedure.

/*Вся информации об остатках и оборотах по объекту за сменные сутки*/
procedure wth-lib_full-inf-shift-date:
/*input  parobj-type     like clients.obj-type      */
/*input  parobj-code     like clients.obj-code      */
/*input  parwth-code     like wth-line.wth-code     */
/*input  parshift-date   like shift-obj.shift-date  */
/*output parstock-start  like wth-line.income       */
/*output parstock-end    like wth-line.income       */
/*output parincome       like wth-line.income       */
/*output parincome-cassa like wth-line.income-cassa */
/*output parincome-other like wth-line.income-other */
/*output parincass       like wth-line.incass       */
/*output parincass-bank  like wth-line.incass-bank  */
/*output parincass-other like wth-line.incass-other */
/*output parincass-cassa like wth-line.incass-cassa */
&scop input-parameters define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.
&scop cur-where        cur_wth-line.shift-date = parshift-date   and
&scop start-where      start_wth-line.shift-date < parshift-date and
&scop cur-place-where
&scop start-place-where
&scop sf
&scop find-index stat-sd
{&stock-ot-information}
end procedure.

/*Вся информации об остатках и оборотах по месту хранения на объекте за сменные сутки*/
procedure wth-lib_full-inf-shift-date-place:
/*input  parobj-type     like clients.obj-type      */
/*input  parobj-code     like clients.obj-code      */
/*input  parwth-code     like wth-line.wth-code     */
/*input  parw-p-code     like wth-line.w-p-code     */
/*input  parshift-date   like shift-obj.shift-date  */
/*output parstock-start  like wth-line.income       */
/*output parstock-end    like wth-line.income       */
/*output parincome       like wth-line.income       */
/*output parincome-cassa like wth-line.income-cassa */
/*output parincome-other like wth-line.income-other */
/*output parincass       like wth-line.incass       */
/*output parincass-bank  like wth-line.incass-bank  */
/*output parincass-other like wth-line.incass-other */
/*output parincass-cassa like wth-line.incass-cassa */
&scop input-parameters define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo. ~
                       define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.
&scop cur-where        cur_wth-line.shift-date = parshift-date   and
&scop start-where      start_wth-line.shift-date < parshift-date and
&scop cur-place-where    cur_wth-line.w-p-code   = parw-p-code and
&scop start-place-where  start_wth-line.w-p-code = parw-p-code and
&scop sf                 -pl
&scop find-index stat-sd-pl
{&stock-ot-information}
end procedure.

/*Вся информации об остатках и оборотах по объекту за календарные сутки*/
procedure wth-lib_full-inf-calend-date:
/*input  parobj-type     like clients.obj-type      */
/*input  parobj-code     like clients.obj-code      */
/*input  parwth-code     like wth-line.wth-code     */
/*input  parfact-date    like wth-line.fact-date    */
/*output parstock-start  like wth-line.income       */
/*output parstock-end    like wth-line.income       */
/*output parincome       like wth-line.income       */
/*output parincome-cassa like wth-line.income-cassa */
/*output parincome-other like wth-line.income-other */
/*output parincass       like wth-line.incass       */
/*output parincass-bank  like wth-line.incass-bank  */
/*output parincass-other like wth-line.incass-other */
/*output parincass-cassa like wth-line.incass-cassa */
&scop input-parameters define input  parameter parfact-date    like ub.wth-line.fact-date    no-undo.
&scop cur-where        cur_wth-line.fact-date  = parfact-date  and
&scop start-where      start_wth-line.fact-date  < parfact-date   and
&scop cur-place-where
&scop start-place-where
&scop sf
&scop find-index stat-cld
{&stock-ot-information}
end procedure.

/*Вся информации об остатках и оборотах по месту хранения на объекте за календарные сутки*/
procedure wth-lib_full-inf-calend-date-place:
/*input  parobj-type     like clients.obj-type      */
/*input  parobj-code     like clients.obj-code      */
/*input  parwth-code     like wth-line.wth-code     */
/*input  parw-p-code     like wth-line.w-p-code     */
/*input  parfact-date    like wth-line.fact-date    */
/*output parstock-start  like wth-line.income       */
/*output parstock-end    like wth-line.income       */
/*output parincome       like wth-line.income       */
/*output parincome-cassa like wth-line.income-cassa */
/*output parincome-other like wth-line.income-other */
/*output parincass       like wth-line.incass       */
/*output parincass-bank  like wth-line.incass-bank  */
/*output parincass-other like wth-line.incass-other */
/*output parincass-cassa like wth-line.incass-cassa */
&scop input-parameters define input parameter parw-p-code  like ub.wth-line.w-p-code  no-undo. ~
                       define input parameter parfact-date like ub.wth-line.fact-date no-undo.
&scop cur-where        cur_wth-line.fact-date  = parfact-date  and
&scop start-where      start_wth-line.fact-date  < parfact-date   and
&scop cur-place-where    cur_wth-line.w-p-code   = parw-p-code and
&scop start-place-where  start_wth-line.w-p-code = parw-p-code and
&scop sf                 -pl
&scop find-index stat-cld-pl
{&stock-ot-information}
end procedure.

/**/
FUNCTION get-curr RETURNS CHARACTER
  (buffer loc-wealth for ub.wealth ) :
define buffer buf_currency for ub.currency.
if loc-wealth.curr-code = ? or loc-wealth.is-money = no then
return loc-wealth.unit-base.
FIND FIRST buf_currency no-lock where
          buf_currency.curr-code = loc-wealth.curr-code No-ERROR.

if avail buf_currency then
  RETURN buf_currency.curr-abbr.   /* Function return value. */
else return "".

END FUNCTION.


/* $Workfile$ e n d */