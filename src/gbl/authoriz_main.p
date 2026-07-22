block-level on error undo, throw.
/*

$Revision: 1eba0946c2d7, 3078, rls $
$Author: DRuban $
$Date: Пт авг 05 19:16:25 2022 +0300 $
$Workfile: authoriz_main.p $
$Archive: gbl/authoriz_main.p $

Программа авторизации пользователя для выполнения определенного действия.

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input parameter  p-action as character no-undo .
define output parameter p-permit as logical no-undo .

def var vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: authoriz_main.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/authoriz_main.p $":U .
def var vss-description as character no-undo init "Программа авторизации пользователя для выполнения определенного действия".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

if not ibs.th.gbl.gbl-var:rcode  and not session:debug-alert
then do:
   p-permit = yes.
   return.
end.
  
{ gbl/objsrv.i}

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
assign
  p-permit = false
.

FUNCTION make-num-string RETURN CHAR
( input in-str as character )
:
  def var v-out-str as character no-undo .
  assign
    v-out-str = ''
  .

  def var ind as integer no-undo .
  do ind = 1 to length(in-str) :
    assign
      v-out-str = v-out-str + string(asc( substring(in-str, ind, 1)) - asc(' '))
    .
  end.

  return v-out-str .

end.


def var v-user-name as character no-undo .
def var passwd as character no-undo .

run input-user-and-passwd in this-procedure
  (output v-user-name
  ,output passwd
  ) no-error .
if error-status :error then do:
  return . /* --->>>--- */
end.

case passwd :
  when "request" then do:
    /* необходимо запросить одноразовый пароль у IBS */
    run request-passwd in this-procedure .
  end.
  when "generate" then do:
    /* сгенерировать одноразовый пароль */
    run generate-passwd in this-procedure .
  end.
  when "rndgen" then do:
    /* сгенерировать случайный пароль */
    run random-passwd in this-procedure .
  end.
  otherwise do:
    /* проверить пароль пользователя sysadm */
    run check-passwd in this-procedure
      (input  v-user-name
      ,input  passwd
      ) .
  end.
end.
return . /* --->>>--- */


procedure input-user-and-passwd :
  /* запрашиваем пароль пользователя adm */
  /* если он отсутствует, запрашиваем имя пользователя */

  define output parameter p-user-name as character no-undo .
  define output parameter p-password  as character no-undo .

  assign
    p-user-name = 'sysadm'
  .

  define buffer buf__User for {&db-name_schema}._User .

  find first buf__User no-lock
    where buf__User._Userid = p-user-name
    no-error .

  if not available buf__User then do:
    run gbl/d-prompt.w (
        'title=Введите имя пользователя\'
      + 'text1=Введите имя пользователя\'
      + 'format=x(20)\'
      + 'type=char\'
      ,input-output p-user-name
      ).
    if return-value = 'false':u then do:
      return error . /* --->>>--- */
    end.
  end.

  find first buf__User no-lock
    where buf__User._Userid = p-user-name
    no-error .

  if not available buf__User then do:
    message
      "Пользователь" p-user-name "недоступен"
      view-as alert-box .
    return error . /* --->>>--- */
  end.


  run gbl/d-prompt.w (
      'title=Password Prompter\':u
    + 'text1=Enter password for user "':u + p-user-name + '"\':u
    + 'text2=or enter "request" to receive one time password (generate, rndgen)\':u
    + 'format=x(40)\':u
    + 'password=yes\':u
    + 'type=char\':u
    ,input-output p-password
    ).
  if return-value = 'false':u then do:
    return error . /* --->>>--- */
  end.

end procedure. /* input-user-and-passwd */


procedure generate-passwd :
  def var v-passwd as character no-undo .
  def var v-seed as character no-undo .
  if not objSrv:SystemSetting:DeveloperMode
  then do:
     run gbl/d-prompt.w (
        'title=One time password generation\'
      + 'text1=Enter password\'
      + 'format=x(40)\'
      + 'password=yes\'
      + 'type=char\'
      ,input-output v-passwd
      ).
 
     if encode(v-passwd) <> "idZiiziQdcZKcbba" then do:
       run trg/userlog.p (
                 input 'one-pwd'
                , input ("Введен неправильный пароль для генерации одноразового пароля"  + {&delim-key} + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
       message
         "Incorrect one time generation password"
       view-as alert-box error .
       return . /* --->>>--- */
     end.
  end. 
  run gbl/d-prompt.w (
      'title=One time password\'
    + 'text1=Input client seed\'
    + 'format=x(40)\'
    + 'type=char\'
    ,input-output v-seed
    ).

  assign
    v-passwd = make-num-string(substring(encode( 'ab' + v-seed ), 1, 7))
  .

  run gbl/d-prompt.w (
      'title=One time password\'
    + 'text1=Client seed: "' + v-seed + '"\'
    + 'text2=Send this password to the client\'
    + 'format=x(40)\'
    + 'type=char\'
    ,input-output v-passwd
    ).
    run trg/userlog.p (
                input 'one-pwd'
                , input ("Сгенерирован одноразовый пароль"  + {&delim-key} + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
end procedure. /* generate-passwd */


procedure request-passwd :

  def var v-passwd         as character no-undo .
  def var v-seed           as character no-undo .
  def var v-new-seed       as character no-undo .
  def var v-must-be-passwd as character no-undo .

  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  assign
    v-seed = make-num-string
            (substring
              ( encode( p-action + string ( v-today ) + string(etime) )
              , 1
              , 7
              )
            )
  .

  assign
    v-passwd = v-seed
  .
  assign
    v-must-be-passwd = make-num-string(substring(encode( 'ab' + v-seed ), 1, 7))
  .

  def var ind as integer no-undo .

  do ind = 1 to 3
  :

    run gbl/d-prompt.w (
        'title=Password Prompter\'
      + 'text1=Give seed "' + v-seed + '" to developers of system\'
      + 'text2=Enter recieved password\'
      + 'format=x(40)\'
      + 'type=char\'
      ,input-output v-passwd
      ).
    if return-value = 'false':u then do:
      return . /* --->>>--- */
    end.

    if v-passwd = v-must-be-passwd then do:
       run trg/userlog.p (
                input 'one-pwd'
                , input (substitute( "Введен правильный одноразовый пароль попытка № &1",ind)  + {&delim-key} + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
      run permit-action in this-procedure .
      return . /* --->>>--- */
    end.
    run trg/userlog.p (
                input 'one-pwd'
                , input (substitute( "Введен неправильный одноразовый пароль попытка № &1",ind)  + {&delim-key} + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
    if ind < 3 then do:
      message
        "One-time password incorrect" skip
        "Try once more" skip
        view-as alert-box error .
    end.
    else do:
      message
        "One-time password incorrect" skip
        view-as alert-box error .
    end.
  end.

end procedure. /* request-passwd */


procedure check-passwd :

  define input  parameter p-user-name as character no-undo .
  define input  parameter p-password  as character no-undo .

  define buffer buf__User for {&db-name_schema}._User .

  find first buf__User no-lock
    where buf__User._Userid = p-user-name
    no-error .
  if not available buf__User then do:
    message
      "Пользователь" p-user-name "недоступен"
      view-as alert-box .
    return error . /* --->>>--- */
  end.

  if encode(p-password) = buf__User._Password or objSrv:SystemSetting:DeveloperMode then do:
     run trg/userlog.p (
                input 'one-pwd'
                , input (substitute("Введен пароль для &1", p-user-name)  + {&delim-key} + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
    run permit-action in this-procedure .
  end.
  else do:
    run trg/userlog.p (
                input 'one-pwd'
                , input (substitute("Неправильно введен пароль для &1", p-user-name)  + {&delim-key} + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
    message
      "Неправильно введен пароль для " p-user-name
      view-as alert-box .
  end.

end procedure. /* check-passwd */


procedure random-passwd :
  def var ind as integer no-undo .

  def var v-passwd as character no-undo .

  assign
    v-passwd = ""
  .

  do ind = 1 to 5
  :
    assign
      v-passwd = v-passwd + chr( random( asc('a'), asc('z') ) )
    .
  end.


  do ind = 1 to 3
  :
    assign
      v-passwd =  v-passwd + string(random( 0, 9 ))
    .
  end.

  message
    "Random password" skip
    v-passwd skip
    encode(v-passwd) skip
    view-as alert-box .

end procedure. /* random-passwd */



procedure permit-action :

  do
  on error undo, return error
  :
    assign
      p-permit = true
    .

  end.

end procedure. /* permit-action */