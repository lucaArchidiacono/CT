#include "utils_ctboard.h"
// Um die Adresse der DIPSW lesen zu koennen muss man zuerst folgenden header file inkludieren.
#include "reg_ctboard.h"

// Anschliessend kann man die Adresse definieren. All das und weiteres steht auf folgender Seite in ennis.zhaw.ch
// https://ennis.zhaw.ch/wiki/doku.php?id=ctboard:peripherals:dipsw
#define ADDR_DIPSW 	0x60000200
// Das gleiche gilt fuer diese Komponente. Hier noch die expliziete Seite in ennis.zhaw.ch
// https://ennis.zhaw.ch/wiki/doku.php?id=ctboard:peripherals:led
#define ADDR_LED		0x60000100

extern void out_word(uint32_t out_address, uint32_t out_value);
extern uint32_t in_word(uint32_t in_address);

int main() {	
	while (1) {
		uint32_t dipsw_values = in_word(ADDR_DIPSW);
		
		out_word(ADDR_LED, dipsw_values);	
	}
}
