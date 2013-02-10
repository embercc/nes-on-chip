#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"
#include "veriuser.h"

/*
int: 23:16, 15:8, 7:0
     r      g     b
           y    x
*/
int pixel[480][800]; 
int frame_count = 0;

unsigned char bmp_header[] = {
//  0      1      2      3      4      5      6      7      8      9      10     11     12     13     14     15
    0x42,  0x4d,  0x36,  0x94,  0x11,  0x00,  0x00,  0x00,  0x00,  0x00,  0x36,  0x00,  0x00,  0x00,  0x28,  0x00, 
    0x00,  0x00,  0x20,  0x03,  0x00,  0x00,  0xe0,  0x01,  0x00,  0x00,  0x01,  0x00,  0x18,  0x00,  0x00,  0x00,
    0x00,  0x00,  0x00,  0x94,  0x11,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,
    0x00,  0x00,  0x00,  0x00,  0x00,  0x00
};

extern"C" void dump_file();
extern"C" void set_pixel(int x, int y, int rgb);

extern "C" void dump_file(){
    io_printf("------------begin dump frame %02d --------\n", frame_count);
    char file_name[256];
    sprintf(file_name, "/workspace/nesdev/nes_project/bmps/%02d.bmp", frame_count);
    FILE* bmp_handle;
    bmp_handle = fopen(file_name, "wb");
    fwrite(bmp_header, 1, 0x36, bmp_handle);
    for(int y=0; y<480; y++){
        for(int x=0; x<800; x++){
            fwrite((char*)(&(pixel[y][x])), 1, 3, bmp_handle);
        }
    }
    
    
    fclose(bmp_handle);
    io_printf("------------frame %02d.bmp SAVED--------\n", frame_count);
    frame_count++;
}

extern "C" void set_pixel(int x, int y, int rgb){
    pixel[y%480][799 - x%800] = rgb;
}
