//
//  ViewController.m
//  Speccy Viewer
//
//  Created by riskej on 1/21/15.
//  Copyright (c) 2015 Simbolbit & Debris. All rights reserved.
//

#import "ViewController.h"
#import "RKJConverterToRGB.h"

@implementation ViewController {
    
    BOOL isLoadedFilePNG;
    BOOL isDropboxActive;
    BOOL isFlashImage;
    BOOL is6912Image;
    BOOL isMG1Image;
    BOOL check;
    BOOL isNoflicMode;
    
    NSImageView *screenToShow;
    NSImageView *screenToShow2;
    
}

    int kRetina;
    int border01, border02;
    NSUInteger incomingFileSize;
    NSImage *image01;
    NSImage *image02;

    NSData *currentData;
    NSURL *openedURL;

    NSColor *borderColor;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor = [[NSColor blackColor] CGColor];
    kRetina = 2;
    
//    screenToShow = [[NSImageView alloc] initWithFrame:NSMakeRect(32, 24, 256, 192)];
//    screenToShow.image = [NSImage imageNamed:@"animeeshon.png"];
//    
//    [self.view addSubview:screenToShow];
    
//    NSLog(@"%@", self.view.layer);
    
    [self convert6912Screen:2];
//    [self convert6144_n_rgb:1];
    
}


-(IBAction)openDocument:(id)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (openedURL in [panel URLs]) {
            
            [self preparingFilesToShow];
            
        }
    }
    
}

#pragma mark - Convert methods

- (void) convert6144_n_rgb:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);
//    NSData *data2 = [NSData dataWithContentsOfURL:[NSURL URLWithString :@"https://dl.dropboxusercontent.com/u/36464659/_apptest/np.scr"]];
    
    self.view.layer.backgroundColor = [[NSColor blackColor] CGColor];
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_scr6144_n_rgb:currentData];
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage;
    
    screenToShow = [[NSImageView alloc] initWithFrame:NSMakeRect(64, 48, 512, 384)];
    screenToShow.image = convertedImage.FinallyProcessedImage;

    
    screenToShow2 = [[NSImageView alloc] initWithFrame:NSMakeRect(64, 48, 512, 384)];
    screenToShow2.image = convertedImage.FinallyProcessedImage;

    [self.view addSubview:screenToShow];
}


- (void) convert6912Screen:(int) mode_scr {
    
    self.view.layer.backgroundColor = [[NSColor blackColor] CGColor];
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_scr6912:currentData];
    
    screenToShow = [[NSImageView alloc] initWithFrame:NSMakeRect(64, 48, 512, 384)];
    screenToShow.image = convertedImage.FinallyProcessedImage;

    
    [self.view addSubview:screenToShow];
    
}


- (void) convertImgMgx:(int) mode_scr {
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr = mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_img_mgX:currentData];
    
    border01 = convertedImage.BorderColor1;
    border02 = convertedImage.BorderColor2;
    
    [self getBorderColors];
    
    if (incomingFileSize != 13824) {
        self.view.layer.backgroundColor = [borderColor CGColor];
    }
    
    convertedImage.mode_scr = mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_img_mgX_noflic:currentData];
    
    screenToShow = [[NSImageView alloc] initWithFrame:NSMakeRect(64, 48, 512, 384)];
    screenToShow.image = convertedImage.FinallyProcessedImage;
    [self.view addSubview:screenToShow];
    
}


- (void) convertImgMg1 {
    NSLog(@"IMg1");
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_img_mg1:currentData];
    
    border01 = convertedImage.BorderColor1;
    border02 = convertedImage.BorderColor2;
    
    [self getBorderColors];
    self.view.layer.backgroundColor = [borderColor CGColor];
   
    convertedImage.mode_scr = 7;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_img_mg1_noflic:currentData];
    
    screenToShow = [[NSImageView alloc] initWithFrame:NSMakeRect(64, 48, 512, 384)];
    screenToShow.image = convertedImage.FinallyProcessedImage;
    [self.view addSubview:screenToShow];
    
}


- (void)drawRect:(NSRect)rect {
    // Clear the drawing rect.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void) preparingFilesToShow {
    
    currentData = [NSData dataWithContentsOfURL:openedURL];
    incomingFileSize = [currentData length];
    
    if (currentData != nil) {
     
        if (incomingFileSize == 6912) {
            [self convert6912Screen:2];
        }
        
        else if (incomingFileSize == 6144) {
            [self convert6144_n_rgb:1];
        }
        
        else if (incomingFileSize == 13824) {
            [self convertImgMgx:3];
        }
        
        else if (incomingFileSize == 14080) {
            [self convertImgMgx:4];
        }
        
        else if (incomingFileSize == 15616) {
            [self convertImgMgx:5];
        }
        
        else if (incomingFileSize == 18688) {
            [self convertImgMgx:6];
        }
        
        else if (incomingFileSize == 19456) {
            [self convertImgMg1];
        }
        
    }
    
}


- (void)getBorderColors {
    
    float border[3]={0,0.4609375,0.8039};
    float colRed = border[((border01 & 2) + (border02 & 2)) >>1];
    float colGreen = border[((border01 & 4) + (border02 & 4)) >>2];
    float colBlue = border[(border01 & 1) + (border02 & 1)];
    borderColor = [NSColor colorWithRed:colRed green:colGreen blue:colBlue alpha:1];
    
}


@end
