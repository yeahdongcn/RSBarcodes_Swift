//
//  ContextMaker.h
//  RSBarcodes
//
//  Created by R0CKSTAR on 11/22/16.
//  Copyright (c) 2016 P.D.Q. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

// http://stackoverflow.com/questions/39939415/cicontext-initwithoptions-unrecognized-selector-sent-to-instance
@interface ContextMaker : NSObject

+ (CIContext *)make;

@end
