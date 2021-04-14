# See LICENSE for license details.

#*****************************************************************************
# mtimecmp.S
#-----------------------------------------------------------------------------
#
# Test the mtimecmp csr and timer interupt
#

#include "riscv_test.h"
#include "test_macros.h"

#define mtime 0xb01
#define mtimecmp 0xbc0

RVTEST_RV32M
RVTEST_CODE_BEGIN

  # This assumes the current mtime fits into one word
  csrr t0, mtime
  addi t0, t0, 1000
  csrw mtimecmp, t0
  li t0, (1 << 7) # Enable timer interupts
  csrrs zero, mie, t0
  li t0, (1 << 3) # Enable global interupts
  csrrs zero, mstatus, t0
1:
  wfi
  j 1b

  TEST_PASSFAIL

.global mtvec_handler
mtvec_handler:
  # Make sure CAUSE indicates a timer interrupt
  csrr t0, mcause
  li t1, 0x80000007
  bne t0, t1, fail
  j pass

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
