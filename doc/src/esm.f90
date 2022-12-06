!
! Copyright (C) 2007-2011 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
! Original version by Minoru Otani (AIST), Yoshio Miura (Tohoku U.),
! Nicephore Bonet (MIT), Nicola Marzari (MIT), Brandon Wood (LLNL),
! Tadashi Ogitsu (LLNL).
! Constant bias potential (constant-mu) method by Minoru Otani (AIST) and
! Nicephore Bonnet (AIST).
!
! Contains SUBROUTINEs for implementation of
! 1) ESM (Effective Screening Medium Method) developed by M. Otani and
!    O. Sugino (see PRB 73, 115407 [2006])
! 2) Constant-mu method developed by N. Bonnet, T. Morishita, O. Sugino,
!    and M. Otani (see PRL 109, 266101 [2012]).
!
! ESM enables description of a surface slab sandwiched between two
! semi-infinite media, making it possible to deal with polarized surfaces
! without using dipole corrections. It is useful for simulating interfaces
! with vacuum, one or more electrodes, or an electrolyte.
!
! Constant-mu scheme with the boundary condition 'bc2' and 'bc3' enables
! description of the system is connected to a potentiostat which preserves
! the Fermi energy of the system as the target Fermi energy (mu).
!
! Modified SUBROUTINEs for calculating the Hartree potential, the local
! potential, and the Ewald sum are contained here, along with SUBROUTINEs for
! calculating force contributions based on the modified local potential and
! Ewald term. Constant-mu parts are contained in the fcp.f90.
!
!----------------------------------------------------------------------------
MODULE esm
  !--------------------------------------------------------------------------
  !
  ! ... this module contains the variables and SUBROUTINEs needed for the
  ! ... EFFECTIVE SCREENING MEDIUM (ESM) METHOD
  !
  USE kinds, ONLY : DP
  USE esm_common_mod
  USE esm_hartree_mod
  USE esm_ewald_mod
  USE esm_local_mod
  USE esm_force_mod
  USE esm_stres_mod
  !
  IMPLICIT NONE
  !
  SAVE
  !
  PRIVATE
  !
  PUBLIC :: do_comp_esm, esm_nfit, esm_efield, esm_w, esm_a, esm_bc, &
            mill_2d, imill_2d, ngm_2d, &
            esm_init, esm_z_inv, esm_hartree, esm_local, esm_ewald, &
            esm_force_lc, esm_force_ew, &
            esm_stres_har, esm_stres_ewa, esm_stres_loclong, &
            esm_printpot, esm_summary
  !
  LOGICAL :: do_comp_esm = .FALSE.
  !
CONTAINS
  !
  ! Checks inversion symmetry along z-axis
  !
  LOGICAL FUNCTION esm_z_inv(lrism)
    !
    USE constants, ONLY : eps14
    !
    IMPLICIT NONE
    !
    LOGICAL, INTENT(IN) :: lrism
    !
    esm_z_inv = .TRUE.
    !
    IF (do_comp_esm) THEN
      IF (TRIM(esm_bc) == 'bc1') THEN
        esm_z_inv = (.NOT. lrism)
      ELSE IF (TRIM(esm_bc) == 'bc2') THEN
        esm_z_inv = (ABS(esm_efield) < eps14)
      ELSE IF (TRIM(esm_bc) == 'bc3') THEN
        esm_z_inv = .FALSE.
      ELSE IF (TRIM(esm_bc) == 'bc4') THEN
        esm_z_inv = .FALSE.
      END IF
    END IF
    !
  END FUNCTION esm_z_inv
  !
END MODULE esm
