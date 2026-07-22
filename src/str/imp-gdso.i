/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновить учетную цену услуги в новостях

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/12/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined( imp-gdso_i ) = 0 &then
&glob imp-gdso_i

procedure update-service-price :

  /* обновить учетную цену услуги */
  /* она передается по новостям в записи gds-obj */
  /* при приеме информации в ГБД повторно отправить информацию в УБД */

  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-obj-code   as integer   no-undo .
  define input  parameter p-artic      as character no-undo .
  define input  parameter p-prod-type  as character no-undo .
  define input  parameter p-prod-code  as integer   no-undo .
  define input  parameter p-price-base as decimal   no-undo .
  define input  parameter p-price-rubl as decimal   no-undo .

  define buffer buf_gds-obj for ub.gds-obj .

  do
  on error undo, return error return-value
  :
    { gbl/gdsobjcr.i
      p-obj-type
      p-obj-code
      p-artic
      p-prod-type
      p-prod-code
      buf_gds-obj
      no-error
    }

    find current buf_gds-obj exclusive-lock .

    assign
      buf_gds-obj.price-base = p-price-base
      buf_gds-obj.price-rubl = p-price-rubl
    .

    if g#db-num = 0
    then do:
      run str/callnews.p
        (input {&table_gds-obj}
        ,input (buffer buf_gds-obj:handle)
        ).
    end.
  end.

end procedure. /* update-service-price */

&endif
/* $Workfile$ e n d */