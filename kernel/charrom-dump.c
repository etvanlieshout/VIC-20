#include <stdio.h>
#include <stdlib.h>

/* Commodore chars are stored as 8x8 bitmaps (8 bytes total) */
struct CBM_char {
	unsigned long bitmap;
};

void cbmchar_print(unsigned long bitmap);

int main (int argc, char* argv[])
{
	/* cmdline args: 1 - Character ROM filename
	* 2 - Indicates either single char @ offset or whole ROM contents */
	if (argc < 2){
		printf("ERROR: No Character ROM file specified.\n");
		return -1;
	}

	FILE *fp = fopen(argv[1], "rb");
	if (!fp){
		printf("ERROR: File does not exist.\n");
		return -1;
	}

	// get single char or whole ROM
	if (argc > 2){
		unsigned int ROM_offset = atoi(argv[2]) * 8;
		if (ROM_offset > 256)
			ROM_offset = 256;
		struct CBM_char *cbmchar = malloc(sizeof(struct CBM_char));
		// get single char, print and return, else continue
		fseek(fp, ROM_offset, SEEK_SET);
		fread(cbmchar, sizeof(struct CBM_char), 1, fp);
		cbmchar_print(cbmchar->bitmap);
		return 0;
	}
	else {
		struct CBM_char *charray;
		charray = malloc(sizeof(struct CBM_char) * 256); //dump whole ROM
	}

	// not right
	fread(fp, sizeof(struct CBM_char), 1, fp);

	return 0;
}

void cbmchar_print(unsigned long bmp)
{
	char curr_map, bit, c;
	char *bitmap = (char *)&bmp;
	for (int i=0; i < 8; ++i){
		curr_map = *(bitmap + i);
		//printf("%c", curr_map); // prints ascii char to match hex dump
		for (int j=7; j >= 0; --j){
			bit = (curr_map >> j) & 0x01;
			c = bit ? 'X' : '.';
			printf("%c", c);
		}
		printf("\n");
	}
	printf("\n");
}
