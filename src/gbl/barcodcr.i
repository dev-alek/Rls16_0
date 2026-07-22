/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ѕоиск/создание бар-кода товара

јвтор: ѕерваков ћихаил —ергеевич
ƒата создани€: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

»щетс€ бар-код со статусом no-lock
≈сли он находитс€, то возвращаетс€ в буфере

≈сли бар-код не найден, то создаетс€ новый бар-код.

≈сли единица измерени€ бар-кода равна основной единице измерени€,
то поле cli-base-rate устанавливаетс€ равным 1.
≈сли единица измерени€ бар-кода не равна основной единице измерени€,
то поле cli-base-rate устанавливаетс€ равным ?. ≈му нужно присвоить
необходимое значение, так как запись в таком виде не может быть сохранена.

ѕосле создани€ бар-кода может быть не задано поле cli-base-rate
если оно равно нулю, то его надо проинициализировать

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name barcodcr
{&run_proc_library}
  (input  {1} /* p-gds-code      */
  ,input  {2} /* p-node-code     */
  ,input  {3} /* p-part-code     */
  ,input  {4} /* p-in-code       */
  ,input  {5} /* p-unit-cli      */
  ,input  {6} /* p-cli-base-rate */
  ,output {7} /* p-is-new        */
  ,buffer {8} /* buf_bar-code    */
  ) {9} .
/* $Workfile$ e n d */