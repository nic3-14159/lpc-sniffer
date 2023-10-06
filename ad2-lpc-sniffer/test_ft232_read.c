#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <ftdi.h>

int main()
{
	int ret;
	uint8_t buffer[9182];
	struct ftdi_context *ftdi = ftdi_new();
	if (ftdi == NULL)
		return EXIT_FAILURE;
	if (ftdi_usb_open(ftdi, 0x0403, 0x6014) < 0) {
		fprintf(stderr, "Couldn't open device 0403:0604: %s\n",
		    ftdi_get_error_string(ftdi));
		ftdi_free(ftdi);
		return EXIT_FAILURE;
	}
	if (ftdi_set_bitmode(ftdi, 0xff, BITMODE_RESET) < 0) {
		fprintf(stderr, "Can't reset mode\n");
		return 1;
	}
	if (ftdi_set_bitmode(ftdi,  0xff, BITMODE_SYNCFF) < 0) {
		fprintf(stderr,"Can't set synchronous fifo mode: %s\n",
		ftdi_get_error_string(ftdi));
		return 1;
	}
	while (1) {
		ret = ftdi_read_data(ftdi, buffer, 9182);
		if (ret < 0) {
			printf("error: %d\n", ret);
			break;
		} else {
			/*
			printf("read %d bytes\n", ret);
			for (int i = 0; i < ret; i++) {
				printf("%02x ", buffer[i]);
				if (i % 16 == 15)
					printf("\n");
			}
			printf("\n");
				*/
			for (int i = 0; i < ret; i++)
				printf("%c", buffer[i]);
		}
	}

	if (ftdi_usb_close(ftdi) < 0) {
		fprintf(stderr, "Couldn't close device 0403:0604: %s\n",
		    ftdi_get_error_string(ftdi));
		ftdi_free(ftdi);
		return EXIT_FAILURE;
	}
	ftdi_free(ftdi);
	return 0;
}
