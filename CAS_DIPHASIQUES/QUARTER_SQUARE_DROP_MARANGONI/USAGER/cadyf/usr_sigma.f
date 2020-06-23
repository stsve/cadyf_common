      subroutine USR_SIGMA ( npgaus, x     , y     ,
     &                       t     , sigma , groupe)
*=======================================================================
*
* fonction : routine usager pour sigma
*
*=======================================================================

      use disks_mod, only: iprint

      USE time_module, only: time_tstart,
     &                       time_tfinal

      implicit none

*     --------
*     includes
*     --------
      include 'pastmp.inc'

*     ---------
*     arguments
*     ---------
      integer          npgaus
      integer          groupe
      double precision x (npgaus)
      double precision y (npgaus)
      double precision t (npgaus)
      double precision sigma (npgaus)

*     -----------------
*     variables locales
*     -----------------
      integer           i

      do i = 1, npgaus
         sigma(i) = 0.2d0 * sqrt(x(i)**2+y(i)**2)
      end do
*
      return
      end
