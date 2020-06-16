      subroutine usr_init ( ide, neq, u, coord, constr )
*=======================================================================
*
* fonction : definition des conditions initiales par l'usager
*            pour des problemes laminaires ou turbulents.
*
* notes : (1) constr =
*               .false. : on initialise les inconnues (ieq>0)
*               .true.  : on initialise les contraintes (ieq<0)
*                         (i.e. les dirichlets usages)
*
*=======================================================================

      use dof_mod, only: ndof, udof, vdof, wdof, tdof, pdof,
     &                   tkedof, edof, xidof, etadof

      implicit none
*
      include 'prbsiz.inc'
      include 'crdtyp.inc'
      include 'problm.inc'
      include 'timint.inc'
      include 'pastmp.inc'
      include 'parm2d.inc'
*
      integer          neq
      integer          ide  (numnp, ndof)
      double precision coord(numnp, ncoord)
      double precision u    (neq          )
      logical          constr
*
      logical          threed
      integer          i, j, ieq, ics
      real*8           xi, yi, zi, time
      logical          keps
      character*16     msg1
      character*20     msg2

      integer          colon
*=======================================================================

      threed = (idim .eq.3)
      keps   = (iturb.eq.2)

      if (constr) then
         write(msg1,'(A)') ' des contraintes'
      else
         write(msg1,'(A)') ' de la solution'
      endif

      write(msg2,'(A)') ' au temps ='

      print'(3A,X,1P,E23.15E3)', ' USR_INIT : Initialisation',
     &trim(msg1), trim(msg2), time1

      time = time1

! Signe des indices dans u
      if (constr) then
         ics = -1
      else
         ics = +1
      endif

      do i = 1, numnp

         xi = coord(i,1)
         yi = coord(i,2)
         if (threed) then
            zi = coord(i,3)
         else
            zi = 0.d0
         endif

         do j = 1, ndof
            ieq = ics*ide(i,j)

          ! traitement des inconnues
          ! note : la conversion en variable log
          !        est faite dans cadyf
            if (ieq.gt.0) then

               if      (j.eq.COLON(udof)) then
                  if ( yi .LE. 1.0d0 )  then
                     u(ieq) = 2.0d0/3.0d0*yi
                  else
                     u(ieq) = 4.0d0/3.0d0*yi - 2.0d0/3.0d0
                  end if

               else if (j.eq.COLON(tdof)) then
                  if ( yi .LE. 1.0d0 )  then
                     u(ieq) = 4.0d0/3.0d0*yi
                  else
                     u(ieq) = 2.0d0/3.0d0*yi + 2.0d0/3.0d0
                  end if

               else if (j.eq.COLON(vdof)) then
                  u(ieq) = 0.0d0

               else if (j.eq.COLON(pdof)) then
                  u(ieq) = 0.0d0

               else if (j.eq.COLON(xidof)) then
                  u(ieq) = 0.0d0

               else if (j.eq.COLON(etadof)) then
                  u(ieq) = 0.0d0

               else
                  u(ieq) = 0.0d0
               end if

            end if

         end do

      end do

* ==================================================================== *
      return
      end subroutine
* ==================================================================== *
