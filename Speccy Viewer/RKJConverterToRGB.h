//
//  RKJConverterToRGB.h
//  Speccy Viewer
//
//  Created by riskej on 1/21/15.
//  Copyright (c) 2015 Simbolbit & Debris. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <UIKit/UIKit.h>

@interface RKJConverterToRGB : NSView

@property (strong, nonatomic) NSImage *FinallyProcessedImage;
@property (strong, nonatomic) NSImage *FinallyProcessedImage2;
@property int mode_scr;
@property int kRetina;
@property int BorderColor1;
@property int BorderColor2;

- (void) openZX_scr6144_n_rgb:(NSData*)datafile;
- (void) openZX_scr6912:(NSData*)datafile;
- (void) openZX_img_mgX:(NSData*)datafile;
- (void) openZX_img_mgX_noflic:(NSData*)datafile;
- (void) openZX_img_mg1:(NSData*)datafile;
- (void) openZX_img_mg1_noflic:(NSData*)datafile;
- (void) openZX_chr:   (NSData*)datafile;
//-(int) convertPNGtoSCR:(UIImage *)inputImage;

@end
