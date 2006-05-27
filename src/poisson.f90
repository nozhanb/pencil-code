! $Id: poisson.f90,v 1.3 2006-05-27 00:11:04 ajohan Exp $

!
!  This module solves the Poisson equation
!    (d^2/dx^2 + d^2/dy^2 + d^2/dz^2)f = rhs(x,y,z)
!  for the function f(x,y,z).
!

!** AUTOMATIC CPARAM.INC GENERATION ****************************
! Declare (for generation of cparam.inc) the number of f array
! variables and auxiliary variables added by this module
!
! MVAR CONTRIBUTION 0
! MAUX CONTRIBUTION 0
!
!***************************************************************

module Poisson

  use Cdata
  use Cparam
  use Messages
  use Mpicomm

  implicit none

  include 'poisson.h'

  contains

!***********************************************************************
    subroutine poisson_solver_fft(f,irhs,ipoisson,rhs_const)
!
!  Solve the Poisson equation by Fourier transforming on a periodic grid.
!
!  15-may-2006/anders+jeff: coded
!
      real, dimension (mx,my,mz,mvar+maux) :: f
      real :: rhs_const
      real, dimension (nx,ny,nz) :: a1,b1
      real, dimension(nxgrid) :: kx
      real, dimension(nygrid) :: ky
      real, dimension(nzgrid) :: kz
      integer :: irhs, ipoisson,i,ikx,iky,ikz
!
!  identify version
!
      if (lroot .and. ip<10) call cvs_id( &
        "$Id: poisson.f90,v 1.3 2006-05-27 00:11:04 ajohan Exp $")
!
!  populate wavenumber arrays
!
      if (nxgrid/=1) then
         kx=cshift((/(i-(nxgrid+1)/2,i=0,nxgrid-1)/),+(nxgrid+1)/2)*2*pi/Lx
      else
         kx=0
      endif

      if (nygrid/=1) then
         ky=cshift((/(i-(nygrid+1)/2,i=0,nygrid-1)/),+(nygrid+1)/2)*2*pi/Ly
      else
         ky=0
      endif

      if (nzgrid/=1) then
         kz=cshift((/(i-(nzgrid+1)/2,i=0,nzgrid-1)/),+(nzgrid+1)/2)*2*pi/Lz
      else
         kz=0
      endif
!
!  set up right-hand-side of Poisson equation
!
      if (ldensity_nolog) then
        a1 = rhs_const*f(l1:l2,m1:m2,n1:n2,ilnrho)
      else
        a1 = rhs_const*exp(f(l1:l2,m1:m2,n1:n2,ilnrho))
      endif

      b1 = 0.0
!  forward transform (to k-space)
      if (lshear) then
        call transform_fftpack_shear(a1,b1,1)
      else
        call transform_fftpack(a1,b1,1)
      endif
!
!  FT(phi) = -rhs_const*FT(rho)/k^2
!
      do ikz=1,nz; do iky=1,ny; do ikx=1,nx
        if ( (kx(ikx)==0.0) .and. (ky(iky)==0.0) .and. (kz(ikz)==0.0) ) then
          a1(ikx,iky,ikz) = 0.
          b1(ikx,iky,ikz) = 0.
        else
          a1(ikx,iky,ikz) = -a1(ikx,iky,ikz) &
              /(kx(ikx)**2 + ky(iky)**2 + kz(ikz)**2)
          b1(ikx,iky,ikz) = -b1(ikx,iky,ikz) &
              /(kx(ikx)**2 + ky(iky)**2 + kz(ikz)**2)
        endif
      enddo; enddo; enddo
!  inverse transform (to real space)
      if (lshear) then
        call transform_fftpack_shear(a1,b1,-1)
      else
        call transform_fftpack(a1,b1,-1)
      endif
!
      f(l1:l2,m1:m2,n1:n2,ipoisson) = a1
!
    endsubroutine poisson_solver_fft
!***********************************************************************

endmodule Poisson

