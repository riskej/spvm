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

- (void) openZX_scr6144_n_rgb:(NSData*)datafile;
- (void) openZX_scr6912:(NSData*)datafile;

@end
