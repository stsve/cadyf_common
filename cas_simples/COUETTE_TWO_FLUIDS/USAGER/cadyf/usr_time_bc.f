* NOM      : USR_TIME_BC
* UTILITE  : Calcul la valeur d''une condition limite en instationnaire
* AUTHEUR  : Hristina Hristova
* VERSION  : Juillet 2002
* PROGRAMME: Cadyf
* RESUME   : Cette fonction calcule la valeur d''une condition limite sur la
*           sur la variable var, la courbe 'Courbe' aux coordonnees X, Y, Z
*
*        condition essentielle (Dirichlet)
*            si var = 'U', 'V', 'W', 'T', 'K', 'E'
*
*
* USAGE
*
*    L'appel au module :
*      condition =  USR_TIME_BC( var, courbe, x, y )
*
*    Les arguments d'entree:
*      var     : character*32 : identificateur de la variable...
*      courbe  : character*32 : identificateur de la courbe...
*      X, Y, Z : Coordonnees du noeud ou l'on impose le Dirichlet
*
*-----------------------------------------------------------+-----------
*          M O D I F I C A T I O N S                |  DATE
*-----------------------------------------------------------+-----------
*F======================================================================
*
      double precision function USR_TIME_BC
     &               ( Var, Courbe,
     &                 X0, Y0 , Z0 , ! configuration initiale
     &                 xsi, eta, zta) ! deplacements du maillage
*
      implicit none

*     --------
*     includes
*     --------
      include 'pastmp.inc'

*     ---------
*     arguments
*     ---------
      character*(*)     Var, Courbe
      double precision  X0, Y0, Z0
      double precision  xsi, eta, zta

*     -----------------
*     variables locales
*     -----------------
      integer           i
      double precision  xi, yi, zi, time

*     ----
*     code
*     ----

      ! Set time
      time = time1

      ! position courante des noeuds
      xi = x0 + xsi
      yi = y0 + eta
      zi = z0 + zta

      if( Var(1:1) .eq. 'U' ) then
         if ( yi .LE. 1.0d0 )  then
            usr_time_bc = 2.0d0/3.0d0*yi
         else
            usr_time_bc = 4.0d0/3.0d0*yi - 2.0d0/3.0d0
         end if

      elseif( Var(1:1) .eq. 'T' ) then
         if ( yi .LE. 1.0d0 )  then
            usr_time_bc = 4.0d0/3.0d0*yi
         else
            usr_time_bc = 2.0d0/3.0d0*yi + 2.0d0/3.0d0
         end if

      else
         write(*,*)'Identificateur de variable "',Var,'" est '//
     &     'inconnu dans sous-routine USR_TIME_BC'
         write(*,*)'Identificateur de Courbe "',courbe
         write(*,*) 'Arret du programme...'
         stop
      end if
      return
      end function
