/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами видов алкогольной продукции

Автор: Шкляр Елена
Дата создания: 04/10/16
Author: Shklyar Elena
Creation date: 04/10/16

*/



procedure alc-type-attr-value :

  define input  parameter p-alc-type-inner-code as integer   no-undo .  /* alc-type-inner-code */
  define input  parameter p-create-user-db-num  as integer   no-undo .  /* номер БД */
  define input  parameter p-code                as character no-undo .  /* код атрибута */

  define output parameter p-value               as character no-undo .  /* значение атрибута */
  define output parameter p-status              as integer   no-undo .
  define output parameter p-corr-date           as date      no-undo .  /*дата изменения*/
  define output parameter p-corr-time           as integer   no-undo .  /*время изменения*/
  define output parameter p-corr-user-name      as character no-undo .  /*кто внес последние изменения*/
  define output parameter p-create-date         as date      no-undo .  /*дата создания*/
  define output parameter p-create-time         as integer   no-undo .  /*время создания*/
  define output parameter p-create-user         as character no-undo .  /*кто создал*/
  
  define buffer buf_alc-type-attr for ub.alc-type-attr . 
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
      assign
        p-value           = buf_alc-type-attr.attr-value
        p-status          = buf_alc-type-attr.attr-status
        p-corr-date       = buf_alc-type-attr.corr-date
        p-corr-time       = buf_alc-type-attr.corr-time
        p-corr-user-name  = buf_alc-type-attr.corr-user-name
        p-create-date     = buf_alc-type-attr.create-date
        p-create-time     = buf_alc-type-attr.create-time
        p-create-user     = buf_alc-type-attr.create-user
      .
      end.
  end.
end procedure.


procedure alc-type-attr-val :

  define input  parameter p-alc-type-inner-code as integer   no-undo .  /* alc-type-inner-code */
  define input  parameter p-create-user-db-num  as integer   no-undo .  /* номер БД */
  define input  parameter p-code                as character no-undo .  /* код атрибута */

  define output parameter p-value               as character no-undo .  /* значение атрибута */
  
  define buffer buf_alc-type-attr for ub.alc-type-attr . 
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
      assign
        p-value           = buf_alc-type-attr.attr-value
      .
      end.
  end.
end procedure.

procedure alc-type-attr-write :

  define input  parameter p-alc-type-inner-code as integer   no-undo .  /* alc-type-inner-code */
  define input  parameter p-create-user-db-num  as integer   no-undo .  /* номер БД */
  define input  parameter p-code                as character no-undo .  /* код атрибута */

  define input parameter p-value                as character no-undo .  /* значение атрибута */
  define input parameter p-status               as integer   no-undo .
  define input parameter p-corr-date            as date      no-undo .  /*дата изменения*/
  define input parameter p-corr-time            as integer   no-undo .  /*время изменения*/
  define input parameter p-corr-user-name       as character no-undo .  /*кто внес последние изменения*/
  define input parameter p-create-date          as date      no-undo .  /*дата создания*/
  define input parameter p-create-time          as integer   no-undo .  /*время создания*/
  define input parameter p-create-user          as character no-undo .  /*кто создал*/
  
  define buffer buf_alc-type-attr for ub.alc-type-attr . 
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      
      if not available buf_alc-type-attr then do:
        create buf_alc-type-attr .
        assign
          buf_alc-type-attr.alc-type-inner-code = p-alc-type-inner-code
          buf_alc-type-attr.create-user-db-num  = p-create-user-db-num
          buf_alc-type-attr.attr-code           = p-code
          buf_alc-type-attr.attr-value          = p-value
          buf_alc-type-attr.attr-status         = p-status
          buf_alc-type-attr.corr-date           = p-corr-date
          buf_alc-type-attr.corr-time           = p-corr-time
          buf_alc-type-attr.corr-user-name      = p-corr-user-name
          buf_alc-type-attr.create-date         = p-create-date
          buf_alc-type-attr.create-time         = p-create-time
          buf_alc-type-attr.create-user         = p-create-user
        .
      end.
      else do:
      assign
          buf_alc-type-attr.attr-value          = p-value
          buf_alc-type-attr.attr-status         = p-status
          buf_alc-type-attr.corr-date           = p-corr-date
          buf_alc-type-attr.corr-time           = p-corr-time
          buf_alc-type-attr.corr-user-name      = p-corr-user-name
          buf_alc-type-attr.create-date         = p-create-date
          buf_alc-type-attr.create-time         = p-create-time
          buf_alc-type-attr.create-user         = p-create-user
      .
      end.
  end.
end procedure.



procedure alc-type-attr-delete :

  define input  parameter p-alc-type-inner-code as integer   no-undo .  /* alc-type-inner-code */
  define input  parameter p-create-user-db-num  as integer   no-undo .  /* номер БД */
  define input  parameter p-code                as character no-undo .  /* код атрибута */

  define buffer buf_alc-type-attr for ub.alc-type-attr . 
  do
  on error undo, return error
  :
       find first buf_alc-type-attr exclusive-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
        delete buf_alc-type-attr .
      end.
  end.
end procedure.



/* $Workfile$ e n d */