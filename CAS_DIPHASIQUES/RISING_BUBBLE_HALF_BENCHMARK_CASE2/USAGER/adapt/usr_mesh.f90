! NOM      : Usr_mesh
! UTILITE  : Determine la taille des mailles dans le domaine
! AUTEUR   : S. Etienne
! VERSION  : 2006
! PROGRAMME: Adapt
! RESUME   :
!
! USAGE
!
!    Arguments de base a l'entree:
!       coord................ coordonnees du noeud
!       dnode...............  raffinement demande
!       numnp...............  nombre de noeuds
!    Arguments complementaires :
!       xi .................. deplacement pseudo-solide selon x
!       eta.................. deplacement pseudo-solide selon y
!       k  .................. energie cinetique de turbulence
!       e  .................. dissipation de la turbulence
!       dpar................. distance a la plus proche paroi
!
!-----------------------------------------------------------+----------
!            M O D I F I C A T I O N S                      |  DATE
!-----------------------------------------------------------+----------
! Aucunes                                                   |
!----------------------------------------------------------------------
!======================================================================

      subroutine usr_mesh ( coord, dnode, numnp, k, e, dpar, xi, eta )

      implicit none

      !Arguments
      integer :: numnp
      real*8, dimension(numnp,*) :: coord
      real*8, dimension(numnp)   :: dnode
      real*8, dimension(numnp)   :: k
      real*8, dimension(numnp)   :: e
      real*8, dimension(numnp)   :: dpar
      real*8, dimension(numnp)   :: xi
      real*8, dimension(numnp)   :: eta

      character(len=32) :: FROM
      parameter          ( FROM = 'usr_mesh' )

      integer           :: i
      real*8            :: dmin, dmax, dcenter
      real*8            :: x, y, r
      real*8, parameter :: xc = 0.0d0
      real*8, parameter :: yc = 0.5d0

      dmin    = 2e-3
      dmax    = 1e-1
      dcenter = 1e-1

      do i = 1, NumNp
         x=coord(i,1); y=coord(i,2)
         r = sqrt((x-xc)**2+(y-yc)**2)

         if ( r .LE. 0.25d0 ) then
            dnode(i) = (dmin - dcenter) * r / 0.25d0 + dcenter
         else
            dnode(i) = MIN ( dmax, (dmax - dmin) * r / 0.25d0 + (2.0d0 * dmin - dmax) )
         end if
      end do

      return
      end subroutine
