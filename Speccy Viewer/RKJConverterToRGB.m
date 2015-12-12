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
    //          6 - mg2
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
