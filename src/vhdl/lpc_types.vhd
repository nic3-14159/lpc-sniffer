library ieee;

package lpc_types is
    TYPE LPC_STATE IS (
        IDLE,
        START,
        CTDIR,
        SIZE,
        BM_TAR,
        TAR_A,
        TAR_B,
        ADDR_CHANNEL,
        DATA,
        SYNC
    );
    TYPE LPC_TYPE IS (
        MEM_R, --Memory Read
        MEM_W, --Memory Write
        IO_R, --IO Read
        IO_W, --IO Write
        DMA_R, --DMA Read
        DMA_W, --DMA Write
        BM_MEM_R, --Bus Mastering Memory Read
        BM_MEM_W, --Bus Mastering Memory Write
        BM_IO_R, --Bus Mastering IO Read
        BM_IO_W, --Bus Mastering IO Write
        OTHER
    );
end package;