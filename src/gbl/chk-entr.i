/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедура проверки входит ли данный sys-key в список

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/26/10
Author: Dmitry Ukhanov
Creation date: 01/26/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".

function check-entry-with-mask returns logical ( input p-element as character, input p-list as character, input p-delimiter as character ) :

  define variable p-entry   as logical   no-undo .
  define variable v-ind as integer   no-undo .

  if p-delimiter = "*":U then do:
    message
      vss-workfile "(check-entry-with-mask)" vss-revision vss-description skip
      substitute('Разделитель не может быть равный "&1"', p-delimiter ) skip
      view-as alert-box error .
    return ? .
  end.
  assign
    p-entry = true
  .
  if lookup( p-element, p-list, p-delimiter ) = 0 then do: /* если НЕ указан в списке полностью */
    assign
      p-entry = false /* НЕТ в списоке в полном виде */
    .
    if num-entries( p-list, "*":U ) > 1 then do: /* в списке есть маски, а вдруг элемент указан в виде маски */
      block_check-list:
      do v-ind = 1 to num-entries( p-list, p-delimiter )
      :
        if p-element matches entry( v-ind, p-list, p-delimiter ) then do:
          assign
            p-entry = true /* ЕСТЬ в списке в виде маски */
          .
          leave block_check-list .
        end.
      end.
    end.
  end.

  return p-entry .

end function . /* check-entry-with-mask */

/* $Workfile$   E n d */