//
//  RKJConverterToRGB.m
//  Speccy Viewer
//
//  Created by riskej on 1/21/15.
//  Copyright (c) 2015 Simbolbit & Debris. All rights reserved.
//

#import "RKJConverterToRGB.h"
#import <Cocoa/Cocoa.h>

@implementation RKJConverterToRGB {
    
    NSUInteger shiftPixelAdress;
    NSUInteger shiftZxcharAdress;
    
}

@synthesize mode_scr;
@synthesize kRetina;
@synthesize FinallyProcessedImage;
@synthesize FinallyProcessedImage2;
@synthesize BorderColor1;
@synthesize BorderColor2;


- (void) openZX_scr6144_n_rgb:(NSData*)datafile {
    
    UInt32 * inputPixels;
    
    NSUInteger inputWidth = 256*2;
    NSUInteger inputHeight = 192*2;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    
    
    for (NSUInteger yRetina = 0; yRetina < 2; yRetina++) {
        for (int line = 0; line < 192; line++) {
            [self calculateAddressForPixel:line andMode:mode_scr];
            for (int xchar = 0; xchar < 32; xchar++) {
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                if(mode_scr==1){
                    NSUInteger byte = byteData[shiftPixelAdress + xchar];
                    for (int xBit=128;xBit>0; xBit/=2) {
                        *inputPixel++ = byte & xBit ? 0xffffff : 0;
                        *inputPixel++ = byte & xBit ? 0xffffff : 0;
                    }
                }
                if(mode_scr==10) {
                    NSUInteger byteR = byteData[shiftPixelAdress + xchar];
                    NSUInteger byteG = byteData[shiftPixelAdress + xchar+6144];
                    NSUInteger byteB = byteData[shiftPixelAdress + xchar+12288];
                    
                    for (int xBit=128;xBit>0; xBit/=2) {
                        int pix = byteR & xBit ? 0xff : 0;
                        pix|= byteG & xBit ? 0xff00 : 0;
                        pix|= byteB & xBit ? 0xff0000 : 0;
                        *inputPixel++=pix;
                        *inputPixel++=pix;
                    }
                }
                
                
            }
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
//    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    free(inputPixels);
    
    NSRect rect = NSMakeRect(0.0, 0.0, 512, 384);
    rect.size.width = 512;
    rect.size.height = 384;
    NSImage * processedImage = [[NSImage alloc] initWithCGImage:newCGImage size:rect.size];

    FinallyProcessedImage = processedImage;
    
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newCGImage);
    CGContextRelease(context);
}

- (void) openZX_scr6912:(NSData*)datafile {
    
    NSLog(@"Screen: %i", (int)datafile.length);
    
    UInt32 * inputPixels_firstImage_noFlash;
    UInt32 * inputPixels_firstImage_invertedFlash;
    NSUInteger colorPalettePulsar [16] = {0x0, 0xca0000, 0x0000ca, 0xca00ca, 0x00ca00, 0xcaca00, 0x00caca, 0xcacaca,
        0x0, 0xfe0000, 0x0000fe, 0xfe00fe, 0x00fe00, 0xfefe00, 0x00fefe, 0xfefefe};
    
    
    
    NSUInteger inputWidth = 256*kRetina;
    NSUInteger inputHeight = 192*kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels_firstImage_noFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_firstImage_invertedFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    //    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString :@"https://dl.dropboxusercontent.com/u/36464659/_apptest/nday6144.scr"]];
    
    //    NSData *data = [NSData dataWithContentsOfFile:@"/Users/riskej/Documents/Developing/SpecViewT1/Files/nday6144.scr"];
    
    NSData *data = datafile;
    
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    
    // Draw Screen
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen = 0;
    NSUInteger firstByteOfCharsArrayOfFirstScreen = 6144;
    
    for (NSUInteger yRetina = 0; yRetina < kRetina; yRetina++) {
        
        for (int line=0; line<192; line++) {
            
            [self calculateAddressForPixel:line andMode:mode_scr];
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel_firstImage_noFlash = inputPixels_firstImage_noFlash + (line * kRetina + yRetina) * inputWidth + (xchar*8*kRetina);
                UInt32 * inputPixel_firstImage_invertedFlash = inputPixels_firstImage_invertedFlash + (line * kRetina + yRetina) * inputWidth + (xchar*8*kRetina);
                NSUInteger byte = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
                NSUInteger atr= byteData[firstByteOfCharsArrayOfFirstScreen + shiftZxcharAdress + xchar];
                bool flash = atr & 128;
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                
                for (int xBit=128;xBit>0; xBit/=2) {
                    UInt32 valNoFlash= byte & xBit ? (int)ink : (int)paper;
                    UInt32 valFlash= (bool) (byte & xBit) ^ flash ? (int)ink : (int)paper;
                    for(int xRetina=0;xRetina<kRetina;xRetina++) {
                        *inputPixel_firstImage_noFlash++ = valNoFlash;
                        *inputPixel_firstImage_invertedFlash++ = valFlash;
                    }
                }
            }
        }
    }
    
    
    
    CGContextRef context = CGBitmapContextCreate(inputPixels_firstImage_noFlash, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
//    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect: NSMakeRect(0, 0, inputWidth, inputHeight)];
//    CGImageRef newCGImage = [rep CGImage];
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
//    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    NSRect rect = NSMakeRect(0.0, 0.0, 512, 384);
    rect.size.width = 512;
    rect.size.height = 384;
    NSImage * processedImage = [[NSImage alloc] initWithCGImage:newCGImage size:rect.size];
    FinallyProcessedImage = processedImage;

    free(byteData);
        CGColorSpaceRelease(colorSpace);
    CGImageRelease(newCGImage);
    CGContextRelease(context);
    
}


-(void)calculateAddressForPixel:(int)line andMode:(int)mode {
    
    shiftPixelAdress = 2048*((line & 192) >> 6) + 32* ((line >> 3) & 7) + 256 * (line & 7);
    
    // modes =  1 - 6144
    //          2 - 6912
    //          3 - img(gsc)
    //          4 - mg8
    //          5 - mg4
    //          6 - mg2            Hi 4 Riski
    //          7 – mg1
    //          8 - mc
    //          9 - chr$
    //          10- rgb(3color)
    switch (mode) {
        case 2:
        case 3:
        case 4:
            shiftZxcharAdress = (line >> 3) * 32;
            break;
        case 5:
            shiftZxcharAdress  = (line >> 2)* 32;
            break;
        case 6:
            shiftZxcharAdress  = (line >> 1)* 32;
            break;
        case 7:
            shiftZxcharAdress  = line *16;
            break;
        case 8:
            shiftZxcharAdress = shiftPixelAdress = line * 32;
            break;
        default:
            break;
    }
    //    from Trefyushka
}


- (void) openZX_img_mgX:(NSData*)datafile {
    
    UInt32 * inputPixels_firstImage_noFlash;
    UInt32 * inputPixels_firstImage_invertedFlash;
    UInt32 * inputPixels_secondImage_noFlash;
    UInt32 * inputPixels_secondImage_invertedFlash;
    
    NSUInteger colorPalettePulsar [16] = {0x0, 0xca0000, 0x0000ca, 0xca00ca, 0x00ca00, 0xcaca00, 0x00caca, 0xcacaca,
        0x0, 0xfe0000, 0x0000fe, 0xfe00fe, 0x00fe00, 0xfefe00, 0x00fefe, 0xfefefe};
    
    NSUInteger colorTabMgs [16] = {0x0, 0xca0000, 0xfe0000, 0x0000ca, 0x0000fe, 0xca00ca, 0xfe00fe, 0x00ca00, 0x00fe00, 0xcaca00, 0xfefe00,  0x00caca, 0x00fefe, 0xcacaca, 0xfefefe};
    
    bool isInterlaceMode=true;
    
    NSUInteger inputWidth = 256*kRetina;
    NSUInteger inputHeight = 192*kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels_firstImage_noFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_firstImage_invertedFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_secondImage_noFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_secondImage_invertedFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen=0;
    NSUInteger firstByteOfPixelArrayOfSecondScreen=0;
    NSUInteger firstByteOfCharsArrayOfFirstScreen=0;
    NSUInteger firstByteOfCharsArrayOfSecondScreen=0;
    
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    NSUInteger chSize=byteData[4];
    NSUInteger chAnd=255*chSize;
    BorderColor1 = byteData [5];
    BorderColor2 = byteData [6];
    NSLog(@"border1: %i", BorderColor1);
    NSLog(@"border2: %i", BorderColor2);
    NSLog(@"screen length: %i", mode_scr);// (unsigned long)data.length);
    
    if (mode_scr==3) {
        firstByteOfPixelArrayOfFirstScreen = 0;
        firstByteOfCharsArrayOfFirstScreen = 6144;
        firstByteOfPixelArrayOfSecondScreen = 6912;
        firstByteOfCharsArrayOfSecondScreen = 6912+6144;
    }
    
    if (mode_scr==4) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+768;
    }
    
    if (mode_scr==5) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+1536;
    }
    
    if (mode_scr==6) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+3072;
    }
    if (mode_scr==11) {
        firstByteOfPixelArrayOfFirstScreen = 7;
        firstByteOfPixelArrayOfSecondScreen = 7+6144;
        firstByteOfCharsArrayOfFirstScreen = 12295;
        firstByteOfCharsArrayOfSecondScreen = 24583;
    }
    for (int line=0; line<192; line++) {
        
        [self calculateAddressForPixel:line andMode:mode_scr];
        
        for (int xchar=0; xchar<32; xchar++) {
            
            NSUInteger byte1 = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
            NSUInteger byte2 = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
            
            NSUInteger atr1= byteData[firstByteOfCharsArrayOfFirstScreen + shiftZxcharAdress + xchar];
            bool flash1 = atr1 & 128;
            NSUInteger bright1 = atr1 & 64 ? 8 : 0;
            NSUInteger ink1=(UInt32)colorPalettePulsar [(atr1 & 7) + bright1];
            NSUInteger paper1=(UInt32)colorPalettePulsar [(atr1 >> 3) & 7 + bright1];
            
            
            NSUInteger atr2= byteData[firstByteOfCharsArrayOfSecondScreen + shiftZxcharAdress + xchar];
            bool flash2 = atr2 & 128;
            NSUInteger bright2 = atr2 & 64 ? 8 : 0;
            NSUInteger ink2=(UInt32)colorPalettePulsar [(atr2 & 7) + bright2];
            NSUInteger paper2=(UInt32)colorPalettePulsar [(atr2 >> 3) & 7 + bright2];
            
            if(mode_scr==11) {
                byte1 = byteData[firstByteOfPixelArrayOfFirstScreen + line*32 + xchar];
                byte2 = byteData[firstByteOfPixelArrayOfSecondScreen + line*32 + xchar];
                ink1= byteData[firstByteOfCharsArrayOfFirstScreen + (line&chAnd)*32*2  + xchar*2];
                ink1=(UInt32)colorTabMgs [ink1];
                paper1=byteData[firstByteOfCharsArrayOfFirstScreen + (line&chAnd)*32*2  + xchar*2+1];
                paper1=(UInt32)colorTabMgs [paper1];
                
                ink2= byteData[firstByteOfCharsArrayOfSecondScreen + (line&chAnd)*32*2  + xchar*2];
                ink2=(UInt32)colorTabMgs [ink2];
                paper2=byteData[firstByteOfCharsArrayOfSecondScreen + (line&chAnd)*32*2  + xchar*2+1];
                paper2=(UInt32)colorTabMgs [paper2];
            }
            int xx=0;
            for (int xBit=128; xBit>0; xBit/=2,xx++) {
                UInt32 val_1_0=byte1 & xBit ? (int)ink1 : (int)paper1;
                UInt32 val_1_1=(bool) (byte1 & xBit) ^ flash1 ? (int)ink1 : (int)paper1;
                UInt32 val_2_0=byte2 & xBit ? (int)ink2 : (int)paper2;
                UInt32 val_2_1=(bool) (byte2 & xBit) ^ flash2 ? (int)ink2 : (int)paper2;
                for(int yRetina=0;yRetina<kRetina;yRetina++)
                {
                    NSUInteger adr = (line * kRetina + yRetina) * inputWidth + (xchar * 8 +xx) * kRetina;
                    UInt32 * inputPixel_firstImage_noFlash = inputPixels_firstImage_noFlash +adr;
                    UInt32 * inputPixel_firstImage_invertedFlash = inputPixels_firstImage_invertedFlash +adr;
                    UInt32 * inputPixel_secondImage_noFlash = inputPixels_secondImage_noFlash +adr;
                    UInt32 * inputPixel_secondImage_invertedFlash = inputPixels_secondImage_invertedFlash +adr;
                    for(int xRetina=0;xRetina<kRetina;xRetina++) {
                        *inputPixel_firstImage_noFlash++ = val_1_0;
                        *inputPixel_firstImage_invertedFlash++ = val_1_1;
                        *inputPixel_secondImage_noFlash++ = val_2_0;
                        *inputPixel_secondImage_invertedFlash++ = val_2_1;
                    }
                }
            }
        }
    }
    
    if (isInterlaceMode==true) {
        NSLog(@"Interlace");
        NSUInteger numberLines=96;
        NSUInteger numberBytes=inputWidth*kRetina;
        if(mode_scr==6) numberLines=48,numberBytes=inputWidth*2*kRetina;
        for (int line=0;line<numberLines;line++) {
            NSUInteger adr = line * numberBytes * 2;
            UInt32 * inputPixel_firstImage_noFlash = inputPixels_firstImage_noFlash + adr;
            UInt32 * inputPixel_firstImage_invertedFlash = inputPixels_firstImage_invertedFlash + adr;
            UInt32 * inputPixel_secondImage_noFlash = inputPixels_secondImage_noFlash + adr;
            UInt32 * inputPixel_secondImage_invertedFlash = inputPixels_secondImage_invertedFlash + adr;
            for(int i=0;i<numberBytes;i++) {
                UInt32 a=*inputPixel_firstImage_noFlash;// ^ 0xffffff;
                *inputPixel_firstImage_noFlash=*inputPixel_secondImage_noFlash;
                *inputPixel_secondImage_noFlash=a;
                
                a=*inputPixel_firstImage_invertedFlash;
                *inputPixel_firstImage_invertedFlash=*inputPixel_secondImage_invertedFlash;
                *inputPixel_secondImage_invertedFlash=a;
                
                inputPixel_firstImage_noFlash++;
                inputPixel_firstImage_invertedFlash++;
                inputPixel_secondImage_noFlash++;
                inputPixel_secondImage_invertedFlash++;
            }
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(inputPixels_firstImage_noFlash, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
//    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    NSRect rect = NSMakeRect(0.0, 0.0, 512, 384);
    rect.size.width = 512;
    rect.size.height = 384;
    NSImage * processedImage = [[NSImage alloc] initWithCGImage:newCGImage size:rect.size];
    FinallyProcessedImage = processedImage;
    
    CGContextRef context2 = CGBitmapContextCreate(inputPixels_secondImage_noFlash, inputWidth, inputHeight,
                                                  bitsPerComponent, inputBytesPerRow, colorSpace,
                                                  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage2 = CGBitmapContextCreateImage(context2);
//    CGContextDrawImage(context2, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage2);
    
    NSImage * processedImage2 = [[NSImage alloc] initWithCGImage:newCGImage size:rect.size];

    FinallyProcessedImage2 = processedImage2;
    
    free(inputPixels_firstImage_noFlash);
    free(inputPixels_secondImage_noFlash);
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context2);
    CGImageRelease(newCGImage);
    CGImageRelease(newCGImage2);
}


- (void) openZX_img_mgX_noflic:(NSData*)datafile {
    
    UInt32 * inputPixels_firstImage_noFlash;
    UInt32 * inputPixels_firstImage_invertedFlash;
    
    NSUInteger colorInkMgs [15] = {0, 1, 0101, 2, 0102, 3, 0103, 4, 0104, 5, 0105, 6, 0106, 7, 0107};
    NSUInteger colorPapMgs [15] = {0, 010, 0110, 020, 0120, 030, 0130, 040, 0140, 050, 0150, 060, 0160, 070, 0170};
    
    NSUInteger inputWidth = 256*kRetina;
    NSUInteger inputHeight = 192*kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels_firstImage_noFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_firstImage_invertedFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen=0;
    NSUInteger firstByteOfPixelArrayOfSecondScreen=0;
    NSUInteger firstByteOfCharsArrayOfFirstScreen=0;
    NSUInteger firstByteOfCharsArrayOfSecondScreen=0;
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    NSUInteger chSize=byteData[4];
    NSUInteger chAnd=255*chSize;
    BorderColor1 = byteData [5];
    BorderColor2 = byteData [6];
    NSLog(@"border1: %i", BorderColor1);
    NSLog(@"border2: %i", BorderColor2);
    NSLog(@"screen length: %i", mode_scr);// (unsigned long)data.length);
    
    if (mode_scr==3) {
        firstByteOfPixelArrayOfFirstScreen = 0;
        firstByteOfCharsArrayOfFirstScreen = 6144;
        firstByteOfPixelArrayOfSecondScreen = 6912;
        firstByteOfCharsArrayOfSecondScreen = 6912+6144;
    }
    
    if (mode_scr==4) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+768;
    }
    
    if (mode_scr==5) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+1536;
    }
    
    if (mode_scr==6) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+3072;
    }
    if (mode_scr==11) {
        firstByteOfPixelArrayOfFirstScreen = 7;
        firstByteOfPixelArrayOfSecondScreen = 7+6144;
        firstByteOfCharsArrayOfFirstScreen = 12295;
        firstByteOfCharsArrayOfSecondScreen = 24583;
    }
    for (int line=0; line<192; line++) {
        
        [self calculateAddressForPixel:line andMode:mode_scr];
        
        for (int xchar=0; xchar<32; xchar++) {
            
            int byte1 = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
            int atr1= byteData[firstByteOfCharsArrayOfFirstScreen + shiftZxcharAdress + xchar];
            
            
            int byte2 = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
            int atr2= byteData[firstByteOfCharsArrayOfSecondScreen + shiftZxcharAdress + xchar];
            
            
            if(mode_scr==11) {
                byte1 = byteData[firstByteOfPixelArrayOfFirstScreen + line*32 + xchar];
                byte2 = byteData[firstByteOfPixelArrayOfSecondScreen + line*32 + xchar];
                int ink1= byteData[firstByteOfCharsArrayOfFirstScreen + (line&chAnd)*32*2  + xchar*2];
                int paper1=byteData[firstByteOfCharsArrayOfFirstScreen + (line&chAnd)*32*2  + xchar*2+1];
                atr1=colorInkMgs[ink1] | colorPapMgs[paper1];
                
                int ink2= byteData[firstByteOfCharsArrayOfSecondScreen + (line&chAnd)*32*2  + xchar*2];
                int paper2=byteData[firstByteOfCharsArrayOfSecondScreen + (line&chAnd)*32*2  + xchar*2+1];
                atr2=colorInkMgs[ink2] | colorPapMgs[paper2];
            }
            int flash1 = atr1 & 128;
            int bright1 = atr1 & 64;
            int flash2 = atr2 & 128;
            int bright2 = atr2 & 64;
            // i - ink , p - paper
            UInt32 i1i2=[self calculateColorForGiga:atr1 :atr2];
            UInt32 i1p2=[self calculateColorForGiga:atr1 :(bright2|((atr2>>3)&7))];
            UInt32 p1i2=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :atr2];
            UInt32 p1p2=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :(bright2|((atr2>>3)&7))];
            
            int xx=0;
            for (int xBit=128; xBit>0; xBit/=2,xx++) {
                UInt32 val1 = 0;
                UInt32 val2 = 0;
                int px=byte1 & xBit ? 1 : 0;
                px+=byte2 & xBit ? 2 : 0;
                switch(px){
                    case 0: val1=p1p2;
                        break;
                    case 1: val1=i1p2;
                        break;
                    case 2: val1=p1i2;
                        break;
                    case 3: val1=i1i2;
                        break;
                }
                px=px ^ (flash1>>7) ^ (flash2>>6);
                switch(px){
                    case 0: val2=p1p2;
                        break;
                    case 1: val2=i1p2;
                        break;
                    case 2: val2=p1i2;
                        break;
                    case 3: val2=i1i2;
                        break;
                }
                for(int yRetina=0;yRetina<kRetina;yRetina++)
                {
                    NSUInteger adr = (line * kRetina + yRetina) * inputWidth + (xchar * 8 +xx) * kRetina;
                    UInt32 * inputPixel_firstImage_noFlash = inputPixels_firstImage_noFlash +adr;
                    UInt32 * inputPixel_firstImage_invertedFlash = inputPixels_firstImage_invertedFlash +adr;
                    for(int xRetina=0;xRetina<kRetina;xRetina++) {
                        *inputPixel_firstImage_noFlash++ = val1;
                        *inputPixel_firstImage_invertedFlash++ = val2;
                    }
                }
            }
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(inputPixels_firstImage_noFlash, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
// CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    NSRect rect = NSMakeRect(0.0, 0.0, 512, 384);
    rect.size.width = 512;
    rect.size.height = 384;
    NSImage * processedImage = [[NSImage alloc] initWithCGImage:newCGImage size:rect.size];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    FinallyProcessedImage = processedImage;
    
    CGContextRef context2 = CGBitmapContextCreate(inputPixels_firstImage_invertedFlash, inputWidth, inputHeight,
                                                  bitsPerComponent, inputBytesPerRow, colorSpace,
                                                  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage2 = CGBitmapContextCreateImage(context2);
//    CGContextDrawImage(context2, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage2);
    
    NSImage * processedImage2 = [[NSImage alloc] initWithCGImage:newCGImage2 size:rect.size];
    
    FinallyProcessedImage2 = processedImage2;
    
    free(inputPixels_firstImage_noFlash);
    free(inputPixels_firstImage_invertedFlash);
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context2);
    CGImageRelease(newCGImage);
    CGImageRelease(newCGImage2);
}


- (void) openZX_img_mg1:(NSData*)datafile {
    
    //    NSUInteger testArray[15] = [1, 2, 3];
    
    UInt32 * inputPixels;
    
    NSUInteger colorPalettePulsar [16] = {0x0, 0xca0000, 0x0000ca, 0xca00ca, 0x00ca00, 0xcaca00, 0x00caca, 0xcacaca,
        0x0, 0xfe0000, 0x0000fe, 0xfe00fe, 0x00fe00, 0xfefe00, 0x00fefe, 0xfefefe};
    
    //    NSUInteger colorPalettePulsar [16] = {0x0, 0x0000ea, 0xea0000, 0xea00ea, 0x00ea00, 0x00eaea, 0xeaea00, 0xeaeaea,
    //        0x0, 0x0000fe, 0xfe0000, 0xfe00fe, 0x00fe00, 0x00fefe, 0xfefe00, 0xfefefe};
    
    NSUInteger inputWidth = 256*2;
    NSUInteger inputHeight = 192*2;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen=256;
    NSUInteger firstByteOfPixelArrayOfSecondScreen=256+6144;
    NSUInteger firstByteOf_1_CharsArrayOfFirstScreen=256+6144*2;
    NSUInteger firstByteOf_1_CharsArrayOfSecondScreen=256+6144*2+3072;
    NSUInteger firstByteOf_8_CharsArrayOfFirstScreen=256+6144*3;
    NSUInteger firstByteOf_8_CharsArrayOfSecondScreen=256+6144*3+384;
    
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    BorderColor1 = byteData [5];
    BorderColor2 = byteData [6];
    //    NSLog(@"border1: %i", BorderColor1);
    //    NSLog(@"border2: %i", BorderColor2);
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    
    mode_scr = 7;
    
    NSUInteger shift_1_Zxchar=0;
    NSUInteger shift_8_Zxchar=0;
    
    NSUInteger atr=0;
    
    for (NSUInteger yRetina = 0; yRetina < 2; yRetina++) {
        
        for (int line=0; line<192; line++) {
            
            [self calculateAddressForPixel:line andMode:mode_scr];
            shift_8_Zxchar = (line>>3) * 16;
            shift_1_Zxchar = line * 16;
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                
                if (xchar>7 && xchar<24) atr = byteData[firstByteOf_1_CharsArrayOfFirstScreen + shift_1_Zxchar + xchar-8];
                else atr = byteData[firstByteOf_8_CharsArrayOfFirstScreen + shift_8_Zxchar + (xchar & 15)];
                
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                NSUInteger byte = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
                
                for (int xBit=128; xBit>0; xBit/=2) {
                    *inputPixel++ = byte & xBit ? (int)ink : (int)paper;
                    *inputPixel++ = byte & xBit ? (int)ink : (int)paper;
                }
            }
        }
    }
    
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
//    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
//    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    NSRect rect = NSMakeRect(0.0, 0.0, 512, 384);
    rect.size.width = 512;
    rect.size.height = 384;
    NSImage * processedImage = [[NSImage alloc] initWithCGImage:newCGImage size:rect.size];
    
    FinallyProcessedImage = processedImage;
    
    for (NSUInteger yRetina = 0; yRetina < 2; yRetina++) {
        
        for (int line=0; line<192; line++) {
            
            [self calculateAddressForPixel:line andMode:mode_scr];
            shift_8_Zxchar = (line>>3) * 16;
            shift_1_Zxchar = line * 16;
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                
                if (xchar>7 && xchar<24) atr= byteData[firstByteOf_1_CharsArrayOfSecondScreen + shift_1_Zxchar + xchar-8];
                else atr= byteData[firstByteOf_8_CharsArrayOfSecondScreen + shift_8_Zxchar + (xchar & 15)];
                
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                NSUInteger byte = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
                
                for (int xBit=128; xBit>0; xBit/=2) {
                    *inputPixel++ = byte & xBit ? (int)ink : (int)paper;
                    *inputPixel++ = byte & xBit ? (int)ink : (int)paper;
                }
            }
        }
    }
    
    CGContextRef context2 = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                  bitsPerComponent, inputBytesPerRow, colorSpace,
                                                  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage2 = CGBitmapContextCreateImage(context2);
//    CGContextDrawImage(context2, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage2);
//    UIImage * processedImage2 = [UIImage imageWithCGImage:newCGImage2];
    
    NSImage * processedImage2 = [[NSImage alloc] initWithCGImage:newCGImage2 size:rect.size];
    
    FinallyProcessedImage2 = processedImage2;
    
    free(inputPixels);
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context2);
    CGImageRelease(newCGImage);
    CGImageRelease(newCGImage2);
    
}

- (void) openZX_img_mg1_noflic:(NSData*)datafile {
    
    UInt32 * inputPixels;
    
    NSUInteger inputWidth = 256*kRetina;
    NSUInteger inputHeight = 192*kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen=256;
    NSUInteger firstByteOfPixelArrayOfSecondScreen=256+6144;
    NSUInteger firstByteOf_1_CharsArrayOfFirstScreen=256+6144*2;
    NSUInteger firstByteOf_1_CharsArrayOfSecondScreen=256+6144*2+3072;
    NSUInteger firstByteOf_8_CharsArrayOfFirstScreen=256+6144*3;
    NSUInteger firstByteOf_8_CharsArrayOfSecondScreen=256+6144*3+384;
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    BorderColor1 = byteData [5];
    BorderColor2 = byteData [6];
    //    NSLog(@"border1: %i", BorderColor1);
    //    NSLog(@"border2: %i", BorderColor2);
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    
    mode_scr = 7;
    
    NSUInteger shift_1_Zxchar=0;
    NSUInteger shift_8_Zxchar=0;
    int atr1=0;
    int atr2=0;
    
    for (int line=0; line<192; line++) {
        
        [self calculateAddressForPixel:line andMode:mode_scr];
        shift_8_Zxchar = (line>>3) * 16;
        shift_1_Zxchar = line * 16;
        
        for (int xchar=0; xchar<32; xchar++) {
            
            if (xchar>7 && xchar<24) {
                atr1 = byteData[firstByteOf_1_CharsArrayOfFirstScreen + shift_1_Zxchar + xchar-8];
                atr2 = byteData[firstByteOf_1_CharsArrayOfSecondScreen + shift_1_Zxchar + xchar-8];
            }
            else {
                atr1 = byteData[firstByteOf_8_CharsArrayOfFirstScreen + shift_8_Zxchar + (xchar & 15)];
                atr2 = byteData[firstByteOf_8_CharsArrayOfSecondScreen + shift_8_Zxchar + (xchar & 15)];
            }
            int byte1 = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
            int bright1 = atr1 & 64;
            
            int byte2 = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
            int bright2 = atr2 & 64;
            
            // i - ink , p - paper
            UInt32 i1i2=[self calculateColorForGiga:atr1 :atr2];
            UInt32 i1p2=[self calculateColorForGiga:atr1 :(bright2|((atr2>>3)&7))];
            UInt32 p1i2=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :atr2];
            UInt32 p1p2=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :(bright2|((atr2>>3)&7))];
            
            int xx=0;
            for (int xBit=128; xBit>0; xBit/=2,xx++) {
                UInt32 val1 = 0;
                int px=byte1 & xBit ? 1 : 0;
                px+=byte2 & xBit ? 2 : 0;
                switch(px){
                    case 0: val1=p1p2;
                        break;
                    case 1: val1=i1p2;
                        break;
                    case 2: val1=p1i2;
                        break;
                    case 3: val1=i1i2;
                        break;
                }
                for(int yRetina=0;yRetina<kRetina;yRetina++)
                {
                    NSUInteger adr = (line * kRetina + yRetina) * inputWidth + (xchar * 8 +xx) * kRetina;
                    UInt32 * inputPixel_firstImage_noFlash = inputPixels +adr;
                    for(int xRetina=0;xRetina<kRetina;xRetina++) {
                        *inputPixel_firstImage_noFlash++ = val1;
                    }
                }
            }
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
//    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    free(inputPixels);
    
    NSRect rect = NSMakeRect(0.0, 0.0, 512, 384);
    rect.size.width = 512;
    rect.size.height = 384;
    NSImage * processedImage = [[NSImage alloc] initWithCGImage:newCGImage size:rect.size];
    FinallyProcessedImage = processedImage;
    
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newCGImage);
    CGContextRelease(context);
}


-(void)reverse:(Byte*)byteData withCharN:(NSUInteger)ch charMode:(NSUInteger)chrMode {
    NSUInteger pixs=7 + ch * chrMode;
    int col=byteData[pixs+ chrMode-1];
    byteData[pixs + chrMode-1]=(col&64)+((col&7)<<3)+((col>>3)&7);
    for(int y=0;y<8;y++) byteData[pixs+y]^=255;
}

-(BOOL)compare:(Byte*)byteData Old:(NSUInteger)old New:(NSUInteger)new charMode:(NSUInteger)chrMode {
    
    int atrOld=byteData[7+ old * chrMode + chrMode-1];
    int atrNew=byteData[7+ new * chrMode + chrMode-1];
    int ink1=atrOld&7;
    int paper1=(atrOld>>3) & 7;
    int ink2=atrNew&7;
    int paper2=(atrNew>>3) & 7;
    
    if(ink2==paper1 || paper2==ink1) return true;
    
    return false;
}

-(BOOL)compareHorizontal:(Byte*)byteData Old:(NSUInteger)old New:(NSUInteger)new charMode:(NSUInteger)chrMode {
    
    NSUInteger atrOld=byteData[7+ old * chrMode + chrMode-1];
    NSUInteger atrNew=byteData[7+ new * chrMode + chrMode-1];
    NSUInteger ink1=atrOld&7;
    NSUInteger paper1=(atrOld>>3) & 7;
    NSUInteger ink2=atrNew&7;
    NSUInteger paper2=(atrNew>>3) & 7;
    
    NSUInteger contrast=0;
    NSUInteger charLeft=7+ old * chrMode;
    NSUInteger charRight=7+ new * chrMode;
    
    for(int i=0;i<8;i++) {
        int cL=byteData[charLeft+i] & 1;
        int cR=byteData[charRight+i] >> 7;
        if(!(cL ^ cR)) contrast++;
    }
    
    if(ink2==paper1 || paper2==ink1) return true;
    //if((ink1==ink2) && (paper1==paper2)) return false;
    if ((ink1==ink2) && (contrast>6)) return true;
    if ((paper1==paper2) && (contrast>6)) return true;
    
    return FALSE;
}


-(int)calculateColorForGiga:(NSUInteger)col1 :(NSUInteger)col2 {
    
    int colorGigaPalettePulsar [16] = {0x0, 0x76, 0x00, 0x9f, 0x76, 0xcd, 0x76, 0xe9, 0x00, 0x76, 0x00, 0x9f, 0x9f, 0xe9, 0x9f, 0xff};
    
    int r=colorGigaPalettePulsar[4*(((col1&64)>>5) + ((col1>>1) & 1)) + ((col2&64)>>5) + ((col2>>1) & 1)];
    int g=colorGigaPalettePulsar[4*(((col1&64)>>5) + ((col1>>2) & 1)) + ((col2&64)>>5) + ((col2>>2) & 1)];
    int b=colorGigaPalettePulsar[4*(((col1&64)>>5) + (col1 & 1)) + ((col2&64)>>5) + (col2 & 1)];
    int rgb=(b<<16) | (g<<8) | r;
    return rgb;
}

-(int)calculateColorForMetaGiga:(NSUInteger)col1 :(NSUInteger)col2 {
    
    int colorGigaPalettePulsar [16] = {0, 1, 0, 2, 1, 3, 1, 4, 0, 1, 0, 2, 2, 4, 2, 5};
    int r=colorGigaPalettePulsar[4*(((col1&64)>>5) + ((col1>>1) & 1)) + ((col2&64)>>5) + ((col2>>1) & 1)];
    int g=colorGigaPalettePulsar[4*(((col1&64)>>5) + ((col1>>2) & 1)) + ((col2&64)>>5) + ((col2>>2) & 1)];
    int b=colorGigaPalettePulsar[4*(((col1&64)>>5) + (col1 & 1)) + ((col2&64)>>5) + (col2 & 1)];
    int rgb=(b<<6) | (g<<3) | r;
    return rgb;
}


-(int)calculateColorForGiga_2:(int)col1 :(int)col2 {
    
    int colorGigaPalettePulsar [16] = {0, 1, 0, 2, 1, 3, 1, 4, 0, 1, 0, 2, 2, 4, 2, 5};
    
    int r=colorGigaPalettePulsar[4 * ((col1 & 1) *2 + ((col1>>2) & 1)) + (col2&1)*2 + ((col2>>2) & 1)];
    int g=colorGigaPalettePulsar[4 * ((col1 & 1) *2 + ((col1>>3) & 1)) + (col2&1)*2 + ((col2>>3) & 1)];
    int b=colorGigaPalettePulsar[4 * ((col1 & 1) *2 + ((col1>>1) & 1)) + (col2&1)*2 + ((col2>>1) & 1)];
    int rgb=(b<<6) | (g<<3) | r;
    return rgb;
}


-(int)calculateBright:(NSUInteger)col {
    if (col < 0x66) return 0;
    if (col < 0x8a) return 1;
    if (col < 0xb6) return 2;
    if (col < 0xdb) return 3;
    if (col < 0xf3) return 4;
    return 5;
}

-(NSUInteger)calculateGiga_colorMetaTable:(int*)iipp colors:(NSUInteger *)mt amount:(NSUInteger)amount {
    
    // p0p1 - 1   i0i1 - 2  i0p1 - 3   p0i1 - 4
    
    NSUInteger num=amount;
    if(amount > 3) num=4;
    int ipadr=0;
    int c0=mt[0];
    for(int atr1=0; atr1<128; atr1++) {
        for (int atr2=0; atr2<128; atr2++) {
            int ixip[4]={3,3,3,3};
            if(c0==iipp[ipadr+0] || c0==iipp[ipadr+1] || c0==iipp[ipadr+2] || c0==iipp[ipadr+3]) {
                int ifind=0;
                for (int i=0; i<num; i++) {
                    BOOL find=false;
                    if(mt[i]==iipp[ipadr+0]) ixip[0]=i, find=true;
                    if(mt[i]==iipp[ipadr+1]) ixip[1]=i, find=true;
                    if(mt[i]==iipp[ipadr+2]) ixip[2]=i, find=true;
                    if(mt[i]==iipp[ipadr+3]) ixip[3]=i, find=true;
                    if (find) ifind++;
                }
                if (ifind>=num) return (ixip[3]<<22) | (ixip[2]<<20) | (ixip[1]<<18) | (ixip[0]<<16) | (atr2<<8) | atr1;
            }
            ipadr+=4;
        }
    }
    return  0b111001000101010001001011;
}
-(int) get2colfrom1:(int)col1 {
    int c1=col1 & 15;
    c1=(c1>>1) + ((c1 & 1) << 3);
    int c2=(col1 >> 4) & 15;
    c2=(c2>>1) + ((c2 & 1) << 3);
    return (c1<<4) + c2;
}

-(void) convChr6912:(Byte*)byteData {
    Byte * newData=(Byte*)malloc(6912);
    NSUInteger src=7;
    for(int ch=0; ch<768; ch++) {
        NSUInteger adrpix=(ch>>8)*2048 + (ch&255);
        NSUInteger adratr=6144+ch;
        for(int i=0; i<8; i++) {
            newData[adrpix+i*256]=byteData[src++];
        }
        newData[adratr]=byteData[src++];
    }
    memcpy(byteData, newData, 6912);
    free(newData);
    
}


-(void) convChr2Img:(Byte*)byteData {
    Byte * newData=(Byte*)malloc(6912*2);
    NSUInteger src=7;
    for(int ch=0; ch<768; ch++) {
        NSUInteger adrpix=(ch>>8)*2048 + (ch&255);
        NSUInteger adratr=6144+ch;
        for(int i=0; i<8; i++) {
            newData[adrpix+i*256]=byteData[src++];
        }
        newData[adratr]=byteData[src++];
        for(int i=0; i<8; i++) {
            newData[6912+adrpix+i*256]=byteData[src++];
        }
        newData[6912+adratr]=byteData[src++];
    }
    memcpy(byteData, newData, 6912*2);
    free(newData);
}


-(int) convChr2Mgx:(Byte*)byteData mode:(NSUInteger)chMode{
    int atrInCh=2;
    int mode=4;
    int shift=1536;
    if(chMode==24) mode=8, atrInCh=4, shift=3072;
    int len=256+12288+(768*mode);
    Byte * newData=(Byte*)malloc(len);
    newData[0]='M'; // signature
    newData[1]='G';
    newData[2]='H';
    newData[3]=1; // version
    newData[4]=chMode > 21 ? 2 : 4; // char size
    newData[5]=0; // border 1
    newData[6]=0; // border 2
    
    for(int ch=0; ch<768; ch++) {
        NSUInteger adrpix=256 + (ch>>8)*2048 + (ch&255);
        NSUInteger atradr=256 + 12288 + (ch&0x3e0)*atrInCh + (ch&31);
        NSUInteger src=7 + ch*chMode;
        for(int i=0; i<8; i++) {
            newData[adrpix + i*256]=byteData[src + i];
            newData[adrpix + 6144 + i*256]=byteData[src + i + chMode/2];
        }
        for(int a=0; a<atrInCh; a++) {
            newData[atradr + a*32]=byteData[src + 8 + a];
            newData[atradr + a*32 + shift]=byteData[src + 8 + a + chMode/2];
        }
    }
    memcpy(byteData, newData, len);
    free(newData);
    return len;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
