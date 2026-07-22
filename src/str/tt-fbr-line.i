
/*------------------------------------------------------------------------
    File        : tt-fbr-line
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SlivenkoSA
    Created     : Thu Sep 19 11:18:11 MSK 2024
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define temp-table tt-fbr-line no-undo
  field num as integer
  field gds-code as integer
  field gds-name as character
  field qnty as decimal
  field ingr-qnty as decimal
  field recipe-code like ub.recipe.recipe-code
  field recipe-type like ub.recipe.recipe-type
  field ingr-gds-code as integer
  field unit as character
  field mark-weight as decimal 
  field weighed as logical 
.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
