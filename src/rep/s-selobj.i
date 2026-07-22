/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок для вызова списка объектов на 1 странице отчетов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/02
Author: Svetlana Chernova
Creation date: 03/03/02

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each {1}obj-list :
 delete {1}obj-list.
end.

str-obj#  = "" .
str-obj2# = "" .
str-obj3# = "" .


case selectobject :
when {&obj-currency} then do:
 run verify-check.
end.
when {&all} then   do:
 run sss.
end.
when "all" then   do:
 run sss.
end.
when {&obj-firm} then   do:
 run sss.
end.
when {&obj-choice} then do:
  for each {1}obj-list :
      delete {1}obj-list.
  end.

  define variable v-object-exist as logical   no-undo .
  { gbl/uobjexst.i
    v-object-exist
  }
  &if "{1}" <> "alt-" &then
  if not params-only and v-object-exist = false then do:
  { gbl/uobjapnd.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    }
     v-object-exist = true .
  end.
  &endif

  if my-request     = false
  or v-object-exist = false
  then do:
    define variable v-user-select as logical   no-undo .
    define variable v-recids as character no-undo .
    /*
    for each userobjs_temp-user-obj :
        message userobjs_temp-user-obj.obj-code .
    end.
    */
    if params-only then do:
    run ref/thobjs.w
        ( input my-handle
        , input this-procedure:handle
        , input (if params-only-mode = {&lookup} then "b-mark-hidden" else "b-mark,b-sel")
        , input {&all}
        , input '' /*p-obj-type*/
        , input ? /*p-db-num*/
        , input ? /*p-host-code*/
        , input-output v-recids ) no-error .
     end.
     else do:
        { gbl/uobjsman.i
          my-handle
          v-cntxt-db-num
          v-cntxt-userid
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          v-user-select
        }
     end.
  end.
  my-request = true .

  { gbl/uobjexst.i
    v-object-exist
  }
  if v-object-exist = false
  then do:
    if temp-param-obj-type = 'shop':u or temp-param-obj-type = 'stock':u then do:
      assign selectobject = {&obj-firm} .
    end.
    else do:
      assign selectobject = &if "{1}" = "alt-" &then "not":u &else "currency":u &endif .
    end.

    display selectobject with frame {&frame-name} .
    disable button-obj   with frame {&frame-name} .

    find cli-obj where cli-obj.obj-type = v-cntxt-obj-type and
                        cli-obj.obj-code = v-cntxt-obj-code no-lock .
    if temp-param-obj-type = 'shop':u or temp-param-obj-type = 'stock':u
    then do:
      run sss.
    end.
    else do:
      &if "{1}" <> "alt-" &then
      run verify-check.
      &endif
    end.
  end.
  else do:
      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
      define buffer buf_clients for ub.clients .
      define buffer buf_db for ub.db .
      define buffer buf_shop for ub.shop .
      define buffer buf_store for ub.store .
      define buffer buf_sysconf for ub.sysconf .

      for each buf_userobjs_temp-user-obj
      :
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
            and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
          .
          if verify-send-check  and buf_clients.db-num <> v-cntxt-db-num  and v-all-object = false then do:
                find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
                if buf_db.send-check = false then do:
                  str-obj2# = str-obj2#  + " " + buf_clients.obj-name + ",".
                  next.
                end.
          end.

          if temp-param-obj-type = 'shop':u and v-all-object = false then do:
              if buf_userobjs_temp-user-obj.obj-type = {&stock} then do:
                  str-obj# = str-obj#  +  " " +  buf_clients.obj-name  .
                  next.
                end.
          end.

          if temp-param-obj-type = 'stock':u and v-all-object = false then do:
              if buf_userobjs_temp-user-obj.obj-type = {&shop} then do:
                  str-obj# = str-obj#  +  " " +  buf_clients.obj-name  .
                  next.
              end.
          end.

          case buf_userobjs_temp-user-obj.obj-type:
              when {&stock} then
                  do:
                      find buf_store where buf_store.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                      find first buf_sysconf no-lock where buf_sysconf.host-code = buf_store.host-code no-error.
                      find first buf_clients no-lock where
                                  buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                  buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
                          .

                      if buf_sysconf.base-code = base-code or v-all-object = true
                          then do:
                              &if "{1}" = ""  &then
                              { cmp/cr-objls.i  buf_userobjs_temp-user-obj.obj-type  buf_userobjs_temp-user-obj.obj-code  }
                              &else
                              create {1}obj-list.
                              assign
                                  {1}obj-list.obj-name = buf_clients.obj-name
                                  {1}obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
                                  {1}obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code.
                              &endif
                          end.
                          else do:
                            str-obj# = str-obj#  +  " " +  buf_clients.obj-name + "," .
                          end.

                  end.
              when {&shop} then
                  do:
                      find first buf_shop where buf_shop.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                      find first buf_sysconf no-lock where buf_sysconf.host-code = buf_shop.host-code no-error.
                      find first buf_clients no-lock where
                                  buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                  buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.

                      if buf_sysconf.base-code = base-code or v-all-object = true
                            then do:
                              &if "{1}" = ""  &then
                              { cmp/cr-objls.i  buf_userobjs_temp-user-obj.obj-type  buf_userobjs_temp-user-obj.obj-code  }
                              &else
                              create {1}obj-list.
                              assign
                                  {1}obj-list.obj-name = buf_clients.obj-name
                                  {1}obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
                                  {1}obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code.
                              &endif
                          end.
                          else do:
                            str-obj# = str-obj#  +  " " +  buf_clients.obj-name + "," .
                          end.
                  end.
          end case.

        end.
    end.
end.
end case.
/* $Workfile$ e n d */