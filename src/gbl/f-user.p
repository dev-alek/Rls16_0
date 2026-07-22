block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: f-user.p $
$Archive: gbl/f-user.p $

Выбор пользователя и создание выражения для фильтра

Автор: Хныкин Павел Андреевич
Дата создания: 03/17/08
Author: Pavel Khnykin
Creation date: 03/17/08

*/
define  input parameter parParentProc as widget-handle no-undo.
define  input parameter spr           as character     no-undo.
define  input parameter znak          as character     no-undo.
define  input parameter lab_user      as character     no-undo.
define  input parameter fld           as character     no-undo.
define  input parameter lab           as character     no-undo.
define  input parameter type          as character     no-undo.
define output parameter str           as character     no-undo.
define output parameter str_rus       as character     no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: f-user.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/f-user.p $":U .
define variable vss-description as character no-undo init "Выбор пользователя и создание выражения для фильтра".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_user-account for ub.user-account.
define variable v-cntxt-userid as character no-undo .
define variable v-user-id     as character no-undo .
define variable v-user-login  as character no-undo .
define variable v-user-nik    as character no-undo .
define variable v-user-db-num as integer   no-undo .
define variable v-selected-userid like ub.user-account.user-id        no-undo .
define variable v-old-userid      like ub.user-account.parent-user-id no-undo .

do on error undo, return error return-value
:
  run get-userid in parparentproc ( output v-cntxt-userid).

  run str/usersel.p ( input parparentproc
                    , input v-cntxt-userid
                    , output v-selected-userid
                    , output v-old-userid
                    ).
  find buf_user-account no-lock
    where buf_user-account.user-id = v-selected-userid
  no-error .
  if available buf_user-account then do:
    assign
      v-user-id     = buf_user-account.user-id
      v-user-login  = buf_user-account.parent-user-id
      v-user-nik    = buf_user-account.nik
      v-user-db-num = integer( entry( 1 , v-selected-userid , '-' ) )
    no-error .

    case znak :
      when "=" then do:
        assign
          str     = substitute( '( &1 = "&2" )' , fld , v-user-id )
          str_rus = substitute('&1 &2 "&3" ' , lab_user , znak , v-user-nik )
        .
        if v-user-login <> "" and v-user-login <> ? then do:
          assign
            str = substitute( '( &1 OR ( &2 = &3 ) )' , str , fld , v-user-login )
          .
        end.
      end.
      when "<>" then do:
        assign
          str     = substitute( '( &1 <> "&2" )' , fld , v-user-id )
          str_rus = substitute('&1 &2 "&3" ' , lab_user , znak , v-user-nik )
        .
        if v-user-login <> "" and v-user-login <> ? then do:
          assign
            str = substitute( '( &1 AND ( &2 <> &3 ) )' , str , fld , v-user-login )
          .
        end.
      end.
    end case.
  end. /* if available buf_user-account */
  else do:
    return error "error".
  end.
end.